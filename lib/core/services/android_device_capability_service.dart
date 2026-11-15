import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidDeviceInfo {
  final String manufacturer;
  final String model;
  final String brand;
  final String device;
  final String androidVersion;
  final int sdkInt;
  final bool isXiaomi;
  final bool isHyperOs;
  final String? miuiVersion;
  final String? hyperOsVersion;
  final bool isSamsung;
  final String? oneUiVersion;
  final bool isPixel;
  final bool isIgnoringBatteryOptimizations;
  final bool areNotificationsEnabled;
  final bool canScheduleExactAlarms;

  const AndroidDeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.brand,
    required this.device,
    required this.androidVersion,
    required this.sdkInt,
    required this.isXiaomi,
    required this.isHyperOs,
    this.miuiVersion,
    this.hyperOsVersion,
    required this.isSamsung,
    this.oneUiVersion,
    required this.isPixel,
    required this.isIgnoringBatteryOptimizations,
    required this.areNotificationsEnabled,
    required this.canScheduleExactAlarms,
  });

  /// Factory for unknown / test fallback environment
  factory AndroidDeviceInfo.fallback() {
    return const AndroidDeviceInfo(
      manufacturer: 'Android Device',
      model: 'Universal',
      brand: 'Generic',
      device: 'generic',
      androidVersion: '14.0',
      sdkInt: 34,
      isXiaomi: false,
      isHyperOs: false,
      miuiVersion: null,
      hyperOsVersion: null,
      isSamsung: false,
      oneUiVersion: null,
      isPixel: false,
      isIgnoringBatteryOptimizations: true,
      areNotificationsEnabled: true,
      canScheduleExactAlarms: true,
    );
  }

  factory AndroidDeviceInfo.fromMap(Map<String, dynamic> map) {
    return AndroidDeviceInfo(
      manufacturer: map['manufacturer'] as String? ?? 'Android',
      model: map['model'] as String? ?? 'Device',
      brand: map['brand'] as String? ?? '',
      device: map['device'] as String? ?? '',
      androidVersion: map['androidVersion'] as String? ?? '14.0',
      sdkInt: map['sdkInt'] as int? ?? 34,
      isXiaomi: map['isXiaomi'] as bool? ?? false,
      isHyperOs: map['isHyperOs'] as bool? ?? false,
      miuiVersion: map['miuiVersion'] as String?,
      hyperOsVersion: map['hyperOsVersion'] as String?,
      isSamsung: map['isSamsung'] as bool? ?? false,
      oneUiVersion: map['oneUiVersion'] as String?,
      isPixel: map['isPixel'] as bool? ?? false,
      isIgnoringBatteryOptimizations:
          map['isIgnoringBatteryOptimizations'] as bool? ?? false,
      areNotificationsEnabled: map['areNotificationsEnabled'] as bool? ?? false,
      canScheduleExactAlarms: map['canScheduleExactAlarms'] as bool? ?? true,
    );
  }

  /// Whether device family supports Xiaomi Focus Notifications / HyperIsland
  bool get supportsXiaomiFocusNotification => isHyperOs || isXiaomi;

  /// Whether device family supports Samsung One UI Lockscreen and AOD live widgets
  bool get supportsSamsungLiveWidget => isSamsung && sdkInt >= 31;

  /// Human-readable display label of the operating environment
  String get systemUiLabel {
    if (isHyperOs) {
      return hyperOsVersion != null
          ? 'Xiaomi HyperOS ($hyperOsVersion)'
          : 'Xiaomi HyperOS';
    }
    if (isXiaomi && miuiVersion != null) {
      return 'MIUI $miuiVersion';
    }
    if (isSamsung && oneUiVersion != null) {
      return 'Samsung $oneUiVersion';
    }
    if (isPixel) {
      return 'Google Pixel Experience (Android $androidVersion)';
    }
    return 'Android $androidVersion (API $sdkInt)';
  }

  /// Diagnostic summary of background restrictions for GymBro timer reliability
  String get backgroundReliabilityStatusFa {
    if (!areNotificationsEnabled) {
      return 'مجوز اعلان‌ها صادر نشده است؛ نوتیفیکیشن زنده غیرفعال است.';
    }
    if (!canScheduleExactAlarms && sdkInt >= 31) {
      return 'مجوز زنگ دقیق (Exact Alarm) صادر نشده است؛ آلارم ممکن است با تاخیر شلیک شود.';
    }
    if (!isIgnoringBatteryOptimizations) {
      if (isXiaomi) {
        return 'بهینه‌سازی باتری شیائومی فعال است. برای جلوگیری از بسته شدن در پس‌زمینه، مصرف باتری را روی «بدون محدودیت» قرار دهید.';
      }
      if (isSamsung) {
        return 'حالت ذخیره انرژی سامسونگ فعال است؛ لطفاً برنامه را در لیست Never Sleeping Apps قرار دهید.';
      }
      return 'بهینه‌سازی باتری سیستم فعال است.';
    }
    return 'شرایط پس‌زمینه پایدار و بهینه است (کامل)';
  }
}

class AndroidDeviceCapabilityService {
  static final AndroidDeviceCapabilityService _instance =
      AndroidDeviceCapabilityService._internal();
  factory AndroidDeviceCapabilityService() => _instance;
  AndroidDeviceCapabilityService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.gymbro.app/device_info');

  AndroidDeviceInfo? _cachedInfo;

  /// Returns detected device capabilities, using cached data when possible
  Future<AndroidDeviceInfo> getDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    if (kIsWeb || !Platform.isAndroid) {
      _cachedInfo = AndroidDeviceInfo.fallback();
      return _cachedInfo!;
    }

    try {
      final res =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (res != null) {
        _cachedInfo = AndroidDeviceInfo.fromMap(Map<String, dynamic>.from(res));
      } else {
        _cachedInfo = AndroidDeviceInfo.fallback();
      }
    } catch (_) {
      _cachedInfo = AndroidDeviceInfo.fallback();
    }
    return _cachedInfo!;
  }

  /// Opens the system dialog/screen to request battery optimization whitelist
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final result = await _channel
          .invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens manufacturer-specific autostart settings (Xiaomi/Samsung)
  Future<bool> openAutostartSettings() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('openAutostartSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
