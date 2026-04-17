import 'package:flutter/material.dart';
import '../data/sign_dictionary.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'ai_chat_screen.dart';
import 'conversation_screen.dart';
import 'emergency_screen.dart';
import 'learn_signs_screen.dart';
import 'settings_screen.dart';
import 'sign_dictionary_screen.dart';
import 'sound_awareness_screen.dart';
import 'text_chat_screen.dart';
import 'type_to_speak_screen.dart';
import 'world_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();
  bool _serverOnline = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    final ok = await _api.ping();
    if (mounted) setState(() => _serverOnline = ok);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    _ModeEntry(
      title: 'Type to Speak',
      icon: Icons.record_voice_over_rounded,
      builder: () => const TypeToSpeakScreen(),
    ),
    _ModeEntry(
      title: 'Text Chat',
      icon: Icons.chat_rounded,
      builder: () => const TextChatScreen(),
    ),
    _ModeEntry(
      title: 'Sign Dictionary',
      icon: Icons.menu_book_rounded,
      builder: () => const SignDictionaryScreen(),
    ),
    _ModeEntry(
      title: 'Ishara AI',
      icon: Icons.smart_toy_rounded,
      builder: () => const AiChatScreen(),
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
            label: 'Home',
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _NavBarItem(
            icon: Icons.search_rounded,
            label: 'Sign Dictionary',
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _NavBarItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
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
                      semanticLabel: 'Ishara app logo',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Server connectivity indicator
          if (!_serverOnline)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Server offline — configure in Settings',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Retry server connection',
                    child: InkWell(
                      onTap: _checkServerStatus,
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.refresh,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 28,
            runSpacing: 36,
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
    final results = SignDictionary.search(_searchQuery);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign Dictionary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${SignDictionary.allSigns.length} signs across ${SignDictionary.categories.length} categories',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppColors.premiumShadows,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Semantics(
              label: 'Search signs and phrases',
              textField: true,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search signs, phrases, alphabet...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildCategoryList()
                : _buildSearchResults(results),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: SignDictionary.categories.length,
      itemBuilder: (context, index) {
        final cat = SignDictionary.categories[index];
        return Semantics(
          button: true,
          label: '${cat.name} category, ${cat.signs.length} signs',
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignDictionaryScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cat.signs.length} signs',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<SignEntry> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No signs found for "$_searchQuery"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final sign = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(sign.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sign.word,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sign.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label tab',
      selected: isSelected,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
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
    return Semantics(
      button: true,
      label: '${entry.title} mode',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.premiumShadows,
                ),
                child: Icon(entry.icon, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                entry.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
