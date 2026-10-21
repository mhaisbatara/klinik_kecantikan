import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';

enum PatientSyncStep { choose, formRegister, formClaim }

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

  // Controllers Opsi A (Pasien Baru)
  final _nikCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _alergiCtrl = TextEditingController();
  DateTime? _tanggalLahirA;
  String _jenisKelamin = 'P';

  // Controllers Opsi B (Klaim Pasien Lama)
  final _noRmCtrl = TextEditingController();
  final _verifHpCtrl = TextEditingController();
  final _verifNikCtrl = TextEditingController();
  DateTime? _tanggalLahirB;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    // Pre-fill nomor HP user saat ini jika ada
    if (widget.currentUser != null && widget.currentUser?['telp'] != null) {
      _verifHpCtrl.text = widget.currentUser!['telp'].toString();
    }
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _alergiCtrl.dispose();
    _noRmCtrl.dispose();
    _verifHpCtrl.dispose();
    _verifNikCtrl.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? AppColors.primaryDark : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
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
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatDateDisplay(DateTime? dt) {
    if (dt == null) return 'Pilih Tanggal Lahir';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  // ─── SUBMIT OPSI A (PASIEN BARU) ──────────────────────────────
  Future<void> _submitRegisterPatient() async {
    final nik = _nikCtrl.text.trim();
    final tempat = _tempatLahirCtrl.text.trim();
    final alamat = _alamatCtrl.text.trim();
    final alergi = _alergiCtrl.text.trim();

    if (nik.length != 16 || int.tryParse(nik) == null) {
      _showToast('NIK wajib diisi tepat 16 digit angka', isSuccess: false);
      return;
    }
    if (tempat.isEmpty) {
      _showToast('Tempat lahir wajib diisi', isSuccess: false);
      return;
    }
    if (_tanggalLahirA == null) {
      _showToast('Tanggal lahir wajib dipilih', isSuccess: false);
      return;
    }
    if (alamat.length < 3) {
      _showToast('Alamat domisili lengkap wajib diisi', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthService.registerPatient(
      nik: nik,
      tempatLahir: tempat,
      tanggalLahir: _formatDate(_tanggalLahirA),
      jenisKelamin: _jenisKelamin,
      alamat: alamat,
      alergi: alergi.isNotEmpty ? alergi : null,
      nama: widget.currentUser?['fullname'] ?? widget.currentUser?['nama'],
      noHp: widget.currentUser?['telp'],
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showToast('Selamat! Rekam Medis Anda berhasil diterbitkan.');
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      _showToast(res['message'] ?? 'Pendaftaran gagal', isSuccess: false);
    }
  }

  // ─── SUBMIT OPSI B (KLAIM PASIEN LAMA) ─────────────────────────
  Future<void> _submitClaimPatient() async {
    final noRm = _noRmCtrl.text.trim();
    final noHp = _verifHpCtrl.text.trim();
    final nik = _verifNikCtrl.text.trim();

    if (noRm.isEmpty) {
      _showToast('Nomor Rekam Medis (RM) klinik wajib diisi', isSuccess: false);
      return;
    }
    if (_tanggalLahirB == null) {
      _showToast('Tanggal lahir sesuai rekam medis klinik wajib dipilih', isSuccess: false);
      return;
    }
    if (noHp.isEmpty && nik.isEmpty) {
      _showToast('Masukkan Nomor HP atau NIK untuk verifikasi kepemilikan', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthService.claimPatient(
      noRm: noRm,
      tanggalLahir: _formatDate(_tanggalLahirB),
      noHp: noHp.isNotEmpty ? noHp : null,
      nik: nik.isNotEmpty ? nik : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showToast('Rekam Medis klinik berhasil ditautkan ke akun Anda!');
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      _showToast(res['message'] ?? 'Verifikasi data gagal', isSuccess: false);
    }
  }

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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep != PatientSyncStep.choose)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                  onPressed: () => setState(() => _currentStep = PatientSyncStep.choose),
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
                child: Text(
                  _getTitle(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
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
        return 'Daftar Pasien Baru';
      case PatientSyncStep.formClaim:
        return 'Sinkronisasi Pasien Lama';
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
    }
  }

  // ─── STEP 1: PILIH OPSI A ATAU B ──────────────────────────────
  Widget _buildChooseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner info
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
          onTap: () => setState(() => _currentStep = PatientSyncStep.formRegister),
        ),

        const SizedBox(height: 14),

        // OPSI B: Pasien Lama
        _buildOptionCard(
          icon: Icons.sync_lock_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBg: const Color(0xFFE0F2FE),
          badgeText: 'PASIEN LAMA / SUDAH PUNYA RM',
          title: 'Saya Sudah Memiliki No. RM',
          desc: 'Tautkan kartu pasien fisik / rekam medis klinik yang pernah Anda miliki ke akun mobile ini untuk mengakses riwayat tindakan Anda.',
          buttonLabel: 'Klaim / Hubungkan No. RM',
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
            color: Colors.black.withValues(alpha: 0.03),
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

  // ─── STEP 2: FORM PASIEN BARU (OPSI A) ────────────────────────
  Widget _buildFormRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lengkapi data pasien Anda sesuai KTP/Identitas resmi untuk penerbitan Rekam Medis klinik:',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 14),

        // NIK
        _buildTextField(
          controller: _nikCtrl,
          label: 'Nomor Induk Kependudukan (NIK)*',
          hint: '16 digit angka KTP',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        const SizedBox(height: 12),

        // Tempat Lahir
        _buildTextField(
          controller: _tempatLahirCtrl,
          label: 'Tempat Lahir*',
          hint: 'Contoh: Surabaya',
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 12),

        // Tanggal Lahir Picker
        _buildDatePickerField(
          label: 'Tanggal Lahir*',
          valueText: _tanggalLahirA != null ? _formatDateDisplay(_tanggalLahirA) : null,
          onTap: () => _pickDate(true),
        ),
        const SizedBox(height: 12),

        // Jenis Kelamin
        Text(
          'Jenis Kelamin*',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _jenisKelamin = 'P'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _jenisKelamin == 'P' ? AppColors.bgMintLight : AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _jenisKelamin == 'P' ? AppColors.primary : AppColors.inputBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.female_rounded, size: 18, color: _jenisKelamin == 'P' ? AppColors.primaryDark : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Perempuan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: _jenisKelamin == 'P' ? FontWeight.w700 : FontWeight.w500,
                          color: _jenisKelamin == 'P' ? AppColors.primaryDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _jenisKelamin = 'L'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _jenisKelamin == 'L' ? AppColors.bgMintLight : AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _jenisKelamin == 'L' ? AppColors.primary : AppColors.inputBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.male_rounded, size: 18, color: _jenisKelamin == 'L' ? AppColors.primaryDark : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Laki-laki',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: _jenisKelamin == 'L' ? FontWeight.w700 : FontWeight.w500,
                          color: _jenisKelamin == 'L' ? AppColors.primaryDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Alamat
        _buildTextField(
          controller: _alamatCtrl,
          label: 'Alamat Domisili Lengkap*',
          hint: 'Jalan, RT/RW, Kelurahan, Kecamatan',
          icon: Icons.home_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 12),

        // Riwayat Alergi (Opsional)
        _buildTextField(
          controller: _alergiCtrl,
          label: 'Riwayat Alergi Obat / Kosmetik (Opsional)',
          hint: 'Contoh: Alergi Alkohol, Seafood, Debu (kosongkan jika tidak ada)',
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(height: 20),

        // Tombol Submit
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _submitRegisterPatient,
            child: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Daftarkan Rekam Medis Baru', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // ─── STEP 3: FORM KLAIM PASIEN LAMA (OPSI B) ──────────────────
  Widget _buildFormClaimStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verifikasi 3 Kunci Keamanan: Pastikan No. RM, Tanggal Lahir, dan Nomor HP / NIK Anda cocok dengan database klinik.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF0369A1), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // No. RM
        _buildTextField(
          controller: _noRmCtrl,
          label: 'Nomor Rekam Medis (No. RM)*',
          hint: 'Contoh: RM-000001',
          icon: Icons.folder_shared_outlined,
        ),
        const SizedBox(height: 12),

        // Tanggal Lahir (Kunci 2)
        _buildDatePickerField(
          label: 'Tanggal Lahir Terdaftar*',
          valueText: _tanggalLahirB != null ? _formatDateDisplay(_tanggalLahirB) : null,
          onTap: () => _pickDate(false),
        ),
        const SizedBox(height: 12),

        // Nomor HP (Kunci 3 Opsi 1)
        _buildTextField(
          controller: _verifHpCtrl,
          label: 'Nomor WhatsApp / HP Terdaftar*',
          hint: 'Contoh: 081234567890',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        // NIK (Kunci 3 Opsi 2 / Opsional jika HP sudah cocok)
        _buildTextField(
          controller: _verifNikCtrl,
          label: 'Atau NIK KTP Terdaftar',
          hint: '16 digit angka KTP',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        const SizedBox(height: 20),

        // Tombol Submit
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _submitClaimPatient,
            child: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Verifikasi & Hubungkan No. RM', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String? valueText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    valueText ?? 'Pilih Tanggal Lahir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: valueText != null ? AppColors.textDark : AppColors.textLight,
                      fontWeight: valueText != null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
