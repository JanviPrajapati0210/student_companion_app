import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'services/database_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

// Practical 5: SharedPreferences Theme & Preferences Controller
// - Restores saved theme mode when app starts
// - Notifies entire widget tree dynamically when theme is switched
class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> init() async {
    final storage = StorageService();
    final mode = await storage.getThemeMode();
    themeMode.value = (mode == 'dark') ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme(bool isDark) async {
    final storage = StorageService();
    await storage.setThemeMode(isDark ? 'dark' : 'light');
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage, SQLite database, and load saved preferences
  await StorageService().init();
  await DatabaseService().init();
  await ThemeController.init();

  // Set Android system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartStudentCompanionApp());
}

class SmartStudentCompanionApp extends StatelessWidget {
  const SmartStudentCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
