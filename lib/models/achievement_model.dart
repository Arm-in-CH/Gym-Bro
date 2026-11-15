import 'package:flutter/material.dart';
import '../state/app_state.dart';

/// دسته‌بندی‌های دست‌آوردهای ورزشی جیم‌برو (الهام‌گرفته از سیستم مدال‌های قهرمانی)
enum AchievementCategory {
  streak('قهرمان استمرار (Streak Master)', Icons.local_fire_department_rounded, Color(0xFFFF6D00)),
  workouts('جنگجوی پولادین (Iron Warrior)', Icons.fitness_center_rounded, Color(0xFF7C4DFF)),
  volume('غول تناژ (Volume Titan)', Icons.line_weight_rounded, Color(0xFF00E676)),
  nutrition('انضباط تغذیه و آب (Nutrition & Hydration)', Icons.restaurant_rounded, Color(0xFF00B0FF)),
  body('تن‌سنجی و پایش بدن (Body Tracker)', Icons.accessibility_new_rounded, Color(0xFFFFD600));

  final String titleFa;
  final IconData icon;
  final Color primaryColor;

  const AchievementCategory(this.titleFa, this.icon, this.primaryColor);
}

/// مدل هر دست‌آورد ورزشی با سطوح ۱ تا ۴ و پیشرفت واقعی
class AchievementItem {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int tierLevel; // 1, 2, 3, 4
  final int targetValue;
  final int currentValue;
  final String unit;
  final int coinReward;
  final IconData badgeIcon;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tierLevel,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.coinReward,
    required this.badgeIcon,
  });

  bool get isUnlocked => currentValue >= targetValue;

  double get progressFraction =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  int get remaining =>
      (targetValue - currentValue) > 0 ? (targetValue - currentValue) : 0;

  /// محاسبه دقیق دست‌آوردهای کاربر بر اساس دیتای ذخیره‌شده واقعی در AppState
  static List<AchievementItem> computeAllAchievements(AppState state) {
    final streakDays = state.userProfile.streakDays;
    final workoutCount = state.workoutLogs.length;
    final totalVolume = state.workoutLogs.fold<double>(
      0.0,
      (sum, log) => sum + log.totalVolumeKg,
    ).toInt();
    final foodCount = state.calorieLogs.length;
    final waterTargetReached = state.selectedConsumedWaterMl >= state.nutritionPlan.targetWaterMl ? 1 : 0;
    final weightCount = state.weightRecords.length;
    final measurementCount = state.bodyMeasurements.length;

    return [
      // 1. Streak Master
      AchievementItem(
        id: 'streak_1',
        title: 'شروع استمرار',
        description: 'ثبت ۳ روز حضور و تمرین مداوم',
        category: AchievementCategory.streak,
        tierLevel: 1,
        targetValue: 3,
        currentValue: streakDays,
        unit: 'روز',
        coinReward: 10,
        badgeIcon: Icons.local_fire_department_rounded,
      ),
      AchievementItem(
        id: 'streak_2',
        title: 'استمرار فولادین',
        description: 'ثبت ۷ روز حضور و فعالیت ورزشی',
        category: AchievementCategory.streak,
        tierLevel: 2,
        targetValue: 7,
        currentValue: streakDays,
        unit: 'روز',
        coinReward: 25,
        badgeIcon: Icons.local_fire_department_rounded,
      ),
      AchievementItem(
        id: 'streak_3',
        title: 'عادت بی‌پایان',
        description: 'ثبت ۱۵ روز حضور مستمر در باشگاه',
        category: AchievementCategory.streak,
        tierLevel: 3,
        targetValue: 15,
        currentValue: streakDays,
        unit: 'روز',
        coinReward: 50,
        badgeIcon: Icons.local_fire_department_rounded,
      ),
      AchievementItem(
        id: 'streak_4',
        title: 'افسانه اراده',
        description: 'ثبت ۳۰ روز فعالیت بی‌وقفه',
        category: AchievementCategory.streak,
        tierLevel: 4,
        targetValue: 30,
        currentValue: streakDays,
        unit: 'روز',
        coinReward: 100,
        badgeIcon: Icons.local_fire_department_rounded,
      ),

      // 2. Iron Warrior (Workouts)
      AchievementItem(
        id: 'workout_1',
        title: 'گام نخست',
        description: 'تکمیل ۱ جلسه تمرین ثبت‌شده',
        category: AchievementCategory.workouts,
        tierLevel: 1,
        targetValue: 1,
        currentValue: workoutCount,
        unit: 'جلسه',
        coinReward: 10,
        badgeIcon: Icons.military_tech_rounded,
      ),
      AchievementItem(
        id: 'workout_2',
        title: 'مبارز پرتلاش',
        description: 'تکمیل ۵ جلسه تمرین ثبت‌شده',
        category: AchievementCategory.workouts,
        tierLevel: 2,
        targetValue: 5,
        currentValue: workoutCount,
        unit: 'جلسه',
        coinReward: 25,
        badgeIcon: Icons.military_tech_rounded,
      ),
      AchievementItem(
        id: 'workout_3',
        title: 'ورزشکار حرفه‌ای',
        description: 'تکمیل ۱۵ جلسه تمرین موفق',
        category: AchievementCategory.workouts,
        tierLevel: 3,
        targetValue: 15,
        currentValue: workoutCount,
        unit: 'جلسه',
        coinReward: 50,
        badgeIcon: Icons.military_tech_rounded,
      ),
      AchievementItem(
        id: 'workout_4',
        title: 'ماشین عضله‌سازی',
        description: 'تکمیل ۳۰ جلسه تمرین ثبت‌شده',
        category: AchievementCategory.workouts,
        tierLevel: 4,
        targetValue: 30,
        currentValue: workoutCount,
        unit: 'جلسه',
        coinReward: 100,
        badgeIcon: Icons.military_tech_rounded,
      ),

      // 3. Volume Titan
      AchievementItem(
        id: 'volume_1',
        title: 'هزار کیلوگرم آهن',
        description: 'ثبت ۱,۰۰۰ کیلوگرم تناژ کل جابجاشده',
        category: AchievementCategory.volume,
        tierLevel: 1,
        targetValue: 1000,
        currentValue: totalVolume,
        unit: 'kg',
        coinReward: 15,
        badgeIcon: Icons.fitness_center_rounded,
      ),
      AchievementItem(
        id: 'volume_2',
        title: '۱۰ تن بار ورزشی',
        description: 'جابجایی ۱۰,۰۰۰ کیلوگرم تناژ کل',
        category: AchievementCategory.volume,
        tierLevel: 2,
        targetValue: 10000,
        currentValue: totalVolume,
        unit: 'kg',
        coinReward: 35,
        badgeIcon: Icons.fitness_center_rounded,
      ),
      AchievementItem(
        id: 'volume_3',
        title: 'تناژ سنگین',
        description: 'ثبت ۵۰,۰۰۰ کیلوگرم تناژ ورزشی',
        category: AchievementCategory.volume,
        tierLevel: 3,
        targetValue: 50000,
        currentValue: totalVolume,
        unit: 'kg',
        coinReward: 75,
        badgeIcon: Icons.fitness_center_rounded,
      ),
      AchievementItem(
        id: 'volume_4',
        title: 'اسطوره وزنه‌ها',
        description: 'ثبت ۱۰۰,۰۰۰ کیلوگرم تناژ کل در جیم‌برو',
        category: AchievementCategory.volume,
        tierLevel: 4,
        targetValue: 100000,
        currentValue: totalVolume,
        unit: 'kg',
        coinReward: 150,
        badgeIcon: Icons.fitness_center_rounded,
      ),

      // 4. Nutrition Champion
      AchievementItem(
        id: 'nutrition_1',
        title: 'شروع پایش تغذیه',
        description: 'ثبت اولین وعده غذایی در دفترچه',
        category: AchievementCategory.nutrition,
        tierLevel: 1,
        targetValue: 1,
        currentValue: foodCount,
        unit: 'وعده',
        coinReward: 10,
        badgeIcon: Icons.restaurant_menu_rounded,
      ),
      AchievementItem(
        id: 'nutrition_2',
        title: 'دقت در رژیم',
        description: 'ثبت ۱۰ وعده غذایی در پایشگر',
        category: AchievementCategory.nutrition,
        tierLevel: 2,
        targetValue: 10,
        currentValue: foodCount,
        unit: 'وعده',
        coinReward: 25,
        badgeIcon: Icons.restaurant_menu_rounded,
      ),
      AchievementItem(
        id: 'nutrition_3',
        title: 'هیدراتاسیون کامل',
        description: 'رسیدن به هدف آب مصرفی روزانه',
        category: AchievementCategory.nutrition,
        tierLevel: 3,
        targetValue: 1,
        currentValue: waterTargetReached,
        unit: 'روز',
        coinReward: 20,
        badgeIcon: Icons.water_drop_rounded,
      ),

      // 5. Body Tracker
      AchievementItem(
        id: 'body_1',
        title: 'مبدأ تغییر بدنی',
        description: 'ثبت اولین رکورد پایش وزن',
        category: AchievementCategory.body,
        tierLevel: 1,
        targetValue: 1,
        currentValue: weightCount,
        unit: 'رکورد',
        coinReward: 10,
        badgeIcon: Icons.monitor_weight_outlined,
      ),
      AchievementItem(
        id: 'body_2',
        title: 'اسکن بیومتریک',
        description: 'ثبت اندازه‌گیری جامع سایزهای بدن',
        category: AchievementCategory.body,
        tierLevel: 2,
        targetValue: 1,
        currentValue: measurementCount,
        unit: 'سایزگیری',
        coinReward: 25,
        badgeIcon: Icons.accessibility_new_rounded,
      ),
    ];
  }
}
