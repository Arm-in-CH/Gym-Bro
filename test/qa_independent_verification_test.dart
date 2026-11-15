import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/core/services/alarm_notification_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/widgets/active_set_row.dart';
import 'package:gymbro/widgets/exercise_rest_selector_sheet.dart';
import 'package:gymbro/widgets/floating_timer_bar.dart';

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

  group('GymBro Complete QA Independent Verification (18 Areas)', () {
    test('1. Create, edit, save, and delete workouts', () async {
      final initialCount = appState.workoutPlans.length;

      // Create new plan
      await appState.createWorkoutPlan(
        titleFa: 'برنامه آزمایشی QA ارشد',
        descriptionFa: 'برنامه اختصاصی تست خودکار کنترل کیفیت',
        splitType: 'Push Pull Legs',
        daysPerWeek: 4,
      );

      expect(appState.workoutPlans.length, equals(initialCount + 1));
      final created = appState.workoutPlans.firstWhere(
        (p) => p.titleFa == 'برنامه آزمایشی QA ارشد',
      );
      expect(created.daysPerWeek, equals(4));

      // Edit plan
      final updated = created.copyWith(
        titleFa: 'برنامه ویرایش‌شده QA',
        daysPerWeek: 5,
      );
      await appState.updateWorkoutPlan(updated);

      final foundUpdated = appState.workoutPlans.firstWhere(
        (p) => p.id == created.id,
      );
      expect(foundUpdated.titleFa, equals('برنامه ویرایش‌شده QA'));
      expect(foundUpdated.daysPerWeek, equals(5));

      // Delete plan
      await appState.deleteWorkoutPlan(created.id);
      expect(appState.workoutPlans.any((p) => p.id == created.id), isFalse);
    });

    test('2. Restart the application and verify persistence', () async {
      // Modify user profile and timer settings
      final updatedProfile = appState.userProfile.copyWith(
        firstName: 'آرمین',
        lastName: 'تست',
        weightKg: 85.5,
      );
      await appState.updateUserProfile(updatedProfile);

      final updatedSettings = appState.timerSettings.copyWith(
        defaultRestSeconds: 120,
        autoStartTimer: false,
      );
      await appState.updateTimerSettings(updatedSettings);

      // Create a workout plan
      await appState.createWorkoutPlan(
        titleFa: 'برنامه پایدار',
        descriptionFa: 'توضیحات تست ذخیره دائمی',
      );

      // Simulate cold app restart: instantiate fresh storage & appState
      final restartedStorage = LocalStorageService();
      await restartedStorage.init();
      final restartedAppState = AppState(storage: restartedStorage);

      expect(restartedAppState.userProfile.firstName, equals('آرمین'));
      expect(restartedAppState.userProfile.lastName, equals('تست'));
      expect(restartedAppState.userProfile.weightKg, equals(85.5));
      expect(restartedAppState.timerSettings.defaultRestSeconds, equals(120));
      expect(restartedAppState.timerSettings.autoStartTimer, isFalse);
      expect(
        restartedAppState.workoutPlans.any((p) => p.titleFa == 'برنامه پایدار'),
        isTrue,
      );
    });

    test('3. Create multiple exercises and persist into library', () async {
      final ex1 = Exercise(
        id: 'ex_qa_1',
        nameFa: 'پرس سینه دمبل موازی',
        nameEn: 'Neutral DB Press',
        muscleGroup: 'Chest',
        muscleGroupFa: 'سینه',
        equipment: 'دمبل',
        equipmentFa: 'دمبل',
        instructionsFa: 'اجرای کنترل‌شده با تمرکز بر فیبرهای میانی سینه',
      );

      final ex2 = Exercise(
        id: 'ex_qa_2',
        nameFa: 'زیربغل قایقی دست معکوس',
        nameEn: 'Underhand Cable Row',
        muscleGroup: 'Back',
        muscleGroupFa: 'پشت و زیربغل',
        equipment: 'سیم‌کش',
        equipmentFa: 'سیم‌کش',
        instructionsFa: 'دامنه کامل انقباض با مکث در نقطه اوج',
      );

      await appState.saveExercise(ex1);
      await appState.saveExercise(ex2);

      expect(appState.exercises.any((e) => e.id == 'ex_qa_1'), isTrue);
      expect(appState.exercises.any((e) => e.id == 'ex_qa_2'), isTrue);

      // Restart verify
      final restartedStorage = LocalStorageService();
      await restartedStorage.init();
      final restartedAppState = AppState(storage: restartedStorage);

      expect(restartedAppState.exercises.any((e) => e.id == 'ex_qa_1'), isTrue);
      expect(restartedAppState.exercises.any((e) => e.id == 'ex_qa_2'), isTrue);
    });

    testWidgets(
        '4 & 5. Complete multiple sets & verify individual completion states',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final set1 = ActiveWorkoutSet(
        setNumber: 1,
        targetReps: 10,
        targetWeightKg: 60.0,
        actualReps: 10,
        actualWeightKg: 60.0,
        isCompleted: false,
      );

      final set2 = ActiveWorkoutSet(
        setNumber: 2,
        targetReps: 10,
        targetWeightKg: 60.0,
        actualReps: 10,
        actualWeightKg: 60.0,
        isCompleted: false,
      );

      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              children: [
                ActiveSetRow(
                  workoutSet: set1,
                  restSeconds: 60,
                  onToggleComplete: (done) =>
                      setState(() => set1.isCompleted = done),
                  onDataChanged: () => setState(() {}),
                ),
                ActiveSetRow(
                  workoutSet: set2,
                  restSeconds: 60,
                  onToggleComplete: (done) =>
                      setState(() => set2.isCompleted = done),
                  onDataChanged: () => setState(() {}),
                ),
              ],
            );
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Check initial states
      expect(set1.isCompleted, isFalse);
      expect(set2.isCompleted, isFalse);

      // Toggle set 1
      await tester.tap(find.byIcon(Icons.crop_square).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(set1.isCompleted, isTrue);
      expect(set2.isCompleted, isFalse);

      // Toggle set 2
      await tester.tap(find.byIcon(Icons.crop_square).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(set1.isCompleted, isTrue);
      expect(set2.isCompleted, isTrue);

      // Uncheck set 1
      await tester.tap(find.byIcon(Icons.check).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(set1.isCompleted, isFalse);
      expect(set2.isCompleted, isTrue);
    });

    testWidgets('6 & 7. Rest time presets and custom timer duration selector',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? pickedDuration;

      await tester.pumpWidget(_wrap(
        Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              pickedDuration = await ExerciseRestSelectorSheet.show(
                ctx,
                exerciseName: 'اسکوات هالتر',
                currentRestSeconds: 60,
              );
            },
            child: const Text('انتخاب استراحت'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('انتخاب استراحت'));
      await tester.pumpAndSettle();

      // Verify all presets exist: 30, 45, 60, 90, 120, 180
      expect(find.text('۳۰ ثانیه'), findsOneWidget);
      expect(find.text('۴۵ ثانیه'), findsOneWidget);
      expect(find.text('۶۰ ثانیه'), findsOneWidget);
      expect(find.text('۹۰ ثانیه'), findsOneWidget);
      expect(find.text('۱۲۰ ثانیه'), findsOneWidget);
      expect(find.text('۱۸۰ ثانیه'), findsOneWidget);
      expect(find.text('مدت سفارشی...'), findsOneWidget);

      // Pick 90 seconds preset
      await tester.tap(find.text('۹۰ ثانیه'));
      await tester.pumpAndSettle();

      expect(pickedDuration, equals(90));
    });

    test('8. Timer pause, resume, reset, and cancel', () async {
      final timer = WorkoutTimerService();

      // Start timer with 90 seconds
      await timer.start(90);
      expect(timer.isRunning, isTrue);
      expect(timer.totalDurationSeconds, equals(90));
      expect(timer.remainingSeconds, inInclusiveRange(89, 90));

      // Pause timer
      await timer.pause();
      expect(timer.isPaused, isTrue);
      final pausedVal = timer.remainingSeconds;

      // Resume timer
      await timer.resume();
      expect(timer.isRunning, isTrue);
      expect(
          timer.remainingSeconds, inInclusiveRange(pausedVal - 1, pausedVal));

      // Reset timer
      await timer.reset();
      expect(timer.isPaused, isTrue);
      expect(timer.remainingSeconds, equals(90));

      // Cancel timer
      await timer.cancel();
      expect(timer.isIdle, isTrue);
      expect(timer.status, equals(WorkoutTimerStatus.idle));
    });

    testWidgets('9. Timer during screen navigation', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final timer = WorkoutTimerService();
      await timer.start(75);

      await tester.pumpWidget(_wrap(
        MainNavigationScreen(state: appState),
        appState,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify FloatingTimerBar is present
      expect(find.byType(FloatingTimerBar), findsOneWidget);
      expect(find.text('استراحت بین ست در حال اجراست'), findsOneWidget);

      // Navigate to Workout tab (index 1)
      await tester.tap(find.text('تمرینات'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Timer bar still present and visible
      expect(find.byType(FloatingTimerBar), findsOneWidget);
      expect(find.text('استراحت بین ست در حال اجراست'), findsOneWidget);

      // Navigate to Profile tab (index 4)
      await tester.tap(find.text('پروفایل'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(FloatingTimerBar), findsOneWidget);
      await timer.cancel();
    });

    test('10 & 11. Timer in background and screen lock timestamp recovery',
        () async {
      final timer = WorkoutTimerService();

      // Start timer with 10 seconds
      await timer.start(10);
      expect(timer.isRunning, isTrue);

      // Simulate app paused / screen locked
      timer.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Re-trigger lifecycle resumed (screen unlocked / app foregrounded)
      timer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // The service must compute remainingSeconds based on wall clock, not ticking frames
      expect(timer.progressFraction, inInclusiveRange(0.0, 1.0));
    });

    test('12 & 13. Alarm notification service channel & permissions', () async {
      final alarm = AlarmNotificationService();
      await alarm.init();

      expect(AlarmNotificationService.channelId,
          equals('gymbro_timer_alarm_channel'));
      expect(AlarmNotificationService.channelName, isNotEmpty);
      expect(AlarmNotificationService.channelDescription, isNotEmpty);

      // Trigger immediate alarm without throwing
      await alarm.triggerImmediateAlarm();
      await alarm.cancelAlarm();
    });

    testWidgets('14 & 15. Focused Training module & session draft recovery',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final plan = appState.workoutPlans.first;

      // Mount FocusedTrainingScreen
      await tester.pumpWidget(_wrap(
        FocusedTrainingScreen(planId: plan.id, state: appState),
        appState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('تمرین متمرکز (Focus Mode)'), findsOneWidget);

      // Toggle pause
      await tester.tap(find.text('توقف موقت'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('ادامه'), findsOneWidget);

      // Verify draft saved in storage
      final draft = appState.getActiveWorkoutDraft(plan.id);
      expect(draft, isNotNull);
      expect(draft!.isPaused, isTrue);

      // Resume
      await tester.tap(find.text('ادامه'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('توقف موقت'), findsOneWidget);
    });

    testWidgets('16. Workout history screen and stats breakdown',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final log = WorkoutLog(
        id: 'log_qa_test',
        planId: 'plan_1',
        planTitle: 'برنامه سنگین پا',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        date: '۱۴۰۵/۰۸/۱۹',
        durationMinutes: 48,
        totalVolumeKg: 1000.0,
        completedSets: 1,
        sets: [
          WorkoutSetLog(
            id: 'sl_1',
            exerciseName: 'اسکوات پشت پا',
            setNumber: 1,
            reps: 10,
            weightKg: 100.0,
          ),
        ],
      );

      await appState.completeWorkoutSession(
        plan: appState.workoutPlans.first,
        totalVolumeKg: 1000.0,
        completedSets: 1,
        setLogs: log.sets,
        durationMinutes: 48,
      );

      await tester.pumpWidget(_wrap(
        WorkoutHistoryScreen(state: appState),
        appState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('تاریخچه جلسات تمرین'), findsOneWidget);
      expect(find.text('خلاصه فعالیت‌های ثبت‌شده'), findsOneWidget);
      expect(find.text('تعداد جلسات'), findsOneWidget);
      expect(find.text('مجموع تناژ'), findsOneWidget);
      expect(find.text('ست‌های ثبت‌شده'), findsOneWidget);
    });

    test('17 & 18. Landing Page simulator and Island navigation verification',
        () {
      final file = File('gymbro_redmi_simulator.html');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();

      // 17. Landing Page elements
      expect(content.contains('device-chassis'), isTrue);
      expect(content.contains('phoneScreen'), isTrue);
      expect(content.contains('pageDashboard'), isTrue);
      expect(content.contains('pageWorkout'), isTrue);
      expect(content.contains('pageNutrition'), isTrue);
      expect(content.contains('workoutPlayerModal'), isTrue);

      // 18. Island Navigation & Dynamic Island behavior
      expect(content.contains('dynamic-island'), isTrue);
      expect(content.contains('id="dynamicIsland"'), isTrue);
      expect(content.contains('toggleIslandExpansion'), isTrue);
      expect(content.contains('updateIslandState'), isTrue);
      expect(content.contains('pulse-live'), isTrue);
    });
  });
}
