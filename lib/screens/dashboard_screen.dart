import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/workout_plan.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/common/gymbro_design_system.dart';

// Modular Dashboard Widgets
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/weekly_workout_strip.dart';
import '../widgets/dashboard/today_workout_card.dart';
import '../widgets/dashboard/compact_telemetry_strip.dart';
import '../widgets/dashboard/home_workout_fallback_card.dart';
import '../widgets/dashboard/quick_tools_bar.dart';

// Re-export modular components for backward compatibility with existing tests
export '../widgets/dashboard/dashboard_header.dart';
export '../widgets/dashboard/weekly_workout_strip.dart';
export '../widgets/dashboard/today_workout_card.dart';
export '../widgets/dashboard/compact_telemetry_strip.dart';
export '../widgets/dashboard/home_workout_fallback_card.dart';
export '../widgets/dashboard/quick_tools_bar.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onOpenMealScanner;
  final VoidCallback onOpenHomeMode;
  final VoidCallback onOpenWorkouts;
  final Function(String planId) onStartWorkout;
  final VoidCallback onOpenMarketplace;
  final VoidCallback onOpenAiCoach;
  final VoidCallback? onOpenProfile;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onOpenMealScanner,
    required this.onOpenHomeMode,
    required this.onOpenWorkouts,
    required this.onStartWorkout,
    required this.onOpenMarketplace,
    required this.onOpenAiCoach,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final profile = state.userProfile;

    // Filter strictly valid gym (non-home) workout plans
    final gymPlans = state.workoutPlans.where((p) => !p.isHomeWorkout).toList();

    // Determine current day in Iranian week (0: Saturday ... 6: Friday)
    final dartWeekday = DateTime.now().weekday;
    final todayDayIndex = (dartWeekday == DateTime.saturday)
        ? 0
        : (dartWeekday == DateTime.sunday)
            ? 1
            : dartWeekday + 1;

    final bool isScheduledRestDay;
    final WorkoutPlan? todayPlan;

    if (gymPlans.isEmpty) {
      todayPlan = null;
      isScheduledRestDay = false;
    } else {
      final relevantLogs = state.workoutLogs
          .where((log) => !log.isHomeWorkout)
          .toList();

      if (relevantLogs.isNotEmpty) {
        relevantLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final lastCompletedPlanId = relevantLogs.first.planId;
        final lastPlanIndex = gymPlans.indexWhere((p) => p.id == lastCompletedPlanId);

        if (lastPlanIndex != -1) {
          final nextIndex = (lastPlanIndex + 1) % gymPlans.length;
          todayPlan = gymPlans[nextIndex];
        } else {
          todayPlan = gymPlans.first;
        }
      } else {
        final dayOffset = (todayDayIndex ~/ 2) % gymPlans.length;
        todayPlan = gymPlans[dayOffset];
      }

      // Determine if today is an actual rest day
      final todayStr = PersianUtils.toDateString(DateTime.now());
      final hasCompletedToday = state.workoutLogs.any((l) => l.date == todayStr);

      final todayWeekdayName = WeeklyWorkoutStrip.weekDays[todayDayIndex]['name']!;
      final hasAnyExplicitSchedule = gymPlans.any(
        (p) => p.exercises.any(
          (e) => WeeklyWorkoutStrip.weekDays.any((d) => e.dayNameFa.contains(d['name']!)),
        ),
      );

      if (hasCompletedToday) {
        isScheduledRestDay = true;
      } else if (hasAnyExplicitSchedule) {
        final isTodayScheduled = gymPlans.any(
          (p) => p.exercises.any((e) => e.dayNameFa.contains(todayWeekdayName)),
        );
        isScheduledRestDay = !isTodayScheduled;
      } else {
        isScheduledRestDay = false;
      }
    }

    final mediaQuery = MediaQuery.of(context);
    final double systemTopInset =
        math.max(mediaQuery.padding.top, mediaQuery.viewPadding.top);

    final double responsiveTopPadding = systemTopInset > 0
        ? (systemTopInset + AppSpacing.sm)
        : AppSpacing.base;

    final double horizontalPadding = math.max(
      AppSpacing.base,
      math.max(mediaQuery.padding.left, mediaQuery.padding.right),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: tokens.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: tokens.background,
        body: AdaptiveContainer(
          child: RefreshIndicator(
            color: tokens.lime,
            backgroundColor: tokens.cardElevated,
            edgeOffset: systemTopInset,
            onRefresh: () async {
              await state.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: responsiveTopPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Premium Header: Greeting, Date, Streak & Coins
                  DashboardHeader(
                    profile: profile,
                    tokens: tokens,
                    onOpenAiCoach: onOpenAiCoach,
                    onOpenProfile: onOpenProfile,
                  ),
                  AppSpacing.hLg,

                  // 2. Weekly Workout Calendar Strip (Dynamic Frequency)
                  WeeklyWorkoutStrip(
                    tokens: tokens,
                    selectedPlan: todayPlan,
                    state: state,
                  ),
                  AppSpacing.hLg,

                  // 3. Hero Today Workout Card (Sole Glowing Hero Card)
                  TodayWorkoutCard(
                    todayPlan: todayPlan,
                    isRestDay: isScheduledRestDay,
                    onStartWorkout: onStartWorkout,
                    onOpenWorkouts: onOpenWorkouts,
                    tokens: tokens,
                    state: state,
                  ),
                  AppSpacing.hBase,

                  // 4. Compact Telemetry Strip: Calorie & Hydration without bulky boxed cards
                  CompactTelemetryStrip(
                    state: state,
                    tokens: tokens,
                    onOpenNutrition: onOpenMealScanner,
                  ),
                  AppSpacing.hLg,

                  // 5. Signature Feature: Home Workout Fallback Banner
                  HomeWorkoutFallbackCard(
                    state: state,
                    todayPlan: todayPlan,
                    onOpenHomeMode: onOpenHomeMode,
                    tokens: tokens,
                  ),
                  AppSpacing.hLg,

                  // 6. Tactical Athletic Tools
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GymBroSectionHeader(
                        title: 'ابزارهای سریع',
                        subtitle: 'اسکنر غذا و همراه هوشمند ورزشی',
                      ),
                      AppSpacing.hSm,
                      QuickToolsBar(
                        tokens: tokens,
                        onOpenMealScanner: onOpenMealScanner,
                        onOpenHomeMode: onOpenHomeMode,
                        onOpenAiCoach: onOpenAiCoach,
                      ),
                    ],
                  ),
                  AppSpacing.hLg,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
