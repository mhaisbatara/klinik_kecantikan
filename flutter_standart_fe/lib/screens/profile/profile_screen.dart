import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../auth/auth_screen.dart';
import '../booking/booking_screen.dart';
import 'patient_sync_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUser;

  const ProfileScreen({super.key, this.initialUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _packages = [];
  bool _loading = false;
  bool _loadingPackages = false;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loading = true;
      _loadingPackages = true;
    });

    final updated = await AuthService.fetchProfile();
    final noRm = updated?['no_rm'] ?? _user?['no_rm'];

    List<dynamic> pkgs = [];
    if (noRm != null && noRm.toString().trim().isNotEmpty) {
      pkgs = await BookingService.getMyPackages();
    }

    if (!mounted) return;
    setState(() {
      if (updated != null) _user = updated;
      _packages = pkgs;
      _loading = false;
      _loadingPackages = false;
    });
  }

  void _openSyncSheet(PatientSyncStep step) async {
    final success = await PatientSyncSheet.show(
      context,
      currentUser: _user,
      initialStep: step,
    );
    if (success == true) {
      _refreshProfile();
    }
  }

  static String _maskNik(String? nik) {
    if (nik == null || nik.isEmpty) return '-';
    if (nik.length < 8) return nik;
    return "${nik.substring(0, 4)}********${nik.substring(nik.length - 4)}";
  }

  static String _formatDateIndo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final clean = dateStr.contains('T') ? dateStr.split('T').first : dateStr;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  static String _formatDateDash(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final clean = dateStr.contains('T') ? dateStr.split('T').first : dateStr;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final y = parts[0];
        final m = parts[1].padLeft(2, '0');
        final d = parts[2].padLeft(2, '0');
        return "$d-$m-$y";
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final noRm = _user?['no_rm'];
    final isPatient = noRm != null && noRm.toString().trim().isNotEmpty;
    final pasienProfile = _user?['pasien_profile'] as Map<String, dynamic>?;

    final nama = _user?['fullname'] ?? _user?['nama'] ?? 'Pengguna Klinik';
    final telp = _user?['telp'] ?? '-';
    final email = _user?['username'] ?? '-';
    final cabang = _user?['nama_cabang'] ?? 'Klinik Utama';
    final fotoUrl = ApiConstants.getImageUrl(_user?['foto'] ?? pasienProfile?['foto']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profil Akun & Rekam Medis',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkest,
          ),
        ),
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.bgMintLight,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Perbarui Data',
            onPressed: _loading ? null : _refreshProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Kartu Header Profil Pengguna ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.bgMintLight,
                      backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                      child: fotoUrl == null
                          ? Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : 'U',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            telp,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (email != '-' && email != telp) ...[
                            const SizedBox(height: 1),
                            Text(
                              email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                cabang,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 2. Kartu Status Rekam Medis (Gate Indicator) ──
              if (isPatient)
                _buildVerifiedPatientCard(noRm.toString(), pasienProfile)
              else
                _buildUnverifiedPatientCard(),

              // ── 3. Section Paket Perawatan Saya (Kartu Stempel Multi-Sesi) ──
              if (isPatient) ...[
                const SizedBox(height: 24),
                _buildMyPackagesSection(),
              ],

              const SizedBox(height: 28),

              // ── 4. Tombol Logout ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text('Konfirmasi Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?', style: GoogleFonts.plusJakartaSans()),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── KARTU PASIEN TERVERIFIKASI ───────────────────────────────
  Widget _buildVerifiedPatientCard(String noRm, Map<String, dynamic>? p) {
    final nik = p?['nik'];
    final tglLahir = _formatDateIndo(p?['tanggal_lahir']);
    final tempatLahir = p?['tempat_lahir'] ?? '-';
    final jk = (p?['jenis_kelamin'] == 'L') ? 'Laki-laki' : 'Perempuan';
    final alamat = p?['patokan'] ?? p?['alamat'] ?? '-';
    final alergi = p?['alergi'] ?? 'Tidak ada riwayat alergi';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Rekam Medis Terverifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  noRm,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          // Detail Baris Rekam Medis
          _detailRow(Icons.badge_outlined, 'NIK KTP', _maskNik(nik)),
          const SizedBox(height: 10),
          _detailRow(Icons.calendar_today_outlined, 'TTL', "$tempatLahir, $tglLahir"),
          const SizedBox(height: 10),
          _detailRow(Icons.wc_outlined, 'Jenis Kelamin', jk),
          const SizedBox(height: 10),
          _detailRow(Icons.home_outlined, 'Alamat Domisili', alamat),
          const SizedBox(height: 10),
          _detailRow(Icons.warning_amber_rounded, 'Riwayat Alergi', alergi, isAlergi: true),
        ],
      ),
    );
  }

  // ─── KARTU BELUM TERHUBUNG REKAM MEDIS ────────────────────────
  Widget _buildUnverifiedPatientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akun Belum Terhubung RM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      'Belum memiliki Nomor Rekam Medis klinik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Untuk dapat melakukan reservasi / booking perawatan dokter, silakan hubungkan akun ini dengan rekam medis Anda:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Opsi A: Pasien Baru
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: Text(
                'Daftar Pasien Baru (Terbitkan RM)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              onPressed: () => _openSyncSheet(PatientSyncStep.formRegister),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Opsi B: Pasien Lama
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0284C7),
                side: const BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.sync_lock_rounded, size: 18),
              label: Text(
                'Sinkronisasi Pasien Lama (Klaim No. RM)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              onPressed: () => _openSyncSheet(PatientSyncStep.formClaim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isAlergi = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: isAlergi ? Colors.amber.shade800 : AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isAlergi ? Colors.red.shade700 : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BAGIAN B: SECTION PAKET PERAWATAN SAYA (KARTU STEMPEL)
  // ─────────────────────────────────────────────────────────────
  Widget _buildMyPackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.loyalty_rounded, color: Color(0xFFD97706), size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paket Perawatan Saya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Kartu Member & Kupon Stempel Multi-Sesi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_packages.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgMintLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_packages.length} Paket',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (_loadingPackages)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
              ),
            ),
          )
        else if (_packages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.confirmation_number_outlined, size: 28, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  'Belum Memiliki Paket Perawatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dapatkan paket hemat multi-sesi dengan konsultasi bersama dokter kami.',
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
            itemCount: _packages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final pkg = _packages[index] as Map<String, dynamic>;
              return _buildPackageCard(pkg);
            },
          ),
      ],
    );
  }

  Widget _buildKplRow(
    String label,
    String value, {
    bool isMono = false,
    Color? valueColor,
    bool isBold = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ":  ",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isMono
                  ? GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                      color: valueColor ?? const Color(0xFF0F172A),
                    )
                  : GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                      color: valueColor ?? const Color(0xFF0F172A),
                      height: 1.25,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatTableRow(Map<String, dynamic> rw) {
    final isHangus = rw['status_pemakaian'] == 'hangus_no_show';
    final sesiKe = rw['sesi_ke'] ?? '-';
    final tgl = _formatDateDash(rw['tanggal_pakai']);
    final kode = rw['kode_kunjungan'] ?? rw['kode_booking'] ?? '-';
    final ket = rw['keterangan'] ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              'Ke-$sesiKe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          SizedBox(
            width: 85,
            child: Text(
              tgl,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isHangus ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isHangus ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  isHangus ? '✕ Hangus (No-Show)' : '✓ Hadir Treatment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isHangus ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              kode,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(
              ket,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final count = (boxWidth / (dashWidth + dashSpace)).floor().clamp(1, 100);
        return SizedBox(
          width: boxWidth,
          height: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── KARTU MEMBER / PAKET PERAWATAN MULTI-SESI (IDENTIK DENGAN WEB) ───
  Widget _buildPackageCard(Map<String, dynamic> pkg) {
    final status = (pkg['status'] ?? 'aktif').toString().toLowerCase();
    final isAktif = status == 'aktif';
    final isExpired = status == 'expired';
    final sisaSesi = int.tryParse(pkg['sisa_sesi']?.toString() ?? '0') ?? 0;
    final details = (pkg['details'] is List) ? (pkg['details'] as List) : [];

    final namaPasien = pkg['nama_pasien'] ?? _user?['fullname'] ?? _user?['nama'] ?? 'M. Hais Batara';
    final noRm = pkg['no_rm'] ?? _user?['no_rm'] ?? '-';
    final noHp = pkg['no_hp_pasien'] ?? _user?['telp'] ?? _user?['pasien_profile']?['no_hp'] ?? '-';
    final fotoUrl = ApiConstants.getImageUrl(_user?['foto'] ?? _user?['pasien_profile']?['foto']);

    Color statusColor;
    String statusText;
    if (isAktif) {
      statusColor = const Color(0xFF10B981);
      statusText = 'AKTIF';
    } else if (isExpired) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'KEDALUWARSA';
    } else {
      statusColor = const Color(0xFF94A3B8);
      statusText = 'HABIS';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. KARTU IDENTITAS RESMI (KTP / SIM STYLE) ───
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Kartu (Banner Hijau Gradient)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            size: 20,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KARTU SESI LAYANAN PAKET',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'KLINIK KECANTIKAN ESTETIKA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Black pill status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D0F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body Kartu (Foto & Data Pasien / Paket)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Foto / Avatar Pasien
                    Container(
                      width: 78,
                      height: 102,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (fotoUrl != null && fotoUrl.isNotEmpty)
                          ? Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.person_rounded, size: 42, color: Color(0xFF94A3B8)),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person_rounded, size: 42, color: Color(0xFF94A3B8)),
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Kolom Kanan: Detail Pasien & Paket
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKplRow('Nama Pasien', namaPasien),
                          _buildKplRow('No. RM', noRm, isMono: true),
                          _buildKplRow('No. HP', noHp),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildDashedDivider(),
                          ),
                          _buildKplRow('Nama Paket', pkg['nama_paket'] ?? '-'),
                          _buildKplRow('Kode Paket', pkg['kode_paket_layanan'] ?? '-', isMono: true),
                          _buildKplRow('Tgl Pembelian', _formatDateDash(pkg['tanggal_beli'])),
                          _buildKplRow(
                            'Berlaku s.d.',
                            pkg['tanggal_expired'] != null
                                ? _formatDateDash(pkg['tanggal_expired'])
                                : 'Tidak ada batas',
                            valueColor: const Color(0xFFDC2626),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Kartu: No. KPL & Security Pattern
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. Kartu (KPL)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          pkg['kode_kepemilikan_paket_layanan'] ?? '-',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: const CustomPaint(
                          painter: _CheckerboardPainter(),
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

        // ─── 2. KARTU SESI LAYANAN PAKET (CIRCULAR STAMPS & RIWAYAT) ───
        for (int i = 0; i < details.length; i++) ...[
          _buildServiceDetailWithStamps(pkg, details[i] as Map<String, dynamic>, i + 1),
          const SizedBox(height: 14),
        ],

        // ─── 3. TOMBOL CEPAT BOOKING SESI BERIKUTNYA ───
        if (isAktif && sisaSesi > 0)
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
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(
                'Booking Sesi Berikutnya ↗',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () {
                Map<String, dynamic>? initialLayanan;
                if (details.isNotEmpty) {
                  final firstDet = details.first as Map<String, dynamic>;
                  initialLayanan = {
                    'kode_layanan': firstDet['kode_layanan'],
                    'nama_layanan': firstDet['nama_layanan'],
                    'nama': firstDet['nama_layanan'],
                    'is_paket': true,
                    'kode_kepemilikan_paket_layanan': pkg['kode_kepemilikan_paket_layanan'],
                  };
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(initialLayanan: initialLayanan),
                  ),
                ).then((_) => _refreshProfile());
              },
            ),
          ),
      ],
    );
  }

  // ─── TAMPILAN PER LAYANAN DENGAN STEMPEL LINGKARAN & LOG SESI ───
  Widget _buildServiceDetailWithStamps(
    Map<String, dynamic> pkg,
    Map<String, dynamic> detail,
    int sIdx,
  ) {
    final namaLayanan = detail['nama_layanan'] ?? detail['kode_layanan'] ?? 'Layanan Paket';
    final tipe = detail['tipe'] ?? 'BEAUTY TREATMENT';
    final namaRuangan = detail['nama_ruangan'] ?? 'Ruang Treatment';
    final durasiMenit = detail['durasi_menit'] ?? 30;
    final kodeLayanan = detail['kode_layanan'] ?? '-';

    final sesiTotal = int.tryParse(detail['sesi_total']?.toString() ?? '1') ?? 1;
    final sesiTerpakai = int.tryParse(detail['sesi_terpakai']?.toString() ?? '0') ?? 0;
    final percent = sesiTotal > 0 ? ((sesiTerpakai / sesiTotal) * 100).round() : 0;

    final stamps = (detail['stamps'] is List) ? (detail['stamps'] as List) : [];
    final riwayatList = (detail['riwayat_pemakaian'] is List) ? (detail['riwayat_pemakaian'] as List) : [];

    // Pastikan seluruh stempel sesi dari 1 sampai sesiTotal ter-cover
    List<Map<String, dynamic>> resolvedStamps = [];
    if (stamps.isNotEmpty) {
      resolvedStamps = stamps.cast<Map<String, dynamic>>();
    } else {
      for (int s = 1; s <= sesiTotal; s++) {
        final log = riwayatList.cast<Map<String, dynamic>>().firstWhere(
          (r) => int.tryParse(r['sesi_ke']?.toString() ?? '') == s,
          orElse: () => {},
        );
        if (log.isNotEmpty) {
          resolvedStamps.add({
            'sesi_ke': s,
            'status': log['status_pemakaian'] ?? 'hadir',
            'keterangan': log['keterangan'],
          });
        } else if (s <= sesiTerpakai) {
          resolvedStamps.add({
            'sesi_ke': s,
            'status': 'hadir',
          });
        } else {
          resolvedStamps.add({
            'sesi_ke': s,
            'status': 'tersedia',
          });
        }
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Layanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '$sIdx. $namaLayanan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tipe.toString().toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      namaRuangan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ),
                    Text(
                      '⏱ $durasiMenit Menit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ),
                    Text(
                      kodeLayanan,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDashedDivider(),

          // 2. Area Stempel Sesi (Dot Matrix Pattern & Centered Circular Stamps)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: CustomPaint(
              painter: const _DotMatrixPainter(),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final stamp in resolvedStamps)
                      _buildCircularStampItem(stamp),
                  ],
                ),
              ),
            ),
          ),

          // 3. Progress Bar & Ringkasan Pemakaian
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF475569),
                    ),
                    children: [
                      TextSpan(
                        text: '$sesiTerpakai',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const TextSpan(text: ' dari '),
                      TextSpan(
                        text: '$sesiTotal',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const TextSpan(text: ' sesi terpakai'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent / 100.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$percent%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // 4. Buku Log / Riwayat Pemakaian Sesi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('📋 ', style: TextStyle(fontSize: 12)),
                        Text(
                          'Buku Log / Riwayat Pemakaian Sesi:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    if (riwayatList.isNotEmpty)
                      InkWell(
                        onTap: () => _showPackageUsageHistoryModal(pkg, detail),
                        child: Text(
                          'Detail ↗',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (riwayatList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Belum ada riwayat pemakaian sesi untuk layanan ini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 460),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 55,
                                  child: Text(
                                    'Sesi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    'Tanggal',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    'Status',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Kunjungan / Booking',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    'Keterangan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Table Rows
                          for (final rw in riwayatList)
                            _buildRiwayatTableRow(rw as Map<String, dynamic>),
                        ],
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

  // ─── KOMPONEN STEMPEL SESI LINGKARAN (VISUAL CIRCULAR STAMP) ───
  Widget _buildCircularStampItem(Map<String, dynamic> stamp) {
    final status = (stamp['status'] ?? 'tersedia').toString().toLowerCase();
    final sesiKe = stamp['sesi_ke'] ?? 1;

    final isHadir = status == 'hadir';
    final isHangus = status == 'hangus_no_show';

    if (isHadir) {
      return Transform.rotate(
        angle: -0.08,
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            ),
            border: Border.all(color: const Color(0xFF059669), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33059669),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '✓',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF059669),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'SESI $sesiKe',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'HADIR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF047857),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isHangus) {
      return Transform.rotate(
        angle: -0.08,
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
            ),
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33EF4444),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '✕',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'SESI $sesiKe',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF991B1B),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'HANGUS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB91C1C),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: 74,
        height: 74,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CustomPaint(
          painter: const DashedCirclePainter(
            color: Color(0xFF94A3B8),
            strokeWidth: 1.8,
            dashCount: 16,
            dashGapFraction: 0.45,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$sesiKe',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'TERSEDIA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ─── MODAL BOTTOM SHEET DETAIL RIWAYAT PEMAKAIAN SESI ──────────
  void _showPackageUsageHistoryModal(Map<String, dynamic> pkg, Map<String, dynamic> detail) {
    final riwayatList = (detail['riwayat_pemakaian'] is List) ? (detail['riwayat_pemakaian'] as List) : [];
    final namaLayanan = detail['nama_layanan'] ?? 'Layanan Paket';

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
            top: 14,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Pemakaian Sesi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          namaLayanan,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),

              if (riwayatList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'Belum Ada Sesi yang Digunakan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sesi akan tercatat otomatis saat Anda hadir treatment di klinik.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: riwayatList.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = riwayatList[index] as Map<String, dynamic>;
                      final st = (item['status_pemakaian'] ?? 'hadir').toString().toLowerCase();
                      final isHadir = st == 'hadir';
                      final sesiKe = item['sesi_ke'] ?? (index + 1);
                      final tgl = _formatDateIndo(item['tanggal_pakai']);
                      final refCode = item['kode_kunjungan'] ?? item['kode_booking'] ?? '-';
                      final ket = item['keterangan'] ?? (isHadir ? 'Hadir Treatment' : 'Hangus No-Show');

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isHadir ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isHadir ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 18,
                              color: isHadir ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sesi ke-$sesiKe',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isHadir ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isHadir ? 'HADIR' : 'HANGUS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isHadir ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "$tgl • Ref: $refCode",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (ket.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    ket,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isHadir ? AppColors.primaryDark : AppColors.error,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── CUSTOM PAINTERS UNTUK KARTU SESI LAYANAN PAKET ──────────────

/// Dashed Circle Border untuk Stempel Sesi Tersedia
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double dashGapFraction;

  const DashedCirclePainter({
    this.color = const Color(0xFF94A3B8),
    this.strokeWidth = 2.0,
    this.dashCount = 16,
    this.dashGapFraction = 0.45,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final totalAngle = 2 * math.pi;
    final sweepAngle = (totalAngle / dashCount) * (1 - dashGapFraction);
    final gapAngle = (totalAngle / dashCount) * dashGapFraction;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (sweepAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount ||
        oldDelegate.dashGapFraction != dashGapFraction;
  }
}

/// Checkerboard Pattern untuk Watermark / QR Box Placeholder
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) return;
    final paint = Paint()..color = const Color(0x3394A3B8);
    const cellSize = 5.5;
    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final row = (y / cellSize).floor();
        final col = (x / cellSize).floor();
        if ((row + col) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dot Matrix Pattern untuk Latar Stempel Sesi
class _DotMatrixPainter extends CustomPainter {
  const _DotMatrixPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = const Color(0x18000000)
      ..style = PaintingStyle.fill;

    const step = 15.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

