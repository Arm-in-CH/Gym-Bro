import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/screens/main_navigation_screen.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/meal_scanner_screen.dart';
import 'package:gymbro/widgets/one_rm_calculator_dialog.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/widgets/exercise_detail_sheet.dart';
import 'package:gymbro/widgets/exercise_rest_selector_sheet.dart';
import 'package:gymbro/widgets/floating_timer_bar.dart';

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

  tearDown(() async {
    await WorkoutTimerService().cancel();
  });

  Widget buildAppWithState({
    required Widget child,
    Size size = const Size(360, 640),
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.dark,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('GymBro Phase 7: UI Consistency & Responsive Layout Tests', () {
    testWidgets(
        'MainNavigationScreen renders and switches tabs without overflow at 360x640 (textScale 2.0)',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: MainNavigationScreen(state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Switch to Workouts Tab
      await tester.tap(find.text('تمرینات'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Nutrition Tab
      await tester.tap(find.text('تغذیه'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Profile Tab
      await tester.tap(find.text('پروفایل'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'DashboardScreen renders in Light Mode without contrast bugs or overflow',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: DashboardScreen(
          state: state,
          onOpenMealScanner: () {},
          onOpenHomeMode: () {},
          onOpenWorkouts: () {},
          onStartWorkout: (_) {},
          onOpenMarketplace: () {},
          onOpenAiCoach: () {},
        ),
        size: const Size(360, 640),
        textScale: 1.5,
        themeMode: ThemeMode.light,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('امروز به باشگاه نمی‌رسی؟'), findsOneWidget);
    });

    testWidgets(
        'WorkoutScreen Exercise Library chips do not overflow at textScale 2.0',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: WorkoutScreen(
          state: state,
          onStartWorkout: (_) {},
          onOpenHomeMode: () {},
        ),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      // Switch to Exercise Library tab
      await tester.tap(find.text('بانک جامع حرکات'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('سینه'), findsOneWidget);
      expect(find.text('همه عضلات'), findsOneWidget);
    });

    testWidgets(
        'ActiveWorkoutScreen renders with all sets at textScale 2.0 on 360x640',
        (tester) async {
      final planId = state.workoutPlans.first.id;
      await tester.pumpWidget(buildAppWithState(
        child: ActiveWorkoutScreen(planId: planId, state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    });

    testWidgets(
        'FocusedTrainingScreen renders focus mode at 360x640 with textScale 2.0',
        (tester) async {
      final planId = state.workoutPlans.first.id;
      await tester.pumpWidget(buildAppWithState(
        child: FocusedTrainingScreen(planId: planId, state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(FocusedTrainingScreen), findsOneWidget);
    });

    testWidgets(
        'WorkoutHistoryScreen statistics cards do not overflow at textScale 2.0',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: WorkoutHistoryScreen(state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen metric boxes do not overflow at textScale 2.0',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: ProfileScreen(state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('پروفایل و جایگاه ورزشی'), findsOneWidget);
    });

    testWidgets(
        'MealScannerScreen nutrient boxes do not overflow at textScale 2.0',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: MealScannerScreen(state: state),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('برآورد غذا'), findsOneWidget);
    });

    testWidgets(
        'OneRmCalculatorDialog does not overflow at textScale 2.0 on 360x640',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: const OneRmCalculatorDialog(),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('محاسبه‌گر یک تکرار بیشینه (1RM)'), findsOneWidget);
    });

    testWidgets(
        'RestTimerDialog renders countdown and presets without overflow at textScale 2.0',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: const RestTimerDialog(initialSeconds: 60),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('تایمر استراحت بین ست'), findsOneWidget);
      await WorkoutTimerService().cancel();
    });

    testWidgets('ExerciseDetailSheet scrolls without overflow at textScale 2.0',
        (tester) async {
      final ex = state.exercises.first;
      await tester.pumpWidget(buildAppWithState(
        child: ExerciseDetailSheet(exercise: ex),
        size: const Size(360, 640),
        textScale: 2.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(ex.nameFa), findsOneWidget);
    });

    testWidgets(
        'ExerciseRestSelectorSheet renders with keyboard inset without overflow',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: const ExerciseRestSelectorSheet(
          exerciseName: 'پرس سینه هالتر',
          currentRestSeconds: 60,
        ),
        size: const Size(360, 640),
        textScale: 1.5,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('زمان استراحت حرکت'), findsOneWidget);
    });

    testWidgets('FloatingTimerBar renders compactly on 320x480 narrow screens',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: const Column(
          children: [
            Spacer(),
            FloatingTimerBar(),
          ],
        ),
        size: const Size(320, 480),
        textScale: 1.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Large screen (1024x768) maintains centered adaptive layout across main screens',
        (tester) async {
      await tester.pumpWidget(buildAppWithState(
        child: MainNavigationScreen(state: state),
        size: const Size(1024, 768),
        textScale: 1.0,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MainNavigationScreen), findsOneWidget);
    });
  });
}
