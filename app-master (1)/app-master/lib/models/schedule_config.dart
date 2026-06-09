class ScheduleConfig {
  final bool isEnabled;
  final int intervalDays;
  final DateTime lastScan;
  final String preferredTime;

  ScheduleConfig({
    this.isEnabled = false,
    this.intervalDays = 7,
    DateTime? lastScan,
    this.preferredTime = "21:00",
  }) : lastScan = lastScan ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'intervalDays': intervalDays,
        'lastScan': lastScan.toIso8601String(),
        'preferredTime': preferredTime,
      };

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) => ScheduleConfig(
        isEnabled: json['isEnabled'] ?? false,
        intervalDays: json['intervalDays'] ?? 7,
        lastScan: DateTime.parse(json['lastScan']),
        preferredTime: json['preferredTime'] ?? "21:00",
      );
}
