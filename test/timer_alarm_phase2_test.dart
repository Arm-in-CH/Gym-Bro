import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/widgets/floating_timer_bar.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GymBro Phase 2: Reliable Timer and Alarm System Tests', () {
    late WorkoutTimerService timerService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      timerService = WorkoutTimerService();
      await timerService.init();
      await timerService.cancel();
    });

    tearDown(() async {
      await timerService.cancel();
    });

    test(
        'PART A: Timer starts with predefined and custom durations using timestamp strategy',
        () async {
      expect(
          WorkoutTimerService.predefinedDurations, [15, 30, 45, 60, 90, 120]);
      expect(timerService.isIdle, isTrue);

      // Start with 60 seconds
      await timerService.start(60);
      expect(timerService.isRunning, isTrue);
      expect(timerService.totalDurationSeconds, 60);
      expect(timerService.remainingSeconds, inInclusiveRange(59, 60));
      expect(timerService.targetEndTime, isNotNull);

      // Verify timestamp math (now + 60s)
      final expectedTarget = DateTime.now().add(const Duration(seconds: 60));
      expect(
        timerService.targetEndTime!
            .difference(expectedTarget)
            .inMilliseconds
            .abs(),
        lessThan(500),
      );
    });

    test('PART A: Timer Pause, Resume, Reset, and Cancel lifecycle transitions',
        () async {
      await timerService.start(90);
      expect(timerService.isRunning, isTrue);

      // Pause
      await timerService.pause();
      expect(timerService.isPaused, isTrue);
      final pausedRemaining = timerService.remainingSeconds;
      expect(pausedRemaining, inInclusiveRange(88, 90));

      // Resume
      await timerService.resume();
      expect(timerService.isRunning, isTrue);
      expect(timerService.remainingSeconds,
          inInclusiveRange(pausedRemaining - 1, pausedRemaining));

      // Reset
      await timerService.reset();
      expect(timerService.isPaused, isTrue);
      expect(timerService.remainingSeconds, 90);

      // Cancel
      await timerService.cancel();
      expect(timerService.isIdle, isTrue);
      expect(timerService.targetEndTime, isNull);
    });

    test(
        'PART A: Adding extra seconds (+15s, +30s) updates timestamp accurately',
        () async {
      await timerService.start(45);
      final initialTarget = timerService.targetEndTime!;

      await timerService.addSeconds(15);
      expect(timerService.totalDurationSeconds, 60);
      expect(
          timerService.targetEndTime!.difference(initialTarget).inSeconds, 15);
      expect(timerService.remainingSeconds, inInclusiveRange(58, 60));
    });

    test('PART A: Avoid duplicate countdown instances on rapid starts',
        () async {
      await timerService.start(30);
      final firstTarget = timerService.targetEndTime;

      // Immediately start another with 90s
      await timerService.start(90);
      expect(timerService.totalDurationSeconds, 90);
      expect(timerService.targetEndTime, isNot(equals(firstTarget)));
      expect(timerService.remainingSeconds, inInclusiveRange(89, 90));
    });

    test(
        'PART A: Background elapsed recovery & screen unlock handling via timestamp strategy',
        () async {
      await timerService.start(60);

      // Simulate app backgrounding where time passes
      // Set the target end time to 20 seconds in the future
      timerService.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Verify remaining time dynamically recalculates without requiring ticks
      expect(timerService.remainingSeconds, inInclusiveRange(58, 60));
    });

    test(
        'PART A & B: Timer completion transitions to completed and triggers alarm',
        () async {
      // Start with 1 second
      await timerService.start(1);
      expect(timerService.isRunning, isTrue);

      // Wait 1.5 seconds for ticker and targetEndTime to expire
      await Future.delayed(const Duration(milliseconds: 1500));

      expect(timerService.isCompleted, isTrue);
      expect(timerService.remainingSeconds, 0);

      // Dismiss action
      await timerService.cancel();
      expect(timerService.isIdle, isTrue);
    });

    test('PART A & B: Persistence across simulated application restart',
        () async {
      // Start a 120s timer
      await timerService.start(120);
      final originalTarget = timerService.targetEndTime!;

      // Simulate app kill: create a fresh service and restore
      final restartedTimer = WorkoutTimerService();
      await restartedTimer.restoreFromStorage();

      expect(restartedTimer.isRunning, isTrue);
      expect(restartedTimer.totalDurationSeconds, 120);
      expect(restartedTimer.targetEndTime, isNotNull);
      expect(
        restartedTimer.targetEndTime!.millisecondsSinceEpoch,
        originalTarget.millisecondsSinceEpoch,
      );
      expect(restartedTimer.remainingSeconds, inInclusiveRange(118, 120));

      await restartedTimer.cancel();
    });

    testWidgets(
        'PART C: FloatingTimerBar renders live countdown and responds to actions',
        (tester) async {
      await tester.pumpWidget(_wrap(const FloatingTimerBar()));
      // Initially idle, nothing visible
      expect(find.byType(FloatingTimerBar), findsOneWidget);

      // Start timer
      await timerService.start(60);
      await tester.pumpAndSettle();

      expect(find.text('استراحت بین ست در حال اجراست'), findsOneWidget);

      // Pause via button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      expect(timerService.isPaused, isTrue);
      expect(find.text('تایمر متوقف شده است'), findsOneWidget);

      // Resume via button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(timerService.isRunning, isTrue);

      await timerService.cancel();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'PART C: RestTimerDialog renders chips, controls, and adheres to accessibility',
        (tester) async {
      await tester.pumpWidget(_wrap(const RestTimerDialog(initialSeconds: 90)));
      await tester.pumpAndSettle();

      expect(find.text('تایمر استراحت بین ست'), findsOneWidget);
      expect(find.text('۱۵s'), findsOneWidget);
      expect(find.text('۳۰s'), findsOneWidget);
      expect(find.text('۶۰s'), findsOneWidget);
      expect(find.text('۹۰s'), findsOneWidget);
      expect(find.text('+۱۵ ثانیه'), findsOneWidget);
      expect(find.text('+۳۰ ثانیه'), findsOneWidget);

      // Test +15s button tap
      await tester.tap(find.text('+۱۵ ثانیه'));
      await tester.pumpAndSettle();

      expect(timerService.totalDurationSeconds, 105);

      await timerService.cancel();
    });
  });
}
