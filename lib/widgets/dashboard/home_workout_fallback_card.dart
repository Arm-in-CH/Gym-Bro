import 'package:flutter/material.dart';
import '../../models/workout_plan.dart';
import '../../state/app_state.dart';
import '../common/gymbro_design_system.dart';

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
