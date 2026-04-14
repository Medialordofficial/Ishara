import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'conversation_screen.dart';
import 'emergency_screen.dart';
import 'learn_signs_screen.dart';
import 'settings_screen.dart';
import 'sound_awareness_screen.dart';
import 'world_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  List<_ModeEntry> get _modeEntries => [
    _ModeEntry(
      title: AppStrings.conversationMode,
      icon: Icons.chat_bubble_outline_rounded,
      builder: () => const ConversationScreen(),
    ),
    _ModeEntry(
      title: AppStrings.soundAwarenessMode,
      icon: Icons.hearing_rounded,
      builder: () => const SoundAwarenessScreen(),
    ),
    _ModeEntry(
      title: AppStrings.emergencyMode,
      icon: Icons.emergency_outlined,
      builder: () => const EmergencyScreen(),
    ),
    _ModeEntry(
      title: AppStrings.worldReaderMode,
      icon: Icons.camera_alt_outlined,
      builder: () => const WorldReaderScreen(),
    ),
    _ModeEntry(
      title: AppStrings.learnSignsMode,
      icon: Icons.school_outlined,
      builder: () => const LearnSignsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildPremiumHomeTab(context),
            _buildSearchTab(context),
            const SettingsScreen(showAppBar: false),
          ],
        ),
      ),
      bottomNavigationBar: _buildPremiumBottomNav(),
    );
  }

  Widget _buildPremiumBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppColors.premiumShadows,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _NavBarItem(
            icon: Icons.search_rounded,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _NavBarItem(
            icon: Icons.settings_rounded,
            isSelected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHomeTab(BuildContext context) {
    final modes = _modeEntries;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Premium Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppColors.premiumShadows,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/ishara_logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Floating Circular Action Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 32,
            runSpacing: 40,
            children: modes
                .map(
                  (mode) => _PremiumCircularButton(
                    entry: mode,
                    onTap: () => _openScreen(mode),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return Center(
      child: Text(
        'Search coming soon',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  void _openScreen(_ModeEntry entry) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            entry.builder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(opacity: fade, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _ModeEntry {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  const _ModeEntry({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}

class _PremiumCircularButton extends StatelessWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;

  const _PremiumCircularButton({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppColors.premiumShadows,
            ),
            child: Icon(entry.icon, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            entry.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
