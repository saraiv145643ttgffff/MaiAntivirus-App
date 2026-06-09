import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../services/password_vault_service.dart';
import '../models/saved_password.dart';
import 'password_result_screen.dart';

class PasswordCheckerScreen extends StatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  State<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends State<PasswordCheckerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final PasswordVaultService _vaultService = PasswordVaultService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  List<SavedPassword> _savedPasswords = [];
  final Map<int, bool> _visibilityMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedPasswords();
  }

  Future<void> _loadSavedPasswords() async {
    final list = await _vaultService.getSavedPasswords();
    setState(() => _savedPasswords = list);
  }

  Future<void> _handleCheck() async {
    if (_passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.checkPassword(_passwordController.text);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PasswordResultScreen(result: result)),
        ).then((_) => _loadSavedPasswords());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi Server: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeService>(context).isDarkMode;
    final bgColor = const Color(0xFF0A0E21);
    final cardColor = const Color(0xFF1D1F33);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Kiểm Tra Độ Mạnh Mật Khẩu', 
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () => Navigator.pushNamed(context, '/settings'))],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Kiểm Tra'),
            Tab(text: 'Ví Mật Khẩu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCheckerTab(cardColor),
          _buildVaultTab(cardColor),
        ],
      ),
    );
  }

  Widget _buildCheckerTab(Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.lock_outline, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Text('Kiểm Tra Độ Mạnh Mật Khẩu', 
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Kiểm tra xem mật khẩu của bạn có yếu và phổ biến không', 
            style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập mật khẩu để kiểm tra',
                hintStyle: const TextStyle(color: Colors.white24),
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white38),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleCheck,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.verified_user_outlined),
              label: Text(_isLoading ? 'Đang Kiểm Tra...' : 'Kiểm Tra Mật Khẩu', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildHowItWorks(cardColor),
          const SizedBox(height: 20),
          _buildSecurityBox(),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.info_outline, color: Colors.blue, size: 20), 
            SizedBox(width: 10), 
            Text('Cách hoạt động', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 15),
          _buildStep('Nhập bất kỳ mật khẩu nào bạn muốn kiểm tra'),
          _buildStep('So sánh với hơn 14 triệu mật khẩu yếu phổ biến'),
          _buildStep('Nhận phản hồi ngay lập tức về độ mạnh mật khẩu'),
          _buildStep('Mật khẩu của bạn không bao giờ được lưu trữ'),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Color(0xFF6366F1), size: 16), 
        const SizedBox(width: 10), 
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)))
      ]),
    );
  }

  Widget _buildSecurityBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.amber.withOpacity(0.3))
      ),
      child: Row(children: const [
        Icon(Icons.security, color: Colors.amber, size: 20), 
        SizedBox(width: 12), 
        Expanded(child: Text('Bảo mật: Chỉ mật khẩu của bạn được gửi để kiểm tra. Không thu thập dữ liệu cá nhân.', 
          style: TextStyle(color: Colors.amber, fontSize: 11)))
      ]),
    );
  }

  Widget _buildVaultTab(Color cardColor) {
    if (_savedPasswords.isEmpty) return const Center(child: Text('Bạn chưa lưu mật khẩu nào.', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPasswords.length,
      itemBuilder: (context, index) {
        final item = _savedPasswords[index];
        final isVisible = _visibilityMap[index] ?? false;
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF6366F1), child: Icon(Icons.vpn_key, color: Colors.white, size: 20)),
            title: Text(item.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(isVisible ? item.password : '••••••••', 
              style: TextStyle(color: isVisible ? Colors.greenAccent : Colors.grey, fontFamily: 'monospace')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _visibilityMap[index] = !isVisible),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    await _vaultService.deletePassword(index);
                    _loadSavedPasswords();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
