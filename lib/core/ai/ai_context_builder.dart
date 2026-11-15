import '../../state/app_state.dart';

class AiContextBuilder {
  /// Builds a privacy-preserving, verified system prompt for AI Coach
  /// Strips all hardcoded assumptions, fabricated supplement schedules, and unverified mock data
  static String buildSystemPrompt(AppState state) {
    final profile = state.userProfile;
    final nutrition = state.nutritionPlan;
    final plans = state.workoutPlans;
    final todayMeals = state.todayMeals;
    final logs = state.workoutLogs;

    final buffer = StringBuffer();

    buffer.writeln(
        "شما «مربی هوشمند جیم‌برو (GymBro AI Coach)» هستید؛ مشاور و مربی ورزشی، بیومکانیک و متخصص تغذیه.");
    buffer.writeln(
        "همیشه به زبان فارسی روان، محترمانه، تخصصی، انگیزه‌بخش و دلسوزانه پاسخ دهید.");
    buffer.writeln(
        "قانون اساسی: شما به عنوان هوش مصنوعی هرگز نباید ادعا کنید که برنامه تمرینی یا رژیم ورزشکار را مستقیماً در دیتابیس تغییر داده‌اید. پیشنهادات را منحصراً به عنوان توصیه تخصصی مطرح نمایید.");
    buffer.writeln();

    // 1. Verified Athlete Characteristics (Only Real Verified Data)
    final firstName = profile.firstName.trim();
    final lastName = profile.lastName.trim();
    final displayName = firstName.isNotEmpty
        ? (lastName.isNotEmpty ? '$firstName $lastName' : firstName)
        : 'ورزشکار گرامی';

    buffer.writeln("=== مشخصات تأییدشده ورزشکار ===");
    buffer.writeln("- نام: $displayName");
    buffer.writeln("- سن: ${profile.age > 0 ? '${profile.age} سال' : 'ثبت نشده'}");
    buffer.writeln("- وزن فعلی: ${profile.weightKg > 0 ? '${profile.weightKg} کیلوگرم' : 'ثبت نشده'}");
    buffer.writeln("- قد: ${profile.heightCm > 0 ? '${profile.heightCm.toInt()} سانتی‌متر' : 'ثبت نشده'}");

    if (profile.bodyFatPercentage > 0) {
      buffer.writeln("- درصد چربی بدن: ${profile.bodyFatPercentage}%");
    } else {
      buffer.writeln("- درصد چربی بدن: ثبت نشده");
    }

    if (profile.muscleMassKg > 0) {
      buffer.writeln("- حجم توده عضلانی: ${profile.muscleMassKg} کیلوگرم");
    } else {
      buffer.writeln("- حجم توده عضلانی: ثبت نشده");
    }

    if (profile.bmi > 0) {
      buffer.writeln("- شاخص توده بدنی (BMI): ${profile.bmi.toStringAsFixed(1)}");
    }

    buffer.writeln("- هدف ورزشی: ${profile.fitnessGoal.isNotEmpty ? profile.fitnessGoal : 'ثبت نشده'}");
    buffer.writeln("- سطح آمادگی: ${profile.fitnessLevel.isNotEmpty ? profile.fitnessLevel : 'ثبت نشده'}");
    buffer.writeln("- جایگاه در جیم‌برو: ${profile.level.displayNameFa}");
    buffer.writeln("- سابقه استمرار (Streak): ${profile.streakDays} روز");
    buffer.writeln("- جلسات تمرینی تکمیل‌شده: ${profile.totalWorkoutsCompleted} جلسه");
    buffer.writeln();

    // 2. Verified Nutrition Targets (No fabricated supplements or schedules)
    buffer.writeln("=== اهداف برنامه تغذیه ورزشی ===");
    buffer.writeln("- سقف کالری مجاز روزانه: ${nutrition.dailyCalories} کیلوکالری");
    buffer.writeln("- پروتئین هدف: ${nutrition.targetProteinG} گرم");
    buffer.writeln("- کربوهیدرات هدف: ${nutrition.targetCarbsG} گرم");
    buffer.writeln("- چربی هدف: ${nutrition.targetFatG} گرم");
    buffer.writeln("- آب هدف: ${nutrition.targetWaterMl} میلی‌لیتر");
    buffer.writeln();

    // 3. Today's Consumed Nutrition
    buffer.writeln("=== وضعیت تغذیه ثبت‌شده امروز ===");
    buffer.writeln("- کالری مصرف شده تا این لحظه: ${state.todayConsumedCalories} کیلوکالری");
    buffer.writeln("- پروتئین مصرف شده: ${state.todayConsumedProtein.toInt()} گرم");
    buffer.writeln("- کربوهیدرات مصرف شده: ${state.todayConsumedCarbs.toInt()} گرم");
    buffer.writeln("- چربی مصرف شده: ${state.todayConsumedFat.toInt()} گرم");
    if (state.isOverCalorieLimit) {
      buffer.writeln("- وضعیت هشدار: مصرف امروز ${state.calorieOverdraft} کالری بیش از سقف تعیین‌شده بوده است!");
    } else {
      final rem = nutrition.dailyCalories - state.todayConsumedCalories;
      buffer.writeln("- وضعیت کالری: $rem کالری تا سقف مجاز روزانه باقی‌مانده است.");
    }

    if (todayMeals.isNotEmpty) {
      buffer.writeln("- وعده‌های غذایی ثبت‌شده امروز:");
      for (var m in todayMeals) {
        buffer.writeln(
            "  * [${m.mealType}] ${m.foodName}: ${m.calories} کالری (پروتئین: ${m.proteinG.toInt()}g, کربوهیدرات: ${m.carbsG.toInt()}g, چربی: ${m.fatG.toInt()}g)");
      }
    } else {
      buffer.writeln("- هنوز هیچ وعده غذایی برای امروز ثبت نشده است.");
    }
    buffer.writeln();

    // 4. Active Workout Plans (Defensive Safe Lookup)
    buffer.writeln("=== برنامه‌های تمرینی فعال ===");
    if (plans.isNotEmpty) {
      for (var p in plans) {
        buffer.writeln(
            "- [${p.isHomeWorkout ? 'ورزش خانگی' : 'باشگاهی'}] ${p.titleFa} (${p.splitType}) - ${p.daysPerWeek} روز در هفته:");
        for (var exItem in p.exercises) {
          final exEntity = state.exercises
              .where((e) => e.id == exItem.exerciseId)
              .firstOrNull;
          final exerciseName = exEntity?.nameFa ?? exItem.exerciseId;
          final muscleGroup = exEntity != null ? ' (${exEntity.muscleGroupFa})' : '';
          buffer.writeln(
              "  * روز ${exItem.dayOfWeek} (${exItem.dayNameFa}): $exerciseName$muscleGroup | ${exItem.targetSets} ست × ${exItem.targetReps} تکرار | وزنه هدف: ${exItem.targetWeightKg.toInt()}kg | استراحت: ${exItem.restSeconds}s");
        }
      }
    } else {
      buffer.writeln("- هیچ برنامه تمرینی فعالی ثبت نشده است.");
    }
    buffer.writeln();

    // 5. Recent Training History
    buffer.writeln("=== سوابق اخیر تمرینات ===");
    if (logs.isNotEmpty) {
      for (var log in logs.take(3)) {
        buffer.writeln(
            "- تاریخ ${log.date}: ${log.planTitle} | حجم وزنه جابجا شده: ${log.totalVolumeKg.toInt()} کیلوگرم | ست‌های تکمیل شده: ${log.completedSets}");
      }
    } else {
      buffer.writeln("- سابقه تمرینی ثبت‌شده‌ای در سیستم وجود ندارد.");
    }
    buffer.writeln();
    buffer.writeln(
        "توصیه: پاسخ‌ها را منحصراً بر اساس داده‌های موثق بالا و اصول بیومکانیک و فیزیولوژی ورزشی ارائه دهید.");

    return buffer.toString();
  }
}
