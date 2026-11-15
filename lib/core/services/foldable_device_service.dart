import 'dart:io' show Platform;
import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'workout_timer_service.dart';

enum FoldPosture {
  /// The foldable phone is closed, using the outer cover screen
  folded,

  /// The foldable is opened flat (180 degrees), using the main inner display
  flat,

  /// The foldable is half-opened (tabletop / flex mode, typically 80-110 degrees)
  halfOpened,

  /// Standard candybar smartphone or tablet (not a foldable device)
  notApplicable,
}

enum FoldType {
  /// Book-style foldable (Samsung Galaxy Z Fold, Google Pixel Fold, OnePlus Open)
  book,

  /// Clamshell-style foldable (Samsung Galaxy Z Flip, Motorola Razr)
  clamshell,

  /// Not a foldable device
  none,
}

enum HingeOrientation {
  vertical,
  horizontal,
  none,
}

class FoldableHingeInfo {
  final Rect bounds;
  final HingeOrientation orientation;
  final bool isOccluding;
  final double? angleDegrees;

  const FoldableHingeInfo({
    required this.bounds,
    required this.orientation,
    required this.isOccluding,
    this.angleDegrees,
  });

  @override
  String toString() =>
      'FoldableHingeInfo(bounds: $bounds, orientation: $orientation, angle: $angleDegrees)';
}

class FoldableDeviceInfo {
  final bool isFoldableHardware;
  final FoldType foldType;
  final bool hasHingeSensor;
  final List<String> hardwareFeatures;
  final String deviceModel;
  final String deviceBrand;

  const FoldableDeviceInfo({
    required this.isFoldableHardware,
    required this.foldType,
    required this.hasHingeSensor,
    required this.hardwareFeatures,
    required this.deviceModel,
    required this.deviceBrand,
  });

  factory FoldableDeviceInfo.nonFoldable() {
    return const FoldableDeviceInfo(
      isFoldableHardware: false,
      foldType: FoldType.none,
      hasHingeSensor: false,
      hardwareFeatures: [],
      deviceModel: 'Standard Phone/Tablet',
      deviceBrand: 'Universal',
    );
  }

  factory FoldableDeviceInfo.fromMap(Map<String, dynamic> map) {
    final typeStr = map['foldType'] as String? ?? 'none';
    final foldType = typeStr == 'clamshell'
        ? FoldType.clamshell
        : (typeStr == 'book' ? FoldType.book : FoldType.none);

    final rawFeatures = map['hardwareFeatures'] as List<dynamic>? ?? [];
    final features = rawFeatures.map((e) => e.toString()).toList();

    return FoldableDeviceInfo(
      isFoldableHardware: map['isFoldableHardware'] as bool? ?? false,
      foldType: foldType,
      hasHingeSensor: map['hasHingeSensor'] as bool? ?? false,
      hardwareFeatures: features,
      deviceModel: map['deviceModel'] as String? ?? '',
      deviceBrand: map['deviceBrand'] as String? ?? '',
    );
  }
}

class FoldableDeviceService extends ChangeNotifier {
  static final FoldableDeviceService _instance =
      FoldableDeviceService._internal();
  factory FoldableDeviceService() => _instance;

  FoldableDeviceService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.gymbro.app/device_info');

  FoldableDeviceInfo _deviceInfo = FoldableDeviceInfo.nonFoldable();
  FoldableDeviceInfo get deviceInfo => _deviceInfo;

  FoldPosture _currentPosture = FoldPosture.notApplicable;
  FoldPosture get currentPosture => _currentPosture;

  FoldPosture? _previousPosture;
  FoldPosture? get previousPosture => _previousPosture;

  FoldableHingeInfo? _hingeInfo;
  FoldableHingeInfo? get hingeInfo => _hingeInfo;

  bool _hasShownEasterEggInCurrentSession = false;
  bool get hasShownEasterEggInCurrentSession =>
      _hasShownEasterEggInCurrentSession;

  bool _isWorkoutActiveExplicit = false;

  /// Simulation override for testing and preview
  bool _isSimulated = false;
  bool get isSimulated => _isSimulated;

  /// Whether the device has been confirmed to be a foldable phone
  bool get isFoldableDevice =>
      _deviceInfo.isFoldableHardware ||
      (_hingeInfo != null && _deviceInfo.foldType != FoldType.none);

  /// Whether device is in expanded inner display mode (either flat or flex tabletop)
  bool get isUnfolded =>
      _currentPosture == FoldPosture.flat ||
      _currentPosture == FoldPosture.halfOpened;

  /// Whether device is in flex / tabletop mode
  bool get isTabletopMode => _currentPosture == FoldPosture.halfOpened;

  /// Whether device is folded on the cover screen
  bool get isFolded => _currentPosture == FoldPosture.folded;

  /// Global workout active status (never interrupts workout)
  bool get isWorkoutActive {
    if (_isWorkoutActiveExplicit) return true;
    try {
      final timerService = WorkoutTimerService();
      if (timerService.isRunning) return true;
    } catch (_) {
      // In test or uninitialized state
    }
    return false;
  }

  void setWorkoutActive(bool active) {
    if (_isWorkoutActiveExplicit != active) {
      _isWorkoutActiveExplicit = active;
      notifyListeners();
    }
  }

  /// Initialize device capability via native Android MethodChannel
  Future<void> init() async {
    if (kIsWeb) {
      _deviceInfo = FoldableDeviceInfo.nonFoldable();
      return;
    }

    if (!Platform.isAndroid) {
      _deviceInfo = FoldableDeviceInfo.nonFoldable();
      return;
    }

    try {
      final map =
          await _channel.invokeMapMethod<String, dynamic>('getFoldableCapabilities');
      if (map != null) {
        _deviceInfo = FoldableDeviceInfo.fromMap(map);
        if (_deviceInfo.isFoldableHardware) {
          // Default to folded until metrics confirm inner display
          _currentPosture = FoldPosture.folded;
        }
      }
    } catch (e) {
      debugPrint('GymBro FoldableDeviceService init error: $e');
      _deviceInfo = FoldableDeviceInfo.nonFoldable();
    }
    notifyListeners();
  }

  /// Update posture and display features from MediaQuery
  void updateDisplayMetrics({
    required Size screenSize,
    required List<DisplayFeature> displayFeatures,
    double? hingeAngleDegrees,
  }) {
    if (_isSimulated) return;

    // Check if display features contain physical fold or hinge
    DisplayFeature? foldFeature;
    for (final feature in displayFeatures) {
      if (feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold) {
        foldFeature = feature;
        break;
      }
    }

    if (foldFeature != null) {
      final bounds = foldFeature.bounds;
      final orientation = bounds.width < bounds.height
          ? HingeOrientation.vertical
          : HingeOrientation.horizontal;

      _hingeInfo = FoldableHingeInfo(
        bounds: bounds,
        orientation: orientation,
        isOccluding: bounds.width > 0 && bounds.height > 0,
        angleDegrees: hingeAngleDegrees,
      );

      // If hardware wasn't flagged by OEM model, the physical fold feature confirms it
      if (!_deviceInfo.isFoldableHardware) {
        _deviceInfo = FoldableDeviceInfo(
          isFoldableHardware: true,
          foldType: orientation == HingeOrientation.horizontal
              ? FoldType.clamshell
              : FoldType.book,
          hasHingeSensor: true,
          hardwareFeatures: ['DisplayFeatureType.${foldFeature.type.name}'],
          deviceModel: _deviceInfo.deviceModel,
          deviceBrand: _deviceInfo.deviceBrand,
        );
      }

      final newPosture =
          foldFeature.state == DisplayFeatureState.postureHalfOpened
              ? FoldPosture.halfOpened
              : FoldPosture.flat;

      _setPosture(newPosture);
      return;
    }

    _hingeInfo = null;

    // If device is not a physical foldable, it's not applicable (prevents tablets from being misidentified)
    if (!_deviceInfo.isFoldableHardware) {
      _setPosture(FoldPosture.notApplicable);
      return;
    }

    // On confirmed foldable hardware without an active occluding fold feature in displayFeatures,
    // evaluate aspect ratio to differentiate cover screen vs unfolded flat display.
    if (_deviceInfo.foldType == FoldType.book) {
      final aspectRatio = screenSize.height > screenSize.width
          ? screenSize.height / screenSize.width
          : screenSize.width / screenSize.height;

      // Cover screen of Galaxy Z Fold series has extreme tall aspect ratio (21:9 - 25:9, ratio >= 2.05)
      // and width is typically narrow (<= 440 dp).
      // Inner unfolded screen is nearly square (aspect ratio between 0.9 and 1.35, width >= 600 dp).
      if (aspectRatio >= 2.0 && screenSize.width <= 440) {
        _setPosture(FoldPosture.folded);
      } else if (screenSize.width >= 580 || aspectRatio < 1.6) {
        _setPosture(FoldPosture.flat);
      } else {
        _setPosture(FoldPosture.folded);
      }
    } else if (_deviceInfo.foldType == FoldType.clamshell) {
      // Clamshell (Z Flip): Cover screen is tiny square or widget surface (<= 450x450).
      // Unfolded is full tall screen.
      if (screenSize.height <= 500 && screenSize.width <= 500) {
        _setPosture(FoldPosture.folded);
      } else {
        _setPosture(FoldPosture.flat);
      }
    } else {
      _setPosture(FoldPosture.notApplicable);
    }
  }

  void _setPosture(FoldPosture newPosture) {
    if (_currentPosture != newPosture) {
      _previousPosture = _currentPosture;
      _currentPosture = newPosture;
      notifyListeners();
    }
  }

  /// Determines whether the Easter Egg should be shown according to the 5 scenarios:
  /// Scenario A: Launched already unfolded -> Show once inner screen is ready.
  /// Scenario B: Launched folded -> Do not show on cover screen; wait for unfold.
  /// Scenario C: Folded -> Unfolded transition -> Show!
  /// Scenario D: Re-opened during same session -> Do NOT show again.
  /// Scenario E: Middle of a workout -> NEVER interrupt active exercise, timer, or alarm.
  bool shouldTriggerEasterEgg() {
    // Must be confirmed foldable hardware
    if (!isFoldableDevice) return false;

    // Must be currently on the expanded inner screen (flat or half-opened)
    if (!isUnfolded) return false;

    // Scenario D: Do not show repeatedly in the same session
    if (_hasShownEasterEggInCurrentSession) return false;

    // Scenario E: Never interrupt an active workout
    if (isWorkoutActive) return false;

    // Scenario A: Launched already unfolded (previousPosture was null, notApplicable, or flat)
    // Scenario C: Transition from folded to unfolded
    final isUnfoldTransition = _previousPosture == FoldPosture.folded;
    final isLaunchedUnfolded = _previousPosture == null ||
        _previousPosture == FoldPosture.notApplicable ||
        _previousPosture == FoldPosture.flat;

    return isUnfoldTransition || isLaunchedUnfolded;
  }

  /// Mark Easter Egg as delivered for current session
  void markEasterEggShown() {
    _hasShownEasterEggInCurrentSession = true;
    notifyListeners();
  }

  /// Reset session flag for testing or simulation
  void resetSessionForTesting() {
    _hasShownEasterEggInCurrentSession = false;
    _previousPosture = null;
    _currentPosture = FoldPosture.notApplicable;
    _isWorkoutActiveExplicit = false;
    notifyListeners();
  }

  /// Simulation helper for test harness and HTML simulator integration
  void setSimulatedDevice({
    required bool isFoldable,
    FoldType foldType = FoldType.book,
    FoldPosture posture = FoldPosture.folded,
    FoldableHingeInfo? hinge,
    FoldPosture? previousPosture,
  }) {
    _isSimulated = true;
    _deviceInfo = FoldableDeviceInfo(
      isFoldableHardware: isFoldable,
      foldType: isFoldable ? foldType : FoldType.none,
      hasHingeSensor: isFoldable,
      hardwareFeatures: isFoldable ? ['SIMULATED_HINGE'] : [],
      deviceModel: isFoldable ? 'Simulated Foldable' : 'Standard Phone',
      deviceBrand: 'GymBro Test',
    );
    _hingeInfo = hinge;
    if (previousPosture != null) {
      _previousPosture = previousPosture;
      _currentPosture = isFoldable ? posture : FoldPosture.notApplicable;
    } else {
      _setPosture(isFoldable ? posture : FoldPosture.notApplicable);
    }
    notifyListeners();
  }

  void endSimulation() {
    _isSimulated = false;
    notifyListeners();
  }
}
