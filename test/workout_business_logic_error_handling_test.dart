import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/repository/workout_repository.dart';
import 'package:gymbro/core/error/app_exceptions.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';

class FailingWorkoutRepository extends LocalWorkoutRepository {
  bool shouldFailSave = false;

  FailingWorkoutRepository({required super.storage});

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    if (shouldFailSave) {
      throw Exception('Simulated disk I/O failure during saveWorkoutLog');
    }
    await super.saveWorkoutLog(log);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState appState;
  late WorkoutPlan testPlan;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    appState = AppState(storage: storage);
    testPlan = appState.workoutPlans.first;
  });

  tearDown(() async {
    await WorkoutTimerService().cancel();
  });

  group('GymBro Phase 03: Workout Business Logic & Error Handling Tests', () {
    test('1. Valid workout completion commits history, streak, and cleans active draft', () async {
      final initialHistoryLength = appState.workoutLogs.length;
      final initialCompletedWorkouts = appState.userProfile.totalWorkoutsCompleted;

      // Start a workout draft first
      await appState.startWorkoutSession(planId: testPlan.id);
      expect(appState.getActiveWorkoutDraft(testPlan.id), isNotNull);

      final setLogs = [
        WorkoutSetLog(
          id: 'set_1',
          exerciseName: 'پرس سینه با هالتر',
          setNumber: 1,
          reps: 10,
          weightKg: 80.0,
        ),
        WorkoutSetLog(
          id: 'set_2',
          exerciseName: 'پرس سینه با هالتر',
          setNumber: 2,
          reps: 8,
          weightKg: 85.0,
        ),
      ];
      const expectedVolume = (10 * 80.0) + (8 * 85.0); // 800 + 680 = 1480.0

      final completedLog = await appState.completeWorkoutSession(
        plan: testPlan,
        totalVolumeKg: expectedVolume,
        completedSets: 2,
        setLogs: setLogs,
        durationMinutes: 45,
      );

      // Verify returned log
      expect(completedLog.id, startsWith('wlog_'));
      expect(completedLog.planId, equals(testPlan.id));
      expect(completedLog.completedSets, equals(2));
      expect(completedLog.totalVolumeKg, equals(expectedVolume));
      expect(completedLog.durationMinutes, equals(45));

      // Verify history reloaded in state
      expect(appState.workoutLogs.length, equals(initialHistoryLength + 1));
      expect(appState.workoutLogs.first.id, equals(completedLog.id));

      // Verify streak and completed count updated
      expect(
        appState.userProfile.totalWorkoutsCompleted,
        equals(initialCompletedWorkouts + 1),
      );
      expect(appState.userProfile.streakDays, greaterThanOrEqualTo(1));

      // Verify active draft is cleaned up
      expect(appState.getActiveWorkoutDraft(testPlan.id), isNull);
    });

    test('2. Empty workout completion throws ValidationException and preserves state', () async {
      final initialHistoryLength = appState.workoutLogs.length;

      // Completed sets count is 0
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 0.0,
          completedSets: 0,
          setLogs: [],
          durationMinutes: 30,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('EMPTY_WORKOUT'),
        )),
      );

      // Verify no workout log was committed
      expect(appState.workoutLogs.length, equals(initialHistoryLength));
    });

    test('3. Missing or invalid plan throws ValidationException', () async {
      final emptyPlan = WorkoutPlan(
        id: '',
        titleFa: '',
        titleEn: '',
        descriptionFa: '',
        splitType: '',
      );

      final setLogs = [
        WorkoutSetLog(
          id: 'set_1',
          exerciseName: 'اسکوات',
          setNumber: 1,
          reps: 10,
          weightKg: 100.0,
        ),
      ];

      expect(
        () => appState.completeWorkoutSession(
          plan: emptyPlan,
          totalVolumeKg: 1000.0,
          completedSets: 1,
          setLogs: setLogs,
          durationMinutes: 40,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('MISSING_PLAN'),
        )),
      );
    });

    test('4. Invalid set values (negative weight, 0 reps, empty name) throw ValidationException', () async {
      // 4A: Negative weight
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 0.0,
          completedSets: 1,
          setLogs: [
            WorkoutSetLog(
              id: 'set_neg',
              exerciseName: 'ددلیفت',
              setNumber: 1,
              reps: 5,
              weightKg: -50.0,
            ),
          ],
          durationMinutes: 35,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('INVALID_SETS'),
        )),
      );

      // 4B: Zero reps
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 0.0,
          completedSets: 1,
          setLogs: [
            WorkoutSetLog(
              id: 'set_zero_reps',
              exerciseName: 'ددلیفت',
              setNumber: 1,
              reps: 0,
              weightKg: 100.0,
            ),
          ],
          durationMinutes: 35,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('INVALID_SETS'),
        )),
      );

      // 4C: Empty exercise name
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 500.0,
          completedSets: 1,
          setLogs: [
            WorkoutSetLog(
              id: 'set_empty_name',
              exerciseName: '   ',
              setNumber: 1,
              reps: 5,
              weightKg: 100.0,
            ),
          ],
          durationMinutes: 35,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('INVALID_SETS'),
        )),
      );

      // 4D: Set count mismatch (completedSets != setLogs.length)
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 500.0,
          completedSets: 3,
          setLogs: [
            WorkoutSetLog(
              id: 'set_mismatch',
              exerciseName: 'لانژ',
              setNumber: 1,
              reps: 5,
              weightKg: 100.0,
            ),
          ],
          durationMinutes: 35,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.code,
          'code',
          equals('INVALID_SETS'),
        )),
      );
    });

    test('5. Duplicate completion prevention stops double submits and double increments', () async {
      final setLogs = [
        WorkoutSetLog(
          id: 'set_dup',
          exerciseName: 'بارفیکس',
          setNumber: 1,
          reps: 10,
          weightKg: 0.0,
        ),
      ];

      // First submit succeeds
      final log1 = await appState.completeWorkoutSession(
        plan: testPlan,
        totalVolumeKg: 0.0,
        completedSets: 1,
        setLogs: setLogs,
        durationMinutes: 30,
      );
      expect(log1, isNotNull);

      final countAfterFirst = appState.userProfile.totalWorkoutsCompleted;
      final historyLengthAfterFirst = appState.workoutLogs.length;

      // Immediate second submit of exact same session throws StateTransitionException
      expect(
        () => appState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 0.0,
          completedSets: 1,
          setLogs: setLogs,
          durationMinutes: 30,
        ),
        throwsA(isA<StateTransitionException>().having(
          (e) => e.code,
          'code',
          equals('ALREADY_COMPLETED'),
        )),
      );

      // Ensure history length and total completed workouts were NOT doubled
      expect(appState.workoutLogs.length, equals(historyLengthAfterFirst));
      expect(
        appState.userProfile.totalWorkoutsCompleted,
        equals(countAfterFirst),
      );
    });

    test('6. Storage failure during workout completion raises StorageException and resets loading state', () async {
      final failingRepo = FailingWorkoutRepository(storage: storage);
      failingRepo.shouldFailSave = true;

      final failingAppState = AppState(
        storage: storage,
        repository: failingRepo,
      );

      final setLogs = [
        WorkoutSetLog(
          id: 'set_fail',
          exerciseName: 'شنا سوئدی',
          setNumber: 1,
          reps: 15,
          weightKg: 0.0,
        ),
      ];

      // Attempt completion
      await expectLater(
        failingAppState.completeWorkoutSession(
          plan: testPlan,
          totalVolumeKg: 0.0,
          completedSets: 1,
          setLogs: setLogs,
          durationMinutes: 20,
        ),
        throwsA(isA<StorageException>()),
      );

      // Ensure isCompletingWorkoutSession is cleanly reset to false
      expect(failingAppState.isCompletingWorkoutSession, isFalse);
    });

    test('7. Full Workout Lifecycle (Start, Add Ex, Add Set, Edit Set, Delete Set, Rest, Pause, Resume, Cancel)', () async {
      // 1. Start Workout Session
      final progress = await appState.startWorkoutSession(planId: testPlan.id);
      expect(progress.planId, equals(testPlan.id));
      expect(progress.exerciseSets, isNotEmpty);
      expect(progress.isPaused, isFalse);

      final firstPeId = progress.exerciseSets.keys.first;
      final initialSetCount = progress.exerciseSets[firstPeId]!.length;

      // 2. Add Exercise to Active Workout
      final customExercise = WorkoutPlanExercise(
        id: 'pe_lifecycle_custom',
        planId: testPlan.id,
        exerciseId: 'ex_custom',
        dayOfWeek: 1,
        dayNameFa: 'حرکت اضافه شده زنده',
        orderInDay: 99,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 50.0,
      );
      final afterAddEx = await appState.addExerciseToActiveWorkout(
        planId: testPlan.id,
        exercise: customExercise,
      );
      expect(afterAddEx.exerciseSets.containsKey('pe_lifecycle_custom'), isTrue);
      expect(afterAddEx.exerciseSets['pe_lifecycle_custom']!.length, equals(3));

      // 3. Add Set to Active Exercise
      final afterAddSet = await appState.addSetToActiveExercise(
        planId: testPlan.id,
        planExerciseId: firstPeId,
        targetReps: 10,
        targetWeightKg: 70.0,
      );
      expect(afterAddSet.exerciseSets[firstPeId]!.length, equals(initialSetCount + 1));
      expect(afterAddSet.exerciseSets[firstPeId]!.last.setNumber, equals(initialSetCount + 1));

      // 4. Edit Active Set
      final afterEditSet = await appState.editActiveSet(
        planId: testPlan.id,
        planExerciseId: firstPeId,
        setNumber: 1,
        actualReps: 12,
        actualWeightKg: 75.0,
        isCompleted: true,
      );
      final editedSet = afterEditSet.exerciseSets[firstPeId]!.firstWhere((s) => s.setNumber == 1);
      expect(editedSet.actualReps, equals(12));
      expect(editedSet.actualWeightKg, equals(75.0));
      expect(editedSet.isCompleted, isTrue);

      // 5. Delete Set from Active Exercise
      final afterDeleteSet = await appState.deleteSetFromActiveExercise(
        planId: testPlan.id,
        planExerciseId: firstPeId,
        setNumber: 2,
      );
      expect(afterDeleteSet.exerciseSets[firstPeId]!.length, equals(initialSetCount));
      // Verify re-indexing
      for (int i = 0; i < afterDeleteSet.exerciseSets[firstPeId]!.length; i++) {
        expect(afterDeleteSet.exerciseSets[firstPeId]![i].setNumber, equals(i + 1));
      }

      // 6. Rest Timer Validation
      expect(
        () => appState.startRestTimer(seconds: -10),
        throwsA(isA<ValidationException>()),
      );
      await appState.startRestTimer(seconds: 45);
      expect(WorkoutTimerService().isRunning, isTrue);
      await WorkoutTimerService().cancel();

      // 7. Pause Workout Session
      final pausedProgress = await appState.pauseWorkoutSession(testPlan.id);
      expect(pausedProgress.isPaused, isTrue);

      // Attempting to pause already paused session throws StateTransitionException
      expect(
        () => appState.pauseWorkoutSession(testPlan.id),
        throwsA(isA<StateTransitionException>()),
      );

      // 8. Resume Workout Session
      final resumedProgress = await appState.resumeWorkoutSession(testPlan.id);
      expect(resumedProgress.isPaused, isFalse);

      // Attempting to resume already active session throws StateTransitionException
      expect(
        () => appState.resumeWorkoutSession(testPlan.id),
        throwsA(isA<StateTransitionException>()),
      );

      // 9. Cancel Workout Session
      await appState.cancelWorkoutSession(testPlan.id);
      expect(appState.getActiveWorkoutDraft(testPlan.id), isNull);
    });

    test('8. Interrupted Workout Restores Exact Sets Across Re-instantiation', () async {
      // 1. Start and mutate draft
      await appState.startWorkoutSession(planId: testPlan.id);
      final firstPeId = appState.getActiveWorkoutDraft(testPlan.id)!.exerciseSets.keys.first;

      await appState.editActiveSet(
        planId: testPlan.id,
        planExerciseId: firstPeId,
        setNumber: 1,
        actualReps: 14,
        actualWeightKg: 92.5,
        isCompleted: true,
      );

      // 2. Simulate application restart
      final newStorage = LocalStorageService();
      await newStorage.init();
      final restoredAppState = AppState(storage: newStorage);

      final restoredDraft = restoredAppState.getActiveWorkoutDraft(testPlan.id);
      expect(restoredDraft, isNotNull);
      final restoredSet = restoredDraft!.exerciseSets[firstPeId]!.firstWhere((s) => s.setNumber == 1);
      expect(restoredSet.actualReps, equals(14));
      expect(restoredSet.actualWeightKg, equals(92.5));
      expect(restoredSet.isCompleted, isTrue);
    });
  });
}
