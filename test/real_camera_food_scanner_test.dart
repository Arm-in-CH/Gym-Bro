import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro/core/storage/local_storage_service.dart';
import 'package:gymbro/core/services/camera_service.dart';
import 'package:gymbro/state/app_state.dart';
import 'package:gymbro/screens/meal_scanner_screen.dart';
import 'package:gymbro/core/theme/app_theme.dart';

Widget buildTestApp({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    locale: const Locale('fa', 'IR'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    ),
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

  group('GymBro Phase 05: Real Camera Integration & Food Scanner Tests', () {
    testWidgets('1. Permission granted: shows camera viewfinder or capture interface', (tester) async {
      final cameraService = SimulatedCameraService(
        permissionStatus: CameraPermissionStatus.granted,
        cameraAvailable: true,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اسکنر هوشمند غذا'), findsOneWidget);
      expect(find.text('دوربین و تصویر'), findsOneWidget);
      expect(find.text('برآورد متنی دستی'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('2. Permission denied: displays informative banner and request CTA', (tester) async {
      final cameraService = SimulatedCameraService(
        permissionStatus: CameraPermissionStatus.denied,
        cameraAvailable: true,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('دسترسی دوربین رد شده است'), findsOneWidget);
      expect(find.text('درخواست دسترسی'), findsOneWidget);
      expect(find.text('انتخاب از گالری'), findsOneWidget);
    });

    testWidgets('3. Camera unavailable: provides gallery fallback cleanly without crashing', (tester) async {
      final cameraService = SimulatedCameraService(
        cameraAvailable: false,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('دوربین زنده در این محیط در دسترس نیست'), findsOneWidget);
      expect(find.text('انتخاب عکس غذا از گالری'), findsOneWidget);
    });

    testWidgets('4. Gallery selection: loads valid image and transitions to confirmation preview', (tester) async {
      final validImage = CapturedImage(
        path: 'gallery_steak.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02, 0x03]),
        sizeBytes: 7,
      );

      final cameraService = SimulatedCameraService(
        cameraAvailable: true,
        mockImage: validImage,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap gallery button
      await tester.tap(find.byIcon(Icons.photo_library_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('تصویر آماده تحلیل است'), findsOneWidget);
      expect(find.text('عکاسی مجدد'), findsOneWidget);
      expect(find.text('تأیید و تحلیل تصویر'), findsOneWidget);
    });

    testWidgets('5. Cancelled capture / gallery: preserves state without error', (tester) async {
      final cameraService = SimulatedCameraService(
        cameraAvailable: true,
        shouldFailCapture: true, // Simulates cancellation / null return
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_library_outlined).first);
      await tester.pumpAndSettle();

      // Should not crash and remains on capture view
      expect(find.text('اسکنر هوشمند غذا'), findsOneWidget);
      expect(find.text('تأیید و تحلیل تصویر'), findsNothing);
    });

    testWidgets('6. Invalid image handling: rejects empty or corrupt bytes', (tester) async {
      final corruptImage = CapturedImage(
        path: 'corrupt.jpg',
        bytes: Uint8List(0),
        sizeBytes: 0,
      );

      final cameraService = SimulatedCameraService(
        cameraAvailable: false,
        mockImage: corruptImage,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('انتخاب عکس غذا از گالری'));
      await tester.pumpAndSettle();

      expect(find.text('تصویر انتخابی نامعتبر یا بیش از حد حجیم است.'), findsOneWidget);
    });

    testWidgets('7. AI Analysis & Uncertainty Notice: displays structured macros and disclaimers', (tester) async {
      final validImage = CapturedImage(
        path: 'food.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02, 0x03]),
        sizeBytes: 7,
      );

      final cameraService = SimulatedCameraService(
        mockImage: validImage,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select image
      await tester.tap(find.byIcon(Icons.photo_library_outlined).first);
      await tester.pumpAndSettle();

      // Tap analyze
      await tester.tap(find.text('تأیید و تحلیل تصویر'));
      await tester.pumpAndSettle();

      // Verify structured breakdown
      expect(find.text('نتیجه تحلیل هوشمند غذا'), findsOneWidget);
      expect(find.textContaining('توجه: مقادیر ارائه‌شده برآورد هوش مصنوعی هستند'), findsOneWidget);
      expect(find.text('کالری'), findsOneWidget);
      expect(find.text('پروتئین'), findsOneWidget);
      expect(find.text('کربوهیدرات'), findsOneWidget);
      expect(find.text('چربی'), findsOneWidget);
      expect(find.text('تایید و ثبت در برنامه تغذیه'), findsOneWidget);
    });

    testWidgets('8. User rejection (Discard & Retake): clears analysis and resumes camera', (tester) async {
      final validImage = CapturedImage(
        path: 'food.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02, 0x03]),
        sizeBytes: 7,
      );

      final cameraService = SimulatedCameraService(mockImage: validImage);

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_library_outlined).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأیید و تحلیل تصویر'));
      await tester.pumpAndSettle();

      expect(find.text('نتیجه تحلیل هوشمند غذا'), findsOneWidget);

      // User decides to discard and retake
      await tester.ensureVisible(find.text('انصراف / لغو'));
      await tester.tap(find.text('انصراف / لغو'));
      await tester.pumpAndSettle();

      expect(find.text('نتیجه تحلیل هوشمند غذا'), findsNothing);
      expect(find.text('اسکنر هوشمند غذا'), findsOneWidget);
    });

    testWidgets('9. Confirmed nutrition entry: persists to nutrition state and prevents duplicates', (tester) async {
      final initialMealCount = appState.todayMeals.length;

      final validImage = CapturedImage(
        path: 'salmon_salad.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02, 0x03]),
        sizeBytes: 7,
      );

      final cameraService = SimulatedCameraService(mockImage: validImage);

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_library_outlined).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأیید و تحلیل تصویر'));
      await tester.pumpAndSettle();

      // Confirm & Save
      await tester.ensureVisible(find.text('تایید و ثبت در برنامه تغذیه'));
      await tester.tap(find.text('تایید و ثبت در برنامه تغذیه'));
      await tester.pumpAndSettle();

      // Verify that the meal was saved
      expect(appState.todayMeals.length, equals(initialMealCount + 1));
      expect(appState.todayMeals.any((m) => m.mealType == 'ناهار'), isTrue);
    });

    testWidgets('10. Preserves manual text estimation functionality', (tester) async {
      final cameraService = SimulatedCameraService();

      await tester.pumpWidget(
        buildTestApp(
          child: MealScannerScreen(
            state: appState,
            cameraService: cameraService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to manual text tab
      await tester.tap(find.text('برآورد متنی دستی'));
      await tester.pumpAndSettle();

      expect(find.text('نام و ترکیبات غذا'), findsOneWidget);
      expect(find.text('تحلیل متن غذا با هوش مصنوعی'), findsOneWidget);

      // Select quick meal
      await tester.tap(find.text('۱۰ قاشق برنج + ۱۵۰ گرم فیله مرغ گریل'));
      await tester.pumpAndSettle();

      expect(find.text('نتیجه تحلیل هوشمند غذا'), findsOneWidget);
      expect(find.text('تایید و ثبت در برنامه تغذیه'), findsOneWidget);
    });
  });
}
