import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_notification_service.dart';
import 'android_live_timer_notification_service.dart';

enum WorkoutTimerStatus {
  idle,
  running,
  paused,
  completed,
}

class WorkoutTimerService extends ChangeNotifier with WidgetsBindingObserver {
  static final WorkoutTimerService _instance = WorkoutTimerService._internal();
  factory WorkoutTimerService() => _instance;

  WorkoutTimerService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  final AlarmNotificationService _alarmService = AlarmNotificationService();
  final AndroidLiveTimerNotificationService _liveNotificationService =
      AndroidLiveTimerNotificationService();

  static const List<int> predefinedDurations = [15, 30, 45, 60, 90, 120];

  static const String _keyTargetEndTime = 'gymbro_timer_target_end_ms';
  static const String _keyTotalDuration = 'gymbro_timer_total_duration';
  static const String _keyStatus = 'gymbro_timer_status';
  static const String _keyPausedRemaining = 'gymbro_timer_paused_remaining';

  WorkoutTimerStatus _status = WorkoutTimerStatus.idle;
  WorkoutTimerStatus get status => _status;

  int _totalDurationSeconds = 90;
  int get totalDurationSeconds => _totalDurationSeconds;

  DateTime? _targetEndTime;
  DateTime? get targetEndTime => _targetEndTime;

  int? _pausedRemainingSeconds;

  Timer? _ticker;

  /// Returns the true, timestamp-calculated remaining seconds.
  int get remainingSeconds {
    if (_status == WorkoutTimerStatus.idle) {
      return _totalDurationSeconds;
    }
    if (_status == WorkoutTimerStatus.paused) {
      return _pausedRemainingSeconds ?? _totalDurationSeconds;
    }
    if (_status == WorkoutTimerStatus.completed) {
      return 0;
    }

    if (_targetEndTime == null) return 0;
    final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  double get progressFraction {
    if (_totalDurationSeconds <= 0) return 0.0;
    final fraction = remainingSeconds / _totalDurationSeconds;
    return fraction.clamp(0.0, 1.0);
  }

  bool get isRunning => _status == WorkoutTimerStatus.running;
  bool get isPaused => _status == WorkoutTimerStatus.paused;
  bool get isCompleted => _status == WorkoutTimerStatus.completed;
  bool get isIdle => _status == WorkoutTimerStatus.idle;

  /// Initializes the service and restores any ongoing timer from disk.
  Future<void> init() async {
    await _alarmService.init();
    await _liveNotificationService.init();
    await restoreFromStorage();
  }

  /// Restores timer state after an application restart or background kill.
  Future<void> restoreFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusStr = prefs.getString(_keyStatus);
      if (statusStr == null) return;

      _totalDurationSeconds = prefs.getInt(_keyTotalDuration) ?? 90;

      if (statusStr == 'running') {
        final targetMs = prefs.getInt(_keyTargetEndTime);
        if (targetMs != null) {
          _targetEndTime = DateTime.fromMillisecondsSinceEpoch(targetMs);
          final now = DateTime.now();

          if (now.isAfter(_targetEndTime!)) {
            _status = WorkoutTimerStatus.completed;
            _clearPersistedState();
          } else {
            _status = WorkoutTimerStatus.running;
            _startTicker();
          }
        }
      } else if (statusStr == 'paused') {
        _status = WorkoutTimerStatus.paused;
        _pausedRemainingSeconds =
            prefs.getInt(_keyPausedRemaining) ?? _totalDurationSeconds;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Starts or restarts the timer with a specific duration in seconds.
  Future<void> start(int durationSeconds, {String? exerciseName}) async {
    _stopTicker();
    await _alarmService.cancelAlarm();

    _totalDurationSeconds = durationSeconds > 0 ? durationSeconds : 60;
    _pausedRemainingSeconds = null;
    _targetEndTime =
        DateTime.now().add(Duration(seconds: _totalDurationSeconds));
    _status = WorkoutTimerStatus.running;

    if (exerciseName != null) {
      _liveNotificationService.setActiveExerciseName(exerciseName);
    }

    // Schedule exact audible background alarm
    await _alarmService.scheduleAlarm(
      targetEndTime: _targetEndTime!,
      title: 'زمان استراحت پایان یافت!',
      body: 'ست بعدی را با تمرکز و قدرت آغاز کنید.',
    );

    await _persistState();
    _startTicker();
    _updateLiveNotification();
    notifyListeners();
  }

  /// Pauses the running countdown without losing progress.
  Future<void> pause() async {
    if (_status != WorkoutTimerStatus.running) return;

    _pausedRemainingSeconds = remainingSeconds;
    _status = WorkoutTimerStatus.paused;
    _stopTicker();

    // Cancel pending background alarm while paused
    await _alarmService.cancelAlarm();
    await _persistState();
    _updateLiveNotification();
    notifyListeners();
  }

  /// Resumes countdown from paused state.
  Future<void> resume() async {
    if (_status != WorkoutTimerStatus.paused) return;

    final remaining = _pausedRemainingSeconds ?? _totalDurationSeconds;
    _targetEndTime = DateTime.now().add(Duration(seconds: remaining));
    _pausedRemainingSeconds = null;
    _status = WorkoutTimerStatus.running;

    // Re-schedule background alarm for newly calculated end time
    await _alarmService.scheduleAlarm(
      targetEndTime: _targetEndTime!,
      title: 'زمان استراحت پایان یافت!',
      body: 'ست بعدی را با تمرکز و قدرت آغاز کنید.',
    );

    await _persistState();
    _startTicker();
    _updateLiveNotification();
    notifyListeners();
  }

  /// Resets the timer back to its initial duration and pauses.
  Future<void> reset() async {
    _stopTicker();
    await _alarmService.cancelAlarm();

    _pausedRemainingSeconds = _totalDurationSeconds;
    _targetEndTime = null;
    _status = WorkoutTimerStatus.paused;

    await _persistState();
    _updateLiveNotification();
    notifyListeners();
  }

  /// Cancels the timer completely and returns to idle state.
  Future<void> cancel() async {
    _stopTicker();
    await _alarmService.cancelAlarm();
    await _liveNotificationService.dismiss();

    _status = WorkoutTimerStatus.idle;
    _targetEndTime = null;
    _pausedRemainingSeconds = null;

    await _clearPersistedState();
    notifyListeners();
  }

  /// Adds extra seconds (+15s, +30s) to the currently running or paused timer.
  Future<void> addSeconds(int seconds) async {
    if (_status == WorkoutTimerStatus.running && _targetEndTime != null) {
      _targetEndTime = _targetEndTime!.add(Duration(seconds: seconds));
      _totalDurationSeconds += seconds;

      await _alarmService.scheduleAlarm(
        targetEndTime: _targetEndTime!,
        title: 'زمان استراحت پایان یافت!',
        body: 'ست بعدی را با تمرکز و قدرت آغاز کنید.',
      );

      await _persistState();
      _updateLiveNotification();
      notifyListeners();
    } else if (_status == WorkoutTimerStatus.paused) {
      _pausedRemainingSeconds = (_pausedRemainingSeconds ?? 0) + seconds;
      _totalDurationSeconds += seconds;
      await _persistState();
      _updateLiveNotification();
      notifyListeners();
    }
  }

  void _startTicker() {
    _stopTicker();
    // Ticker updates UI smoothly every 500ms, using timestamp for absolute truth
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_status != WorkoutTimerStatus.running || _targetEndTime == null) {
        _stopTicker();
        return;
      }

      if (DateTime.now().isAfter(_targetEndTime!)) {
        _onCountdownCompleted();
      } else {
        _updateLiveNotification();
        notifyListeners();
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onCountdownCompleted() async {
    _stopTicker();
    _status = WorkoutTimerStatus.completed;
    _targetEndTime = null;
    _pausedRemainingSeconds = null;

    await _clearPersistedState();
    await _liveNotificationService.dismiss();

    // Trigger immediate audible and haptic alarm
    await _alarmService.triggerImmediateAlarm();

    notifyListeners();
  }

  void _updateLiveNotification() {
    _liveNotificationService.updateLiveNotification(
      status: _status,
      remainingSeconds: remainingSeconds,
      totalDurationSeconds: _totalDurationSeconds,
    );
  }

  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTotalDuration, _totalDurationSeconds);

      if (_status == WorkoutTimerStatus.running && _targetEndTime != null) {
        await prefs.setString(_keyStatus, 'running');
        await prefs.setInt(
            _keyTargetEndTime, _targetEndTime!.millisecondsSinceEpoch);
        await prefs.remove(_keyPausedRemaining);
      } else if (_status == WorkoutTimerStatus.paused) {
        await prefs.setString(_keyStatus, 'paused');
        await prefs.setInt(_keyPausedRemaining,
            _pausedRemainingSeconds ?? _totalDurationSeconds);
        await prefs.remove(_keyTargetEndTime);
      } else {
        await _clearPersistedState();
      }
    } catch (_) {}
  }

  Future<void> _clearPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStatus);
      await prefs.remove(_keyTargetEndTime);
      await prefs.remove(_keyPausedRemaining);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Screen unlocked or application brought back to foreground
      if (_status == WorkoutTimerStatus.running && _targetEndTime != null) {
        if (DateTime.now().isAfter(_targetEndTime!)) {
          _onCountdownCompleted();
        } else {
          _startTicker();
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    super.dispose();
  }
}
