import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Daftar kandidat IP host backend:
  /// 1. 127.0.0.1 (Koneksi via adb reverse atau Android Emulator)
  /// 2. 192.168.137.1 (IP Windows Mobile Hotspot ke HP fisik)
  /// 3. 192.168.1.13 (IP Wi-Fi LAN lokal)
  static const List<String> candidateHosts = [
    '127.0.0.1',
    '192.168.137.1',
    '192.168.1.13',
  ];

  static String _activeHost = '127.0.0.1';

  static String get host => _activeHost;

  static void setHost(String newHost) {
    _activeHost = newHost;
  }

  /// Otomatis mendeteksi host mana yang aktif dan merespons cepat di port 8008
  static Future<String> resolveActiveHost() async {
    if (kIsWeb) {
      _activeHost = '127.0.0.1';
      return _activeHost;
    }

    // 1. Coba host aktif terlebih dahulu
    try {
      final s = await Socket.connect(_activeHost, 8008, timeout: const Duration(milliseconds: 300));
      s.destroy();
      return _activeHost;
    } catch (_) {}

    // 2. Jika host saat ini tidak merespons, cari dari daftar kandidat lain
    for (final candidate in candidateHosts) {
      if (candidate == _activeHost) continue;
      try {
        final socket = await Socket.connect(candidate, 8008, timeout: const Duration(milliseconds: 500));
        socket.destroy();
        _activeHost = candidate;
        debugPrint('[ApiConstants] Auto-switched backend host to: $_activeHost:8008');
        return candidate;
      } catch (_) {
        continue;
      }
    }
    return _activeHost;
  }

  static String get baseUrl => 'http://$host:8008/api/v1';

  // Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';
  static String get profile => '$baseUrl/profile';
  static String get registerPatient => '$baseUrl/profile/register-patient';
  static String get claimPatient => '$baseUrl/profile/claim-patient';
  static String get myPackages => '$profile/packages';
  static String get homeDashboard => '$baseUrl/dashboard/home';
  static String get layanan => '$baseUrl/layanan';
  static String get produk => '$baseUrl/produk';
  static String get booking => '$baseUrl/booking';
  static String get antrean => '$baseUrl/antrean';
  static String get cabang => '$baseUrl/cabang';
  static String get kunjungan => '$baseUrl/kunjungan';
  static String get chatbotMessage => '$baseUrl/chatbot/message';
  static String get chatbotChat => '$baseUrl/chatbot/chat';

  // Base URL untuk static assets (uploads gambar)
  static String get assetBaseUrl => 'http://$host:8008';

  // Format URL Gambar dari Server
  static String? getImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://127.0.0.1:8008')) {
      return p.replaceFirst('http://127.0.0.1:8008', assetBaseUrl);
    }
    if (p.startsWith('http://localhost:8008')) {
      return p.replaceFirst('http://localhost:8008', assetBaseUrl);
    }
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final cleanPath = p.startsWith('/') ? p : '/$p';
    return '$assetBaseUrl$cleanPath';
  }
}
