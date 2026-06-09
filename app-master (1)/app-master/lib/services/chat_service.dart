import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import 'config_service.dart';

class ChatService {
  final ConfigService _configService = ConfigService();
  List<ChatMessage> conversationHistory = [];
  static const String _historyKey = 'chat_history_secure_vFinal';
  static const String _encryptionKey = 'MAI_ANTIVIRUS_PRO_2024';

  static const String _welcomeMessage = 
      'Xin chào! Tôi là trợ lý AI của MaiAntivirus. Tôi có thể giúp bạn với:\n\n'
      '• Thông tin về bảo mật và virus\n'
      '• Hướng dẫn sử dụng ứng dụng\n'
      '• Kiểm tra mật khẩu mạnh\n'
      '• Phát hiện phần mềm độc hại\n'
      '• Các mẹo bảo mật thiết bị\n\n'
      'Bạn có câu hỏi gì không?';

  Future<void> init() async {
    await _loadHistory();
  }

  String _encrypt(String data) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(_encryptionKey);
    return base64Encode(List.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]));
  }

  String _decrypt(String encrypted) {
    try {
      final bytes = base64Decode(encrypted);
      final keyBytes = utf8.encode(_encryptionKey);
      return utf8.decode(List.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]));
    } catch (e) { return '[]'; }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_historyKey);
    if (data != null) {
      try {
        final List decoded = jsonDecode(_decrypt(data));
        conversationHistory = decoded.map((m) => ChatMessage.fromJson(m)).toList();
      } catch (e) {}
    }
    if (conversationHistory.isEmpty) {
      conversationHistory.add(ChatMessage(role: 'assistant', content: _welcomeMessage));
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, _encrypt(jsonEncode(conversationHistory.map((m) => m.toJson()).toList())));
  }

  Future<String> sendMessage(String message) async {
    final baseUrl = _configService.backendUrl;
    final url = Uri.parse('$baseUrl/api/v1/chat');
    
    conversationHistory.add(ChatMessage(role: 'user', content: message));
    await _saveHistory();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['response'] ?? 'Không có phản hồi từ AI.';
        conversationHistory.add(ChatMessage(role: 'assistant', content: reply));
        await _saveHistory();
        return reply;
      } else {
        throw 'Lỗi Server';
      }
    } catch (e) {
      final errorMsg = 'Xin lỗi, đã xảy ra lỗi: Lỗi kết nối AI: Vui lòng kiểm tra mạng của bạn.';
      conversationHistory.add(ChatMessage(role: 'assistant', content: errorMsg));
      await _saveHistory();
      throw errorMsg;
    }
  }

  Future<void> clearHistory() async {
    conversationHistory.clear();
    conversationHistory.add(ChatMessage(role: 'assistant', content: _welcomeMessage));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await _saveHistory();
  }
}
