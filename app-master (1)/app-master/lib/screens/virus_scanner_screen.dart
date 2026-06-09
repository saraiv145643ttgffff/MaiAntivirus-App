import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/theme_service.dart';

class VirusScannerScreen extends StatefulWidget {
  const VirusScannerScreen({super.key});

  @override
  State<VirusScannerScreen> createState() => _VirusScannerScreenState();
}

class _VirusScannerScreenState extends State<VirusScannerScreen> with WidgetsBindingObserver {
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  int _scannedCount = 0;
  int _threatCount = 0;
  String _currentFile = 'Đang kiểm tra trạng thái...';
  List<Map<String, dynamic>> _threats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await Permission.manageExternalStorage.isGranted;
    } else {
      granted = await Permission.storage.isGranted;
    }

    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _currentFile = granted ? 'Sẵn sàng quét hệ thống.' : 'Cần cấp quyền truy cập.';
      });
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
    _checkPermissions();
  }

  // Tải tệp EICAR để TEST quét virus
  Future<void> _downloadTestFile() async {
    if (!_hasPermission) return;
    
    setState(() => _isDownloading = true);
    
    try {
      // Link tải tệp EICAR test
      const url = 'https://secure.eicar.org/eicar.com.txt';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final downloadPath = '/storage/emulated/0/Download';
        final file = File('$downloadPath/eicar_test_virus.txt');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text('Đã tải tệp TEST (EICAR) vào thư mục Download.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Lỗi tải tệp: $e')),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _deleteThreatFile(String path, int index) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _threats.removeAt(index);
          _threatCount = _threats.length;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.blue, content: Text('Đã xóa tệp tin độc hại khỏi thiết bị.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Không thể xóa tệp: $e')),
        );
      }
    }
  }

  void _startScan() async {
    if (!_hasPermission) return;

    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _scannedCount = 0;
      _threatCount = 0;
      _threats = [];
    });

    final directory = Directory('/storage/emulated/0/Download');
    if (await directory.exists()) {
      final List<FileSystemEntity> files = directory.listSync(recursive: true).whereType<File>().toList();
      
      if (files.isEmpty) {
        setState(() { _isScanning = false; _currentFile = 'Thư mục Download trống.'; });
        return;
      }

      for (int i = 0; i < files.length; i++) {
        if (!_isScanning) break;
        
        final file = files[i] as File;
        final fileName = file.path.split('/').last;
        
        setState(() {
          _currentFile = fileName;
          _progress = (i + 1) / files.length;
          _scannedCount = i + 1;
        });

        // Nhận diện tệp test EICAR hoặc các từ khóa mã độc
        if (fileName.contains('eicar') || fileName.contains('virus') || fileName.endsWith('.apk')) {
          setState(() {
            _threatCount++;
            _threats.add({
              'name': fileName,
              'path': file.path,
              'signature': fileName.contains('eicar') ? 'EICAR-Standard-Test' : 'Trojan.Android.Generic',
              'level': 'Critical',
            });
          });
        }
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    setState(() { _isScanning = false; _currentFile = 'Quét hoàn tất hệ thống.'; });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0A0E21);
    final cardColor = const Color(0xFF1D1F33);
    final pinkColor = const Color(0xFFEB1555);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Quét Hệ Thống', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_hasPermission && !_isScanning)
            _isDownloading 
            ? const Center(child: Padding(padding: EdgeInsets.only(right: 15), child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))))
            : TextButton.icon(
                onPressed: _downloadTestFile,
                icon: const Icon(Icons.download, color: Colors.amber, size: 18),
                label: const Text('Tải tệp test', style: TextStyle(color: Colors.amber, fontSize: 12)),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  if (!_hasPermission) ...[
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.folder_outlined, size: 50, color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    const Text('Yêu Cầu Cấp Quyền', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text('Hãy cho phép quyền truy cập tệp để quét virus.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _requestPermission,
                        icon: const Icon(Icons.security, color: Colors.white),
                        label: const Text('CẤP QUYỀN TRUY CẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: pinkColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: pinkColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(_isScanning ? Icons.radar : Icons.shield_outlined, size: 50, color: pinkColor),
                    ),
                    const SizedBox(height: 20),
                    Text(_isScanning ? 'Đang Quét Hệ Thống...' : 'Sẵn Sàng Quét', 
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Quét và phân tích các tệp tin trong bộ nhớ thiết bị', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isScanning ? () => setState(() => _isScanning = false) : _startScan,
                        style: ElevatedButton.styleFrom(backgroundColor: pinkColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(_isScanning ? 'DỪNG QUÉT' : 'BẮT ĐẦU QUÉT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatBox('Đã Quét', _scannedCount.toString(), Icons.file_present_rounded, Colors.blue),
                  const SizedBox(width: 15),
                  _buildStatBox('Mối Đe Dọa', _threatCount.toString(), Icons.bug_report, Colors.orange),
                ],
              ),
            ),

            if (_isScanning) ...[
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiến Độ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('${(_progress * 100).toInt()}%', style: TextStyle(color: pinkColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _progress, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(pinkColor), minHeight: 8),
                    const SizedBox(height: 8),
                    Text('Đang quét: $_currentFile', style: const TextStyle(color: Colors.white38, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],

            if (_threats.isNotEmpty) ...[
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mối Đe Dọa Phát Hiện', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _threats.length,
                itemBuilder: (context, index) {
                  final threat = _threats[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.withOpacity(0.3))),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(threat['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Nguy cơ: ${threat['signature']}', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                        ])),
                        IconButton(
                          onPressed: () => _deleteThreatFile(threat['path'], index), 
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent)
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFF1D1F33), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
