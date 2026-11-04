import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../booking/booking_screen.dart';
import '../branch/clinic_branches_screen.dart';
import '../profile/patient_sync_sheet.dart';
import '../profile/profile_screen.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigasi Utama (Bottom Navigation Bar)
  int _currentIndex = 0; // 0: Home Dashboard, 1: Booking Hub, 2: Riwayat

  // Filter & Search untuk Tab Booking
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  String _selectedCategory = 'Semua';
  String _bookingStatusFilter = 'semua'; // 'semua', 'aktif', 'selesai', 'tidak_hadir', 'dibatalkan'

  // Segmen Tab Riwayat (0: Reservasi, 1: Kunjungan Nyata)
  int _riwayatSegmentIndex = 0;
  String _kunjunganStatusFilter = 'semua'; // 'semua', 'selesai', 'berlangsung'
  List<dynamic> _myVisits = [];
  final Set<String> _expandedBookingCodes = {};
  final Set<String> _expandedVisitCodes = {};

  Map<String, dynamic>? _currentUser;
  List<dynamic> _myBookings = [];
  List<dynamic> _layananList = [];
  Map<String, dynamic>? _pendingBooking;
  List<Map<String, dynamic>> _cabangList = [];
  bool _loading = true;

  // Pemilihan Cabang Klinik untuk Booking Layanan
  Map<String, dynamic>? _selectedCabangBooking;
  bool _loadingLayananCabang = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadData();
    _refreshUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshUserData() async {
    final cached = await AuthService.getUser();
    if (cached != null && mounted) {
      setState(() => _currentUser = cached);
    }
    final remote = await AuthService.fetchProfile();
    final pending = await BookingService.getPendingBooking();
    if (mounted) {
      setState(() {
        if (remote != null) _currentUser = remote;
        _pendingBooking = pending;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final bookings = await BookingService.getBookingHistory();
    final visits = await BookingService.getKunjunganHistoryPaged();
    final cabangList = await AuthService.getCabangList();
    final pending = await BookingService.getPendingBooking();

    List<dynamic> layanan = [];
    if (_selectedCabangBooking != null) {
      layanan = await BookingService.getLayananList(
        kodeCabang: _selectedCabangBooking!['kode_cabang'],
      );
    } else {
      layanan = await BookingService.getLayananList();
    }

    if (!mounted) return;
    setState(() {
      _myBookings = bookings;
      _myVisits = visits['items'] as List<dynamic>? ?? [];
      _layananList = layanan;
      _pendingBooking = pending;
      _cabangList = cabangList;
      _loading = false;
    });
  }

  Future<void> _selectCabangAndLoadLayanan(Map<String, dynamic> cabang) async {
    setState(() {
      _selectedCabangBooking = cabang;
      _loadingLayananCabang = true;
    });
    final list = await BookingService.getLayananList(
      kodeCabang: cabang['kode_cabang'],
    );
    if (!mounted) return;
    setState(() {
      _layananList = list;
      _loadingLayananCabang = false;
      _searchController.clear();
      _searchKeyword = '';
      _selectedCategory = 'Semua';
    });
  }

  Future<Map<String, dynamic>?> _showCabangPickerDialog() async {
    if (_cabangList.isEmpty) {
      _cabangList = await AuthService.getCabangList();
    }
    if (!mounted) return null;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Cabang Klinik',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tentukan cabang klinik untuk reservasi Anda:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _cabangList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final c = _cabangList[idx];
                      return ListTile(
                        onTap: () => Navigator.pop(ctx, c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: AppColors.inputBorder),
                        ),
                        tileColor: const Color(0xFFFAFAFA),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          c['nama_cabang'] ?? c['kode_cabang'] ?? 'Klinik',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          c['alamat'] ?? '-',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  /// CEK & KUNCI TRANSAKSI BOOKING PENDING:
  /// Pengguna tidak dapat membuat reservasi baru selama ada booking pending yang belum di-upload bukti DP
  Future<bool> _checkAndHandlePendingBooking() async {
    final pending = await BookingService.getPendingBooking();
    if (!mounted) return false;
    setState(() => _pendingBooking = pending);

    if (pending != null) {
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
                  'Transaksi Booking Terkunci',
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
                      pending['kode_booking'] ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${pending['nama_dokter'] ?? 'Dokter'} • ${pending['tanggal_booking']} (${pending['jam_booking']} WIB)",
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFB45309)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nominal DP: ${pending['dp_nominal'] != null ? _formatRupiah(pending['dp_nominal']) : 'DP 20%'}",
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Anda tidak dapat membuat booking baru selama transaksi ini belum diselesaikan dengan mengunggah bukti DP, atau dibatalkan.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted, height: 1.35),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'batal_reservasi'),
              child: const Text('Batalkan Booking Lama', style: TextStyle(color: AppColors.error, fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, 'lanjut_upload'),
              child: const Text('Lanjutkan Upload DP ➔', style: TextStyle(color: Colors.white, fontSize: 12.5)),
            ),
          ],
        ),
      );

      if (action == 'lanjut_upload') {
        if (!mounted) return true;
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(pendingBooking: pending),
          ),
        );
        if (res == true && mounted) {
          _loadData();
          _refreshUserData();
        }
        return true; // Ditangani, jangan lanjut buat booking baru
      } else if (action == 'batal_reservasi') {
        final kodeBooking = pending['kode_booking'];
        if (kodeBooking != null) {
          final res = await BookingService.cancelBooking(kodeBooking, 'Dibatalkan oleh pasien via dialog interceptor');
          if (!mounted) return true;
          if (res['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking $kodeBooking berhasil dibatalkan. Anda dapat membuat booking baru sekarang.'),
                backgroundColor: AppColors.primaryDark,
              ),
            );
            await _loadData();
            await _refreshUserData();
            return false; // Berhasil dibatalkan, boleh lanjut ke flow booking baru
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Gagal membatalkan booking'),
                backgroundColor: AppColors.error,
              ),
            );
            return true;
          }
        }
        return true;
      }
      return true;
    }

    return false; // Tidak ada pending booking, silakan lanjut booking
  }

  /// BOOKING GATE INTERCEPTOR:
  /// Memastikan pasien sudah terhubung dengan Nomor Rekam Medis klinik (no_rm != null)
  /// dan tidak ada booking pending yang belum selesai sebelum lanjut ke formulir booking.
  void _openBookingScreen([Map<String, dynamic>? item]) async {
    final noRm = _currentUser?['no_rm'];
    if (noRm == null || noRm.toString().trim().isEmpty) {
      final synced = await PatientSyncSheet.show(
        context,
        currentUser: _currentUser,
        initialStep: PatientSyncStep.choose,
      );

      if (synced == true) {
        await _refreshUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '🎉 Sinkronisasi Berhasil! Rekam Medis aktif, silakan lanjutkan reservasi.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        return; // User membatalkan dialog, tahan navigasi
      }
    }

    // Interceptor: Cegah booking jika ada transaksi booking pending yang belum upload bukti DP
    final isLocked = await _checkAndHandlePendingBooking();
    if (isLocked) return;

    // Pastikan cabang klinik sudah ditentukan
    Map<String, dynamic>? targetCabang = _selectedCabangBooking;
    if (targetCabang == null) {
      targetCabang = await _showCabangPickerDialog();
      if (targetCabang == null) return;
      await _selectCabangAndLoadLayanan(targetCabang);
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          initialLayanan: item,
          selectedCabang: targetCabang,
        ),
      ),
    );

    if (result == true) {
      _loadData();
      _refreshUserData();
    }
  }


  void _openChatbotScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatbotScreen(currentUser: _currentUser),
      ),
    ).then((_) {
      _refreshUserData();
      _loadData();
    });
  }

  void _handleCancelBooking(dynamic bookingData) async {
    final Map<String, dynamic> b = (bookingData is Map<String, dynamic>)
        ? bookingData
        : _myBookings.firstWhere(
            (item) => item['kode_booking'] == bookingData,
            orElse: () => {'kode_booking': bookingData.toString()},
          );

    final kodeBooking = b['kode_booking']?.toString() ?? '';
    final dpNominal = int.tryParse(b['dp_nominal']?.toString() ?? '0') ?? 0;
    final isClaim = b['alasan_bebas_dp'] != null ||
        dpNominal == 0 ||
        b['is_claim_packet'] == true ||
        (b['layanan'] as List?)?.any((l) => l is Map && l['is_claim'] == true) == true;
    final alasanController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Batalkan Reservasi?',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin membatalkan jadwal reservasi $kodeBooking ini?',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              if (dpNominal > 0 && !isClaim)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Peringatan Konsekuensi: Uang Muka (DP ${_formatRupiah(dpNominal)}) yang telah dibayarkan akan berstatus HANGUS sesuai kebijakan non-refundable klinik.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF991B1B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF15803D), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Info Bebas DP / Klaim Paket: Kuota sesi paket Anda tidak berkurang dan tetap aman.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF166534),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Alasan Pembatalan (Opsional):',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: alasanController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Ada urusan mendadak / ganti tanggal...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
                ),
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Kembali', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Batalkan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final alasan = alasanController.text.trim().isNotEmpty
          ? alasanController.text.trim()
          : 'Dibatalkan oleh pelanggan';
      final res = await BookingService.cancelBooking(kodeBooking, alasan);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: res['success'] ? AppColors.primaryDark : AppColors.error,
          content: Text(res['message'] ?? '', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        ),
      );

      _loadData();
    }
  }

  static String _formatRupiah(dynamic val) {
    if (val == null) return 'Rp 0';
    final n = int.tryParse(val.toString()) ?? (double.tryParse(val.toString())?.toInt() ?? 0);
    final s = n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $s';
  }

  static String _formatDateIndo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final clean = dateStr.contains('T') ? dateStr.split('T').first : dateStr;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return "${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}";
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  static String _formatJam(String? jamStr) {
    if (jamStr == null || jamStr.isEmpty) return '-';
    final parts = jamStr.split(':');
    if (parts.length >= 2) {
      return "${parts[0]}:${parts[1]} WIB";
    }
    return "$jamStr WIB";
  }

  Widget _buildStatusBadge(String? status) {
    final st = (status ?? 'menunggu').toString().toLowerCase();
    final isDone = st == 'selesai';
    final isWaiting = st == 'menunggu' || st == 'menunggu_pembayaran' || st == 'pending';
    final isConfirmed = st == 'dikonfirmasi' || st == 'terkonfirmasi';

    Color bg;
    Color fg;
    String label;

    if (isDone) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'SELESAI';
    } else if (isWaiting) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = 'MENUNGGU';
    } else if (isConfirmed) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
      label = 'DIKONFIRMASI';
    } else if (st == 'tidak_hadir') {
      bg = const Color(0xFFFFFBEB); // Light Amber
      fg = const Color(0xFFD97706); // Amber 600 (Web Standard)
      label = 'TIDAK HADIR';
    } else if (st == 'dibatalkan' || st == 'batal') {
      bg = const Color(0xFFFEF2F2); // Light Red
      fg = const Color(0xFFDC2626); // Red 600 (Web Standard)
      label = 'DIBATALKAN';
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
      label = st.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildDpStatusBadge(Map<String, dynamic> booking) {
    final dpNominal = (num.tryParse(booking['dp_nominal']?.toString() ?? '0') ?? 0).toInt();
    final dpStatus = (booking['dp_status'] ?? '').toString().toLowerCase();
    final metode = (booking['metode_pembayaran_dp'] ?? '').toString().toLowerCase();

    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (dpNominal <= 0 || metode == 'paket') {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF166534);
      label = 'Klaim Paket - Bebas DP';
      icon = Icons.loyalty_rounded;
    } else if (dpStatus == 'dipotong_treatment') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      label = 'DP Dipotong Tagihan Kasir';
      icon = Icons.receipt_long_rounded;
    } else if (dpStatus == 'hangus') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFB91C1C);
      label = 'DP Hangus (${_formatRupiah(dpNominal)})';
      icon = Icons.cancel_outlined;
    } else if (dpStatus == 'sudah_bayar' || dpStatus == 'lunas') {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF15803D);
      label = 'Lunas DP (${_formatRupiah(dpNominal)})';
      icon = Icons.check_circle_outline_rounded;
    } else {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFB45309);
      label = 'Menunggu Konfirmasi DP';
      icon = Icons.pending_actions_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bukti Pembayaran DP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 460),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            'Gagal memuat gambar bukti transfer.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetailModal(Map<String, dynamic> booking) {
    final items = (booking['items'] is List) ? (booking['items'] as List) : [];
    final dpNominal = (num.tryParse(booking['dp_nominal']?.toString() ?? '0') ?? 0).toInt();
    final totalBiayaRaw = (num.tryParse(booking['total_biaya']?.toString() ?? '0') ?? 0).toInt();
    final itemsSum = items.fold<num>(0, (sum, it) => sum + (num.tryParse(it['harga']?.toString() ?? '0') ?? 0)).toInt();
    final totalBiaya = totalBiayaRaw > 0 ? totalBiayaRaw : (itemsSum > 0 ? itemsSum : (dpNominal > 0 ? (dpNominal * 5) : 0));
    final sisaBayar = (totalBiaya > dpNominal) ? (totalBiaya - dpNominal) : 0;
    final st = (booking['status'] ?? '').toString().toLowerCase();
    final canCancel = !['batal', 'dibatalkan', 'selesai', 'tidak_hadir'].contains(st);
    final dpStatus = (booking['dp_status'] ?? 'belum_bayar').toString().toLowerCase();
    final isDpPaid = dpStatus == 'sudah_bayar' || dpStatus == 'lunas' || dpStatus == 'dipotong_treatment';
    final buktiDpUrl = ApiConstants.getImageUrl(booking['bukti_dp']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + (MediaQuery.of(ctx).padding.bottom > 0 ? MediaQuery.of(ctx).padding.bottom : 16) + 8,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Reservasi Booking',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        booking['kode_booking'] ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'KODE RESERVASI RESMI',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SelectableText(
                                        booking['kode_booking'] ?? '-',
                                        style: GoogleFonts.firaCode(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: _buildStatusBadge(booking['status']),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.qr_code_2_rounded, size: 22, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tunjukkan Kode / QR ini ke staf saat tiba di klinik',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'JADWAL KEDATANGAN & DOKTER',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _detailRow(Icons.calendar_today_rounded, 'Tanggal', _formatDateIndo(booking['tanggal_booking'])),
                            const Divider(height: 14),
                            _detailRow(Icons.access_time_rounded, 'Jam Kunjungan', _formatJam(booking['jam_booking'])),
                            const Divider(height: 14),
                            _detailRow(Icons.medical_information_outlined, 'Dokter / Petugas', booking['nama_dokter'] ?? 'Dokter Klinik'),
                            if (booking['nama_ruangan'] != null) ...[
                              const Divider(height: 14),
                              _detailRow(Icons.meeting_room_outlined, 'Ruangan', booking['nama_ruangan']),
                            ],
                            if (booking['nama_cabang'] != null) ...[
                              const Divider(height: 14),
                              _detailRow(Icons.storefront_outlined, 'Cabang Klinik', booking['nama_cabang']),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'LAYANAN PERAWATAN (${items.isNotEmpty ? items.length : 1} ITEM)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            if (items.isNotEmpty)
                              ...items.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final it = entry.value;
                                return Column(
                                  children: [
                                    if (idx > 0) const Divider(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  if (it['jenis_layanan'] == 'paket' || it['is_paket'] == true || booking['jenis_layanan'] == 'paket') ...[
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
                                                      it['nama_layanan'] ?? 'Perawatan',
                                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (it['durasi_menit'] != null)
                                                Text(
                                                  "Durasi: ${it['durasi_menit']} menit",
                                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatRupiah(it['harga']),
                                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              })
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (booking['jenis_layanan'] == 'paket') ...[
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
                                            booking['nama_layanan'] ?? 'Perawatan Klinik',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatRupiah(totalBiaya),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'RINCIAN BIAYA & STATUS DP',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          children: [
                            _biayaRow('Total Biaya Layanan', _formatRupiah(totalBiaya)),
                            const SizedBox(height: 6),
                            _biayaRow(
                              'Uang Muka (DP 20%)',
                              dpNominal > 0 ? _formatRupiah(dpNominal) : 'Rp 0 (Bebas DP)',
                              valueColor: AppColors.primaryDark,
                              isBold: true,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    'Status Uang Muka (DP):',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: isDpPaid ? Colors.green.shade100 : Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isDpPaid ? 'Lunas DP ✓' : (dpNominal > 0 ? 'Menunggu Konfirmasi Kasir' : 'Bebas DP'),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDpPaid ? Colors.green.shade800 : Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _biayaRow('Metode Pembayaran DP', (booking['metode_pembayaran_dp'] ?? 'Transfer Bank').toString().toUpperCase()),
                            const Divider(height: 14),
                            _biayaRow(
                              'Sisa Pelunasan di Kasir (80%)',
                              _formatRupiah(sisaBayar),
                              valueColor: const Color(0xFFB45309),
                              isBold: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '* Sisa pembayaran dilunasi langsung di meja kasir klinik setelah perawatan selesai.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      if (buktiDpUrl != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          'BUKTI TRANSFER DP TERLAMPIR',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showImagePreview(context, buktiDpUrl),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    buktiDpUrl,
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 58,
                                      height: 58,
                                      color: AppColors.bgMintLight,
                                      child: const Icon(Icons.image_outlined, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bukti Pembayaran Tersimpan',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Ketuk foto untuk melihat ukuran penuh',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.zoom_in_rounded, color: AppColors.primary, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (booking['catatan_pasien'] != null && booking['catatan_pasien'].toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'CATATAN / KELUHAN PASIEN',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            booking['catatan_pasien'].toString().trim(),
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textDark, height: 1.4),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        'JEJAK STATUS RESERVASI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _auditStep(
                              isDone: true,
                              title: 'Reservasi Dibuat Pasien',
                              time: '${_formatDateIndo(booking['created_at'])} • ${_formatJam(booking['created_at'])}',
                              desc: 'Pendaftaran booking berhasil terkirim ke klinik.',
                            ),
                            const Divider(height: 14),
                            _auditStep(
                              isDone: st != 'menunggu_pembayaran',
                              title: isDpPaid ? 'DP Terverifikasi' : 'Status Konfirmasi Klinik',
                              time: booking['dp_dibayar_at'] != null ? '${_formatDateIndo(booking['dp_dibayar_at'])} • ${_formatJam(booking['dp_dibayar_at'])}' : 'Terkonfirmasi',
                              desc: isDpPaid ? 'Down Payment telah tervalidasi.' : 'Menunggu kedatangan pasien.',
                            ),
                            if (st == 'selesai') ...[
                              const Divider(height: 14),
                              _auditStep(
                                isDone: true,
                                title: 'Selesai Check-in & Treatment',
                                time: '${_formatDateIndo(booking['updated_at'])} • ${_formatJam(booking['updated_at'])}',
                                desc: 'Pasien telah hadir dan menyelesaikan perawatan.',
                              ),
                            ] else if (st == 'tidak_hadir') ...[
                              const Divider(height: 14),
                              _auditStep(
                                isDone: true,
                                isFailed: true,
                                title: 'Tidak Hadir pada Jadwal',
                                time: '${_formatDateIndo(booking['tanggal_booking'])} • ${_formatJam(booking['jam_booking'])}',
                                desc: 'Pasien tidak hadir. Sesuai ketentuan, DP berstatus hangus.',
                              ),
                            ] else if (st == 'dibatalkan' || st == 'batal') ...[
                              const Divider(height: 14),
                              _auditStep(
                                isDone: true,
                                isFailed: true,
                                title: 'Reservasi Dibatalkan',
                                time: '${_formatDateIndo(booking['updated_at'])} • ${_formatJam(booking['updated_at'])}',
                                desc: booking['catatan_pasien'] ?? 'Reservasi telah dibatalkan.',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (canCancel) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: Text('Batalkan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleCancelBooking(booking);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _biayaRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isBold ? AppColors.textDark : AppColors.textMuted,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditStep({
    required bool isDone,
    bool isFailed = false,
    required String title,
    required String time,
    required String desc,
  }) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    if (isFailed) {
      iconBg = const Color(0xFFFEF2F2);
      iconColor = AppColors.error;
      icon = Icons.cancel_rounded;
    } else if (isDone) {
      iconBg = const Color(0xFFF0FDF4);
      iconColor = const Color(0xFF16A34A);
      icon = Icons.check_circle_rounded;
    } else {
      iconBg = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF94A3B8);
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isFailed ? AppColors.error : AppColors.textDark,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 1.5),
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GETTERS UNTUK FILTER KATALOG LAYANAN & RIWAYAT BOOKING
  // ─────────────────────────────────────────────────────────────
  List<String> get _categories {
    final set = <String>{'Semua'};
    for (final it in _layananList) {
      final c = it['nama_kategori'] ?? it['kategori'];
      if (c != null && c.toString().trim().isNotEmpty) {
        set.add(c.toString().trim());
      }
    }
    return set.toList();
  }

  List<dynamic> get _filteredLayananList {
    return _layananList.where((item) {
      final name = (item['nama_layanan'] ?? item['nama'] ?? '').toString().toLowerCase();
      final cat = (item['nama_kategori'] ?? item['kategori'] ?? '').toString().toLowerCase();
      final matchKeyword = _searchKeyword.isEmpty ||
          name.contains(_searchKeyword.toLowerCase()) ||
          cat.contains(_searchKeyword.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' ||
          cat == _selectedCategory.toLowerCase() ||
          name.contains(_selectedCategory.toLowerCase());
      return matchKeyword && matchCategory;
    }).toList();
  }

  List<dynamic> get _filteredMyBookings {
    List<dynamic> list = [];
    if (_bookingStatusFilter == 'semua') {
      list = List.from(_myBookings);
    } else {
      list = _myBookings.where((b) {
        final st = (b['status'] ?? '').toString().toLowerCase();
        if (_bookingStatusFilter == 'aktif') {
          return ['menunggu', 'menunggu_konfirmasi', 'menunggu_pembayaran', 'terkonfirmasi', 'dikonfirmasi'].contains(st);
        }
        if (_bookingStatusFilter == 'selesai') {
          return st == 'selesai';
        }
        if (_bookingStatusFilter == 'tidak_hadir') {
          return st == 'tidak_hadir';
        }
        if (_bookingStatusFilter == 'dibatalkan' || _bookingStatusFilter == 'batal') {
          return ['batal', 'dibatalkan'].contains(st);
        }
        return st == _bookingStatusFilter;
      }).toList();
    }

    // Urutan: Mendatang/Aktif urut dari tanggal TERDEKAT (ASC); Selesai, Batal, Tidak Hadir dari yang TERBARU (DESC).
    list.sort((a, b) {
      final tglA = a['tanggal_booking']?.toString() ?? '';
      final jamA = a['jam_booking']?.toString() ?? '';
      final tglB = b['tanggal_booking']?.toString() ?? '';
      final jamB = b['jam_booking']?.toString() ?? '';
      final dtA = '$tglA $jamA';
      final dtB = '$tglB $jamB';
      if (_bookingStatusFilter == 'aktif') {
        return dtA.compareTo(dtB);
      } else {
        return dtB.compareTo(dtA);
      }
    });

    return list;
  }

  List<dynamic> get _filteredMyVisits {
    List<dynamic> list = [];
    if (_kunjunganStatusFilter == 'semua') {
      list = List.from(_myVisits);
    } else {
      list = _myVisits.where((v) {
        final st = (v['status'] ?? '').toString().toLowerCase();
        return st == _kunjunganStatusFilter;
      }).toList();
    }

    list.sort((a, b) {
      final tglA = a['tanggal_kunjungan']?.toString() ?? '';
      final jamA = a['jam_datang']?.toString() ?? '';
      final tglB = b['tanggal_kunjungan']?.toString() ?? '';
      final jamB = b['jam_datang']?.toString() ?? '';
      final dtA = '$tglA $jamA';
      final dtB = '$tglB $jamB';
      return dtB.compareTo(dtA);
    });

    return list;
  }

  // ─────────────────────────────────────────────────────────────
  // 1. TAB HOME (DASHBOARD MODERN, REKAM MEDIS & PROMO)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    final userMap = _currentUser ?? widget.user;
    final nama = userMap?['fullname'] ?? userMap?['nama'] ?? 'Pelanggan Setia';
    final rawNoRm = userMap?['no_rm'];
    final isPatient = rawNoRm != null && rawNoRm.toString().trim().isNotEmpty;
    final noRm = isPatient ? rawNoRm.toString() : null;
    final namaCabang = userMap?['nama_cabang'] ?? 'Klinik Utama';

    // Cari maksimal 2 jadwal booking aktif / mendatang terdekat yang SUDAH selesai proses DP (atau bebas DP)
    final upcomingBookings = _myBookings.where((b) {
      final st = (b['status'] ?? '').toString().toLowerCase();
      final dpNominal = (num.tryParse(b['dp_nominal']?.toString() ?? '0') ?? 0);
      final buktiDp = b['bukti_dp'];
      final isPendingUploadDp = (st == 'menunggu' && dpNominal > 0 && (buktiDp == null || buktiDp.toString().trim().isEmpty));

      // Jika belum upload bukti DP, jangan tampilkan di Jadwal Reservasi Mendatang (hanya muncul setelah selesai upload bukti DP)
      if (isPendingUploadDp) return false;

      return ['menunggu', 'terkonfirmasi', 'dikonfirmasi', 'menunggu_pembayaran'].contains(st);
    }).take(2).toList();

    // Ambil 3-4 layanan teratas untuk preview populer
    final popularServices = _layananList.take(4).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
        await _refreshUserData();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. KARTU REKAM MEDIS KLINIK (RAPI, ELEGAN, DAN PROPORIONAL)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isPatient
                      ? const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPatient ? const Color(0xFF064E3B) : const Color(0xFFB45309)).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Aksen dekoratif latar belakang
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: Icon(
                        Icons.spa_rounded,
                        size: 70,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),

                    // Konten Utama Kartu
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Atas: Label & Badge Verifikasi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.medical_information_outlined, color: Colors.white, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'REKAM MEDIS KLINIK',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        namaCabang,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPatient ? Icons.verified_rounded : Icons.info_outline_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPatient ? 'TERVERIFIKASI' : 'BELUM TERHUBUNG',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Nama Pasien
                          Text(
                            nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // No. RM Badge atau Info
                          if (isPatient)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'NO. RM: ',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    noRm ?? '-',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              'Hubungkan nomor rekam medis untuk reservasi & cek paket.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),

                          // Garis Pemisah Halus & Aksi Bawah
                          const SizedBox(height: 14),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          const SizedBox(height: 10),

                          if (isPatient)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined, color: Colors.white.withValues(alpha: 0.8), size: 13),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Pasien Aktif Terdaftar',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ProfileScreen(initialUser: _currentUser)),
                                    );
                                    _refreshUserData();
                                    _loadData();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Lihat Profil & Paket',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            InkWell(
                              onTap: () async {
                                final res = await PatientSyncSheet.show(context, currentUser: _currentUser);
                                if (res == true) {
                                  _refreshUserData();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '🎉 Rekam Medis berhasil disinkronkan! Akun Anda kini aktif.',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF059669),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.link_rounded, color: Color(0xFFB45309), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Klaim / Hubungkan No. RM',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF92400E),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB45309), size: 12),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BANNER PERINGATAN TRANSAKSI PENDING (KUNCI UPLOAD BUKTI DP)
            if (_pendingBooking != null) ...[
              InkWell(
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(pendingBooking: _pendingBooking),
                    ),
                  );
                  if (res == true) {
                    _loadData();
                    _refreshUserData();
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Booking Menunggu Bukti DP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF92400E),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    'PENDING',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_pendingBooking?['kode_booking'] ?? ''} • Kuota dokter terkunci. Ketuk untuk menyelesaikan upload bukti transfer DP.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFFB45309),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF92400E)),
                    ],
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 6),

            // B. BANNER FITUR AI CHATBOT "BEAUTY CARE ASSISTANT"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, color: Color(0xFF059669), size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Beauty Care Assistant',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'AI 24/7',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tanyakan rekomendasi keluhan kulit, cek jadwal booking & sisa paket.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _openChatbotScreen,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mulai Konsultasi Chat',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // C. RINGKASAN JANJI TEMU / BOOKING AKTIF TERDEKAT (MAKSIMAL 2 JADWAL)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal Reservasi Mendatang',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                if (_myBookings.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2; // Pindah ke Tab Riwayat
                      });
                    },
                    child: Text(
                      'Semua (${_myBookings.length}) ↗',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (upcomingBookings.isNotEmpty)
              Column(
                children: [
                  for (int i = 0; i < upcomingBookings.length; i++) ...[
                    _buildUpcomingBookingItem(upcomingBookings[i] as Map<String, dynamic>),
                    if (i < upcomingBookings.length - 1) const SizedBox(height: 10),
                  ],
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgMintLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum Ada Janji Temu Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Jadwalkan perawatan wajah Anda hari ini.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: Text(
                        'Pesan',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // D. LAYANAN UNGGULAN / POPULER (Preview Singkat)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perawatan Populer',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: Text(
                    'Lihat Semua (${_layananList.length}) ↗',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (popularServices.isEmpty && !_loading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Katalog perawatan sedang disiapkan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              SizedBox(
                height: 188,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularServices.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = popularServices[index];
                    final imageUrl = ApiConstants.getImageUrl(item['gambar'] ?? item['foto']);

                    return Container(
                      width: 154,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.inputBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 74,
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.bgMintLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Center(
                                      child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item['nama_layanan'] ?? item['nama'] ?? 'Perawatan',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatRupiah(item['harga']),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              InkWell(
                                onTap: () => _openBookingScreen(item),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Pesan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // E. KEUNGGULAN KLINIK (Quick Info Grid)
            Text(
              'Mengapa Memilih Kami?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    Icons.medical_services_outlined,
                    'Dokter Berlisensi',
                    'Ditangani dokter & terapis estetika spesialis bersertifikat.',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    Icons.biotech_outlined,
                    'Alat Medis Modern',
                    'Teknologi kecantikan mutakhir yang higienis & terstandarisasi.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    Icons.verified_outlined,
                    'Produk Resmi BPOM',
                    'Seluruh krim & serum teruji klinis dan teregistrasi resmi.',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    Icons.chat_bubble_outline_rounded,
                    'Konsultasi Personal',
                    'Rencana perawatan kulit sesuai profil dan kebutuhan Anda.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingItem(Map<String, dynamic> activeBooking) {
    final items = (activeBooking['items'] is List) ? (activeBooking['items'] as List) : [];
    final serviceNames = items.isNotEmpty
        ? items.map((it) => it['nama_layanan']).join(', ')
        : (activeBooking['nama_layanan'] ?? 'Perawatan Klinik');

    return InkWell(
      onTap: () => _showBookingDetailModal(activeBooking),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgMintLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activeBooking['kode_booking'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(activeBooking['status']),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              serviceNames,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDateIndo(activeBooking['tanggal_booking']),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  _formatJam(activeBooking['jam_booking']),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.medical_information_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${activeBooking['nama_dokter'] ?? 'Dokter Klinik'}${activeBooking['nama_ruangan'] != null ? ' • ${activeBooking['nama_ruangan']}' : ''}",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDpStatusBadge(activeBooking),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => _showBookingDetailModal(activeBooking),
                  child: Text(
                    'Lihat Detail ↗',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgMintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2A. VIEW PEMILIHAN CABANG KLINIK SEBELUM BOOKING LAYANAN
  // ─────────────────────────────────────────────────────────────
  Widget _buildPilihCabangBookingView() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Pilih Cabang
            Text(
              'Pilih Cabang Klinik',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Silakan pilih cabang klinik terdekat untuk melihat katalog layanan dan jadwal dokter spesialis yang tersedia.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 18),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_cabangList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.store_mall_directory_outlined, size: 44, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        'Tidak ada cabang klinik aktif.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cabangList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cabang = _cabangList[index];
                  final namaCabang = cabang['nama_cabang'] ?? cabang['kode_cabang'] ?? 'Klinik Cabang';
                  final alamat = cabang['alamat'] ?? 'Kantor Cabang Resmi Klinik';
                  final telp = cabang['telp'] ?? cabang['no_telp'];

                  return InkWell(
                    onTap: () => _selectCabangAndLoadLayanan(cabang),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.inputBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaCabang,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        alamat,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (telp != null && telp.toString().isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        telp.toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.bgMintLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2B. TAB BOOKING (KATALOG LENGKAP PERAWATAN KECANTIKAN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBookingTab() {
    // Jika belum memilih cabang, tampilkan layar pemilihan cabang terlebih dahulu
    if (_selectedCabangBooking == null) {
      return _buildPilihCabangBookingView();
    }

    final categories = _categories;
    final filteredLayanan = _filteredLayananList;

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedCabangBooking != null) {
          await _selectCabangAndLoadLayanan(_selectedCabangBooking!);
        } else {
          await _loadData();
        }
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tab Booking
            Text(
              'Pilihan Perawatan Kecantikan',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih treatment dan dokter ahli untuk merawat kecantikan kulit Anda.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            // Bar Cabang Aktif + Tombol Ganti Cabang
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cabang Terpilih:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedCabangBooking!['nama_cabang'] ?? _selectedCabangBooking!['kode_cabang'] ?? 'Klinik Cabang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDarkest,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCabangBooking = null;
                        _searchController.clear();
                        _searchKeyword = '';
                        _selectedCategory = 'Semua';
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Ganti Cabang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_loadingLayananCabang)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else ...[
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchKeyword = val.trim());
                  },
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Cari nama perawatan atau treatment...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: _searchKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchKeyword = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Kategori Chips
              if (categories.length > 1) ...[
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat;

                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.inputBorder,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Header Jumlah Perawatan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilihan Perawatan Kecantikan',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  Text(
                    '${filteredLayanan.length} Treatment',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Daftar Kartu Layanan
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (filteredLayanan.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        'Tidak Ada Perawatan yang Cocok',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Silakan coba kata kunci lain atau pilih kategori Semua.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLayanan.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredLayanan[index];
                    final imageUrl = ApiConstants.getImageUrl(item['gambar'] ?? item['foto']);
                    final durasi = item['durasi_menit'] ?? 30;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.inputBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.bgMintLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.5)),
                            ),
                            child: (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(
                                    imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_layanan'] ?? item['nama'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      _formatRupiah(item['harga']),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• $durasi mnt',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              elevation: 0,
                            ),
                            onPressed: () => _openBookingScreen(item),
                            child: Text(
                              'Booking',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80), // Ruang untuk FloatingActionButton
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. TAB RIWAYAT (AKTIVITAS RESERVASI & STATUS KUNJUNGAN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildRiwayatTab() {
    final filteredBookings = _filteredMyBookings;
    final filteredVisits = _filteredMyVisits;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tab Riwayat
            Text(
              'Riwayat & Kehadiran',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau seluruh jadwal reservasi booking serta riwayat kunjungan perawatan Anda di klinik.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Segmented Switcher: [ Reservasi (N) | Kunjungan (N) ]
            _buildSegmentSwitcher(),
            const SizedBox(height: 14),

            // Horizontal Filter Chips with Edge-Fade Effect
            _buildFilterChipsBar(),
            const SizedBox(height: 16),

            // Konten Segmen Aktif
            if (_loading) ...[
              _buildSkeletonCard(),
              _buildSkeletonCard(),
              _buildSkeletonCard(),
            ] else if (_riwayatSegmentIndex == 0) ...[
              // ─── SEGMEN 0: RESERVASI BOOKING ───
              if (filteredBookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgMintLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_busy_rounded, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Tidak Ada Aktivitas Reservasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Belum ada data jadwal reservasi pada filter kategori ini.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          elevation: 0,
                        ),
                        onPressed: () => setState(() => _currentIndex = 1),
                        icon: const Icon(Icons.spa_rounded, color: Colors.white, size: 16),
                        label: Text(
                          'Buat Reservasi Baru',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_bookingStatusFilter == 'semua') ...[
                // Pengelompokan: Mendatang / Aktif vs Riwayat Selesai
                () {
                  final activeList = filteredBookings.where((b) {
                    final st = (b['status'] ?? '').toString().toLowerCase();
                    return ['menunggu', 'menunggu_konfirmasi', 'menunggu_pembayaran', 'terkonfirmasi', 'dikonfirmasi'].contains(st);
                  }).toList();
                  final pastList = filteredBookings.where((b) {
                    final st = (b['status'] ?? '').toString().toLowerCase();
                    return !['menunggu', 'menunggu_konfirmasi', 'menunggu_pembayaran', 'terkonfirmasi', 'dikonfirmasi'].contains(st);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeList.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              'Mendatang & Aktif (${activeList.length})',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...activeList.map((b) => _buildBookingCard(b)),
                        const SizedBox(height: 16),
                      ],
                      if (pastList.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              'Riwayat Selesai & Lainnya (${pastList.length})',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...pastList.map((b) => _buildBookingCard(b)),
                      ],
                    ],
                  );
                }(),
              ] else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) => _buildBookingCard(filteredBookings[index]),
                ),
            ] else ...[
              // ─── SEGMEN 1: RIWAYAT KUNJUNGAN FISIK ───
              if (filteredVisits.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgMintLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services_outlined, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Belum Ada Riwayat Kunjungan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Riwayat kunjungan perawatan klinik (baik dari reservasi online maupun datang langsung) akan tercatat otomatis di sini setelah Anda berkunjung.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredVisits.length,
                  itemBuilder: (context, index) => _buildVisitCard(filteredVisits[index]),
                ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEGMENTED SWITCHER: RESERVASI VS KUNJUNGAN
  // ─────────────────────────────────────────────────────────────
  Widget _buildSegmentSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _riwayatSegmentIndex = 0),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _riwayatSegmentIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _riwayatSegmentIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: _riwayatSegmentIndex == 0 ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reservasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: _riwayatSegmentIndex == 0 ? FontWeight.w800 : FontWeight.w600,
                        color: _riwayatSegmentIndex == 0 ? AppColors.primaryDark : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _riwayatSegmentIndex == 0 ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_myBookings.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _riwayatSegmentIndex == 0 ? AppColors.primaryDark : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _riwayatSegmentIndex = 1),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _riwayatSegmentIndex == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _riwayatSegmentIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: _riwayatSegmentIndex == 1 ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kunjungan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: _riwayatSegmentIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                        color: _riwayatSegmentIndex == 1 ? AppColors.primaryDark : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _riwayatSegmentIndex == 1 ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_myVisits.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _riwayatSegmentIndex == 1 ? AppColors.primaryDark : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FILTER CHIPS HORIZONTAL DENGAN EDGE-FADE (SHADERMASK)
  // ─────────────────────────────────────────────────────────────
  Widget _buildFilterChipsBar() {
    final List<Map<String, String>> filters = _riwayatSegmentIndex == 0
        ? [
            {'label': 'Semua', 'key': 'semua'},
            {'label': 'Mendatang / Aktif', 'key': 'aktif'},
            {'label': 'Selesai', 'key': 'selesai'},
            {'label': 'Tidak Hadir', 'key': 'tidak_hadir'},
            {'label': 'Dibatalkan', 'key': 'dibatalkan'},
          ]
        : [
            {'label': 'Semua', 'key': 'semua'},
            {'label': 'Selesai', 'key': 'selesai'},
            {'label': 'Sedang Dilayani', 'key': 'berlangsung'},
          ];

    final currentKey = _riwayatSegmentIndex == 0 ? _bookingStatusFilter : _kunjunganStatusFilter;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.05, 0.94, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          children: filters.map((f) {
            final isSelected = currentKey == f['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_riwayatSegmentIndex == 0) {
                      _bookingStatusFilter = f['key']!;
                    } else {
                      _kunjunganStatusFilter = f['key']!;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    f['label']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SKELETON CARD PLACEHOLDER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 90,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 70,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 180,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 130,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 110,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 60,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // KARTU RESERVASI BOOKING (WITH EXPANDABLE SERVICES & AUDIT TRAIL)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBookingCard(Map<String, dynamic> b) {
    final kode = b['kode_booking'] ?? '';
    final items = (b['items'] is List) ? (b['items'] as List) : [];
    final hasMultipleItems = items.length > 1;
    final isExpanded = _expandedBookingCodes.contains(kode);
    final st = (b['status'] ?? '').toString().toLowerCase();
    final canCancel = !['batal', 'dibatalkan', 'selesai', 'tidak_hadir'].contains(st);
    final dpNominal = int.tryParse(b['dp_nominal']?.toString() ?? '0') ?? 0;
    final isClaim = b['alasan_bebas_dp'] != null || dpNominal == 0;

    String mainServiceName = 'Perawatan';
    if (items.isNotEmpty && items[0]['nama_layanan'] != null) {
      mainServiceName = items[0]['nama_layanan'];
    } else if (b['nama_layanan'] != null) {
      mainServiceName = b['nama_layanan'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar: Kode Booking & Branch + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              kode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.firaCode(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (b['nama_cabang'] != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.storefront_outlined, size: 10, color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        b['nama_cabang'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(b['status']),
                  ],
                ),
                const SizedBox(height: 8),

                // Primary Service
                Text(
                  mainServiceName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),

                // Multi-service expansion trigger
                if (hasMultipleItems) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedBookingCodes.remove(kode);
                        } else {
                          _expandedBookingCodes.add(kode);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpanded
                                ? 'Tutup rincian layanan'
                                : '+${items.length - 1} layanan lainnya (${items.skip(1).map((e) => e['nama_layanan']).take(2).join(', ')}${items.length > 3 ? '...' : ''})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items.map((it) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "• ${it['nama_layanan'] ?? '-'}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatRupiah(it['harga']),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
                const SizedBox(height: 8),

                // Tanggal & Jam
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateIndo(b['tanggal_booking']),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatJam(b['jam_booking']),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Dokter & Ruangan
                Row(
                  children: [
                    const Icon(Icons.medical_information_outlined, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${b['nama_dokter'] ?? 'Dokter Klinik'}${b['nama_ruangan'] != null ? ' • ${b['nama_ruangan']}' : ''}",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Footer: DP Status & Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildDpStatusBadge(b),
                      if (st == 'dibatalkan' || st == 'batal' || st == 'tidak_hadir')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isClaim ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isClaim ? 'Sesi Kuota Aman' : (dpNominal > 0 ? 'DP Hangus' : 'Non-DP'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isClaim ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (canCancel) ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: () => _handleCancelBooking(b),
                        child: Text(
                          'Batalkan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => _showBookingDetailModal(b),
                      child: Text(
                        'Detail ↗',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // KARTU HISTORI KUNJUNGAN FISIK (WALK-IN & DARI RESERVASI)
  // ─────────────────────────────────────────────────────────────
  Widget _buildVisitCard(Map<String, dynamic> v) {
    final kodeKunjungan = v['kode_kunjungan'] ?? v['nomor_antrian'] ?? '-';
    final kodeBooking = v['kode_booking'];
    final isFromBooking = kodeBooking != null && kodeBooking.toString().trim().isNotEmpty;
    final layananList = (v['layanan'] is List) ? (v['layanan'] as List) : [];
    final namaPaket = v['nama_paket'];
    final isExpanded = _expandedVisitCodes.contains(kodeKunjungan);
    final status = (v['status'] ?? 'selesai').toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Visit Code + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            kodeKunjungan,
                            style: GoogleFonts.firaCode(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isFromBooking ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isFromBooking ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFromBooking ? Icons.calendar_month_rounded : Icons.directions_walk_rounded,
                                    size: 10,
                                    color: isFromBooking ? const Color(0xFF2563EB) : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      isFromBooking ? 'Dari Booking' : 'Datang Langsung',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isFromBooking ? const Color(0xFF2563EB) : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: status == 'selesai' ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: status == 'selesai' ? const Color(0xFFBBF7D0) : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Text(
                        status == 'selesai' ? 'SELESAI' : 'SEDANG DILAYANI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: status == 'selesai' ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Services performed
                if (layananList.isNotEmpty) ...[
                  Text(
                    layananList[0]['nama_layanan'] ?? 'Perawatan Klinik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (layananList.length > 1) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedVisitCodes.remove(kodeKunjungan);
                          } else {
                            _expandedVisitCodes.add(kodeKunjungan);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpanded
                                  ? 'Tutup rincian tindakan'
                                  : '+${layananList.length - 1} tindakan lainnya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: layananList.map((it) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "• ${it['nama_layanan'] ?? '-'}${it['durasi_menit'] != null ? ' (${it['durasi_menit']} mnt)' : ''}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textDark,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ] else ...[
                  Text(
                    v['nama_layanan_paket'] ?? 'Kunjungan Perawatan Klinik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],

                // Package Usage Tag (if from package)
                if (namaPaket != null && namaPaket.toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.loyalty_rounded, size: 12, color: Color(0xFF9333EA)),
                        const SizedBox(width: 4),
                        Text(
                          "Paket: $namaPaket (Sesi ${v['sesi_ke'] ?? 1} dari ${v['total_sesi'] ?? 1})",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7E22CE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateIndo(v['tanggal_kunjungan']),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatJam(v['jam_datang'] ?? v['jam_kunjungan']),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Doctor / Room & Branch
                Row(
                  children: [
                    const Icon(Icons.medical_information_outlined, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${v['nama_dokter'] ?? v['nama_petugas'] ?? 'Dokter Klinik'}${v['nama_ruangan'] != null ? ' • ${v['nama_ruangan']}' : ''}${v['nama_cabang'] != null ? ' • 📍 ${v['nama_cabang']}' : ''}",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Tercatat di Sistem Klinik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _showKunjunganDetailModal(v),
                  child: Text(
                    'Detail ↗',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODAL DETAIL KUNJUNGAN FISIK (NON-MEDIS)
  // ─────────────────────────────────────────────────────────────
  void _showKunjunganDetailModal(Map<String, dynamic> visit) {
    final kodeKunjungan = visit['kode_kunjungan'] ?? visit['nomor_antrian'] ?? '-';
    final kodeBooking = visit['kode_booking'];
    final isFromBooking = kodeBooking != null && kodeBooking.toString().trim().isNotEmpty;
    final layananList = (visit['layanan'] is List) ? (visit['layanan'] as List) : [];
    final namaPaket = visit['nama_paket'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + (MediaQuery.of(ctx).padding.bottom > 0 ? MediaQuery.of(ctx).padding.bottom : 16) + 8,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Riwayat Kunjungan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        kodeKunjungan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Verification Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NOMOR KUNJUNGAN / ANTRIAN',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SelectableText(
                                        kodeKunjungan,
                                        style: GoogleFonts.firaCode(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isFromBooking ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isFromBooking ? const Color(0xFFBFDBFE) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isFromBooking ? Icons.calendar_month_rounded : Icons.directions_walk_rounded,
                                          size: 11,
                                          color: isFromBooking ? const Color(0xFF2563EB) : AppColors.textDark,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            isFromBooking ? 'Dari Booking' : 'Datang Langsung',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: isFromBooking ? const Color(0xFF2563EB) : AppColors.textDark,
                                            ),
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
                      const SizedBox(height: 14),

                      Text(
                        'INFORMASI KEDATANGAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _detailRow(Icons.calendar_today_rounded, 'Tanggal Kunjungan', _formatDateIndo(visit['tanggal_kunjungan'])),
                            const Divider(height: 14),
                            _detailRow(Icons.access_time_rounded, 'Waktu Kedatangan', _formatJam(visit['jam_datang'] ?? visit['jam_kunjungan'])),
                            if (visit['nama_cabang'] != null) ...[
                              const Divider(height: 14),
                              _detailRow(Icons.storefront_outlined, 'Cabang Klinik', visit['nama_cabang']),
                            ],
                            if (visit['nama_ruangan'] != null) ...[
                              const Divider(height: 14),
                              _detailRow(Icons.meeting_room_outlined, 'Ruangan', visit['nama_ruangan']),
                            ],
                            const Divider(height: 14),
                            _detailRow(Icons.medical_information_outlined, 'Dokter / Petugas', visit['nama_dokter'] ?? visit['nama_petugas'] ?? 'Dokter Klinik'),
                            if (isFromBooking) ...[
                              const Divider(height: 14),
                              _detailRow(Icons.bookmark_border_rounded, 'Kode Booking Terkait', kodeBooking.toString()),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Layanan Perawatan yang Diberikan
                      Text(
                        'TINDAKAN PERAWATAN (${layananList.isNotEmpty ? layananList.length : 1} ITEM)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            if (layananList.isNotEmpty)
                              ...layananList.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final it = entry.value;
                                return Column(
                                  children: [
                                    if (idx > 0) const Divider(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                it['nama_layanan'] ?? 'Perawatan Klinik',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              if (it['durasi_menit'] != null)
                                                Text(
                                                  "Durasi: ${it['durasi_menit']} menit",
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (it['tarif'] != null)
                                          Text(
                                            _formatRupiah(it['tarif']),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              })
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    visit['nama_layanan_paket'] ?? 'Perawatan Sesuai Jadwal',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF16A34A)),
                                ],
                              ),
                          ],
                        ),
                      ),

                      if (namaPaket != null && namaPaket.toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'KLAIM PAKET PERAWATAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9D5FF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaPaket.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Penggunaan Sesi: Sesi ${visit['sesi_ke'] ?? 1} dari ${visit['total_sesi'] ?? 1}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF7E22CE),
                                    ),
                                  ),
                                  Text(
                                    "Sisa: ${visit['sisa_sesi'] ?? 0} Sesi",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7E22CE),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Non-clinical disclaimer notice
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Catatan Kehadiran: Halaman ini memuat histori kehadiran non-medis. Catatan rekam medis dan resep obat dapat dikonsultasikan langsung bersama dokter spesialis klinik.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD METHOD (MAIN SHELL DENGAN APPBAR & BOTTOM NAV BAR)
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClinicBranchesScreen(
                  initialBranches: _cabangList,
                  currentUser: _currentUser,
                  onSelectBranch: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.spa_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Klinik Kecantikan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Profil & Rekam Medis Screen
          IconButton(
            tooltip: 'Profil & Rekam Medis',
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(initialUser: _currentUser)),
              );
              _refreshUserData();
              _loadData();
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      // Floating Action Button aktif di Tab Home (Chatbot AI) & Tab Booking (Reservasi Baru)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openChatbotScreen,
              backgroundColor: AppColors.primaryDark,
              elevation: 4,
              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              label: Text(
                'Tanya Asisten AI',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : ((_currentIndex == 1 && _selectedCabangBooking != null)
              ? FloatingActionButton.extended(
                  onPressed: () => _openBookingScreen(),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'Reservasi Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              : null),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildBookingTab(),
          _buildRiwayatTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
