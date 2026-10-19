import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class BookingService {
  // 1. Ambil Katalog Layanan
  static Future<List<dynamic>> getLayananList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.layanan),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00' || response.statusCode == 200) {
        final resData = data['data'];
        if (resData is List) return resData;
        if (resData is Map) {
          return resData['items'] ?? resData['layanan'] ?? [];
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 2. Cek Slot Jam Tersedia
  static Future<Map<String, dynamic>> getAvailableSlots({
    required String tanggal,
    String? kodeRuangan,
    String? kodeLayanan,
    String? kodeCabang,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.booking}/slots?tanggal_booking=$tanggal'
        '${kodeRuangan != null ? '&kode_ruangan=$kodeRuangan' : ''}'
        '${kodeLayanan != null ? '&kode_layanan=$kodeLayanan' : ''}'
        '${kodeCabang != null ? '&kode_cabang=$kodeCabang' : ''}',
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00') {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal memuat slot'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server slot ($e)'};
    }
  }

  // 3. Buat Booking Reservasi Baru
  static Future<Map<String, dynamic>> createBooking({
    required String kodeJadwal,
    required String tanggalBooking,
    required String jamBooking,
    String? kodeLayanan,
    List<Map<String, dynamic>>? items,
    String? catatan,
    String? metodeDp,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.booking}/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'kode_jadwal': kodeJadwal,
          'tanggal_booking': tanggalBooking,
          'jam_booking': jamBooking,
          'kode_layanan': kodeLayanan ?? (items?.isNotEmpty == true ? items!.first['kode_layanan'] : null),
          if (items != null && items.isNotEmpty) 'items': items,
          'catatan_pasien': catatan,
          'metode_pembayaran_dp': metodeDp ?? 'transfer',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['status'] == '00') {
        return {'success': true, 'message': data['message'], 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat reservasi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server booking ($e)',
      };
    }
  }

  // 4. Ambil Riwayat Booking Pelanggan
  static Future<List<dynamic>> getBookingHistory() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.booking}/history'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00') {
        return data['data'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // 5. Batalkan Booking
  static Future<Map<String, dynamic>> cancelBooking(String kodeBooking, String alasan) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.booking}/$kodeBooking/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'alasan_batal': alasan}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': data['status'] == '00',
        'message': data['message'] ?? 'Gagal membatalkan booking',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }
}
