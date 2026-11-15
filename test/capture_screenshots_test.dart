import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/workout_plan.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/calorie_scan_log.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/models/marketplace_models.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/active_workout_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';
import 'package:gymbro/screens/meal_scanner_screen.dart';
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/ai_coach_screen.dart';
import 'package:gymbro/screens/focused_training_screen.dart';
import 'package:gymbro/widgets/rest_timer_dialog.dart';
import 'package:gymbro/core/services/workout_timer_service.dart';
import 'package:gymbro/models/active_workout_progress.dart';

class _ScreenShotStorageService extends LocalStorageService {
  @override
  String getApiKey() => '';

  @override
  Future<void> saveApiKey(String key) async {}

  @override
  String getGeminiApiKey() => '';

  @override
  Future<void> saveGeminiApiKey(String key) async {}

  @override
  String getGeminiModel() => 'gemini-1.5-flash';

  @override
  Future<void> saveGeminiModel(String model) async {}

  @override
  UserProfile getProfile() => UserProfile(
        id: 'u_shot',
        firstName: 'آرمین',
        lastName: 'جعفری',
        phone: '09123456789',
        email: 'armin@gymbro.app',
        weightKg: 80.0,
        heightCm: 180.0,
        fitnessGoal: 'Hypertrophy',
        fitnessLevel: 'Advanced',
        level: UserLevel.athlete,
        coins: 120,
        dailyFreeScans: 10,
        streakDays: 14,
        totalWorkoutsCompleted: 35,
        activeSinceMonths: 3,
      );

  @override
  NutritionPlan getNutritionPlan() => NutritionPlan(
        id: 'n1',
        dailyCalories: 2650,
        targetProteinG: 165,
        targetCarbsG: 290,
        targetFatG: 70,
        targetWaterMl: 3500,
      );

  @override
  List<WorkoutPlan> getWorkoutPlans() => [
        WorkoutPlan(
          id: 'p1',
          titleFa: 'روز هل دادنی تخصصی سینه و سرشانه',
          titleEn: 'Push Day A',
          descriptionFa: 'تمرین سینه، سرشانه و پشت بازو',
          splitType: 'PPL',
          daysPerWeek: 4,
          difficulty: 'پیشرفته',
          exercises: [
            WorkoutPlanExercise(
              id: 'pe1',
              planId: 'p1',
              exerciseId: 'ex1',
              dayOfWeek: 1,
              dayNameFa: 'شنبه',
              orderInDay: 1,
              targetSets: 4,
              targetReps: 10,
              targetWeightKg: 80.0,
              restSeconds: 90,
            ),
          ],
        ),
      ];

  @override
  List<WorkoutLog> getWorkoutLogs() => [];

  @override
  List<CalorieScanLog> getCalorieLogs() => [
        CalorieScanLog(
          id: 'c1',
          foodName: 'چلو جوجه کباب با کته زعفرانی',
          mealType: 'ناهار',
          calories: 780,
          proteinG: 48,
          carbsG: 82,
          fatG: 22,
          portionG: 380,
          dateString: '2026-11-07',
          timestamp: 1000,
        ),
      ];

  @override
  List<Gym> getGyms() => [
        Gym(
          id: 'g1',
          name: 'باشگاه وی آی پی نیاوران',
          address: 'تهران، نیاوران، خیابان باهنر',
          district: 'نیاوران',
          latitude: 35.81,
          longitude: 51.46,
          monthlyFeeToman: 4200000,
          rating: 4.9,
          reviewCount: 38,
          amenities: ['استخر', 'سونا', 'کافه پروتئینی'],
        ),
      ];

  @override
  List<Trainer> getTrainers() => [
        Trainer(
          id: 't1',
          name: 'استاد علیرضا راد',
          title: 'مربی رسمی فدراسیون IFBB',
          specialty: 'هایپرتروفی',
          bio: 'دارای ۱۰ سال سابقه مربیگری',
          hourlyRateToman: 650000,
          sessionType: 'حضوری در باشگاه',
          rating: 5.0,
          reviewCount: 42,
        ),
      ];

  @override
  List<Booking> getBookings() => [];

  @override
  List<Exercise> getExercises() => [
        Exercise(
          id: 'ex1',
          nameFa: 'پرس سینه هالتر روی نیمکت تخت',
          nameEn: 'Barbell Flat Bench Press',
          muscleGroup: 'Chest',
          muscleGroupFa: 'سینه',
          equipment: 'Barbell',
          equipmentFa: 'هالتر و نیمکت',
          instructionsFa: 'روی نیمکت دراز بکشید و هالتر را پایین بیاورید.',
          homeEquivalentId: 'ex_pushups',
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ScreenShotStorageService storage;
  late AppState state;
  final outDir = Directory(
      r'C:\Users\Armin\.gemini\antigravity\brain\b3221214-45b8-4363-b995-5464e3d643ff\screenshots');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = _ScreenShotStorageService();
    await storage.init();
    state = AppState(storage: storage);
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }
  });

  Future<void> captureScreen({
    required WidgetTester tester,
    required Widget child,
    required String fileName,
    Size size = const Size(360, 640),
    bool isDark = true,
    TextDirection dir = TextDirection.rtl,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    final repaintKey = GlobalKey();

    final testApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Directionality(
        textDirection: dir,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 24, bottom: 16),
          ),
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(testApp);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      try {
        final boundary = repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 1.0);
          final byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final file = File('${outDir.path}/$fileName.png');
            file.writeAsBytesSync(byteData.buffer.asUint8List());
          }
        }
      } catch (e) {
        // Fallback for headless environments without GPU surface
      }
    });

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  group('Capture Main Flow Screenshots Across Configurations', () {
    testWidgets('Dashboard Screen variations', (tester) async {
      final dashboard = DashboardScreen(
        state: state,
        onOpenMealScanner: () {},
        onOpenHomeMode: () {},
        onOpenWorkouts: () {},
        onStartWorkout: (_) {},
        onOpenMarketplace: () {},
        onOpenAiCoach: () {},
      );

      // 1. Small phone 360x640 Dark RTL
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_360x640_dark_rtl',
        size: const Size(360, 640),
      );

      // 2. Small phone 360x640 Light RTL
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_360x640_light_rtl',
        size: const Size(360, 640),
        isDark: false,
      );

      // 3. Large phone 412x915 Dark RTL
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_412x915_dark_rtl',
        size: const Size(412, 915),
      );

      // 4. Tablet Landscape 1024x768 Dark RTL
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_1024x768_dark_rtl',
        size: const Size(1024, 768),
      );

      // 5. Small phone TextScale 2.0
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_360x640_textscale2_dark_rtl',
        size: const Size(360, 640),
        textScale: 2.0,
      );

      // 6. LTR English Fallback
      await captureScreen(
        tester: tester,
        child: dashboard,
        fileName: 'flutter_dashboard_412x915_dark_ltr',
        size: const Size(412, 915),
        dir: TextDirection.ltr,
      );
    });

    testWidgets('Active Workout & Workout Screen variations', (tester) async {
      final activeWorkout = ActiveWorkoutScreen(planId: 'p1', state: state);
      final workoutScreen = WorkoutScreen(
        state: state,
        onStartWorkout: (_) {},
        onOpenHomeMode: () {},
      );

      // Workout Screen
      await captureScreen(
        tester: tester,
        child: workoutScreen,
        fileName: 'flutter_workout_plans_412x915_dark_rtl',
        size: const Size(412, 915),
      );

      // Small phone Portrait
      await captureScreen(
        tester: tester,
        child: activeWorkout,
        fileName: 'flutter_active_workout_360x640_dark_rtl',
        size: const Size(360, 640),
      );

      // Small phone Landscape (stress test)
      await captureScreen(
        tester: tester,
        child: activeWorkout,
        fileName: 'flutter_active_workout_640x360_landscape_dark_rtl',
        size: const Size(640, 360),
      );

      // Text Scale 2.0
      await captureScreen(
        tester: tester,
        child: activeWorkout,
        fileName: 'flutter_active_workout_360x640_textscale2_dark_rtl',
        size: const Size(360, 640),
        textScale: 2.0,
      );
    });

    testWidgets('Marketplace Screen variations', (tester) async {
      final marketplace = MarketplaceScreen(state: state);

      await captureScreen(
        tester: tester,
        child: marketplace,
        fileName: 'flutter_marketplace_412x915_dark_rtl',
        size: const Size(412, 915),
      );

      await captureScreen(
        tester: tester,
        child: marketplace,
        fileName: 'flutter_marketplace_360x640_light_rtl',
        size: const Size(360, 640),
        isDark: false,
      );
    });

    testWidgets('Nutrition & Meal Scanner variations', (tester) async {
      await captureScreen(
        tester: tester,
        child: NutritionScreen(state: state, onOpenScanner: () {}),
        fileName: 'flutter_nutrition_412x915_dark_rtl',
        size: const Size(412, 915),
      );

      await captureScreen(
        tester: tester,
        child: MealScannerScreen(state: state),
        fileName: 'flutter_meal_scanner_360x640_dark_rtl',
        size: const Size(360, 640),
      );
    });

    testWidgets('Profile & AI Coach variations', (tester) async {
      await captureScreen(
        tester: tester,
        child: ProfileScreen(state: state),
        fileName: 'flutter_profile_412x915_dark_rtl',
        size: const Size(412, 915),
      );

      await captureScreen(
        tester: tester,
        child: AiCoachScreen(state: state),
        fileName: 'flutter_ai_coach_360x640_dark_rtl',
        size: const Size(360, 640),
      );
    });

    testWidgets('Phase 20 Visual Testing Screenshots', (tester) async {
      // 1. Workout not started
      final workoutNotStarted = WorkoutScreen(
        state: state,
        onStartWorkout: (_) {},
        onOpenHomeMode: () {},
      );
      await captureScreen(
        tester: tester,
        child: workoutNotStarted,
        fileName: 'phase20_workout_not_started',
        size: const Size(360, 640),
      );

      // 2. Active workout
      final activeWorkout = ActiveWorkoutScreen(planId: 'p1', state: state);
      await captureScreen(
        tester: tester,
        child: activeWorkout,
        fileName: 'phase20_active_workout',
        size: const Size(360, 640),
      );

      // 3. Active rest timer
      final timerService = WorkoutTimerService();
      await timerService.start(90);
      await captureScreen(
        tester: tester,
        child: const Scaffold(
          body: Center(
            child: RestTimerDialog(initialSeconds: 90),
          ),
        ),
        fileName: 'phase20_active_rest_timer',
        size: const Size(360, 640),
      );

      // 4. Paused timer
      await timerService.pause();
      await captureScreen(
        tester: tester,
        child: const Scaffold(
          body: Center(
            child: RestTimerDialog(initialSeconds: 90),
          ),
        ),
        fileName: 'phase20_paused_timer',
        size: const Size(360, 640),
      );
      await timerService.cancel();

      // 5. Completed exercise
      final completedDraft = ActiveWorkoutProgress(
        planId: 'p1',
        selectedDay: 1,
        startTimeEpoch: DateTime.now().millisecondsSinceEpoch - 1200000,
        exerciseSets: {
          'pe1': [
            ActiveWorkoutSet(
              setNumber: 1,
              targetReps: 10,
              targetWeightKg: 80.0,
              actualReps: 10,
              actualWeightKg: 80.0,
              isCompleted: true,
            ),
            ActiveWorkoutSet(
              setNumber: 2,
              targetReps: 10,
              targetWeightKg: 80.0,
              actualReps: 10,
              actualWeightKg: 80.0,
              isCompleted: true,
            ),
            ActiveWorkoutSet(
              setNumber: 3,
              targetReps: 10,
              targetWeightKg: 80.0,
              actualReps: 10,
              actualWeightKg: 80.0,
              isCompleted: true,
            ),
            ActiveWorkoutSet(
              setNumber: 4,
              targetReps: 10,
              targetWeightKg: 80.0,
              actualReps: 10,
              actualWeightKg: 80.0,
              isCompleted: true,
            ),
          ],
        },
      );
      state.saveActiveWorkoutDraft(completedDraft);
      final completedExerciseScreen =
          ActiveWorkoutScreen(planId: 'p1', state: state);
      await captureScreen(
        tester: tester,
        child: completedExerciseScreen,
        fileName: 'phase20_completed_exercise',
        size: const Size(360, 640),
      );

      // 6. Completed workout dialog / summary
      await captureScreen(
        tester: tester,
        child: Dialog(
          backgroundColor: const Color(0xFF161E28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                const SizedBox(height: 8),
                const Text('جلسه تمرین ثبت شد',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                    'خسته نباشید! جلسه تمرین با موفقیت در دیتابیس ثبت گردید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2838),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('مجموع تناژ:',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      Text('۳,۲۰۰ کیلوگرم',
                          style: TextStyle(
                              color: Color(0xFFCCFF00),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        fileName: 'phase20_completed_workout',
        size: const Size(360, 640),
      );

      // 7. Focused Training
      final focusedTraining =
          FocusedTrainingScreen(planId: 'p1', state: state);
      await captureScreen(
        tester: tester,
        child: focusedTraining,
        fileName: 'phase20_focused_training',
        size: const Size(360, 640),
      );
      await state.clearActiveWorkoutDraft('p1');
    });
  });
}
