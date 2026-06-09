import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_scanner_service.dart';
import '../services/theme_service.dart';
import '../models/app_info.dart';

class AppAnalysisScreen extends StatefulWidget {
  const AppAnalysisScreen({super.key});

  @override
  State<AppAnalysisScreen> createState() => _AppAnalysisScreenState();
}

class _AppAnalysisScreenState extends State<AppAnalysisScreen> {
  bool _isLoading = true;
  List<AppInfo> _allApps = [];
  List<AppInfo> _riskyApps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final scanner = Provider.of<AppScannerService>(context, listen: false);
    final apps = await scanner.getInstalledApps();
    final risky = scanner.findRiskyApps(apps);

    setState(() {
      _allApps = apps;
      _riskyApps = risky;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeService>(context).isDarkMode;
    final bgColor = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1A1F3A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Phân Tích Ứng Dụng',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(isDark),
                  const SizedBox(height: 24),
                  Text(
                    'Ứng dụng có rủi ro cao',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._riskyApps.map((app) => _buildAppTile(app, isDark, true)),
                  const SizedBox(height: 24),
                  Text(
                    'Tất cả ứng dụng',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._allApps.map((app) => _buildAppTile(app, isDark, false)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng số ứng dụng: ${_allApps.length}',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Ứng dụng nguy hiểm: ${_riskyApps.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppTile(AppInfo app, bool isDark, bool isRisky) {
    final cardColor = isDark ? const Color(0xFF1A1F3A) : Colors.white;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isRisky ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isRisky ? Colors.red : Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isRisky ? Icons.warning_amber_rounded : Icons.android,
            color: isRisky ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          app.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          'Quyền: ${app.permissions.take(3).join(", ")}...',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showAppDetails(app),
      ),
    );
  }

  void _showAppDetails(AppInfo app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Provider.of<ThemeService>(context).isDarkMode 
              ? const Color(0xFF1A1F3A) 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.name,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Package: ${app.packageName}', style: GoogleFonts.poppins(color: Colors.grey)),
            const Divider(height: 32),
            Text(
              'Các quyền truy cập:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: app.permissions.map((p) => Chip(
                label: Text(p, style: const TextStyle(fontSize: 10)),
                backgroundColor: Colors.red.withOpacity(0.1),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đã hiểu', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
