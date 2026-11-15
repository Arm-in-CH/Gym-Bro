import '../core/storage/safe_cast.dart';

class CalorieScanLog {
  final String id;
  final String foodName;
  final String mealType; // صبحانه, ناهار, شام, میان‌وعده
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double portionG;
  final bool isAiScanned;
  final String dateString;
  final int timestamp;
  final String? note;

  CalorieScanLog({
    required this.id,
    required this.foodName,
    required this.mealType,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.portionG,
    this.isAiScanned = true,
    required this.dateString,
    required this.timestamp,
    this.note,
  });

  CalorieScanLog copyWith({
    String? id,
    String? foodName,
    String? mealType,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? portionG,
    bool? isAiScanned,
    String? dateString,
    int? timestamp,
    String? note,
  }) {
    return CalorieScanLog(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      portionG: portionG ?? this.portionG,
      isAiScanned: isAiScanned ?? this.isAiScanned,
      dateString: dateString ?? this.dateString,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodName': foodName,
        'mealType': mealType,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'portionG': portionG,
        'isAiScanned': isAiScanned,
        'dateString': dateString,
        'timestamp': timestamp,
        if (note != null) 'note': note,
      };

  factory CalorieScanLog.fromJson(Map<String, dynamic> json) => CalorieScanLog(
        id: SafeCast.toStringVal(json['id']),
        foodName: SafeCast.toStringVal(json['foodName']),
        mealType: SafeCast.toStringVal(json['mealType'], 'ناهار'),
        calories: SafeCast.toInt(json['calories'], 0),
        proteinG: SafeCast.toDouble(json['proteinG'], 0.0),
        carbsG: SafeCast.toDouble(json['carbsG'], 0.0),
        fatG: SafeCast.toDouble(json['fatG'], 0.0),
        portionG: SafeCast.toDouble(json['portionG'], 100.0),
        isAiScanned: SafeCast.toBool(json['isAiScanned']),
        dateString: SafeCast.toStringVal(json['dateString']),
        timestamp: SafeCast.toInt(
          json['timestamp'],
          DateTime.now().millisecondsSinceEpoch,
        ),
        note: SafeCast.toStringOrNull(json['note']),
      );
}
