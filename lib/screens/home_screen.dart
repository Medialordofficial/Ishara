import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'conversation_screen.dart';
import 'sound_awareness_screen.dart';
import 'emergency_screen.dart';
import 'world_reader_screen.dart';
import 'learn_signs_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo and title
              Image.asset('assets/images/ishara_logo.png', height: 100),
              const SizedBox(height: 12),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.fullTagline,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Mode grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _ModeCard(
                      icon: Icons.sign_language,
                      label: AppStrings.conversationMode,
                      subtitle: 'Sign ↔ Speech',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConversationScreen(),
                        ),
                      ),
                    ),
                    _ModeCard(
                      icon: Icons.hearing,
                      label: AppStrings.soundAwarenessMode,
                      subtitle: 'Be your ears',
                      color: AppColors.info,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SoundAwarenessScreen(),
                        ),
                      ),
                    ),
                    _ModeCard(
                      icon: Icons.emergency,
                      label: AppStrings.emergencyMode,
                      subtitle: 'One-tap help',
                      color: AppColors.danger,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyScreen(),
                        ),
                      ),
                    ),
                    _ModeCard(
                      icon: Icons.document_scanner,
                      label: AppStrings.worldReaderMode,
                      subtitle: 'Read anything',
                      color: AppColors.success,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorldReaderScreen(),
                        ),
                      ),
                    ),
                    _ModeCard(
                      icon: Icons.school,
                      label: AppStrings.learnSignsMode,
                      subtitle: 'Bridge the gap',
                      color: AppColors.warning,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LearnSignsScreen(),
                        ),
                      ),
                    ),
                    _ModeCard(
                      icon: Icons.settings,
                      label: 'Settings',
                      subtitle: 'Server & prefs',
                      color: AppColors.textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
