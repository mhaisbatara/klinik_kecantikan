import 'package:flutter/foundation.dart';

class ApiConstants {
  // Otomatis memilih host:
  // - Android Emulator: 10.0.2.2 (karena localhost di emulator adalah emulator itu sendiri)
  // - iOS Simulator / Web / Desktop: localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8008/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8008/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8008/api/v1';
    }
  }

  // Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';
  static String get homeDashboard => '$baseUrl/dashboard/home';
  static String get layanan => '$baseUrl/layanan';
  static String get produk => '$baseUrl/produk';
  static String get booking => '$baseUrl/booking';
  static String get antrean => '$baseUrl/antrean';
  static String get cabang => '$baseUrl/cabang';

  // Base URL untuk static assets (uploads gambar)
  static String get assetBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8008';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8008';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8008';
    }
  }

  // Format URL Gambar dari Server
  static String? getImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final cleanPath = p.startsWith('/') ? p : '/$p';
    return '$assetBaseUrl$cleanPath';
  }
}
