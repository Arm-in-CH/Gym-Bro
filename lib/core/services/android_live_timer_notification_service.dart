import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../localization/persian_utils.dart';
import 'workout_timer_service.dart';

class AndroidLiveTimerNotificationService {
  static final AndroidLiveTimerNotificationService _instance =
      AndroidLiveTimerNotificationService._internal();
  factory AndroidLiveTimerNotificationService() => _instance;
  AndroidLiveTimerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'gymbro_live_timer_channel';
  static const String channelName = 'تایمر زنده و استراحت تمرین جیم‌برو';
  static const String channelDescription =
      'نمایش زمان زنده باقی‌مانده استراحت بین ست‌ها و وضعیت تمرین';
  static const int liveNotificationId = 772;

  static const String actionPause = 'gymbro_action_pause';
  static const String actionResume = 'gymbro_action_resume';
  static const String actionCancel = 'gymbro_action_cancel';

  bool _isInitialized = false;
  String _activeExerciseName = 'استراحت بین ست';
  int _lastPublishedSeconds = -1;

  void setActiveExerciseName(String name) {
    if (name.trim().isNotEmpty) {
      _activeExerciseName = name.trim();
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Low importance so ongoing countdown does not trigger sound/vibration repeatedly
        const androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );

        await androidPlugin.createNotificationChannel(androidChannel);
      }

      _isInitialized = true;
    } catch (_) {
      _isInitialized = true;
    }
  }

  /// Handles action buttons tapped directly from the Android ongoing notification
  Future<void> handleNotificationAction(String actionId) async {
    final timer = WorkoutTimerService();
    switch (actionId) {
      case actionPause:
        await timer.pause();
        break;
      case actionResume:
        await timer.resume();
        break;
      case actionCancel:
        await timer.cancel();
        break;
    }
  }

  /// Displays or updates the persistent ongoing live notification
  Future<void> updateLiveNotification({
    required WorkoutTimerStatus status,
    required int remainingSeconds,
    required int totalDurationSeconds,
    String? exerciseName,
  }) async {
    if (kIsWeb) return;
    if (exerciseName != null && exerciseName.isNotEmpty) {
      _activeExerciseName = exerciseName;
    }

    if (status == WorkoutTimerStatus.idle ||
        status == WorkoutTimerStatus.completed) {
      await dismiss();
      return;
    }

    // Rate-limit notifications to integer second changes
    if (remainingSeconds == _lastPublishedSeconds &&
        status == WorkoutTimerStatus.running) {
      return;
    }
    _lastPublishedSeconds = remainingSeconds;

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final persianTime = PersianUtils.toPersianDigits(timeStr);

    final isPaused = status == WorkoutTimerStatus.paused;

    final actions = <AndroidNotificationAction>[
      if (!isPaused)
        const AndroidNotificationAction(
          actionPause,
          'توقف موقت',
          showsUserInterface: false,
          cancelNotification: false,
        )
      else
        const AndroidNotificationAction(
          actionResume,
          'ادامه تایمر',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      const AndroidNotificationAction(
        actionCancel,
        'لغو و بستن',
        showsUserInterface: false,
        cancelNotification: true,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.workout,
      visibility: NotificationVisibility.public,
      actions: actions,
      styleInformation: BigTextStyleInformation(
        isPaused
            ? 'تایمر متوقف شده است: $persianTime • برای ادامه ست کلیک کنید'
            : 'زمان باقی‌مانده استراحت: $persianTime • ست بعدی را با تمرکز آغاز کنید',
        contentTitle: 'GymBro • $_activeExerciseName',
        summaryText: isPaused ? 'متوقف شد' : 'در حال استراحت ($persianTime)',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        liveNotificationId,
        'GymBro • $_activeExerciseName',
        isPaused ? 'متوقف شده: $persianTime' : 'زمان باقی‌مانده: $persianTime',
        notificationDetails,
      );
    } catch (_) {}
  }

  /// Cancels and removes the ongoing live notification
  Future<void> dismiss() async {
    _lastPublishedSeconds = -1;
    try {
      await _notificationsPlugin.cancel(liveNotificationId);
    } catch (_) {}
  }
}
