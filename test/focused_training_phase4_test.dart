import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/active_workout_progress.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';

Widget _wrap(Widget child, [AppState? state]) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState appState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    appState = AppState(storage: storage);
  });

  tearDown(() async {
    await WorkoutTimerService().cancel();
  });

  group('GymBro Phase 4: Focused Training Module & History Tests', () {
    testWidgets(
      'Feature 1, 2, 3 & 4: FocusedTrainingScreen mounts with workout info, exercise list and exercise details',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final plan = appState.workoutPlans.first;

        await tester.pumpWidget(_wrap(
          FocusedTrainingScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // 1. Current workout information
        expect(find.text('تمرین متمرکز (Focus Mode)'), findsOneWidget);
        expect(find.textContaining(plan.titleFa), findsOneWidget);
        expect(find.text('مدت جلسه: '), findsOneWidget);

        // 2. Exercise Stepper / List
        final firstEx = plan.exercises.first;
        final exDetail =
            appState.exercises.firstWhere((e) => e.id == firstEx.exerciseId);
        expect(find.text(exDetail.nameFa), findsWidgets);

        // 3. Current exercise details
        expect(find.text('${exDetail.muscleGroupFa} • ${exDetail.equipmentFa}'),
            findsOneWidget);
        expect(find.textContaining('استراحت:'), findsWidgets);

        // 4. Quick adjustment panel for active set 1
        expect(find.textContaining('تنظیم سریع ست فعال'), findsOneWidget);
        expect(find.text('+۲.۵'), findsOneWidget);
        expect(find.text('-۲.۵'), findsOneWidget);
        expect(find.text('+۱'), findsOneWidget);
        expect(find.text('-۱'), findsOneWidget);
      },
    );

    testWidgets(
      'Feature 5, 8 & 9: Quick set tracking, progress calculation, and completed exercise tracking',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final plan = appState.workoutPlans.first;

        await tester.pumpWidget(_wrap(
          FocusedTrainingScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // Check initial weight adjustment
        final initialCompleteButton = find.text('ثبت ست ۱ (تکمیل شد)');
        expect(initialCompleteButton, findsOneWidget);

        // Tap +5kg
        await tester.tap(find.text('+۵'));
        await tester.pumpAndSettle();

        // Tap +2 reps
        await tester.tap(find.text('+۲'));
        await tester.pumpAndSettle();

        // Tap complete set 1
        await tester.tap(initialCompleteButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Now button targets set 2
        expect(find.text('ثبت ست ۲ (تکمیل شد)'), findsOneWidget);

        // Complete set 2
        await tester.tap(find.text('ثبت ست ۲ (تکمیل شد)'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Complete set 3
        if (find.text('ثبت ست ۳ (تکمیل شد)').evaluate().isNotEmpty) {
          await tester.tap(find.text('ثبت ست ۳ (تکمیل شد)'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        }

        // Exercise all done banner should appear
        expect(find.text('تمام ست‌های این حرکت با موفقیت به پایان رسید!'),
            findsOneWidget);
        expect(find.text('حرکت بعدی'), findsWidgets);
      },
    );

    testWidgets(
      'Feature 7 & 10: Focus timer and pause/resume functionality',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final plan = appState.workoutPlans.first;

        await tester.pumpWidget(_wrap(
          FocusedTrainingScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // Initially in running state, pause button is visible
        final pauseButton = find.text('توقف موقت');
        expect(pauseButton, findsOneWidget);

        // Tap Pause
        await tester.tap(pauseButton);
        await tester.pumpAndSettle();

        // Button label switches to Resume ('ادامه')
        expect(find.text('ادامه'), findsOneWidget);

        // Tap Resume
        await tester.tap(find.text('ادامه'));
        await tester.pumpAndSettle();

        expect(find.text('توقف موقت'), findsOneWidget);
      },
    );

    testWidgets(
      'Functional Requirement: Persist and restore unfinished focused training session',
      (tester) async {
        final plan = appState.workoutPlans.first;
        final ex1 = plan.exercises.first;

        // Save a draft with 2 sets completed and 350 seconds elapsed
        final draft = ActiveWorkoutProgress(
          planId: plan.id,
          selectedDay: 1,
          startTimeEpoch: DateTime.now().millisecondsSinceEpoch - 350000,
          exerciseSets: {
            ex1.id: [
              ActiveWorkoutSet(
                setNumber: 1,
                targetReps: 10,
                targetWeightKg: 60.0,
                actualReps: 10,
                actualWeightKg: 65.0,
                isCompleted: true,
              ),
              ActiveWorkoutSet(
                setNumber: 2,
                targetReps: 10,
                targetWeightKg: 60.0,
                actualReps: 10,
                actualWeightKg: 65.0,
                isCompleted: true,
              ),
              ActiveWorkoutSet(
                setNumber: 3,
                targetReps: 10,
                targetWeightKg: 60.0,
                actualReps: 10,
                actualWeightKg: 60.0,
                isCompleted: false,
              ),
            ],
          },
          exerciseRestSeconds: {
            ex1.id: 90,
          },
          isPaused: true,
          pausedElapsedSeconds: 350,
        );

        await appState.saveActiveWorkoutDraft(draft);

        // Mount FocusedTrainingScreen
        await tester.pumpWidget(_wrap(
          FocusedTrainingScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // Restored paused state & elapsed time (350s = 05:50)
        expect(find.text('ادامه'), findsOneWidget);
        expect(find.textContaining('۰۵:۵۰'), findsOneWidget);

        // Next set to complete is set 3
        expect(find.text('ثبت ست ۳ (تکمیل شد)'), findsOneWidget);
      },
    );

    testWidgets(
      'Complete Training Flow: Start focused workout, finish session, and review in WorkoutHistoryScreen',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final plan = appState.workoutPlans.first;

        await tester.pumpWidget(_wrap(
          FocusedTrainingScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // Complete Set 1
        await tester.tap(find.text('ثبت ست ۱ (تکمیل شد)'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Complete Set 2
        await tester.tap(find.text('ثبت ست ۲ (تکمیل شد)'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Finish session button in bottom bar
        final finishBtn = find.text('اتمام تمرین و ذخیره در تاریخچه');
        await tester.tap(finishBtn);
        await tester.pumpAndSettle();

        // Celebratory dialog appears
        expect(find.text('جلسه تمرین ثبت شد'), findsOneWidget);
        expect(find.text('مشاهده در تاریخچه'), findsOneWidget);

        // Tap "مشاهده در تاریخچه" (View in History)
        await tester.tap(find.text('مشاهده در تاریخچه'));
        await tester.pumpAndSettle();

        // Verify WorkoutHistoryScreen is now displayed
        expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
        expect(find.text('تاریخچه جلسات تمرین'), findsOneWidget);
        expect(find.text(plan.titleFa), findsOneWidget);
        expect(find.text('تعداد جلسات'), findsOneWidget);
      },
    );

    testWidgets(
      'Feature 12: WorkoutHistoryScreen expands detailed exercise set breakdown',
      (tester) async {
        // Preload completed workout session
        final log = WorkoutLog(
          id: 'log_test_1',
          planId: 'p1',
          planTitle: 'برنامه فوق‌حرفه‌ای پا و شکم',
          date: '۱۴۰۳/۰۸/۱۹',
          durationMinutes: 45,
          totalVolumeKg: 3200.0,
          completedSets: 8,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          sets: [
            WorkoutSetLog(
              id: 's1',
              exerciseName: 'اسکات پا با هالتر',
              setNumber: 1,
              reps: 10,
              weightKg: 100.0,
            ),
            WorkoutSetLog(
              id: 's2',
              exerciseName: 'اسکات پا با هالتر',
              setNumber: 2,
              reps: 8,
              weightKg: 110.0,
            ),
          ],
        );

        await storage.saveWorkoutLog(log);
        final historyState = AppState(storage: storage);

        await tester.pumpWidget(_wrap(
          WorkoutHistoryScreen(state: historyState),
          historyState,
        ));
        await tester.pumpAndSettle();

        // History summary
        expect(find.text('برنامه فوق‌حرفه‌ای پا و شکم'), findsOneWidget);
        expect(find.text('۳۲۰۰ kg'), findsOneWidget);
        expect(find.text('۸ ست'), findsNWidgets(2));

        // Tap card to expand detailed set log breakdown
        await tester.tap(find.text('برنامه فوق‌حرفه‌ای پا و شکم'));
        await tester.pumpAndSettle();

        // Expanded view shows exercise name and sets
        expect(find.text('اسکات پا با هالتر'), findsWidgets);
        expect(find.textContaining('۱۰۰kg × ۱۰'), findsOneWidget);
        expect(find.textContaining('۱۱۰kg × ۸'), findsOneWidget);
      },
    );
  });
}
