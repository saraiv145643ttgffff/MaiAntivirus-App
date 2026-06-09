class AppInfo {
  final String name;
  final String packageName;
  final String version;
  final bool isSystemApp;
  final List<String> permissions;
  final DateTime installedAt;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.version,
    required this.isSystemApp,
    required this.permissions,
    required this.installedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'packageName': packageName,
        'version': version,
        'isSystemApp': isSystemApp,
        'permissions': permissions,
        'installedAt': installedAt.toIso8601String(),
      };

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        name: json['name'],
        packageName: json['packageName'],
        version: json['version'],
        isSystemApp: json['isSystemApp'],
        permissions: List<String>.from(json['permissions']),
        installedAt: DateTime.parse(json['installedAt']),
      );

  bool get hasSensitivePermissions {
    const sensitive = ['CAMERA', 'LOCATION', 'CONTACTS', 'SMS', 'MICROPHONE'];
    return permissions.any((p) => sensitive.any((s) => p.toUpperCase().contains(s)));
  }
}
