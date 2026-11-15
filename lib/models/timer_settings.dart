import '../core/storage/safe_cast.dart';

class TimerSettings {
  final int defaultRestSeconds;
  final bool autoStartTimer;
  final bool soundAlerts;
  final bool vibrationAlerts;

  const TimerSettings({
    this.defaultRestSeconds = 90,
    this.autoStartTimer = false,
    this.soundAlerts = true,
    this.vibrationAlerts = true,
  });

  Map<String, dynamic> toJson() => {
        'defaultRestSeconds': defaultRestSeconds,
        'autoStartTimer': autoStartTimer,
        'soundAlerts': soundAlerts,
        'vibrationAlerts': vibrationAlerts,
      };

  factory TimerSettings.fromJson(Map<String, dynamic> json) => TimerSettings(
        defaultRestSeconds: SafeCast.toInt(json['defaultRestSeconds'], 90),
        autoStartTimer: SafeCast.toBool(json['autoStartTimer'], false),
        soundAlerts: SafeCast.toBool(json['soundAlerts'], true),
        vibrationAlerts: SafeCast.toBool(json['vibrationAlerts'], true),
      );

  TimerSettings copyWith({
    int? defaultRestSeconds,
    bool? autoStartTimer,
    bool? soundAlerts,
    bool? vibrationAlerts,
  }) {
    return TimerSettings(
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      autoStartTimer: autoStartTimer ?? this.autoStartTimer,
      soundAlerts: soundAlerts ?? this.soundAlerts,
      vibrationAlerts: vibrationAlerts ?? this.vibrationAlerts,
    );
  }
}
