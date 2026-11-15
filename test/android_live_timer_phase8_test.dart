import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/services/android_device_capability_service.dart';
import 'package:gymbro/core/services/android_live_timer_notification_service.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await WorkoutTimerService().cancel();
    await AndroidLiveTimerNotificationService().dismiss();
  });

  group('GymBro Phase 8: Android Device Capability & Info Tests', () {
    test(
        'AndroidDeviceInfo fallback returns valid defaults in test environment',
        () {
      final info = AndroidDeviceInfo.fallback();
      expect(info.manufacturer, equals('Android Device'));
      expect(info.sdkInt, equals(34));
      expect(info.isXiaomi, isFalse);
      expect(info.isSamsung, isFalse);
      expect(info.systemUiLabel, contains('Android'));
      expect(info.backgroundReliabilityStatusFa, contains('پایدار'));
    });

    test('AndroidDeviceInfo parses Xiaomi HyperOS device accurately', () {
      final map = {
        'manufacturer': 'Xiaomi',
        'model': '23127PN0CG',
        'brand': 'Xiaomi',
        'device': 'houji',
        'androidVersion': '14',
        'sdkInt': 34,
        'isXiaomi': true,
        'isHyperOs': true,
        'hyperOsVersion': '1.0.14.0.UNAMIXM',
        'miuiVersion': '14',
        'isSamsung': false,
        'oneUiVersion': null,
        'isPixel': false,
        'isIgnoringBatteryOptimizations': false,
        'areNotificationsEnabled': true,
        'canScheduleExactAlarms': true,
      };

      final info = AndroidDeviceInfo.fromMap(map);
      expect(info.isXiaomi, isTrue);
      expect(info.isHyperOs, isTrue);
      expect(info.supportsXiaomiFocusNotification, isTrue);
      expect(info.systemUiLabel, contains('HyperOS'));
      expect(info.backgroundReliabilityStatusFa, contains('شیائومی'));
    });

    test('AndroidDeviceInfo parses Samsung One UI device accurately', () {
      final map = {
        'manufacturer': 'Samsung',
        'model': 'SM-S928B',
        'brand': 'samsung',
        'device': 'e3q',
        'androidVersion': '14',
        'sdkInt': 34,
        'isXiaomi': false,
        'isHyperOs': false,
        'miuiVersion': null,
        'hyperOsVersion': null,
        'isSamsung': true,
        'oneUiVersion': 'One UI 6.1',
        'isPixel': false,
        'isIgnoringBatteryOptimizations': false,
        'areNotificationsEnabled': true,
        'canScheduleExactAlarms': true,
      };

      final info = AndroidDeviceInfo.fromMap(map);
      expect(info.isSamsung, isTrue);
      expect(info.supportsSamsungLiveWidget, isTrue);
      expect(info.systemUiLabel, contains('One UI 6.1'));
      expect(info.backgroundReliabilityStatusFa, contains('سامسونگ'));
    });

    test('AndroidDeviceInfo handles disabled notifications diagnostic', () {
      final map = {
        'manufacturer': 'Google',
        'model': 'Pixel 8',
        'brand': 'google',
        'device': 'shiba',
        'androidVersion': '14',
        'sdkInt': 34,
        'isXiaomi': false,
        'isHyperOs': false,
        'isSamsung': false,
        'isPixel': true,
        'isIgnoringBatteryOptimizations': true,
        'areNotificationsEnabled': false,
        'canScheduleExactAlarms': true,
      };

      final info = AndroidDeviceInfo.fromMap(map);
      expect(info.backgroundReliabilityStatusFa,
          contains('مجوز اعلان‌ها صادر نشده است'));
    });
  });

  group('GymBro Phase 8: Android Live Timer Ongoing Notification Tests', () {
    test('AndroidLiveTimerNotificationService initializes safely', () async {
      final service = AndroidLiveTimerNotificationService();
      await service.init();
      expect(service, isNotNull);
    });

    test('AndroidLiveTimerNotificationService updates and dismisses gracefully',
        () async {
      final service = AndroidLiveTimerNotificationService();
      service.setActiveExerciseName('پرس سینه هالتر');

      // Update when running
      await service.updateLiveNotification(
        status: WorkoutTimerStatus.running,
        remainingSeconds: 75,
        totalDurationSeconds: 90,
      );

      // Update when paused
      await service.updateLiveNotification(
        status: WorkoutTimerStatus.paused,
        remainingSeconds: 45,
        totalDurationSeconds: 90,
      );

      // Dismiss on completed
      await service.updateLiveNotification(
        status: WorkoutTimerStatus.completed,
        remainingSeconds: 0,
        totalDurationSeconds: 90,
      );

      // Clean dismiss
      await service.dismiss();
    });

    test('Action callbacks route to WorkoutTimerService methods safely',
        () async {
      final service = AndroidLiveTimerNotificationService();
      final timer = WorkoutTimerService();

      await timer.start(60);
      expect(timer.isRunning, isTrue);

      // Action: Pause
      await service.handleNotificationAction(
          AndroidLiveTimerNotificationService.actionPause);
      expect(timer.isPaused, isTrue);

      // Action: Resume
      await service.handleNotificationAction(
          AndroidLiveTimerNotificationService.actionResume);
      expect(timer.isRunning, isTrue);

      // Action: Cancel
      await service.handleNotificationAction(
          AndroidLiveTimerNotificationService.actionCancel);
      expect(timer.isIdle, isTrue);
    });
  });

  group(
      'GymBro Phase 8: WorkoutTimerService Live Notification Integration Tests',
      () {
    test(
        'WorkoutTimerService starts with exerciseName and updates live notification',
        () async {
      final timer = WorkoutTimerService();
      await timer.init();

      await timer.start(90, exerciseName: 'اسکوات پا با هالتر');
      expect(timer.isRunning, isTrue);
      expect(timer.remainingSeconds, inInclusiveRange(89, 90));

      await timer.pause();
      expect(timer.isPaused, isTrue);

      await timer.resume();
      expect(timer.isRunning, isTrue);

      await timer.addSeconds(15);
      expect(timer.remainingSeconds, greaterThanOrEqualTo(95));

      await timer.cancel();
      expect(timer.isIdle, isTrue);
    });
  });
}
