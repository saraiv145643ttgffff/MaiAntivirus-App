import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_password.dart';

class PasswordVaultService {
  static const String _storageKey = 'secure_password_vault_v1';
  static const String _encryptionKey = 'MAI_VAULT_PROTECT_2024';

  // Hàm mã hóa đơn giản (XOR)
  String _encrypt(String data) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(_encryptionKey);
    return base64Encode(List.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]));
  }

  // Hàm giải mã
  String _decrypt(String encrypted) {
    try {
      final bytes = base64Decode(encrypted);
      final keyBytes = utf8.encode(_encryptionKey);
      return utf8.decode(List.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]));
    } catch (e) { return '[]'; }
  }

  Future<void> savePassword(String label, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getSavedPasswords();
    
    currentList.add(SavedPassword(
      label: label,
      password: password,
      date: DateTime.now(),
    ));

    final String encoded = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, _encrypt(encoded));
  }

  Future<List<SavedPassword>> getSavedPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];

    try {
      final List decoded = jsonDecode(_decrypt(data));
      return decoded.map((e) => SavedPassword.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePassword(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getSavedPasswords();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      final String encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, _encrypt(encoded));
    }
  }
}
