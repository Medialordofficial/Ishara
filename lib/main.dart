import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

/// Global notifier so any screen can toggle dark mode.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await NotificationService().init();

  // Restore persisted theme preference.
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('ishara_theme') ?? 'system';
  themeNotifier.value = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  final onboarded = prefs.getBool('ishara_onboarded') ?? false;

  runApp(IsharaApp(showOnboarding: !onboarded));
}

class IsharaApp extends StatelessWidget {
  const IsharaApp({super.key, this.showOnboarding = false});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
        );
      },
    );
  }
}
