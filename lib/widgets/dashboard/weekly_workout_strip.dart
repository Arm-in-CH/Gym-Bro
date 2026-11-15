import 'package:flutter/material.dart';
import '../../core/localization/persian_utils.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../models/workout_plan.dart';

class WeeklyWorkoutStrip extends StatefulWidget {
  final AppThemeExtension tokens;
  final WorkoutPlan? selectedPlan;
  final AppState state;
  final DateTime? currentDate;

  static const List<Map<String, String>> weekDays = [
    {'day': 'ش', 'name': 'شنبه'},
    {'day': 'ی', 'name': 'یکشنبه'},
    {'day': 'د', 'name': 'دوشنبه'},
    {'day': 'س', 'name': 'سه‌شنبه'},
    {'day': 'چ', 'name': 'چهارشنبه'},
    {'day': 'پ', 'name': 'پنج‌شنبه'},
    {'day': 'ج', 'name': 'جمعه'},
  ];

  const WeeklyWorkoutStrip({
    super.key,
    required this.tokens,
    required this.selectedPlan,
    required this.state,
    this.currentDate,
  });

  @override
  State<WeeklyWorkoutStrip> createState() => _WeeklyWorkoutStripState();
}

class _WeeklyWorkoutStripState extends State<WeeklyWorkoutStrip> {
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    final now = widget.currentDate ?? DateTime.now();
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
    final saturdayOfThisWeek = DateTime(now.year, now.month, now.day - todayWeekIndex);

    final frequencyBadgeLabel = widget.selectedPlan != null
        ? '${PersianUtils.toPersianDigits(widget.selectedPlan!.daysPerWeek)} جلسه در هفته'
        : 'بدون برنامه';

    // Pre-compute O(1) set of logged workout date strings
    final loggedDateSet = widget.state.workoutLogs.map((log) => log.date).toSet();
    final planExercises = widget.selectedPlan?.exercises ?? const [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.6),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: tokens.borderColor.withOpacity(0.4)),
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

              final dayDateString = PersianUtils.toDateString(dayDate);
              final hasLoggedWorkout = loggedDateSet.contains(dayDateString);

              final isScheduledDay = planExercises.any(
                (e) => e.dayNameFa.contains(dayInfo['name']!),
              );

              final daySemanticLabel =
                  '${dayInfo['name']}، $dayNumber ${hasLoggedWorkout ? 'تمرین تکمیل شده' : (isToday ? 'امروز' : '')}';

              return Semantics(
                button: true,
                selected: isSelected,
                label: daySemanticLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 38,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tokens.lime.withOpacity(0.2)
                          : (isToday
                              ? tokens.lime.withOpacity(0.08)
                              : Colors.transparent),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isSelected
                            ? tokens.lime
                            : (isToday
                                ? tokens.lime.withOpacity(0.4)
                                : Colors.transparent),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            dayInfo['day']!,
                            style: AppTypography.caption(context).copyWith(
                              color: isSelected
                                  ? tokens.lime
                                  : (isToday
                                      ? tokens.lime
                                      : tokens.textMuted),
                              fontWeight: (isSelected || isToday)
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            dayNumber,
                            style: AppTypography.caption(context).copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onSurface
                                  : (isToday
                                      ? Theme.of(context).colorScheme.onSurface
                                      : tokens.textMuted),
                              fontWeight: (isSelected || isToday)
                                  ? FontWeight.w800
                                  : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasLoggedWorkout)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.lime,
                              boxShadow: [
                                BoxShadow(
                                  color: tokens.lime.withOpacity(0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          )
                        else if (isScheduledDay)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.cyan.withOpacity(0.7),
                            ),
                          )
                        else
                          const SizedBox(height: 6),
                      ],
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
