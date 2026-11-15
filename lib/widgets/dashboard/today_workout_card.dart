import 'package:flutter/material.dart';
import '../../core/localization/persian_utils.dart';
import '../../models/workout_plan.dart';
import '../../state/app_state.dart';
import '../common/gymbro_design_system.dart';
import '../../screens/focused_training_screen.dart';

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
  /// 3. Returns null if insufficient information exists (no hardcoded fabrication).
  static String? getWorkoutDurationLabel({
    required WorkoutPlan? plan,
    required AppState state,
  }) {
    if (plan == null) return null;

    final planLogs = state.workoutLogs
        .where((log) => log.planId == plan.id && log.durationMinutes > 0)
        .toList();
    if (planLogs.isNotEmpty) {
      planLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final realDuration = planLogs.first.durationMinutes;
      return '${PersianUtils.toPersianDigits(realDuration)} دقیقه';
    }

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

    return null;
  }

  /// Derives calorie burn:
  /// - Only returns a value if a validated calculation or log exists.
  /// - Never invents fixed calorie burn values.
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
        borderColor: tokens.borderColor.withOpacity(0.5),
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
            Text(
              'برای شروع تمرینات تخصصی در باشگاه و ثبت ست‌ها و رکوردها، لطفاً یک برنامه تمرینی اختصاصی بسازید یا از برنامه‌های آماده استفاده نمایید.',
              style: AppTypography.bodySmall(context).copyWith(
                color: tokens.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
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

    // True HERO Card: Glowing border, rich gradient depth, high visual hierarchy
    return GymBroCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: hasActiveDraft
          ? tokens.lime
          : tokens.lime.withOpacity(0.45),
      gradient: LinearGradient(
        colors: [
          theme.brightness == Brightness.dark
              ? const Color(0xFF141C12)
              : tokens.lime.withOpacity(0.14),
          tokens.cardElevated,
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
                          fontWeight: FontWeight.w900,
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

          // Workout Title (Athletic contrast)
          Text(
            plan.titleFa,
            style: AppTypography.pageTitle(context).copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // Split & Frequency subtitle (Dynamic)
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

          // Primary CTA Button
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
