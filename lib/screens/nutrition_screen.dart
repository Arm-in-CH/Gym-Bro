import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../core/storage/id_generator.dart';
import '../state/app_state.dart';
import '../models/calorie_scan_log.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/charts/calorie_gauge_card.dart';
import '../widgets/charts/macronutrient_bar_card.dart';
import '../widgets/charts/weekly_nutrition_chart.dart';
import '../widgets/water_tracker_card.dart';
import 'add_food_dialog.dart';
import 'edit_nutrition_goals_dialog.dart';

/// داشبورد تخصصی پایش هوشمند تغذیه، کالری و آب (Phase 13)
class NutritionScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onOpenScanner;

  const NutritionScreen({
    super.key,
    required this.state,
    required this.onOpenScanner,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final List<String> _mealCategories = const [
    'صبحانه',
    'ناهار',
    'شام',
    'میان‌وعده',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final state = widget.state;

    final isToday = state.selectedNutritionDateString == state.todayDateString;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تغذیه و پایش هوشمند کالری'),
        actions: [
          IconButton(
            tooltip: 'تنظیم اهداف تغذیه',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => EditNutritionGoalsDialog.show(context, state: state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddFoodDialog.show(
          context,
          state: state,
          initialDateString: state.selectedNutritionDateString,
        ),
        backgroundColor: tokens.lime,
        foregroundColor: tokens.textOnLime,
        icon: const Icon(Icons.add_rounded),
        label: const Text('ثبت وعده', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: AdaptiveContainer(
          child: RefreshIndicator(
            color: tokens.lime,
            backgroundColor: tokens.cardElevated,
            onRefresh: () async {
              await state.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Date Navigator Strip
                  _buildDateNavigator(context, isToday),
                  const SizedBox(height: AppSpacing.sm),

                  // 2. Horizontal Week Days Bar
                  _buildWeekDaysSelector(context),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Calorie Gauge Card (Today Calories Hero with Macros)
                  CalorieGaugeCard(
                    consumedCalories: state.selectedConsumedCalories,
                    targetCalories: state.nutritionPlan.dailyCalories,
                    consumedProtein: state.selectedConsumedProtein,
                    targetProtein: state.nutritionPlan.targetProteinG,
                    consumedCarbs: state.selectedConsumedCarbs,
                    targetCarbs: state.nutritionPlan.targetCarbsG,
                    consumedFat: state.selectedConsumedFat,
                    targetFat: state.nutritionPlan.targetFatG,
                    onEditGoals: () => EditNutritionGoalsDialog.show(context, state: state),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Macronutrient Bar Card
                  MacronutrientBarCard(
                    consumedProtein: state.selectedConsumedProtein,
                    targetProtein: state.nutritionPlan.targetProteinG,
                    consumedCarbs: state.selectedConsumedCarbs,
                    targetCarbs: state.nutritionPlan.targetCarbsG,
                    consumedFat: state.selectedConsumedFat,
                    targetFat: state.nutritionPlan.targetFatG,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 5. Water Tracker Card
                  WaterTrackerCard(
                    consumedMl: state.selectedConsumedWaterMl,
                    targetMl: state.nutritionPlan.targetWaterMl,
                    lastLoggedAmount: state.getLastWaterLog(dateString: state.selectedNutritionDateString)?.amountMl,
                    dateLabel: state.selectedNutritionDateString == state.todayDateString
                        ? 'امروز'
                        : PersianUtils.toPersianDigits(state.selectedNutritionDateString),
                    onAddWater: (amount) async {
                      await state.logWater(amount, dateString: state.selectedNutritionDateString);
                    },
                    onUndoWater: (amount) async {
                      await state.undoWater(amount, dateString: state.selectedNutritionDateString);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 6. AI Meal Scanner Action Card
                  _buildAiScanBanner(context),
                  const SizedBox(height: AppSpacing.md),

                  // 7. Quick Favorites Food Carousel
                  _buildFavoriteFoodsCarousel(context),
                  const SizedBox(height: AppSpacing.lg),

                  // 8. Categorized Meals Diary (Breakfast, Lunch, Dinner, Snack)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'دفترچه وعده‌های روز ${_getDateDisplayLabel()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${PersianUtils.toPersianDigits(state.selectedDateMeals.length)} وعده',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: tokens.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 8. Vertical Meals Timeline (Anti-Boxy Timeline Layout)
                  _buildMealsTimeline(context),

                  const SizedBox(height: AppSpacing.lg),

                  // 9. Weekly & Monthly Nutrition Trends Chart
                  WeeklyNutritionChart(
                    weeklySummaries: state.getPast7DaysSummaries(),
                    monthlySummaries: state.getPast30DaysSummaries(),
                    selectedDateString: state.selectedNutritionDateString,
                    targetCalories: state.nutritionPlan.dailyCalories,
                    onDaySelected: (date) {
                      state.selectNutritionDate(date);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl * 2), // Extra padding for FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDateDisplayLabel() {
    final state = widget.state;
    if (state.selectedNutritionDateString == state.todayDateString) {
      return 'امروز';
    }
    return PersianUtils.formatPersianDate(state.selectedNutritionDate);
  }

  Widget _buildDateNavigator(BuildContext context, bool isToday) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final state = widget.state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.baseRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'روز قبل',
              onPressed: () => state.selectPreviousNutritionDay(),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.selectedNutritionDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (picked != null) {
                  state.selectNutritionDate(picked);
                }
              },
              borderRadius: AppRadii.smRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: tokens.textMuted),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      isToday
                          ? 'امروز (${PersianUtils.formatPersianDate(state.selectedNutritionDate)})'
                          : PersianUtils.formatPersianDate(state.selectedNutritionDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday ? theme.colorScheme.onSurface : tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isToday)
                  TextButton(
                    onPressed: () => state.selectTodayNutrition(),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: tokens.lime,
                    ),
                    child: const Text('امروز'),
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'روز بعد',
                  onPressed: () => state.selectNextNutritionDay(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaysSelector(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final state = widget.state;

    // Display 7 days centered on or leading up to today
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return SizedBox(
      height: 68,
      child: Row(
        children: days.map((day) {
          final dayStr = PersianUtils.toDateString(day);
          final isSelected = dayStr == state.selectedNutritionDateString;
          final isDayToday = dayStr == state.todayDateString;
          final dayName = _getDayShortName(day);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => state.selectNutritionDate(day),
                borderRadius: AppRadii.smRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tokens.lime
                        : (isDayToday ? tokens.cardElevated : tokens.cardBackground),
                    borderRadius: AppRadii.smRadius,
                    border: Border.all(
                      color: isSelected
                          ? tokens.lime
                          : (isDayToday ? tokens.lime.withOpacity(0.5) : tokens.borderColor),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: isSelected ? tokens.textOnLime : tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PersianUtils.toPersianDigits(day.day),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? tokens.textOnLime : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDayShortName(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return 'شنبه';
      case DateTime.sunday:
        return '۱شنبه';
      case DateTime.monday:
        return '۲شنبه';
      case DateTime.tuesday:
        return '۳شنبه';
      case DateTime.wednesday:
        return '۴شنبه';
      case DateTime.thursday:
        return '۵شنبه';
      case DateTime.friday:
        return 'جمعه';
      default:
        return '';
    }
  }

  Widget _buildAiScanBanner(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.onOpenScanner,
      borderRadius: AppRadii.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: tokens.cardBackground,
          borderRadius: AppRadii.lgRadius,
          border: Border.all(color: tokens.cyan.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.cyan.withOpacity(0.15),
              ),
              child: Icon(Icons.camera_alt_rounded, color: tokens.cyan, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'اسکن تصویری و برآورد هوشمند غذا',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: tokens.cyan.withOpacity(0.15),
                          borderRadius: AppRadii.xsRadius,
                          border: Border.all(color: tokens.cyan.withOpacity(0.3)),
                        ),
                        child: Text(
                          'AI Vision',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: tokens.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'عکس‌برداری با دوربین زنده یا انتخاب از گالری و محاسبه ماکروها با هوش مصنوعی',
                    style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tokens.cyan.withOpacity(0.12),
                borderRadius: AppRadii.smRadius,
                border: Border.all(color: tokens.cyan.withOpacity(0.25)),
              ),
              child: Text(
                'اسکن سریع ⚡',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tokens.cyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteFoodsCarousel(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final favorites = widget.state.favoriteFoods;

    if (favorites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'غذاهای پرتکرار ورزشی (افزودن با یک لمس)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'سریع',
                style: theme.textTheme.labelSmall?.copyWith(color: tokens.lime),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (ctx, idx) {
              final fav = favorites[idx];
              return InkWell(
                onTap: () async {
                  // 1-tap quick add dialog or direct prompt
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: tokens.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgRadius,
                        side: BorderSide(color: tokens.borderColor),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.restaurant_rounded, color: tokens.lime, size: 22),
                          const SizedBox(width: AppSpacing.sm),
                          Text('افزودن «${fav.name}»',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Text(
                        'آیا می‌خواهید این وعده با ${PersianUtils.formatCalories(fav.calories)} و ${PersianUtils.formatGrams(fav.proteinG.toInt())} پروتئین به وعده ${fav.defaultMealType} امروز اضافه شود؟',
                        style: TextStyle(fontSize: 13, color: tokens.textMuted, height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: Text('انصراف', style: TextStyle(color: tokens.textMuted)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tokens.lime,
                            foregroundColor: tokens.textOnLime,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.roundedSm,
                            ),
                          ),
                          child: const Text('افزودن به دفترچه',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await widget.state.addMealLog(
                      foodName: fav.name,
                      mealType: fav.defaultMealType,
                      calories: fav.calories,
                      proteinG: fav.proteinG,
                      carbsG: fav.carbsG,
                      fatG: fav.fatG,
                      portionG: fav.portionG,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('«${fav.name}» به ${fav.defaultMealType} اضافه شد.')),
                      );
                    }
                  }
                },
                borderRadius: AppRadii.smRadius,
                child: Container(
                  width: 145,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: tokens.cardBackground,
                    borderRadius: AppRadii.smRadius,
                    border: Border.all(color: tokens.borderColor),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fav.name,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PersianUtils.formatCalories(fav.calories),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.lime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'پ: ${PersianUtils.toPersianDigits(fav.proteinG.toInt())} گرم • ک: ${PersianUtils.toPersianDigits(fav.carbsG.toInt())} گرم',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _repeatYesterdayMeal(String category) async {
    final state = widget.state;
    final tokens = context.appTokens;
    final yesterdayDate = state.selectedNutritionDate.subtract(const Duration(days: 1));
    final yesterdayDateString = PersianUtils.toDateString(yesterdayDate);

    final yesterdayMeals = state.calorieLogs
        .where((l) => l.dateString == yesterdayDateString && l.mealType == category)
        .toList();

    if (yesterdayMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'موردی در وعده $category دیروز (${PersianUtils.toPersianDigits(yesterdayDateString)}) یافت نشد.',
            style: const TextStyle(fontFamily: 'Vazirmatn'),
          ),
          backgroundColor: tokens.cardElevated,
        ),
      );
      return;
    }

    for (final meal in yesterdayMeals) {
      final copy = CalorieScanLog(
        id: IdGenerator.generate('scan'),
        foodName: meal.foodName,
        mealType: category,
        calories: meal.calories,
        proteinG: meal.proteinG,
        carbsG: meal.carbsG,
        fatG: meal.fatG,
        portionG: meal.portionG,
        dateString: state.selectedNutritionDateString,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: meal.note,
        isAiScanned: meal.isAiScanned,
      );
      await state.addFoodEntry(copy);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'وعده $category دیروز (${PersianUtils.toPersianDigits(yesterdayMeals.length)} مورد) با موفقیت به امروز افزوده شد.',
            style: const TextStyle(fontFamily: 'Vazirmatn'),
          ),
          backgroundColor: tokens.lime,
        ),
      );
    }
  }

  Widget _buildMealsTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _mealCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final isLast = index == _mealCategories.length - 1;
        return _buildTimelineNode(context, category, isLast: isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineNode(BuildContext context, String category, {required bool isLast}) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final state = widget.state;

    final meals = state.getMealsByCategory(category);
    final categoryCalories = state.getCategoryCalories(category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Spine & Node Indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.lime.withOpacity(0.5), width: 1.5),
                ),
                child: Center(
                  child: Icon(_getCategoryIcon(category), size: 16, color: tokens.lime),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tokens.lime.withOpacity(0.4),
                          tokens.borderColor.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // Milestone Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Milestone Header Row
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '(${PersianUtils.formatCalories(categoryCalories)})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.lime,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Action Buttons: Quick 1-tap yesterday duplicate & Add Food
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1-Tap Repeat Yesterday's Meal Button
                          Tooltip(
                            message: 'تکرار وعده دیروز با ۱ لمس',
                            child: InkWell(
                              onTap: () => _repeatYesterdayMeal(category),
                              borderRadius: AppRadii.roundedXs,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: tokens.cardElevated.withOpacity(0.8),
                                  borderRadius: AppRadii.roundedXs,
                                  border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.history_rounded, size: 13, color: tokens.cyan),
                                    const SizedBox(width: 3),
                                    Text(
                                      'تکرار دیروز',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: tokens.cyan,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),

                          TextButton(
                            onPressed: () => AddFoodDialog.show(
                              context,
                              state: state,
                              initialMealType: category,
                              initialDateString: state.selectedNutritionDateString,
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              '+ ثبت غذا',
                              style: TextStyle(color: tokens.lime, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Items List or Muted Empty State
                  if (meals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'موردی برای $category ثبت نشده',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    ...meals.map((meal) => _buildMealEntryRow(context, meal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'صبحانه':
        return Icons.wb_sunny_outlined;
      case 'ناهار':
        return Icons.lunch_dining_rounded;
      case 'شام':
        return Icons.nightlight_outlined;
      case 'میان‌وعده':
      default:
        return Icons.apple_rounded;
    }
  }

  Widget _buildMealEntryRow(BuildContext context, CalorieScanLog meal) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final state = widget.state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.borderColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        meal.foodName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (meal.isAiScanned) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: tokens.cyan.withOpacity(0.15),
                          borderRadius: AppRadii.xsRadius,
                        ),
                        child: Text(
                          'AI',
                          style: TextStyle(color: tokens.cyan, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${PersianUtils.formatCalories(meal.calories)} • پرو: ${PersianUtils.toPersianDigits(meal.proteinG.toInt())} گرم • کرب: ${PersianUtils.toPersianDigits(meal.carbsG.toInt())} گرم • چربی: ${PersianUtils.toPersianDigits(meal.fatG.toInt())} گرم',
                  style: theme.textTheme.labelSmall?.copyWith(color: tokens.textMuted),
                ),
                if (meal.note != null && meal.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'یادداشت: ${meal.note!}',
                    style: theme.textTheme.labelSmall?.copyWith(color: tokens.lime, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),

          // Action Menu (Duplicate, Edit, Delete)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 18, color: tokens.textMuted),
            tooltip: 'عملیات وعده',
            onSelected: (value) async {
              switch (value) {
                case 'duplicate':
                  await state.duplicateFoodEntry(meal);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('«${meal.foodName}» تکرار شد.')),
                    );
                  }
                  break;
                case 'edit':
                  AddFoodDialog.show(
                    context,
                    state: state,
                    existingMeal: meal,
                    initialMealType: meal.mealType,
                    initialDateString: meal.dateString,
                  );
                  break;
                case 'delete':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: tokens.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgRadius,
                        side: BorderSide(color: tokens.borderColor),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('حذف وعده غذایی',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Text(
                        'آیا از حذف «${meal.foodName}» از دفترچه کالری اطمینان دارید؟',
                        style: TextStyle(fontSize: 13, color: tokens.textMuted, height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: Text('انصراف', style: TextStyle(color: tokens.textMuted)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.roundedSm,
                            ),
                          ),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await state.deleteFoodEntry(meal.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('وعده غذایی با موفقیت حذف شد.')),
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('تکرار وعده (Duplicate)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('ویرایش وعده'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: tokens.red),
                    const SizedBox(width: 8),
                    Text('حذف وعده', style: TextStyle(color: tokens.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
