import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/widgets/floating_timer_bar.dart';

class _MockStorageService extends LocalStorageService {
  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'plan_test',
          titleFa: 'برنامه حرفه‌ای تست',
          titleEn: 'Pro Test Plan',
          descriptionFa: 'تست تمرین زنده و تایمر',
          splitType: 'PPL',
          daysPerWeek: 3,
          difficulty: 'پیشرفته',
          exercises: [
            WorkoutPlanExercise(
              id: 'pe_bench',
              planId: 'plan_test',
              exerciseId: 'ex_bench',
              dayOfWeek: 1,
              dayNameFa: 'روز اول',
              orderInDay: 1,
              targetSets: 3,
              targetReps: 10,
              targetWeightKg: 80.0,
              restSeconds: 90,
            ),
            WorkoutPlanExercise(
              id: 'pe_incline',
              planId: 'plan_test',
              exerciseId: 'ex_incline',
              dayOfWeek: 1,
              dayNameFa: 'روز اول',
              orderInDay: 2,
              targetSets: 3,
              targetReps: 12,
              targetWeightKg: 60.0,
              restSeconds: 60,
            ),
          ],
        ),
      ];

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex_bench',
          nameFa: 'پرس سینه هالتر',
          nameEn: 'Barbell Bench Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر',
          instructionsFa: 'میله را تا سینه پایین بیاورید.',
        ),
        Exercise(
          id: 'ex_incline',
          nameFa: 'پرس بالاسینه دمبل',
          nameEn: 'Incline Dumbbell Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'بالا سینه',
          equipment: 'Dumbbell',
          equipmentFa: 'دمبل',
          instructionsFa: 'روی میز شیبدار دمبل‌ها را به بالا پرس کنید.',
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockStorageService storage;
  late AppState appState;
  final timerService = WorkoutTimerService();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = _MockStorageService();
    await storage.init();
    appState = AppState(storage: storage);
    await timerService.cancel();
  });

  tearDown(() async {
    await timerService.cancel();
  });

  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }

  group('GymBro Phase 20: Active Workout, Timer & Focused Training Tests', () {
    test('1. Timer Reliability: Start, Pause, Resume, Reset, and AddSeconds',
        () async {
      // 1. Start timer with 90s
      await timerService.start(90, exerciseName: 'پرس سینه هالتر');
      expect(timerService.isRunning, isTrue);
      expect(timerService.totalDurationSeconds, 90);
      expect(timerService.remainingSeconds, inInclusiveRange(89, 90));

      // 2. Pause
      await timerService.pause();
      expect(timerService.isPaused, isTrue);
      final pausedVal = timerService.remainingSeconds;

      // 3. Add 15 seconds (+15s) while paused
      await timerService.addSeconds(15);
      expect(timerService.totalDurationSeconds, 105);
      expect(timerService.remainingSeconds, pausedVal + 15);

      // 4. Resume
      await timerService.resume();
      expect(timerService.isRunning, isTrue);

      // 5. Add 30 seconds while running
      await timerService.addSeconds(30);
      expect(timerService.totalDurationSeconds, 135);

      // 6. Reset
      await timerService.reset();
      expect(timerService.isPaused, isTrue);
      expect(timerService.remainingSeconds, 135);

      // 7. Cancel
      await timerService.cancel();
      expect(timerService.isIdle, isTrue);
    });

    testWidgets('2. RestTimerDialog UI: Renders arc, numbers, presets, and +15s',
        (tester) async {
      await timerService.start(60);
      await tester.pumpWidget(wrapWithTheme(
        const Scaffold(
          body: RestTimerDialog(initialSeconds: 60),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('تایمر استراحت بین ست'), findsOneWidget);
      expect(find.text('+۱۵ ثانیه'), findsOneWidget);
      expect(find.text('+۳۰ ثانیه'), findsOneWidget);
      expect(find.text('رد کردن استراحت'), findsOneWidget);

      // Tap +15s button
      await tester.tap(find.text('+۱۵ ثانیه'));
      await tester.pumpAndSettle();
      expect(timerService.totalDurationSeconds, 75);

      // Tap Skip Rest
      await tester.tap(find.text('رد کردن استراحت'));
      await tester.pumpAndSettle();
      expect(timerService.isIdle, isTrue);
    });

    testWidgets('3. FloatingTimerBar: Displays countdown and inline actions',
        (tester) async {
      await timerService.start(45);
      await tester.pumpWidget(wrapWithTheme(
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingTimerBar(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('استراحت بین ست در حال اجراست'), findsOneWidget);

      // Tap pause on floating bar
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();
      expect(timerService.isPaused, isTrue);

      // Tap resume on floating bar
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(timerService.isRunning, isTrue);

      // Close timer
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(timerService.isIdle, isTrue);
    });

    testWidgets(
        '4. ActiveWorkoutScreen: Displays Active Exercise badge, previous set hint & next exercise',
        (tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ActiveWorkoutScreen(planId: 'plan_test', state: appState),
      ));
      await tester.pumpAndSettle();

      // Check Active Exercise badge
      expect(find.text('در حال اجرا'), findsOneWidget);
      expect(find.textContaining('حرکت بعدی:'), findsOneWidget);

      // Check sets rendered
      expect(find.text('هدف برنامه'), findsAtLeastNWidgets(1));

      // Complete Set 1
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      // Set 2 & Set 3 have Previous Set hints
      expect(find.textContaining('قبل: ۸۰kg × ۱۰'), findsWidgets);
    });

    testWidgets(
        '5. FocusedTrainingScreen: Renders round pills and quick adjust buttons',
        (tester) async {
      await tester.pumpWidget(wrapWithTheme(
        FocusedTrainingScreen(planId: 'plan_test', state: appState),
      ));
      await tester.pumpAndSettle();

      // Exercise title
      expect(find.text('پرس سینه هالتر'), findsWidgets);

      // Round indicator
      expect(find.text('وضعیت ست‌ها:'), findsOneWidget);

      // Weight adjustment pills
      expect(find.text('+۲.۵'), findsOneWidget);
      expect(find.text('-۲.۵'), findsOneWidget);

      // Tap +2.5kg
      await tester.tap(find.text('+۲.۵'));
      await tester.pumpAndSettle();
      expect(find.textContaining('۸۲.۵'), findsOneWidget);

      // Scroll into view & tap Complete Set 1
      final completeBtn = find.text('ثبت ست ۱ (تکمیل شد)');
      await tester.ensureVisible(completeBtn);
      await tester.pumpAndSettle();
      await tester.tap(completeBtn);
      await tester.pumpAndSettle();

      // Next set should be Set 2
      expect(find.text('ثبت ست ۲ (تکمیل شد)'), findsOneWidget);
    });

    testWidgets(
        '6. Safety: Discard vs Save exit confirmation protects workout draft',
        (tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ActiveWorkoutScreen(planId: 'plan_test', state: appState),
      ));
      await tester.pumpAndSettle();

      // Complete Set 1
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Simulate system back button / pop invocation
      final dynamic popScope =
          tester.widget(find.byWidgetPredicate((w) => w is PopScope));
      popScope.onPopInvokedWithResult(false, null);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('خروج از تمرین زنده'), findsOneWidget);
      expect(find.text('ذخیره و خروج'), findsOneWidget);
      expect(find.text('حذف پیش‌نویس و لغو'), findsOneWidget);
      expect(find.text('ادامه تمرین'), findsOneWidget);

      // Tap 'ادامه تمرین' cancels exit
      await tester.tap(find.text('ادامه تمرین'));
      await tester.pumpAndSettle();
      expect(find.text('خروج از تمرین زنده'), findsNothing);
    });

    testWidgets('7. Workout pause and resume persist active elapsed time',
        (tester) async {
      var now = DateTime(2026, 11, 10, 10);
      await tester.pumpWidget(wrapWithTheme(
        ActiveWorkoutScreen(
          planId: 'plan_test',
          state: appState,
          clock: () => now,
        ),
      ));
      await tester.pumpAndSettle();

      now = now.add(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const ValueKey('workout-pause-resume')));
      await tester.pumpAndSettle();

      final pausedDraft = appState.getActiveWorkoutDraft('plan_test');
      expect(pausedDraft?.isPaused, isTrue);
      final pausedElapsed = pausedDraft!.pausedElapsedSeconds;
      expect(pausedElapsed, greaterThanOrEqualTo(3));

      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('۰۰:۰۳'), findsOneWidget);
      expect(appState.getActiveWorkoutDraft('plan_test')?.pausedElapsedSeconds,
          pausedElapsed);

      await tester.tap(find.byKey(const ValueKey('workout-pause-resume')));
      await tester.pumpAndSettle();
      expect(appState.getActiveWorkoutDraft('plan_test')?.isPaused, isFalse);

      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('۰۰:۰۵'), findsOneWidget);
    });

    testWidgets('8. Focus Mode pauses and resumes the shared session clock',
        (tester) async {
      var now = DateTime(2026, 11, 10, 10);
      await tester.pumpWidget(wrapWithTheme(
        FocusedTrainingScreen(
          planId: 'plan_test',
          state: appState,
          clock: () => now,
        ),
      ));
      await tester.pumpAndSettle();

      now = now.add(const Duration(seconds: 17));
      await tester.pump(const Duration(seconds: 17));
      expect(find.text('۰۰:۱۷'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('focused-workout-pause-resume')),
      );
      await tester.pumpAndSettle();
      expect(appState.getActiveWorkoutDraft('plan_test')?.isPaused, isTrue);

      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('۰۰:۱۷'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('focused-workout-pause-resume')),
      );
      await tester.pumpAndSettle();
      expect(appState.getActiveWorkoutDraft('plan_test')?.isPaused, isFalse);

      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('۰۰:۲۲'), findsOneWidget);
    });

    testWidgets('9. Focus Mode exits an empty session without logging it',
        (tester) async {
      await tester.pumpWidget(wrapWithTheme(
        FocusedTrainingScreen(planId: 'plan_test', state: appState),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('اتمام تمرین و ذخیره در تاریخچه'));
      await tester.pumpAndSettle();
      expect(find.text('پایان تمرین بدون ست ثبت‌شده'), findsOneWidget);

      await tester.tap(find.text('خروج بدون ثبت'));
      await tester.pumpAndSettle();

      expect(appState.workoutLogs, isEmpty);
      expect(appState.getActiveWorkoutDraft('plan_test'), isNull);
    });
  });
}
