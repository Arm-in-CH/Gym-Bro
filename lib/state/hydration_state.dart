import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/repository/hydration_repository.dart';
import '../models/nutrition_models.dart';

class HydrationState extends ChangeNotifier {
  final IHydrationRepository repository;
  final int Function()? getTargetWaterMl;

  List<WaterLog> waterLogs = [];

  HydrationState({
    required this.repository,
    this.getTargetWaterMl,
    List<WaterLog>? initialWaterLogs,
  }) {
    if (initialWaterLogs != null) waterLogs = initialWaterLogs;
  }

  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadFromRepository() async {
    waterLogs = await repository.getWaterLogs();
    notifyListeners();
  }

  int get todayConsumedWaterMl => waterLogs
      .where((log) => log.dateString == todayDateString)
      .fold(0, (sum, log) => sum + log.amountMl);

  List<WaterLog> getWaterLogsForDate(String dateString) =>
      waterLogs.where((w) => w.dateString == dateString).toList();

  int getConsumedWaterMlForDate(String dateString) =>
      getWaterLogsForDate(dateString).fold(0, (sum, w) => sum + w.amountMl);

  int getRemainingWaterMlForDate(String dateString, [int? targetMl]) {
    final target = targetMl ?? getTargetWaterMl?.call() ?? 3000;
    final consumed = getConsumedWaterMlForDate(dateString);
    return (target - consumed) > 0 ? (target - consumed) : 0;
  }

  Future<void> logWater(int amountMl, {required String dateString}) async {
    final log = WaterLog(
      id: 'water_${DateTime.now().millisecondsSinceEpoch}',
      dateString: dateString,
      amountMl: amountMl,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await repository.saveWaterLog(log);
    waterLogs = await repository.getWaterLogs();
    notifyListeners();
  }

  Future<void> undoWater(int amountMl, {required String dateString}) async {
    final dayLogs = waterLogs.where((w) => w.dateString == dateString).toList();
    if (dayLogs.isNotEmpty) {
      final lastLog = dayLogs.first;
      if (lastLog.amountMl <= amountMl) {
        await repository.deleteWaterLog(lastLog.id);
      } else {
        final updated = lastLog.copyWith(amountMl: lastLog.amountMl - amountMl);
        final all = await repository.getWaterLogs();
        final idx = all.indexWhere((w) => w.id == lastLog.id);
        if (idx != -1) all[idx] = updated;
        await repository.saveWaterLogs(all);
      }
      waterLogs = await repository.getWaterLogs();
      notifyListeners();
    }
  }
}
