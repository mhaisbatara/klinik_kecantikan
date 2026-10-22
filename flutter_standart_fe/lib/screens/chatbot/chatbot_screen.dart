import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/chatbot_service.dart';
import '../booking/booking_screen.dart';
import '../profile/patient_sync_sheet.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final List<Map<String, dynamic>> suggestedServices;
  final List<String> quickReplies;
  final String? provider;

  ChatMessage({
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.suggestedServices = const [],
    this.quickReplies = const [],
    this.provider,
  });

  ChatMessage copyWith({
    bool? isUser,
    String? text,
    DateTime? timestamp,
    List<Map<String, dynamic>>? suggestedServices,
    List<String>? quickReplies,
    String? provider,
  }) {
    return ChatMessage(
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      suggestedServices: suggestedServices ?? this.suggestedServices,
      quickReplies: quickReplies ?? this.quickReplies,
      provider: provider ?? this.provider,
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const ChatbotScreen({super.key, this.currentUser});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;
  Map<String, dynamic>? _user;

  // Filter Cabang Klinik
  List<Map<String, dynamic>> _branches = [];
  String _selectedKodeCabang = 'semua';
  String _selectedNamaCabang = 'Semua Cabang';

  static const List<String> _defaultQuickReplies = [
    '✨ Rekomendasi wajah berjerawat',
    '💆‍♀️ Daftar harga perawatan',
    '📅 Cek jadwal booking saya',
    '🎫 Cek sisa paket saya',
  ];

  List<String> _currentQuickReplies = [];

  late AnimationController _dotsAnimCtrl;

  // Animasi Mengetik Bertahap (Typewriter Effect)
  Timer? _typewriterTimer;
  Completer<void>? _typewriterCompleter;
  String? _pendingFullText;
  int? _pendingMsgIndex;
  List<Map<String, dynamic>>? _pendingServices;
  List<String>? _pendingQuickReplies;
  String? _pendingProvider;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
    _dotsAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Munculkan indikator asisten sedang mengetik terlebih dahulu
    _isTyping = true;
    _currentQuickReplies = [];

    _initUserDataAndGreeting();
    _fetchBranches();
  }

  @override
  void dispose() {
    _completeTypewriterImmediately();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _dotsAnimCtrl.dispose();
    super.dispose();
  }

  void _completeTypewriterImmediately() {
    if (_typewriterTimer != null && _typewriterTimer!.isActive) {
      _typewriterTimer?.cancel();
      if (_pendingMsgIndex != null &&
          _pendingMsgIndex! < _messages.length &&
          _pendingFullText != null) {
        setState(() {
          _messages[_pendingMsgIndex!] = _messages[_pendingMsgIndex!].copyWith(
            text: _pendingFullText!,
            suggestedServices: _pendingServices ?? const [],
            quickReplies: _pendingQuickReplies ?? const [],
            provider: _pendingProvider,
          );
        });
      }
      _pendingFullText = null;
      _pendingMsgIndex = null;
      _pendingServices = null;
      _pendingQuickReplies = null;
      _pendingProvider = null;

      if (_typewriterCompleter != null && !_typewriterCompleter!.isCompleted) {
        _typewriterCompleter!.complete();
      }
    }
  }

  Future<void> _typewriterAnimate(
    String fullText, {
    List<Map<String, dynamic>> suggestedServices = const [],
    List<String> quickReplies = const [],
    String? provider,
  }) async {
    _completeTypewriterImmediately();

    final messageIndex = _messages.length;
    _pendingFullText = fullText;
    _pendingMsgIndex = messageIndex;
    _pendingServices = suggestedServices;
    _pendingQuickReplies = quickReplies;
    _pendingProvider = provider;

    setState(() {
      _messages.add(
        ChatMessage(
          isUser: false,
          text: '',
          timestamp: DateTime.now(),
          provider: provider,
        ),
      );
    });

    final completer = Completer<void>();
    _typewriterCompleter = completer;

    // Hitung step chunk agar animasi selalu terasa responsif, luwes dan tidak terlalu lambat
    final chunkSize = (fullText.length / 60).ceil().clamp(2, 12);
    int charIndex = 0;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }

      charIndex += chunkSize;
      if (charIndex >= fullText.length) {
        charIndex = fullText.length;
        timer.cancel();
        setState(() {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            text: fullText,
            suggestedServices: suggestedServices,
            quickReplies: quickReplies,
            provider: provider,
          );
        });
        _pendingFullText = null;
        _pendingMsgIndex = null;
        _pendingServices = null;
        _pendingQuickReplies = null;
        _pendingProvider = null;

        _scrollToBottom();
        if (!completer.isCompleted) completer.complete();
      } else {
        setState(() {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            text: fullText.substring(0, charIndex),
          );
        });
        _jumpToBottom();
      }
    });

    return completer.future;
  }

  Future<void> _fetchBranches() async {
    try {
      final list = await AuthService.getCabangList();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _branches = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _initUserDataAndGreeting() async {
    _completeTypewriterImmediately();

    setState(() {
      _isTyping = true;
      _currentQuickReplies = [];
    });

    if (_user == null) {
      final cached = await AuthService.getUser();
      if (mounted && cached != null) {
        setState(() => _user = cached);
      }
    }

    final name = _user?['fullname'] ?? _user?['nama'] ?? _user?['username'] ?? 'Kak';
    final greeting =
        'Halo Kak $name! 🌸 Selamat datang di **Beauty Care AI Assistant** Klinik Kecantikan.\n\n'
        'Saya siap membantu konsultasi keluhan kulit (jerawat, flek kusam, anti-aging), cek harga treatment, '
        'serta memeriksa **jadwal booking aktif** dan **sisa kuota paket** perawatan Anda secara real-time.\n\n'
        'Ada yang bisa saya bantu hari ini?';

    // Jeda alami ~650ms agar animasi dots mengetik muncul terlebih dahulu
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
    });

    // Mulai animasi teks berjalan (typewriter effect)
    await _typewriterAnimate(
      greeting,
      quickReplies: _defaultQuickReplies,
    );

    if (mounted) {
      setState(() {
        _currentQuickReplies = _defaultQuickReplies;
      });
      _scrollToBottom();
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? predefinedText]) async {
    final text = (predefinedText ?? _inputCtrl.text).trim();
    if (text.isEmpty || _isTyping) return;

    _completeTypewriterImmediately();

    if (predefinedText == null) {
      _inputCtrl.clear();
    }

    // Bangun history percakapan sebelumnya untuk multi-turn context
    final history = _messages
        .where((m) => m.text.trim().isNotEmpty)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    setState(() {
      _messages.add(
        ChatMessage(
          isUser: true,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await ChatbotService.chat(
      text,
      history: history,
      kodeCabangFilter: _selectedKodeCabang,
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;
    });

    await _typewriterAnimate(
      response.reply,
      suggestedServices: response.suggestedServices,
      quickReplies: response.quickReplies,
      provider: response.provider,
    );

    if (mounted) {
      if (response.quickReplies.isNotEmpty) {
        setState(() {
          _currentQuickReplies = response.quickReplies;
        });
      }
      _scrollToBottom();
    }
  }

  void _handleBookingDirect(Map<String, dynamic> service) async {
    final noRm = _user?['no_rm'];
    if (noRm == null || noRm.toString().trim().isEmpty) {
      final synced = await PatientSyncSheet.show(
        context,
        currentUser: _user,
        initialStep: PatientSyncStep.choose,
      );

      if (synced == true) {
        final refreshed = await AuthService.fetchProfile();
        if (mounted && refreshed != null) {
          setState(() => _user = refreshed);
        }
      } else {
        return;
      }
    }

    if (!mounted) return;

    final String? svcKodeCabang = service['kode_cabang'] ??
        (_selectedKodeCabang != 'semua' ? _selectedKodeCabang : null);
    final String? rawNamaCabang = service['nama_cabang'] ??
        (_selectedKodeCabang != 'semua' ? _selectedNamaCabang : null);
    final String? svcNamaCabang = rawNamaCabang != null ? _formatBranchName(rawNamaCabang) : null;

    final bool isClaim = service['is_claim_packet'] == true ||
        service['is_claim'] == true ||
        (service['kode_detail_kepemilikan_paket_layanan'] != null &&
            service['kode_detail_kepemilikan_paket_layanan'].toString().isNotEmpty);
    final String? dkpl = service['kode_detail_kepemilikan_paket_layanan']?.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          initialLayanan: {
            'kode_layanan': service['kode_layanan'],
            'nama_layanan': service['nama_layanan'] ?? service['nama'],
            'nama': service['nama_layanan'] ?? service['nama'],
            'harga': isClaim ? 0 : service['harga'],
            'durasi_menit': service['durasi_menit'],
            'kode_ruangan': service['kode_ruangan'],
            'kode_cabang': svcKodeCabang,
            'nama_cabang': svcNamaCabang,
            'is_claim_packet': isClaim,
            'kode_detail_kepemilikan_paket_layanan': dkpl,
            'kode_kepemilikan_paket_layanan': service['kode_kepemilikan_paket_layanan'],
            'nama_paket': service['nama_paket'],
            'sisa_sesi': service['sisa_sesi'],
          },
          initialKodeCabang: svcKodeCabang,
          initialNamaCabang: svcNamaCabang,
          isClaim: isClaim,
          kodeDetailKepemilikan: dkpl,
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

  String _formatCurrency(dynamic val) {
    final num = int.tryParse(val.toString()) ?? (double.tryParse(val.toString())?.toInt() ?? 0);
    return 'Rp${num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildBranchFilterBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (ctx, idx) {
                  if (idx == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[idx]);
                },
              ),
            ),
            if (_currentQuickReplies.isNotEmpty) _buildQuickReplyBar(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchFilterBar() {
    final allOptions = <Map<String, String>>[
      {'kode_cabang': 'semua', 'nama_cabang': 'Semua Cabang', 'icon': '🌐'},
      ..._branches.map((b) => {
            'kode_cabang': (b['kode_cabang'] ?? '').toString(),
            'nama_cabang': _formatBranchName((b['nama_cabang'] ?? 'Cabang Klinik').toString()),
            'icon': '📍',
          }),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: allOptions.map((opt) {
            final isSelected = _selectedKodeCabang == opt['kode_cabang'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  if (_selectedKodeCabang != opt['kode_cabang']) {
                    setState(() {
                      _selectedKodeCabang = opt['kode_cabang']!;
                      _selectedNamaCabang = opt['nama_cabang']!;
                    });
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _selectedKodeCabang == 'semua'
                              ? '🌐 Menampilkan seluruh cabang klinik'
                              : '📍 Fokus chat diubah ke: ${opt['nama_cabang']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 1800),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryDark : const Color(0xFFCBD5E1),
                      width: 1.1,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt['icon'] ?? '📍',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        opt['nama_cabang']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Beauty Care Assistant',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgMintSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Online • Siap Membantu 24/7',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF059669),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
          tooltip: 'Reset Percakapan',
          onPressed: () {
            _completeTypewriterImmediately();
            setState(() {
              _messages.clear();
              _currentQuickReplies = [];
            });
            _initUserDataAndGreeting();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.timestamp),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    // Assistant Message Bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(top: 2, right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgMintSoft,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.spa_rounded, color: AppColors.primaryDark, size: 18),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _renderFormattedText(msg.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Row(
              children: [
                Text(
                  _formatTime(msg.timestamp),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                if (msg.provider != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      msg.provider == 'google_gemini'
                          ? '✨ Gemini 2.5'
                          : (msg.provider == 'groq_llama' ? '⚡ Groq Llama 3.3' : '🏥 Data Klinik'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (msg.suggestedServices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.recommend_rounded, size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Text(
                        'Rekomendasi Perawatan Terkait:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...msg.suggestedServices.map((svc) => _buildServiceCard(svc)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> svc) {
    final nama = svc['nama_layanan'] ?? svc['nama'] ?? 'Layanan Klinik';
    final harga = svc['harga'] ?? 0;
    final durasi = svc['durasi_menit'] ?? 30;
    final isIncludeKonsul = svc['is_include_konsultasi'] == 1;

    final bool isClaim = svc['is_claim_packet'] == true ||
        svc['is_claim'] == true ||
        (svc['kode_detail_kepemilikan_paket_layanan'] != null &&
            svc['kode_detail_kepemilikan_paket_layanan'].toString().isNotEmpty);
    final sisaSesi = svc['sisa_sesi'];
    final namaPaket = svc['nama_paket'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isClaim ? const Color(0xFFF9FDFB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isClaim ? const Color(0xFF10B981) : AppColors.primary.withValues(alpha: 0.25),
          width: isClaim ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isClaim ? const Color(0xFF10B981) : AppColors.primary).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (isClaim && namaPaket != null && namaPaket.toString().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Dari: $namaPaket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isClaim)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Klaim Sisa Sesi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF047857),
                      ),
                    ),
                    Text(
                      'Gratis (Free DP)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  _formatCurrency(harga),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Badge Sisa Sesi Paket jika Klaim
              if (isClaim)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎫', style: TextStyle(fontSize: 10.5)),
                      const SizedBox(width: 4),
                      Text(
                        sisaSesi != null ? 'Sisa $sisaSesi Sesi Paket' : 'Sisa Sesi Paket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF065F46),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Durasi Treatment
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '$durasi menit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge Lokasi Cabang
              if (svc['nama_cabang'] != null && svc['nama_cabang'].toString().trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // soft blue background
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          _formatBranchName(svc['nama_cabang'].toString()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Badge Free Konsul Dokter (hanya jika bukan klaim paket)
              if (!isClaim && isIncludeKonsul)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text(
                        'Free Konsul',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleBookingDirect(svc),
              icon: Icon(
                isClaim ? Icons.verified_rounded : Icons.calendar_month_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                isClaim ? 'Klaim Sesi Ini' : 'Booking Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isClaim ? const Color(0xFF059669) : AppColors.primaryDark,
                elevation: isClaim ? 1 : 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Asisten sedang mengetik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _dotsAnimCtrl,
                  builder: (ctx, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final val = (_dotsAnimCtrl.value * 3 - index) % 3;
                        final active = val >= 0 && val < 1.2;
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? AppColors.primary : const Color(0xFFCBD5E1),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderFormattedText(String content) {
    // Basic Markdown Parser (support bold **bold**, bullet points, warnings)
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      final isWarning = line.trim().startsWith('⚠️') || line.trim().startsWith('*Catatan Medis:');
      final isBullet = line.trim().startsWith('•') || line.trim().startsWith('-');

      TextStyle baseStyle = GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: isWarning ? const Color(0xFFB45309) : AppColors.textDark,
        height: 1.45,
      );

      if (isWarning) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: _buildRichSpan(line, baseStyle.copyWith(fontWeight: FontWeight.w500)),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            left: isBullet ? 6 : 0,
            bottom: 3,
          ),
          child: _buildRichSpan(line, baseStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichSpan(String line, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: line.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastMatchEnd), style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildQuickReplyBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _currentQuickReplies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final reply = _currentQuickReplies[idx];
          return ActionChip(
            onPressed: () => _handleSendMessage(reply),
            label: Text(
              reply,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDeep,
              ),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFA7F3D0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0.5,
            pressElevation: 1.5,
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Tanyakan keluhan, harga, atau jadwal...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _handleSendMessage(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
