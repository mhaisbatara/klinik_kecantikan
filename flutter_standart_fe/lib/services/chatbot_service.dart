import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class ChatbotResponse {
  final bool success;
  final String reply;
  final List<Map<String, dynamic>> suggestedServices;
  final List<String> quickReplies;
  final String? provider;
  final String? errorMessage;

  ChatbotResponse({
    required this.success,
    required this.reply,
    this.suggestedServices = const [],
    this.quickReplies = const [],
    this.provider,
    this.errorMessage,
  });
}

class ChatbotService {
  /// Mengirim pesan dengan riwayat percakapan (Multi-Turn Chatbot)
  static Future<ChatbotResponse> chat(
    String message, {
    List<Map<String, String>>? history,
    String? kodeCabangFilter,
  }) async {
    try {
      final token = await AuthService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final payload = {
        'message': message.trim(),
        'history': history ?? [],
        if (kodeCabangFilter != null &&
            kodeCabangFilter.isNotEmpty &&
            kodeCabangFilter.toLowerCase() != 'semua' &&
            kodeCabangFilter.toLowerCase() != 'all')
          'kode_cabang_filter': kodeCabangFilter,
      };

      final response = await http
          .post(
            Uri.parse(ApiConstants.chatbotChat),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 50));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['status'] == '00' || data['success'] == true)) {
        final resData = data['data'] ?? {};
        final rawServices = (resData['recommended_services'] ?? resData['suggested_services']) as List? ?? [];
        final rawQuickReplies = resData['quick_replies'] as List? ?? [];

        return ChatbotResponse(
          success: true,
          reply: resData['reply'] ?? 'Terima kasih atas pertanyaan Anda.',
          suggestedServices: rawServices
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
          quickReplies: rawQuickReplies.map((e) => e.toString()).toList(),
          provider: resData['provider']?.toString(),
        );
      } else {
        final msg = data['message'] ?? 'Mohon maaf, terjadi kendala saat memproses jawaban asisten.';
        return ChatbotResponse(
          success: false,
          reply: msg,
          errorMessage: msg,
        );
      }
    } catch (e) {
      return ChatbotResponse(
        success: false,
        reply: 'Gagal terhubung ke Beauty Care Assistant klinik. Silakan periksa koneksi Anda dan coba lagi.',
        errorMessage: e.toString(),
      );
    }
  }

  /// Alias sendMessage untuk backward-compatibility
  static Future<ChatbotResponse> sendMessage(
    String message, {
    List<Map<String, String>>? history,
    String? kodeCabangFilter,
  }) {
    return chat(message, history: history, kodeCabangFilter: kodeCabangFilter);
  }
}
