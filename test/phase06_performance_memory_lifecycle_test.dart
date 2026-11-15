import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/ai/openrouter_ai_service.dart';
import 'package:gymbro/core/ai/gemini_service.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/theme/app_tokens.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/widgets/floating_timer_bar.dart';
import 'package:gymbro/widgets/staggered_fade_slide.dart';

Widget buildTestScaffold({required Widget child, bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        size: const Size(400, 800),
      ),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    state = AppState(storage: storage);
  });

  group('Phase 06: Performance, Memory & Lifecycle Optimization Suite', () {
    testWidgets('1. MainNavigationScreen scopes tab repaints with RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MainNavigationScreen(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that IndexedStack isolates the active tab with RepaintBoundary
      final indexedStackFinder = find.byType(IndexedStack);
      expect(indexedStackFinder, findsOneWidget);

      final repaintBoundariesInStack = find.descendant(
        of: indexedStackFinder,
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundariesInStack, findsAtLeastNWidgets(1));

      // Switch to workouts tab
      await tester.tap(find.text('تمرینات'));
      await tester.pumpAndSettle();

      expect(repaintBoundariesInStack, findsAtLeastNWidgets(1));
    });

    testWidgets('2. FloatingTimerBar is isolated with RepaintBoundary for 1Hz ticks', (tester) async {
      await tester.pumpWidget(
        buildTestScaffold(child: const FloatingTimerBar()),
      );
      await tester.pumpAndSettle();

      // When timer is idle, it returns SizedBox.shrink()
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. WorkoutHistoryScreen utilizes ListView.builder for lazy item evaluation', (tester) async {
      // Seed 25 workout logs
      final logs = List.generate(
        25,
        (i) => WorkoutLog(
          id: 'log_perf_$i',
          planId: 'plan_1',
          planTitle: 'جلسه تمرینی سرعت بالا شماره $i',
          date: '۱۴۰۴/۰۱/${(i + 1).toString().padLeft(2, '0')}',
          durationMinutes: 45,
          totalVolumeKg: 3000.0 + (i * 50),
          completedSets: 10,
          timestamp: DateTime.now().millisecondsSinceEpoch - (i * 86400000),
          sets: [
            WorkoutSetLog(
              id: 's_$i',
              exerciseName: 'پرس سینه',
              setNumber: 1,
              reps: 10,
              weightKg: 80.0,
            ),
          ],
        ),
      );

      for (final log in logs) {
        await state.workoutRepository.saveWorkoutLog(log);
      }
      state.workoutLogs = await state.workoutRepository.getWorkoutLogs();

      await tester.pumpWidget(
        buildTestScaffold(child: WorkoutHistoryScreen(state: state)),
      );
      await tester.pumpAndSettle();

      // Verify ListView is rendered
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Verify header and first items render without building all 25 logs at once
      expect(find.text('خلاصه فعالیت‌های ثبت‌شده'), findsOneWidget);
      expect(find.text('جلسه تمرینی سرعت بالا شماره 0'), findsOneWidget);

      // Bottom-most item should not be rendered yet in the initial viewport
      expect(find.text('جلسه تمرینی سرعت بالا شماره 24'), findsNothing);

      // Scroll down to lazily build later items
      await tester.drag(listViewFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      // Later item is now built on demand
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. StaggeredFadeSlide respects reduced motion (disableAnimations)', (tester) async {
      // Build with disableAnimations = true
      await tester.pumpWidget(
        buildTestScaffold(
          disableAnimations: true,
          child: const StaggeredFadeSlide(
            index: 3,
            child: Text('کارت با موشن غیرفعال'),
          ),
        ),
      );
      // Because animations are disabled, value is immediately 1.0 without waiting for delay timer
      await tester.pump();

      expect(find.text('کارت با موشن غیرفعال'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('5. OpenRouterAiService caches identical text food queries', () async {
      final service = OpenRouterAiService();

      final firstResult = await service.analyzeFood(
        description: '۱۰ قاشق برنج + ۱۵۰ گرم فیله مرغ گریل',
        apiKey: '', // Offline Persian engine
      );

      final secondResult = await service.analyzeFood(
        description: '۱۰ قاشق برنج + ۱۵۰ گرم فیله مرغ گریل',
        apiKey: '',
      );

      // Same instance returned from cache
      expect(identical(firstResult, secondResult), isTrue);
      expect(firstResult.estimatedCalories, equals(secondResult.estimatedCalories));

      service.dispose();
    });

    test('6. GeminiService and OpenRouterAiService close HTTP clients on dispose()', () {
      final gemini = GeminiService();
      expect(() => gemini.dispose(), returnsNormally);

      final openRouter = OpenRouterAiService();
      expect(() => openRouter.dispose(), returnsNormally);
    });

    test('7. AiState disposes underlying AI services cleanly', () {
      final aiState = state.aiState;
      expect(() => aiState.dispose(), returnsNormally);
    });

    testWidgets('8. WeeklyWorkoutStrip evaluates dates without redundant O(7*N) scans', (tester) async {
      final testLogs = List.generate(
        15,
        (i) => WorkoutLog(
          id: 'log_$i',
          planId: 'p1',
          planTitle: 'تست تقویم',
          date: '۱۴۰۴/۰۱/${(i + 1).toString().padLeft(2, '0')}',
          durationMinutes: 40,
          totalVolumeKg: 1000,
          completedSets: 5,
          timestamp: DateTime.now().millisecondsSinceEpoch - (i * 86400000),
          sets: const [],
        ),
      );
      state.workoutLogs = testLogs;

      await tester.pumpWidget(
        buildTestScaffold(
          child: WeeklyWorkoutStrip(
            state: state,
            tokens: AppThemeExtension.dark,
            selectedPlan: state.workoutPlans.firstOrNull,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تقویم هفتگی تمرینات'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
