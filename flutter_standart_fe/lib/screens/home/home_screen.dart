import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../booking/booking_screen.dart';
import '../profile/patient_sync_sheet.dart';
import '../profile/profile_screen.dart';

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
  String _bookingStatusFilter = 'semua'; // 'semua', 'aktif', 'selesai', 'batal'

  Map<String, dynamic>? _currentUser;
  List<dynamic> _myBookings = [];
  List<dynamic> _layananList = [];
  bool _loading = true;

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
    if (remote != null && mounted) {
      setState(() => _currentUser = remote);
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final bookings = await BookingService.getBookingHistory();
    final layanan = await BookingService.getLayananList();

    if (!mounted) return;
    setState(() {
      _myBookings = bookings;
      _layananList = layanan;
      _loading = false;
    });
  }

  /// BOOKING GATE INTERCEPTOR:
  /// Memastikan pasien sudah terhubung dengan Nomor Rekam Medis klinik (no_rm != null)
  /// sebelum dapat melanjutkan ke formulir booking reservasi.
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
      } else {
        return; // User membatalkan dialog, tahan navigasi
      }
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(initialLayanan: item),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _handleCancelBooking(String kodeBooking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Reservasi?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan jadwal reservasi $kodeBooking ini?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Tidak', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Batalkan', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await BookingService.cancelBooking(kodeBooking, 'Dibatalkan oleh pelanggan');
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
    final st = (status ?? 'dikonfirmasi').toString().toLowerCase();
    final isConfirmed = st == 'dikonfirmasi' || st == 'terkonfirmasi';
    final isDone = st == 'selesai';
    final isCancelled = st == 'dibatalkan' || st == 'batal' || st == 'tidak_hadir';

    Color bg;
    Color fg;
    String label;

    if (isDone) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'SELESAI';
    } else if (isConfirmed) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
      label = 'DIKONFIRMASI';
    } else if (isCancelled) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      label = st == 'tidak_hadir' ? 'TIDAK HADIR' : 'DIBATALKAN';
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = st.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildDpStatusBadge(Map<String, dynamic> booking) {
    final dpNominal = int.tryParse(booking['dp_nominal']?.toString() ?? '0') ?? 0;
    final dpStatus = (booking['dp_status'] ?? '').toString().toLowerCase();
    final metode = (booking['metode_pembayaran_dp'] ?? '').toString().toLowerCase();

    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (dpNominal == 0 || metode == 'paket') {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF166534);
      label = 'Klaim Paket - Bebas DP';
      icon = Icons.loyalty_rounded;
    } else if (dpStatus == 'sudah_bayar' || dpStatus == 'lunas' || dpStatus == 'dipotong_treatment') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'Sudah Bayar DP';
      icon = Icons.check_circle_outline_rounded;
    } else if (dpStatus == 'hangus') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      label = 'DP Hangus';
      icon = Icons.cancel_outlined;
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = 'Menunggu Verifikasi DP';
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
              fontSize: 10,
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
    final dpNominal = int.tryParse(booking['dp_nominal']?.toString() ?? '0') ?? 0;
    final totalBiaya = int.tryParse(booking['total_biaya']?.toString() ?? '0') ??
        items.fold<int>(0, (sum, it) => sum + (int.tryParse(it['harga']?.toString() ?? '0') ?? 0));
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status Booking:',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                            _buildStatusBadge(booking['status']),
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
                                              Text(
                                                it['nama_layanan'] ?? 'Perawatan',
                                                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                              ),
                                              if (it['durasi_menit'] != null)
                                                Text(
                                                  "Durasi: ${it['durasi_menit']} menit",
                                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                                                ),
                                            ],
                                          ),
                                        ),
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
                                  Text(
                                    booking['nama_layanan'] ?? 'Perawatan Klinik',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status Uang Muka (DP):', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDpPaid ? Colors.green.shade100 : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isDpPaid ? 'Lunas DP ✓' : (dpNominal > 0 ? 'Menunggu Konfirmasi' : 'Bebas DP'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDpPaid ? Colors.green.shade800 : Colors.amber.shade900,
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              Row(
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
                          _handleCancelBooking(booking['kode_booking']);
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
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  Widget _biayaRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: isBold ? AppColors.textDark : AppColors.textMuted, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: valueColor ?? AppColors.textDark)),
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
    if (_bookingStatusFilter == 'semua') return _myBookings;
    return _myBookings.where((b) {
      final st = (b['status'] ?? '').toString().toLowerCase();
      if (_bookingStatusFilter == 'aktif') {
        return ['menunggu', 'menunggu_pembayaran', 'terkonfirmasi', 'dikonfirmasi'].contains(st);
      }
      if (_bookingStatusFilter == 'selesai') {
        return st == 'selesai';
      }
      if (_bookingStatusFilter == 'batal') {
        return ['batal', 'dibatalkan', 'tidak_hadir'].contains(st);
      }
      return st == _bookingStatusFilter;
    }).toList();
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

    // Cari maksimal 2 jadwal booking aktif / mendatang terdekat
    final upcomingBookings = _myBookings.where((b) {
      final st = (b['status'] ?? '').toString().toLowerCase();
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
                                if (res == true) _refreshUserData();
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
            const SizedBox(height: 22),

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
                        _currentIndex = 2; // Pindah ke Tab 3 (Riwayat)
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgMintLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activeBooking['kode_booking'] ?? '-',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
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
  // 2. TAB BOOKING (KATALOG LENGKAP PERAWATAN KECANTIKAN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBookingTab() {
    final categories = _categories;
    final filteredLayanan = _filteredLayananList;

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
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. TAB RIWAYAT (AKTIVITAS RESERVASI & STATUS KUNJUNGAN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildRiwayatTab() {
    final filteredBookings = _filteredMyBookings;

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
              'Riwayat Aktivitas & Reservasi',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau seluruh jadwal reservasi, status pembayaran, dan riwayat kunjungan.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Filter Chips Horizontal (Semua, Mendatang/Aktif, Selesai, Batal/Tidak Hadir)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _statusFilterChip('Semua', 'semua'),
                  const SizedBox(width: 8),
                  _statusFilterChip('Mendatang / Aktif', 'aktif'),
                  const SizedBox(width: 8),
                  _statusFilterChip('Selesai', 'selesai'),
                  const SizedBox(width: 8),
                  _statusFilterChip('Batal / Tidak Hadir', 'batal'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (filteredBookings.isEmpty)
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
                    const Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak Ada Aktivitas Reservasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada data jadwal reservasi pada filter kategori ini.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = filteredBookings[index];
                  final items = (b['items'] is List) ? (b['items'] as List) : [];
                  final serviceNames = items.isNotEmpty
                      ? items.map((it) => it['nama_layanan']).join(', ')
                      : (b['nama_layanan'] ?? 'Perawatan');
                  final st = (b['status'] ?? '').toString().toLowerCase();
                  final canCancel = !['batal', 'dibatalkan', 'selesai', 'tidak_hadir'].contains(st);

                  return InkWell(
                    onTap: () => _showBookingDetailModal(b),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                b['kode_booking'] ?? '-',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              _buildStatusBadge(b['status']),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            serviceNames,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(_formatDateIndo(b['tanggal_booking']), style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                              const SizedBox(width: 10),
                              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(_formatJam(b['jam_booking']), style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.medical_information_outlined, size: 13, color: AppColors.primary),
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
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDpStatusBadge(b),
                              Row(
                                children: [
                                  if (canCancel) ...[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        foregroundColor: AppColors.error,
                                      ),
                                      onPressed: () => _handleCancelBooking(b['kode_booking']),
                                      child: Text(
                                        'Batalkan',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _showBookingDetailModal(b),
                                    child: Text(
                                      'Detail ↗',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _statusFilterChip(String label, String key) {
    final isSelected = _bookingStatusFilter == key;
    return InkWell(
      onTap: () => setState(() => _bookingStatusFilter = key),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
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
        title: Row(
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
      // Floating Action Button aktif di Tab Booking
      floatingActionButton: _currentIndex == 1
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
          : null,
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
