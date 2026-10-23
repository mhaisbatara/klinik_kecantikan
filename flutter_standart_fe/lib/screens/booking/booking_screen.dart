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

  const BookingScreen({
    super.key,
    this.initialLayanan,
    this.selectedCabang,
    this.klaimPaketData,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Multi-step Booking Flow:
  // 1: Pengisian Layanan, Alur Kunjungan, Jadwal & Catatan (Gambar 2)
  // 2: Rincian Reservasi & Pembayaran DP (Gambar 1)
  int _currentStep = 1;
  final ScrollController _scrollController = ScrollController();

  // Data Pasien Login & Cabang Terpilih
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _activeCabang;

  // Pilihan Alur Konsultasi Pasien (Persis seperti di Web)
  // false: Langsung Tindakan, true: Konsultasi Dokter Dulu
  bool _pilihanKonsul = false;

  // Katalog Layanan & Ruangan
  List<dynamic> _allLayanan = [];
  List<String> _roomList = ['Semua'];
  String _selectedRoom = 'Semua';
  bool _loadingLayanan = true;

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
    _activeCabang = widget.selectedCabang;
    _loadUser();
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
    setState(() => _currentStep = 1);

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

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        if (_activeCabang == null && user != null) {
          _activeCabang = {
            'kode_cabang': user['kode_cabang'] ?? 'CBG-001',
            'nama_cabang': user['nama_cabang'] ?? 'Klinik Cabang Utama',
          };
        }
      });
    }
  }

  Future<void> _fetchLayanan() async {
    setState(() => _loadingLayanan = true);
    final list = await BookingService.getLayananList(
      kodeCabang: _activeCabang?['kode_cabang'],
    );
    if (!mounted) return;

    // Kumpulkan nama ruangan unik
    final Set<String> uniqueRooms = {'Semua'};
    for (final it in list) {
      final rName = (it['nama_ruangan'] ?? '').toString().trim();
      if (rName.isNotEmpty) {
        uniqueRooms.add(rName);
      }
    }

    setState(() {
      _allLayanan = list;
      _roomList = uniqueRooms.toList();
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

  void _toggleItem(Map<String, dynamic> item) {
    final kode = item['kode_layanan'];
    final itemRoom = item['kode_ruangan'];
    final itemRoomName = item['nama_ruangan'] ?? 'Ruang Treatment';

    final exists = _selectedItems.any((it) => it['kode_layanan'] == kode);

    if (exists) {
      setState(() {
        _selectedItems.removeWhere((it) => it['kode_layanan'] == kode);
        if (_selectedItems.isEmpty) {
          _activeKodeRuangan = null;
          _activeNamaRuangan = null;
          _selectedSlot = null;
          _selectedJamBooking = null;
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

  void _showRoomConflictDialog(Map<String, dynamic> newItem, String newRoom, String newRoomName) {
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
      kodeCabang: _activeCabang?['kode_cabang'],
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

  num get _totalBiaya {
    num total = 0;
    for (final it in _selectedItems) {
      total += _toNum(it['harga']);
    }
    return total;
  }

  num get _dpNominal => (_totalBiaya * 0.2).round();
  num get _sisaPelunasan => _totalBiaya - _dpNominal;

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

  Future<void> _handleSubmitBooking() async {
    final noRm = _currentUser?['no_rm'];
    if (noRm == null || noRm.toString().trim().isEmpty) {
      _showToast('Akun Anda belum terhubung dengan Rekam Medis (No. RM). Silakan lengkapi pendaftaran pasien terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedItems.isEmpty) {
      _showToast('Pilih minimal satu layanan perawatan di Langkah 2', isError: true);
      return;
    }
    if (_selectedSlot == null) {
      _showToast('Pilih jadwal dokter yang tersedia di Langkah 3', isError: true);
      return;
    }
    if (_selectedJamBooking == null) {
      _showToast('Pilih jam kedatangan janji temu yang tersedia', isError: true);
      return;
    }
    if (_dpNominal > 0 && !_persetujuanDp) {
      _showToast('Centang persetujuan uang muka (DP 20%) untuk melanjutkan', isError: true);
      return;
    }
    if (_dpNominal > 0 && _buktiDpImage == null) {
      _showToast('Silakan upload bukti pembayaran DP terlebih dahulu', isError: true);
      return;
    }

    final dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    setState(() => _submitting = true);

    final formattedItems = _selectedItems.map((it) {
      return {
        'kode_layanan': it['kode_layanan'],
        'nama_layanan': it['nama_layanan'] ?? it['nama'],
        'harga': _toNum(it['harga']),
        'durasi_menit': _toNum(it['durasi_menit']).toInt(),
        if (it['is_klaim'] == true) ...{
          'is_klaim': true,
          'is_klaim_paket': true,
          'jenis': 'klaim_paket',
          'kode_kepemilikan_paket_layanan': it['kode_kepemilikan_paket_layanan'],
          'kode_detail_kepemilikan_paket_layanan': it['kode_detail_kepemilikan_paket_layanan'],
        },
      };
    }).toList();

    final effectiveButuhKonsul = _hasWajibKonsul ? true : (_hasOpsionalKonsul ? _pilihanKonsul : false);

    // Ambil kode metode pembayaran aktif terpilih agar sinkron dengan kasir web
    String? selectedKodeMetode;
    if (_dpNominal == 0) {
      selectedKodeMetode = 'MP-PAKET';
    } else if (_metodeDp == 'transfer') {
      selectedKodeMetode = _selectedRekening?['kode_metode'] ?? 'MP-001';
    } else if (_metodeDp == 'qris') {
      selectedKodeMetode = _qrisData?['kode_metode'] ?? 'MP-003';
    }

    final result = await BookingService.createBooking(
      kodeJadwal: _selectedSlot!['kode_jadwal'],
      tanggalBooking: dateStr,
      jamBooking: _selectedJamBooking!,
      kodeLayanan: formattedItems.first['kode_layanan'],
      items: formattedItems,
      catatan: _catatanCtrl.text.trim(),
      metodeDp: _dpNominal == 0 ? 'paket' : _metodeDp,
      kodeMetodePembayaran: selectedKodeMetode,
      buktiDpFile: _dpNominal == 0 ? null : _buktiDpImage,
      kodeCabang: _activeCabang?['kode_cabang'] ?? _currentUser?['kode_cabang'] ?? 'CBG-001',
      butuhKonsul: effectiveButuhKonsul,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      _showSuccessDialog(result['data']);
    } else {
      _showToast(result['message'] ?? 'Gagal membuat reservasi', isError: true);
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
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bukti pembayaran DP telah berhasil diunggah dan akan diverifikasi oleh kasir sebelum menyelesaikan pesanan Anda.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.amber.shade900),
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
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep == 2) {
          _goToStep1();
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
                    : 'Rincian Reservasi & DP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
              ),
              Text(
                _currentStep == 1
                    ? 'Langkah 1 dari 2: Isi layanan & jadwal dokter'
                    : 'Langkah 2 dari 2: Rincian biaya & pembayaran DP',
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
          child: _currentStep == 1 ? _buildStep1Content() : _buildStep2Content(),
        ),
      ),
    );
  }

  // ── INDIKATOR LANGKAH MULTI-STEP ──
  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              onTap: _currentStep == 2 ? _goToStep1 : null,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep == 1
                          ? AppColors.primary
                          : const Color(0xFF10B981),
                    ),
                    child: Center(
                      child: _currentStep > 1
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : Text(
                              '1',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANGKAH 1',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _currentStep == 1 ? AppColors.primary : AppColors.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          'Layanan & Jadwal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
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

          // Divider Icon / Panah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _currentStep == 2 ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ),

          // Langkah 2
          Expanded(
            child: InkWell(
              onTap: _currentStep == 1 ? _goToStep2 : null,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep == 2
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _currentStep == 2 ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANGKAH 2',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _currentStep == 2 ? AppColors.primary : AppColors.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          'Rincian & DP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
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

        // Banner pintasan kembali ubah jadwal/layanan
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

        // Tombol Submit Reservasi
        _buildSubmitButton(),
        const SizedBox(height: 12),

        // Tombol Kembali
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

  // 1. KARTU INFORMASI PASIEN
  Widget _buildPatientHeaderCard() {
    final nama = _currentUser?['nama'] ?? 'Pelanggan Klinik';
    final noRm = _currentUser?['no_rm'] ?? 'RM-BARU';
    final noHp = _currentUser?['no_hp'] ?? '-';
    final cabang = _activeCabang?['nama_cabang'] ?? _currentUser?['nama_cabang'] ?? 'Klinik Cabang Utama';

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
      child: Row(
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
                Row(
                  children: [
                    Text('No. HP: $noHp', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    Text('·', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textLight)),
                    const SizedBox(width: 8),
                    Text(cabang, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. PILIHAN LAYANAN DENGAN TAB FILTER RUANGAN & MULTI-SELECT
  Widget _buildTreatmentSelectionSection() {
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
                    '1. Pilih Layanan Treatment',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  Text(
                    'Multi-select treatment dalam ruangan yang sama',
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

        // Tabs Filter Ruangan
        if (_roomList.length > 1)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roomList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final room = _roomList[index];
                final isSelected = _selectedRoom == room;
                return InkWell(
                  onTap: () => setState(() => _selectedRoom = room),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.inputBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        room,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        // Daftar Treatment Cards
        if (_loadingLayanan)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_filteredLayanan.isEmpty)
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
              final isSelected = _selectedItems.any((it) => it['kode_layanan'] == kode);
              final imageUrl = ApiConstants.getImageUrl(item['gambar'] ?? item['foto']);
              final consultType = _getItemConsultType(item);
              final isInclude = item['is_include_konsultasi'] == 1 || item['is_include_konsultasi'] == true;

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
                      color: isSelected ? AppColors.primary : AppColors.inputBorder,
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
                                errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
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
                                // Badge Ruangan
                                if (item['nama_ruangan'] != null)
                                  _buildBadge(item['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),

                                // Badge Konsultasi (Sesuai dengan Web)
                                if (consultType['isWajib'] == true)
                                  _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                                else if (consultType['isOpsional'] == true)
                                  _buildBadge('Opsional Konsul', const Color(0xFF2563EB), const Color(0xFFDBEAFE))
                                else
                                  _buildBadge('Tanpa Konsul', const Color(0xFF059669), const Color(0xFFD1FAE5)),

                                if (isInclude)
                                  _buildBadge('Include', const Color(0xFF0D9488), const Color(0xFFCCFBF1)),

                                // Badge Durasi
                                _buildBadge('${item['durasi_menit'] ?? 30} mnt', AppColors.primaryDark, AppColors.bgMintLight),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              it['nama_layanan'] ?? it['nama'] ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textDark),
                            ),
                          ),
                          Text(
                            _formatRupiah(it['harga']),
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
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
                      _formatRupiah(_totalBiaya),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
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

            // Upload Bukti Pembayaran DP
            _buildUploadBuktiDpSection(),
            const SizedBox(height: 14),
          ],

          // Checkbox Persetujuan DP
          InkWell(
            onTap: () => setState(() => _persetujuanDp = !_persetujuanDp),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _persetujuanDp ? AppColors.bgMintLight : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _persetujuanDp ? AppColors.primary : AppColors.inputBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _persetujuanDp,
                    activeColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) => setState(() => _persetujuanDp = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      _dpNominal == 0
                          ? 'Saya mengonfirmasi reservasi klaim sesi paket ini dengan jaminan jadwal kedatangan di klinik.'
                          : 'Saya menyetujui ketentuan pembayaran DP 20% sebesar ${_formatRupiah(_dpNominal)} untuk mengonfirmasi jadwal reservasi.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Box Ringkasan & Kebijakan Booking Klinik (Sama seperti Web)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      'RINGKASAN & KEBIJAKAN BOOKING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _policyItem('Kebijakan DP', 'Uang muka yang telah dibayar otomatis dipotongkan ke tagihan saat check-in di kasir klinik. Bila pasien tidak hadir tanpa konfirmasi, DP dinyatakan hangus.'),
                _policyItem('Toleransi Keterlambatan', 'Maksimal 30 menit dari jam booking sebelum status otomatis ditandai batal / tidak hadir.'),
                _policyItem('Alokasi Jadwal', 'Slot dan jam kedatangan yang dipilih terkunci khusus untuk Anda saat booking dibuat.'),
                _policyItem('Pelunasan di Tempat', 'Sisa pembayaran 80% dilunasi langsung di kasir klinik setelah perawatan selesai.'),
              ],
            ),
          ),
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

  Widget _buildUploadBuktiDpSection() {
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
        const SizedBox(height: 14),

        // Judul Field Upload
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Bukti Pembayaran DP (Wajib):',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
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
        const SizedBox(height: 6),

        if (_buktiDpImage == null)
          // Tampilan belum upload (Dropzone Style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.bgMintLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unggah Foto / Screenshot Bukti Transfer',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  'Format: JPG, PNG, WEBP (Maks 5 MB) agar diverifikasi kasir',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textLight),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => _pickBuktiDp(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: Text('Kamera', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => _pickBuktiDp(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Tampilan sudah upload (Preview Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buktiDpBytes != null
                      ? Image.memory(
                          _buktiDpBytes!,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 46,
                          height: 46,
                          color: AppColors.bgMintLight,
                          child: const Icon(Icons.image_rounded, color: AppColors.primary),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _buktiDpImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Siap dikirim',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
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
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
                  onPressed: () => _pickBuktiDp(ImageSource.gallery),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Hapus',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  onPressed: _removeBuktiDp,
                ),
              ],
            ),
          ),
      ],
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

  // 6. TOMBOL KONFIRMASI BOOKING
  Widget _buildSubmitButton() {
    final canSubmit = _selectedItems.isNotEmpty &&
        _selectedSlot != null &&
        _selectedJamBooking != null &&
        _persetujuanDp;

    return InkWell(
      onTap: (_submitting || !canSubmit) ? null : _handleSubmitBooking,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: canSubmit ? AppColors.primaryGradient : null,
          color: canSubmit ? null : Colors.grey.shade300,
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
                'Menyimpan Reservasi...',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
              ),
            ] else ...[
              Icon(Icons.check_rounded, color: canSubmit ? Colors.white : Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Konfirmasi & Buat Janji Temu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: canSubmit ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
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
