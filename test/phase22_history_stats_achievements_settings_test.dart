import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/models/workout_log.dart';
import 'package:gymbro/models/achievement_model.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/screens/workout_history_screen.dart';
import 'package:gymbro/screens/achievements_screen.dart';
import 'package:gymbro/screens/settings_screen.dart';

Widget _wrap(Widget child, [AppState? state]) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStorageService storage;
  late AppState testState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    testState = AppState(storage: storage);
  });

  group('Phase 22: Workout History & Statistics Dashboard Tests', () {
    testWidgets('WorkoutHistoryScreen switches between History and Statistics tabs', (tester) async {
      // Seed a sample workout log
      final log = WorkoutLog(
        id: 'hist_test_1',
        planId: 'p1',
        planTitle: 'تمرین بالاتنه فوق‌العاده',
        date: '۱۴۰۴/۱۲/۲۲',
        durationMinutes: 50,
        totalVolumeKg: 4500.0,
        completedSets: 12,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sets: [
          WorkoutSetLog(
            id: 's1',
            exerciseName: 'پرس سینه هالتر',
            setNumber: 1,
            reps: 10,
            weightKg: 80.0,
          ),
          WorkoutSetLog(
            id: 's2',
            exerciseName: 'پرس سینه هالتر',
            setNumber: 2,
            reps: 8,
            weightKg: 90.0,
          ),
        ],
      );

      await testState.workoutRepository.saveWorkoutLog(log);
      testState.workoutLogs = await testState.workoutRepository.getWorkoutLogs();

      await tester.pumpWidget(_wrap(WorkoutHistoryScreen(state: testState), testState));
      await tester.pumpAndSettle();

      // Verify Tab headers
      expect(find.text('پرونده تمرینات'), findsOneWidget);
      expect(find.text('داشبورد آماری'), findsOneWidget);

      // Verify History Tab items
      expect(find.text('تمرین بالاتنه فوق‌العاده'), findsOneWidget);
      expect(find.text('۴۵۰۰ kg'), findsOneWidget);

      // Switch to Statistics Tab
      await tester.tap(find.text('داشبورد آماری'));
      await tester.pumpAndSettle();

      // Verify Statistics Tab contents
      expect(find.text('استمرار تمرینی'), findsOneWidget);
      expect(find.text('بزرگترین رکورد تناژ'), findsOneWidget);
      expect(find.text('رکوردهای وزنی شخصی (Personal Records)'), findsOneWidget);
      expect(find.text('پرس سینه هالتر'), findsOneWidget);
      expect(find.text('۹۰kg × ۸'), findsOneWidget);

      // Verify Metric switcher buttons
      expect(find.text('تناژ (Volume)'), findsOneWidget);
      expect(find.text('کالری فعال (Calories)'), findsOneWidget);
      expect(find.text('ست‌ها (Sets)'), findsOneWidget);

      // Tap Sets metric switcher
      await tester.tap(find.text('ست‌ها (Sets)'));
      await tester.pumpAndSettle();
      expect(find.text('مجموع کل ست‌های تمرین ثبت‌شده'), findsOneWidget);
    });
  });

  group('Phase 22: Achievements System Tests', () {
    test('AchievementItem computes real state values correctly without fake claims', () {
      final items = AchievementItem.computeAllAchievements(testState);
      expect(items.isNotEmpty, isTrue);

      final streakItem = items.firstWhere((a) => a.id == 'streak_1');
      expect(streakItem.targetValue, equals(3));
      expect(streakItem.currentValue, equals(testState.userProfile.streakDays));
      expect(streakItem.isUnlocked, equals(testState.userProfile.streakDays >= 3));

      final workoutItem = items.firstWhere((a) => a.id == 'workout_1');
      expect(workoutItem.targetValue, equals(1));
      expect(workoutItem.currentValue, equals(testState.workoutLogs.length));
    });

    testWidgets('AchievementsScreen renders badges and shows detail modal on tap', (tester) async {
      await tester.pumpWidget(_wrap(AchievementsScreen(state: testState), testState));
      await tester.pumpAndSettle();

      // Verify screen title & summary
      expect(find.text('دست‌آوردها و مدال‌ها'), findsOneWidget);
      expect(find.text('مدال‌های قهرمانی جیم‌برو'), findsOneWidget);
      expect(find.textContaining('دست‌آورد کسب‌شده'), findsOneWidget);

      // Tap on a badge to open detail dialog
      final badge = find.text('شروع استمرار');
      expect(badge, findsOneWidget);
      await tester.tap(badge);
      await tester.pumpAndSettle();

      // Dialog explains record-based unlocks without promising inactive rewards.
      expect(find.text('سطح ۱'), findsOneWidget);
      expect(find.text('ثبت ۳ روز حضور و تمرین مداوم'), findsOneWidget);
      expect(find.textContaining('پاداش سکه‌ای فعال نیست'), findsOneWidget);
      expect(find.textContaining('پاداش:'), findsNothing);

      // Close dialog
      await tester.tap(find.text('بستن'));
      await tester.pumpAndSettle();
    });
  });

  group('Phase 22: Settings Screen Tests', () {
    testWidgets('SettingsScreen updates timer preferences and shows data summary', (tester) async {
      await tester.pumpWidget(_wrap(SettingsScreen(state: testState), testState));
      await tester.pumpAndSettle();

      // Verify sections
      expect(find.text('تنظیمات و ترجیحات'), findsOneWidget);
      expect(find.text('تنظیمات تایمر استراحت بین ست‌ها'), findsOneWidget);
      expect(find.text('اعلان‌ها و یادآورهای هوشمند'), findsOneWidget);
      expect(find.text('ظاهر، پوسته و زبان'), findsOneWidget);
      expect(find.text('مدیریت داده‌ها و پشتیبان‌گیری'), findsOneWidget);

      // Change timer preset to 60s
      final pill60 = find.text('۶۰s');
      expect(pill60, findsOneWidget);
      await tester.tap(pill60);
      await tester.pumpAndSettle();
      expect(testState.timerSettings.defaultRestSeconds, equals(60));

      // Toggle auto start timer switch
      final autoStartSwitch = find.widgetWithText(SwitchListTile, 'شروع خودکار تایمر استراحت');
      expect(autoStartSwitch, findsOneWidget);
      await tester.tap(autoStartSwitch);
      await tester.pumpAndSettle();
      expect(testState.timerSettings.autoStartTimer, isTrue);

      // Tap view data storage status
      final viewDataBtn = find.text('مشاهده وضعیت');
      await tester.ensureVisible(viewDataBtn);
      await tester.tap(viewDataBtn);
      await tester.pumpAndSettle();

      expect(find.text('شناسنامه پرونده ورزشی'), findsOneWidget);
      expect(find.text('تایید و بازگشت'), findsOneWidget);
      await tester.tap(find.text('تایید و بازگشت'));
      await tester.pumpAndSettle();
    });
  });
}
