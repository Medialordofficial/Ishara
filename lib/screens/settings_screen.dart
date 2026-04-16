import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _hostController = TextEditingController(text: ApiConfig.defaultHost);
  final _portController = TextEditingController(
    text: ApiConfig.defaultPort.toString(),
  );
  final _emergencyNumberController = TextEditingController(text: '112');
  final _apiKeyController = TextEditingController();
  final ApiService _api = ApiService();
  String _connectionStatus = '';
  bool _isTesting = false;
  bool _apiKeyObscured = true;
  // Validates E.164-ish phone numbers: optional +, 1-15 digits.
  static final _phoneRegex = RegExp(r'^\+?[0-9]{1,15}$');

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('ishara_host');
    final savedPort = prefs.getInt('ishara_port');
    if (savedHost != null) _hostController.text = savedHost;
    if (savedPort != null) _portController.text = savedPort.toString();
    final savedEmergency = prefs.getString('ishara_emergency_number');
    if (savedEmergency != null && savedEmergency.isNotEmpty) {
      _emergencyNumberController.text = savedEmergency;
    }
    // Load API key from secure storage via ApiService (it handles secure reads internally).
    // Do NOT read from SharedPreferences — that would expose the key in unencrypted storage.
    final secureApiKey = await _api.loadApiKey();
    if (secureApiKey != null && secureApiKey.isNotEmpty) {
      _apiKeyController.text = secureApiKey;
    }
    // Apply saved settings to API service
    await _api.updateBaseUrl(
      _hostController.text.trim(),
      port: _parsedPort(),
    );
  }

  /// Returns a valid port in [1, 65535], defaulting to [ApiConfig.defaultPort].
  int _parsedPort() {
    final parsed = int.tryParse(_portController.text.trim()) ?? ApiConfig.defaultPort;
    return parsed.clamp(1, 65535);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ishara_host', _hostController.text.trim());
    await prefs.setInt('ishara_port', _parsedPort());
    final emergencyNum = _emergencyNumberController.text.trim();
    if (emergencyNum.isNotEmpty) {
      await _api.setEmergencyNumber(emergencyNum);
    }
    // Save API key to secure storage only (never plaintext SharedPreferences).
    final apiKey = _apiKeyController.text.trim();
    await _api.setApiKey(apiKey);
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _connectionStatus = '';
    });

    await _api.updateBaseUrl(
      _hostController.text.trim(),
      port: _parsedPort(),
    );

    // Save settings
    await _saveSettings();

    // Refresh state to show/hide insecure HTTP warning after host change.
    setState(() {});

    try {
      final ok = await _api.ping();
      setState(() {
        _connectionStatus = ok
            ? '✅ Connected to Ishara server'
            : '❌ Server not responding';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Could not reach server. Check IP and port.';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _emergencyNumberController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Widget _buildThemeSelector() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return RadioGroup<ThemeMode>(
          groupValue: mode,
          onChanged: (ThemeMode? value) async {
            if (value == null) return;
            themeNotifier.value = value;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('ishara_theme', value.name);
          },
          child: Column(
            children: [
              for (final entry in [
                (ThemeMode.system, 'System Default', Icons.brightness_auto),
                (ThemeMode.light, 'Light', Icons.light_mode),
                (ThemeMode.dark, 'Dark', Icons.dark_mode),
              ])
                RadioListTile<ThemeMode>(
                  value: entry.$1,
                  title: Text(entry.$2),
                  secondary: Icon(entry.$3, color: AppColors.primary),
                  activeColor: AppColors.primary,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (!widget.showAppBar) ...[
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Connect to your local Gemma 4 backend, tune the app, and get Ishara ready for daily use.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
        ],
        // Server connection
        Text(
          'Server Connection',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Ishara runs Gemma 4 on your laptop. Enter the IP address of the machine running the backend.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Host
        TextField(
          controller: _hostController,
          decoration: InputDecoration(
            labelText: 'Server Host / IP',
            hintText: '192.168.1.x',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),

        // Port
        TextField(
          controller: _portController,
          decoration: InputDecoration(
            labelText: 'Port',
            hintText: '8000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // API Key
        TextField(
          controller: _apiKeyController,
          obscureText: _apiKeyObscured,
          decoration: InputDecoration(
            labelText: 'API Key (optional)',
            hintText: 'Leave empty if not required',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: IconButton(
              icon: Icon(
                _apiKeyObscured ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              tooltip: _apiKeyObscured ? 'Show API key' : 'Hide API key',
              onPressed: () =>
                  setState(() => _apiKeyObscured = !_apiKeyObscured),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Insecure HTTP warning — shown when using plain HTTP on a non-local host
        if (_api.isInsecureHttp) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Insecure HTTP: Your data (signs, location, messages) is sent unencrypted. '
                    'Use HTTPS in production or connect via localhost.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Test button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isTesting ? null : _testConnection,
            icon: _isTesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  )
                : const Icon(Icons.wifi_find),
            label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        if (_connectionStatus.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _connectionStatus,
            style: TextStyle(
              color: _connectionStatus.contains('✅')
                  ? AppColors.success
                  : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),
        const Divider(color: AppColors.surfaceLight),
        const SizedBox(height: 16),

        // Emergency Number
        Text(
          'Emergency Services',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Emergency number to dial when sending SOS. Default: 112 (international). Use 911 (USA), 999 (UK), etc.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emergencyNumberController,
          decoration: InputDecoration(
            labelText: 'Emergency Number',
            hintText: '112',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          keyboardType: TextInputType.phone,
          onChanged: (val) async {
            final trimmed = val.trim();
            if (trimmed.isNotEmpty && _phoneRegex.hasMatch(trimmed)) {
              await _api.setEmergencyNumber(trimmed);
            }
          },
        ),
        // Inline validation hint
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _emergencyNumberController,
          builder: (context, value, _) {
            final trimmed = value.text.trim();
            if (trimmed.isNotEmpty && !_phoneRegex.hasMatch(trimmed)) {
              return Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  'Enter a valid number (digits only, optional leading +, max 15 digits)',
                  style: TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 32),
        const Divider(color: AppColors.surfaceLight),
        const SizedBox(height: 16),

        // Appearance
        Text(
          'Appearance',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        _buildThemeSelector(),

        const SizedBox(height: 32),
        const Divider(color: AppColors.surfaceLight),
        const SizedBox(height: 16),

        // Quick start guide
        Text(
          'Quick Start',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        _StepTile(
          step: '1',
          title: 'Install Ollama on your laptop',
          subtitle: 'brew install ollama   (macOS)',
        ),
        _StepTile(
          step: '2',
          title: 'Pull Gemma 4',
          subtitle: 'ollama pull gemma4',
        ),
        _StepTile(
          step: '3',
          title: 'Run the Ishara backend',
          subtitle: 'cd backend && python server.py',
        ),
        _StepTile(
          step: '4',
          title: 'Enter your laptop\'s IP above',
          subtitle: 'Find it: Settings → Wi-Fi → IP Address',
        ),
        _StepTile(
          step: '5',
          title: 'Test connection and start using!',
          subtitle: 'Tap "Test Connection" above',
        ),

        const SizedBox(height: 32),
        const Divider(color: AppColors.surfaceLight),
        const SizedBox(height: 16),

        // About
        Text(
          'About Ishara',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.fullTagline,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Powered by Gemma 4 via Ollama',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 40),
      ],
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            const Text('Settings'),
          ],
        ),
      ),
      body: content,
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;

  const _StepTile({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
