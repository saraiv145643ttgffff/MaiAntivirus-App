import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_config.dart';

class ScheduleService {
  static const String _configKey = 'schedule_config';
  ScheduleConfig _config = ScheduleConfig();

  ScheduleConfig get config => _config;

  Future<void> init() async {
    await loadConfig();
  }

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? configJson = prefs.getString(_configKey);
      if (configJson != null) {
        _config = ScheduleConfig.fromJson(jsonDecode(configJson));
      }
    } catch (e) {
      // Bỏ qua lỗi load config
    }
  }

  Future<void> saveConfig(ScheduleConfig newConfig) async {
    try {
      _config = newConfig;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, jsonEncode(_config.toJson()));
    } catch (e) {
      // Bỏ qua lỗi save config
    }
  }

  Future<void> updateLastScan() async {
    await saveConfig(ScheduleConfig(
      isEnabled: _config.isEnabled,
      intervalDays: _config.intervalDays,
      lastScan: DateTime.now(),
      preferredTime: _config.preferredTime,
    ));
  }

  /// Kiểm tra xem đã đến lúc quét chưa
  bool shouldScanNow() {
    if (!_config.isEnabled) return false;
    
    final nextScanDate = _config.lastScan.add(Duration(days: _config.intervalDays));
    return DateTime.now().isAfter(nextScanDate);
  }
}
