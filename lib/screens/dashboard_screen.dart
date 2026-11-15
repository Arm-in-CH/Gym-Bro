import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/workout_plan.dart';
import '../models/user_profile.dart';
import '../models/user_level.dart';
import '../widgets/level_badge.dart';
import '../widgets/calorie_budget_card.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/common/gymbro_design_system.dart';
import 'focused_training_screen.dart';

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
      // Safe empty state: no valid gym plan exists
      todayPlan = null;
      isScheduledRestDay = false;
    } else {
      // Determine next workout plan in rotation based on most recently completed gym workout log
      final relevantLogs = state.workoutLogs
          .where((log) => !log.isHomeWorkout)
          .toList();

      if (relevantLogs.isNotEmpty) {
        // Sort by timestamp descending to find the last completed gym plan
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
        // If no prior logs, map day of week to rotation index
        final dayOffset = (todayDayIndex ~/ 2) % gymPlans.length;
        todayPlan = gymPlans[dayOffset];
      }

      // Determine if today is an actual rest day:
      // 1. If today's workout has already been completed and logged in history
      final todayStr = PersianUtils.toDateString(DateTime.now());
      final hasCompletedToday = state.workoutLogs.any((l) => l.date == todayStr);

      // 2. If the plan has explicit weekday scheduling, check if today is scheduled
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
        // Never fabricate a rest day schedule if no explicit schedule exists
        isScheduledRestDay = false;
      }
    }

    final mediaQuery = MediaQuery.of(context);
    // Dynamic Island / camera cutout / notch / status bar hardware safe inset
    final double systemTopInset =
        math.max(mediaQuery.padding.top, mediaQuery.viewPadding.top);

    // Responsive top spacing for Landing header:
    // When a notch, Dynamic Island, or status bar is present (systemTopInset > 0),
    // add an intentional 8dp athletic margin (AppSpacing.sm) below it so UI elements
    // never sit underneath or dangerously close to the camera cutout.
    // When on a device without a camera cutout (systemTopInset == 0),
    // supply standard screen padding (AppSpacing.base = 16dp).
    final double responsiveTopPadding = systemTopInset > 0
        ? (systemTopInset + AppSpacing.sm)
        : AppSpacing.base;

    // Horizontal safe area padding (e.g. landscape notch / foldable crease)
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

                  // 2. Weekly Workout Calendar Strip
                  WeeklyWorkoutStrip(
                    tokens: tokens,
                    selectedPlan: todayPlan,
                    state: state,
                  ),
                  AppSpacing.hLg,

                  // 3. Hero Today Workout Card (Live Draft Detection & High-Impact CTA)
                  TodayWorkoutCard(
                    todayPlan: todayPlan,
                    isRestDay: isScheduledRestDay,
                    onStartWorkout: onStartWorkout,
                    onOpenWorkouts: onOpenWorkouts,
                    tokens: tokens,
                    state: state,
                  ),
                  AppSpacing.hBase,

                  // 4. Daily Progress: Calories & Nutrition Budget
                  CalorieBudgetCard(
                    consumedCalories: state.todayConsumedCalories,
                    targetCalories: state.nutritionPlan.dailyCalories,
                    consumedProtein: state.todayConsumedProtein,
                    targetProtein: state.nutritionPlan.targetProteinG,
                    consumedCarbs: state.todayConsumedCarbs,
                    targetCarbs: state.nutritionPlan.targetCarbsG,
                    consumedFat: state.todayConsumedFat,
                    targetFat: state.nutritionPlan.targetFatG,
                    isOverLimit: state.isOverCalorieLimit,
                    overdraftCalories: state.calorieOverdraft,
                  ),
                  AppSpacing.hBase,

                  // 5. Daily Progress: Hydration Tracker
                  _DailyHydrationCard(state: state, tokens: tokens),
                  AppSpacing.hLg,

                  // 6. Signature Feature: Home Workout Fallback Banner
                  HomeWorkoutFallbackCard(
                    state: state,
                    todayPlan: todayPlan,
                    onOpenHomeMode: onOpenHomeMode,
                    tokens: tokens,
                  ),
                  AppSpacing.hLg,

                  // 7. Tactical Athletic Tools
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GymBroSectionHeader(
                        title: 'ابزارهای سریع',
                        subtitle: 'اسکنر غذا و همراه هوشمند ورزشی',
                      ),
                      AppSpacing.hSm,
                      _QuickToolsBar(
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

// ============================================================================
// 1. DASHBOARD HEADER WIDGET
// ============================================================================

class DashboardHeader extends StatelessWidget {
  final UserProfile? profile;
  final AppThemeExtension tokens;
  final VoidCallback onOpenAiCoach;
  final VoidCallback? onOpenProfile;

  const DashboardHeader({
    super.key,
    required this.profile,
    required this.tokens,
    required this.onOpenAiCoach,
    this.onOpenProfile,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صبح بخیر';
    } else if (hour >= 12 && hour < 17) {
      return 'ظهر بخیر';
    } else if (hour >= 17 && hour < 21) {
      return 'عصر بخیر';
    } else {
      return 'شب بخیر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final persianDate = PersianUtils.formatPersianDate(now);

    final avatarWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenProfile,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tokens.lime.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: tokens.lime.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/app_logo_small.png',
            semanticLabel: 'لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری',
            width: 48,
            height: 48,
            cacheWidth: 96,
            cacheHeight: 96,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ExcludeSemantics(
              child: Container(
                color: tokens.cardElevated,
                child: const GymBroBrandLogo(
                  size: 48,
                  withGlow: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final String firstName = profile?.firstName ?? '';
    final String greetingTitle = firstName.trim().isNotEmpty
        ? '$greeting، $firstName عزیز'
        : '$greeting، ورزشکار عزیز';
    final int streakDays = profile?.streakDays ?? 0;
    final int coins = profile?.coins ?? 0;
    final UserLevel level = profile?.level ?? UserLevel.athlete;

    final streakPill = Semantics(
      label: 'روزهای استمرار',
      value: '${PersianUtils.toPersianDigits(streakDays)} روز',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔥 استمرار شما: ${PersianUtils.toPersianDigits(streakDays)} روز متوالی بدون وقفه!',
              ),
              backgroundColor: tokens.cardElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.cardElevated,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: tokens.lime.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 16, color: Color(0xFFFF5722)),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${PersianUtils.toPersianDigits(streakDays)} روز',
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final coinsPill = Semantics(
      label: 'اعتبار نمایشی',
      value: '${PersianUtils.toPersianDigits(coins)} سکه نمونه',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'موجودی نمایشی: ${PersianUtils.toPersianDigits(coins)} سکه. خرید و جایزه در این نسخه فعال نیست.',
              ),
              backgroundColor: tokens.cardElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.cardElevated,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: tokens.gold.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GymBroIcon(
                icon: GymBroDashboardIconType.personalRecord,
                size: 15,
                active: true,
                activeColor: tokens.gold,
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${PersianUtils.toPersianDigits(coins)} سکه',
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final userProfileSection = Row(
          children: [
            avatarWidget,
            AppSpacing.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greetingTitle,
                    style: AppTypography.sectionTitle(context),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      LevelBadge(level: level),
                      Text(
                        'امروز $persianDate',
                        style: AppTypography.caption(context).copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              userProfileSection,
              AppSpacing.hSm,
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 4,
                children: [
                  streakPill,
                  coinsPill,
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: userProfileSection),
            AppSpacing.wSm,
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                streakPill,
                coinsPill,
              ],
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// 2. WEEKLY WORKOUT CALENDAR STRIP
// ============================================================================

class WeeklyWorkoutStrip extends StatefulWidget {
  final AppThemeExtension tokens;
  final WorkoutPlan? selectedPlan;
  final AppState state;
  final DateTime? currentDate;

  const WeeklyWorkoutStrip({
    super.key,
    required this.tokens,
    required this.selectedPlan,
    required this.state,
    this.currentDate,
  });

  static const List<Map<String, String>> weekDays = [
    {'name': 'شنبه', 'short': 'ش'},
    {'name': '۱شنبه', 'short': 'ی'},
    {'name': '۲شنبه', 'short': 'د'},
    {'name': '۳شنبه', 'short': 'س'},
    {'name': '۴شنبه', 'short': 'چ'},
    {'name': '۵شنبه', 'short': 'پ'},
    {'name': 'جمعه', 'short': 'ج'},
  ];

  @override
  State<WeeklyWorkoutStrip> createState() => _WeeklyWorkoutStripState();
}

class _WeeklyWorkoutStripState extends State<WeeklyWorkoutStrip> {
  // 0: شنبه, 1: یکشنبه, 2: دوشنبه, 3: سه‌شنبه, 4: چهارشنبه, 5: پنج‌شنبه, 6: جمعه
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    final now = widget.currentDate ?? DateTime.now();
    // Dart: Mon=1 ... Sat=6, Sun=7. Persian week: Sat=0 ... Fri=6
    _selectedDayIndex = (now.weekday + 1) % 7;
  }

  @override
  void didUpdateWidget(covariant WeeklyWorkoutStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDate != oldWidget.currentDate) {
      final now = widget.currentDate ?? DateTime.now();
      _selectedDayIndex = (now.weekday + 1) % 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final now = widget.currentDate ?? DateTime.now();

    // Map to Persian week anchor (Saturday is index 0)
    final todayWeekIndex = (now.weekday + 1) % 7;
    // Derive Saturday of this week handling month transitions cleanly
    final saturdayOfThisWeek = DateTime(now.year, now.month, now.day - todayWeekIndex);

    final frequencyBadgeLabel = widget.selectedPlan != null
        ? '${PersianUtils.toPersianDigits(widget.selectedPlan!.daysPerWeek)} جلسه در هفته'
        : 'بدون برنامه';

    // Pre-compute O(1) set of logged workout date strings to avoid redundant O(7 * N) scans
    final loggedDateSet = widget.state.workoutLogs.map((log) => log.date).toSet();
    final planExercises = widget.selectedPlan?.exercises ?? const [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.6),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 16, color: tokens.lime),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'تقویم هفتگی تمرینات',
                          style: AppTypography.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.15),
                  borderRadius: AppRadii.roundedXs,
                ),
                child: Text(
                  frequencyBadgeLabel,
                  style: AppTypography.caption(context).copyWith(
                    color: tokens.lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayInfo = WeeklyWorkoutStrip.weekDays[index];
              // Robust month transition and week boundaries date calculation
              final dayDate = DateTime(
                saturdayOfThisWeek.year,
                saturdayOfThisWeek.month,
                saturdayOfThisWeek.day + index,
              );
              final isToday = dayDate.year == now.year &&
                  dayDate.month == now.month &&
                  dayDate.day == now.day;
              final isSelected = index == _selectedDayIndex;
              final dayNumber = PersianUtils.toPersianDigits(dayDate.day);

              // 1. Inspect actual workout history for this date via O(1) set lookup
              final dayDateString = PersianUtils.toDateString(dayDate);
              final hasLoggedWorkout = loggedDateSet.contains(dayDateString);

              // 2. Inspect actual scheduled-day information from plan exercises if present
              final hasExplicitSchedule = planExercises.any(
                (e) => e.dayNameFa.contains(dayInfo['name']!),
              );

              // Do not invent a schedule: only mark if actual log or explicit schedule exists
              final isWorkoutDay = hasLoggedWorkout || hasExplicitSchedule;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _selectedDayIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      curve: AppCurves.standard,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isToday
                            ? tokens.lime
                            : tokens.cardBackground.withOpacity(0.9),
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color: isToday
                              ? tokens.lime
                              : (isSelected
                                  ? tokens.lime.withOpacity(0.6)
                                  : tokens.borderColor.withOpacity(0.4)),
                          width: (isToday || isSelected) ? 1.5 : 1,
                        ),
                        boxShadow: isToday ? AppShadows.limeGlow() : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              dayInfo['short']!,
                              style: AppTypography.caption(context).copyWith(
                                color: isToday
                                    ? tokens.textOnLime
                                    : tokens.textMuted,
                                fontWeight: isToday
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              dayNumber,
                              style: AppTypography.bodySmall(context).copyWith(
                                color: isToday
                                    ? tokens.textOnLime
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Training day indicator dot: neutral/transparent unless confirmed by history/schedule
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isWorkoutDay
                                  ? (isToday ? tokens.textOnLime : tokens.lime)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. HERO TODAY WORKOUT CARD
// ============================================================================

class TodayWorkoutCard extends StatelessWidget {
  final WorkoutPlan? todayPlan;
  final bool isRestDay;
  final Function(String planId) onStartWorkout;
  final VoidCallback onOpenWorkouts;
  final AppThemeExtension tokens;
  final AppState state;

  const TodayWorkoutCard({
    super.key,
    required this.todayPlan,
    this.isRestDay = false,
    required this.onStartWorkout,
    required this.onOpenWorkouts,
    required this.tokens,
    required this.state,
  });

  /// Derives workout duration:
  /// 1. Uses real stored duration from workout history if available.
  /// 2. Transparently derives estimate from targetSets, targetReps, and restSeconds.
  /// 3. Returns null if insufficient information exists (no fabrication).
  static String? getWorkoutDurationLabel({
    required WorkoutPlan? plan,
    required AppState state,
  }) {
    if (plan == null) return null;

    // 1. Real stored duration from actual workout history for this plan
    final planLogs = state.workoutLogs
        .where((log) => log.planId == plan.id && log.durationMinutes > 0)
        .toList();
    if (planLogs.isNotEmpty) {
      planLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final realDuration = planLogs.first.durationMinutes;
      return '${PersianUtils.toPersianDigits(realDuration)} دقیقه';
    }

    // 2. Derive a transparent estimate only when sufficient information exists
    if (plan.exercises.isNotEmpty) {
      int totalEstimatedSeconds = 0;
      for (final ex in plan.exercises) {
        if (ex.targetSets > 0) {
          final repTimeSeconds = (ex.targetReps > 0 ? ex.targetReps : 10) * 3;
          final restTimeSeconds = ex.restSeconds > 0 ? ex.restSeconds : 60;
          final setSeconds = repTimeSeconds + restTimeSeconds;
          totalEstimatedSeconds += ex.targetSets * setSeconds;
        }
      }

      final estimatedMinutes = (totalEstimatedSeconds / 60).round();
      if (estimatedMinutes > 0) {
        return 'تخمین ${PersianUtils.toPersianDigits(estimatedMinutes)} دقیقه';
      }
    }

    // 3. No reliable value exists -> omit or return null
    return null;
  }

  /// Derives calorie burn:
  /// - Only returns a value if a validated calculation exists.
  /// - Never invents fixed calorie burn values.
  /// - Returns null when reliable data is unavailable so the badge is omitted.
  static String? getValidatedCalories({
    required WorkoutPlan? plan,
    required AppState state,
  }) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Empty state: displayed when user has no valid gym workout plan
    if (todayPlan == null) {
      return GymBroCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderColor: tokens.borderColor.withOpacity(0.6),
        gradient: LinearGradient(
          colors: [
            tokens.cardBackground,
            tokens.cardElevated.withOpacity(0.95),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GymBroIcon(
                      icon: GymBroDashboardIconType.workout,
                      size: 18,
                      active: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'برنامه تمرینی باشگاه',
                      style: AppTypography.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AppRadii.roundedXs,
                    border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
                  ),
                  child: Text(
                    'بدون برنامه',
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              'هنوز برنامه تمرینی باشگاهی ثبت نکرده‌اید',
              style: AppTypography.pageTitle(context).copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Explanation
            Text(
              'برای شروع تمرینات تخصصی در باشگاه و ثبت ست‌ها و رکوردها، لطفاً یک برنامه تمرینی اختصاصی بسازید یا از برنامه‌های آماده استفاده نمایید.',
              style: AppTypography.bodySmall(context).copyWith(
                color: tokens.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Functional CTA to open workout plans section
            GymBroPrimaryButton(
              text: 'طراحی و انتخاب برنامه تمرینی',
              prefixIcon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: onOpenWorkouts,
            ),
          ],
        ),
      );
    }

    final plan = todayPlan!;
    final activeDraft = state.getActiveWorkoutDraft(plan.id);
    final hasActiveDraft = activeDraft != null;

    final durationLabel = getWorkoutDurationLabel(plan: plan, state: state);
    final caloriesLabel = getValidatedCalories(plan: plan, state: state);

    return GymBroCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: hasActiveDraft
          ? tokens.lime
          : tokens.lime.withOpacity(0.35),
      gradient: LinearGradient(
        colors: [
          tokens.cardBackground,
          tokens.cardElevated.withOpacity(0.95),
        ],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag & Difficulty / Draft Badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GymBroIcon(
                    icon: GymBroDashboardIconType.workout,
                    size: 18,
                    active: true,
                    activeColor: tokens.lime,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isRestDay ? 'امروز: روز استراحت و ریکاوری' : 'برنامه تمرینی امروز',
                        style: AppTypography.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: isRestDay ? tokens.cyan : tokens.lime,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isRestDay)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.cyan.withOpacity(0.15),
                    borderRadius: AppRadii.roundedXs,
                    border: Border.all(color: tokens.cyan.withOpacity(0.4)),
                  ),
                  child: Text(
                    'روز ریکاوری',
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (hasActiveDraft)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.lime.withOpacity(0.2),
                    borderRadius: AppRadii.roundedXs,
                    border: Border.all(color: tokens.lime.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.lime,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'جلسه فعال',
                        style: AppTypography.caption(context).copyWith(
                          color: tokens.lime,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AppRadii.roundedXs,
                    border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
                  ),
                  child: Text(
                    plan.difficulty,
                    style: AppTypography.caption(context).copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Workout Title
          Text(
            plan.titleFa,
            style: AppTypography.pageTitle(context).copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // Split & Frequency subtitle
          Text(
            'اسپلیت: ${plan.splitType} • ${PersianUtils.toPersianDigits(plan.daysPerWeek)} روز در هفته',
            style: AppTypography.bodySmall(context).copyWith(
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Metric Badges Strip (Duration, Burn, Exercises count)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (durationLabel != null)
                HeroMetricBadge(
                  icon: Icons.timer_outlined,
                  label: durationLabel,
                  tokens: tokens,
                ),
              if (caloriesLabel != null)
                HeroMetricBadge(
                  icon: Icons.local_fire_department_outlined,
                  label: caloriesLabel,
                  tokens: tokens,
                ),
              HeroMetricBadge(
                icon: Icons.fitness_center_outlined,
                label: '${PersianUtils.toPersianDigits(plan.exercises.length)} حرکت',
                tokens: tokens,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary CTA Button: شروع تمرین / ادامه تمرین زنده
          GymBroPrimaryButton(
            text: hasActiveDraft
                ? 'ادامه تمرین در حال اجرا'
                : 'رفتن به تمرین (ورود به جلسه زنده)',
            prefixIcon: GymBroIcon(
              icon: GymBroDashboardIconType.workout,
              size: 20,
              active: true,
              activeColor: tokens.textOnLime,
            ),
            onPressed: () => onStartWorkout(plan.id),
          ),
          const SizedBox(height: 10),

          // Secondary CTA: Focus Mode
          SizedBox(
            width: double.infinity,
            child: GymBroOutlineButton(
              text: 'ورود به تمرین متمرکز (Focus Mode)',
              icon: GymBroIcon(
                icon: GymBroDashboardIconType.focusedTraining,
                size: 18,
                active: true,
                activeColor: tokens.cyan,
              ),
              textColor: tokens.cyan,
              borderColor: tokens.cyan.withOpacity(0.5),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FocusedTrainingScreen(
                      planId: plan.id,
                      state: state,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HeroMetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeExtension tokens;

  const HeroMetricBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: tokens.cardElevated.withOpacity(0.8),
          borderRadius: AppRadii.roundedSm,
          border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 14, color: tokens.textMuted),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. SIGNATURE FEATURE: HOME WORKOUT FALLBACK BANNER
// ============================================================================

class HomeWorkoutFallbackCard extends StatefulWidget {
  final AppState state;
  final WorkoutPlan? todayPlan;
  final WorkoutPlan? currentPlan; // Backward-compatibility alias
  final VoidCallback onOpenHomeMode;
  final AppThemeExtension tokens;

  const HomeWorkoutFallbackCard({
    super.key,
    required this.state,
    this.todayPlan,
    this.currentPlan,
    required this.onOpenHomeMode,
    required this.tokens,
  });

  @override
  State<HomeWorkoutFallbackCard> createState() => _HomeWorkoutFallbackCardState();
}

class _HomeWorkoutFallbackCardState extends State<HomeWorkoutFallbackCard> {
  bool _isConvertingLocally = false;

  Future<void> _handleConversion(BuildContext context, WorkoutPlan sourcePlan) async {
    if (_isConvertingLocally || widget.state.isConvertingHome) return;

    setState(() => _isConvertingLocally = true);

    try {
      final homePlan = await widget.state.convertGymPlanToHomePlan(sourcePlan.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('برنامه «${homePlan.titleFa}» با موفقیت ایجاد شد!'),
            backgroundColor: widget.tokens.lime,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تبدیل برنامه به تمرین خانگی: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConvertingLocally = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = widget.tokens;
    final effectivePlan = widget.todayPlan ?? widget.currentPlan;

    // Strict validation: must be non-null and NOT a home workout plan
    final bool hasValidGymPlan = effectivePlan != null && !effectivePlan.isHomeWorkout;
    final bool isConverting = widget.state.isConvertingHome || _isConvertingLocally;
    final bool canConvert = hasValidGymPlan && !isConverting;

    return GymBroCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      borderColor: tokens.lime.withOpacity(0.3),
      gradient: LinearGradient(
        colors: [
          theme.brightness == Brightness.dark
              ? const Color(0xFF161E12)
              : widget.tokens.lime.withOpacity(0.12),
          widget.tokens.cardBackground,
        ],
        begin: AlignmentDirectional.centerStart,
        end: AlignmentDirectional.centerEnd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.tokens.lime.withOpacity(0.18),
                ),
                child: Center(
                  child: GymBroIcon(
                    icon: GymBroDashboardIconType.homeMode,
                    size: 22,
                    active: true,
                    activeColor: widget.tokens.lime,
                  ),
                ),
              ),
              AppSpacing.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'امروز به باشگاه نمی‌رسی؟',
                      style: AppTypography.body(context).copyWith(
                        fontWeight: FontWeight.w900,
                        color: widget.tokens.lime,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تبدیل فوری حرکات به تمرین بدون وسیله در خانه',
                      style: AppTypography.caption(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;

              final convertBtn = GymBroPrimaryButton(
                text: 'تبدیل برنامه امروز',
                isLoading: isConverting,
                height: 44,
                prefixIcon: const Icon(Icons.sync_rounded, size: 18),
                onPressed: canConvert
                    ? () => _handleConversion(context, effectivePlan)
                    : null,
              );

              final homeModeBtn = GymBroOutlineButton(
                text: 'ورزش خانگی',
                onPressed: widget.onOpenHomeMode,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    convertBtn,
                    AppSpacing.hSm,
                    homeModeBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: convertBtn),
                  AppSpacing.wSm,
                  Expanded(flex: 2, child: homeModeBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. DAILY HYDRATION TRACKER (HUMAN-CRAFTED ATHLETIC TECH)
// ============================================================================

class _DailyHydrationCard extends StatelessWidget {
  final AppState state;
  final AppThemeExtension tokens;

  const _DailyHydrationCard({required this.state, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state.hydrationState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final consumed = state.todayConsumedWaterMl;
        final target = state.nutritionPlan.targetWaterMl > 0
            ? state.nutritionPlan.targetWaterMl
            : 2500;
        final progress = (consumed / target).clamp(0.0, 1.0);
        final percentage = (progress * 100).toInt();

        return GymBroCard(
          padding: const EdgeInsets.all(AppSpacing.base),
          borderColor: tokens.cyan.withOpacity(0.35),
          gradient: LinearGradient(
            colors: [
              theme.brightness == Brightness.dark
                  ? const Color(0xFF101C24)
                  : tokens.cyan.withOpacity(0.08),
              tokens.cardBackground,
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: tokens.cyan.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.water_drop_rounded,
                                color: tokens.cyan, size: 18),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مصرف آب و هیدراتاسیون',
                                style: AppTypography.bodySmall(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'هدف روزانه (امروز): ${PersianUtils.toPersianDigits(target)} میلی‌لیتر',
                                style: AppTypography.caption(context).copyWith(
                                  color: tokens.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.cyan.withOpacity(0.18),
                      borderRadius: AppRadii.smRadius,
                    ),
                    child: Text(
                      PersianUtils.formatPercentage(percentage),
                      textDirection: TextDirection.rtl,
                      style: AppTypography.caption(context).copyWith(
                        color: tokens.cyan,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: AppRadii.pillRadius,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: tokens.cardElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.cyan),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${PersianUtils.toPersianDigits(consumed)} / ${PersianUtils.toPersianDigits(target)} میلی‌لیتر',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ) ??
                          TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (consumed > 0) ...[
                        GymBroIconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          tooltip: 'کاهش ۲۵۰ میلی‌لیتر',
                          size: 36,
                          onPressed: () => state.undoWater(
                            250,
                            dateString: state.todayDateString,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      GymBroOutlineButton(
                        text: '+۲۵۰ ml',
                        icon: Icon(Icons.add, size: 16, color: tokens.cyan),
                        textColor: tokens.cyan,
                        borderColor: tokens.cyan.withOpacity(0.5),
                        onPressed: () => state.logWater(
                          250,
                          dateString: state.todayDateString,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// 6. QUICK TOOLS BAR
// ============================================================================

class _QuickToolsBar extends StatelessWidget {
  final AppThemeExtension tokens;
  final VoidCallback onOpenMealScanner;
  final VoidCallback onOpenHomeMode;
  final VoidCallback onOpenAiCoach;

  const _QuickToolsBar({
    required this.tokens,
    required this.onOpenMealScanner,
    required this.onOpenHomeMode,
    required this.onOpenAiCoach,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            title: 'برآورد غذا',
            subtitle: 'ورودی متنی · نتیجه دمو مشخص می‌شود',
            customIcon: const GymBroNutritionIllustration(
              type: GymBroNutritionType.foodScanner,
              size: 20,
            ),
            accentColor: tokens.lime,
            onTap: onOpenMealScanner,
          ),
        ),
        AppSpacing.wSm,
        Expanded(
          child: _QuickActionCard(
            title: 'مربی هوشمند AI',
            subtitle: 'مشاوره بیومکانیک',
            customIcon: GymBroIcon(
              icon: GymBroDashboardIconType.aiCoach,
              size: 20,
              active: true,
              activeColor: tokens.cyan,
            ),
            accentColor: tokens.cyan,
            onTap: onOpenAiCoach,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget customIcon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.customIcon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    return Semantics(
      button: true,
      label: '$title، $subtitle',
      child: GymBroCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        onTap: onTap,
        borderColor: tokens.borderColor.withOpacity(0.5),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.18),
                ),
                child: customIcon,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


