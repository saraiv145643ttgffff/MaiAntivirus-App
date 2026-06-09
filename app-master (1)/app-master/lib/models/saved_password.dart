import 'dart:convert';

class SavedPassword {
  final String label;
  final String password;
  final DateTime date;

  SavedPassword({required this.label, required this.password, required this.date});

  Map<String, dynamic> toJson() => {
    'label': label,
    'password': password,
    'date': date.toIso8601String(),
  };

  factory SavedPassword.fromJson(Map<String, dynamic> json) => SavedPassword(
    label: json['label'],
    password: json['password'],
    date: DateTime.parse(json['date']),
  );
}
