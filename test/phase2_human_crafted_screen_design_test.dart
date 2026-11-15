import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/theme/app_theme.dart';
import 'package:gymbro/core/localization/persian_utils.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/screens/dashboard_screen.dart';
import 'package:gymbro/screens/workout_screen.dart';
import 'package:gymbro/screens/nutrition_screen.dart';
import 'package:gymbro/screens/profile_screen.dart';
import 'package:gymbro/screens/marketplace_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState testState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    testState = AppState(storage: storage);
  });

  Widget wrapWithTheme(Widget child, {TextDirection textDirection = TextDirection.rtl}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: textDirection,
        child: child,
      ),
    );
  }

  group('Phase 2: Human-Crafted Screen Design Tests', () {
    testWidgets('1. DashboardScreen prioritizes Today Workout, Weekly Strip, Nutrition & Hydration', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool startedWorkout = false;

      await tester.pumpWidget(
        wrapWithTheme(
          DashboardScreen(
            state: testState,
            onOpenMealScanner: () {},
            onOpenHomeMode: () {},
            onOpenWorkouts: () {},
            onStartWorkout: (id) => startedWorkout = true,
            onOpenMarketplace: () {},
            onOpenAiCoach: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Weekly consistency
      expect(find.text('تقویم هفتگی تمرینات'), findsOneWidget);

      // Hero Today Workout Card
      expect(find.text('برنامه تمرینی امروز'), findsOneWidget);
      expect(find.text('رفتن به تمرین (ورود به جلسه زنده)'), findsOneWidget);

      // Tap primary CTA
      final cta = find.text('رفتن به تمرین (ورود به جلسه زنده)');
      await tester.ensureVisible(cta);
      await tester.pumpAndSettle();
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(startedWorkout, isTrue);

      // Nutrition & Hydration
      expect(find.text('بودجه کالری و درشت‌مغذی‌ها'), findsOneWidget);
      expect(find.text('مصرف آب و هیدراتاسیون'), findsOneWidget);
      expect(find.text('+۲۵۰ ml'), findsOneWidget);

      // Hydration quick interaction
      final waterBtn = find.text('+۲۵۰ ml');
      await tester.ensureVisible(waterBtn);
      await tester.pumpAndSettle();
      final initialWater = testState.selectedConsumedWaterMl;
      await tester.tap(waterBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(testState.selectedConsumedWaterMl, initialWater + 250);

      // Scanner entry is explicitly text-based in the current demo.
      expect(find.text('ابزارهای سریع'), findsOneWidget);
      expect(find.text('برآورد غذا'), findsOneWidget);
      expect(find.text('مربی هوشمند AI'), findsOneWidget);

      // Verify Marketplace is not forced onto Dashboard
      expect(find.text('باشگاه‌های تهران'), findsNothing);
      expect(find.text('رزرو مربی اختصاصی'), findsNothing);
    });

    testWidgets('Dashboard water actions always update today', (tester) async {
      final historicalDate = DateTime.now().subtract(const Duration(days: 1));
      testState.selectNutritionDate(historicalDate);
      final todayBefore = testState.todayConsumedWaterMl;
      final historyBefore = testState.selectedConsumedWaterMl;

      await tester.pumpWidget(
        wrapWithTheme(
          DashboardScreen(
            state: testState,
            onOpenMealScanner: () {},
            onOpenHomeMode: () {},
            onOpenWorkouts: () {},
            onStartWorkout: (_) {},
            onOpenMarketplace: () {},
            onOpenAiCoach: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addWater = find.text('+۲۵۰ ml');
      await tester.ensureVisible(addWater);
      await tester.tap(addWater);
      await tester.pumpAndSettle();

      expect(testState.todayConsumedWaterMl, todayBefore + 250);
      expect(testState.selectedConsumedWaterMl, historyBefore);
      expect(testState.selectedNutritionDateString,
          PersianUtils.toDateString(historicalDate));
    });

    testWidgets('2. WorkoutScreen provides Exercise Peek Preview and Active Draft Banner', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool workoutTriggered = false;

      await tester.pumpWidget(
        wrapWithTheme(
          WorkoutScreen(
            state: testState,
            onStartWorkout: (id) => workoutTriggered = true,
            onOpenHomeMode: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تمرینات تخصصی جیم‌برو'), findsOneWidget);
      expect(find.text('برنامه‌های تمرینی فعال شما'), findsOneWidget);
      expect(find.text('حرکات اصلی این برنامه:'), findsAtLeastNWidgets(1));

      // Test primary action
      final startBtn = find.text('رفتن به تمرین (ورود به جلسه زنده)').first;
      await tester.ensureVisible(startBtn);
      await tester.pumpAndSettle();
      await tester.tap(startBtn);
      await tester.pumpAndSettle();
      expect(workoutTriggered, isTrue);
    });

    testWidgets('3. NutritionScreen enables immediate data entry with category quick add', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWithTheme(
          NutritionScreen(
            state: testState,
            onOpenScanner: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تغذیه و پایش هوشمند کالری'), findsOneWidget);
      expect(find.text('ثبت وعده'), findsOneWidget);
      expect(find.text('+ ثبت غذا'), findsAtLeastNWidgets(1));
    });

    testWidgets('4. ProfileScreen displays personal progress and 3D anatomical model', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWithTheme(
          ProfileScreen(state: testState),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('پروفایل و جایگاه ورزشی'), findsOneWidget);
      expect(find.text('نقشه عضلات بدن'), findsOneWidget);
      expect(find.text('نمودار تغییرات وزن و هدف'), findsOneWidget);
    });

    testWidgets('5. MarketplaceScreen offers appropriate browsing experience with tabs', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWithTheme(
          MarketplaceScreen(state: testState),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مجموعه‌های ورزشی و مربیان'), findsOneWidget);
      expect(find.text('فهرست نمونه؛ رزرو و پرداخت آنلاین غیرفعال'), findsOneWidget);
      expect(find.text('باشگاه‌های VIP'), findsOneWidget);
      expect(find.text('مربیان خصوصی (۱-به-۱)'), findsOneWidget);
      expect(find.text('رزروهای من'), findsOneWidget);
      expect(testState.bookings, isEmpty);

      final gymAction = find.text('عضویت آنلاین در دسترس نیست').first;
      await tester.ensureVisible(gymAction);
      await tester.tap(gymAction);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('عضویت آنلاین در دسترس نیست'),
        ),
        findsOneWidget,
      );
      expect(testState.bookings, isEmpty);
      await tester.tap(find.text('متوجه شدم'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('مربیان خصوصی (۱-به-۱)'));
      await tester.pumpAndSettle();
      final bookingButton = find.text('بررسی امکان رزرو').first;
      await tester.ensureVisible(bookingButton);
      await tester.tap(bookingButton);
      await tester.pumpAndSettle();
      expect(find.text('رزرو آنلاین در دسترس نیست'), findsOneWidget);
      expect(testState.bookings, isEmpty);
    });
  });
}
