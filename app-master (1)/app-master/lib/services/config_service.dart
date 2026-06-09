import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService extends ChangeNotifier {
  static const String _backendUrlKey = 'backend_url';
  String? _backendUrl;

  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _backendUrl = prefs.getString(_backendUrlKey);

    if (_backendUrl == null) {
      try {
        final String configString = await rootBundle.loadString('assets/config.json');
        final Map<String, dynamic> config = json.decode(configString);
        _backendUrl = config['backend_url'] as String;
      } catch (e) {
        _backendUrl = 'http://10.0.2.2:8080';
      }
    }
    notifyListeners();
  }

  String get backendUrl => _backendUrl ?? 'http://10.0.2.2:8080';

  Future<void> setBackendUrl(String url) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    _backendUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUrlKey, url);
    
    notifyListeners();
  }
}
