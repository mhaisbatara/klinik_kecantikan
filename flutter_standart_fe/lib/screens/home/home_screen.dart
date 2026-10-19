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
              Text(
                'Jadwal Reservasi Mendatang',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
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
                Container(
                  padding: const EdgeInsets.all(18),
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
                          Builder(
                            builder: (context) {
                              final st = (activeBooking['status'] ?? 'Dikonfirmasi').toString().toLowerCase();
                              final isConfirmed = st == 'dikonfirmasi' || st == 'terkonfirmasi';
                              final isCancelled = st == 'dibatalkan' || st == 'batal';

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isConfirmed
                                      ? Colors.blue.shade50
                                      : (isCancelled ? Colors.red.shade50 : Colors.amber.shade50),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  st.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isConfirmed
                                        ? Colors.blue.shade700
                                        : (isCancelled ? Colors.red.shade700 : Colors.amber.shade800),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            activeBooking['tanggal_booking'] ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            "${activeBooking['jam_booking']} WIB",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.medical_information_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            activeBooking['nama_dokter'] ?? 'Dokter Klinik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: Text(
                              'Batalkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => _handleCancelBooking(activeBooking['kode_booking']),
                          ),
                        ],
                      ),
                    ],
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
