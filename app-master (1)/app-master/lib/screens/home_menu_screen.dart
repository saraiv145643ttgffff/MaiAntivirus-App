import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1D1F33) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MaiAntivirus ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Xin chào,',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
            Text(
              'Hệ thống của bạn an toàn',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            
            _buildFeatureCard(
              context,
              'Quét Virus & Tệp Tin',
              'Quét toàn bộ thiết bị để tìm mã độc',
              Icons.shield_outlined,
              const Color(0xFFEB1555),
              '/virus',
              cardColor,
              isDark,
            ),
            
            _buildFeatureCard(
              context,
              'Phân Tích Ứng Dụng',
              'Kiểm tra quyền hạn các app đã cài đặt',
              Icons.grid_view_rounded,
              const Color(0xFFFF9800),
              '/app-analysis',
              cardColor,
              isDark,
            ),
            
            _buildFeatureCard(
              context,
              'Trợ Lý AI Bảo Mật',
              'Hỏi đáp chuyên gia AI về virus',
              Icons.smart_toy_outlined,
              const Color(0xFF00C853),
              '/chat',
              cardColor,
              isDark,
            ),
            
            _buildFeatureCard(
              context,
              'Kiểm Tra Mật Khẩu',
              'Đánh giá độ an toàn mật khẩu của bạn',
              Icons.lock_outline,
              const Color(0xFF7C4DFF),
              '/password',
              cardColor,
              isDark,
            ),
            
            _buildFeatureCard(
              context,
              'Lịch Quét Định Kỳ',
              'Thiết lập tự động quét máy hàng tuần',
              Icons.history_rounded,
              const Color(0xFF2196F3),
              '/schedule',
              cardColor,
              isDark,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    String route,
    Color cardColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
