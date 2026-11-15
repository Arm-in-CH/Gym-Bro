import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/storage/id_generator.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/active_workout_progress.dart';
import 'package:gymbro/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GymBro Phase 1: Complete Data Persistence & Lifecycle Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'Requirement 1, 3, 4, 5, 6: Create new workout and restore across application restart',
        () async {
      // 1. Initial Launch
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      final initialPlanCount = appState1.workoutPlans.length;
      final benchPressEx = appState1.exercises
          .firstWhere((e) => e.id == 'ex_bench_press_pyramid');
      final squatEx = appState1.exercises.firstWhere((e) => e.id == 'ex_squat');

      final customExercises = [
        WorkoutPlanExercise(
          id: IdGenerator.planExercise(),
          planId: '',
          exerciseId: benchPressEx.id,
          dayOfWeek: 1,
          dayNameFa: 'روز ۱: قدرت سینه',
          orderInDay: 1,
          targetSets: 4,
          targetReps: 8,
          targetWeightKg: 85.0,
          restSeconds: 120,
        ),
        WorkoutPlanExercise(
          id: IdGenerator.planExercise(),
          planId: '',
          exerciseId: squatEx.id,
          dayOfWeek: 1,
          dayNameFa: 'روز ۱: قدرت سینه',
          orderInDay: 2,
          targetSets: 5,
          targetReps: 5,
          targetWeightKg: 110.0,
          restSeconds: 180,
        ),
      ];

      // Create new workout
      await appState1.createWorkoutPlan(
        titleFa: 'برنامه قدرتی ۵×۵ اختصاصی',
        titleEn: '5x5 Strength Routine',
        descriptionFa: 'تمرکز بر بارهای سنگین و افزایش رکورد',
        splitType: 'Upper / Lower',
        daysPerWeek: 4,
        difficulty: 'پیشرفته',
        exercises: customExercises,
      );

      expect(appState1.workoutPlans.length, initialPlanCount + 1);
      final createdPlan = appState1.workoutPlans.firstWhere(
        (p) => p.titleFa == 'برنامه قدرتی ۵×۵ اختصاصی',
      );
      expect(createdPlan.exercises.length, 2);
      expect(createdPlan.exercises[0].orderInDay, 1);
      expect(createdPlan.exercises[0].targetWeightKg, 85.0);
      expect(createdPlan.exercises[0].restSeconds, 120);
      expect(createdPlan.exercises[1].orderInDay, 2);
      expect(createdPlan.exercises[1].targetWeightKg, 110.0);
      expect(createdPlan.exercises[1].restSeconds, 180);

      final createdId = createdPlan.id;

      // 2. SIMULATE FULL APP RESTART
      // Create new LocalStorageService and new AppState instance
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      // Verify the new workout is completely restored
      expect(appState2.workoutPlans.length, initialPlanCount + 1);
      final restoredPlan =
          appState2.workoutPlans.firstWhere((p) => p.id == createdId);
      expect(restoredPlan.titleFa, 'برنامه قدرتی ۵×۵ اختصاصی');
      expect(restoredPlan.titleEn, '5x5 Strength Routine');
      expect(restoredPlan.difficulty, 'پیشرفته');
      expect(restoredPlan.daysPerWeek, 4);
      expect(restoredPlan.exercises.length, 2);

      // Verify exercise list, ordering, sets, repetitions, weights, and rest durations
      expect(restoredPlan.exercises[0].exerciseId, benchPressEx.id);
      expect(restoredPlan.exercises[0].orderInDay, 1);
      expect(restoredPlan.exercises[0].targetSets, 4);
      expect(restoredPlan.exercises[0].targetReps, 8);
      expect(restoredPlan.exercises[0].targetWeightKg, 85.0);
      expect(restoredPlan.exercises[0].restSeconds, 120);

      expect(restoredPlan.exercises[1].exerciseId, squatEx.id);
      expect(restoredPlan.exercises[1].orderInDay, 2);
      expect(restoredPlan.exercises[1].targetSets, 5);
      expect(restoredPlan.exercises[1].targetReps, 5);
      expect(restoredPlan.exercises[1].targetWeightKg, 110.0);
      expect(restoredPlan.exercises[1].restSeconds, 180);
    });

    test(
        'Requirement 2 & 4: Edit workout, modify weights, reorder exercises, and restore across restart',
        () async {
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      // Pick an existing plan
      final targetPlan = appState1.workoutPlans.first;
      final originalExerciseCount = targetPlan.exercises.length;

      // Edit plan metadata
      final editedPlan = targetPlan.copyWith(
        titleFa: 'برنامه ویرایش‌شده با وزنه سنگین‌تر',
        descriptionFa: 'توضیحات به‌روز شده برای هایپرتروفی حداکثر',
        difficulty: 'پیشرفته',
      );
      await appState1.updateWorkoutPlan(editedPlan);

      // Add a new exercise to Day 1
      final overheadEx =
          appState1.exercises.firstWhere((e) => e.id == 'ex_cable_crossover');
      await appState1.addExerciseToPlan(
        planId: targetPlan.id,
        exerciseId: overheadEx.id,
        dayOfWeek: 1,
        dayNameFa: 'برنامه روز ۱',
        targetSets: 4,
        targetReps: 12,
        targetWeightKg: 50.0,
        restSeconds: 75,
      );

      final updatedInMemory =
          appState1.workoutPlans.firstWhere((p) => p.id == targetPlan.id);
      expect(updatedInMemory.titleFa, 'برنامه ویرایش‌شده با وزنه سنگین‌تر');
      expect(updatedInMemory.exercises.length, originalExerciseCount + 1);

      // SIMULATE APP RESTART
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      final restoredEdited =
          appState2.workoutPlans.firstWhere((p) => p.id == targetPlan.id);
      expect(restoredEdited.titleFa, 'برنامه ویرایش‌شده با وزنه سنگین‌تر');
      expect(restoredEdited.descriptionFa,
          'توضیحات به‌روز شده برای هایپرتروفی حداکثر');
      expect(restoredEdited.difficulty, 'پیشرفته');
      expect(restoredEdited.exercises.length, originalExerciseCount + 1);

      // Verify added exercise persistence
      final addedEx = restoredEdited.exercises
          .lastWhere((e) => e.exerciseId == overheadEx.id);
      expect(addedEx.targetSets, 4);
      expect(addedEx.targetReps, 12);
      expect(addedEx.targetWeightKg, 50.0);
      expect(addedEx.restSeconds, 75);
    });

    test(
        'Requirement 5, 7, 8: Save and restore active workout progress with completed and incomplete sets',
        () async {
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      final plan = appState1.workoutPlans.first;
      final ex1 = plan.exercises.first;

      // Create draft state with set 1 completed, set 2 incomplete but with custom weights/reps
      final sets = [
        ActiveWorkoutSet(
          setNumber: 1,
          targetReps: 10,
          targetWeightKg: 80.0,
          actualReps: 10,
          actualWeightKg: 82.5,
          isCompleted: true,
        ),
        ActiveWorkoutSet(
          setNumber: 2,
          targetReps: 10,
          targetWeightKg: 80.0,
          actualReps: 8,
          actualWeightKg: 85.0,
          isCompleted: false, // Incomplete set with customized data
        ),
      ];

      final draft = ActiveWorkoutProgress(
        planId: plan.id,
        selectedDay: 2,
        startTimeEpoch: DateTime.now()
            .subtract(const Duration(minutes: 25))
            .millisecondsSinceEpoch,
        warmupTreadmillDone: true,
        warmupJointsDone: true,
        cooldownTreadmillDone: false,
        cooldownStretchingDone: false,
        exerciseSets: {
          ex1.id: sets,
        },
      );

      await appState1.saveActiveWorkoutDraft(draft);

      // Verify in-memory immediate draft
      final directDraft = appState1.getActiveWorkoutDraft(plan.id);
      expect(directDraft, isNotNull);
      expect(directDraft!.selectedDay, 2);
      expect(directDraft.warmupTreadmillDone, isTrue);

      // SIMULATE APP RESTART
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      final restoredDraft = appState2.getActiveWorkoutDraft(plan.id);
      expect(restoredDraft, isNotNull);
      expect(restoredDraft!.planId, plan.id);
      expect(restoredDraft.selectedDay, 2);
      expect(restoredDraft.warmupTreadmillDone, isTrue);
      expect(restoredDraft.warmupJointsDone, isTrue);
      expect(restoredDraft.cooldownTreadmillDone, isFalse);

      final restoredSets = restoredDraft.exerciseSets[ex1.id];
      expect(restoredSets, isNotNull);
      expect(restoredSets!.length, 2);

      // Set 1: Completed with 82.5kg x 10
      expect(restoredSets[0].isCompleted, isTrue);
      expect(restoredSets[0].actualWeightKg, 82.5);
      expect(restoredSets[0].actualReps, 10);

      // Set 2: Incomplete with 85.0kg x 8
      expect(restoredSets[1].isCompleted, isFalse);
      expect(restoredSets[1].actualWeightKg, 85.0);
      expect(restoredSets[1].actualReps, 8);
    });

    test(
        'Requirement 10: Complete workout, record elapsed duration and history, clear draft',
        () async {
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      final plan = appState1.workoutPlans.first;
      final initialCoins = appState1.userProfile.coins;
      final setLogs = [
        WorkoutSetLog(
            id: 's1',
            exerciseName: 'پرس سینه',
            setNumber: 1,
            reps: 10,
            weightKg: 80.0),
        WorkoutSetLog(
            id: 's2',
            exerciseName: 'پرس سینه',
            setNumber: 2,
            reps: 10,
            weightKg: 80.0),
        WorkoutSetLog(
            id: 's3',
            exerciseName: 'اسکات پا',
            setNumber: 1,
            reps: 8,
            weightKg: 100.0),
      ];

      // Complete session with 52 minutes elapsed duration
      await appState1.completeWorkoutSession(
        plan: plan,
        totalVolumeKg: 2400.0,
        completedSets: 3,
        setLogs: setLogs,
        durationMinutes: 52,
      );

      // Verify draft is cleared
      expect(appState1.getActiveWorkoutDraft(plan.id), isNull);

      // Verify workout log recorded
      expect(appState1.workoutLogs.isNotEmpty, isTrue);
      final latestLog = appState1.workoutLogs.first;
      expect(latestLog.planId, plan.id);
      expect(latestLog.totalVolumeKg, 2400.0);
      expect(latestLog.completedSets, 3);
      expect(latestLog.durationMinutes, 52);
      expect(latestLog.sets.length, 3);
      expect(appState1.userProfile.coins, initialCoins);
      expect(appState1.userProfile.streakDays, 1);

      // SIMULATE APP RESTART
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      expect(appState2.workoutLogs.isNotEmpty, isTrue);
      final restoredLog = appState2.workoutLogs.first;
      expect(restoredLog.planId, plan.id);
      expect(restoredLog.durationMinutes, 52);
      expect(restoredLog.totalVolumeKg, 2400.0);
      expect(restoredLog.sets.length, 3);
      expect(restoredLog.sets[0].exerciseName, 'پرس سینه');
      expect(restoredLog.sets[2].exerciseName, 'اسکات پا');
      expect(restoredLog.sets[2].weightKg, 100.0);
    });

    test('A session without completed sets is not saved as a workout', () async {
      final storage = LocalStorageService();
      await storage.init();
      final appState = AppState(storage: storage);
      final plan = appState.workoutPlans.first;

      await expectLater(
        appState.completeWorkoutSession(
          plan: plan,
          totalVolumeKg: 0,
          completedSets: 0,
          setLogs: const [],
          durationMinutes: 1,
        ),
        throwsArgumentError,
      );

      expect(appState.workoutLogs, isEmpty);
    });

    test('Workout volume must match completed set logs', () async {
      final storage = LocalStorageService();
      await storage.init();
      final appState = AppState(storage: storage);
      final plan = appState.workoutPlans.first;
      final setLog = WorkoutSetLog(
        id: 'set_actual',
        exerciseName: 'پرس سینه',
        setNumber: 1,
        reps: 10,
        weightKg: 50,
      );

      await expectLater(
        appState.completeWorkoutSession(
          plan: plan,
          totalVolumeKg: 999,
          completedSets: 1,
          setLogs: [setLog],
          durationMinutes: 10,
        ),
        throwsArgumentError,
      );
      expect(appState.workoutLogs, isEmpty);
    });

    test(
        'Delete workout plan and delete workout history log with selective isolation',
        () async {
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      // Create a temporary plan to delete
      await appState1.createWorkoutPlan(
        titleFa: 'برنامه موقت جهت تست حذف',
        descriptionFa: 'تست حذف ایمن بدون اثر بر سایر رکوردها',
      );

      final tempPlan = appState1.workoutPlans.firstWhere(
        (p) => p.titleFa == 'برنامه موقت جهت تست حذف',
      );
      final initialCount = appState1.workoutPlans.length;

      // Delete the specific plan
      await appState1.deleteWorkoutPlan(tempPlan.id);
      expect(appState1.workoutPlans.length, initialCount - 1);
      expect(appState1.workoutPlans.any((p) => p.id == tempPlan.id), isFalse);

      // SIMULATE APP RESTART
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      expect(appState2.workoutPlans.length, initialCount - 1);
      expect(appState2.workoutPlans.any((p) => p.id == tempPlan.id), isFalse);

      // Test selective history deletion
      if (appState2.workoutLogs.isNotEmpty) {
        final logToDelete = appState2.workoutLogs.first;
        final logsBefore = appState2.workoutLogs.length;

        await appState2.deleteWorkoutHistoryLog(logToDelete.id);
        expect(appState2.workoutLogs.length, logsBefore - 1);
        expect(
            appState2.workoutLogs.any((l) => l.id == logToDelete.id), isFalse);

        // RESTART AGAIN
        final storage3 = LocalStorageService();
        await storage3.init();
        final appState3 = AppState(storage: storage3);

        expect(appState3.workoutLogs.length, logsBefore - 1);
        expect(
            appState3.workoutLogs.any((l) => l.id == logToDelete.id), isFalse);
      }
    });

    test(
        'Requirement 9: Save user preferences and timer settings across restart',
        () async {
      final storage1 = LocalStorageService();
      await storage1.init();
      final appState1 = AppState(storage: storage1);

      expect(appState1.timerSettings.defaultRestSeconds, 90);
      expect(appState1.timerSettings.autoStartTimer, isFalse);

      // Update timer settings
      final newSettings = appState1.timerSettings.copyWith(
        defaultRestSeconds: 120,
        autoStartTimer: true,
        soundAlerts: true,
        vibrationAlerts: false,
      );
      await appState1.updateTimerSettings(newSettings);

      expect(appState1.timerSettings.defaultRestSeconds, 120);
      expect(appState1.timerSettings.autoStartTimer, isTrue);
      expect(appState1.timerSettings.vibrationAlerts, isFalse);

      // SIMULATE APP RESTART
      final storage2 = LocalStorageService();
      await storage2.init();
      final appState2 = AppState(storage: storage2);

      expect(appState2.timerSettings.defaultRestSeconds, 120);
      expect(appState2.timerSettings.autoStartTimer, isTrue);
      expect(appState2.timerSettings.soundAlerts, isTrue);
      expect(appState2.timerSettings.vibrationAlerts, isFalse);
    });
  });
}
