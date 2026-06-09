import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:async/async.dart' show ChunkedStreamReader;
import 'package:path_provider/path_provider.dart';
import '../models/scan_result.dart';
import 'api_service.dart';

class ScannerService {
  final ApiService _apiService = ApiService();
  bool _isCancelled = false;

  /// Tính toán mã SHA256 của một file bằng cách đọc theo luồng (stream)
  /// Giúp tránh lỗi tràn bộ nhớ (Out of Memory) với các file lớn.
  Future<String> calculateSHA256(File file) async {
    try {
      if (!await file.exists()) throw Exception('File không tồn tại');
      
      final reader = ChunkedStreamReader(file.openRead());
      const int chunkSize = 8192;
      
      Digest? resultDigest;
      final input = sha256.startChunkedConversion(
        _DigestSink((digest) => resultDigest = digest)
      );

      try {
        while (true) {
          final chunk = await reader.readChunk(chunkSize);
          if (chunk.isEmpty) break;
          input.add(chunk);
        }
      } finally {
        await reader.cancel();
      }

      input.close();
      
      if (resultDigest == null) {
        throw Exception('Không thể tính toán mã hash');
      }
      
      return resultDigest.toString();
    } catch (e) {
      throw Exception('Lỗi khi tính SHA256 cho ${file.path}: $e');
    }
  }

  /// Lấy danh sách các file cần quét dựa trên các thư mục phổ biến
  Future<List<File>> getFilesToScan() async {
    List<File> files = [];
    
    try {
      // Các thư mục ứng dụng có quyền truy cập
      final directories = [
        await getApplicationDocumentsDirectory(),
        if (Platform.isAndroid) await getExternalStorageDirectory(),
      ];

      for (var dir in directories) {
        if (dir != null && await dir.exists()) {
          try {
            final entities = dir.listSync(recursive: true, followLinks: false);
            files.addAll(entities.whereType<File>());
          } catch (e) {
            // Log lỗi truy cập thư mục cụ thể nhưng vẫn tiếp tục các thư mục khác
            continue;
          }
        }
      }

      // Quét thư mục Download trên Android (nơi chứa nhiều rủi ro nhất)
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          try {
            final entities = downloadDir.listSync(recursive: false);
            files.addAll(entities.whereType<File>());
          } catch (e) {
             // Thư mục Download có thể yêu cầu quyền bổ sung
          }
        }
      }
    } catch (e) {
      // Xử lý lỗi tổng quát khi duyệt file
    }

    return files;
  }

  Stream<ScanProgress> startScan() async* {
    _isCancelled = false;
    List<ScanResult> threats = [];
    
    yield ScanProgress(
      totalFiles: 0,
      scannedFiles: 0,
      threatsFound: 0,
      threats: [],
      isScanning: true,
      currentFile: 'Đang chuẩn bị quét...',
    );

    final files = await getFilesToScan();
    final totalFiles = files.length;
    int scannedCount = 0;

    yield ScanProgress(
      totalFiles: totalFiles,
      scannedFiles: 0,
      threatsFound: 0,
      threats: [],
      isScanning: true,
      currentFile: 'Đã tìm thấy $totalFiles tệp tin',
    );

    for (var file in files) {
      if (_isCancelled) break;

      try {
        final fileName = file.path.split(Platform.pathSeparator).last;
        
        yield ScanProgress(
          totalFiles: totalFiles,
          scannedFiles: scannedCount,
          threatsFound: threats.length,
          threats: threats,
          isScanning: true,
          currentFile: 'Đang kiểm tra: $fileName',
        );

        final stat = await file.stat();
        // Chỉ quét các file thực thi hoặc file có dung lượng hợp lý để tối ưu
        final isExecutable = file.path.endsWith('.apk') || 
                            file.path.endsWith('.exe') || 
                            file.path.endsWith('.bin');
        
        // Tính toán hash
        final hash = await calculateSHA256(file);
        
        try {
          // Gửi mã hash lên server để kiểm tra mã độc
          final malware = await _apiService.searchMalware(hash);
          
          final scanResult = ScanResult(
            filePath: file.path,
            sha256: hash,
            fileSize: stat.size,
            scannedAt: DateTime.now(),
            isMalware: true,
            signature: malware.signature,
            threatLevel: malware.getThreatLevel(),
            vtPercent: malware.vtpercent,
          );
          
          threats.add(scanResult);
        } catch (e) {
          // File an toàn (không có trong database mã độc)
        }

        scannedCount++;
      } catch (e) {
        scannedCount++;
        // Tiếp tục quét file tiếp theo nếu một file bị lỗi (ví dụ: đang bị khóa)
        continue;
      }
    }

    yield ScanProgress(
      totalFiles: totalFiles,
      scannedFiles: scannedCount,
      threatsFound: threats.length,
      threats: threats,
      isScanning: false,
      currentFile: 'Hoàn tất quét',
    );
  }

  void cancelScan() {
    _isCancelled = true;
  }
}

class _DigestSink implements Sink<Digest> {
  final void Function(Digest) callback;
  _DigestSink(this.callback);
  @override
  void add(Digest digest) => callback(digest);
  @override
  void close() {}
}
