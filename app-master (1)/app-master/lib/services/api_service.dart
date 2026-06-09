import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/malware_sample.dart';
import 'config_service.dart';

class ApiService {
  final ConfigService _configService = ConfigService();

  Future<String> checkConnectionDetail() async {
    final url = '${_configService.backendUrl}/api/v1/health';
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return "OK";
      return "Server lỗi: ${response.statusCode}";
    } catch (e) {
      return "Không thể kết nối: $e";
    }
  }

  Future<PasswordCheckResult> checkPassword(String password) async {
    final url = '${_configService.backendUrl}/api/v1/password/check';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PasswordCheckResult.fromJson(data);
      }
      throw 'Server phản hồi lỗi: ${response.statusCode}';
    } catch (e) {
      print('Lỗi Password Check: $e');
      throw 'Lỗi kết nối Server. Vui lòng kiểm tra lại địa chỉ IP trong Cài đặt.';
    }
  }

  Future<MalwareSample> searchMalware(String sha256) async {
    final url = '${_configService.backendUrl}/api/v1/malware/${sha256.trim()}';
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return MalwareSample.fromJson(json.decode(response.body));
      }
      throw 'Không tìm thấy mẫu';
    } catch (e) {
      throw 'Lỗi kết nối';
    }
  }
}
