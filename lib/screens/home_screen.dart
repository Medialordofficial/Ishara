import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sign_dictionary.dart';
import '../services/api_service.dart';
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

// Mockup-matched palette.
class _Palette {
  static const bg = Color(0xFFF6F4FF); // Soft lavender background
  static const card = Colors.white;
  static const ink = Color(0xFF1B1F3B);
  static const sub = Color(0xFF7C84A3);
  static const accentStart = Color(0xFF6C7BFF); // Indigo
  static const accentEnd = Color(0xFF8B5CF6); // Violet
  // Tile accent tints
  static const blue = Color(0xFF4F7BFF);
  static const violet = Color(0xFF8B5CF6);
  static const red = Color(0xFFFF4D5E);
  static const green = Color(0xFF24C56F);
  static const orange = Color(0xFFFF8A3D);
  static const sky = Color(0xFF4F8EFF);
  static const teal = Color(0xFF22C7B6);
  static const pink = Color(0xFFE25BB8);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _askController = TextEditingController();
  final ApiService _api = ApiService();
  bool _serverOnline = false;
  bool _serverChecking = true;

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
    _askController.dispose();
    super.dispose();
  }

  // Tile catalog — order matches mockup grid.
  List<_Tile> get _tiles => [
    _Tile(
      title: 'Conversation',
      subtitle: 'Talk naturally',
      icon: Icons.chat_bubble_rounded,
      accent: _Palette.blue,
      builder: () => const ConversationScreen(),
    ),
    _Tile(
      title: 'Sound\nAwareness',
      subtitle: 'Listen & understand',
      icon: Icons.hearing_rounded,
      accent: _Palette.violet,
      builder: () => const SoundAwarenessScreen(),
    ),
    _Tile(
      title: 'Emergency SOS',
      subtitle: 'Get help fast',
      icon: Icons.emergency_rounded,
      accent: _Palette.red,
      builder: () => const EmergencyScreen(),
    ),
    _Tile(
      title: 'World Reader',
      subtitle: 'Scan & explore',
      icon: Icons.camera_alt_rounded,
      accent: _Palette.green,
      builder: () => const WorldReaderScreen(),
    ),
    _Tile(
      title: 'Learn Signs',
      subtitle: 'Sign language',
      icon: Icons.school_rounded,
      accent: _Palette.orange,
      builder: () => const LearnSignsScreen(),
    ),
    _Tile(
      title: 'Type to Speak',
      subtitle: 'Convert text',
      icon: Icons.record_voice_over_rounded,
      accent: _Palette.sky,
      builder: () => const TypeToSpeakScreen(),
    ),
    _Tile(
      title: 'Text Chat',
      subtitle: 'Chat in text',
      icon: Icons.chat_rounded,
      accent: _Palette.violet,
      builder: () => const TextChatScreen(),
    ),
    _Tile(
      title: 'Sign\nDictionary',
      subtitle: 'Learn & reference',
      icon: Icons.menu_book_rounded,
      accent: _Palette.teal,
      builder: () => const SignDictionaryScreen(),
    ),
    _Tile(
      title: 'Ishara AI',
      subtitle: 'Your AI assistant',
      icon: Icons.smart_toy_rounded,
      accent: _Palette.pink,
      builder: () => const AiChatScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHomeTab(context),
            _buildExploreTab(context),
            _buildProfileTab(context),
          ],
        ),
      ),
      bottomNavigationBar: _MockupBottomNav(
        selectedIndex: _selectedTab,
        onSelect: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = i);
        },
      ),
    );
  }

  // ----- HOME TAB -----------------------------------------------------------

  Widget _buildHomeTab(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: _GreetingHeader(
              greeting: _greeting,
              onLogoTap: _checkServerStatus,
              serverOnline: _serverOnline,
              serverChecking: _serverChecking,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _AskAnythingBar(
              controller: _askController,
              onSubmit: (text) {
                if (text.trim().isEmpty) {
                  _openTile(_tiles.firstWhere((t) => t.title == 'Ishara AI'));
                  return;
                }
                _openTile(_tiles.firstWhere((t) => t.title == 'Ishara AI'));
              },
              onMicTap: () {
                HapticFeedback.lightImpact();
                _openTile(_tiles.firstWhere((t) => t.title == 'Conversation'));
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) =>
                  _GridTile(tile: _tiles[i], onTap: () => _openTile(_tiles[i])),
              childCount: _tiles.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _IsharaAIBanner(
              onTap: () =>
                  _openTile(_tiles.firstWhere((t) => t.title == 'Ishara AI')),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }

  // ----- EXPLORE (search) TAB ----------------------------------------------

  Widget _buildExploreTab(BuildContext context) {
    final results = SignDictionary.search(_searchQuery);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Dictionary',
                  style: TextStyle(
                    color: _Palette.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${SignDictionary.allSigns.length} signs • ${SignDictionary.categories.length} categories',
                  style: const TextStyle(
                    color: _Palette.sub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                _SearchField(
                  controller: _searchController,
                  value: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (_searchQuery.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 130),
            sliver: SliverList.separated(
              itemCount: SignDictionary.categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _CategoryTile(
                category: SignDictionary.categories[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignDictionaryScreen(),
                  ),
                ),
              ),
            ),
          )
        else if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(query: _searchQuery),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 130),
            sliver: SliverList.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _SignResultTile(sign: results[i]),
            ),
          ),
      ],
    );
  }

  // ----- PROFILE (settings) TAB --------------------------------------------

  Widget _buildProfileTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: _Palette.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Personalize Ishara',
                      style: TextStyle(
                        color: _Palette.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusDot(
                online: _serverOnline,
                checking: _serverChecking,
                onTap: _checkServerStatus,
              ),
            ],
          ),
        ),
        const Expanded(child: SettingsScreen(showAppBar: false)),
      ],
    );
  }

  void _openTile(_Tile tile) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => tile.builder(),
        transitionsBuilder: (_, animation, _, child) {
          final fade = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
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

class _Tile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget Function() builder;
  const _Tile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.builder,
  });
}

// =========================================================================
// Header
// =========================================================================

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final VoidCallback onLogoTap;
  final bool serverOnline;
  final bool serverChecking;
  const _GreetingHeader({
    required this.greeting,
    required this.onLogoTap,
    required this.serverOnline,
    required this.serverChecking,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: _Palette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: _Palette.ink,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    height: 1.05,
                  ),
                  children: [
                    TextSpan(text: 'Welcome '),
                    TextSpan(
                      text: 'back',
                      style: TextStyle(
                        foreground: null,
                        color: _Palette.accentEnd,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How can I help you today?',
                style: TextStyle(
                  color: _Palette.sub,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _LogoBadge(
          onTap: onLogoTap,
          serverOnline: serverOnline,
          serverChecking: serverChecking,
        ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final VoidCallback onTap;
  final bool serverOnline;
  final bool serverChecking;
  const _LogoBadge({
    required this.onTap,
    required this.serverOnline,
    required this.serverChecking,
  });

  @override
  Widget build(BuildContext context) {
    final dot = serverChecking
        ? _Palette.sub
        : (serverOnline ? const Color(0xFF22C55E) : const Color(0xFFEF4444));
    return Semantics(
      button: true,
      label:
          'Server ${serverChecking ? "checking" : (serverOnline ? "online" : "offline")}, tap to retry',
      child: Tooltip(
        message: serverChecking
            ? 'Checking server'
            : (serverOnline
                  ? 'Server online'
                  : 'Server offline — tap to retry'),
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8C9AB5).withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ishara_logo.png',
                      fit: BoxFit.cover,
                      semanticLabel: 'Ishara logo',
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// Ask anything bar
// =========================================================================

class _AskAnythingBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onMicTap;
  const _AskAnythingBar({
    required this.controller,
    required this.onSubmit,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C9AB5).withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          const _SparkleIcon(size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              textField: true,
              label: 'Ask Ishara anything',
              child: TextField(
                controller: controller,
                onSubmitted: onSubmit,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  color: _Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: 'Ask anything...',
                  hintStyle: TextStyle(
                    color: _Palette.sub,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Voice conversation',
            child: Tooltip(
              message: 'Start voice conversation',
              child: GestureDetector(
                onTap: onMicTap,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_Palette.accentStart, _Palette.accentEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.accentEnd.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleIcon extends StatelessWidget {
  final double size;
  const _SparkleIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        colors: [_Palette.accentStart, _Palette.accentEnd, Color(0xFFFF7AB6)],
      ).createShader(rect),
      child: Icon(Icons.auto_awesome, size: size, color: Colors.white),
    );
  }
}

// =========================================================================
// Grid tile
// =========================================================================

class _GridTile extends StatefulWidget {
  final _Tile tile;
  final VoidCallback onTap;
  const _GridTile({required this.tile, required this.onTap});

  @override
  State<_GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.tile.accent;
    return Semantics(
      button: true,
      label:
          '${widget.tile.title.replaceAll('\n', ' ')}. ${widget.tile.subtitle}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: _Palette.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8C9AB5).withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                  ),
                  child: Icon(widget.tile.icon, color: accent, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.tile.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _Palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tile.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _Palette.sub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// Ishara AI promo banner
// =========================================================================

class _IsharaAIBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _IsharaAIBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Discover the power of Ishara AI, your intelligent sign language assistant',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8E2FF), Color(0xFFF1E5FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.accentEnd.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB7A6FF), Color(0xFF8B5CF6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.accentEnd.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover the power of',
                      style: TextStyle(
                        color: _Palette.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Ishara AI ',
                          style: TextStyle(
                            color: _Palette.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const _SparkleIcon(size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Your intelligent sign language assistant',
                      style: TextStyle(
                        color: _Palette.sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Palette.accentStart, _Palette.accentEnd],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.accentEnd.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 18,
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

// =========================================================================
// Bottom navigation matching mockup
// =========================================================================

class _MockupBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _MockupBottomNav({required this.selectedIndex, required this.onSelect});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.search_rounded, label: 'Explore'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8C9AB5).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = selectedIndex == i;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${item.label} tab',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(i),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        height: 56,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 22 : 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _Palette.accentStart,
                                    _Palette.accentEnd,
                                  ],
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _Palette.accentEnd.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                    spreadRadius: -2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? Colors.white : _Palette.sub,
                              size: 24,
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              child: isSelected
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
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

// =========================================================================
// Status dot (used by Profile tab header)
// =========================================================================

class _StatusDot extends StatelessWidget {
  final bool online;
  final bool checking;
  final VoidCallback onTap;
  const _StatusDot({
    required this.online,
    required this.checking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = checking
        ? _Palette.sub
        : (online ? const Color(0xFF22C55E) : const Color(0xFFEF4444));
    final label = checking ? 'Checking' : (online ? 'Online' : 'Offline');
    return Semantics(
      button: true,
      label: 'Server $label, tap to retry',
      child: Tooltip(
        message: 'Server $label',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

// =========================================================================
// Search field, category tile, sign result tile, empty state
// =========================================================================

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C9AB5).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
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
              color: _Palette.sub,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            icon: const Icon(Icons.search_rounded, color: _Palette.accentEnd),
            suffixIcon: value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: _Palette.sub,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8C9AB5).withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _Palette.accentEnd.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
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
                        color: _Palette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.signs.length} signs',
                      style: const TextStyle(
                        color: _Palette.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _Palette.sub),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C9AB5).withValues(alpha: 0.10),
            blurRadius: 12,
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
              color: _Palette.accentEnd.withValues(alpha: 0.10),
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
                    color: _Palette.accentEnd,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sign.description,
                  style: const TextStyle(
                    color: _Palette.sub,
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
              color: _Palette.accentEnd.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: _Palette.sub,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No signs found',
            style: TextStyle(
              color: _Palette.ink,
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
                color: _Palette.sub,
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

// Constants reference kept for backward compat (not used directly here).
