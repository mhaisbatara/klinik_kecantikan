import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';

enum PatientSyncStep { choose, formRegister, formClaim, formClaimOtp }

class PatientSyncSheet extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  final VoidCallback? onSuccess;
  final PatientSyncStep initialStep;

  const PatientSyncSheet({
    super.key,
    this.currentUser,
    this.onSuccess,
    this.initialStep = PatientSyncStep.choose,
  });

  static Future<bool?> show(
    BuildContext context, {
    Map<String, dynamic>? currentUser,
    PatientSyncStep initialStep = PatientSyncStep.choose,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PatientSyncSheet(
        currentUser: currentUser,
        initialStep: initialStep,
      ),
    );
  }

  @override
  State<PatientSyncSheet> createState() => _PatientSyncSheetState();
}

class _PatientSyncSheetState extends State<PatientSyncSheet> {
  late PatientSyncStep _currentStep;
  bool _isLoading = false;

  // ─── STATE & CONTROLLERS OPSI A (FORMULIR PASIEN BARU) ───
  int _activeTabA = 0; // 0: Data Diri, 1: Alamat, 2: Kontak & Darurat, 3: Alergi
  final Set<int> _submittedTabs = {};

  // Tab 0: Data Diri
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  DateTime? _tanggalLahirA;
  String _jenisKelamin = 'L';
  String _golonganDarah = '-';
  String _agama = 'Islam';
  String _statusPerkawinan = 'belum_menikah';
  String _kewarganegaraan = 'WNI';
  String _pekerjaan = 'Lainnya';
  final _pekerjaanLainnyaCtrl = TextEditingController();

  // Tab 1: Alamat & Wilayah
  String? _provinsi;
  String? _kodeProvinsi;
  String? _kotaKabupaten;
  String? _kodeKota;
  String? _kecamatan;
  String? _kodeKecamatan;
  String? _kelurahanDesa;
  String? _kodeKelurahan;
  final _kodePosCtrl = TextEditingController();
  final _patokanCtrl = TextEditingController();

  List<Map<String, dynamic>> _provList = [];
  List<Map<String, dynamic>> _kotaList = [];
  List<Map<String, dynamic>> _kecList = [];
  List<Map<String, dynamic>> _kelList = [];
  bool _isLoadingProv = false;
  bool _isLoadingKota = false;
  bool _isLoadingKec = false;
  bool _isLoadingKel = false;

  // Tab 2: Kontak & Darurat
  final _noHpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _namaKontakDaruratCtrl = TextEditingController();
  final _noHpKontakDaruratCtrl = TextEditingController();
  final _hubunganKontakCtrl = TextEditingController();

  // Tab 3: Alergi
  final _alergiCtrl = TextEditingController();

  // ─── STATE & CONTROLLERS OPSI B (KLAIM PASIEN LAMA) ──────
  final _noRmCtrl = TextEditingController();
  final _verifHpCtrl = TextEditingController();
  final _verifNikCtrl = TextEditingController();
  final _verifNamaCtrl = TextEditingController();
  DateTime? _tanggalLahirB;
  Map<String, dynamic>? _foundPatientData;
  bool _submittedClaim = false;

  // In-Sheet Toast Notification State
  String? _sheetToastMessage;
  bool _sheetToastIsSuccess = true;
  Timer? _sheetToastTimer;

  // Opsi B - Step OTP
  final _otpCtrl = TextEditingController();
  String? _maskedPhone;
  int _otpRemainingSeconds = 300;
  Timer? _otpTimer;
  String? _devOtpCode;
  bool _canResendOtp = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;

    // Listeners agar saat user mengetik, border merah langsung hilang real-time
    _namaCtrl.addListener(_onFieldChanged);
    _nikCtrl.addListener(_onFieldChanged);
    _noHpCtrl.addListener(_onFieldChanged);
    _alergiCtrl.addListener(_onFieldChanged);

    // Listeners agar jika user mengubah data pencarian verifikasi, data validasi di-reset
    _verifNikCtrl.addListener(_onVerifInputChanged);
    _verifHpCtrl.addListener(_onVerifInputChanged);
    _noRmCtrl.addListener(_onVerifInputChanged);

    // Pre-fill data akun user saat ini
    if (widget.currentUser != null) {
      final name = widget.currentUser?['fullname'] ?? widget.currentUser?['nama'];
      if (name != null) {
        _namaCtrl.text = name.toString();
        _verifNamaCtrl.text = name.toString();
      }
      final phone = widget.currentUser?['telp'];
      if (phone != null) {
        _noHpCtrl.text = phone.toString();
        _verifHpCtrl.text = phone.toString();
      }
      final rawEmail = widget.currentUser?['email'];
      final rawUsername = widget.currentUser?['username']?.toString();
      if (rawEmail != null) {
        _emailCtrl.text = rawEmail.toString();
      } else if (rawUsername != null && rawUsername.contains('@')) {
        _emailCtrl.text = rawUsername;
      }
    }

    _loadProvinces();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _onVerifInputChanged() {
    if (_foundPatientData != null) {
      setState(() {
        _foundPatientData = null;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _sheetToastTimer?.cancel();
    _namaCtrl.removeListener(_onFieldChanged);
    _nikCtrl.removeListener(_onFieldChanged);
    _noHpCtrl.removeListener(_onFieldChanged);
    _alergiCtrl.removeListener(_onFieldChanged);
    _verifNikCtrl.removeListener(_onVerifInputChanged);
    _verifHpCtrl.removeListener(_onVerifInputChanged);
    _noRmCtrl.removeListener(_onVerifInputChanged);

    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _pekerjaanLainnyaCtrl.dispose();
    _kodePosCtrl.dispose();
    _patokanCtrl.dispose();
    _noHpCtrl.dispose();
    _emailCtrl.dispose();
    _namaKontakDaruratCtrl.dispose();
    _noHpKontakDaruratCtrl.dispose();
    _hubunganKontakCtrl.dispose();
    _alergiCtrl.dispose();

    _noRmCtrl.dispose();
    _verifHpCtrl.dispose();
    _verifNikCtrl.dispose();
    _verifNamaCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ─── WILAYAH DATA LOADERS ──────────────────────────────────────
  Future<void> _loadProvinces() async {
    if (_provList.isNotEmpty) return;
    setState(() => _isLoadingProv = true);
    final list = await AuthService.getWilayahProvinsi();
    if (mounted) {
      setState(() {
        _provList = list;
        _isLoadingProv = false;
      });
    }
  }

  Future<void> _onProvinceSelected(Map<String, dynamic> item) async {
    final kode = item['kode']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama']?.toString() ?? item['name']?.toString() ?? '';
    setState(() {
      _kodeProvinsi = kode;
      _provinsi = nama;
      _kodeKota = null;
      _kotaKabupaten = null;
      _kodeKecamatan = null;
      _kecamatan = null;
      _kodeKelurahan = null;
      _kelurahanDesa = null;
      _kotaList = [];
      _kecList = [];
      _kelList = [];
      _isLoadingKota = true;
    });
    final list = await AuthService.getWilayahKota(kode);
    if (mounted) {
      setState(() {
        _kotaList = list;
        _isLoadingKota = false;
      });
    }
  }

  Future<void> _onKotaSelected(Map<String, dynamic> item) async {
    final kode = item['kode']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama']?.toString() ?? item['name']?.toString() ?? '';
    setState(() {
      _kodeKota = kode;
      _kotaKabupaten = nama;
      _kodeKecamatan = null;
      _kecamatan = null;
      _kodeKelurahan = null;
      _kelurahanDesa = null;
      _kecList = [];
      _kelList = [];
      _isLoadingKec = true;
    });
    final list = await AuthService.getWilayahKecamatan(kode);
    if (mounted) {
      setState(() {
        _kecList = list;
        _isLoadingKec = false;
      });
    }
  }

  Future<void> _onKecamatanSelected(Map<String, dynamic> item) async {
    final kode = item['kode']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama']?.toString() ?? item['name']?.toString() ?? '';
    setState(() {
      _kodeKecamatan = kode;
      _kecamatan = nama;
      _kodeKelurahan = null;
      _kelurahanDesa = null;
      _kelList = [];
      _isLoadingKel = true;
    });
    final list = await AuthService.getWilayahKelurahan(kode);
    if (mounted) {
      setState(() {
        _kelList = list;
        _isLoadingKel = false;
      });
    }
  }

  void _onKelurahanSelected(Map<String, dynamic> item) {
    final kode = item['kode']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama']?.toString() ?? item['name']?.toString() ?? '';
    setState(() {
      _kodeKelurahan = kode;
      _kelurahanDesa = nama;
    });
  }

  // ─── OTP TIMERS & TOAST ─────────────────────────────────────────
  void _startOtpTimer([int duration = 300]) {
    _otpTimer?.cancel();
    setState(() {
      _otpRemainingSeconds = duration;
      _canResendOtp = false;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpRemainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _otpRemainingSeconds = 0;
          _canResendOtp = true;
        });
      } else {
        setState(() {
          _otpRemainingSeconds--;
        });
      }
    });
  }

  String _formatOtpTimer() {
    final minutes = (_otpRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_otpRemainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showToast(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    _sheetToastTimer?.cancel();
    setState(() {
      _sheetToastMessage = message;
      _sheetToastIsSuccess = isSuccess;
      if (!isSuccess) {
        _errorMessage = message;
      }
    });

    _sheetToastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _sheetToastMessage = null;
        });
      }
    });
  }

  Future<void> _pickDate(bool isOptionA) async {
    final initial = isOptionA
        ? (_tanggalLahirA ?? DateTime(2000, 1, 1))
        : (_tanggalLahirB ?? DateTime(2000, 1, 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOptionA) {
          _tanggalLahirA = picked;
        } else {
          _tanggalLahirB = picked;
          _foundPatientData = null;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatDateDisplay(DateTime? dt) {
    if (dt == null) return 'YYYY-MM-DD';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  // ─── TAB NAVIGATION & VALIDATION OPSI A ──────────────────────────
  void _nextTabA() {
    setState(() => _submittedTabs.add(_activeTabA));
    if (_activeTabA == 0) {
      // Validasi Tab 0: Data Diri
      if (_namaCtrl.text.trim().isEmpty) {
        _showToast('Nama Lengkap Pasien wajib diisi', isSuccess: false);
        return;
      }
      final nik = _nikCtrl.text.trim();
      if (nik.length != 16 || int.tryParse(nik) == null) {
        _showToast('NIK wajib diisi tepat 16 digit angka', isSuccess: false);
        return;
      }
      if (_tanggalLahirA == null) {
        _showToast('Tanggal Lahir wajib diisi', isSuccess: false);
        return;
      }
      setState(() => _activeTabA = 1);
    } else if (_activeTabA == 1) {
      // Validasi Tab 1: Alamat
      if (_provinsi == null || _provinsi!.trim().isEmpty) {
        _showToast('Provinsi wajib dipilih', isSuccess: false);
        return;
      }
      setState(() => _activeTabA = 2);
    } else if (_activeTabA == 2) {
      // Validasi Tab 2: Kontak & Darurat
      if (_noHpCtrl.text.trim().isEmpty) {
        _showToast('Nomor HP (WhatsApp) wajib diisi', isSuccess: false);
        return;
      }
      setState(() => _activeTabA = 3);
    } else {
      // Tab 3: Submit Registrasi
      _submitRegisterPatient();
    }
  }

  // ─── SUBMIT OPSI A (PENDAFTARAN PASIEN BARU LENGKAP) ────────────
  Future<void> _submitRegisterPatient() async {
    setState(() => _submittedTabs.addAll([0, 1, 2, 3]));
    final nama = _namaCtrl.text.trim();
    final nik = _nikCtrl.text.trim();
    final tempat = _tempatLahirCtrl.text.trim();
    final noHp = _noHpCtrl.text.trim();
    final provinsi = _provinsi ?? '';

    if (nama.isEmpty) {
      setState(() => _activeTabA = 0);
      _showToast('Nama lengkap pasien wajib diisi', isSuccess: false);
      return;
    }
    if (nik.length != 16 || int.tryParse(nik) == null) {
      setState(() => _activeTabA = 0);
      _showToast('NIK wajib diisi tepat 16 digit angka', isSuccess: false);
      return;
    }
    if (_tanggalLahirA == null) {
      setState(() => _activeTabA = 0);
      _showToast('Tanggal lahir pasien wajib dipilih', isSuccess: false);
      return;
    }
    if (provinsi.isEmpty) {
      setState(() => _activeTabA = 1);
      _showToast('Provinsi domisili wajib dipilih', isSuccess: false);
      return;
    }
    if (noHp.isEmpty) {
      setState(() => _activeTabA = 2);
      _showToast('Nomor HP (WhatsApp) wajib diisi', isSuccess: false);
      return;
    }

    String finalPekerjaan = _pekerjaan;
    if (_pekerjaan == 'Lainnya' && _pekerjaanLainnyaCtrl.text.trim().isNotEmpty) {
      finalPekerjaan = _pekerjaanLainnyaCtrl.text.trim();
    }

    setState(() => _isLoading = true);

    final res = await AuthService.registerPatient(
      nama: nama,
      nik: nik,
      tempatLahir: tempat.isNotEmpty ? tempat : null,
      tanggalLahir: _formatDate(_tanggalLahirA),
      jenisKelamin: _jenisKelamin,
      golonganDarah: _golonganDarah != '-' ? _golonganDarah : null,
      agama: _agama,
      statusPerkawinan: _statusPerkawinan,
      kewarganegaraan: _kewarganegaraan,
      pekerjaan: finalPekerjaan,
      provinsi: provinsi,
      kotaKabupaten: _kotaKabupaten,
      kecamatan: _kecamatan,
      kelurahanDesa: _kelurahanDesa,
      kodePos: _kodePosCtrl.text.trim().isNotEmpty ? _kodePosCtrl.text.trim() : null,
      patokan: _patokanCtrl.text.trim().isNotEmpty ? _patokanCtrl.text.trim() : null,
      noHp: noHp,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      namaKontakDarurat: _namaKontakDaruratCtrl.text.trim().isNotEmpty ? _namaKontakDaruratCtrl.text.trim() : null,
      noHpKontakDarurat: _noHpKontakDaruratCtrl.text.trim().isNotEmpty ? _noHpKontakDaruratCtrl.text.trim() : null,
      hubunganKontakDarurat: _hubunganKontakCtrl.text.trim().isNotEmpty ? _hubunganKontakCtrl.text.trim() : null,
      alergi: _alergiCtrl.text.trim().isNotEmpty ? _alergiCtrl.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showToast('Selamat! Rekam Medis Anda berhasil diterbitkan.');
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      _showToast(res['message'] ?? 'Pendaftaran pasien baru gagal', isSuccess: false);
    }
  }

  // ─── SUBMIT OPSI B - PRA-VALIDASI DATA PASIEN SEBELUM OTP ─────────
  Future<void> _submitCheckClaimPatient() async {
    final noRm = _noRmCtrl.text.trim();
    final noHp = _verifHpCtrl.text.trim();
    final nik = _verifNikCtrl.text.trim();

    setState(() {
      _submittedClaim = true;
    });

    if (nik.isEmpty && noRm.isEmpty) {
      _showToast('Wajib memasukkan NIK KTP (16 digit) atau Nomor RM jika dulu mendaftar tanpa KTP', isSuccess: false);
      return;
    }
    if (nik.isNotEmpty && (nik.length != 16 || int.tryParse(nik) == null)) {
      _showToast('NIK KTP harus berisi tepat 16 digit angka', isSuccess: false);
      return;
    }
    if (_tanggalLahirB == null) {
      _showToast('Tanggal lahir sesuai KTP/klinik wajib dipilih', isSuccess: false);
      return;
    }
    if (noHp.isEmpty) {
      _showToast('Nomor WhatsApp / HP terdaftar wajib diisi', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.checkClaimPatient(
      noRm: noRm.isNotEmpty ? noRm : null,
      tanggalLahir: _formatDate(_tanggalLahirB),
      noHp: noHp,
      nik: nik.isNotEmpty ? nik : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true && res['data'] != null) {
      setState(() {
        _errorMessage = null;
        _foundPatientData = res['data'];
      });
      _showToast('Data rekam medis ditemukan! Silakan verifikasi identitas Anda.');
    } else {
      final msg = res['message'] ?? 'Verifikasi data rekam medis tidak sesuai';
      setState(() {
        _errorMessage = msg;
        _foundPatientData = null;
      });
      _showToast(msg, isSuccess: false);
    }
  }

  // ─── SUBMIT OPSI B - STEP 1 (REQUEST OTP KE NOMOR HP) ─────────
  Future<void> _submitRequestClaimOtp() async {
    final noRm = _noRmCtrl.text.trim();
    final noHp = _verifHpCtrl.text.trim();
    final nik = _verifNikCtrl.text.trim();

    setState(() {
      _submittedClaim = true;
    });

    if (nik.isEmpty && noRm.isEmpty) {
      _showToast('Wajib memasukkan NIK KTP (16 digit) atau Nomor RM jika dulu mendaftar tanpa KTP', isSuccess: false);
      return;
    }
    if (nik.isNotEmpty && (nik.length != 16 || int.tryParse(nik) == null)) {
      _showToast('NIK KTP harus berisi tepat 16 digit angka', isSuccess: false);
      return;
    }
    if (_tanggalLahirB == null) {
      _showToast('Tanggal lahir sesuai KTP/klinik wajib dipilih', isSuccess: false);
      return;
    }
    if (noHp.isEmpty) {
      _showToast('Nomor WhatsApp / HP terdaftar wajib diisi', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.requestClaimOtp(
      noRm: noRm.isNotEmpty ? noRm : null,
      tanggalLahir: _formatDate(_tanggalLahirB),
      noHp: noHp,
      nik: nik.isNotEmpty ? nik : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _errorMessage = null;
      final resData = res['data'] ?? {};
      _maskedPhone = resData['masked_phone']?.toString() ?? noHp;
      _devOtpCode = resData['dev_otp_code']?.toString();
      final expiresIn = resData['expires_in'] is int ? resData['expires_in'] as int : 300;
      _otpCtrl.clear();
      _startOtpTimer(expiresIn);

      setState(() => _currentStep = PatientSyncStep.formClaimOtp);
      _showToast(res['message'] ?? 'Kode OTP berhasil dikirimkan ke nomor HP terdaftar');
    } else {
      final msg = res['message'] ?? 'Verifikasi data rekam medis tidak sesuai';
      setState(() => _errorMessage = msg);
      _showToast(msg, isSuccess: false);
    }
  }

  // ─── SUBMIT OPSI B - STEP 2 (VERIFIKASI 6 DIGIT OTP) ────────────
  Future<void> _submitVerifyClaimOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6 || int.tryParse(otp) == null) {
      _showToast('Masukkan 6 digit angka kode OTP yang diterima', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.verifyClaimOtp(otpCode: otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _errorMessage = null;
      _otpTimer?.cancel();
      final rmFound = res['data']?['no_rm'] ?? '';
      _showToast(res['message'] ?? 'Berhasil terhubung! Nomor Rekam Medis Anda adalah $rmFound');
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      final msg = res['message'] ?? 'Verifikasi kode OTP gagal';
      setState(() => _errorMessage = msg);
      _showToast(msg, isSuccess: false);
    }
  }

  // ─── BUILD ROOT SHEET ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            18,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // In-Sheet Toast Notification Banner
          if (_sheetToastMessage != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _sheetToastIsSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _sheetToastIsSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_sheetToastIsSuccess ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _sheetToastIsSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: _sheetToastIsSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _sheetToastMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _sheetToastIsSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _sheetToastMessage = null);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _sheetToastIsSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep != PatientSyncStep.choose)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                  onPressed: () {
                    if (_currentStep == PatientSyncStep.formClaimOtp) {
                      setState(() => _currentStep = PatientSyncStep.formClaim);
                    } else if (_currentStep == PatientSyncStep.formRegister && _activeTabA > 0) {
                      setState(() => _activeTabA--);
                    } else {
                      setState(() => _currentStep = PatientSyncStep.choose);
                    }
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgMintLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_information_rounded, color: AppColors.primary, size: 20),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (_currentStep == PatientSyncStep.formRegister)
                      Text(
                        'Pendaftaran identitas, data profil, dan rekam medis pasien baru.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const Divider(height: 18),

          // Content Step
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildCurrentStepWidget(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case PatientSyncStep.choose:
        return 'Hubungkan Rekam Medis';
      case PatientSyncStep.formRegister:
        return 'Formulir Pasien Baru';
      case PatientSyncStep.formClaim:
        return 'Sinkronisasi Pasien Lama';
      case PatientSyncStep.formClaimOtp:
        return 'Verifikasi OTP WhatsApp';
    }
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case PatientSyncStep.choose:
        return _buildChooseStep();
      case PatientSyncStep.formRegister:
        return _buildFormRegisterStep();
      case PatientSyncStep.formClaim:
        return _buildFormClaimStep();
      case PatientSyncStep.formClaimOtp:
        return _buildFormClaimOtpStep();
    }
  }

  // ─── STEP 1: PILIH OPSI A ATAU B ──────────────────────────────
  Widget _buildChooseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Untuk melakukan reservasi dan mendapatkan riwayat medis klinik, akun Anda wajib terhubung dengan Rekam Medis (No. RM). Silakan pilih opsi di bawah ini:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // OPSI A: Pasien Baru
        _buildOptionCard(
          icon: Icons.person_add_alt_1_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.bgMintLight,
          badgeText: 'PASIEN BARU',
          title: 'Saya Belum Pernah ke Klinik',
          desc: 'Daftarkan diri Anda untuk pertama kali. Sistem klinik akan menerbitkan Nomor Rekam Medis (No. RM) baru secara otomatis.',
          buttonLabel: 'Daftar Pasien Baru',
          onTap: () => setState(() {
            _currentStep = PatientSyncStep.formRegister;
            _activeTabA = 0;
          }),
        ),

        const SizedBox(height: 14),

        // OPSI B: Pasien Lama
        _buildOptionCard(
          icon: Icons.person_search_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBg: const Color(0xFFE0F2FE),
          badgeText: 'PASIEN LAMA / PERNAH BEROBAT',
          title: 'Saya Pernah Berobat ke Klinik',
          desc: 'Tidak hafal Nomor RM? Cukup verifikasi dengan NIK atau No. HP & Tanggal Lahir. Sistem akan mencari Rekam Medis Anda secara otomatis.',
          buttonLabel: 'Cari & Hubungkan Rekam Medis',
          onTap: () => setState(() => _currentStep = PatientSyncStep.formClaim),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badgeText,
    required String title,
    required String desc,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(
                buttonLabel,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: FORMULIR PASIEN BARU (4 TABS SEPERTI DI WEB) ───────
  Widget _buildFormRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Navigasi Horizontal (Data Diri, Alamat, Kontak & Darurat, Alergi)
        _buildRegisterTabBar(),
        const SizedBox(height: 18),

        // Konten Tab yang sedang aktif
        IndexedStack(
          index: _activeTabA,
          children: [
            _buildTab0DataDiri(),
            _buildTab1Alamat(),
            _buildTab2KontakDarurat(),
            _buildTab3Alergi(),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Footer Action Buttons (Batal / Kembali di kiri, Selanjutnya / Daftarkan di kanan)
        _buildRegisterFooterButtons(),
      ],
    );
  }

  // Tab Bar dengan desain yang meniru web
  Widget _buildRegisterTabBar() {
    final tabs = [
      {'title': 'Data Diri', 'icon': Icons.person_outline_rounded},
      {'title': 'Alamat', 'icon': Icons.location_on_outlined},
      {'title': 'Kontak & Darurat', 'icon': Icons.phone_outlined},
      {'title': 'Alergi', 'icon': Icons.warning_amber_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _activeTabA == index;
          return InkWell(
            onTap: () {
              if (index > _activeTabA) {
                _nextTabA();
              } else {
                setState(() => _activeTabA = index);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    size: 16,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tabs[index]['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // TAB 0: DATA DIRI
  Widget _buildTab0DataDiri() {
    final isNamaInvalid = _submittedTabs.contains(0) && _namaCtrl.text.trim().isEmpty;
    final isNikEmpty = _nikCtrl.text.trim().isEmpty;
    final isNikLengthInvalid = !isNikEmpty && (_nikCtrl.text.trim().length != 16 || int.tryParse(_nikCtrl.text.trim()) == null);
    final isNikInvalid = _submittedTabs.contains(0) && (isNikEmpty || isNikLengthInvalid);
    final isTglLahirInvalid = _submittedTabs.contains(0) && _tanggalLahirA == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama Lengkap *
        _buildTextField(
          controller: _namaCtrl,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap pasien',
          icon: Icons.person_outline_rounded,
          isRequired: true,
          isInvalid: isNamaInvalid,
          errorMessage: isNamaInvalid ? 'Nama lengkap wajib diisi.' : null,
        ),
        const SizedBox(height: 14),

        // NIK (16 Digit) *
        _buildTextField(
          controller: _nikCtrl,
          label: 'NIK (16 Digit)',
          hint: '3515xxxxxxxxxxxx',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
          isRequired: true,
          isInvalid: isNikInvalid,
          errorMessage: isNikInvalid
              ? (isNikEmpty ? 'NIK wajib diisi (16 digit).' : 'NIK harus 16 digit angka.')
              : null,
        ),
        const SizedBox(height: 14),

        // Tempat Lahir & Tanggal Lahir
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _tempatLahirCtrl,
                label: 'Tempat Lahir',
                hint: 'Kota tempat lahir',
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePickerField(
                label: 'Tanggal Lahir',
                valueText: _tanggalLahirA != null ? _formatDateDisplay(_tanggalLahirA) : null,
                onTap: () => _pickDate(true),
                isRequired: true,
                isInvalid: isTglLahirInvalid,
                errorMessage: isTglLahirInvalid ? 'Tanggal lahir wajib diisi.' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Jenis Kelamin * (Dropdown matching web) & Golongan Darah
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Jenis Kelamin',
                value: _jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                icon: _jenisKelamin == 'L' ? Icons.male_rounded : Icons.female_rounded,
                isRequired: true,
                onTap: () {
                  _showOptionPicker(
                    title: 'Pilih Jenis Kelamin',
                    options: [
                      {'value': 'L', 'label': 'Laki-laki'},
                      {'value': 'P', 'label': 'Perempuan'},
                    ],
                    selectedValue: _jenisKelamin,
                    onSelect: (val) => setState(() => _jenisKelamin = val),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'Golongan Darah',
                value: _golonganDarah == '-' ? 'Pilih Golongan Darah' : _golonganDarah,
                hint: 'Pilih Golongan Darah',
                icon: Icons.water_drop_outlined,
                onTap: () {
                  _showOptionPicker(
                    title: 'Pilih Golongan Darah',
                    options: [
                      {'value': '-', 'label': 'Belum Tahu / -'},
                      {'value': 'A', 'label': 'A'},
                      {'value': 'B', 'label': 'B'},
                      {'value': 'AB', 'label': 'AB'},
                      {'value': 'O', 'label': 'O'},
                    ],
                    selectedValue: _golonganDarah,
                    onSelect: (val) => setState(() => _golonganDarah = val),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Agama & Status Perkawinan
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Agama',
                value: _agama,
                icon: Icons.mosque_outlined,
                onTap: () {
                  _showOptionPicker(
                    title: 'Pilih Agama',
                    options: [
                      {'value': 'Islam', 'label': 'Islam'},
                      {'value': 'Kristen', 'label': 'Kristen'},
                      {'value': 'Katolik', 'label': 'Katolik'},
                      {'value': 'Hindu', 'label': 'Hindu'},
                      {'value': 'Buddha', 'label': 'Buddha'},
                      {'value': 'Konghucu', 'label': 'Konghucu'},
                      {'value': 'Lainnya', 'label': 'Lainnya'},
                    ],
                    selectedValue: _agama,
                    onSelect: (val) => setState(() => _agama = val),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                label: 'Status Perkawinan',
                value: _getStatusPerkawinanLabel(_statusPerkawinan),
                icon: Icons.favorite_border_rounded,
                onTap: () {
                  _showOptionPicker(
                    title: 'Pilih Status Perkawinan',
                    options: [
                      {'value': 'belum_menikah', 'label': 'Belum Menikah'},
                      {'value': 'menikah', 'label': 'Menikah'},
                      {'value': 'cerai_hidup', 'label': 'Cerai Hidup'},
                      {'value': 'cerai_mati', 'label': 'Cerai Mati'},
                    ],
                    selectedValue: _statusPerkawinan,
                    onSelect: (val) => setState(() => _statusPerkawinan = val),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Kewarganegaraan
        _buildDropdownField(
          label: 'Kewarganegaraan',
          value: _kewarganegaraan == 'WNI' ? 'WNI (Warga Negara Indonesia)' : 'WNA (Warga Negara Asing)',
          icon: Icons.flag_outlined,
          onTap: () {
            _showOptionPicker(
              title: 'Pilih Kewarganegaraan',
              options: [
                {'value': 'WNI', 'label': 'WNI (Warga Negara Indonesia)'},
                {'value': 'WNA', 'label': 'WNA (Warga Negara Asing)'},
              ],
              selectedValue: _kewarganegaraan,
              onSelect: (val) => setState(() => _kewarganegaraan = val),
            );
          },
        ),
        const SizedBox(height: 14),

        // Pekerjaan & Pekerjaan Lainnya
        _buildDropdownField(
          label: 'Pekerjaan',
          value: _pekerjaan,
          icon: Icons.work_outline_rounded,
          onTap: () {
            _showOptionPicker(
              title: 'Pilih Pekerjaan',
              options: [
                {'value': 'Karyawan Swasta', 'label': 'Karyawan Swasta'},
                {'value': 'PNS / ASN', 'label': 'PNS / ASN'},
                {'value': 'Wiraswasta / Pengusaha', 'label': 'Wiraswasta / Pengusaha'},
                {'value': 'Ibu Rumah Tangga', 'label': 'Ibu Rumah Tangga'},
                {'value': 'Pelajar / Mahasiswa', 'label': 'Pelajar / Mahasiswa'},
                {'value': 'Dokter / Tenaga Kesehatan', 'label': 'Dokter / Tenaga Kesehatan'},
                {'value': 'TNI / POLRI', 'label': 'TNI / POLRI'},
                {'value': 'Professional / Konsultan', 'label': 'Professional / Konsultan'},
                {'value': 'Buruh / Pekerja Harian', 'label': 'Buruh / Pekerja Harian'},
                {'value': 'Pensiunan', 'label': 'Pensiunan'},
                {'value': 'Belum / Tidak Bekerja', 'label': 'Belum / Tidak Bekerja'},
                {'value': 'Lainnya', 'label': 'Lainnya'},
              ],
              selectedValue: _pekerjaan,
              onSelect: (val) => setState(() => _pekerjaan = val),
            );
          },
        ),

        if (_pekerjaan == 'Lainnya') ...[
          const SizedBox(height: 14),
          _buildTextField(
            controller: _pekerjaanLainnyaCtrl,
            label: 'Ketik Pekerjaan Lainnya',
            hint: 'Ketik detail pekerjaan...',
            icon: Icons.edit_note_rounded,
          ),
        ],
      ],
    );
  }

  String _getStatusPerkawinanLabel(String val) {
    switch (val) {
      case 'belum_menikah':
        return 'Belum Menikah';
      case 'menikah':
        return 'Menikah';
      case 'cerai_hidup':
        return 'Cerai Hidup';
      case 'cerai_mati':
        return 'Cerai Mati';
      default:
        return val;
    }
  }

  // TAB 1: ALAMAT CASCADING DROPDOWNS
  Widget _buildTab1Alamat() {
    final isProvInvalid = _submittedTabs.contains(1) && (_provinsi == null || _provinsi!.trim().isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provinsi *
        _buildDropdownField(
          label: 'Provinsi',
          value: _provinsi ?? 'Pilih Provinsi',
          hint: 'Pilih Provinsi',
          icon: Icons.map_outlined,
          isRequired: true,
          isLoading: _isLoadingProv,
          isInvalid: isProvInvalid,
          errorMessage: isProvInvalid ? 'Provinsi wajib dipilih.' : null,
          onTap: () {
            _showSearchablePicker(
              title: 'Pilih Provinsi',
              items: _provList,
              selectedCode: _kodeProvinsi,
              onSelect: (item) {
                _onProvinceSelected(item);
                setState(() {});
              },
            );
          },
        ),
        const SizedBox(height: 14),

        // Kota / Kabupaten
        _buildDropdownField(
          label: 'Kota / Kabupaten',
          value: _kotaKabupaten ?? (_kodeProvinsi == null ? 'Pilih Provinsi terlebih dahulu' : 'Pilih Kota / Kabupaten'),
          hint: 'Pilih Kota / Kabupaten',
          icon: Icons.apartment_rounded,
          isDisabled: _kodeProvinsi == null,
          isLoading: _isLoadingKota,
          onTap: () {
            if (_kodeProvinsi == null) {
              _showToast('Silakan pilih provinsi terlebih dahulu', isSuccess: false);
              return;
            }
            _showSearchablePicker(
              title: 'Pilih Kota / Kabupaten',
              items: _kotaList,
              selectedCode: _kodeKota,
              onSelect: _onKotaSelected,
            );
          },
        ),
        const SizedBox(height: 14),

        // Kecamatan
        _buildDropdownField(
          label: 'Kecamatan',
          value: _kecamatan ?? (_kodeKota == null ? 'Pilih Kota/Kabupaten terlebih dahulu' : 'Pilih Kecamatan'),
          hint: 'Pilih Kecamatan',
          icon: Icons.holiday_village_outlined,
          isDisabled: _kodeKota == null,
          isLoading: _isLoadingKec,
          onTap: () {
            if (_kodeKota == null) {
              _showToast('Silakan pilih kota/kabupaten terlebih dahulu', isSuccess: false);
              return;
            }
            _showSearchablePicker(
              title: 'Pilih Kecamatan',
              items: _kecList,
              selectedCode: _kodeKecamatan,
              onSelect: _onKecamatanSelected,
            );
          },
        ),
        const SizedBox(height: 14),

        // Kelurahan / Desa
        _buildDropdownField(
          label: 'Kelurahan / Desa',
          value: _kelurahanDesa ?? (_kodeKecamatan == null ? 'Pilih Kecamatan terlebih dahulu' : 'Pilih Kelurahan / Desa'),
          hint: 'Pilih Kelurahan / Desa',
          icon: Icons.signpost_outlined,
          isDisabled: _kodeKecamatan == null,
          isLoading: _isLoadingKel,
          onTap: () {
            if (_kodeKecamatan == null) {
              _showToast('Silakan pilih kecamatan terlebih dahulu', isSuccess: false);
              return;
            }
            _showSearchablePicker(
              title: 'Pilih Kelurahan / Desa',
              items: _kelList,
              selectedCode: _kodeKelurahan,
              onSelect: _onKelurahanSelected,
            );
          },
        ),
        const SizedBox(height: 14),

        // Kode Pos & Patokan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildTextField(
                controller: _kodePosCtrl,
                label: 'Kode Pos',
                hint: '60123',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 7,
              child: _buildTextField(
                controller: _patokanCtrl,
                label: 'Patokan / Alamat Detail',
                hint: 'Depan Masjid / Jalan Utama No. 12',
                icon: Icons.home_work_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // TAB 2: KONTAK & DARURAT
  Widget _buildTab2KontakDarurat() {
    final isNoHpInvalid = _submittedTabs.contains(2) && _noHpCtrl.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No. HP (WhatsApp) *
        _buildTextField(
          controller: _noHpCtrl,
          label: 'No. HP (WhatsApp)',
          hint: '081234567890',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          isRequired: true,
          isInvalid: isNoHpInvalid,
          errorMessage: isNoHpInvalid ? 'Nomor HP (WhatsApp) wajib diisi.' : null,
        ),
        const SizedBox(height: 14),

        // Email
        _buildTextField(
          controller: _emailCtrl,
          label: 'Email',
          hint: 'pasien@gmail.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Section Hubungan Kontak Darurat
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.emergency_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Kontak Darurat (Opsional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Nama Kontak Darurat
        _buildTextField(
          controller: _namaKontakDaruratCtrl,
          label: 'Nama Kontak Darurat',
          hint: 'Nama penanggung jawab',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),

        // No. HP Kontak Darurat & Hubungan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _noHpKontakDaruratCtrl,
                label: 'No. HP Darurat',
                hint: '081234567890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _hubunganKontakCtrl,
                label: 'Hubungan',
                hint: 'Orang Tua / Suami / Istri',
                icon: Icons.people_outline_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── TAB 3: ALERGI & CONTOH PILIHAN CEPAT ─────────────────────────
  void _toggleAlergi(String item) {
    setState(() {
      final current = _alergiCtrl.text.trim();
      if (item == 'Tidak Ada Alergi') {
        if (current.toLowerCase() == 'tidak ada riwayat alergi' || current.toLowerCase() == 'tidak ada') {
          _alergiCtrl.clear();
        } else {
          _alergiCtrl.text = 'Tidak ada riwayat alergi';
        }
        return;
      }

      // Jika sebelumnya terisi 'Tidak ada riwayat alergi', gantikan langsung
      if (current.toLowerCase() == 'tidak ada riwayat alergi' || current.toLowerCase() == 'tidak ada') {
        _alergiCtrl.text = item;
        return;
      }

      if (current.isEmpty) {
        _alergiCtrl.text = item;
        return;
      }

      final list = current
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.toLowerCase() != 'tidak ada riwayat alergi')
          .toList();

      if (list.any((s) => s.toLowerCase() == item.toLowerCase())) {
        list.removeWhere((s) => s.toLowerCase() == item.toLowerCase());
      } else {
        list.add(item);
      }

      _alergiCtrl.text = list.join(', ');
    });
  }

  bool _isAlergiSelected(String item) {
    final current = _alergiCtrl.text.trim().toLowerCase();
    if (item == 'Tidak Ada Alergi') {
      return current == 'tidak ada riwayat alergi' || current == 'tidak ada';
    }
    final list = current.split(',').map((s) => s.trim().toLowerCase()).toList();
    return list.contains(item.toLowerCase());
  }

  Widget _buildAlergiChip({
    required String label,
    required IconData icon,
    bool isNegative = false,
  }) {
    final isSelected = _isAlergiSelected(label);
    final primaryColor = isNegative ? const Color(0xFF16A34A) : AppColors.primary;
    final bgColor = isSelected
        ? (isNegative ? const Color(0xFFDCFCE7) : const Color(0xFFECFDF5))
        : const Color(0xFFF8FAFC);
    final borderColor = isSelected ? primaryColor : const Color(0xFFCBD5E1);
    final textColor = isSelected ? primaryColor : AppColors.textDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleAlergi(label),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : icon,
                size: 15,
                color: isSelected ? primaryColor : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab3Alergi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Riwayat Alergi (Obat / Makanan / Kosmetik)', isRequired: false),
            if (_alergiCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _alergiCtrl.clear();
                  });
                },
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Bersihkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _alergiCtrl,
          maxLines: 4,
          textAlignVertical: TextAlignVertical.top,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Tuliskan riwayat alergi jika ada (atau pilih contoh di bawah)...',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bagian Contoh Isi / Pilihan Cepat
        Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined, size: 16, color: Color(0xFFD97706)),
            const SizedBox(width: 6),
            Text(
              'Contoh Pilihan Cepat (Ketuk untuk mengisi):',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAlergiChip(
              label: 'Tidak Ada Alergi',
              icon: Icons.shield_outlined,
              isNegative: true,
            ),
            _buildAlergiChip(
              label: 'Parasetamol',
              icon: Icons.medication_outlined,
            ),
            _buildAlergiChip(
              label: 'Penisilin / Antibiotik',
              icon: Icons.medication_liquid_outlined,
            ),
            _buildAlergiChip(
              label: 'Seafood / Udang',
              icon: Icons.set_meal_outlined,
            ),
            _buildAlergiChip(
              label: 'Debu / Udara Dingin',
              icon: Icons.air_rounded,
            ),
            _buildAlergiChip(
              label: 'Kosmetik Tertentu',
              icon: Icons.face_retouching_natural_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kosongkan atau pilih "Tidak Ada Alergi" jika Anda tidak memiliki riwayat alergi obat atau kosmetik. Riwayat ini dicatat dokter untuk keselamatan resep & tindakan perawatan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // FOOTER ACTIONS OPSI A
  Widget _buildRegisterFooterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Batal / Kembali (kiri)
        if (_activeTabA == 0)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
            onPressed: () => setState(() => _currentStep = PatientSyncStep.choose),
          )
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text('Kembali', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
            onPressed: () => setState(() => _activeTabA--),
          ),

        // Tombol Selanjutnya / Submit (kanan)
        if (_activeTabA < 3)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text('Selanjutnya', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
            onPressed: _nextTabA,
          )
        else
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.check_circle_outline_rounded, size: 17),
            label: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Daftarkan Pasien Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
            onPressed: _isLoading ? null : _submitRegisterPatient,
          ),
      ],
    );
  }

  Widget _buildFoundDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF059669)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─── STEP 3: FORM KLAIM PASIEN LAMA (STRICT MULTI-FACTOR VERIFICATION) ──
  Widget _buildFormClaimStep() {
    final isNikEmpty = _submittedClaim && _verifNikCtrl.text.trim().isEmpty && _noRmCtrl.text.trim().isEmpty;
    final isNikInvalidFormat = _submittedClaim &&
        _verifNikCtrl.text.trim().isNotEmpty &&
        (_verifNikCtrl.text.trim().length != 16 || int.tryParse(_verifNikCtrl.text.trim()) == null);
    final isNikInvalid = isNikEmpty || isNikInvalidFormat;
    final nikErrorMessage = isNikEmpty
        ? 'NIK KTP wajib diisi (16 digit) atau isi Nomor RM'
        : (isNikInvalidFormat ? 'NIK KTP harus berisi tepat 16 digit angka' : null);

    final isDobInvalid = _submittedClaim && _tanggalLahirB == null;
    final dobErrorMessage = isDobInvalid ? 'Tanggal lahir pasien wajib dipilih' : null;

    final isHpEmpty = _submittedClaim && _verifHpCtrl.text.trim().isEmpty;
    final isHpInvalidFormat = _submittedClaim && _verifHpCtrl.text.trim().isNotEmpty && _verifHpCtrl.text.trim().length < 8;
    final isHpInvalid = isHpEmpty || isHpInvalidFormat;
    final hpErrorMessage = isHpEmpty
        ? 'Nomor WhatsApp / HP terdaftar wajib diisi'
        : (isHpInvalidFormat ? 'Nomor WhatsApp minimal 8 digit' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Demi perlindungan keamanan data medis, sistem menerapkan verifikasi ketat. Masukkan NIK KTP (16 digit), Tanggal Lahir, dan Nomor HP yang terdaftar di klinik. Jika dahulu Anda mendaftar tanpa KTP, Anda dapat menyertakan Nomor RM.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF15803D),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _verifNikCtrl,
          label: 'NIK KTP (16 Digit)',
          hint: '16 digit angka sesuai KTP',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
          isRequired: true,
          isInvalid: isNikInvalid,
          errorMessage: nikErrorMessage,
        ),
        const SizedBox(height: 12),

        _buildDatePickerField(
          label: 'Tanggal Lahir Sesuai KTP / Resepsionis',
          valueText: _tanggalLahirB != null ? _formatDateDisplay(_tanggalLahirB) : null,
          onTap: () => _pickDate(false),
          isRequired: true,
          isInvalid: isDobInvalid,
          errorMessage: dobErrorMessage,
        ),
        const SizedBox(height: 12),

        _buildTextField(
          controller: _verifHpCtrl,
          label: 'Nomor WhatsApp / HP Terdaftar',
          hint: 'Contoh: 081234567890',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isRequired: true,
          isInvalid: isHpInvalid,
          errorMessage: hpErrorMessage,
        ),
        const SizedBox(height: 12),

        _buildTextField(
          controller: _noRmCtrl,
          label: 'Nomor RM (Opsional - Diperlukan jika dulu daftar tanpa KTP)',
          hint: 'Contoh: RM-000001 (dari kartu / struk berobat)',
          icon: Icons.folder_shared_outlined,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            '*Kosongkan bila Anda sudah mengisi NIK 16 digit KTP di atas.',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 16),

        _buildInlineErrorBanner(),

        // JIKA SUDAH VALIDASI & DATA DITEMUKAN: TAMPILKAN KARTU KONFIRMASI IDENTITAS
        if (_foundPatientData != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rekam Medis Ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF065F46),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4ADE80)),
                      ),
                      child: Text(
                        _foundPatientData!['no_rm']?.toString() ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Icon(Icons.person_rounded, size: 24, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Pasien Terdaftar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _foundPatientData!['nama']?.toString() ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFBBF7D0)),
                const SizedBox(height: 10),

                _buildFoundDetailRow(Icons.credit_card_rounded, 'NIK KTP', _foundPatientData!['nik']?.toString() ?? '-'),
                const SizedBox(height: 6),
                _buildFoundDetailRow(
                  Icons.calendar_today_rounded,
                  'Tanggal Lahir',
                  _foundPatientData!['tanggal_lahir'] != null
                      ? _formatDateDisplay(DateTime.tryParse(_foundPatientData!['tanggal_lahir'].toString()) ?? _tanggalLahirB)
                      : '-',
                ),
                const SizedBox(height: 6),
                _buildFoundDetailRow(Icons.wc_rounded, 'Jenis Kelamin', _foundPatientData!['jenis_kelamin']?.toString() ?? '-'),
                if (_foundPatientData!['kota_kabupaten'] != null) ...[
                  const SizedBox(height: 6),
                  _buildFoundDetailRow(Icons.location_on_outlined, 'Wilayah', _foundPatientData!['kota_kabupaten'].toString()),
                ],

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_chat_unread_rounded, size: 18, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OTP akan dikirim ke WhatsApp: ${_foundPatientData!['masked_phone'] ?? _foundPatientData!['target_phone']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Pastikan data di atas adalah milik Anda sebelum meminta kode OTP.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Konfirmasi "Ya, Kirim OTP" dan "Bukan Data Saya"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.send_rounded, size: 18),
              label: _isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Ya, Benar — Kirim Kode OTP', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700)),
              onPressed: _isLoading ? null : _submitRequestClaimOtp,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text('Bukan Data Saya / Ubah Input', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600)),
              onPressed: () {
                setState(() {
                  _foundPatientData = null;
                  _errorMessage = null;
                });
              },
            ),
          ),
        ] else ...[
          // Tombol awal untuk validasi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.search_rounded, size: 18),
              label: _isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Periksa & Validasi Data Pasien', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700)),
              onPressed: _isLoading ? null : _submitCheckClaimPatient,
            ),
          ),
        ],
      ],
    );
  }

  // ─── STEP 4: FORM INPUT 6 DIGIT KODE OTP WHATSAPP ───────────────
  Widget _buildFormClaimOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_foundPatientData != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menghubungkan Rekam Medis: ${_foundPatientData!['nama']} (${_foundPatientData!['no_rm']})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_devOtpCode != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chat_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '📲 [Simulasi Pesan WhatsApp ke ${_maskedPhone ?? 'HP'}]:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Kode OTP Verifikasi Rekam Medis Anda adalah:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF047857)),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF34D399)),
                      ),
                      child: Text(
                        _devOtpCode!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.paste_rounded, size: 15),
                      label: Text(
                        'Salin & Pakai',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        _otpCtrl.text = _devOtpCode!;
                        _showToast('Kode OTP $_devOtpCode berhasil diterapkan');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.phone_android_rounded, color: Color(0xFF0284C7), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kode verifikasi 6 digit telah dikirimkan ke nomor WhatsApp / HP terdaftar ${_maskedPhone ?? 'Anda'}. Berlaku selama 5 menit.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF0369A1),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Center(
          child: Text(
            'Masukkan 6 Digit Kode OTP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(102), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _otpCtrl,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
              color: AppColors.primaryDark,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: '••••••',
              hintStyle: TextStyle(color: Colors.grey, letterSpacing: 8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _otpRemainingSeconds < 30 ? AppColors.error : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _otpRemainingSeconds > 0
                      ? 'Berlaku: ${_formatOtpTimer()}'
                      : 'Kode telah kedaluwarsa',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _otpRemainingSeconds < 30 ? AppColors.error : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (_canResendOtp)
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: const Color(0xFF0284C7),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Kirim Ulang OTP',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: _isLoading ? null : _submitRequestClaimOtp,
              )
            else
              Text(
                'Kirim ulang dalam ${_formatOtpTimer()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        _buildInlineErrorBanner(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.verified_user_rounded, size: 18),
            label: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Verifikasi & Hubungkan', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700)),
            onPressed: _isLoading ? null : _submitVerifyClaimOtp,
          ),
        ),
      ],
    );
  }

  // ─── PICKERS & MODAL BOTTOM SHEETS ──────────────────────────────
  void _showOptionPicker({
    required String title,
    required List<Map<String, String>> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = options[idx];
                      final isSel = item['value'] == selectedValue;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        title: Text(
                          item['label'] ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.primary : AppColors.textDark,
                          ),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          onSelect(item['value'] ?? '');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSearchablePicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required String? selectedCode,
    required ValueChanged<Map<String, dynamic>> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = items.where((it) {
              final name = (it['nama'] ?? it['name'] ?? '').toString().toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search Box
                  TextField(
                    onChanged: (val) => setModalState(() => query = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // List Wilayah
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              items.isEmpty ? 'Sedang memuat data wilayah...' : 'Tidak ada data yang cocok',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final it = filtered[idx];
                              final itCode = it['kode']?.toString() ?? it['id']?.toString() ?? '';
                              final itName = it['nama']?.toString() ?? it['name']?.toString() ?? '';
                              final isSel = itCode == selectedCode;

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                title: Text(
                                  itName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? AppColors.primary : AppColors.textDark,
                                  ),
                                ),
                                trailing: isSel
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                    : null,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onSelect(it);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── ATOMIC UI WIDGET BUILDERS ──────────────────────────────────
  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
    bool isRequired = false,
    bool isDisabled = false,
    bool isLoading = false,
    bool isInvalid = false,
    String? errorMessage,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 6),
        InkWell(
          onTap: isDisabled || isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDisabled
                  ? const Color(0xFFF1F5F9)
                  : (isInvalid ? const Color(0xFFFEF2F2) : AppColors.inputBg),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isInvalid ? const Color(0xFFEF4444) : AppColors.inputBorder,
                width: isInvalid ? 1.5 : 1.5,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: isInvalid
                        ? const Color(0xFFEF4444)
                        : (isDisabled ? Colors.grey : AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDisabled || value == hint ? AppColors.textLight : AppColors.textDark,
                      fontWeight: value == hint ? FontWeight.w400 : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isInvalid ? const Color(0xFFEF4444) : Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (isInvalid && errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    bool isRequired = false,
    bool isInvalid = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: (maxLines > 1 || icon == null)
                ? null
                : Icon(
                    icon,
                    size: 20,
                    color: isInvalid ? const Color(0xFFEF4444) : AppColors.primary,
                  ),
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textLight),
            filled: true,
            fillColor: isInvalid ? const Color(0xFFFEF2F2) : AppColors.inputBg,
            contentPadding: maxLines > 1
                ? const EdgeInsets.all(14)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isInvalid ? const Color(0xFFEF4444) : AppColors.inputBorder,
                width: isInvalid ? 1.5 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isInvalid ? const Color(0xFFEF4444) : AppColors.primary,
                width: 1.8,
              ),
            ),
          ),
        ),
        if (isInvalid && errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String? valueText,
    required VoidCallback onTap,
    bool isRequired = false,
    bool isInvalid = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isInvalid ? const Color(0xFFFEF2F2) : AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isInvalid ? const Color(0xFFEF4444) : AppColors.inputBorder,
                width: isInvalid ? 1.5 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: isInvalid ? const Color(0xFFEF4444) : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    valueText ?? 'YYYY-MM-DD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: valueText != null ? AppColors.textDark : AppColors.textLight,
                      fontWeight: valueText != null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isInvalid ? const Color(0xFFEF4444) : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isInvalid && errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInlineErrorBanner() {
    if (_errorMessage == null || _errorMessage!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
