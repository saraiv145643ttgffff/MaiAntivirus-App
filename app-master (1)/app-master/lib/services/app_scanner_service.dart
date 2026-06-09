import 'dart:async';
import '../models/app_info.dart';

class AppScannerService {
  Future<List<AppInfo>> getInstalledApps() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      AppInfo(
        name: 'Facebook',
        packageName: 'com.facebook.katana',
        version: '450.0.0.1',
        isSystemApp: false,
        permissions: ['CAMERA', 'LOCATION', 'CONTACTS', 'MICROPHONE', 'STORAGE'],
        installedAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      AppInfo(
        name: 'Zalo',
        packageName: 'com.zing.zalo',
        version: '24.01.01',
        isSystemApp: false,
        permissions: ['CAMERA', 'CONTACTS', 'STORAGE'],
        installedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      AppInfo(
        name: 'Hệ thống Android',
        packageName: 'android.system',
        version: '14.0',
        isSystemApp: true,
        permissions: ['ALL'],
        installedAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      AppInfo(
        name: 'Phần mềm lạ',
        packageName: 'com.unknown.riskyapp',
        version: '1.0',
        isSystemApp: false,
        permissions: ['SMS', 'LOCATION', 'RECORD_AUDIO'],
        installedAt: DateTime.now(),
      ),
    ];
  }

  List<AppInfo> findRiskyApps(List<AppInfo> apps) {
    return apps.where((app) => !app.isSystemApp && app.hasSensitivePermissions).toList();
  }
}
