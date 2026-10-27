import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLayanan;
  final Map<String, dynamic>? selectedCabang;
  final Map<String, dynamic>? klaimPaketData;
  final Map<String, dynamic>? pendingBooking;
  final String? initialKodeCabang;
  final String? initialNamaCabang;
  final bool isClaim;
  final String? kodeDetailKepemilikan;

  const BookingScreen({
    super.key,
    this.initialLayanan,
    this.selectedCabang,
    this.klaimPaketData,
    this.pendingBooking,
    this.initialKodeCabang,
    this.initialNamaCabang,
    this.isClaim = false,
    this.kodeDetailKepemilikan,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Mode Klaim Sisa Sesi Paket
  bool _isClaim = false;
  String? _kodeDetailKepemilikan;
  String? _namaPaketKlaim;

  // Multi-step Booking Flow:
  // 1: Pengisian Layanan, Alur Kunjungan, Jadwal & Catatan
  // 2: Rincian Reservasi & Pilihan Pembayaran DP (Gambar 1)
  // 3: Upload Bukti Pembayaran DP (Gambar 2)
  int _currentStep = 1;
  final ScrollController _scrollController = ScrollController();

  // Booking Pending (Terkunci jika sudah di langkah 3)
  Map<String, dynamic>? _createdBooking;
  bool _isPendingLocked = false;
  bool _creatingPending = false;

  // Data Pasien Login & Cabang Terpilih
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _activeCabang;

  // Pilihan Alur Konsultasi Pasien (Persis seperti di Web)
  // false: Langsung Tindakan, true: Konsultasi Dokter Dulu
  bool _pilihanKonsul = false;

  // Cabang Terpilih & Daftar Cabang
  List<Map<String, dynamic>> _cabangList = [];
  String? _selectedKodeCabang;
  String? _selectedNamaCabang;

  // Katalog Layanan, Paket Perawatan & Ruangan
  List<dynamic> _allLayanan = [];
  List<dynamic> _allPaket = [];
  String _activeCategoryTab = 'layanan'; // 'layanan' | 'paket'
  List<String> _roomList = ['Semua'];
  String _selectedRoom = 'Semua';
  bool _loadingLayanan = true;

  // Paket Perawatan Dimiliki Pasien (Multi-Sesi Klaim)
  List<Map<String, dynamic>> _claimableItems = [];

  // Selected Treatments (Multi-select dalam 1 ruangan)
  final List<Map<String, dynamic>> _selectedItems = [];
  String? _activeKodeRuangan;
  String? _activeNamaRuangan;

  // Tanggal & Jadwal
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  List<dynamic> _availableSlots = [];
  bool _loadingSlots = false;
  Map<String, dynamic>? _selectedSlot;
  String? _selectedJamBooking;

  // DP & Metode Pembayaran
  String _metodeDp = 'transfer'; // 'transfer' | 'qris'
  bool _persetujuanDp = false;
  XFile? _buktiDpImage;
  Uint8List? _buktiDpBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickBuktiDp(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _buktiDpImage = picked;
          _buktiDpBytes = bytes;
        });
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        _showToast(
          'Plugin gambar belum terdaftar pada server yang sedang berjalan. Silakan stop (Ctrl+C) lalu jalankan ulang "flutter run".',
          isError: true,
        );
      } else {
        _showToast('Gagal memilih gambar: $e', isError: true);
      }
    }
  }

  void _removeBuktiDp() {
    setState(() {
      _buktiDpImage = null;
      _buktiDpBytes = null;
    });
  }

  // Master Rekening & QRIS Dinamis dari Web
  bool _loadingPaymentMethods = false;
  List<dynamic> _rekeningList = [];
  Map<String, dynamic>? _selectedRekening;
  Map<String, dynamic>? _qrisData;

  // Catatan Keluhan
  final _catatanCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _isClaim = widget.isClaim || (widget.initialLayanan?['is_claim_packet'] == true);
    _kodeDetailKepemilikan = widget.kodeDetailKepemilikan ??
        widget.initialLayanan?['kode_detail_kepemilikan_paket_layanan']?.toString();
    _namaPaketKlaim = widget.initialLayanan?['nama_paket']?.toString();

    _activeCabang = widget.selectedCabang;
    if (widget.pendingBooking != null) {
      _createdBooking = Map<String, dynamic>.from(widget.pendingBooking!);
      _isPendingLocked = true;
      _currentStep = 3;
      _metodeDp = _createdBooking?['metode_pembayaran_dp'] ?? 'transfer';
      _selectedJamBooking = _createdBooking?['jam_booking'];
      if (_createdBooking?['tanggal_booking'] != null) {
        try {
          _selectedDate = DateTime.parse(_createdBooking!['tanggal_booking']);
        } catch (_) {}
      }
      final rawItems = _createdBooking?['items'];
      if (rawItems is List) {
        for (final it in rawItems) {
          if (it is Map) {
            _selectedItems.add(Map<String, dynamic>.from(it));
          }
        }
      }
    }

    _selectedKodeCabang = widget.initialKodeCabang ?? widget.selectedCabang?['kode_cabang'] ?? widget.initialLayanan?['kode_cabang'];
    final rawInitNama = widget.initialNamaCabang ?? widget.selectedCabang?['nama_cabang'] ?? widget.initialLayanan?['nama_cabang'];
    _selectedNamaCabang = rawInitNama != null ? _formatBranchName(rawInitNama) : null;
    _loadUser();
    _fetchCabangList();
    _fetchLayanan();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() => _loadingPaymentMethods = true);
    final res = await BookingService.getMetodePembayaran(
      kodeCabang: _activeCabang?['kode_cabang'],
    );
    if (!mounted) return;
    setState(() {
      _loadingPaymentMethods = false;
      final grouped = res['grouped'] ?? (res['data']?['grouped'] ?? {});
      final rekList = List<dynamic>.from(grouped['rekening'] ?? []);
      final qrisList = List<dynamic>.from(grouped['qris'] ?? []);

      if (rekList.isNotEmpty) {
        _rekeningList = rekList;
      } else {
        // Fallback master data sesuai web (Gambar 3) jika koneksi/data kosong
        _rekeningList = [
          {
            'id': 1,
            'kode_metode': 'MP-001',
            'tipe': 'rekening',
            'nama_bank': 'Bank Central Asia (BCA)',
            'no_rekening': '8830123456',
            'atas_nama': 'Klinik Kecantikan Pusat',
            'status': 'aktif',
          },
          {
            'id': 2,
            'kode_metode': 'MP-002',
            'tipe': 'rekening',
            'nama_bank': 'Bank Mandiri',
            'no_rekening': '1370087654334',
            'atas_nama': 'Klinik Kecantikan Pusat',
            'status': 'aktif',
          },
          {
            'id': 5,
            'kode_metode': 'MP-004',
            'tipe': 'rekening',
            'nama_bank': 'Bank Rakyat Indonesia (BRI)',
            'no_rekening': '839249847234984',
            'atas_nama': 'PT Klinik Jihu',
            'status': 'aktif',
          },
        ];
      }

      if (qrisList.isNotEmpty) {
        _qrisData = Map<String, dynamic>.from(qrisList.first);
      } else {
        _qrisData = {
          'id': 3,
          'kode_metode': 'MP-003',
          'tipe': 'qris',
          'gambar_qris': 'http://127.0.0.1:8008/uploads/qris/qris_MP-003_1792640492062.png',
        };
      }

      if (_rekeningList.isNotEmpty && _selectedRekening == null) {
        _selectedRekening = Map<String, dynamic>.from(_rekeningList.first);
      }
    });
  }

  void _showEnlargedQrisModal() {
    final qrisUrl = ApiConstants.getImageUrl(_qrisData?['gambar_qris']);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
           padding: const EdgeInsets.all(20),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                       const SizedBox(width: 8),
                       Text(
                         'Barcode QRIS',
                         style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                       ),
                     ],
                   ),
                   IconButton(
                     visualDensity: VisualDensity.compact,
                     icon: const Icon(Icons.close_rounded),
                     onPressed: () => Navigator.pop(ctx),
                   ),
                 ],
               ),
               const SizedBox(height: 12),
               Text(
                 'Nominal Pembayaran DP: ${_formatRupiah(_dpNominal)}',
                 style: GoogleFonts.plusJakartaSans(
                   fontSize: 14,
                   fontWeight: FontWeight.w800,
                   color: AppColors.primaryDark,
                 ),
               ),
               const SizedBox(height: 14),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: AppColors.inputBorder),
                   boxShadow: [
                     BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                   ],
                 ),
                 child: qrisUrl != null
                     ? Image.network(
                         qrisUrl,
                         width: 250,
                         height: 250,
                         fit: BoxFit.contain,
                         errorBuilder: (context, error, stackTrace) => const SizedBox(
                           width: 250,
                           height: 250,
                           child: Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey)),
                         ),
                       )
                     : const SizedBox(
                         width: 250,
                         height: 250,
                         child: Center(child: Text('QRIS belum diunggah di web')),
                       ),
               ),
               const SizedBox(height: 14),
               Text(
                 'Pindai QR code ini melalui aplikasi m-Banking atau E-Wallet pilihan Anda untuk pembayaran instan.',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
               ),
               const SizedBox(height: 16),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.primary,
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   onPressed: () => Navigator.pop(ctx),
                   child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                 ),
               ),
             ],
           ),
         ),
      ),
    );
  }

  /// Format nama cabang agar bersih dari kata 'Klinik' dan menyisakan 'Cabang [Nama]'
  String _formatBranchName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Cabang Utama';
    var s = name.trim();
    if (s.toLowerCase().startsWith('klinik ')) {
      s = s.substring(7).trim();
    }
    if (!s.toLowerCase().startsWith('cabang ')) {
      s = 'Cabang $s';
    }
    return s;
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    final noRm = _currentUser?['no_rm'];
    if (noRm == null || noRm.toString().trim().isEmpty) {
      _showToast('Akun Anda belum terhubung dengan Rekam Medis (No. RM). Silakan lengkapi pendaftaran pasien terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedItems.isEmpty) {
      _showToast('Silakan pilih minimal 1 layanan treatment terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedSlot == null) {
      _showToast('Silakan pilih sesi dokter yang bertugas terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedJamBooking == null || _selectedJamBooking!.isEmpty) {
      _showToast('Silakan pilih jam kedatangan janji temu spesifik terlebih dahulu.', isError: true);
      return;
    }

    if (_rekeningList.isEmpty && !_loadingPaymentMethods) {
      _fetchPaymentMethods();
    }

    setState(() => _currentStep = 2);
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goToStep1() {
    if (_isPendingLocked) {
      _showExitPendingDialog();
      return;
    }
    setState(() => _currentStep = 1);
    _scrollToTop();
  }

  Future<void> _showExitPendingDialog() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.lock_clock_rounded, color: Color(0xFFD97706), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Transaksi Booking Pending',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Text(
          'Reservasi Anda dengan kode ${_createdBooking?['kode_booking'] ?? ''} telah tercatat sebagai PENDING dan jadwal dokter telah terkunci.\n\nJika keluar sekarang, Anda dapat melanjutkan upload bukti transfer DP kapan saja melalui menu Profil > PENDING.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Lanjut Upload DP',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar ke Beranda',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );

    if (exit == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _selectedKodeCabang ??= user?['kode_cabang'] ?? 'CBG-001';
        _selectedNamaCabang ??= _formatBranchName(user?['nama_cabang']);
        if (_activeCabang == null && user != null) {
          _activeCabang = {
            'kode_cabang': _selectedKodeCabang ?? user['kode_cabang'] ?? 'CBG-001',
            'nama_cabang': _selectedNamaCabang ?? user['nama_cabang'] ?? 'Klinik Cabang Utama',
          };
        }
      });
    }
  }

  Future<void> _fetchCabangList() async {
    try {
      final list = await AuthService.getCabangList();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _cabangList = list;
          if (_selectedKodeCabang != null && (_selectedNamaCabang == null || _selectedNamaCabang!.isEmpty)) {
            final found = list.firstWhere(
              (c) => c['kode_cabang'] == _selectedKodeCabang,
              orElse: () => list.first,
            );
            _selectedNamaCabang = _formatBranchName(found['nama_cabang']?.toString());
          }
        });
      }
    } catch (_) {}
  }

  void _changeCabang(String newKode, String newNama) {
    if (_selectedKodeCabang == newKode) return;
    setState(() {
      _selectedKodeCabang = newKode;
      _selectedNamaCabang = _formatBranchName(newNama);
      _selectedItems.clear();
      _activeKodeRuangan = null;
      _activeNamaRuangan = null;
      _selectedSlot = null;
      _selectedJamBooking = null;
    });
    _fetchLayanan();
  }

  Future<void> _fetchLayanan() async {
    setState(() => _loadingLayanan = true);
    final branchCode = _selectedKodeCabang ?? _activeCabang?['kode_cabang'];
    final results = await Future.wait([
      BookingService.getLayananList(
        kodeCabang: branchCode,
      ),
      BookingService.getPaketList(
        kodeCabang: branchCode,
      ),
      BookingService.getMyPackages(),
    ]);
    if (!mounted) return;

    final list = results[0];
    final paketList = results[1];
    final myPkgs = results[2];

    final List<Map<String, dynamic>> claimable = [];
    {
      for (final pkg in myPkgs) {
        if (pkg is Map) {
          final pkgStatus = (pkg['status'] ?? '').toString().toLowerCase();
          if (pkgStatus != 'aktif' && pkgStatus != '1') continue;
          final details = pkg['details'];
          if (details is List) {
            for (final d in details) {
              if (d is Map) {
                final sisa = _toNum(d['sesi_tersedia'] ?? d['sisa_sesi']).toInt();
                if (sisa > 0) {
                  final kRuangan = d['kode_ruangan']?.toString() ?? pkg['kode_ruangan_paket']?.toString() ?? 'RNG-002';
                  final nRuangan = d['nama_ruangan']?.toString() ?? pkg['nama_ruangan_paket']?.toString() ?? 'Ruang Treatment';
                  claimable.add({
                    'kode_detail_kepemilikan_paket_layanan': d['kode_detail_kepemilikan_paket_layanan'],
                    'kode_kepemilikan_paket_layanan': pkg['kode_kepemilikan_paket_layanan'],
                    'kode_layanan': d['kode_layanan'],
                    'nama_layanan': d['nama_layanan'] ?? 'Layanan Paket',
                    'nama_paket': pkg['nama_paket'] ?? 'Paket Perawatan',
                    'foto_layanan': d['foto_layanan'] ?? pkg['foto_paket'],
                    'gambar': d['foto_layanan'] ?? pkg['foto_paket'],
                    'foto': d['foto_layanan'] ?? pkg['foto_paket'],
                    'kode_ruangan': kRuangan,
                    'nama_ruangan': nRuangan,
                    'durasi_menit': _toNum(d['durasi_menit']).toInt() > 0 ? _toNum(d['durasi_menit']).toInt() : 30,
                    'wajib_konsultasi': d['wajib_konsultasi'] ?? 'tidak',
                    'is_include_konsultasi': d['is_include_konsultasi'] ?? 0,
                    'harga': 0,
                    'sesi_total': _toNum(d['sesi_total']).toInt(),
                    'sesi_terpakai': _toNum(d['sesi_terpakai']).toInt(),
                    'sisa_sesi': sisa,
                    'is_claim_packet': true,
                    'is_klaim': true,
                    'is_klaim_paket': true,
                    'jenis': 'klaim_paket',
                    'jenis_layanan': 'klaim_paket',
                    'jenis_item': 'klaim_paket',
                  });
                }
              }
            }
          }
        }
      }
    }

    // Kumpulkan nama ruangan unik dari semua daftar
    final Set<String> uniqueRooms = {'Semua'};
    for (final it in list) {
      final rName = (it['nama_ruangan'] ?? '').toString().trim();
      if (rName.isNotEmpty) {
        uniqueRooms.add(rName);
      }
    }
    for (final it in paketList) {
      final rName = (it['nama_ruangan'] ?? '').toString().trim();
      if (rName.isNotEmpty) {
        uniqueRooms.add(rName);
      }
    }
    for (final it in claimable) {
      final rName = (it['nama_ruangan'] ?? '').toString().trim();
      if (rName.isNotEmpty) {
        uniqueRooms.add(rName);
      }
    }

    setState(() {
      _allLayanan = list;
      _allPaket = paketList;
      _claimableItems = claimable;
      _roomList = uniqueRooms.toList();
      _selectedRoom = 'Semua';
      _loadingLayanan = false;

      // Inisialisasi dari klaim paket atau initialLayanan
      if (widget.klaimPaketData != null) {
        final kpd = widget.klaimPaketData!;
        final klaimItem = {
          'kode_layanan': kpd['kode_layanan'],
          'nama_layanan': '${kpd['nama_layanan']} (Klaim ${kpd['nama_paket'] ?? 'Paket'})',
          'nama': '${kpd['nama_layanan']} (Klaim ${kpd['nama_paket'] ?? 'Paket'})',
          'harga': 0,
          'durasi_menit': kpd['durasi_menit'] ?? 45,
          'kode_ruangan': kpd['kode_ruangan'] ?? 'R-001',
          'nama_ruangan': kpd['nama_ruangan'] ?? 'Ruang Treatment',
          'wajib_konsultasi': 'tidak',
          'is_klaim': true,
          'is_klaim_paket': true,
          'jenis': 'klaim_paket',
          'kode_kepemilikan_paket_layanan': kpd['kode_kepemilikan_paket_layanan'],
          'kode_detail_kepemilikan_paket_layanan': kpd['kode_detail_kepemilikan_paket_layanan'],
        };
        _selectedItems.clear();
        _selectedItems.add(klaimItem);
        _activeKodeRuangan = klaimItem['kode_ruangan'];
        _activeNamaRuangan = klaimItem['nama_ruangan'];
        _persetujuanDp = true;
      } else if (widget.initialLayanan != null) {
        _toggleItem(widget.initialLayanan!);
      }
    });

    _fetchSlots();
  }

  List<dynamic> get _filteredLayanan {
    if (_selectedRoom == 'Semua') return _allLayanan;
    return _allLayanan.where((it) => it['nama_ruangan'] == _selectedRoom).toList();
  }

  List<dynamic> get _filteredPaket {
    if (_selectedRoom == 'Semua') return _allPaket;
    return _allPaket.where((it) => it['nama_ruangan'] == _selectedRoom).toList();
  }

  List<Map<String, dynamic>> get _filteredClaimable {
    if (_selectedRoom == 'Semua' || _selectedRoom == 'dimiliki') return _claimableItems;
    return _claimableItems.where((it) => it['nama_ruangan'] == _selectedRoom).toList();
  }

  void _toggleClaimItem(Map<String, dynamic> item) {
    final kodeDkpl = item['kode_detail_kepemilikan_paket_layanan'];
    final itemRoom = item['kode_ruangan'];
    final itemRoomName = item['nama_ruangan'] ?? 'Ruang Treatment';

    final isSelected = _selectedItems.any((it) =>
      it['kode_detail_kepemilikan_paket_layanan'] != null &&
      it['kode_detail_kepemilikan_paket_layanan'] == kodeDkpl
    );

    if (isSelected) {
      setState(() {
        _selectedItems.removeWhere((it) =>
          it['kode_detail_kepemilikan_paket_layanan'] == kodeDkpl
        );
        if (_selectedItems.isEmpty) {
          _activeKodeRuangan = null;
          _activeNamaRuangan = null;
          _selectedSlot = null;
          _selectedJamBooking = null;
          _isClaim = false;
        } else {
          _isClaim = _selectedItems.any((it) => it['is_klaim'] == true || it['is_claim_packet'] == true);
        }
      });
      _fetchSlots();
      return;
    }

    // Periksa konflik ruangan jika ada item lain yang sudah dipilih sebelumnya
    if (_selectedItems.isNotEmpty && _activeKodeRuangan != null && itemRoom != null && itemRoom != _activeKodeRuangan) {
      _showRoomConflictDialog(item, itemRoom, itemRoomName, isClaimItem: true);
      return;
    }

    setState(() {
      _selectedItems.add(item);
      _activeKodeRuangan = itemRoom;
      _activeNamaRuangan = itemRoomName;
      _isClaim = true;
      _selectedJamBooking = null;
      _selectedRoom = itemRoomName; // Otomatis arahkan tab ruangan ke ruangan tindakan paket
    });

    _fetchSlots();
  }

  void _toggleItem(Map<String, dynamic> item) {
    // Jika sebelumnya memilih paket baru (bukan klaim), reset jika ingin beralih
    if (_selectedItems.any((it) => it['is_paket'] == true && it['is_klaim'] != true)) {
      _selectedItems.clear();
      _activeKodeRuangan = null;
      _activeNamaRuangan = null;
      _selectedSlot = null;
      _selectedJamBooking = null;
      _isClaim = false;
    }

    final kode = item['kode_layanan'];
    final itemRoom = item['kode_ruangan'];
    final itemRoomName = item['nama_ruangan'] ?? 'Ruang Treatment';

    // Cek apakah layanan ini sudah dipilih melalui klaim kuota paket aktif
    final isAlreadyClaimed = _selectedItems.any((it) =>
      it['kode_layanan'] == kode && (it['is_klaim'] == true || it['is_claim_packet'] == true)
    );
    if (isAlreadyClaimed) {
      _showToast('Layanan ini sudah Anda pilih via klaim paket aktif (Rp 0).', isError: false);
      return;
    }

    final exists = _selectedItems.any((it) => it['kode_layanan'] == kode && it['is_klaim'] != true);

    if (exists) {
      setState(() {
        _selectedItems.removeWhere((it) => it['kode_layanan'] == kode && it['is_klaim'] != true);
        if (_selectedItems.isEmpty) {
          _activeKodeRuangan = null;
          _activeNamaRuangan = null;
          _selectedSlot = null;
          _selectedJamBooking = null;
          _isClaim = false;
        } else {
          _isClaim = _selectedItems.any((it) => it['is_klaim'] == true || it['is_claim_packet'] == true);
        }
      });
      _fetchSlots();
      return;
    }

    // Jika item baru memiliki ruangan berbeda dengan item yang sudah dipilih
    if (_selectedItems.isNotEmpty && _activeKodeRuangan != null && itemRoom != null && itemRoom != _activeKodeRuangan) {
      _showRoomConflictDialog(item, itemRoom, itemRoomName);
      return;
    }

    setState(() {
      _selectedItems.add(item);
      _activeKodeRuangan = itemRoom;
      _activeNamaRuangan = itemRoomName;
      _selectedJamBooking = null;
    });

    _fetchSlots();
  }

  void _togglePaket(Map<String, dynamic> paket) {
    final kodePaket = paket['kode_paket_layanan'] ?? paket['kode_layanan'];
    final itemRoom = paket['kode_ruangan'];
    final itemRoomName = paket['nama_ruangan'] ?? 'Ruang Treatment';

    final isSelected = _selectedItems.any((it) => it['kode_layanan'] == kodePaket && it['is_klaim'] != true);

    if (isSelected) {
      setState(() {
        _selectedItems.removeWhere((it) => it['kode_layanan'] == kodePaket && it['is_klaim'] != true);
        if (_selectedItems.isEmpty) {
          _activeKodeRuangan = null;
          _activeNamaRuangan = null;
          _selectedSlot = null;
          _selectedJamBooking = null;
          _isClaim = false;
        } else {
          _isClaim = _selectedItems.any((it) => it['is_klaim'] == true || it['is_claim_packet'] == true);
        }
      });
      _fetchSlots();
      return;
    }

    // Periksa konflik ruangan
    if (_selectedItems.isNotEmpty && _activeKodeRuangan != null && itemRoom != null && itemRoom != _activeKodeRuangan) {
      _showRoomConflictDialog(paket, itemRoom, itemRoomName);
      return;
    }

    setState(() {
      _selectedItems.add({
        'kode_layanan': kodePaket,
        'kode_paket_layanan': kodePaket,
        'nama_layanan': paket['nama'] ?? paket['nama_paket'] ?? 'Paket Perawatan',
        'nama': paket['nama'] ?? paket['nama_paket'] ?? 'Paket Perawatan',
        'harga': _toNum(paket['harga_paket'] ?? paket['harga']),
        'harga_paket': _toNum(paket['harga_paket'] ?? paket['harga']),
        'durasi_menit': paket['durasi_menit'] ?? 60,
        'kode_ruangan': itemRoom,
        'nama_ruangan': itemRoomName,
        'wajib_konsultasi': 'tidak',
        'is_include_konsultasi': paket['is_include_konsultasi'] ?? 0,
        'is_paket': true,
        'jenis': 'paket',
        'jenis_layanan': 'paket',
        'foto': paket['foto'],
        'gambar': paket['foto'],
        'details': paket['details'] ?? [],
        'total_sesi': paket['total_sesi'] ?? 1,
      });
      _activeKodeRuangan = itemRoom;
      _activeNamaRuangan = itemRoomName;
      _selectedSlot = null;
      _selectedJamBooking = null;
    });

    _fetchSlots();
  }

  void _showRoomConflictDialog(Map<String, dynamic> newItem, String newRoom, String newRoomName, {bool isClaimItem = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Ganti Ruangan Treatment?',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Layanan "${newItem['nama_layanan'] ?? newItem['nama']}" berada di $newRoomName. '
          'Satu sesi reservasi hanya dapat memilih layanan di ruangan yang sama.\n\n'
          'Ganti pilihan layanan ke $newRoomName?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedItems.clear();
                _selectedItems.add(newItem);
                _activeKodeRuangan = newRoom;
                _activeNamaRuangan = newRoomName;
                _selectedSlot = null;
                _selectedJamBooking = null;
                _isClaim = isClaimItem || (newItem['is_klaim'] == true || newItem['is_claim_packet'] == true);
                _selectedRoom = newRoomName;
              });
              _fetchSlots();
            },
            child: Text('Ya, Ganti', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchSlots() async {
    final dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
      _selectedJamBooking = null;
    });

    final res = await BookingService.getAvailableSlots(
      tanggal: dateStr,
      kodeRuangan: _activeKodeRuangan,
      kodeLayanan: _selectedItems.isNotEmpty ? _selectedItems.first['kode_layanan'] : null,
      kodeCabang: _selectedKodeCabang ?? _activeCabang?['kode_cabang'],
    );

    if (!mounted) return;
    setState(() {
      _loadingSlots = false;
      if (res['success'] == true) {
        _availableSlots = res['data']['available_slots'] ?? [];
        if (_availableSlots.isNotEmpty) {
          // Auto select first available slot
          final firstAvail = _availableSlots.firstWhere(
            (s) => s['is_penuh'] != true,
            orElse: () => _availableSlots.first,
          );
          if (firstAvail['is_penuh'] != true) {
            _selectedSlot = firstAvail;
            _autoSelectDefaultTime();
          }
        }
      } else {
        _availableSlots = [];
      }
    });
  }

  void _autoSelectDefaultTime() {
    final slots = _generateTimeSlots();
    final firstValid = slots.firstWhere(
      (st) => st['isBooked'] != true && st['isPast'] != true,
      orElse: () => <String, dynamic>{},
    );
    if (firstValid.isNotEmpty) {
      _selectedJamBooking = firstValid['time'];
    }
  }

  static num _toNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    if (val is String) {
      return num.tryParse(val) ?? 0;
    }
    return 0;
  }

  int get _totalDurasi {
    if (_selectedItems.isEmpty) return 30;
    int total = 0;
    for (final it in _selectedItems) {
      final d = _toNum(it['durasi_menit']).toInt();
      total += d > 0 ? d : 30;
    }
    return total > 0 ? total : 30;
  }

  bool get _hasClaimItem {
    return _selectedItems.any((it) => it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket') || _isClaim;
  }

  bool get _hasPaidItem {
    return _selectedItems.any((it) => it['is_klaim'] != true && it['is_claim_packet'] != true && it['jenis'] != 'klaim_paket');
  }

  num get _totalBiaya {
    if (_createdBooking?['total_biaya'] != null) {
      return _toNum(_createdBooking!['total_biaya']);
    }
    if (_createdBooking?['total_estimasi'] != null) {
      return _toNum(_createdBooking!['total_estimasi']);
    }
    num total = 0;
    for (final it in _selectedItems) {
      final isItemClaim = it['is_claim_packet'] == true || it['is_klaim'] == true || it['jenis'] == 'klaim_paket';
      if (isItemClaim) continue;
      total += _toNum(it['harga'] ?? it['harga_paket']);
    }
    return total;
  }

  num get _dpNominal {
    if (_createdBooking?['dp_nominal'] != null) {
      return _toNum(_createdBooking!['dp_nominal']);
    }
    if (_totalBiaya <= 0) return 0;
    return (_totalBiaya * 0.2).round();
  }

  num get _sisaPelunasan => _totalBiaya <= 0 ? 0 : (_totalBiaya - _dpNominal);

  Map<String, bool> _getItemConsultType(Map<String, dynamic> item) {
    final wk = (item['wajib_konsultasi'] ?? '').toString().trim().toLowerCase();
    if (wk == 'wajib') return {'isWajib': true, 'isService': false, 'isOpsional': false};
    if (wk == 'tidak') return {'isWajib': false, 'isService': true, 'isOpsional': false};
    if (wk == 'opsional') return {'isWajib': false, 'isService': false, 'isOpsional': true};

    final tp = (item['tipe'] ?? '').toString().trim().toUpperCase();
    final isWajib = tp == 'MEDICAL TREATMENT';
    final isService = tp == 'SERVICE TREATMENT';
    final isOpsional = !isWajib && !isService;
    return {'isWajib': isWajib, 'isService': isService, 'isOpsional': isOpsional};
  }

  bool get _hasWajibKonsul {
    return _selectedItems.any((it) => _getItemConsultType(it)['isWajib'] == true);
  }

  bool get _hasOpsionalKonsul {
    return !_hasWajibKonsul && _selectedItems.any((it) => _getItemConsultType(it)['isOpsional'] == true);
  }

  List<Map<String, dynamic>> _generateTimeSlots() {
    if (_selectedSlot == null) return [];

    final jamMulai = (_selectedSlot!['jam_mulai'] ?? '08:00').toString().sliceSafe(0, 5);
    final jamSelesai = (_selectedSlot!['jam_selesai'] ?? '16:00').toString().sliceSafe(0, 5);
    final bookedTimes = List<String>.from(_selectedSlot!['booked_times'] ?? []);

    final startMin = _timeToMinutes(jamMulai);
    final endMin = _timeToMinutes(jamSelesai);
    final step = _totalDurasi > 0 ? _totalDurasi : 30;

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final nowMinutes = now.hour * 60 + now.minute;

    final List<Map<String, dynamic>> results = [];

    for (int m = startMin; m < endMin; m += step) {
      final candEnd = m + step;
      if (candEnd > endMin) break;

      final timeStr = _minutesToTime(m);
      final endStr = _minutesToTime(candEnd);

      final isPast = isToday && (m <= nowMinutes + 15);
      final isBooked = bookedTimes.any((bt) => bt.startsWith(timeStr));

      results.add({
        'time': timeStr,
        'endEst': endStr,
        'isBooked': isBooked,
        'isPast': isPast,
      });
    }

    return results;
  }

  int _timeToMinutes(String t) {
    try {
      final parts = t.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  String _minutesToTime(int m) {
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final min = (m % 60).toString().padLeft(2, '0');
    return '$h:$min';
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
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
      setState(() => _selectedDate = picked);
      _fetchSlots();
    }
  }

  // ── LOGIKA LANGKAH 2 KE LANGKAH 3 (KUNCI TRANSAKSI PENDING) ──
  Future<void> _proceedToStep3() async {
    final noRm = _currentUser?['no_rm'];
    if (noRm == null || noRm.toString().trim().isEmpty) {
      _showToast('Akun Anda belum terhubung dengan Rekam Medis (No. RM). Silakan lengkapi pendaftaran pasien terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedItems.isEmpty) {
      _showToast('Pilih minimal satu layanan perawatan', isError: true);
      return;
    }
    if (_selectedSlot == null) {
      _showToast('Pilih sesi dokter yang bertugas terlebih dahulu', isError: true);
      return;
    }
    if (_selectedJamBooking == null) {
      _showToast('Pilih jam kedatangan janji temu yang tersedia', isError: true);
      return;
    }
    // Jika bebas DP (misal klaim sesi paket 100%), langsung konfirmasi
    if (_dpNominal == 0) {
      await _handleSubmitBookingBebasDp();
      return;
    }

    // Jika belum ada booking pending yang tersimpan di server untuk sesi ini, simpan sekarang
    if (_createdBooking == null) {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      setState(() => _creatingPending = true);

      final hasClaim = _hasClaimItem;
      final hasPaid = _hasPaidItem;
      String jenisLayanan = 'layanan';
      if (hasClaim && hasPaid) {
        jenisLayanan = 'campuran';
      } else if (hasClaim) {
        jenisLayanan = 'klaim_paket';
      } else if (_selectedItems.any((it) => it['is_paket'] == true || it['jenis'] == 'paket')) {
        jenisLayanan = 'paket';
      }

      final formattedItems = _selectedItems.map((it) {
        final isPkt = it['is_paket'] == true || it['jenis'] == 'paket';
        final isItemClaim = it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket';
        return {
          'kode_layanan': it['kode_layanan'] ?? it['kode_paket_layanan'],
          'nama_layanan': it['nama_layanan'] ?? it['nama'],
          'harga': isItemClaim ? 0 : _toNum(it['harga'] ?? it['harga_paket']),
          'durasi_menit': _toNum(it['durasi_menit']).toInt(),
          if (isPkt) ...{
            'is_paket': true,
            'jenis': 'paket',
            'jenis_layanan': 'paket',
          },
          if (isItemClaim) ...{
            'is_klaim': true,
            'is_klaim_paket': true,
            'is_claim_packet': true,
            'jenis': 'klaim_paket',
            'kode_kepemilikan_paket_layanan': it['kode_kepemilikan_paket_layanan'],
            'kode_detail_kepemilikan_paket_layanan': it['kode_detail_kepemilikan_paket_layanan'],
          },
        };
      }).toList();

      final effectiveButuhKonsul = _hasWajibKonsul ? true : (_hasOpsionalKonsul ? _pilihanKonsul : false);

      String? selectedKodeMetode;
      if (_metodeDp == 'transfer') {
        selectedKodeMetode = _selectedRekening?['kode_metode'] ?? 'MP-001';
      } else if (_metodeDp == 'qris') {
        selectedKodeMetode = _qrisData?['kode_metode'] ?? 'MP-003';
      }

      final result = await BookingService.createBooking(
        kodeJadwal: _selectedSlot!['kode_jadwal'],
        tanggalBooking: dateStr,
        jamBooking: _selectedJamBooking!,
        kodeLayanan: formattedItems.first['kode_layanan'],
        jenisLayanan: jenisLayanan,
        items: formattedItems,
        catatan: _catatanCtrl.text.trim(),
        metodeDp: _metodeDp,
        kodeMetodePembayaran: selectedKodeMetode,
        buktiDpFile: null, // Belum upload bukti transfer (status pending kunci transaksi)
        kodeCabang: _activeCabang?['kode_cabang'] ?? _currentUser?['kode_cabang'] ?? 'CBG-001',
        butuhKonsul: effectiveButuhKonsul,
        isClaimPacket: hasClaim && !hasPaid,
        kodeDetailKepemilikan: _kodeDetailKepemilikan,
      );

      if (!mounted) return;
      setState(() => _creatingPending = false);

      if (result['success'] == true) {
        setState(() {
          _createdBooking = Map<String, dynamic>.from(result['data'] ?? {});
          _isPendingLocked = true;
          _currentStep = 3;
        });
        _scrollToTop();
      } else {
        // Cek apakah kegagalan karena masih ada booking pending yang belum di-upload bukti DP
        final pendingData = await BookingService.getPendingBooking();
        if (pendingData != null && mounted) {
          final action = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_clock_rounded, color: Color(0xFFB45309), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Transaksi Pending Ditemukan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda masih memiliki transaksi booking yang belum selesai:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingData['kode_booking'] ?? '-',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF92400E)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${pendingData['nama_dokter'] ?? 'Dokter'} • ${pendingData['tanggal_booking']} (${pendingData['jam_booking']} WIB)",
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFB45309)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Nominal DP: ${pendingData['dp_nominal'] != null ? _formatRupiah(pendingData['dp_nominal']) : 'DP 20%'}",
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pilih apakah Anda ingin melanjutkan upload bukti transfer untuk transaksi tersebut, atau membatalkannya untuk membuat janji baru.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted, height: 1.35),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'batal_lama'),
                  child: const Text('Batalkan Booking Lama', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx, 'lanjut_upload'),
                  child: const Text('Lanjut Upload DP ➔', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                ),
              ],
            ),
          );

          if (!mounted) return;

          if (action == 'lanjut_upload') {
            setState(() {
              _createdBooking = Map<String, dynamic>.from(pendingData);
              _isPendingLocked = true;
              _currentStep = 3;
            });
            _scrollToTop();
            return;
          } else if (action == 'batal_lama') {
            final kodeBooking = pendingData['kode_booking'];
            if (kodeBooking != null) {
              setState(() => _creatingPending = true);
              final res = await BookingService.cancelBooking(kodeBooking, 'Dibatalkan oleh pasien untuk membuat jadwal baru');
              setState(() => _creatingPending = false);
              if (res['success'] == true) {
                _showToast('Booking lama berhasil dibatalkan. Menyimpan jadwal baru...');
                _proceedToStep3();
                return;
              } else {
                _showToast(res['message'] ?? 'Gagal membatalkan booking lama', isError: true);
                return;
              }
            }
          }
        }
        _showToast(result['message'] ?? 'Gagal membuat reservasi pending', isError: true);
      }
    } else {
      setState(() => _currentStep = 3);
      _scrollToTop();
    }
  }

  // ── KONFIRMASI BOOKING BEBAS DP (KLAIM PAKET 100%) ──
  Future<void> _handleSubmitBookingBebasDp() async {
    final dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    setState(() => _submitting = true);

    final formattedItems = _selectedItems.map((it) {
      final isItemClaim = it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket' || _isClaim;
      return {
        'kode_layanan': it['kode_layanan'] ?? it['kode_paket_layanan'],
        'nama_layanan': it['nama_layanan'] ?? it['nama'],
        'harga': isItemClaim ? 0 : _toNum(it['harga'] ?? it['harga_paket']),
        'durasi_menit': _toNum(it['durasi_menit']).toInt(),
        if (isItemClaim) ...{
          'is_klaim': true,
          'is_klaim_paket': true,
          'is_claim_packet': true,
          'jenis': 'klaim_paket',
          'kode_kepemilikan_paket_layanan': it['kode_kepemilikan_paket_layanan'],
          'kode_detail_kepemilikan_paket_layanan': it['kode_detail_kepemilikan_paket_layanan'],
        },
      };
    }).toList();

    final effectiveButuhKonsul = _hasWajibKonsul ? true : (_hasOpsionalKonsul ? _pilihanKonsul : false);

    final result = await BookingService.createBooking(
      kodeJadwal: _selectedSlot!['kode_jadwal'],
      tanggalBooking: dateStr,
      jamBooking: _selectedJamBooking!,
      kodeLayanan: formattedItems.first['kode_layanan'],
      items: formattedItems,
      catatan: _catatanCtrl.text.trim(),
      metodeDp: 'paket',
      kodeMetodePembayaran: 'MP-PAKET',
      buktiDpFile: null,
      kodeCabang: _activeCabang?['kode_cabang'] ?? _currentUser?['kode_cabang'] ?? 'CBG-001',
      butuhKonsul: effectiveButuhKonsul,
      isClaimPacket: _isClaim,
      kodeDetailKepemilikan: _kodeDetailKepemilikan,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      _showSuccessDialog(result['data']);
    } else {
      _showToast(result['message'] ?? 'Gagal membuat reservasi', isError: true);
    }
  }

  // ── SUBMIT LANGKAH 3: UPLOAD BUKTI PEMBAYARAN DP ──
  Future<void> _submitStep3BuktiDp() async {
    if (_buktiDpImage == null) {
      _showToast('Silakan upload foto / screenshot bukti transfer terlebih dahulu', isError: true);
      return;
    }
    if (!_persetujuanDp) {
      _showToast('Centang persetujuan uang muka (DP 20%) untuk melanjutkan', isError: true);
      return;
    }

    final kodeBooking = _createdBooking?['kode_booking'];
    if (kodeBooking == null) {
      _showToast('Kode booking tidak valid', isError: true);
      return;
    }

    setState(() => _submitting = true);

    String? selectedKodeMetode;
    if (_metodeDp == 'transfer') {
      selectedKodeMetode = _selectedRekening?['kode_metode'] ?? _createdBooking?['kode_metode_pembayaran'] ?? 'MP-001';
    } else if (_metodeDp == 'qris') {
      selectedKodeMetode = _qrisData?['kode_metode'] ?? _createdBooking?['kode_metode_pembayaran'] ?? 'MP-003';
    }

    final res = await BookingService.uploadBuktiDp(
      kodeBooking: kodeBooking,
      buktiDpFile: _buktiDpImage!,
      metodeDp: _metodeDp,
      kodeMetodePembayaran: selectedKodeMetode,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      _showSuccessDialog(_createdBooking);
    } else {
      _showToast(res['message'] ?? 'Gagal mengunggah bukti pembayaran DP', isError: true);
    }
  }

  // ── BATALKAN TRANSAKSI PENDING DARI LANGKAH 3 ──
  Future<void> _cancelCurrentPendingBooking() async {
    final kodeBooking = _createdBooking?['kode_booking'];
    if (kodeBooking == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Janji Temu?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Transaksi reservasi $kodeBooking akan dibatalkan dan kuota jadwal dokter akan dilepas. Anda dapat membuat booking baru setelah pembatalan ini.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _submitting = true);
      final res = await BookingService.cancelBooking(kodeBooking, 'Dibatalkan oleh pengguna di langkah 3');
      if (!mounted) return;
      setState(() => _submitting = false);

      if (res['success'] == true) {
        _showToast('Transaksi booking berhasil dibatalkan');
        Navigator.pop(context, true);
      } else {
        _showToast(res['message'] ?? 'Gagal membatalkan booking', isError: true);
      }
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic>? data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Reservasi Berhasil!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Jadwal reservasi Anda telah berhasil tercatat di sistem klinik.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              // Rincian Struk Singkat
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'KODE BOOKING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data?['kode_booking'] ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Divider(height: 18),
                    _strukRow('Cabang', _activeCabang?['nama_cabang'] ?? _currentUser?['nama_cabang'] ?? 'Klinik Cabang Utama'),
                    _strukRow('Pasien', data?['nama_pasien'] ?? _currentUser?['nama'] ?? '-'),
                    _strukRow('Ruangan', data?['nama_ruangan'] ?? _activeNamaRuangan ?? '-'),
                    _strukRow('Alur Kunjungan', (_hasWajibKonsul || (_hasOpsionalKonsul && _pilihanKonsul)) ? 'Konsultasi Dokter Dulu' : 'Langsung Tindakan', color: const Color(0xFF2563EB), isBold: true),
                    _strukRow('Tanggal', data?['tanggal_booking'] ?? '-'),
                    _strukRow('Jam', "${data?['jam_booking'] ?? _selectedJamBooking ?? '-'} WIB"),
                    _strukRow('Dokter', data?['nama_dokter'] ?? _selectedSlot?['nama_dokter'] ?? '-'),
                    const Divider(height: 14),
                    _strukRow(
                      'Status Booking',
                      _dpNominal > 0 ? 'Menunggu Konfirmasi Kasir' : 'Dikonfirmasi',
                      color: _dpNominal > 0 ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                      isBold: true,
                    ),
                    _strukRow('Total Estimasi', _formatRupiah(data?['total_estimasi'] ?? _totalBiaya), isBold: true),
                    _strukRow('Uang Muka (DP 20%)', _formatRupiah(data?['dp_nominal'] ?? _dpNominal), color: AppColors.primaryDark),
                    _strukRow('Sisa di Kasir (80%)', _formatRupiah(_sisaPelunasan), color: AppColors.textMuted),
                    _strukRow('Metode DP', _metodeDp.toUpperCase(), isBold: true),
                    if (_buktiDpImage != null)
                      _strukRow('Bukti DP', 'Terlampir ✓', color: AppColors.primary, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Status DP Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: _isClaim ? const Color(0xFFECFDF5) : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _isClaim ? const Color(0xFFA7F3D0) : Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isClaim ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                      size: 16,
                      color: _isClaim ? const Color(0xFF059669) : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isClaim
                            ? 'Reservasi berhasil dikonfirmasi menggunakan sisa kuota sesi paket aktif Anda. Tidak memerlukan pembayaran DP baru.'
                            : 'Bukti pembayaran DP telah berhasil diunggah dan akan diverifikasi oleh kasir sebelum menyelesaikan pesanan Anda.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: _isClaim ? const Color(0xFF065F46) : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Selesai & Lihat Jadwal Saya',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _strukRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: color ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatRupiah(dynamic val) {
    if (val == null) return 'Rp 0';
    final n = _toNum(val);
    final s = n.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  static String _formatTanggalIndo(DateTime dt) {
    const hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${hari[dt.weekday % 7]}, ${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 1 && !_isPendingLocked,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep == 2) {
          _goToStep1();
        } else if (_currentStep == 3 || _isPendingLocked) {
          _showExitPendingDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FCFA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
            onPressed: () {
              if (_currentStep == 2) {
                _goToStep1();
              } else if (_currentStep == 3 || _isPendingLocked) {
                _showExitPendingDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentStep == 1
                    ? 'Buat Reservasi / Booking Baru'
                    : (_currentStep == 2 ? 'Rincian Reservasi & DP' : 'Upload Bukti Pembayaran DP'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
              ),
              Text(
                _currentStep == 1
                    ? 'Langkah 1 dari 3: Isi layanan & jadwal dokter'
                    : (_currentStep == 2
                        ? 'Langkah 2 dari 3: Rincian biaya & pembayaran DP'
                        : 'Langkah 3 dari 3: Unggah bukti transfer uang muka'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _currentStep == 1
              ? _buildStep1Content()
              : (_currentStep == 2 ? _buildStep2Content() : _buildStep3Content()),
        ),
      ),
    );
  }

  // ── INDIKATOR LANGKAH MULTI-STEP (3 LANGKAH) ──
  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Langkah 1
          Expanded(
            child: InkWell(
              onTap: (_currentStep == 2 && !_isPendingLocked) ? _goToStep1 : null,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep == 1
                          ? AppColors.primary
                          : const Color(0xFF10B981),
                    ),
                    child: Center(
                      child: _currentStep > 1
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : Text(
                              '1',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANGKAH 1',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: _currentStep == 1 ? AppColors.primary : AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Layanan & Jadwal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: _currentStep == 1 ? FontWeight.w700 : FontWeight.w600,
                            color: _currentStep == 1 ? AppColors.textDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _currentStep >= 2 ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ),

          // Langkah 2
          Expanded(
            child: InkWell(
              onTap: (_currentStep == 1) ? _goToStep2 : null,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep == 2
                          ? AppColors.primary
                          : (_currentStep > 2 ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: _currentStep > 2
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : Text(
                              '2',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _currentStep == 2 ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANGKAH 2',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: _currentStep == 2 ? AppColors.primary : AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Rincian & DP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: _currentStep == 2 ? FontWeight.w700 : FontWeight.w600,
                            color: _currentStep == 2 ? AppColors.textDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider 2
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _currentStep >= 3 ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ),

          // Langkah 3
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStep == 3
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _currentStep == 3 ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LANGKAH 3',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: _currentStep == 3 ? AppColors.primary : AppColors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Upload DP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: _currentStep == 3 ? FontWeight.w700 : FontWeight.w600,
                          color: _currentStep == 3 ? AppColors.textDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── KONTEN LANGKAH 1 (GAMBAR 2: FORMULIR LAYANAN & JADWAL) ──
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(),

        // 1. Identitas Pasien & Cabang
        _buildPatientHeaderCard(),
        const SizedBox(height: 18),

        // 2. Pilih Layanan & Paket Treatment
        _buildTreatmentSelectionSection(),
        const SizedBox(height: 16),

        // 3. Pilihan Alur Kunjungan Pasien (Sama seperti Web)
        _buildConsultationFlowSection(),

        // 4. Pilih Tanggal & Sesi Dokter & Jam Spesifik
        _buildDateAndScheduleSection(),
        const SizedBox(height: 20),

        // 5. Catatan Keluhan Pasien (Opsional)
        _buildNotesSection(),
        const SizedBox(height: 24),

        // 6. Tombol Selanjutnya (Menuju Langkah 2)
        _buildNextStepButton(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── KONTEN LANGKAH 2 (GAMBAR 1: RINCIAN RESERVASI & PEMBAYARAN DP) ──
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(),

        // Banner pintasan kembali ubah jadwal/layanan (hanya jika belum terkunci)
        if (!_isPendingLocked)
          InkWell(
            onTap: _goToStep1,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_calendar_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingin mengubah layanan atau jadwal dokter?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ),
                  Text(
                    'Ubah ➔',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Panel Rincian Reservasi & DP (Persis Gambar Pertama)
        _buildReservationAndDpPanel(),
        const SizedBox(height: 22),

        // Tombol Lanjut ke Langkah 3 (Upload Bukti DP)
        _buildStep2ActionButton(),
        const SizedBox(height: 12),

        // Tombol Kembali
        if (!_isPendingLocked)
          Center(
            child: TextButton.icon(
              onPressed: _goToStep1,
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textMuted),
              label: Text(
                'Kembali ke Pemilihan Layanan & Jadwal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── TOMBOL SELANJUTNYA DARI LANGKAH 1 ──
  Widget _buildNextStepButton() {
    final bool canProceed = _selectedItems.isNotEmpty &&
        _selectedSlot != null &&
        _selectedJamBooking != null &&
        _selectedJamBooking!.isNotEmpty;

    return Column(
      children: [
        InkWell(
          onTap: _goToStep2,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: canProceed ? AppColors.primaryGradient : null,
              color: canProceed ? null : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
              boxShadow: canProceed
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selanjutnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: canProceed ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: canProceed ? Colors.white : const Color(0xFF64748B),
                  size: 19,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          !canProceed
              ? (_selectedItems.isEmpty
                  ? '* Silakan pilih minimal 1 treatment untuk lanjut'
                  : _selectedSlot == null
                      ? '* Silakan pilih sesi dokter untuk lanjut'
                      : '* Silakan pilih jam kedatangan spesifik untuk lanjut')
              : 'Periksa rincian biaya & konfirmasi uang muka (DP) di langkah berikutnya',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: canProceed ? AppColors.primaryDark : AppColors.textMuted,
            fontWeight: canProceed ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 1. KARTU INFORMASI PASIEN & PILIHAN CABANG
  Widget _buildPatientHeaderCard() {
    final nama = _currentUser?['nama'] ?? 'Pelanggan Klinik';
    final noRm = _currentUser?['no_rm'] ?? 'RM-BARU';
    final noHp = _currentUser?['no_hp'] ?? '-';
    final cabang = _formatBranchName(_selectedNamaCabang ?? _activeCabang?['nama_cabang'] ?? _currentUser?['nama_cabang']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nama,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            noRm,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('No. HP: $noHp', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          // Baris Pemilihan / Indikator Cabang Klinik
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bgMintSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cabang Reservasi:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      cabang,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (_cabangList.length > 1)
                InkWell(
                  onTap: _showBranchSelectModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ganti Cabang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_isClaim) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 0.9),
              ),
              child: Row(
                children: [
                  const Text('🎫', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservasi Klaim Sisa Sesi Paket',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                        Text(
                          _namaPaketKlaim != null
                              ? 'Paket: $_namaPaketKlaim • Bebas DP (Rp0)'
                              : 'Bebas Uang Muka (DP Rp0) via Kuota Paket Aktif',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBranchSelectModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Cabang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._cabangList.map((c) {
                  final cKode = c['kode_cabang'] ?? '';
                  final cNama = _formatBranchName(c['nama_cabang']?.toString());
                  final isCurrent = _selectedKodeCabang == cKode;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.bgMintSoft : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.storefront_outlined,
                        color: isCurrent ? AppColors.primaryDark : AppColors.textMuted,
                      ),
                      title: Text(
                        cNama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isCurrent ? AppColors.primaryDark : AppColors.textDark,
                        ),
                      ),
                      subtitle: c['alamat'] != null
                          ? Text(
                              c['alamat'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                            )
                          : null,
                      trailing: isCurrent
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _changeCabang(cKode, cNama);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. PILIHAN LAYANAN / PAKET DENGAN TAB FILTER RUANGAN & MULTI-SELECT
  Widget _buildTreatmentSelectionSection() {
    final isLayananTab = _activeCategoryTab == 'layanan';
    final isPaketTab = _activeCategoryTab == 'paket';
    final isDimilikiTab = _activeCategoryTab == 'dimiliki';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Pilih Layanan / Paket',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  Text(
                    isDimilikiTab
                        ? 'Klaim jatah sesi paket perawatan aktif Anda (Rp 0)'
                        : (isLayananTab
                            ? 'Multi-select treatment dalam ruangan yang sama'
                            : 'Pilih paket perawatan hemat klinik'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (_selectedItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_selectedItems.length} Dipilih',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── CATEGORY TAB TOGGLE: LAYANAN SATUAN vs PAKET HEMAT vs PAKET DIMILIKI ──
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // Tab Layanan
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeCategoryTab = 'layanan'),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isLayananTab ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isLayananTab
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            size: 15,
                            color: isLayananTab ? AppColors.primaryDark : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Layanan (${_filteredLayanan.length})',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: isLayananTab ? FontWeight.w800 : FontWeight.w600,
                                color: isLayananTab ? AppColors.primaryDark : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Tab Paket Hemat
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeCategoryTab = 'paket'),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isPaketTab ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isPaketTab
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 15,
                            color: isPaketTab ? const Color(0xFFD97706) : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Paket (${_filteredPaket.length})',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: isPaketTab ? FontWeight.w800 : FontWeight.w600,
                                color: isPaketTab ? const Color(0xFFD97706) : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tab Paket Dimiliki (Jika Pasien Memiliki Paket Aktif)
              if (_claimableItems.isNotEmpty) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeCategoryTab = 'dimiliki'),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDimilikiTab ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isDimilikiTab
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Dimiliki (${_claimableItems.length})',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: isDimilikiTab ? FontWeight.w800 : FontWeight.w600,
                                  color: isDimilikiTab ? const Color(0xFF059669) : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── TABS FILTER RUANGAN (PERSIS GAMBAR 2 & 3 DI WEB) ──
        if (_roomList.length > 1 || _claimableItems.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Chip Paket Dimiliki Pasien di depan (Sesuai Web Gambar 2 & 3)
                if (_claimableItems.isNotEmpty) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _activeCategoryTab = 'dimiliki';
                        _selectedRoom = 'dimiliki';
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDimilikiTab ? const Color(0xFFECFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDimilikiTab ? const Color(0xFF10B981) : AppColors.inputBorder,
                          width: isDimilikiTab ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            'Paket Dimiliki Pasien (${_claimableItems.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isDimilikiTab ? FontWeight.w800 : FontWeight.w600,
                              color: isDimilikiTab ? const Color(0xFF065F46) : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Chip Semua Ruangan
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isDimilikiTab) _activeCategoryTab = 'layanan';
                      _selectedRoom = 'Semua';
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: (!isDimilikiTab && _selectedRoom == 'Semua') ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (!isDimilikiTab && _selectedRoom == 'Semua') ? AppColors.primary : AppColors.inputBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Semua',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: (!isDimilikiTab && _selectedRoom == 'Semua') ? FontWeight.w700 : FontWeight.w500,
                          color: (!isDimilikiTab && _selectedRoom == 'Semua') ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // Daftar Chip Ruangan Dinamis
                ..._roomList.where((r) => r != 'Semua').map((room) {
                  final isRoomSelected = !isDimilikiTab && _selectedRoom == room;
                  final isRoomActive = _activeNamaRuangan != null && _activeNamaRuangan == room;
                  final isConflict = _activeNamaRuangan != null && !isRoomActive;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isDimilikiTab) _activeCategoryTab = 'layanan';
                        _selectedRoom = room;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isRoomSelected
                            ? (isRoomActive ? const Color(0xFFECFDF5) : AppColors.primary)
                            : (isConflict ? const Color(0xFFFEF2F2) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRoomSelected
                              ? (isRoomActive ? const Color(0xFF10B981) : AppColors.primary)
                              : (isConflict ? const Color(0xFFFCA5A5) : AppColors.inputBorder),
                          width: (isRoomSelected || isRoomActive) ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isRoomActive) ...[
                            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                          ] else if (isConflict) ...[
                            const Text('🚫', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                          ] else ...[
                            Icon(Icons.meeting_room_outlined, size: 14, color: isRoomSelected ? Colors.white : AppColors.textMuted),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            room,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: (isRoomSelected || isRoomActive) ? FontWeight.w800 : FontWeight.w500,
                              color: isRoomSelected
                                  ? (isRoomActive ? const Color(0xFF065F46) : Colors.white)
                                  : (isRoomActive
                                      ? const Color(0xFF059669)
                                      : (isConflict ? const Color(0xFFDC2626) : AppColors.textDark)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // ── KONTEN DAFTAR: PAKET DIMILIKI vs LAYANAN SATUAN vs PAKET HEMAT ──
        if (_loadingLayanan)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (isDimilikiTab) ...[
          // ── DAFTAR PAKET DIMILIKI PASIEN (KLAIM SESI LANJUTAN - PERSIS GAMBAR 2) ──
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pasien memiliki paket aktif! Pilih sesi treatment di bawah ini untuk mengklaim sesi lanjutan (Rp 0).',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_filteredClaimable.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Center(
                child: Text(
                  'Tidak ada jatah sesi paket yang dapat diklaim pada ruangan ini.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredClaimable.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _filteredClaimable[index];
                final kodeDkpl = item['kode_detail_kepemilikan_paket_layanan'];
                final isSelected = _selectedItems.any((it) =>
                  it['kode_detail_kepemilikan_paket_layanan'] != null &&
                  it['kode_detail_kepemilikan_paket_layanan'] == kodeDkpl
                );
                final imageUrl = ApiConstants.getImageUrl(item['foto_layanan'] ?? item['foto'] ?? item['gambar']);
                final consultType = _getItemConsultType(item);
                final isInclude = item['is_include_konsultasi'] == 1 || item['is_include_konsultasi'] == true;

                return InkWell(
                  onTap: () => _toggleClaimItem(item),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF10B981) : AppColors.inputBorder,
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto Treatment / Icon
                        Container(
                          width: 58,
                          height: 58,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  imageUrl,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, stackTrace) => const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF059669),
                                    size: 26,
                                  ),
                                )
                              : const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF059669),
                                  size: 26,
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Detail Treatment Klaim
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_layanan'] ?? 'Layanan Paket',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Paket: ${item['nama_paket'] ?? 'Paket Perawatan'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Rp 0',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Klaim Kuota',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Badges: Sisa Sesi, Ruangan, Konsul, Durasi
                              Wrap(
                                spacing: 5,
                                runSpacing: 4,
                                children: [
                                  _buildBadge(
                                    'Klaim (${item['sisa_sesi']} Sesi)',
                                    const Color(0xFFB45309),
                                    const Color(0xFFFEF3C7),
                                  ),
                                  if (item['nama_ruangan'] != null)
                                    _buildBadge(item['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                                  if (consultType['isWajib'] == true)
                                    _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                                  else if (consultType['isOpsional'] == true)
                                    _buildBadge('Opsional Konsul', const Color(0xFF2563EB), const Color(0xFFDBEAFE))
                                  else
                                    _buildBadge('Tanpa Konsul', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                                  if (isInclude)
                                    _buildBadge('Include Konsul', const Color(0xFF059669), const Color(0xFFDCFCE7)),
                                  _buildBadge('${item['durasi_menit'] ?? 30} mnt', AppColors.primaryDark, AppColors.bgMintLight),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Checkbox Selection Bulat
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFF10B981) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF10B981) : AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ] else if (isLayananTab) ...[
          // ── LIST LAYANAN SATUAN (DENGAN TAMPILAN ITEM TERKLAIM DI RUANGAN INI - PERSIS GAMBAR 3) ──
          Builder(builder: (context) {
            // Cek apakah ada item klaim yang berada di ruangan yang sedang aktif/dilihat
            final claimedInThisRoom = _selectedItems.where((it) =>
              (it['is_klaim'] == true || it['is_claim_packet'] == true) &&
              (_selectedRoom == 'Semua' || it['nama_ruangan'] == _selectedRoom)
            ).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render Kartu Item Terklaim di Ruangan yang Sama (Persis Gambar 3 di Web)
                if (claimedInThisRoom.isNotEmpty) ...[
                  ...claimedInThisRoom.map((claimItem) {
                    final imageUrl = ApiConstants.getImageUrl(claimItem['foto_layanan'] ?? claimItem['foto'] ?? claimItem['gambar']);
                    final consultType = _getItemConsultType(claimItem);
                    final isInclude = claimItem['is_include_konsultasi'] == 1 || claimItem['is_include_konsultasi'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail Foto
                              Container(
                                width: 58,
                                height: 58,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: (imageUrl != null && imageUrl.isNotEmpty)
                                    ? Image.network(
                                        imageUrl,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, error, stackTrace) => const Icon(
                                          Icons.spa_rounded,
                                          color: Color(0xFF059669),
                                          size: 26,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.spa_rounded,
                                        color: Color(0xFF059669),
                                        size: 26,
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Info Treatment Terklaim
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD1FAE5),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🎁', style: TextStyle(fontSize: 10)),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Sudah Diklaim',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF065F46),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      claimItem['nama_layanan'] ?? claimItem['nama'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Rp 0 (Klaim Sesi Selesai)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF059669),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Badges
                                    Wrap(
                                      spacing: 5,
                                      runSpacing: 4,
                                      children: [
                                        if (claimItem['nama_ruangan'] != null)
                                          _buildBadge(claimItem['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                                        if (consultType['isWajib'] == true)
                                          _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                                        else if (consultType['isOpsional'] == true)
                                          _buildBadge('Opsional Konsul', const Color(0xFF2563EB), const Color(0xFFDBEAFE))
                                        else
                                          _buildBadge('Tanpa Konsul', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                                        if (isInclude)
                                          _buildBadge('Include', const Color(0xFF0D9488), const Color(0xFFCCFBF1)),
                                        _buildBadge('${claimItem['durasi_menit'] ?? 30} mnt', AppColors.primaryDark, AppColors.bgMintLight),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Checkbox checked
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Tombol Status Terklaim (Persis Gambar 3)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded, size: 14, color: Color(0xFF475569)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Sudah dipilih via Klaim',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Daftar Layanan Reguler dalam Ruangan
                if (_filteredLayanan.isEmpty && claimedInThisRoom.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Center(
                      child: Text(
                        'Tidak ada layanan pada kategori ruangan ini.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredLayanan.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredLayanan[index];
                      final kode = item['kode_layanan'];
                      // Cek apakah item ini sama dengan yang sudah diklaim
                      final isClaimedItem = _selectedItems.any((it) =>
                        it['kode_layanan'] == kode && (it['is_klaim'] == true || it['is_claim_packet'] == true)
                      );
                      if (isClaimedItem) {
                        return const SizedBox.shrink(); // Sudah ditampilkan di blok klaim di atas
                      }

                      final isSelected = _selectedItems.any((it) => it['kode_layanan'] == kode && it['is_klaim'] != true);
                      final imageUrl = ApiConstants.getImageUrl(item['gambar'] ?? item['foto']);
                      final consultType = _getItemConsultType(item);
                      final isInclude = item['is_include_konsultasi'] == 1 || item['is_include_konsultasi'] == true;
                      final isConflictRoom = _activeKodeRuangan != null && item['kode_ruangan'] != null && item['kode_ruangan'] != _activeKodeRuangan;

                      return InkWell(
                        onTap: () => _toggleItem(item),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.bgMintLight : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isConflictRoom ? const Color(0xFFFECACA) : AppColors.inputBorder),
                              width: isSelected ? 1.8 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail Foto
                              Container(
                                width: 58,
                                height: 58,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: (imageUrl != null && imageUrl.isNotEmpty)
                                    ? Image.network(
                                        imageUrl,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, error, stackTrace) => const Icon(
                                          Icons.spa_rounded,
                                          color: AppColors.primary,
                                          size: 26,
                                        ),
                                      )
                                    : const Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                              ),
                              const SizedBox(width: 12),

                              // Detail Treatment
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama_layanan'] ?? item['nama'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _formatRupiah(item['harga']),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Badges: Ruangan, Konsultasi, Include, Durasi
                                    Wrap(
                                      spacing: 5,
                                      runSpacing: 4,
                                      children: [
                                        if (item['nama_ruangan'] != null)
                                          _buildBadge(item['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                                        if (consultType['isWajib'] == true)
                                          _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                                        else if (consultType['isOpsional'] == true)
                                          _buildBadge('Opsional Konsul', const Color(0xFF2563EB), const Color(0xFFDBEAFE))
                                        else
                                          _buildBadge('Tanpa Konsul', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                                        if (isInclude)
                                          _buildBadge('Include', const Color(0xFF0D9488), const Color(0xFFCCFBF1)),
                                        _buildBadge('${item['durasi_menit'] ?? 30} mnt', AppColors.primaryDark, AppColors.bgMintLight),
                                        if (isConflictRoom)
                                          _buildBadge('Beda Ruangan', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Checkbox Selection
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.primary : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.inputBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          }),
        ] else ...[
          // ── LIST PAKET PERAWATAN ──
          if (_filteredPaket.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Center(
                child: Text(
                  'Tidak ada paket perawatan pada kategori ruangan ini.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredPaket.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final pkt = _filteredPaket[index];
                final kode = pkt['kode_paket_layanan'] ?? pkt['kode_layanan'];
                final isSelected = _selectedItems.any((it) => it['kode_layanan'] == kode && it['is_klaim'] != true);
                final imageUrl = ApiConstants.getImageUrl(pkt['foto'] ?? pkt['gambar']);
                final details = (pkt['details'] is List) ? (pkt['details'] as List) : [];
                final totalSesi = pkt['total_sesi'] ?? details.length;
                final isConflictRoom = _activeKodeRuangan != null && pkt['kode_ruangan'] != null && pkt['kode_ruangan'] != _activeKodeRuangan;

                return InkWell(
                  onTap: () => _togglePaket(pkt),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD97706)
                            : (isConflictRoom ? const Color(0xFFFECACA) : AppColors.inputBorder),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Paket
                        Container(
                          width: 58,
                          height: 58,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  imageUrl,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, stackTrace) => const Icon(
                                    Icons.card_giftcard_rounded,
                                    color: Color(0xFFD97706),
                                    size: 26,
                                  ),
                                )
                              : const Icon(
                                  Icons.card_giftcard_rounded,
                                  color: Color(0xFFD97706),
                                  size: 26,
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Detail Paket
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'PAKET HEMAT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                  if (pkt['nama_ruangan'] != null) ...[
                                    const SizedBox(width: 5),
                                    _buildBadge(pkt['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pkt['nama'] ?? pkt['nama_paket'] ?? 'Paket Perawatan',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatRupiah(pkt['harga_paket'] ?? pkt['harga']),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD97706),
                                ),
                              ),

                              // Preview item di dalam paket
                              if (details.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Isi Paket ($totalSesi Sesi):',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      ...details.take(2).map((d) {
                                        return Text(
                                          '• ${d['jumlah_sesi']}x ${d['nama_layanan'] ?? 'Perawatan'}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: AppColors.textMuted,
                                          ),
                                        );
                                      }),
                                      if (details.length > 2)
                                        Text(
                                          '+ ${details.length - 2} item lainnya',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Checkbox bulat
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFFD97706) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFD97706) : AppColors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // 2.5 PILIHAN ALUR KUNJUNGAN PASIEN (PERSIS SEPERTI DI WEB)
  Widget _buildConsultationFlowSection() {
    if (_selectedItems.isEmpty) return const SizedBox.shrink();

    if (_hasWajibKonsul) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_outlined, color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Wajib Konsultasi Dokter Terlebih Dahulu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Salah satu tindakan yang Anda pilih berstatus tindakan medis (Medical Treatment). '
                    'Pasien otomatis diarahkan ke Ruang Konsultasi Dokter saat check-in di klinik sebelum tindakan.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFFB91C1C),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_hasOpsionalKonsul) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: Color(0xFF6366F1), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pilihan Alur Kunjungan Pasien',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildBadge('Opsional Konsul', const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Tindakan yang dipilih menyertakan opsi konsultasi dokter pra-tindakan. Tentukan alur kunjungan saat pasien tiba / check-in di klinik:',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, height: 1.35),
            ),
            const SizedBox(height: 12),

            // 2 Opsi Card: Konsultasi Dokter Dulu vs Langsung Tindakan (Sama Persis seperti di Web)
            Row(
              children: [
                // Opsi 1: Konsultasi Dokter Dulu
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _pilihanKonsul = true),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: _pilihanKonsul ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _pilihanKonsul ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                          width: _pilihanKonsul ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _pilihanKonsul ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_search_rounded,
                                  color: _pilihanKonsul ? Colors.white : const Color(0xFF64748B),
                                  size: 16,
                                ),
                              ),
                              if (_pilihanKonsul)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 18),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Konsultasi Dokter Dulu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _pilihanKonsul ? const Color(0xFF4338CA) : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pasien antre di Ruang Konsultasi Dokter sebelum treatment.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Opsi 2: Langsung Tindakan
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _pilihanKonsul = false),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: !_pilihanKonsul ? const Color(0xFFECFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_pilihanKonsul ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                          width: !_pilihanKonsul ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: !_pilihanKonsul ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  color: !_pilihanKonsul ? Colors.white : const Color(0xFF64748B),
                                  size: 16,
                                ),
                              ),
                              if (!_pilihanKonsul)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Langsung Tindakan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !_pilihanKonsul ? const Color(0xFF065F46) : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pasien langsung dilayani di ruang tindakan tanpa antre dokter.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // 3. PILIH TANGGAL, SESI DOKTER & JAM KEDATANGAN SPESIFIK
  Widget _buildDateAndScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Pilih Tanggal & Sesi Dokter',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 10),

        // Input Tanggal Kunjungan
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal Janji Temu', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                      Text(
                        _formatTanggalIndo(_selectedDate),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                Text('Ubah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Sesi Dokter Tersedia
        if (_loadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.event_busy_rounded, color: Colors.amber.shade800, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tidak ada sesi jadwal dokter di ruangan ini pada tanggal terpilih. Silakan ganti tanggal atau ruangan.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableSlots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final slot = _availableSlots[index];
              final isSelected = _selectedSlot?['kode_jadwal'] == slot['kode_jadwal'];
              final isPenuh = slot['is_penuh'] == true;

              return InkWell(
                onTap: isPenuh
                    ? null
                    : () {
                        setState(() {
                          _selectedSlot = slot;
                          _autoSelectDefaultTime();
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.bgMintLight : (isPenuh ? Colors.grey.shade100 : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isPenuh ? Colors.grey.shade300 : AppColors.inputBorder),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot['nama_dokter'] ?? 'Dokter Klinik',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                            Text(
                              "${slot['jam_mulai']} - ${slot['jam_selesai']} WIB · ${slot['nama_ruangan'] ?? ''}",
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPenuh ? Colors.red.shade50 : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isPenuh ? 'Penuh' : 'Sisa: ${slot['sisa_kuota']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPenuh ? AppColors.error : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Grid Jam Kedatangan Spesifik
        if (_selectedSlot != null) ...[
          const SizedBox(height: 14),
          Text(
            'Pilih Jam Janji Temu Spesifik:',
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          _buildTimeSlotsGrid(),
        ],
      ],
    );
  }

  Widget _buildTimeSlotsGrid() {
    final slots = _generateTimeSlots();
    if (slots.isEmpty) {
      return Text('Tidak ada slot jam tersedia pada sesi ini.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((st) {
        final timeStr = st['time'] as String;
        final isSelected = _selectedJamBooking == timeStr;
        final isBooked = st['isBooked'] == true;
        final isPast = st['isPast'] == true;
        final isDisabled = isBooked || isPast;

        return InkWell(
          onTap: isDisabled ? null : () => setState(() => _selectedJamBooking = timeStr),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isDisabled
                      ? Colors.grey.shade100
                      : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isDisabled
                        ? Colors.grey.shade300
                        : AppColors.inputBorder,
              ),
            ),
            child: Column(
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                            ? Colors.grey.shade400
                            : AppColors.textDark,
                  ),
                ),
                Text(
                  isPast
                      ? 'Lewat'
                      : isBooked
                          ? 'Terisi'
                          : 'WIB',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : isBooked
                            ? Colors.red.shade400
                            : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. KELUHAN / CATATAN PASIEN
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. Catatan Pasien (Opsional)',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            controller: _catatanCtrl,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Keluhan awal, kondisi kulit, atau permintaan khusus...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  // 5. PANEL "RINCIAN RESERVASI & DP" (SESUAI DENGAN WEB)
  Widget _buildReservationAndDpPanel() {
    final pasienNama = _currentUser?['nama'] ?? 'Pelanggan';
    final pasienRm = _currentUser?['no_rm'] ?? '-';
    final dokterNama = _selectedSlot?['nama_dokter'] ?? 'Belum dipilih';
    final jamStr = _selectedJamBooking != null ? '$_selectedJamBooking WIB' : 'Pilih jam...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Rincian Reservasi & DP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Rincian Reservasi & DP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ],
              ),
              if (_selectedItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_selectedItems.length} Item',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Info Table (Mirip Web)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _summaryRow('Pasien:', '$pasienNama ($pasienRm)'),
                _summaryRow('Ruangan Tujuan:', _activeNamaRuangan ?? 'Belum dipilih', highlight: true),
                _summaryRow('Tanggal:', "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}"),
                _summaryRow('Jadwal:', _selectedSlot != null ? '$dokterNama ($jamStr)' : 'Belum dipilih'),
                _summaryRow(
                  'Alur Kunjungan:',
                  _hasWajibKonsul
                      ? 'Wajib Konsul Dokter'
                      : (_pilihanKonsul ? 'Konsultasi Dokter Dulu' : 'Langsung Tindakan'),
                  badgeColor: _hasWajibKonsul
                      ? const Color(0xFFFEE2E2)
                      : (_pilihanKonsul ? const Color(0xFFEEF2FF) : const Color(0xFFD1FAE5)),
                  badgeTextColor: _hasWajibKonsul
                      ? const Color(0xFFDC2626)
                      : (_pilihanKonsul ? const Color(0xFF4338CA) : const Color(0xFF059669)),
                ),

                const Divider(height: 14),

                // Daftar Item Treatment
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Item Layanan / Paket:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 4),
                if (_selectedItems.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Belum ada layanan dipilih',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textLight),
                    ),
                  )
                else
                  ..._selectedItems.map((it) {
                    final isPkt = it['is_paket'] == true || it['jenis'] == 'paket';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket') ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'KLAIM PAKET',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF065F46),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ] else if (isPkt) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'PAKET',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    it['nama_layanan'] ?? it['nama'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: isPkt ? FontWeight.w700 : FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket')
                                ? 'Rp 0 (Klaim Sesi)'
                                : _formatRupiah(it['harga']),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: (it['is_klaim'] == true || it['is_claim_packet'] == true || it['jenis'] == 'klaim_paket')
                                  ? const Color(0xFF059669)
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const Divider(height: 14),

                // Total Biaya
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Biaya:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      _totalBiaya == 0 ? 'Rp 0 (Klaim Paket)' : _formatRupiah(_totalBiaya),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _totalBiaya == 0 ? const Color(0xFF059669) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Ketentuan Uang Muka / DP 20% ATAU Banner Bebas DP Klaim Paket
          if (_dpNominal == 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.loyalty_rounded, color: Color(0xFF16A34A), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Klaim Sesi Paket Terpilih',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Layanan ini menggunakan jatah kuota paket aktif Anda. Bebas biaya uang muka (DP Rp 0) dan tidak perlu transfer.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF15803D),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Text(
              'Uang Muka / DP (Wajib 20%):',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nominal DP (20%):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                      Text(_formatRupiah(_dpNominal), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sisa di Kasir (80%):', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                      Text(_formatRupiah(_sisaPelunasan), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Default 20%. Nominal DP diperlukan sebagai jaminan komitmen untuk penguncian kuota jadwal dokter.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pilihan Metode Pembayaran DP
            Text(
              'Metode Pembayaran DP:',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodOption(
                    id: 'transfer',
                    title: 'Transfer Bank',
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentMethodOption(
                    id: 'qris',
                    title: 'QRIS Scan',
                    icon: Icons.qr_code_scanner_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pilihan Rekening / QRIS Tujuan Transfer Sesuai Web (Gambar 1)
            _buildPaymentAccountSection(),
          ],

        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false, Color? badgeColor, Color? badgeTextColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
          if (badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(5)),
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: badgeTextColor),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: highlight ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _metodeDp == id;
    return InkWell(
      onTap: () => setState(() => _metodeDp = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgMintLight : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_metodeDp == 'transfer') ...[
          // Header Transfer Bank Sesuai Web (Gambar 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Rekening Tujuan Transfer:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${_rekeningList.length} Rekening Aktif',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_loadingPaymentMethods)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_rekeningList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                'Belum ada rekening transfer aktif yang terdaftar.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
              ),
            )
          else
            ..._rekeningList.map((rek) {
              final isSel = _selectedRekening?['id'] == rek['id'] ||
                  _selectedRekening?['kode_metode'] == rek['kode_metode'];
              return InkWell(
                onTap: () => setState(() => _selectedRekening = rek),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFF5F3FF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: isSel ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSel
                            ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_rounded,
                              color: isSel ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rek['nama_bank'] ?? 'Bank Transfer',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                if (rek['atas_nama'] != null)
                                  Text(
                                    'a.n. ${rek['atas_nama']}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSel)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFC7D2FE)),
                              ),
                              child: Text(
                                'Dipilih',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4338CA),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rek['no_rekening'] ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final norek = rek['no_rekening']?.toString() ?? '';
                              if (norek.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: norek));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF1E293B),
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    content: Text(
                                      'Nomor rekening ${rek['nama_bank']} berhasil disalin!',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_rounded, size: 11, color: Color(0xFF475569)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Salin',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ] else ...[
          // Tampilan QRIS Sesuai Web (Gambar 2)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Nominal Pembayaran QRIS:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRupiah(_dpNominal),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Builder(
                    builder: (context) {
                      final qrisUrl = ApiConstants.getImageUrl(_qrisData?['gambar_qris']);
                      if (qrisUrl == null || qrisUrl.isEmpty) {
                        return const SizedBox(
                          width: 170,
                          height: 170,
                          child: Center(
                            child: Text(
                              'QRIS belum diunggah di web',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return Image.network(
                        qrisUrl,
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(
                          width: 170,
                          height: 170,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEA580C),
                    side: const BorderSide(color: Color(0xFFF97316), width: 1.2),
                    backgroundColor: const Color(0xFFFFF7ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 14),
                  label: Text(
                    'Perbesar QRIS',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _showEnlargedQrisModal,
                ),
                const SizedBox(height: 10),
                Text(
                  'Gunakan aplikasi perbankan atau e-wallet (BCA, Mandiri, GoPay, OVO, Dana, ShopeePay) untuk scan kode di atas.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── TOMBOL AKSI LANGKAH 2 ──
  Widget _buildStep2ActionButton() {
    if (_dpNominal == 0) {
      return InkWell(
        onTap: _submitting ? null : _handleSubmitBookingBebasDp,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_submitting) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Menyimpan Reservasi...',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
                ),
              ] else ...[
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Konfirmasi Reservasi (Bebas DP)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Tombol menuju Langkah 3 (Upload Bukti DP & Kunci Transaksi)
    return InkWell(
      onTap: _creatingPending ? null : _proceedToStep3,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_creatingPending) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                'Mengunci Kuota Jadwal...',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
              ),
            ] else ...[
              Text(
                'Lanjut ke Upload Bukti DP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19),
            ],
          ],
        ),
      ),
    );
  }

  // ── BOX UPLOAD BUKTI DP (DIGUNAKAN DI LANGKAH 3) ──
  Widget _buildUploadBuktiDpBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Bukti Pembayaran DP (Wajib):',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            if (_buktiDpImage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgMintLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Terlampir',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (_buktiDpImage == null)
          // Dropzone Style persis Gambar 2
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6EE7B7), width: 1.2),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  'Unggah Foto / Screenshot Bukti Transfer',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Format: JPG, PNG, WEBP (Maks 5 MB) agar diverifikasi kasir',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => _pickBuktiDp(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 17),
                      label: Text('Kamera', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => _pickBuktiDp(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 17),
                      label: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Tampilan sudah upload (Preview Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buktiDpBytes != null
                      ? Image.memory(
                          _buktiDpBytes!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 52,
                          height: 52,
                          color: AppColors.bgMintLight,
                          child: const Icon(Icons.image_rounded, color: AppColors.primary),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _buktiDpImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Foto bukti transfer siap dikirim',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ganti Gambar',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
                  onPressed: () => _pickBuktiDp(ImageSource.gallery),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                  onPressed: _removeBuktiDp,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── KONTEN LENGKAP LANGKAH 3 (PERSIS GAMBAR KEDUA DARI USER) ──
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(),

        // Alert Banner Transaksi Pending Terkunci
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_clock_rounded, color: Color(0xFFB45309), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi Dikunci (Pending Pembayaran)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking ${_createdBooking?['kode_booking'] ?? ''} telah mengunci slot kuota dokter. Harap selesaikan upload bukti transfer DP sebesar ${_formatRupiah(_dpNominal)} agar dapat diproses.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFFB45309),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Section Upload Bukti Transfer (Persis Gambar 2)
        _buildUploadBuktiDpBox(),
        const SizedBox(height: 14),

        // Checkbox Persetujuan DP 20% (Persis Gambar 2)
        InkWell(
          onTap: () => setState(() => _persetujuanDp = !_persetujuanDp),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _persetujuanDp ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _persetujuanDp ? const Color(0xFF86EFAC) : AppColors.inputBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _persetujuanDp,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _persetujuanDp = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saya menyetujui ketentuan pembayaran DP 20% sebesar ${_formatRupiah(_dpNominal)} untuk mengonfirmasi jadwal reservasi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Ringkasan & Kebijakan Booking (Persis Gambar 2)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    'RINGKASAN & KEBIJAKAN BOOKING',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF065F46),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _policyItem(
                'Kebijakan DP',
                'Uang muka yang telah dibayar otomatis dipotongkan ke tagihan saat check-in di kasir klinik. Bila pasien tidak hadir tanpa konfirmasi, DP dinyatakan hangus.',
              ),
              _policyItem(
                'Toleransi Keterlambatan',
                'Maksimal 30 menit dari jam booking sebelum status otomatis ditandai batal / tidak hadir.',
              ),
              _policyItem(
                'Alokasi Jadwal',
                'Slot dan jam kedatangan yang dipilih terkunci khusus untuk Anda saat booking dibuat.',
              ),
              _policyItem(
                'Pelunasan di Tempat',
                'Sisa pembayaran 80% dilunasi langsung di kasir klinik setelah perawatan selesai.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tombol Submit Langkah 3 (Persis Gambar 2)
        _buildStep3SubmitButton(),
        const SizedBox(height: 12),

        // Tombol Batalkan Transaksi Booking Ini
        Center(
          child: TextButton.icon(
            onPressed: _submitting ? null : _cancelCurrentPendingBooking,
            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
            label: Text(
              'Batalkan Transaksi Booking Ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── TOMBOL KONFIRMASI & BUAT JANJI TEMU LANGKAH 3 ──
  Widget _buildStep3SubmitButton() {
    final canSubmit = _buktiDpImage != null && _persetujuanDp;

    return InkWell(
      onTap: (_submitting || !canSubmit) ? null : _submitStep3BuktiDp,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: canSubmit ? AppColors.primaryGradient : null,
          color: canSubmit ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(999),
          boxShadow: canSubmit
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_submitting) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                'Mengunggah Bukti DP...',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
              ),
            ] else ...[
              Icon(Icons.check_rounded, color: canSubmit ? Colors.white : const Color(0xFF64748B), size: 20),
              const SizedBox(width: 8),
              Text(
                'Konfirmasi & Buat Janji Temu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: canSubmit ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _policyItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF4B5563), height: 1.35),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

extension StringSlice on String {
  String sliceSafe(int start, [int? end]) {
    if (isEmpty) return '';
    final s = start < 0 ? 0 : (start > length ? length : start);
    final e = end == null ? length : (end < 0 ? 0 : (end > length ? length : end));
    if (s >= e) return '';
    return substring(s, e);
  }
}
