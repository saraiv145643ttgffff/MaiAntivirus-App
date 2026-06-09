import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/malware_sample.dart';
import '../services/password_vault_service.dart';

class PasswordResultScreen extends StatelessWidget {
  final PasswordCheckResult result;
  final PasswordVaultService _vaultService = PasswordVaultService();

  PasswordResultScreen({super.key, required this.result});

  void _showSaveToVaultDialog(BuildContext context) {
    final TextEditingController labelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1F33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Lưu vào Ví',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập tên nhãn để bạn dễ nhớ tài khoản này:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: labelController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ví dụ: Facebook, Gmail cá nhân...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF0A0E21),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final label = labelController.text.trim();
              if (label.isNotEmpty) {
                await _vaultService.savePassword(label, result.password);
                if (context.mounted) {
                  Navigator.pop(context); // Đóng dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu mật khẩu vào Ví an toàn!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lưu ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeak = result.isWeak;
    final Color mainColor = isWeak ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Phân Tích Mật Khẩu',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: mainColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    isWeak ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                    size: 50,
                    color: mainColor,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isWeak ? 'Mật Khẩu Yếu!' : 'Mật Khẩu Mạnh!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isWeak 
                        ? 'Cảnh báo: Mật khẩu này dễ bị tấn công brute-force hoặc có trong danh sách rò rỉ.' 
                        : 'Tuyệt vời! Mật khẩu này đạt chuẩn an toàn cao.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            // Nút Lưu vào ví nếu mật khẩu Mạnh
            if (!isWeak) ...[
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _showSaveToVaultDialog(context),
                  icon: const Icon(Icons.vpn_key_outlined, color: Colors.white),
                  label: const Text(
                    'LƯU VÀO VÍ ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 35),
            _buildSectionTitle('Chi Tiết Phân Tích'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1F33),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                result.message,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Các Chỉ Số An Toàn'),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D1F33),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildAnalysisRow('Độ dài tối thiểu (12)', '${result.length} ký tự', result.isLengthSufficient),
                  _buildAnalysisRow('Chữ cái in hoa', result.hasUppercase() ? 'Đạt' : 'Không có', result.hasUppercase()),
                  _buildAnalysisRow('Chữ cái thường', result.hasLowercase() ? 'Đạt' : 'Không có', result.hasLowercase()),
                  _buildAnalysisRow('Chữ số (0-9)', result.hasDigits() ? 'Đạt' : 'Không có', result.hasDigits()),
                  _buildAnalysisRow('Ký tự đặc biệt (!@#)', result.hasSpecialChars() ? 'Đạt' : 'Không có', result.hasSpecialChars(), isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Khuyến Nghị Bảo Mật'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1F33),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildTipItem('Sử dụng kết hợp nhiều loại ký tự khác nhau'),
                  _buildTipItem('Không sử dụng lại mật khẩu cũ cho nhiều dịch vụ'),
                  _buildTipItem('Thay đổi mật khẩu định kỳ sau mỗi 3-6 tháng'),
                  _buildTipItem('Kích hoạt xác thực 2 lớp (2FA) nếu có thể'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, bool success, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: success ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value, style: TextStyle(color: success ? Colors.white : Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13))),
        ],
      ),
    );
  }
}
