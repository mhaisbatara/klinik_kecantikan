import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLayanan;

  const BookingScreen({super.key, this.initialLayanan});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Data Pasien Login
  Map<String, dynamic>? _currentUser;

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

  // Catatan Keluhan
  final _catatanCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchLayanan();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _fetchLayanan() async {
    setState(() => _loadingLayanan = true);
    final list = await BookingService.getLayananList();
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

      // Inisialisasi dari parameter jika ada
      if (widget.initialLayanan != null) {
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

  bool get _hasWajibKonsul {
    return _selectedItems.any((it) {
      final wk = (it['wajib_konsultasi'] ?? '').toString().toLowerCase();
      final tp = (it['tipe'] ?? '').toString().toUpperCase();
      return wk == 'wajib' || tp == 'MEDICAL TREATMENT';
    });
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
    if (!_persetujuanDp) {
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
      };
    }).toList();

    final result = await BookingService.createBooking(
      kodeJadwal: _selectedSlot!['kode_jadwal'],
      tanggalBooking: dateStr,
      jamBooking: _selectedJamBooking!,
      kodeLayanan: formattedItems.first['kode_layanan'],
      items: formattedItems,
      catatan: _catatanCtrl.text.trim(),
      metodeDp: _metodeDp,
      buktiDpFile: _buktiDpImage,
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
                    _strukRow('Pasien', data?['nama_pasien'] ?? _currentUser?['nama'] ?? '-'),
                    _strukRow('Ruangan', data?['nama_ruangan'] ?? _activeNamaRuangan ?? '-'),
                    _strukRow('Tanggal', data?['tanggal_booking'] ?? '-'),
                    _strukRow('Jam', "${data?['jam_booking'] ?? _selectedJamBooking ?? '-'} WIB"),
                    _strukRow('Dokter', data?['nama_dokter'] ?? _selectedSlot?['nama_dokter'] ?? '-'),
                    const Divider(height: 14),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat Reservasi / Booking Baru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
            Text(
              'Pilih layanan, jadwal dokter, dan konfirmasi DP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LANGKAH 1: IDENTITAS PASIEN & CABANG ──
            _buildPatientHeaderCard(),
            const SizedBox(height: 20),

            // ── LANGKAH 2: PILIH LAYANAN & PAKET TREATMENT ──
            _buildTreatmentSelectionSection(),
            const SizedBox(height: 20),

            // ── LANGKAH 3: PILIH TANGGAL & SESI JADWAL ──
            _buildDateAndScheduleSection(),
            const SizedBox(height: 20),

            // ── LANGKAH 4: KELUHAN / CATATAN KHUSUS ──
            _buildNotesSection(),
            const SizedBox(height: 22),

            // ── LANGKAH 5: PANEL RINCIAN RESERVASI & DP (KETENTUAN SAMA SEPERTI WEB) ──
            _buildReservationAndDpPanel(),
            const SizedBox(height: 24),

            // ── TOMBOL SUBMIT RESERVASI ──
            _buildSubmitButton(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // 1. KARTU INFORMASI PASIEN
  Widget _buildPatientHeaderCard() {
    final nama = _currentUser?['nama'] ?? 'Pelanggan Klinik';
    final noRm = _currentUser?['no_rm'] ?? 'RM-BARU';
    final noHp = _currentUser?['no_hp'] ?? '-';
    final cabang = _currentUser?['nama_cabang'] ?? 'Cabang Utama';

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
            Column(
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
            if (_selectedItems.isNotEmpty)
              Container(
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
              final wajibKonsul = (item['wajib_konsultasi'] ?? '').toString().toLowerCase();
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

                            // Badges: Durasi, Kategori, Konsultasi
                            Wrap(
                              spacing: 5,
                              runSpacing: 4,
                              children: [
                                // Badge Ruangan
                                if (item['nama_ruangan'] != null)
                                  _buildBadge(item['nama_ruangan'], const Color(0xFF6B7280), const Color(0xFFF3F4F6)),

                                // Badge Konsultasi
                                if (wajibKonsul == 'wajib')
                                  _buildBadge('Wajib Konsul', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                                else if (isInclude)
                                  _buildBadge('Include Konsul', const Color(0xFF0D9488), const Color(0xFFCCFBF1))
                                else
                                  _buildBadge('Tanpa Konsul', const Color(0xFF059669), const Color(0xFFD1FAE5)),

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
                  _hasWajibKonsul ? 'Wajib Konsul Dokter' : 'Langsung Tindakan',
                  badgeColor: _hasWajibKonsul ? Colors.amber.shade100 : const Color(0xFFD1FAE5),
                  badgeTextColor: _hasWajibKonsul ? Colors.amber.shade900 : const Color(0xFF059669),
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

          // Ketentuan Uang Muka / DP 20%
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
                      'Saya menyetujui ketentuan pembayaran DP 20% sebesar ${_formatRupiah(_dpNominal)} untuk mengonfirmasi jadwal reservasi.',
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
        // Instruksi Rekening / QRIS
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _metodeDp == 'transfer' ? 'REKENING TUJUAN TRANSFER DP' : 'QRIS SCAN PEMBAYARAN DP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_metodeDp == 'transfer') ...[
                _rekeningRow('Bank BCA', '873-092-1234', 'a.n Klinik Kecantikan'),
                const SizedBox(height: 4),
                _rekeningRow('Bank Mandiri', '142-00-1928-3344', 'a.n Klinik Kecantikan'),
              ] else ...[
                Text(
                  'Silakan scan QRIS Klinik Kecantikan melalui Mobile Banking atau E-Wallet (GoPay, OVO, Dana, ShopeePay, BCA/Mandiri Mobile) sebesar ${_formatRupiah(_dpNominal)}.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textDark, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

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
                  decoration: BoxDecoration(
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

  Widget _rekeningRow(String bank, String norek, String an) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bank, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(an, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
        Text(
          norek,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
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
