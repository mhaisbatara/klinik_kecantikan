import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Gunakan 127.0.0.1 dengan `adb reverse tcp:8008 tcp:8008` agar lancar di HP Android fisik
  static const String manualHost = '127.0.0.1';

  static String get host {
    if (manualHost.isNotEmpty) return manualHost;
    if (kIsWeb) return '127.0.0.1';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android Emulator menggunakan 10.0.2.2 untuk mengakses localhost host PC
        return '10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        // 127.0.0.1 mencegah ECONNREFUSED karena resolusi IPv6 (::1) di Windows
        return '127.0.0.1';
    }
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

  // Base URL untuk static assets (uploads gambar)
  static String get assetBaseUrl => 'http://$host:8008';

  // Format URL Gambar dari Server
  static String? getImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final cleanPath = p.startsWith('/') ? p : '/$p';
    return '$assetBaseUrl$cleanPath';
  }
}
