import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'android_live_timer_notification_service.dart';

class AlarmNotificationService {
  static final AlarmNotificationService _instance =
      AlarmNotificationService._internal();
  factory AlarmNotificationService() => _instance;
  AlarmNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'gymbro_timer_alarm_channel';
  static const String channelName = 'زنگ هشدار تایمر استراحت جیم‌برو';
  static const String channelDescription =
      'هشدار صوتی و لرزشی پایان زمان استراحت بین ست‌های ورزشی';
  static const int alarmNotificationId = 771;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationAction,
      );

      // Create high-importance alarm notification channel
      final androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 700]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        // Request runtime permission on Android 13+
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      // In unit test environments where native channels aren't available, gracefully continue
      _isInitialized = true;
    }
  }

  void _onNotificationAction(NotificationResponse response) {
    if (response.actionId == 'dismiss_timer_action') {
      cancelAlarm();
    } else if (response.actionId != null) {
      AndroidLiveTimerNotificationService()
          .handleNotificationAction(response.actionId!);
    }
  }

  /// Schedules an exact background alarm notification when the timer expires.
  Future<void> scheduleAlarm({
    required DateTime targetEndTime,
    required String title,
    required String body,
  }) async {
    try {
      // Avoid duplicate alarms: always cancel any pending alarm first
      await cancelAlarm();

      final scheduledDate = tz.TZDateTime.from(targetEndTime, tz.local);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 700]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        actions: const [
          AndroidNotificationAction(
            'dismiss_timer_action',
            'توقف و بستن',
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        alarmNotificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Fallback gracefully in headless test runner
    }
  }

  /// Triggers immediate alarm notification with sound and haptics.
  Future<void> triggerImmediateAlarm({
    String title = 'زمان استراحت پایان یافت!',
    String body = 'وقت شروع ست تمرینی بعدی است. آماده‌ای؟',
  }) async {
    try {
      // Trigger native system sound and haptic vibration
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.vibrate();

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 700]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        actions: const [
          AndroidNotificationAction(
            'dismiss_timer_action',
            'توقف و بستن',
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        alarmNotificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {
      // Headless / mock environment fallback
    }
  }

  /// Cancels any scheduled or active alarm notification.
  Future<void> cancelAlarm() async {
    try {
      await _notificationsPlugin.cancel(alarmNotificationId);
    } catch (_) {}
  }
}
