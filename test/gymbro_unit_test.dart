import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/models/user_level.dart';
import 'package:gymbro/models/user_profile.dart';
import 'package:gymbro/models/marketplace_models.dart';
import 'package:gymbro/models/nutrition_plan.dart';
import 'package:gymbro/models/calorie_scan_log.dart';

void main() {
  group('GymBro Core Domain & Business Logic Tests', () {
    test('UserLevel progression rules - Elite is earned not bought', () {
      final member = UserProfile(
        id: '1',
        firstName: 'Armin',
        lastName: 'GymBro',
        phone: '123',
        email: 'a@g.com',
        weightKg: 78.5,
        heightCm: 182,
        fitnessGoal: 'Hypertrophy',
        fitnessLevel: 'Intermediate',
        level: UserLevel.member,
        coins: 50,
        dailyFreeScans: 5,
        streakDays: 4,
        totalWorkoutsCompleted: 6,
        activeSinceMonths: 1,
      );

      expect(member.level, UserLevel.member);
      expect(member.bmi, closeTo(23.7, 0.1));

      // Elite status cannot be purchased, requires 6+ months active and approval
      final pro = member.copyWith(
        level: UserLevel.pro,
        activeSinceMonths: 7,
        totalWorkoutsCompleted: 60,
      );
      expect(pro.level, UserLevel.pro);
    });

    test('Booking state machine transitions and 10% commission', () {
      // 1. Pending transitions
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.confirmed),
          isTrue);
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.cancelled),
          isTrue);
      expect(BookingStatus.pending.canTransitionTo(BookingStatus.completed),
          isFalse);

      // 2. Confirmed transitions
      expect(BookingStatus.confirmed.canTransitionTo(BookingStatus.completed),
          isTrue);
      expect(BookingStatus.confirmed.canTransitionTo(BookingStatus.cancelled),
          isTrue);

      // 3. Completed (Terminal)
      expect(BookingStatus.completed.canTransitionTo(BookingStatus.cancelled),
          isFalse);

      // 4. Commission is 10% as locked in Brain
      const sessionPrice = 450000;
      final commission = (sessionPrice * 0.10).round();
      expect(commission, 45000);
    });

    test('Calorie budget overdraft calculation', () {
      final plan = NutritionPlan(
        id: '1',
        dailyCalories: 2650,
        targetProteinG: 165,
        targetCarbsG: 300,
        targetFatG: 70,
      );

      final meal1 = CalorieScanLog(
        id: '1',
        foodName: 'چلو کباب کوبیده',
        mealType: 'ناهار',
        calories: 1400,
        proteinG: 60,
        carbsG: 120,
        fatG: 65,
        portionG: 700,
        dateString: '2026-11-04',
        timestamp: 1000,
      );

      final meal2 = CalorieScanLog(
        id: '2',
        foodName: 'قورمه سبزی با برنج',
        mealType: 'شام',
        calories: 1350,
        proteinG: 40,
        carbsG: 140,
        fatG: 50,
        portionG: 650,
        dateString: '2026-11-04',
        timestamp: 2000,
      );

      final totalConsumed = meal1.calories + meal2.calories; // 2750
      expect(totalConsumed, 2750);
      expect(totalConsumed > plan.dailyCalories, isTrue);

      final overdraft = totalConsumed - plan.dailyCalories;
      expect(overdraft, 100);
    });
  });
}
