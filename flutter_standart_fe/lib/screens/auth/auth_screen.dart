import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginUserCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginShowPass = false;
  bool _loginRememberMe = true;
  bool _loginLoading = false;

  // Register Controllers
  final _regNamaCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmPassCtrl = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'P'; // Default P (Perempuan)
  bool _regShowPass = false;
  bool _regLoading = false;
  List<Map<String, dynamic>> _cabangList = [];
  String? _selectedCabang;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCabang();
  }

  Future<void> _fetchCabang() async {
    final list = await AuthService.getCabangList();
    if (!mounted) return;
    setState(() {
      _cabangList = list;
      if (list.isNotEmpty && _selectedCabang == null) {
        _selectedCabang = list.first['kode_cabang'];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNamaCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    super.dispose();
  }

  void _showCustomToast(String message, {bool isSuccess = true, bool isWarn = false}) {
    Color borderColor = AppColors.primary;
    IconData iconData = Icons.check_circle_outline_rounded;
    Color iconColor = AppColors.primary;

    if (!isSuccess) {
      borderColor = AppColors.error;
      iconData = Icons.error_outline_rounded;
      iconColor = AppColors.error;
    } else if (isWarn) {
      borderColor = Colors.amber.shade700;
      iconData = Icons.warning_amber_rounded;
      iconColor = Colors.amber.shade700;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: borderColor, width: 5),
              top: BorderSide(color: borderColor.withValues(alpha: 0.3)),
              right: BorderSide(color: borderColor.withValues(alpha: 0.3)),
              bottom: BorderSide(color: borderColor.withValues(alpha: 0.3)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = _loginUserCtrl.text.trim();
    final password = _loginPassCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _showCustomToast('Username dan password wajib diisi', isSuccess: false);
      return;
    }

    setState(() => _loginLoading = true);

    final result = await AuthService.login(
      username: username,
      password: password,
      rememberMe: _loginRememberMe,
    );

    if (!mounted) return;
    setState(() => _loginLoading = false);

    if (result['success'] == true) {
      _showCustomToast('Login Berhasil! Selamat datang kembali.');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result['data'])),
      );
    } else {
      _showCustomToast(result['message'] ?? 'Login gagal', isSuccess: false);
    }
  }

  Future<void> _handleRegister() async {
    final nama = _regNamaCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final confirmPass = _regConfirmPassCtrl.text;

    if (nama.isEmpty) {
      _showCustomToast('Nama lengkap wajib diisi', isSuccess: false);
      return;
    }
    if (phone.isEmpty) {
      _showCustomToast('Nomor HP wajib diisi', isSuccess: false);
      return;
    }
    if (pass.length < 6) {
      _showCustomToast('Kata sandi minimal 6 karakter', isSuccess: false);
      return;
    }
    if (pass != confirmPass) {
      _showCustomToast('Konfirmasi kata sandi tidak cocok', isSuccess: false);
      return;
    }

    String? birthDateStr;
    if (_selectedBirthDate != null) {
      birthDateStr =
          "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}";
    }

    setState(() => _regLoading = true);

    final result = await AuthService.register(
      nama: nama,
      noHp: phone,
      email: email,
      password: pass,
      tanggalLahir: birthDateStr,
      jenisKelamin: _selectedGender,
      kodeCabang: _selectedCabang ?? 'CBG-001',
    );

    if (!mounted) return;
    setState(() => _regLoading = false);

    if (result['success'] == true) {
      _showCustomToast('Pendaftaran Berhasil! Selamat datang di klinik kami.');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: result['data'])),
      );
    } else {
      _showCustomToast(result['message'] ?? 'Registrasi gagal', isSuccess: false);
    }
  }

  void _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
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
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.ambientGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ── 1. Top Brand Tag Pill ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.spa_rounded, size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Text(
                        'KLINIK KECANTIKAN & ESTETIKA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2. Headline Playfair Display ──
                Text(
                  'Pancarkan Pesona Alami',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkest,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Kulit Sehat & Bersinar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),

                // ── 3. Medical Team Illustration Card ──
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDarkest.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/clinic-team-illustration.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.bgMintLight,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.spa_rounded, size: 40, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(
                                'Klinik Kecantikan & Estetika',
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDarkest,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 4. Main White Card Container ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDarkest.withValues(alpha: 0.08),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Brand Logo Box
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Klinik Kecantikan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tab Switcher (Masuk vs Daftar)
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textMuted,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Masuk'),
                            Tab(text: 'Daftar Pasien'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Tab Views
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          if (_tabController.index == 0) {
                            return _buildLoginForm();
                          } else {
                            return _buildRegisterForm();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── LOGIN FORM ─────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'Selamat Datang',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Silakan masuk ke akun Anda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Username / Email / No HP
        _buildInputField(
          controller: _loginUserCtrl,
          label: 'Email / Username / No. HP',
          hint: 'Masukkan username atau No. HP Anda',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 14),

        // Password
        _buildInputField(
          controller: _loginPassCtrl,
          label: 'Password',
          hint: 'Masukkan password Anda',
          icon: Icons.lock_outline_rounded,
          obscureText: !_loginShowPass,
          suffixIcon: IconButton(
            icon: Icon(
              _loginShowPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textLight,
            ),
            onPressed: () => setState(() => _loginShowPass = !_loginShowPass),
          ),
        ),
        const SizedBox(height: 8),

        // Options: Remember me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _loginRememberMe,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _loginRememberMe = val ?? true),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Ingat Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _showCustomToast(
                  'Lupa password? Silakan hubungi admin klinik untuk mereset kata sandi Anda.',
                  isWarn: true,
                );
              },
              child: Text(
                'Lupa password?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Submit Button
        _buildSubmitButton(
          label: 'Masuk',
          loading: _loginLoading,
          onTap: _handleLogin,
        ),
      ],
    );
  }

  // ─── REGISTER FORM ──────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'Daftar Pasien Baru',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Buat akun untuk booking perawatan & pantau antrean',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Pilih Cabang Klinik
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Cabang Klinik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCabang,
                  isExpanded: true,
                  icon: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 20),
                  items: _cabangList.map((cabang) {
                    return DropdownMenuItem<String>(
                      value: cabang['kode_cabang']?.toString(),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cabang['nama_cabang'] ?? cabang['kode_cabang'] ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCabang = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nama Lengkap
        _buildInputField(
          controller: _regNamaCtrl,
          label: 'Nama Lengkap Pasien',
          hint: 'Contoh: Dewi Safitri',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),

        // Nomor HP / WhatsApp
        _buildInputField(
          controller: _regPhoneCtrl,
          label: 'Nomor WhatsApp / HP',
          hint: 'Contoh: 081234567890',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        // Email (Opsional)
        _buildInputField(
          controller: _regEmailCtrl,
          label: 'Email (Opsional)',
          hint: 'Contoh: dewi@gmail.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        // Tanggal Lahir (Picker)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal Lahir',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickBirthDate,
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
                    const Icon(Icons.calendar_today_outlined, size: 19, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedBirthDate != null
                            ? "${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}"
                            : 'Pilih tanggal lahir Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _selectedBirthDate != null ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Jenis Kelamin Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Kelamin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGender = 'P'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedGender == 'P' ? AppColors.bgMintLight : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedGender == 'P' ? AppColors.primary : AppColors.inputBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female_rounded,
                            size: 18,
                            color: _selectedGender == 'P' ? AppColors.primaryDark : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Perempuan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: _selectedGender == 'P' ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedGender == 'P' ? AppColors.primaryDark : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGender = 'L'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedGender == 'L' ? AppColors.bgMintLight : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedGender == 'L' ? AppColors.primary : AppColors.inputBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male_rounded,
                            size: 18,
                            color: _selectedGender == 'L' ? AppColors.primaryDark : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Laki-laki',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: _selectedGender == 'L' ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedGender == 'L' ? AppColors.primaryDark : AppColors.textMuted,
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
        const SizedBox(height: 12),

        // Kata Sandi
        _buildInputField(
          controller: _regPassCtrl,
          label: 'Kata Sandi',
          hint: 'Minimal 6 karakter',
          icon: Icons.lock_outline_rounded,
          obscureText: !_regShowPass,
          suffixIcon: IconButton(
            icon: Icon(
              _regShowPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textLight,
            ),
            onPressed: () => setState(() => _regShowPass = !_regShowPass),
          ),
        ),
        const SizedBox(height: 12),

        // Konfirmasi Kata Sandi
        _buildInputField(
          controller: _regConfirmPassCtrl,
          label: 'Konfirmasi Kata Sandi',
          hint: 'Ulangi kata sandi Anda',
          icon: Icons.lock_outline_rounded,
          obscureText: !_regShowPass,
        ),
        const SizedBox(height: 22),

        // Submit Button
        _buildSubmitButton(
          label: 'Daftar Akun Pasien',
          loading: _regLoading,
          onTap: _handleRegister,
        ),
      ],
    );
  }

  // Helper Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder, width: 1.5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, size: 19, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hint,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              ?suffixIcon,
            ],
          ),
        ),
      ],
    );
  }

  // Helper Submit Pill Button
  Widget _buildSubmitButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        height: 48,
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
            if (loading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Memproses...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
