import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';

class ClinicBranchesScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialBranches;
  final Map<String, dynamic>? currentUser;
  final VoidCallback? onSelectBranch;

  const ClinicBranchesScreen({
    super.key,
    this.initialBranches,
    this.currentUser,
    this.onSelectBranch,
  });

  @override
  State<ClinicBranchesScreen> createState() => _ClinicBranchesScreenState();
}

class _ClinicBranchesScreenState extends State<ClinicBranchesScreen> {
  List<Map<String, dynamic>> _branches = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBranches != null && widget.initialBranches!.isNotEmpty) {
      _branches = widget.initialBranches!;
    }
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    setState(() => _loading = true);
    final list = await AuthService.getCabangList();
    if (!mounted) return;
    setState(() {
      _branches = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cabang Klinik Kami',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Lokasi, Kontak & Fasilitas Resmi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBranches,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.spa_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Klinik Kecantikan Estetika',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Melayani perawatan kulit terbaik dengan standar medis bersertifikat di seluruh cabang.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Cabang Aktif',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                  if (_branches.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bgMintLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_branches.length} Cabang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_loading && _branches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_branches.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada data cabang yang ditemukan.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _branches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final c = _branches[index];
                    return _buildBranchCard(c);
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatHariOperasional(String? hariOperasional) {
    if (hariOperasional == null || hariOperasional.trim().isEmpty) {
      return 'Senin – Minggu';
    }
    const dayNames = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    final rawList = hariOperasional
        .split(',')
        .map((d) => int.tryParse(d.trim()))
        .where((d) => d != null && d >= 1 && d <= 7)
        .map((d) => d!)
        .toSet()
        .toList()
      ..sort();

    if (rawList.isEmpty || rawList.length == 7) {
      return 'Senin – Minggu';
    }

    bool isContiguous = true;
    for (int i = 0; i < rawList.length - 1; i++) {
      if (rawList[i + 1] != rawList[i] + 1) {
        isContiguous = false;
        break;
      }
    }

    if (isContiguous && rawList.length >= 3) {
      return '${dayNames[rawList.first]} – ${dayNames[rawList.last]}';
    }

    return rawList.map((d) => dayNames[d]!).join(', ');
  }

  static String _formatJamOperasional(Map<String, dynamic> c) {
    if (c['jam_operasional_formatted'] != null &&
        c['jam_operasional_formatted'].toString().trim().isNotEmpty) {
      return c['jam_operasional_formatted'].toString();
    }
    final rawBuka = c['jam_buka']?.toString() ?? '09:00:00';
    final rawTutup = c['jam_tutup']?.toString() ?? '20:00:00';
    final jamBuka = rawBuka.length >= 5 ? rawBuka.substring(0, 5) : rawBuka;
    final jamTutup = rawTutup.length >= 5 ? rawTutup.substring(0, 5) : rawTutup;

    final tz = c['tz']?.toString() ?? 'Asia/Jakarta';
    final tzLower = tz.toLowerCase();
    String tzLabel = 'WIB';
    if (tzLower.contains('makassar') || tzLower.contains('bali') || tzLower.contains('ujung_pandang') || tzLower.contains('wita')) {
      tzLabel = 'WITA';
    } else if (tzLower.contains('jayapura') || tzLower.contains('wit')) {
      tzLabel = 'WIT';
    }

    final hariText = _formatHariOperasional(c['hari_operasional']?.toString());
    return '$jamBuka – $jamTutup $tzLabel ($hariText)';
  }

  static bool _checkIsOpen(Map<String, dynamic> c) {
    if (c['is_open'] != null) {
      return c['is_open'] == true || c['is_open'] == 1 || c['is_open'] == '1';
    }

    final rawBuka = c['jam_buka']?.toString() ?? '09:00:00';
    final rawTutup = c['jam_tutup']?.toString() ?? '20:00:00';
    final jamBuka = rawBuka.length >= 5 ? rawBuka.substring(0, 5) : rawBuka;
    final jamTutup = rawTutup.length >= 5 ? rawTutup.substring(0, 5) : rawTutup;

    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday ... 7 = Sunday
    final currentHhMm = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final daysStr = c['hari_operasional']?.toString() ?? '1,2,3,4,5,6,7';
    final openDays = daysStr
        .split(',')
        .map((d) => int.tryParse(d.trim()))
        .where((d) => d != null)
        .map((d) => d!)
        .toList();

    final isOpenDay = openDays.contains(currentDay);
    final isOpenTime = currentHhMm.compareTo(jamBuka) >= 0 && currentHhMm.compareTo(jamTutup) < 0;

    return isOpenDay && isOpenTime;
  }

  Widget _buildBranchCard(Map<String, dynamic> c) {
    final namaCabang = c['nama_cabang'] ?? 'Cabang Klinik';
    final kodeCabang = c['kode_cabang'] ?? '-';
    final alamat = c['alamat'] ?? 'Alamat klinik tersedia';
    final telp = c['telp'] ?? c['no_telp'] ?? '-';
    final email = c['email'] ?? '-';
    final pjManager = c['pj_manager'] ?? '-';

    final isOpen = _checkIsOpen(c);
    final statusBukaText = (c['status_buka']?.toString()) ?? (isOpen ? 'BUKA HARI INI' : 'TUTUP');
    final jamOperasionalText = _formatJamOperasional(c);

    List<dynamic> fasilitasList = [];
    if (c['fasilitas'] is List) {
      fasilitasList = c['fasilitas'];
    } else if (c['fasilitas'] is String && c['fasilitas'].toString().trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(c['fasilitas']);
        if (decoded is List) fasilitasList = decoded;
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Cabang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF047857), Color(0xFF065F46)],
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
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaCabang,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'Kode: $kodeCabang',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusBukaText,
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
          ),

          // Body Cabang
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alamat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alamat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Informasi Operasional & Kontak
                _branchDetailItem(Icons.schedule_rounded, 'Jam Operasional', jamOperasionalText),
                if (telp != '-') _branchDetailItem(Icons.phone_in_talk_rounded, 'Telepon / WhatsApp', telp),
                if (email != '-') _branchDetailItem(Icons.email_outlined, 'Email Resmi', email),
                if (pjManager != '-') _branchDetailItem(Icons.person_pin_rounded, 'Penanggung Jawab', pjManager),

                // Fasilitas Cabang (Hanya tampil jika ada data fasilitas)
                if (fasilitasList.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Text(
                    'Fasilitas Cabang:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: fasilitasList.map<Widget>((f) {
                      final icon = (f is Map ? f['icon'] : null)?.toString() ?? '✨';
                      final nama = (f is Map ? f['nama'] : f.toString())?.toString() ?? '';
                      return _facilityChip('$icon $nama'.trim());
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Tombol Reservasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(
                      'Reservasi di Cabang Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSelectBranch?.call();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _branchDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF059669)),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}
