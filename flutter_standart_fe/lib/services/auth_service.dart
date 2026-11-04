import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  static const String keyToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';

  // 1. Login
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
          'remember_me': rememberMe,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        final token = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: token,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal, periksa kredensial Anda',
        };
      }
    } catch (e) {
      // Auto-fallback host jika koneksi terputus (misal wireless ADB disconnect)
      final oldHost = ApiConstants.host;
      final newHost = await ApiConstants.resolveActiveHost();
      if (newHost != oldHost) {
        return login(username: username, password: password, rememberMe: rememberMe);
      }
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e). Pastikan server backend berjalan.',
      };
    }
  }

  // Ambil Daftar Cabang Klinik
  static Future<List<Map<String, dynamic>>> getCabangList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.cabang),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00' && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
      return [
        {'kode_cabang': 'CBG-001', 'nama_cabang': 'Klinik Cabang Utama'},
        {'kode_cabang': 'CBG-002', 'nama_cabang': 'Klinik Cabang Surabaya'},
      ];
    } catch (_) {
      final oldHost = ApiConstants.host;
      final newHost = await ApiConstants.resolveActiveHost();
      if (newHost != oldHost) {
        return getCabangList();
      }
      return [
        {'kode_cabang': 'CBG-001', 'nama_cabang': 'Klinik Cabang Utama'},
        {'kode_cabang': 'CBG-002', 'nama_cabang': 'Klinik Cabang Surabaya'},
      ];
    }
  }

  // 2. Register Akun Akses Mobile (User Auth Murni)
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String noHp,
    String? email,
    required String password,
    String? kodeCabang,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama.trim(),
          'no_hp': noHp.trim(),
          'email': email != null && email.trim().isNotEmpty ? email.trim() : null,
          'password': password,
          'kode_cabang': kodeCabang ?? 'CBG-001',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['status'] == '00') {
        final token = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: token,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal, coba lagi nanti',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e). Pastikan server backend aktif.',
      };
    }
  }

  // 3. Register Pasien Baru (Opsi A: Menerbitkan Rekam Medis Baru)
  static Future<Map<String, dynamic>> registerPatient({
    required String nama,
    required String nik,
    String? tempatLahir,
    required String tanggalLahir,
    required String jenisKelamin,
    String? golonganDarah,
    String? agama,
    String? statusPerkawinan,
    String? kewarganegaraan,
    String? pekerjaan,
    required String provinsi,
    String? kotaKabupaten,
    String? kecamatan,
    String? kelurahanDesa,
    String? kodePos,
    String? patokan,
    String? alamat,
    required String noHp,
    String? email,
    String? namaKontakDarurat,
    String? noHpKontakDarurat,
    String? hubunganKontakDarurat,
    String? alergi,
  }) async {
    try {
      final token = await getToken();
      final body = <String, dynamic>{
        'nama': nama.trim(),
        'nik': nik.trim(),
        if (tempatLahir != null && tempatLahir.trim().isNotEmpty) 'tempat_lahir': tempatLahir.trim(),
        'tanggal_lahir': tanggalLahir.trim(),
        'jenis_kelamin': jenisKelamin,
        if (golonganDarah != null && golonganDarah.trim().isNotEmpty) 'golongan_darah': golonganDarah.trim(),
        if (agama != null && agama.trim().isNotEmpty) 'agama': agama.trim(),
        if (statusPerkawinan != null && statusPerkawinan.trim().isNotEmpty) 'status_perkawinan': statusPerkawinan.trim(),
        if (kewarganegaraan != null && kewarganegaraan.trim().isNotEmpty) 'kewarganegaraan': kewarganegaraan.trim(),
        if (pekerjaan != null && pekerjaan.trim().isNotEmpty) 'pekerjaan': pekerjaan.trim(),
        'provinsi': provinsi.trim(),
        if (kotaKabupaten != null && kotaKabupaten.trim().isNotEmpty) 'kota_kabupaten': kotaKabupaten.trim(),
        if (kecamatan != null && kecamatan.trim().isNotEmpty) 'kecamatan': kecamatan.trim(),
        if (kelurahanDesa != null && kelurahanDesa.trim().isNotEmpty) 'kelurahan_desa': kelurahanDesa.trim(),
        if (kodePos != null && kodePos.trim().isNotEmpty) 'kode_pos': kodePos.trim(),
        if (patokan != null && patokan.trim().isNotEmpty) 'patokan': patokan.trim(),
        if (alamat != null && alamat.trim().isNotEmpty) 'alamat': alamat.trim(),
        'no_hp': noHp.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (namaKontakDarurat != null && namaKontakDarurat.trim().isNotEmpty) 'nama_kontak_darurat': namaKontakDarurat.trim(),
        if (noHpKontakDarurat != null && noHpKontakDarurat.trim().isNotEmpty) 'no_hp_kontak_darurat': noHpKontakDarurat.trim(),
        if (hubunganKontakDarurat != null && hubunganKontakDarurat.trim().isNotEmpty) 'hubungan_kontak_darurat': hubunganKontakDarurat.trim(),
        if (alergi != null && alergi.trim().isNotEmpty) 'alergi': alergi.trim(),
      };

      final response = await http.post(
        Uri.parse(ApiConstants.registerPatient),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        final newToken = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: newToken,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Pendaftaran pasien baru gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // Wilayah Indonesia Helpers
  static Future<List<Map<String, dynamic>>> getWilayahProvinsi() async {
    try {
      final res = await http.get(Uri.parse(ApiConstants.wilayahProvinsi)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> getWilayahKota(String kodeProvinsi) async {
    try {
      final url = '${ApiConstants.wilayahKota}?kode_provinsi=$kodeProvinsi';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> getWilayahKecamatan(String kodeKota) async {
    try {
      final url = '${ApiConstants.wilayahKecamatan}?kode_kota=$kodeKota';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> getWilayahKelurahan(String kodeKecamatan) async {
    try {
      final url = '${ApiConstants.wilayahKelurahan}?kode_kecamatan=$kodeKecamatan';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  // 4-pre. Cek & Pra-Validasi Data Pasien Sebelum Kirim OTP
  static Future<Map<String, dynamic>> checkClaimPatient({
    String? noRm,
    required String tanggalLahir,
    required String noHp,
    String? nik,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.checkClaimPatient),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (noRm != null && noRm.trim().isNotEmpty) 'no_rm': noRm.trim(),
          'tanggal_lahir': tanggalLahir.trim(),
          'no_hp': noHp.trim(),
          if (nik != null && nik.trim().isNotEmpty) 'nik': nik.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': data['message'] ?? 'Data pasien tidak ditemukan atau tidak sesuai',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // 4a. Request OTP Sinkronisasi Rekam Medis (Kirim ke Nomor HP / WhatsApp Pasien)
  static Future<Map<String, dynamic>> requestClaimOtp({
    String? noRm,
    required String tanggalLahir,
    required String noHp,
    String? nik,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.requestClaimOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (noRm != null && noRm.trim().isNotEmpty) 'no_rm': noRm.trim(),
          'tanggal_lahir': tanggalLahir.trim(),
          'no_hp': noHp.trim(),
          if (nik != null && nik.trim().isNotEmpty) 'nik': nik.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': data['message'] ?? 'Permintaan kode OTP gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // 4b. Verifikasi 6 Digit Kode OTP untuk Menyelesaikan Penautan Rekam Medis
  static Future<Map<String, dynamic>> verifyClaimOtp({
    required String otpCode,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.verifyClaimOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otp_code': otpCode.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        final newToken = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: newToken,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': data['message'] ?? 'Verifikasi kode OTP gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // 4b-2. Melepaskan Tautan Rekam Medis (Unlink)
  static Future<Map<String, dynamic>> unlinkPatient() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.unlinkPatient),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        final newToken = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: newToken,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal melepaskan tautan rekam medis',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // 4c. Klaim Pasien Lama (Direct Strict Matching Fallback)
  static Future<Map<String, dynamic>> claimPatient({
    String? noRm,
    required String tanggalLahir,
    String? noHp,
    String? nik,
    String? nama,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.claimPatient),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (noRm != null && noRm.trim().isNotEmpty) 'no_rm': noRm.trim(),
          'tanggal_lahir': tanggalLahir.trim(),
          if (noHp != null && noHp.trim().isNotEmpty) 'no_hp': noHp.trim(),
          if (nik != null && nik.trim().isNotEmpty) 'nik': nik.trim(),
          if (nama != null && nama.trim().isNotEmpty) 'nama': nama.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == '00') {
        final newToken = data['data']['access_token'];
        final refreshToken = data['data']['refresh_token'];
        final userInfo = data['data']['user_info'];

        await saveSession(
          token: newToken,
          refreshToken: refreshToken,
          user: userInfo,
        );

        return {'success': true, 'message': data['message'], 'data': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Sinkronisasi rekam medis gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server ($e)',
      };
    }
  }

  // 5. Fetch Profil Terbaru dari Server
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == '00') {
        final userInfo = data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyUser, jsonEncode(userInfo));
        return userInfo;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 3. Simpan Sesi
  static Future<void> saveSession({
    required String token,
    String? refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    if (refreshToken != null) {
      await prefs.setString(keyRefreshToken, refreshToken);
    }
    await prefs.setString(keyUser, jsonEncode(user));
  }

  // 4. Ambil Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  // 5. Ambil Info User
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(keyUser);
    if (userStr != null) {
      try {
        return jsonDecode(userStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // 6. Cek status login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 7. Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyRefreshToken);
    await prefs.remove(keyUser);
  }
}
