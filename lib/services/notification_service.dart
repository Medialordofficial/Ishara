import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request notification permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> show({
    required String title,
    required String body,
    String? channel,
  }) async {
    if (!_initialized) await init();

    final channelId = channel ?? 'ishara_default';
    final channelName = channel ?? 'Ishara';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Convenience methods
  Future<void> aiReply(String reply) => show(
        title: '🤖 Ishara AI',
        body: reply.length > 200 ? '${reply.substring(0, 200)}...' : reply,
        channel: 'ishara_ai',
      );

  Future<void> soundAlert(String label) => show(
        title: '🔊 Sound Detected',
        body: label,
        channel: 'ishara_sound',
      );

  Future<void> emergencyConfirm(String message) => show(
        title: '🚨 Emergency SOS Sent',
        body: message,
        channel: 'ishara_emergency',
      );
}
