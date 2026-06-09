import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/schedule_service.dart';
import '../services/theme_service.dart';
import '../models/schedule_config.dart';

class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
  late bool _isEnabled;
  late int _intervalDays;
  late String _preferredTime;

  @override
  void initState() {
    super.initState();
    final scheduleService = Provider.of<ScheduleService>(context, listen: false);
    _isEnabled = scheduleService.config.isEnabled;
    _intervalDays = scheduleService.config.intervalDays;
    _preferredTime = scheduleService.config.preferredTime;
  }

  Future<void> _saveSettings() async {
    final scheduleService = Provider.of<ScheduleService>(context, listen: false);
    final newConfig = ScheduleConfig(
      isEnabled: _isEnabled,
      intervalDays: _intervalDays,
      lastScan: scheduleService.config.lastScan,
      preferredTime: _preferredTime,
    );
    await scheduleService.saveConfig(newConfig);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cấu hình lịch quét')),
      );
    }
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
          'Lịch Quét Định Kỳ',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildToggleCard(isDark, cardColor),
            const SizedBox(height: 16),
            if (_isEnabled) ...[
              _buildIntervalCard(isDark, cardColor),
              const SizedBox(height: 16),
              _buildTimeCard(isDark, cardColor),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Lưu Cài Đặt',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF6366F1)),
              const SizedBox(width: 16),
              Text(
                'Tự động quét',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) => setState(() => _isEnabled = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalCard(bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tần suất quét',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<int>(
            value: _intervalDays,
            isExpanded: true,
            dropdownColor: cardColor,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Hàng ngày')),
              DropdownMenuItem(value: 7, child: Text('Hàng tuần')),
              DropdownMenuItem(value: 30, child: Text('Hàng tháng')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _intervalDays = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: int.parse(_preferredTime.split(':')[0]),
              minute: int.parse(_preferredTime.split(':')[1]),
            ),
          );
          if (time != null) {
            setState(() {
              _preferredTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giờ bắt đầu quét',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              _preferredTime,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
