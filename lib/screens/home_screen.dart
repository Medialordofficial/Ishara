import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _serverChecking = true;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    if (mounted) setState(() => _serverChecking = true);
    final ok = await _api.ping();
    if (mounted) {
      setState(() {
        _serverOnline = ok;
        _serverChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -- Mode catalog ----------------------------------------------------------
  // Hero gets the most attention. Emergency is its own dedicated bar.
  // The remaining four "primary" modes form the 2×2 finger-zone grid.
  // Everything else is a "tool" surfaced as a horizontal chip row.

  _ModeEntry get _heroMode => _ModeEntry(
    title: AppStrings.conversationMode,
    subtitle: 'Sign with anyone, instantly',
    icon: Icons.chat_bubble_rounded,
    accent: AppColors.primary,
    builder: () => const ConversationScreen(),
  );

  _ModeEntry get _emergencyMode => _ModeEntry(
    title: AppStrings.emergencyMode,
    subtitle: 'Immediate help & location',
    icon: Icons.emergency_rounded,
    accent: AppColors.danger,
    builder: () => const EmergencyScreen(),
  );

  List<_ModeEntry> get _primaryModes => [
    _ModeEntry(
      title: AppStrings.soundAwarenessMode,
      subtitle: 'Hear the world around you',
      icon: Icons.hearing_rounded,
      accent: const Color(0xFF0E9F6E),
      builder: () => const SoundAwarenessScreen(),
    ),
    _ModeEntry(
      title: AppStrings.worldReaderMode,
      subtitle: 'See, read, understand',
      icon: Icons.camera_alt_rounded,
      accent: const Color(0xFF8B5CF6),
      builder: () => const WorldReaderScreen(),
    ),
    _ModeEntry(
      title: 'Type to Speak',
      subtitle: 'Your voice in any language',
      icon: Icons.record_voice_over_rounded,
      accent: const Color(0xFFF59E0B),
      builder: () => const TypeToSpeakScreen(),
    ),
    _ModeEntry(
      title: 'Ishara AI',
      subtitle: 'Ask anything, anytime',
      icon: Icons.auto_awesome_rounded,
      accent: const Color(0xFF06B6D4),
      builder: () => const AiChatScreen(),
    ),
  ];

  List<_ModeEntry> get _toolsModes => [
    _ModeEntry(
      title: AppStrings.learnSignsMode,
      subtitle: 'Practice & learn',
      icon: Icons.school_rounded,
      accent: const Color(0xFF6366F1),
      builder: () => const LearnSignsScreen(),
    ),
    _ModeEntry(
      title: 'Sign Dictionary',
      subtitle: 'Browse all signs',
      icon: Icons.menu_book_rounded,
      accent: const Color(0xFFEC4899),
      builder: () => const SignDictionaryScreen(),
    ),
    _ModeEntry(
      title: 'Text Chat',
      subtitle: 'Send a quick message',
      icon: Icons.chat_rounded,
      accent: const Color(0xFF14B8A6),
      builder: () => const TextChatScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHomeTab(context),
            _buildSearchTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedTab,
        onSelect: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = i);
        },
      ),
    );
  }

  // -- Header ---------------------------------------------------------------
  Widget _buildHeader({String? title, String? subtitle, bool showSettings = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: AppColors.premiumShadows,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/ishara_logo.png',
                fit: BoxFit.cover,
                semanticLabel: 'Ishara logo',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle ?? _greeting,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? AppStrings.appName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(
            online: _serverOnline,
            checking: _serverChecking,
            onTap: _checkServerStatus,
          ),
          if (showSettings) ...[
            const SizedBox(width: 8),
            _IconChip(
              icon: Icons.settings_rounded,
              tooltip: 'Settings',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 2);
              },
            ),
          ],
        ],
      ),
    );
  }

  // -- Home tab -------------------------------------------------------------
  Widget _buildHomeTab(BuildContext context) {
    final hero = _heroMode;
    final emergency = _emergencyMode;
    final primary = _primaryModes;
    final tools = _toolsModes;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _HeroCard(
              entry: hero,
              onTap: () => _openScreen(hero),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _EmergencyBar(
              entry: emergency,
              onTap: () => _openScreen(emergency),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _SectionTitle('Quick actions'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PrimaryActionCard(
                entry: primary[index],
                onTap: () => _openScreen(primary[index]),
              ),
              childCount: primary.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _SectionTitle('Tools'),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: tools.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ToolChip(
                entry: tools[index],
                onTap: () => _openScreen(tools[index]),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  // -- Search tab -----------------------------------------------------------
  Widget _buildSearchTab(BuildContext context) {
    final results = SignDictionary.search(_searchQuery);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(
            title: 'Sign Dictionary',
            subtitle:
                '${SignDictionary.allSigns.length} signs • ${SignDictionary.categories.length} categories',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _SearchField(
              controller: _searchController,
              value: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        if (_searchQuery.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
            sliver: SliverList.separated(
              itemCount: SignDictionary.categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final cat = SignDictionary.categories[index];
                return _CategoryTile(
                  category: cat,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignDictionaryScreen(),
                    ),
                  ),
                );
              },
            ),
          )
        else if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(query: _searchQuery),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
            sliver: SliverList.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _SignResultTile(sign: results[index]),
            ),
          ),
      ],
    );
  }

  // -- Settings tab ---------------------------------------------------------
  Widget _buildSettingsTab(BuildContext context) {
    return Column(
      children: [
        _buildHeader(
          title: 'Settings',
          subtitle: 'Personalize Ishara',
          showSettings: false,
        ),
        const SizedBox(height: 12),
        const Expanded(child: SettingsScreen(showAppBar: false)),
      ],
    );
  }

  void _openScreen(_ModeEntry entry) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => entry.builder(),
        transitionsBuilder: (context, animation, _, child) {
          final fade = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}

// =========================================================================
// Models
// =========================================================================

class _ModeEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget Function() builder;

  const _ModeEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.builder,
  });
}

// =========================================================================
// Reusable widgets
// =========================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool online;
  final bool checking;
  final VoidCallback onTap;
  const _StatusPill({
    required this.online,
    required this.checking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = checking
        ? AppColors.textSecondary
        : (online ? AppColors.success : AppColors.warning);
    final label = checking ? 'Checking' : (online ? 'Online' : 'Offline');
    return Semantics(
      button: true,
      label: 'Server $label, tap to retry',
      child: Tooltip(
        message: 'Server $label',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (checking)
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconChip({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.premiumShadows,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}

// -- Hero CTA ---------------------------------------------------------------

class _HeroCard extends StatefulWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;
  const _HeroCard({required this.entry, required this.onTap});

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.entry.title}. ${widget.entry.subtitle}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            height: 168,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.entry.accent,
                  Color.lerp(widget.entry.accent, Colors.black, 0.25)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.entry.accent.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -28,
                  bottom: -28,
                  child: Icon(
                    widget.entry.icon,
                    size: 168,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'START HERE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.entry.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Open',
                                style: TextStyle(
                                  color: widget.entry.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: widget.entry.accent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Emergency bar ----------------------------------------------------------

class _EmergencyBar extends StatelessWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;
  const _EmergencyBar({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${entry.title}. ${entry.subtitle}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: entry.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: entry.accent.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: entry.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(entry.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: TextStyle(
                          color: entry.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: entry.accent,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Primary action card (2x2 grid) -----------------------------------------

class _PrimaryActionCard extends StatefulWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;
  const _PrimaryActionCard({required this.entry, required this.onTap});

  @override
  State<_PrimaryActionCard> createState() => _PrimaryActionCardState();
}

class _PrimaryActionCardState extends State<_PrimaryActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.entry.accent;
    return Semantics(
      button: true,
      label: '${widget.entry.title}. ${widget.entry.subtitle}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.entry.icon, color: accent, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.entry.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Tool chip (horizontal scroll) ------------------------------------------

class _ToolChip extends StatelessWidget {
  final _ModeEntry entry;
  final VoidCallback onTap;
  const _ToolChip({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = entry.accent;
    return Semantics(
      button: true,
      label: '${entry.title}. ${entry.subtitle}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, color: accent, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Bottom navigation ------------------------------------------------------

class _PremiumBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _PremiumBottomNav({required this.selectedIndex, required this.onSelect});

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.search_rounded, label: 'Search'),
    (icon: Icons.tune_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.premiumShadows,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isSelected = selectedIndex == i;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${tab.label} tab',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: -2,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tab.icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: SizedBox(
                              width: isSelected ? 8 : 0,
                            ),
                          ),
                          ClipRect(
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.centerLeft,
                              widthFactor: isSelected ? 1 : 0,
                              child: Text(
                                tab.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// -- Search field, category tile, sign result tile, empty state ------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadows,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Semantics(
        textField: true,
        label: 'Search signs and phrases',
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search signs, phrases, alphabet…',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'Clear search',
                    onPressed: onClear,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final SignCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name} category, ${category.signs.length} signs',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(category.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.signs.length} signs',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignResultTile extends StatelessWidget {
  final SignEntry sign;
  const _SignResultTile({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(sign.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sign.word,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sign.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No signs found',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try a different word for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
