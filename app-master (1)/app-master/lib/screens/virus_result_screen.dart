import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/malware_sample.dart';
import '../services/theme_service.dart';

class VirusResultScreen extends StatelessWidget {
  final MalwareSample malware;

  const VirusResultScreen({super.key, required this.malware});

  Color _getThreatColor() {
    final level = malware.getThreatLevel();
    switch (level) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi Tiết Phần Mềm Độc Hại',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThreatCard(isDark),
            const SizedBox(height: 24),
            _buildSection('Thông Tin Tệp', [
              _buildDetailRow('Tên Tệp', malware.fileName ?? 'N/A', Icons.insert_drive_file, isDark),
              _buildDetailRow('Loại Tệp', malware.fileTypeGuess ?? 'N/A', Icons.category, isDark),
              _buildDetailRow('Loại MIME', malware.mimeType ?? 'N/A', Icons.code, isDark),
              _buildDetailRow(
                'Lần Đầu Thấy',
                malware.firstSeenUtc != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(malware.firstSeenUtc!)
                    : 'N/A',
                Icons.access_time,
                isDark,
              ),
              _buildDetailRow('Người Báo Cáo', malware.reporter ?? 'N/A', Icons.person, isDark),
            ], isDark),
            const SizedBox(height: 24),
            _buildSection('Thông Tin Phát Hiện', [
              _buildDetailRow('Chữ Ký', malware.signature ?? 'N/A', Icons.fingerprint, isDark),
              _buildDetailRow('ClamAV', malware.clamav ?? 'N/A', Icons.verified_user, isDark),
              _buildDetailRow(
                'VirusTotal',
                malware.vtpercent != null ? '${malware.vtpercent}%' : 'N/A',
                Icons.analytics,
                isDark,
              ),
            ], isDark),
            const SizedBox(height: 24),
            _buildSection('Giá Trị Băm', [
              _buildHashRow('SHA256', malware.sha256Hash, isDark),
              _buildHashRow('MD5', malware.md5Hash ?? 'N/A', isDark),
              _buildHashRow('SHA1', malware.sha1Hash ?? 'N/A', isDark),
              _buildHashRow('ImpHash', malware.imphash ?? 'N/A', isDark),
            ], isDark),
            const SizedBox(height: 24),
            _buildSection('Băm Nâng Cao', [
              _buildHashRow('SSDEEP', malware.ssdeep ?? 'N/A', isDark),
              _buildHashRow('TLSH', malware.tlsh ?? 'N/A', isDark),
            ], isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatCard(bool isDark) {
    final threatLevel = malware.getThreatLevel();
    final threatColor = _getThreatColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            threatColor.withOpacity(0.3),
            threatColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: threatColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 64,
            color: threatColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Mức Độ Nguy Hiểm: $threatLevel',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: threatColor,
            ),
          ),
          if (malware.vtpercent != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Tỷ Lệ Phát Hiện ${malware.vtpercent}%',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.3)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEC4899), size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.robotoMono(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                color: const Color(0xFFEC4899),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                },
                tooltip: 'Sao chép',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: GoogleFonts.robotoMono(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
