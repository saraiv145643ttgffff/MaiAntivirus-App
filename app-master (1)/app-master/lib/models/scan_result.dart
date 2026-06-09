class ScanResult {
  final String filePath;
  final String sha256;
  final int fileSize;
  final DateTime scannedAt;
  bool? isMalware;
  String? threatLevel;
  String? signature;
  int? vtPercent;

  ScanResult({
    required this.filePath,
    required this.sha256,
    required this.fileSize,
    required this.scannedAt,
    this.isMalware,
    this.threatLevel,
    this.signature,
    this.vtPercent,
  });

  String get fileName {
    return filePath.split('/').last;
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'sha256': sha256,
      'fileSize': fileSize,
      'scannedAt': scannedAt.toIso8601String(),
      'isMalware': isMalware,
      'threatLevel': threatLevel,
      'signature': signature,
      'vtPercent': vtPercent,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      filePath: json['filePath'] as String,
      sha256: json['sha256'] as String,
      fileSize: json['fileSize'] as int,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      isMalware: json['isMalware'] as bool?,
      threatLevel: json['threatLevel'] as String?,
      signature: json['signature'] as String?,
      vtPercent: json['vtPercent'] as int?,
    );
  }
}

class ScanProgress {
  final int totalFiles;
  final int scannedFiles;
  final int threatsFound;
  final List<ScanResult> threats;
  final bool isScanning;
  final String? currentFile;

  ScanProgress({
    required this.totalFiles,
    required this.scannedFiles,
    required this.threatsFound,
    required this.threats,
    required this.isScanning,
    this.currentFile,
  });

  double get progress {
    if (totalFiles == 0) return 0.0;
    return scannedFiles / totalFiles;
  }
}
