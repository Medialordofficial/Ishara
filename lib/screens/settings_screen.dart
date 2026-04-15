import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final ApiService _api = ApiService();
  String _connectionStatus = '';
  bool _isTesting = false;

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
    // Apply saved settings to API service
    await _api.updateBaseUrl(
      _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? ApiConfig.defaultPort,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ishara_host', _hostController.text.trim());
    await prefs.setInt(
      'ishara_port',
      int.tryParse(_portController.text.trim()) ?? ApiConfig.defaultPort,
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _connectionStatus = '';
    });

    await _api.updateBaseUrl(
      _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? ApiConfig.defaultPort,
    );

    // Save settings
    await _saveSettings();

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
    super.dispose();
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
        const SizedBox(height: 16),

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
