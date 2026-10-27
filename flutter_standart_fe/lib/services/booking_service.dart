import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class BookingService {
  // 1. Ambil Katalog Layanan
  static Future<List<dynamic>> getLayananList({String? kodeCabang}) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.layanan}${kodeCabang != null && kodeCabang.isNotEmpty ? '?kode_cabang=$kodeCabang' : ''}',
      );
      final response = await http.get(
        uri,
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

  // 1b. Ambil Katalog Paket Layanan
  static Future<List<dynamic>> getPaketList({String? kodeCabang}) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/paket${kodeCabang != null && kodeCabang.isNotEmpty ? '?kode_cabang=$kodeCabang' : ''}',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00' || response.statusCode == 200) {
        final resData = data['data'];
        if (resData is Map) {
          return List<dynamic>.from(resData['paket_layanan'] ?? []);
        }
        if (resData is List) return resData;
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
    String? jenisLayanan,
    List<Map<String, dynamic>>? items,
    String? catatan,
    String? metodeDp,
    String? kodeMetodePembayaran,
    XFile? buktiDpFile,
    String? kodeCabang,
    bool? butuhKonsul,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (buktiDpFile != null) {
        final request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.booking}/create'));
        if (token != null) request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        request.fields['kode_jadwal'] = kodeJadwal;
        request.fields['tanggal_booking'] = tanggalBooking;
        request.fields['jam_booking'] = jamBooking;
        if (jenisLayanan != null && jenisLayanan.isNotEmpty) {
          request.fields['jenis_layanan'] = jenisLayanan;
        }
        if (kodeCabang != null && kodeCabang.isNotEmpty) {
          request.fields['kode_cabang'] = kodeCabang;
        }
        if (butuhKonsul != null) {
          request.fields['butuh_konsul'] = butuhKonsul ? '1' : '0';
        }
        if (kodeLayanan != null) {
          request.fields['kode_layanan'] = kodeLayanan;
        } else if (items?.isNotEmpty == true) {
          request.fields['kode_layanan'] = items!.first['kode_layanan']?.toString() ?? '';
        }
        if (items != null && items.isNotEmpty) {
          request.fields['items'] = jsonEncode(items);
        }
        if (catatan != null && catatan.isNotEmpty) {
          request.fields['catatan_pasien'] = catatan;
        }
        request.fields['metode_pembayaran_dp'] = metodeDp ?? 'transfer';
        if (kodeMetodePembayaran != null && kodeMetodePembayaran.isNotEmpty) {
          request.fields['kode_metode_pembayaran'] = kodeMetodePembayaran;
        }

        final bytes = await buktiDpFile.readAsBytes();
        final rawExt = buktiDpFile.name.contains('.') ? buktiDpFile.name.split('.').last.toLowerCase() : 'jpg';
        MediaType contentType;
        if (rawExt == 'png') {
          contentType = MediaType('image', 'png');
        } else if (rawExt == 'webp') {
          contentType = MediaType('image', 'webp');
        } else {
          contentType = MediaType('image', 'jpeg');
        }

        final multipartFile = http.MultipartFile.fromBytes(
          'bukti_dp',
          bytes,
          filename: buktiDpFile.name.isNotEmpty ? buktiDpFile.name : 'bukti_dp.jpg',
          contentType: contentType,
        );
        request.files.add(multipartFile);

        final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
        final response = await http.Response.fromStream(streamedResponse);
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
      }

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
          if (jenisLayanan != null && jenisLayanan.isNotEmpty) 'jenis_layanan': jenisLayanan,
          'kode_layanan': kodeLayanan ?? (items?.isNotEmpty == true ? items!.first['kode_layanan'] : null),
          if (items != null && items.isNotEmpty) 'items': items,
          'catatan_pasien': catatan,
          'metode_pembayaran_dp': metodeDp ?? 'transfer',
          if (kodeMetodePembayaran != null && kodeMetodePembayaran.isNotEmpty)
            'kode_metode_pembayaran': kodeMetodePembayaran,
          if (kodeCabang != null && kodeCabang.isNotEmpty) 'kode_cabang': kodeCabang,
          if (butuhKonsul != null) 'butuh_konsul': butuhKonsul ? 1 : 0,
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
  static Future<Map<String, dynamic>> cancelBooking(String kodeBooking, [String? alasan]) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.booking}/$kodeBooking/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (alasan != null && alasan.isNotEmpty) 'alasan_batal': alasan,
        }),
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

  // 6. Ambil Daftar Paket Perawatan Pasien (Kartu Stempel Multi-Sesi)
  static Future<List<dynamic>> getMyPackages() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.myPackages),
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

  // 7. Ambil Master Metode Pembayaran Aktif (Rekening Bank & QRIS)
  static Future<Map<String, dynamic>> getMetodePembayaran({String? kodeCabang}) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('${ApiConstants.baseUrl}/metode-pembayaran').replace(
        queryParameters: {
          if (kodeCabang != null && kodeCabang.isNotEmpty) 'kode_cabang': kodeCabang,
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00' || data['status'] == true || data['success'] == true) {
        final payload = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : <String, dynamic>{};
        return {
          'success': true,
          'data': payload,
          'grouped': payload['grouped'] ?? {'rekening': [], 'qris': []},
          'all': payload['metode_pembayaran'] ?? [],
        };
      }
      return {'success': false, 'grouped': {'rekening': [], 'qris': []}, 'all': []};
    } catch (_) {
      return {'success': false, 'grouped': {'rekening': [], 'qris': []}, 'all': []};
    }
  }

  // 8. Ambil Transaksi Booking Pending (Belum Upload Bukti DP)
  static Future<Map<String, dynamic>?> getPendingBooking() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.booking}/pending'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == '00' && data['data'] != null) {
        return Map<String, dynamic>.from(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 9. Upload Bukti DP untuk Booking Pending (Langkah 3)
  static Future<Map<String, dynamic>> uploadBuktiDp({
    required String kodeBooking,
    required XFile buktiDpFile,
    String? metodeDp,
    String? kodeMetodePembayaran,
  }) async {
    try {
      final token = await AuthService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.booking}/$kodeBooking/upload-bukti-dp'),
      );
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      if (metodeDp != null && metodeDp.isNotEmpty) {
        request.fields['metode_pembayaran_dp'] = metodeDp;
      }
      if (kodeMetodePembayaran != null && kodeMetodePembayaran.isNotEmpty) {
        request.fields['kode_metode_pembayaran'] = kodeMetodePembayaran;
      }

      final bytes = await buktiDpFile.readAsBytes();
      final rawExt = buktiDpFile.name.contains('.') ? buktiDpFile.name.split('.').last.toLowerCase() : 'jpg';
      MediaType contentType;
      if (rawExt == 'png') {
        contentType = MediaType('image', 'png');
      } else if (rawExt == 'webp') {
        contentType = MediaType('image', 'webp');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'bukti_dp',
        bytes,
        filename: buktiDpFile.name.isNotEmpty ? buktiDpFile.name : 'bukti_dp.jpg',
        contentType: contentType,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == '00') {
        return {'success': true, 'message': data['message'], 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengunggah bukti pembayaran DP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }
}

