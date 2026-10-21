import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../auth/auth_screen.dart';
import '../booking/booking_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _myBookings = [];
  List<dynamic> _layananList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _openBookingScreen([Map<String, dynamic>? item]) async {
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
              // Drag Handle Pill
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

              // Title Row
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Status Bar
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

                      // 2. Jadwal & Ruangan
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

                      // 3. Layanan yang Dipesan
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

                      // 4. Rincian Biaya & Status DP
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

                      // 5. Bukti Transfer DP (Jika Ada)
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

                      // 6. Catatan Pasien
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

              // Bottom Actions
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

  void _openRiwayatBookingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 12,
                left: 18,
                right: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Riwayat Reservasi Saya',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(height: 16),
                  if (_myBookings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 42, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text('Belum ada riwayat booking', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _myBookings.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final b = _myBookings[index];
                          final items = (b['items'] is List) ? (b['items'] as List) : [];
                          final serviceNames = items.isNotEmpty
                              ? items.map((it) => it['nama_layanan']).join(', ')
                              : (b['nama_layanan'] ?? 'Perawatan');

                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _showBookingDetailModal(b);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
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
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatRupiah(b['total_biaya'] ?? b['dp_nominal'] ?? 0),
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                      ),
                                      Text(
                                        'Rincian Detail ↗',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    final nama = widget.user?['fullname'] ?? widget.user?['nama'] ?? 'Pelanggan Setia';
    final noRm = widget.user?['no_rm'] ?? '-';
    final namaCabang = widget.user?['nama_cabang'] ?? 'Klinik Utama';

    // Cari booking yang paling dekat / aktif
    final activeBooking = _myBookings.cast<Map<String, dynamic>?>().firstWhere(
      (b) {
        final st = (b?['status'] ?? '').toString().toLowerCase();
        return st == 'menunggu' || st == 'terkonfirmasi' || st == 'dikonfirmasi';
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Klinik Kecantikan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkest,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    'Konfirmasi Keluar',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar dari akun ini?',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Keluar', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBookingScreen(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
        label: Text(
          'Reservasi Baru',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Kartu Pelanggan ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'No. RM: $noRm',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PELANGGAN',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Selamat Datang,',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      nama,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          namaCabang,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 2. Jadwal Reservasi Aktif Terdekat ──
              // ── 2. Jadwal Reservasi Aktif Terdekat ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Reservasi Mendatang',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  if (_myBookings.isNotEmpty)
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _openRiwayatBookingModal,
                      child: Text(
                        'Lihat Semua (${_myBookings.length})',
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

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (activeBooking != null)
                InkWell(
                  onTap: () => _showBookingDetailModal(activeBooking),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row Header: Kode & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.bgMintLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeBooking['kode_booking'] ?? '-',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            _buildStatusBadge(activeBooking['status']),
                          ],
                        ),
                        const Divider(height: 18),

                        // Tanggal & Jam (Responsive & No Overflow!)
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _formatDateIndo(activeBooking['tanggal_booking']),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 15, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatJam(activeBooking['jam_booking']),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Dokter & Ruangan
                        Row(
                          children: [
                            const Icon(Icons.medical_information_outlined, size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${activeBooking['nama_dokter'] ?? 'Dokter Klinik'}${activeBooking['nama_ruangan'] != null ? ' • ${activeBooking['nama_ruangan']}' : ''}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Layanan Ringkas jika ada
                        if (activeBooking['items'] != null && (activeBooking['items'] as List).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.spa_outlined, size: 13, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    (activeBooking['items'] as List).map((i) => "${i['nama_layanan'] ?? 'Perawatan'}").join(' + '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // DP Status & Bukti Terlampir Indicator
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (int.tryParse(activeBooking['dp_nominal']?.toString() ?? '0') ?? 0) > 0
                                  ? "DP: ${_formatRupiah(activeBooking['dp_nominal'])}"
                                  : "Bebas DP",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: (int.tryParse(activeBooking['dp_nominal']?.toString() ?? '0') ?? 0) > 0
                                    ? AppColors.primaryDark
                                    : AppColors.textMuted,
                              ),
                            ),
                            if (activeBooking['bukti_dp'] != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Bukti DP Terunggah',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons: [Batalkan] dan [Lihat Detail]
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!['batal', 'dibatalkan', 'selesai', 'tidak_hadir'].contains((activeBooking['status'] ?? '').toString().toLowerCase())) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                icon: const Icon(Icons.cancel_outlined, size: 15),
                                label: Text(
                                  'Batalkan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => _handleCancelBooking(activeBooking['kode_booking']),
                              ),
                              const SizedBox(width: 8),
                            ],
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.receipt_long_rounded, size: 15),
                              label: Text(
                                'Lihat Detail',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () => _showBookingDetailModal(activeBooking),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_available_rounded, size: 38, color: AppColors.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: 10),
                      Text(
                        'Belum Ada Jadwal Reservasi Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih perawatan impian Anda dan jadwalkan sesi bersama dokter ahli.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () => _openBookingScreen(),
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        label: Text(
                          'Buat Reservasi Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // ── 3. Katalog Perawatan yang Bisa di-Booking ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pilihan Perawatan Kecantikan',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openBookingScreen(),
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_layananList.isEmpty && !_loading)
                Center(
                  child: Text(
                    'Katalog perawatan sedang disiapkan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _layananList.length > 5 ? 5 : _layananList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _layananList[index];
                    final imageUrl = ApiConstants.getImageUrl(item['gambar'] ?? item['foto']);

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
                            width: 52,
                            height: 52,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.bgMintLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.5)),
                            ),
                            child: (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(
                                    imageUrl,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 26),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                        ),
                                      );
                                    },
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
                                Text(
                                  'Rp ${(item['harga'] ?? 0).toString()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
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

              const SizedBox(height: 80), // Padding untuk Floating Action Button
            ],
          ),
        ),
      ),
    );
  }
}
