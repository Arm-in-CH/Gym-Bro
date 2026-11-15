import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../widgets/adaptive_container.dart';
import '../state/app_state.dart';
import '../models/workout_plan.dart';

class HomeWorkoutModeScreen extends StatelessWidget {
  final AppState state;
  final Function(String planId) onStartWorkout;

  const HomeWorkoutModeScreen({
    super.key,
    required this.state,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final homePlans = state.workoutPlans.where((p) => p.isHomeWorkout).toList();
    final gymPlans = state.workoutPlans.where((p) => !p.isHomeWorkout).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ورزش در خانه (Home Mode)'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: AdaptiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: tokens.cardBackground,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(color: tokens.lime.withOpacity(0.4)),
                    gradient: LinearGradient(
                      colors: [
                        tokens.lime.withOpacity(0.12),
                        tokens.cardBackground,
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.lime.withOpacity(0.2),
                            ),
                            child:
                                Icon(Icons.home, color: tokens.lime, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سیستم تطبیق هوشمند تمرین خانگی',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: tokens.lime,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  'جایگزینی حرکات باشگاهی با حرکات وزن بدن بدون افت فشار تمرین',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(
                        'تبدیل هوشمند از برنامه‌های باشگاهی شما:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...gymPlans.map((gp) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: state.isConvertingHome
                                    ? null
                                    : () async {
                                        final genPlan = await state
                                            .convertGymPlanToHomePlan(gp.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'برنامه خانگی «${genPlan.titleFa}» تولید شد.'),
                                              backgroundColor:
                                                  tokens.cardElevated,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tokens.cardElevated,
                                  foregroundColor: theme.colorScheme.onSurface,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.roundedMd,
                                    side: BorderSide(color: tokens.borderColor),
                                  ),
                                ),
                                icon: Icon(Icons.sync,
                                    color: tokens.lime, size: 18),
                                label:
                                    Text('تبدیل «${gp.titleFa}» به حالت خانگی'),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'برنامه‌های آماده خانگی (۱۰۰٪ وزن بدن)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                ...homePlans.map((hp) => _buildHomePlanCard(context, hp)),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePlanCard(BuildContext context, WorkoutPlan plan) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.titleFa,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.lime,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.smRadius,
                ),
                child: Text(
                  'بدون وسیله',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.lime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            plan.descriptionFa,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onStartWorkout(plan.id),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('شروع تمرین در خانه'),
            ),
          ),
        ],
      ),
    );
  }
}
