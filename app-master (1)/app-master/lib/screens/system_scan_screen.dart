import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/scanner_service.dart';
import '../services/theme_service.dart';
import '../models/scan_result.dart';

class SystemScanScreen extends StatefulWidget {
  const SystemScanScreen({super.key});

  @override
  State<SystemScanScreen> createState() => _SystemScanScreenState();
}

class _SystemScanScreenState extends State<SystemScanScreen> with WidgetsBindingObserver {
  final ScannerService _scannerService = ScannerService();
  bool _isScanning = false;
  int _totalFiles = 0;
  int _scannedFiles = 0;
  int _threatsFound = 0;
  String? _currentFile;
  List<ScanResult> _threats = [];
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.cancelScan();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    bool granted = false;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      granted = status.isGranted;
      if (!granted) {
        granted = await Permission.storage.isGranted;
      }
    } else {
      granted = await Permission.storage.isGranted;
    }
    
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
    }
  }

  void _handlePermissionGuide() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: Color(0xFFEC4899)),
            const SizedBox(width: 10),
            Text('Yêu Cầu Cấp Quyền', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Để bảo vệ máy khỏi virus, bạn cần cấp quyền "Quản lý tệp" cho ứng dụng này.',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text('• Bước 1: Nhấn "Mở Cài Đặt"\n• Bước 2: Chọn mục "Quyền" hoặc "Quản lý tệp"\n• Bước 3: Bật "Cho phép tất cả tệp tin"', 
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mở trang cài đặt ứng dụng để bạn tự chấp nhận
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
            child: Text('Mở Cài Đặt', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _totalFiles = 0;
      _scannedFiles = 0;
      _threatsFound = 0;
      _threats = [];
      _currentFile = null;
    });

    await for (final progress in _scannerService.startScan()) {
      if (mounted) {
        setState(() {
          _totalFiles = progress.totalFiles;
          _scannedFiles = progress.scannedFiles;
          _threatsFound = progress.threatsFound;
          _threats = progress.threats;
          _currentFile = progress.currentFile;
          _isScanning = progress.isScanning;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeService>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
        title: Text('Bảo Vệ Máy', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: _hasPermission ? _buildScannerUI(isDark) : _buildPermissionRequiredUI(isDark),
    );
  }

  /// Giao diện khi chưa được cấp quyền
  Widget _buildPermissionRequiredUI(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_shared_rounded, size: 100, color: Colors.orangeAccent),
            const SizedBox(height: 32),
            Text(
              'Chưa Có Quyền Truy Cập',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              'Ứng dụng cần quyền quản lý tệp để quét mã độc ẩn trong máy. Bạn cần vào Cài đặt để bật quyền này.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handlePermissionGuide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CẤP QUYỀN TRONG CÀI ĐẶT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện quét thực tế (chỉ hiện khi đã có quyền)
  Widget _buildScannerUI(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScanHero(isDark),
          if (_isScanning) ...[
            const SizedBox(height: 24),
            _buildProgressSection(isDark),
          ],
          if (_scannedFiles > 0) ...[
            const SizedBox(height: 24),
            _buildStatsSection(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildScanHero(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFEC4899).withOpacity(0.4), const Color(0xFFF43F5E).withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_rounded, size: 80, color: Color(0xFFEC4899)),
          const SizedBox(height: 24),
          Text(
            _isScanning ? 'Đang Phân Tích...' : 'Hệ Thống Sẵn Sàng',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
              ),
              child: Text(
                _isScanning ? 'ĐANG QUÉT...' : 'BẮT ĐẦU QUÉT NGAY',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    final progress = _totalFiles > 0 ? _scannedFiles / _totalFiles : 0.0;
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(4), color: const Color(0xFFEC4899)),
        const SizedBox(height: 12),
        Text('Tiến độ: $_scannedFiles / $_totalFiles tệp tin', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatBox('An toàn', '$_scannedFiles', Colors.blue),
        _buildStatBox('Phát hiện', '$_threatsFound', Colors.red),
      ],
    );
  }

  Widget _buildStatBox(String label, String val, Color col) {
    return Column(children: [Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: col)), Text(label, style: const TextStyle(color: Colors.grey))]);
  }
}
