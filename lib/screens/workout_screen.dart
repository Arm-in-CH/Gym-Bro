import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import '../widgets/exercise_detail_sheet.dart';
import '../widgets/one_rm_calculator_dialog.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/workout_plan_editor_dialog.dart';
import '../widgets/common/gymbro_design_system.dart';
import 'workout_history_screen.dart';
import 'focused_training_screen.dart';
import 'exercise_bank_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final AppState state;
  final Function(String planId) onStartWorkout;
  final VoidCallback onOpenHomeMode;

  const WorkoutScreen({
    super.key,
    required this.state,
    required this.onStartWorkout,
    required this.onOpenHomeMode,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscle = 'All';
  String _selectedEquipment = 'All';
  String _searchQuery = '';

  final List<Map<String, String>> _muscleFilters = const [
    {'key': 'All', 'label': 'همه عضلات'},
    {'key': 'Chest', 'label': 'سینه'},
    {'key': 'Back', 'label': 'زیربغل و پشت'},
    {'key': 'Legs', 'label': 'پا'},
    {'key': 'Shoulders', 'label': 'سرشانه'},
    {'key': 'Arms', 'label': 'بازو'},
    {'key': 'Core', 'label': 'شکم'},
  ];

  final List<Map<String, String>> _equipmentFilters = const [
    {'key': 'All', 'label': 'همه تجهیزات'},
    {'key': 'Barbell', 'label': 'هالتر'},
    {'key': 'Dumbbell', 'label': 'دمبل'},
    {'key': 'Machine', 'label': 'دستگاه'},
    {'key': 'Cable', 'label': 'سیم‌کش'},
    {'key': 'Bodyweight', 'label': 'وزن بدن'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تمرینات تخصصی جیم‌برو'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: tokens.lime),
            tooltip: _tabController.index == 0
                ? 'ایجاد برنامه جدید'
                : 'افزودن حرکت جدید به بانک',
            onPressed: () {
              if (_tabController.index == 0) {
                showDialog(
                  context: context,
                  builder: (_) => WorkoutPlanEditorDialog(state: widget.state),
                );
              } else {
                _showAddExerciseDialog(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.calculate_outlined, color: tokens.lime),
            tooltip: 'محاسبه‌گر 1RM',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const OneRmCalculatorDialog(),
              );
            },
          ),
          IconButton(
            icon: GymBroIcon(
              icon: GymBroDashboardIconType.exerciseHistory,
              size: 22,
              active: true,
              activeColor: tokens.cyan,
            ),
            tooltip: 'تاریخچه جلسات تمرین',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutHistoryScreen(state: widget.state),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.travel_explore_rounded, color: tokens.cyan, size: 22),
            tooltip: 'بانک جامع و آناتومی حرکات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseBankScreen(state: widget.state),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tokens.lime,
          indicatorWeight: 3,
          labelColor: tokens.lime,
          unselectedLabelColor: tokens.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'برنامه‌های تمرینی'),
            Tab(text: 'بانک جامع حرکات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(context),
          _buildExerciseLibraryTab(context),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: WORKOUT PLANS TAB
  // ============================================================================

  Widget _buildPlansTab(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final plans = widget.state.workoutPlans;
    final activeDraftPlan = plans.cast<WorkoutPlan?>().firstWhere(
      (p) => p != null && widget.state.getActiveWorkoutDraft(p.id) != null,
      orElse: () => null,
    );

    return AdaptiveContainer(
      child: RefreshIndicator(
        color: tokens.lime,
        backgroundColor: tokens.cardElevated,
        onRefresh: () async {
          await widget.state.refreshData();
        },
        child: plans.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 420,
                  child: EmptyStateWidget(
                    customGraphic: const GymBroIcon(
                      icon: GymBroDashboardIconType.workout,
                      size: 48,
                      active: true,
                    ),
                    title: 'برنامه تمرینی فعالی وجود ندارد',
                    subtitle:
                        'می‌توانید با دکمه + در بالا یک برنامه جدید بسازید یا از مربی هوشمند استفاده کنید.',
                    actionLabel: 'تلاش مجدد',
                    onAction: () => widget.state.refreshData(),
                  ),
                ),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.screenPadding,
                children: [
                  // Live Active Workout Banner (If Any Draft is in Progress)
                  if (activeDraftPlan != null) ...[
                    GymBroHeroCard(
                      content: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tokens.lime.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(Icons.play_arrow_rounded, color: tokens.lime, size: 28),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'جلسه تمرینی زنده در حال اجراست',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: tokens.lime,
                                  ),
                                ),
                                Text(
                                  activeDraftPlan.titleFa,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GymBroPrimaryButton(
                            text: 'ادامه جلسه',
                            height: 38,
                            onPressed: () => widget.onStartWorkout(activeDraftPlan.id),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hBase,
                  ],

                  // Signature Home Workout Fallback Banner
                  GymBroCard(
                    onTap: widget.onOpenHomeMode,
                    borderColor: tokens.lime.withOpacity(0.35),
                    gradient: LinearGradient(
                      colors: [
                        theme.brightness == Brightness.dark
                            ? const Color(0xFF161E12)
                            : tokens.lime.withOpacity(0.12),
                        tokens.cardBackground,
                      ],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.lime.withOpacity(0.2),
                          ),
                          child: GymBroIcon(
                            icon: GymBroDashboardIconType.homeMode,
                            size: 22,
                            active: true,
                            activeColor: tokens.lime,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ورود به بخش اختصاصی ورزش در خانه',
                                style: AppTypography.bodySmall(context).copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: tokens.lime,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تمرینات ۱۰۰٪ وزن بدن بدون نیاز به دمبل و دستگاه',
                                style: AppTypography.caption(context).copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_left_rounded,
                            size: 18, color: tokens.textMuted),
                      ],
                    ),
                  ),
                  AppSpacing.hBase,

                  const GymBroSectionHeader(
                    title: 'برنامه‌های تمرینی فعال شما',
                    subtitle: 'برنامه‌ریزی، مدیریت اسپلیت و اجرای جلسات زنده',
                  ),
                  AppSpacing.hSm,

                  ...plans.map((plan) => _buildPlanItem(context, plan)),
                  AppSpacing.hLg,
                ],
              ),
      ),
    );
  }

  Widget _buildPlanItem(BuildContext context, WorkoutPlan plan) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final activeDraft = widget.state.getActiveWorkoutDraft(plan.id);
    final hasDraft = activeDraft != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GymBroCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        borderColor: hasDraft ? tokens.lime : tokens.borderColor.withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Category Badge, Edit & Delete Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.titleFa,
                    style: AppTypography.pageTitle(context).copyWith(
                      color: hasDraft ? tokens.lime : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plan.isHomeWorkout
                            ? tokens.lime.withOpacity(0.15)
                            : tokens.cyan.withOpacity(0.15),
                        borderRadius: AppRadii.roundedXs,
                      ),
                      child: Text(
                        plan.isHomeWorkout ? 'ورزش خانگی' : 'باشگاهی',
                        style: AppTypography.caption(context).copyWith(
                          color: plan.isHomeWorkout ? tokens.lime : tokens.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'ویرایش برنامه ${plan.titleFa}',
                      child: IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: tokens.textMuted),
                        tooltip: 'ویرایش برنامه',
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.minTouchTarget,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => WorkoutPlanEditorDialog(
                              state: widget.state,
                              initialPlan: plan,
                            ),
                          );
                        },
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'حذف برنامه ${plan.titleFa}',
                      child: IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 18, color: theme.colorScheme.error),
                        tooltip: 'حذف برنامه',
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.minTouchTarget,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _confirmDeletePlan(context, plan),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              plan.descriptionFa,
              style: AppTypography.caption(context).copyWith(
                color: tokens.textMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Plan Tags Wrap
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _PlanTagPill(
                  icon: Icons.splitscreen_outlined,
                  text: 'اسپلیت: ${plan.splitType}',
                  tokens: tokens,
                ),
                _PlanTagPill(
                  icon: Icons.calendar_today_outlined,
                  text: '${PersianUtils.toPersianDigits(plan.daysPerWeek)} روز در هفته',
                  tokens: tokens,
                ),
                _PlanTagPill(
                  icon: Icons.fitness_center_outlined,
                  text: '${PersianUtils.toPersianDigits(plan.exercises.length)} حرکت تخصصی',
                  tokens: tokens,
                ),
                _PlanTagPill(
                  icon: Icons.speed_outlined,
                  text: plan.difficulty,
                  tokens: tokens,
                ),
              ],
            ),

            // Exercise Peek Preview Strip (Immediate Readability)
            if (plan.exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: tokens.cardElevated.withOpacity(0.6),
                  borderRadius: AppRadii.smRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_list_bulleted_rounded, size: 14, color: tokens.lime),
                        const SizedBox(width: 6),
                        Text(
                          'حرکات اصلی این برنامه:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tokens.lime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...plan.exercises.take(3).map((e) {
                      final ex = widget.state.exercises.cast<Exercise?>().firstWhere(
                        (item) => item?.id == e.exerciseId,
                        orElse: () => null,
                      );
                      final name = ex?.nameFa ?? 'حرکت تمرینی';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '• $name',
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${PersianUtils.toPersianDigits(e.targetSets)} ست × ${PersianUtils.toPersianDigits(e.targetReps)} تکرار',
                              style: TextStyle(
                                fontSize: 11,
                                color: tokens.textMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (plan.exercises.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${PersianUtils.toPersianDigits(plan.exercises.length - 3)} حرکت دیگر در این جلسه',
                          style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Primary CTA: شروع تمرین
            GymBroPrimaryButton(
              text: hasDraft
                  ? 'ادامه تمرین در حال اجرا'
                  : 'رفتن به تمرین (ورود به جلسه زنده)',
              prefixIcon: GymBroIcon(
                icon: GymBroDashboardIconType.workout,
                size: 20,
                active: true,
                activeColor: tokens.textOnLime,
              ),
              onPressed: () => widget.onStartWorkout(plan.id),
            ),
            const SizedBox(height: 8),

            // Secondary CTA: Focus Mode
            SizedBox(
              width: double.infinity,
              child: GymBroOutlineButton(
                text: 'ورود به حالت تمرین متمرکز (Focus Mode)',
                textColor: tokens.cyan,
                borderColor: tokens.cyan.withOpacity(0.5),
                icon: GymBroIcon(
                  icon: GymBroDashboardIconType.focusedTraining,
                  size: 18,
                  active: true,
                  activeColor: tokens.cyan,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FocusedTrainingScreen(
                        planId: plan.id,
                        state: widget.state,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, WorkoutPlan plan) async {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: tokens.borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
            const SizedBox(width: AppSpacing.sm),
            const Text('حذف برنامه تمرینی',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'آیا از حذف برنامه «${plan.titleFa}» اطمینان دارید؟ تمرینات ذخیره شده قبلی در تاریخچه حفظ خواهند شد.',
          style: TextStyle(
            fontSize: 13,
            color: tokens.textMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: TextStyle(color: tokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.roundedSm,
              ),
            ),
            child: const Text('حذف برنامه'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.state.deleteWorkoutPlan(plan.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('برنامه "${plan.titleFa}" با موفقیت حذف گردید.')),
        );
      }
    }
  }

  // ============================================================================
  // TAB 2: EXERCISE LIBRARY TAB (IMAGE 3 REFERENCE SPECIFICATION)
  // ============================================================================

  Widget _buildExerciseLibraryTab(BuildContext context) {
    final tokens = context.appTokens;

    final filtered = widget.state.exercises.where((e) {
      // Muscle filter
      final matchesMuscle =
          _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;

      // Equipment filter
      final matchesEquipment = _selectedEquipment == 'All' ||
          e.equipment.toLowerCase().contains(_selectedEquipment.toLowerCase()) ||
          e.equipmentFa.toLowerCase().contains(_selectedEquipment.toLowerCase()) ||
          (_selectedEquipment == 'Bodyweight' && e.isBodyweight);

      // Search query
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          e.nameFa.contains(q) ||
          e.nameEn.toLowerCase().contains(q) ||
          e.muscleGroupFa.contains(q) ||
          e.equipmentFa.contains(q);

      return matchesMuscle && matchesEquipment && matchesSearch;
    }).toList();

    return AdaptiveContainer(
      child: Column(
        children: [
          // 0. Hero Banner to Full Interactive Anatomy Exercise Bank
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              AppSpacing.xs,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseBankScreen(state: widget.state),
                  ),
                );
              },
              borderRadius: AppRadii.roundedMd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: tokens.lime.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.accessibility_new_rounded, color: tokens.lime, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بانک هوشمند حرکات با نقشه آناتومی بدن',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'جستجوی موازی دو زبانه و تفکیک تجهیزات ورزشی',
                            style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: tokens.lime),
                  ],
                ),
              ),
            ),
          ),
          // 1. Search Bar with Clear Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'جستجوی حرکات ورزشی',
                hintText: 'جستجوی نام حرکت (سینه، هالتر، Bicep)...',
                prefixIcon: Icon(Icons.search, color: tokens.lime),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: tokens.cardElevated.withOpacity(0.7),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: AppRadii.roundedBase,
                  borderSide: BorderSide(color: tokens.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.roundedBase,
                  borderSide: BorderSide(color: tokens.borderColor.withOpacity(0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadii.roundedBase,
                  borderSide: BorderSide(color: tokens.lime, width: 1.5),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),

          // 2. Muscle Group Filter Chips
          SizedBox(
            height: math.max(
              AppSpacing.minTouchTarget,
              44.0 * MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.3),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: _muscleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = _muscleFilters[index];
                final isSelected = _selectedMuscle == filter['key'];

                return ChoiceChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  selectedColor: tokens.lime,
                  backgroundColor: tokens.cardBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? tokens.textOnLime : tokens.textMuted,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? tokens.lime
                        : tokens.borderColor.withOpacity(0.5),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.pillRadius,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedMuscle = filter['key']!);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // 3. Equipment Category Filter Chips (Matching Image 3)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: _equipmentFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final filter = _equipmentFilters[index];
                final isSelected = _selectedEquipment == filter['key'];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _selectedEquipment = filter['key']!);
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tokens.cyan.withOpacity(0.2)
                          : tokens.cardElevated.withOpacity(0.5),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(
                        color: isSelected
                            ? tokens.cyan
                            : tokens.borderColor.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      filter['label']!,
                      style: AppTypography.caption(context).copyWith(
                        color: isSelected ? tokens.cyan : tokens.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 4. Exercises Count & Sort Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${PersianUtils.toPersianDigits(filtered.length)} حرکت منطبق',
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'برای مشاهده بیومکانیک لمس کنید',
                    style: AppTypography.caption(context).copyWith(
                      color: tokens.textMuted.withOpacity(0.7),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 5. Exercises List Cards
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.search_off_outlined,
                    title: 'حرکتی یافت نشد',
                    subtitle: 'عبارت جستجو یا فیلتر عضلانی را تغییر دهید.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return _ExerciseCard(
                        exercise: ex,
                        tokens: tokens,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => ExerciseDetailSheet(exercise: ex),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) async {
    final nameFaCtrl = TextEditingController();
    final nameEnCtrl = TextEditingController();
    final instructionsCtrl = TextEditingController();
    String selectedMuscle = 'Chest';
    String selectedMuscleFa = 'سینه';
    String selectedEquipment = 'دمبل';
    bool isBodyweight = false;

    final muscleMap = {
      'Chest': 'سینه',
      'Back': 'پشت و زیربغل',
      'Legs': 'پا و چهارسر',
      'Shoulders': 'سرشانه',
      'Arms': 'بازو',
      'Core': 'شکم و پهلو',
    };

    final equipmentOptions = [
      'دمبل',
      'هالتر',
      'دستگاه سیم‌کش',
      'دستگاه مکانیکی',
      'وزن بدن',
      'کش مقاومتی',
    ];

    final tokens = context.appTokens;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: tokens.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.lgRadius,
                side: BorderSide(color: tokens.borderColor),
              ),
              title: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: tokens.lime, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('افزودن حرکت جدید به بانک حرکات',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameFaCtrl,
                      decoration: InputDecoration(
                        labelText: 'نام حرکت (فارسی) *',
                        hintText: 'مثال: پرس سینه دمبل موازی',
                        filled: true,
                        fillColor: tokens.cardElevated.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.roundedSm,
                          borderSide: BorderSide(color: tokens.borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: nameEnCtrl,
                      decoration: InputDecoration(
                        labelText: 'نام انگلیسی (اختیاری)',
                        hintText: 'مثال: Neutral Dumbbell Press',
                        filled: true,
                        fillColor: tokens.cardElevated.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.roundedSm,
                          borderSide: BorderSide(color: tokens.borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: selectedMuscle,
                      dropdownColor: tokens.cardBackground,
                      decoration: InputDecoration(
                        labelText: 'گروه عضلانی هدف',
                        filled: true,
                        fillColor: tokens.cardElevated.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.roundedSm,
                          borderSide: BorderSide(color: tokens.borderColor),
                        ),
                      ),
                      items: muscleMap.entries.map((e) {
                        return DropdownMenuItem(
                            value: e.key, child: Text(e.value));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedMuscle = v;
                            selectedMuscleFa = muscleMap[v] ?? v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: selectedEquipment,
                      dropdownColor: tokens.cardBackground,
                      decoration: InputDecoration(
                        labelText: 'نوع تجهیزات',
                        filled: true,
                        fillColor: tokens.cardElevated.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.roundedSm,
                          borderSide: BorderSide(color: tokens.borderColor),
                        ),
                      ),
                      items: equipmentOptions.map((eq) {
                        return DropdownMenuItem(value: eq, child: Text(eq));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedEquipment = v;
                            isBodyweight = v == 'وزن بدن';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: instructionsCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'نکات فرم صحیح و بیومکانیک',
                        hintText: 'نکات تنفس، زاویه آرنج و دامنه حرکت...',
                        filled: true,
                        fillColor: tokens.cardElevated.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.roundedSm,
                          borderSide: BorderSide(color: tokens.borderColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('انصراف', style: TextStyle(color: tokens.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nameFa = nameFaCtrl.text.trim();
                    if (nameFa.isEmpty) return;

                    final newEx = Exercise(
                      id: 'ex_custom_${DateTime.now().millisecondsSinceEpoch}',
                      nameFa: nameFa,
                      nameEn: nameEnCtrl.text.trim().isNotEmpty
                          ? nameEnCtrl.text.trim()
                          : nameFa,
                      muscleGroup: selectedMuscle,
                      muscleGroupFa: selectedMuscleFa,
                      equipment: selectedEquipment,
                      equipmentFa: selectedEquipment,
                      instructionsFa: instructionsCtrl.text.trim().isNotEmpty
                          ? instructionsCtrl.text.trim()
                          : 'حرکت با تمرکز کامل روی عضله هدف اجرا گردد.',
                      isBodyweight: isBodyweight,
                    );

                    await widget.state.saveExercise(newEx);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'حرکت "$nameFa" با موفقیت به بانک افزوده شد.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.lime,
                    foregroundColor: tokens.textOnLime,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.roundedSm,
                    ),
                  ),
                  child: const Text('ذخیره در بانک حرکات',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// EXERCISE CARD (MATCHING REFERENCE IMAGE 3 SPECIFICATION)
// ============================================================================

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final AppThemeExtension tokens;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryMuscles = exercise.resolvedSecondaryMusclesFa;

    return GymBroCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: tokens.borderColor.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Anatomy Muscle Group Graphic with Glowing Activation
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: tokens.lime.withOpacity(0.35)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GymBroMuscleIllustration(
                  muscle: GymBroMuscleGroupX.fromString(exercise.muscleGroup),
                  activation: GymBroMuscleActivation.primary,
                  size: 42,
                  isAnimated: false,
                ),
                // Equipment icon miniature badge at bottom-corner
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.cyan.withOpacity(0.5), width: 0.8),
                    ),
                    child: GymBroEquipmentIllustration(
                      type: GymBroEquipmentTypeX.fromString(exercise.equipment),
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 2. Exercise Details (Name Fa, Name En, Muscle breakdown)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.nameFa,
                  style: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  exercise.nameEn,
                  style: AppTypography.caption(context).copyWith(
                    color: tokens.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Primary Muscle Bullet
                Row(
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
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        exercise.primaryMuscleFa,
                        style: AppTypography.caption(context).copyWith(
                          color: tokens.lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Secondary Muscles Bullet (if any)
                if (secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.cyan.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          secondaryMuscles.take(2).join(' • '),
                          style: AppTypography.caption(context).copyWith(
                            color: tokens.textMuted,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Equipment Chip & Chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.roundedXs,
                  border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
                ),
                child: Text(
                  exercise.equipmentFa,
                  style: AppTypography.caption(context).copyWith(
                    color: tokens.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.chevron_left_rounded,
                  size: 18, color: tokens.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTagPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppThemeExtension tokens;

  const _PlanTagPill({
    required this.icon,
    required this.text,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.7),
        borderRadius: AppRadii.roundedXs,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tokens.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: AppTypography.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
