import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/active_workout_progress.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/widgets/active_set_row.dart';
import 'package:gymbro/widgets/exercise_rest_selector_sheet.dart';
import 'package:gymbro/widgets/workout_session_progress_header.dart';
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

  group('GymBro Phase 3: Workout Interaction & Exercise State Tests', () {
    testWidgets(
      'Requirement 1 & 5: Each exercise and set maintains independent completion status',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final plan = appState.workoutPlans.first;
        expect(plan.exercises.length, greaterThanOrEqualTo(2));

        await tester.pumpWidget(_wrap(
          ActiveWorkoutScreen(planId: plan.id, state: appState),
          appState,
        ));
        await tester.pumpAndSettle();

        // Verify independent set rows
        final setRows = find.byType(ActiveSetRow);
        expect(setRows, findsWidgets);

        // First set row is initially uncompleted
        final firstRowCheck = find.descendant(
          of: setRows.first,
          matching: find.byIcon(Icons.check),
        );
        final firstRowUncheck = find.descendant(
          of: setRows.first,
          matching: find.byIcon(Icons.crop_square),
        );
        expect(firstRowCheck, findsNothing);
        expect(firstRowUncheck, findsOneWidget);

        // Tap the first set row
        await tester.ensureVisible(firstRowUncheck);
        await tester.pumpAndSettle();
        await tester.tap(firstRowUncheck);
        await tester.pump();
        await tester.pump(
            const Duration(milliseconds: 250)); // let animated scale settle

        // Now first set row is completed
        expect(
          find.descendant(
              of: setRows.first, matching: find.byIcon(Icons.check)),
          findsOneWidget,
        );
        expect(
          find.descendant(
              of: setRows.first, matching: find.byIcon(Icons.crop_square)),
          findsNothing,
        );

        // Second set row is STILL uncompleted
        expect(
          find.descendant(
              of: setRows.at(1), matching: find.byIcon(Icons.crop_square)),
          findsOneWidget,
        );
        expect(
          find.descendant(
              of: setRows.at(1), matching: find.byIcon(Icons.check)),
          findsNothing,
        );

        // Tap the second set row
        final secondRowUncheck = find.descendant(
          of: setRows.at(1),
          matching: find.byIcon(Icons.crop_square),
        );
        await tester.ensureVisible(secondRowUncheck);
        await tester.pumpAndSettle();
        await tester.tap(secondRowUncheck);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Both are now completed independently
        expect(
          find.descendant(
              of: setRows.first, matching: find.byIcon(Icons.check)),
          findsOneWidget,
        );
        expect(
          find.descendant(
              of: setRows.at(1), matching: find.byIcon(Icons.check)),
          findsOneWidget,
        );

        // Toggle first set row off; second must remain completed
        final firstRowCompletedCheck = find.descendant(
          of: setRows.first,
          matching: find.byIcon(Icons.check),
        );
        await tester.ensureVisible(firstRowCompletedCheck);
        await tester.pumpAndSettle();
        await tester.tap(firstRowCompletedCheck);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // First set is uncompleted, second set remains completed!
        expect(
          find.descendant(
              of: setRows.first, matching: find.byIcon(Icons.crop_square)),
          findsOneWidget,
        );
        expect(
          find.descendant(
              of: setRows.first, matching: find.byIcon(Icons.check)),
          findsNothing,
        );
        expect(
          find.descendant(
              of: setRows.at(1), matching: find.byIcon(Icons.check)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Requirement 2, 3 & 4: ActiveSetRow provides smooth animated transition without duplicate events',
      (tester) async {
        final set = ActiveWorkoutSet(
          setNumber: 1,
          targetReps: 12,
          targetWeightKg: 60.0,
          actualReps: 12,
          actualWeightKg: 60.0,
          isCompleted: false,
        );

        int toggleCalls = 0;
        await tester.pumpWidget(_wrap(
          ActiveSetRow(
            workoutSet: set,
            restSeconds: 60,
            onToggleComplete: (done) => toggleCalls++,
            onDataChanged: () {},
          ),
        ));
        await tester.pumpAndSettle();

        final checkInkWell = find.byType(InkWell);
        expect(checkInkWell, findsOneWidget);

        // First tap: completes set
        await tester.tap(checkInkWell);
        await tester.pump();
        expect(toggleCalls, 1);
        expect(set.isCompleted, isTrue);

        // Rapid second tap immediately after (within 50ms debounce threshold)
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(checkInkWell);
        await tester.pump();

        // Debounce must ignore duplicate tap
        expect(toggleCalls, 1);
        expect(set.isCompleted, isTrue);

        // After debounce period (400ms), tap is accepted
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(checkInkWell);
        await tester.pump();
        expect(toggleCalls, 2);
        expect(set.isCompleted, isFalse);
      },
    );

    testWidgets(
      'Requirement 7: WorkoutSessionProgressHeader accurately computes sets and tonnage progress',
      (tester) async {
        await tester.pumpWidget(_wrap(
          const WorkoutSessionProgressHeader(
            completedSets: 3,
            totalSets: 6,
            totalVolumeKg: 1800.0,
            warmupDone: true,
            cooldownDone: false,
          ),
        ));
        await tester.pumpAndSettle();

        // 3 of 6 = 50%
        expect(find.text('۵۰٪ تکمیل'), findsOneWidget);
        expect(find.text('ست‌ها: ۳ از ۶ ست'), findsOneWidget);
        expect(find.text('تناژ: ۱۸۰۰ kg'), findsOneWidget);
      },
    );

    testWidgets(
      'REST TIME PRESETS: ExerciseRestSelectorSheet offers 30, 45, 60, 90, 120, 180s and custom duration',
      (tester) async {
        int? selectedDuration;

        await tester.pumpWidget(_wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                selectedDuration = await ExerciseRestSelectorSheet.show(
                  ctx,
                  exerciseName: 'پرس سینه دمبل',
                  currentRestSeconds: 60,
                );
              },
              child: const Text('انتخاب استراحت'),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Tap open button
        await tester.tap(find.text('انتخاب استراحت'));
        await tester.pumpAndSettle();

        // Verify all 6 preset duration chips exist
        expect(find.text('۳۰ ثانیه'), findsOneWidget);
        expect(find.text('۴۵ ثانیه'), findsOneWidget);
        expect(find.text('۶۰ ثانیه'), findsOneWidget);
        expect(find.text('۹۰ ثانیه'), findsOneWidget);
        expect(find.text('۱۲۰ ثانیه'), findsOneWidget);
        expect(find.text('۱۸۰ ثانیه'), findsOneWidget);
        expect(find.text('مدت سفارشی...'), findsOneWidget);

        // Tap 90s preset
        await tester.tap(find.text('۹۰ ثانیه'));
        await tester.pumpAndSettle();

        expect(selectedDuration, 90);
      },
    );

    testWidgets(
      'REST TIME PRESETS: Custom duration picker allows arbitrary seconds (e.g. 150s)',
      (tester) async {
        int? selectedDuration;

        await tester.pumpWidget(_wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                selectedDuration = await ExerciseRestSelectorSheet.show(
                  ctx,
                  exerciseName: 'اسکات پا',
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

        // Tap custom mode
        await tester.tap(find.text('مدت سفارشی...'));
        await tester.pumpAndSettle();

        // Enter 150 seconds in TextFormField
        final textInput = find.byType(TextFormField);
        expect(textInput, findsOneWidget);
        await tester.enterText(textInput, '150');
        await tester.pumpAndSettle();

        // Tap Submit ('ثبت')
        await tester.tap(find.text('ثبت'));
        await tester.pumpAndSettle();

        expect(selectedDuration, 150);
      },
    );

    testWidgets(
      'Requirement 8: Multiple exercises and sets maintain completion and rest duration across app restart',
      (tester) async {
        final plan = appState.workoutPlans.first;
        final ex1 = plan.exercises[0];
        final ex2 = plan.exercises[1];

        // Prepare initial workout session draft with custom sets and rest durations
        final draftSets = <String, List<ActiveWorkoutSet>>{
          ex1.id: [
            ActiveWorkoutSet(
              setNumber: 1,
              targetReps: 10,
              targetWeightKg: 50.0,
              actualReps: 12,
              actualWeightKg: 55.0,
              isCompleted: true, // Completed!
            ),
            ActiveWorkoutSet(
              setNumber: 2,
              targetReps: 10,
              targetWeightKg: 50.0,
              actualReps: 10,
              actualWeightKg: 55.0,
              isCompleted: false, // Incomplete!
            ),
          ],
          ex2.id: [
            ActiveWorkoutSet(
              setNumber: 1,
              targetReps: 15,
              targetWeightKg: 30.0,
              actualReps: 15,
              actualWeightKg: 35.0,
              isCompleted: true, // Completed!
            ),
          ],
        };

        final initialDraft = ActiveWorkoutProgress(
          planId: plan.id,
          selectedDay: 1,
          startTimeEpoch: DateTime.now().millisecondsSinceEpoch,
          warmupTreadmillDone: true,
          warmupJointsDone: true,
          exerciseSets: draftSets,
          exerciseRestSeconds: {
            ex1.id: 90, // Custom preset 90s
            ex2.id: 150, // Custom duration 150s
          },
        );

        await appState.saveActiveWorkoutDraft(initialDraft);

        // Also update plan rest in AppState
        await appState.updateWorkoutPlanExerciseRest(
          planId: plan.id,
          exercisePlanId: ex1.id,
          restSeconds: 90,
        );

        // --- SIMULATE APPLICATION RESTART ---
        final storageRestart = LocalStorageService();
        await storageRestart.init();
        final appStateRestart = AppState(storage: storageRestart);

        // 1. Verify restored draft
        final restoredDraft = appStateRestart.getActiveWorkoutDraft(plan.id);
        expect(restoredDraft, isNotNull);
        expect(restoredDraft!.exerciseSets[ex1.id]![0].isCompleted, isTrue);
        expect(restoredDraft.exerciseSets[ex1.id]![0].actualWeightKg, 55.0);
        expect(restoredDraft.exerciseSets[ex1.id]![1].isCompleted, isFalse);
        expect(restoredDraft.exerciseSets[ex2.id]![0].isCompleted, isTrue);
        expect(restoredDraft.exerciseRestSeconds[ex1.id], 90);
        expect(restoredDraft.exerciseRestSeconds[ex2.id], 150);

        // 2. Mount ActiveWorkoutScreen with restored state
        await tester.pumpWidget(_wrap(
          ActiveWorkoutScreen(planId: plan.id, state: appStateRestart),
          appStateRestart,
        ));
        await tester.pumpAndSettle();

        // The screen should accurately render the completed sets
        expect(find.byIcon(Icons.check), findsWidgets);
        expect(find.text('استراحت: ۹۰ ثانیه'), findsOneWidget);
      },
    );
  });
}
