import 'package:flutter/material.dart';
import '../core/storage/safe_cast.dart';

/// Fitness goal types with Persian localization and metadata.
enum FitnessGoal {
  muscleBuilding,
  fatLoss,
  generalFitness,
  strengthImprovement,
  weightMaintenance;

  String get displayNameFa {
    switch (this) {
      case FitnessGoal.muscleBuilding:
        return 'عضله‌سازی و هایپرتروفی';
      case FitnessGoal.fatLoss:
        return 'چربی‌سوزی و کاهش وزن';
      case FitnessGoal.generalFitness:
        return 'تناسب اندام و سلامت عمومی';
      case FitnessGoal.strengthImprovement:
        return 'افزایش قدرت و توان انفجاری';
      case FitnessGoal.weightMaintenance:
        return 'تثبیت وزن و فرم‌دهی بدن';
    }
  }

  String get descriptionFa {
    switch (this) {
      case FitnessGoal.muscleBuilding:
        return 'افزایش توده بدون چربی عضلانی با تمرینات مقاومتی و کالری مازاد کنترل‌شده';
      case FitnessGoal.fatLoss:
        return 'کاهش درصد چربی بدن با حفظ بافت عضلانی از طریق کسری کالری هوشمند';
      case FitnessGoal.generalFitness:
        return 'ارتقای استقامت قلبی‌عروقی، انعطاف‌پذیری و شادابی فیزیکی پایدار';
      case FitnessGoal.strengthImprovement:
        return 'بهبود رکوردهای وزنه در حرکات پایه (اسکات، ددلیفت و پرس سینه)';
      case FitnessGoal.weightMaintenance:
        return 'حفظ وزن فعلی و بازآرایی ترکیب بدنی (Body Recomposition)';
    }
  }

  static FitnessGoal fromString(String? val) {
    if (val == null) return FitnessGoal.muscleBuilding;
    final lower = val.toLowerCase();
    if (lower.contains('fat') || lower.contains('چربی') || lower.contains('کاهش')) {
      return FitnessGoal.fatLoss;
    }
    if (lower.contains('strength') || lower.contains('قدرت') || lower.contains('توان')) {
      return FitnessGoal.strengthImprovement;
    }
    if (lower.contains('maintain') || lower.contains('تثبیت') || lower.contains('recomp')) {
      return FitnessGoal.weightMaintenance;
    }
    if (lower.contains('fitness') || lower.contains('سلامت') || lower.contains('عمومی')) {
      return FitnessGoal.generalFitness;
    }
    return FitnessGoal.muscleBuilding;
  }
}

/// Physical activity level of the user throughout the day.
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive;

  String get displayNameFa {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'کم‌تحرک (پشت‌میزنشین و اداری)';
      case ActivityLevel.lightlyActive:
        return 'فعالیت سبک (۱ الی ۲ روز ورزش در هفته)';
      case ActivityLevel.moderatelyActive:
        return 'فعالیت متوسط (۳ الی ۴ روز ورزش در هفته)';
      case ActivityLevel.veryActive:
        return 'بسیار فعال (۵ الی ۶ روز ورزش پرفشار)';
      case ActivityLevel.extraActive:
        return 'ورزشکار حرفه‌ای / فعالیت سنگین روزانه';
    }
  }

  double get tdeeMultiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  static ActivityLevel fromString(String? val) {
    if (val == null) return ActivityLevel.moderatelyActive;
    final lower = val.toLowerCase();
    if (lower.contains('sedentary') || lower.contains('کم‌تحرک')) return ActivityLevel.sedentary;
    if (lower.contains('light') || lower.contains('سبک')) return ActivityLevel.lightlyActive;
    if (lower.contains('very') || lower.contains('بسیار')) return ActivityLevel.veryActive;
    if (lower.contains('extra') || lower.contains('سنگین') || lower.contains('حرفه‌ای')) return ActivityLevel.extraActive;
    return ActivityLevel.moderatelyActive;
  }
}

/// Voluntary gender indicator.
enum Gender {
  male,
  female,
  preferNotToSay;

  String get displayNameFa {
    switch (this) {
      case Gender.male:
        return 'آقا';
      case Gender.female:
        return 'خانم';
      case Gender.preferNotToSay:
        return 'ترجیح می‌دهم اعلام نکنم';
    }
  }

  static Gender fromString(String? val) {
    if (val == null) return Gender.preferNotToSay;
    final lower = val.toLowerCase();
    if (lower.contains('male') || lower.contains('مرد') || lower.contains('آقا')) return Gender.male;
    if (lower.contains('female') || lower.contains('زن') || lower.contains('خانم')) return Gender.female;
    return Gender.preferNotToSay;
  }
}

/// Clinical WHO Body Mass Index classification categories.
enum BmiCategory {
  underweight,
  normal,
  overweight,
  obeseClass1,
  obeseClass2;

  String get displayNameFa {
    switch (this) {
      case BmiCategory.underweight:
        return 'کمبود وزن (Underweight)';
      case BmiCategory.normal:
        return 'وزن طبیعی و ایده‌آل (Normal)';
      case BmiCategory.overweight:
        return 'اضافه‌وزن (Overweight)';
      case BmiCategory.obeseClass1:
        return 'چاقی درجه ۱ (Obese Class I)';
      case BmiCategory.obeseClass2:
        return 'چاقی درجه ۲ و بالاتر (Severe)';
    }
  }

  Color get color {
    switch (this) {
      case BmiCategory.underweight:
        return const Color(0xFF38BDF8); // Cyan
      case BmiCategory.normal:
        return const Color(0xFFC9F36A); // Lime
      case BmiCategory.overweight:
        return const Color(0xFFFBBF24); // Amber
      case BmiCategory.obeseClass1:
        return const Color(0xFFF97316); // Orange
      case BmiCategory.obeseClass2:
        return const Color(0xFFEF4444); // Red
    }
  }

  String get clinicalNoteFa {
    switch (this) {
      case BmiCategory.underweight:
        return 'شاخص کمتر از ۱۸.۵ است. برای حفظ سلامت ایمنی و استخوان‌ها، دریافت کالری مازاد سالم و عضله‌سازی توصیه می‌شود.';
      case BmiCategory.normal:
        return 'شاخص بین ۱۸.۵ تا ۲۴.۹ و در محدوده سلامت استاندارد جهانی قرار دارد.';
      case BmiCategory.overweight:
        return 'شاخص بین ۲۵.۰ تا ۲۹.۹ است. توجه: در ورزشکاران با توده عضلانی بالا، این عدد لزوماً به معنای چربی اضافه نیست.';
      case BmiCategory.obeseClass1:
        return 'شاخص بین ۳۰.۰ تا ۳۴.۹ است. تمرکز بر تمرینات هوازی و کسری کالری تدریجی توصیه می‌شود.';
      case BmiCategory.obeseClass2:
        return 'شاخص بالاتر از ۳۵.۰ است. پایش مستمر سلامت و تنظیم برنامه تحت نظر متخصص پیشنهاد می‌گردد.';
    }
  }

  static BmiCategory fromBmi(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    if (bmi < 35.0) return BmiCategory.obeseClass1;
    return BmiCategory.obeseClass2;
  }
}

/// Individual recorded weight measurement with timestamp and optional notes.
class WeightRecord {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? note;

  const WeightRecord({
    required this.id,
    required this.date,
    required this.weightKg,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'note': note,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: SafeCast.toStringVal(
        json['id'],
        'w_${DateTime.now().millisecondsSinceEpoch}',
      ),
      date: DateTime.tryParse(SafeCast.toStringVal(json['date'])) ??
          DateTime.now(),
      weightKg: SafeCast.toDouble(json['weightKg'], 70.0),
      note: SafeCast.toStringOrNull(json['note']),
    );
  }

  WeightRecord copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? note,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
    );
  }
}

/// Comprehensive body circumferences and anthropometric measurements.
class BodyMeasurementRecord {
  final String id;
  final DateTime date;
  final double? chestCm;
  final double? waistCm;
  final double? hipCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? thighCm;
  final double? calfCm;
  final double? bodyFatPercentage;
  final String? note;

  const BodyMeasurementRecord({
    required this.id,
    required this.date,
    this.chestCm,
    this.waistCm,
    this.hipCm,
    this.leftArmCm,
    this.rightArmCm,
    this.thighCm,
    this.calfCm,
    this.bodyFatPercentage,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'chestCm': chestCm,
      'waistCm': waistCm,
      'hipCm': hipCm,
      'leftArmCm': leftArmCm,
      'rightArmCm': rightArmCm,
      'thighCm': thighCm,
      'calfCm': calfCm,
      'bodyFatPercentage': bodyFatPercentage,
      'note': note,
    };
  }

  factory BodyMeasurementRecord.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementRecord(
      id: SafeCast.toStringVal(
        json['id'],
        'bm_${DateTime.now().millisecondsSinceEpoch}',
      ),
      date: DateTime.tryParse(SafeCast.toStringVal(json['date'])) ??
          DateTime.now(),
      chestCm: SafeCast.toDoubleOrNull(json['chestCm']),
      waistCm: SafeCast.toDoubleOrNull(json['waistCm']),
      hipCm: SafeCast.toDoubleOrNull(json['hipCm']),
      leftArmCm: SafeCast.toDoubleOrNull(json['leftArmCm']),
      rightArmCm: SafeCast.toDoubleOrNull(json['rightArmCm']),
      thighCm: SafeCast.toDoubleOrNull(json['thighCm']),
      calfCm: SafeCast.toDoubleOrNull(json['calfCm']),
      bodyFatPercentage: SafeCast.toDoubleOrNull(json['bodyFatPercentage']),
      note: SafeCast.toStringOrNull(json['note']),
    );
  }

  BodyMeasurementRecord copyWith({
    String? id,
    DateTime? date,
    double? chestCm,
    double? waistCm,
    double? hipCm,
    double? leftArmCm,
    double? rightArmCm,
    double? thighCm,
    double? calfCm,
    double? bodyFatPercentage,
    String? note,
  }) {
    return BodyMeasurementRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      hipCm: hipCm ?? this.hipCm,
      leftArmCm: leftArmCm ?? this.leftArmCm,
      rightArmCm: rightArmCm ?? this.rightArmCm,
      thighCm: thighCm ?? this.thighCm,
      calfCm: calfCm ?? this.calfCm,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      note: note ?? this.note,
    );
  }
}
