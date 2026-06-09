import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/chat_service.dart';
import 'services/schedule_service.dart';
import 'services/app_scanner_service.dart';
import 'services/config_service.dart';
import 'services/api_service.dart';
import 'screens/home_menu_screen.dart';
import 'screens/home_screen.dart';
import 'screens/password_checker_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/system_scan_screen.dart';
import 'screens/virus_scanner_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/app_analysis_screen.dart';
import 'screens/schedule_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final configService = ConfigService();
  await configService.loadConfig();
  
  final chatService = ChatService();
  await chatService.init();
  
  final scheduleService = ScheduleService();
  await scheduleService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider<ConfigService>.value(value: configService),
        Provider<ChatService>.value(value: chatService),
        Provider<ScheduleService>.value(value: scheduleService),
        Provider<AppScannerService>(create: (_) => AppScannerService()),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'MaiAntivirus Pro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            brightness: themeService.isDarkMode ? Brightness.dark : Brightness.light,
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeMenuScreen(),
            '/home': (context) => const HomeScreen(),
            '/password': (context) => const PasswordCheckerScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/scan': (context) => const SystemScanScreen(),
            '/virus': (context) => const VirusScannerScreen(),
            '/chat': (context) => const AiChatScreen(),
            '/app-analysis': (context) => const AppAnalysisScreen(),
            '/schedule': (context) => const ScheduleSettingsScreen(),
          },
        );
      },
    );
  }
}
