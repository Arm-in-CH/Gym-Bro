import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/core/services/foldable_device_service.dart';
import 'package:gymbro/widgets/foldable_adaptive_layout.dart';
import 'package:gymbro/widgets/foldable_easter_egg.dart';
import 'package:gymbro/widgets/cabbage_mascot_loader.dart';
import 'package:gymbro/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GymBro Phase 9: Foldable Device Detection & Capability Tests', () {
    test('Non-foldable device fallback correctly flags device as not foldable', () {
      final info = FoldableDeviceInfo.nonFoldable();
      expect(info.isFoldableHardware, isFalse);
      expect(info.foldType, equals(FoldType.none));
      expect(info.hasHingeSensor, isFalse);
    });

    test('Samsung Galaxy Z Fold series is accurately recognized as book fold', () {
      final map = {
        'isFoldableHardware': true,
        'foldType': 'book',
        'hasHingeSensor': true,
        'hardwareFeatures': [
          'android.hardware.sensor.hinge_angle',
          'com.sec.feature.foldable_dual_display',
          'OEM_FOLDABLE_MODEL_MATCH',
        ],
        'deviceModel': 'SM-F946B',
        'deviceBrand': 'SAMSUNG',
      };

      final info = FoldableDeviceInfo.fromMap(map);
      expect(info.isFoldableHardware, isTrue);
      expect(info.foldType, equals(FoldType.book));
      expect(info.hasHingeSensor, isTrue);
      expect(info.deviceModel, equals('SM-F946B'));

      final zFold8Info = FoldableDeviceInfo.fromMap({
        'isFoldableHardware': true,
        'foldType': 'book',
        'hasHingeSensor': true,
        'deviceModel': 'SM-F976B',
        'deviceBrand': 'SAMSUNG',
      });
      expect(zFold8Info.isFoldableHardware, isTrue);
      expect(zFold8Info.foldType, equals(FoldType.book));
    });

    test('Samsung Galaxy Z Flip series is accurately recognized as clamshell fold', () {
      final map = {
        'isFoldableHardware': true,
        'foldType': 'clamshell',
        'hasHingeSensor': true,
        'hardwareFeatures': [
          'com.sec.feature.foldable_single_display',
          'OEM_FOLDABLE_MODEL_MATCH',
        ],
        'deviceModel': 'SM-F731B',
        'deviceBrand': 'SAMSUNG',
      };

      final info = FoldableDeviceInfo.fromMap(map);
      expect(info.isFoldableHardware, isTrue);
      expect(info.foldType, equals(FoldType.clamshell));
      expect(info.hasHingeSensor, isTrue);
    });

    test('Large tablet is NOT classified as a foldable device based on screen size alone', () {
      final service = FoldableDeviceService();
      service.resetSessionForTesting();
      service.endSimulation();

      // Tablet with 800x1280 resolution, but non-foldable hardware and no fold features
      service.updateDisplayMetrics(
        screenSize: const Size(800, 1280),
        displayFeatures: const [],
      );

      expect(service.isFoldableDevice, isFalse);
      expect(service.currentPosture, equals(FoldPosture.notApplicable));
      expect(service.shouldTriggerEasterEgg(), isFalse);
    });

    test('Physical DisplayFeature confirms foldable posture and hinge information', () {
      final service = FoldableDeviceService();
      service.resetSessionForTesting();
      service.endSimulation();

      const hingeRect = Rect.fromLTWH(374, 0, 20, 900);
      const feature = DisplayFeature(
        bounds: hingeRect,
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureFlat,
      );

      service.updateDisplayMetrics(
        screenSize: const Size(768, 900),
        displayFeatures: const [feature],
      );

      expect(service.isFoldableDevice, isTrue);
      expect(service.currentPosture, equals(FoldPosture.flat));
      expect(service.hingeInfo, isNotNull);
      expect(service.hingeInfo!.orientation, equals(HingeOrientation.vertical));
      expect(service.hingeInfo!.isOccluding, isTrue);
    });

    test('Tabletop / Flex mode is identified when DisplayFeature state is postureHalfOpened', () {
      final service = FoldableDeviceService();
      service.resetSessionForTesting();
      service.endSimulation();

      const horizontalHinge = Rect.fromLTWH(0, 440, 360, 20);
      const feature = DisplayFeature(
        bounds: horizontalHinge,
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      service.updateDisplayMetrics(
        screenSize: const Size(360, 900),
        displayFeatures: const [feature],
      );

      expect(service.isTabletopMode, isTrue);
      expect(service.currentPosture, equals(FoldPosture.halfOpened));
      expect(service.hingeInfo!.orientation, equals(HingeOrientation.horizontal));
    });
  });

  group('GymBro Phase 9: Easter Egg 5-Scenario Verification', () {
    late FoldableDeviceService service;

    setUp(() {
      service = FoldableDeviceService();
      service.resetSessionForTesting();
      service.setWorkoutActive(false);
    });

    tearDown(() {
      service.endSimulation();
    });

    test('SCENARIO A: App launched while foldable device is already unfolded', () {
      // Simulate launching on inner screen of Z Fold
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );

      // Inner screen is ready, workout is not active
      expect(service.isFoldableDevice, isTrue);
      expect(service.isUnfolded, isTrue);
      expect(service.shouldTriggerEasterEgg(), isTrue);

      // Once marked, it should not trigger again
      service.markEasterEggShown();
      expect(service.shouldTriggerEasterEgg(), isFalse);
    });

    test('SCENARIO B: App launched while foldable is folded on cover screen', () {
      // Launch on cover display
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.folded,
      );

      expect(service.isFolded, isTrue);
      expect(service.isUnfolded, isFalse);

      // Must NOT show easter egg on cover screen
      expect(service.shouldTriggerEasterEgg(), isFalse);
    });

    test('SCENARIO C: App launched folded, then user unfolds the device', () {
      // Step 1: Start folded
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.folded,
      );
      expect(service.shouldTriggerEasterEgg(), isFalse);

      // Step 2: Unfold device to flat inner display
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );

      // Posture changed from folded -> flat: Easter Egg must trigger!
      expect(service.previousPosture, equals(FoldPosture.folded));
      expect(service.currentPosture, equals(FoldPosture.flat));
      expect(service.shouldTriggerEasterEgg(), isTrue);
    });

    test('SCENARIO D: User folds phone again and reopens it (Session deduplication)', () {
      // Step 1: Unfold and show
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );
      expect(service.shouldTriggerEasterEgg(), isTrue);
      service.markEasterEggShown();

      // Step 2: Fold phone
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.folded,
      );

      // Step 3: Unfold again in the same app session
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );

      // Must avoid repeated popups during the same session
      expect(service.hasShownEasterEggInCurrentSession, isTrue);
      expect(service.shouldTriggerEasterEgg(), isFalse);
    });

    test('SCENARIO E: User is in the middle of a workout (Active exercise, timer, alarm)', () {
      // Device unfolds during a workout
      service.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );

      // Mark workout active
      service.setWorkoutActive(true);

      // NEVER interrupt an active workout
      expect(service.isWorkoutActive, isTrue);
      expect(service.shouldTriggerEasterEgg(), isFalse);

      // When workout finishes, easter egg check can proceed if not yet shown
      service.setWorkoutActive(false);
      expect(service.shouldTriggerEasterEgg(), isTrue);
    });
  });

  group('GymBro Phase 9: Foldable Adaptive Layout Tests', () {
    testWidgets('FoldableTwoPane renders single pane on narrow cover screen',
        (tester) async {
      tester.view.physicalSize = const Size(375, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoldableTwoPane(
              pane1: Text('Primary Pane 1'),
              pane2: Text('Secondary Pane 2'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Primary Pane 1'), findsOneWidget);
      expect(find.text('Secondary Pane 2'), findsNothing);
    });

    testWidgets('FoldableTwoPane splits into dual panes on wide unfolded screen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoldableTwoPane(
              pane1: Text('Primary Pane 1'),
              pane2: Text('Secondary Pane 2'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Primary Pane 1'), findsOneWidget);
      expect(find.text('Secondary Pane 2'), findsOneWidget);
    });
  });

  group('GymBro Phase 9: Easter Egg UI & Animation Tests', () {
    testWidgets('FoldableEasterEggBanner displays the GymBro message and mascot',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FoldableEasterEggBanner(
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      // Pump entrance animation
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Persian Easter Egg text
      expect(find.text('اوه، ببین کی داره پُز می‌ده بابا!'), findsOneWidget);
      expect(find.text('حالا برو تمرینتو بکن.'), findsOneWidget);
      expect(find.byType(CabbageMascotLoader), findsOneWidget);

      // Verify GymBro branding badge
      expect(find.text('GYMBRO FOLD'), findsOneWidget);

      // Tap action button to dismiss
      await tester.tap(find.text('باشه، بریم تمرین'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 50));

      expect(dismissed, isTrue);
    });

    testWidgets('Foldable overlay shows only after folded-to-unfolded transition',
        (tester) async {
      final foldableService = FoldableDeviceService();
      foldableService.resetSessionForTesting();
      foldableService.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.folded,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FoldableEasterEggOverlay(
            child: Scaffold(body: Text('Workout home')),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('اوه، ببین کی داره پُز می‌ده بابا!'), findsNothing);

      foldableService.setSimulatedDevice(
        isFoldable: true,
        foldType: FoldType.book,
        posture: FoldPosture.flat,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('اوه، ببین کی داره پُز می‌ده بابا!'), findsOneWidget);
      expect(foldableService.hasShownEasterEggInCurrentSession, isTrue);
      foldableService.endSimulation();
    });
  });
}
