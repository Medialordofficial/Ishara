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
  String _searchQuery = '';

  List<_ModeEntry> get _modeEntries => [
    _ModeEntry(
      title: AppStrings.conversationMode,
      subtitle: 'Translate sign language into speech in real time.',
      eyebrow: 'Live camera',
      accent: AppColors.primary,
      icon: Icons.sign_language_rounded,
      keywords: const ['sign', 'speech', 'camera', 'conversation', 'talk'],
      builder: () => const ConversationScreen(),
    ),
    _ModeEntry(
      title: AppStrings.soundAwarenessMode,
      subtitle: 'Catch alarms, knocks, and urgent sounds around you.',
      eyebrow: 'Safety',
      accent: AppColors.info,
      icon: Icons.hearing_rounded,
      keywords: const ['sound', 'alarm', 'listen', 'awareness', 'audio'],
      builder: () => const SoundAwarenessScreen(),
    ),
    _ModeEntry(
      title: AppStrings.emergencyMode,
      subtitle: 'Generate an emergency message fast when every second matters.',
      eyebrow: 'SOS',
      accent: AppColors.danger,
      icon: Icons.emergency_rounded,
      keywords: const ['emergency', 'sos', 'medical', 'police', 'fire'],
      builder: () => const EmergencyScreen(),
    ),
    _ModeEntry(
      title: AppStrings.worldReaderMode,
      subtitle: 'Read scenes, signs, and text through the back camera.',
      eyebrow: 'Vision',
      accent: AppColors.success,
      icon: Icons.document_scanner_rounded,
      keywords: const ['read', 'world', 'camera', 'text', 'vision'],
      builder: () => const WorldReaderScreen(),
    ),
    _ModeEntry(
      title: AppStrings.learnSignsMode,
      subtitle: 'Practice signs with guided prompts and feedback.',
      eyebrow: 'Learning',
      accent: AppColors.warning,
      icon: Icons.school_rounded,
      keywords: const ['learn', 'practice', 'signs', 'training', 'school'],
      builder: () => const LearnSignsScreen(),
    ),
  ];

  List<_ModeEntry> get _filteredEntries {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _modeEntries;
    return _modeEntries.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.subtitle.toLowerCase().contains(query) ||
          entry.keywords.any((keyword) => keyword.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFCF7), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _buildHomeTab(context),
              _buildSearchTab(context),
              const SettingsScreen(showAppBar: false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    selected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final modes = _modeEntries;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Gemma 4 accessibility companion',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A calmer, clearer home for every mode.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Start a live conversation, detect critical sounds, scan the world, or jump into settings from one place.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/ishara_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _selectedTab = 1),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search features, safety tools, or camera modes',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.secondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _SpotlightCard(
            onPrimaryTap: () => _openScreen(modes.first),
            onSecondaryTap: () => setState(() => _selectedTab = 2),
          ),
          const SizedBox(height: 28),
          const _SectionHeading(
            title: 'Explore every mode',
            subtitle:
                'Purpose-built tools for communication, safety, and independence.',
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            entry: modes[0],
            isLarge: true,
            onTap: () => _openScreen(modes[0]),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  entry: modes[1],
                  onTap: () => _openScreen(modes[1]),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _FeatureCard(
                  entry: modes[2],
                  onTap: () => _openScreen(modes[2]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  entry: modes[3],
                  onTap: () => _openScreen(modes[3]),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _FeatureCard(
                  entry: modes[4],
                  onTap: () => _openScreen(modes[4]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need to connect the backend?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Open Settings, enter your laptop IP, and test your Gemma 4 connection.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => setState(() => _selectedTab = 2),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    final results = _filteredEntries;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Text('Search', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Jump straight to a feature, filter by intent, and keep the app fast to navigate.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Try conversation, emergency, alarm, camera...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () => setState(() => _searchQuery = ''),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _TagChip(label: 'Safety first'),
            _TagChip(label: 'Live camera'),
            _TagChip(label: 'Learning'),
            _TagChip(label: 'Gemma 4'),
          ],
        ),
        const SizedBox(height: 24),
        if (results.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No result for "$_searchQuery"',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Try searching for safety, signs, camera, or emergency.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else
          ...results.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SearchResultCard(
                entry: entry,
                onTap: () => _openScreen(entry),
              ),
            ),
          ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _selectedTab = 2),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings_suggest_rounded, color: AppColors.primary),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Open Settings to update your backend IP and test the connection.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: AppColors.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openScreen(_ModeEntry entry) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            entry.builder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset =
              Tween<Offset>(
                begin: const Offset(0.02, 0.03),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}

class _ModeEntry {
  final String title;
  final String subtitle;
  final String eyebrow;
  final Color accent;
  final IconData icon;
  final List<String> keywords;
  final Widget Function() builder;

  const _ModeEntry({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.accent,
    required this.icon,
    required this.keywords,
    required this.builder,
  });
}

class _SpotlightCard extends StatelessWidget {
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _SpotlightCard({
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D5), Color(0xFFF7E4B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Spotlight',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lead with the feature people reach for most.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Conversation mode stays one tap away, while setup stays close enough to keep the full experience working.',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPrimaryTap,
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Open live mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSecondaryTap,
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Setup'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;
  final bool isLarge;

  const _FeatureCard({
    required this.entry,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.all(isLarge ? 22 : 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: entry.accent.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: entry.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(entry.icon, color: entry.accent, size: 24),
                ),
                const Spacer(),
                Text(
                  entry.eyebrow,
                  style: TextStyle(
                    color: entry.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 18 : 14),
            Text(
              entry.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: isLarge ? 24 : 18),
            ),
            const SizedBox(height: 8),
            Text(entry.subtitle, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: isLarge ? 18 : 20),
            Row(
              children: [
                Text(
                  'Open mode',
                  style: TextStyle(
                    color: entry.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: entry.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;

  const _SearchResultCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: entry.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(entry.icon, color: entry.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, color: entry.accent),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.secondary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.secondary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
