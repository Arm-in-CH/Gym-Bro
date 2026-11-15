import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/workout_log.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/empty_state_widget.dart';
import '../core/graphics/graphics.dart';
import 'active_workout_screen.dart';

/// صفحه تاریخچه جلسات تمرین و داشبورد تحلیلی آمار و رکوردها (Phase 22 - History & Statistics)
class WorkoutHistoryScreen extends StatefulWidget {
  final AppState state;

  const WorkoutHistoryScreen({super.key, required this.state});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedLogIds = {};
  String _searchQuery = '';
  String _filterType = 'all'; // all, gym, home
  String _selectedMetric = 'volume'; // volume, calories, sets

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleExpand(String logId) {
    setState(() {
      if (_expandedLogIds.contains(logId)) {
        _expandedLogIds.remove(logId);
      } else {
        _expandedLogIds.add(logId);
      }
    });
  }

  Future<void> _confirmDeleteLog(WorkoutLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appTokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: Theme.of(ctx).colorScheme.error),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Theme.of(ctx).colorScheme.error, size: 22),
            const SizedBox(width: 8),
            const Text('حذف جلسه تمرین', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'آیا از حذف اطلاعات جلسه «${log.planTitle}» ثبت‌شده در تاریخ ${PersianUtils.toPersianDigits(log.date)} اطمینان دارید؟',
          style: TextStyle(fontSize: 12.5, color: context.appTokens.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: TextStyle(color: context.appTokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف جلسه'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.state.deleteWorkoutHistoryLog(log.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('جلسه تمرینی با موفقیت حذف شد.'),
            backgroundColor: context.appTokens.cardElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _repeatWorkout(WorkoutLog log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          planId: log.planId,
          state: widget.state,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;
    final allLogs = List<WorkoutLog>.from(widget.state.workoutLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filtered logs
    final filteredLogs = allLogs.where((log) {
      final matchesSearch = _searchQuery.isEmpty ||
          log.planTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.sets.any((s) => s.exerciseName.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesType = _filterType == 'all' ||
          (_filterType == 'home' && log.isHomeWorkout) ||
          (_filterType == 'gym' && !log.isHomeWorkout);

      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه جلسات تمرین'),
      ),
      body: SafeArea(
        child: AdaptiveContainer(
          child: Column(
            children: [
              // Segmented Tab Switcher (Reference Image 3: Stats | History)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: tokens.borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: tokens.lime,
                    borderRadius: AppRadii.roundedPill,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: tokens.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  tabs: const [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 15),
                            SizedBox(width: 4),
                            Text('پرونده تمرینات'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 15),
                            SizedBox(width: 4),
                            Text('داشبورد آماری'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Workout History
                    _buildHistoryTab(allLogs, filteredLogs, theme, tokens),

                    // Tab 2: Statistics & Trends (Reference Images 2 & 3)
                    _buildStatisticsTab(allLogs, theme, tokens),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB 1: WORKOUT HISTORY =================

  Widget _buildHistoryTab(
    List<WorkoutLog> allLogs,
    List<WorkoutLog> filteredLogs,
    ThemeData theme,
    AppThemeExtension tokens,
  ) {
    final totalVolume = allLogs.fold<double>(0.0, (acc, item) => acc + item.totalVolumeKg);
    final totalCompletedSets = allLogs.fold<int>(0, (acc, item) => acc + item.completedSets);

    if (allLogs.isEmpty) {
      return EmptyStateWidget(
        customGraphic: GymBroIcon(
          icon: GymBroDashboardIconType.exerciseHistory,
          size: 48,
          active: true,
          activeColor: tokens.lime,
        ),
        title: 'هنوز جلسه تمرینی ثبت نشده است',
        subtitle:
            'پس از به پایان رساندن جلسات تمرینی در حالت متمرکز، تمام آمار تناژ و ست‌های شما در این بخش نمایش داده خواهد شد.',
        actionLabel: 'بازگشت به برنامه',
        onAction: () => Navigator.pop(context),
      );
    }

    final hasLogs = filteredLogs.isNotEmpty;
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: 1 + (hasLogs ? filteredLogs.length : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Statistics Card (Required by Phase 4 and QA tests)
              Container(
                padding: AppSpacing.paddingBase,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: tokens.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GymBroIcon(
                          icon: GymBroDashboardIconType.achievements,
                          size: 22,
                          active: true,
                          activeColor: tokens.gold,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'خلاصه فعالیت‌های ثبت‌شده',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            title: 'تعداد جلسات',
                            value: '${PersianUtils.toPersianDigits(allLogs.length)} جلسه',
                            valueColor: tokens.lime,
                            theme: theme,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: tokens.borderColor,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            title: 'مجموع تناژ',
                            value: '${PersianUtils.toPersianDigits(totalVolume.toInt())} kg',
                            valueColor: tokens.cyan,
                            theme: theme,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: tokens.borderColor,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            title: 'ست‌های ثبت‌شده',
                            value: '${PersianUtils.toPersianDigits(totalCompletedSets)} ست',
                            valueColor: tokens.gold,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // 2. Search & Filter Bar (Reference Image 1 style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.baseRadius,
                  border: Border.all(color: tokens.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: tokens.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'جستجو در نام جلسه یا حرکات...',
                          hintStyle: TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 12.5),
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _searchQuery = ''),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Filter Pills: All, Gym, Home
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeFilterChip('همه جلسات', 'all', tokens),
                    const SizedBox(width: 6),
                    _buildTypeFilterChip('تمرین باشگاه', 'gym', tokens),
                    const SizedBox(width: 6),
                    _buildTypeFilterChip('تمرین در خانه', 'home', tokens),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              Text(
                'جلسات اخیر',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (!hasLogs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'موردی منطبق با جستجو یافت نشد.',
                      style: TextStyle(color: tokens.textMuted, fontSize: 12),
                    ),
                  ),
                ),
            ],
          );
        }

        final log = filteredLogs[index - 1];
        return _buildLogCard(log, theme, tokens);
      },
    );
  }

  Widget _buildTypeFilterChip(String label, String value, AppThemeExtension tokens) {
    final isSelected = _filterType == value;
    return InkWell(
      onTap: () => setState(() => _filterType = value),
      borderRadius: AppRadii.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? tokens.lime : tokens.cardElevated,
          borderRadius: AppRadii.roundedPill,
          border: Border.all(
            color: isSelected ? tokens.lime : tokens.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : tokens.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color valueColor,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(
    WorkoutLog log,
    ThemeData theme,
    AppThemeExtension tokens,
  ) {
    final isExpanded = _expandedLogIds.contains(log.id);

    // Group sets by exercise name
    final groupedSets = <String, List<WorkoutSetLog>>{};
    for (var s in log.sets) {
      groupedSets.putIfAbsent(s.exerciseName, () => []).add(s);
    }

    // Find best set in session (highest weight)
    WorkoutSetLog? bestSet;
    for (var s in log.sets) {
      if (bestSet == null || s.weightKg > bestSet.weightKg) {
        bestSet = s;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleExpand(log.id),
            borderRadius: AppRadii.roundedMd,
            child: Padding(
              padding: AppSpacing.paddingBase,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          log.planTitle.isNotEmpty
                              ? log.planTitle
                              : 'جلسه تمرینی آزاد',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AppRadii.roundedSm,
                          border: Border.all(color: tokens.borderColor),
                        ),
                        child: Text(
                          log.date.isNotEmpty
                              ? PersianUtils.toPersianDigits(log.date)
                              : 'امروز',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Metrics Badges Row
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xxs,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GymBroIcon(
                                    icon: GymBroDashboardIconType.workout,
                                    size: 16,
                                    active: true,
                                    activeColor: tokens.lime,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'تناژ: ${PersianUtils.toPersianDigits(log.totalVolumeKg.toInt())} kg',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tokens.lime,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 16, color: tokens.cyan),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '${PersianUtils.toPersianDigits(log.completedSets)} ست',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tokens.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GymBroIcon(
                                    icon: GymBroDashboardIconType.timer,
                                    size: 16,
                                    active: true,
                                    activeColor: tokens.gold,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '${PersianUtils.toPersianDigits(log.durationMinutes)} دقیقه',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tokens.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: tokens.textMuted,
                        size: 20,
                      ),
                    ],
                  ),

                  // Best set callout pill (Reference Image 1: "Best set")
                  if (bestSet != null && bestSet.weightKg > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tokens.cardElevated.withOpacity(0.8),
                        borderRadius: AppRadii.xsRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: tokens.gold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'سنگین‌ترین حرکت: ${bestSet.exerciseName} (${PersianUtils.toPersianDigits(bestSet.weightKg.toInt())} کیلوگرم)',
                              style: TextStyle(fontSize: 10, color: tokens.textMuted),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded Breakdown & Actions
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: AppSpacing.paddingBase,
              color: theme.scaffoldBackgroundColor.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (groupedSets.isEmpty)
                    Text(
                      'جزئیات ریز ست‌ها برای این جلسه ثبت نشده است.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    )
                  else ...[
                    ...groupedSets.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.lime,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xxs,
                              children: entry.value.map((s) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.cardElevated,
                                    borderRadius: AppRadii.roundedSm,
                                    border: Border.all(color: tokens.borderColor),
                                  ),
                                  child: Text(
                                    'ست ${PersianUtils.toPersianDigits(s.setNumber)}: ${PersianUtils.toPersianDigits(s.weightKg.toInt())}kg × ${PersianUtils.toPersianDigits(s.reps)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _confirmDeleteLog(log),
                        icon: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error),
                        label: Text('حذف جلسه', style: TextStyle(color: theme.colorScheme.error, fontSize: 11)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _repeatWorkout(log),
                        icon: const Icon(Icons.replay, size: 15),
                        label: const Text('اجرای مجدد تمرین', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.lime,
                          foregroundColor: tokens.textOnLime,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= TAB 2: ADVANCED STATISTICS =================

  Widget _buildStatisticsTab(
    List<WorkoutLog> allLogs,
    ThemeData theme,
    AppThemeExtension tokens,
  ) {
    if (allLogs.isEmpty) {
      return Center(
        child: Text('برای رسم نمودارهای آماری نیاز به ثبت حداقل یک جلسه تمرینی است.',
            style: TextStyle(color: tokens.textMuted, fontSize: 12)),
      );
    }

    final totalWorkouts = allLogs.length;
    final totalDuration = allLogs.fold<int>(0, (acc, item) => acc + item.durationMinutes);
    final totalVolume = allLogs.fold<double>(0.0, (acc, item) => acc + item.totalVolumeKg);
    final totalSets = allLogs.fold<int>(0, (acc, item) => acc + item.completedSets);
    final streakDays = widget.state.userProfile.streakDays;

    // Highest volume in a single session
    double maxVolume = 0.0;
    for (var l in allLogs) {
      if (l.totalVolumeKg > maxVolume) maxVolume = l.totalVolumeKg;
    }

    // Weekly day frequency (Saturday to Friday counts)
    final weeklyActivity = List.filled(7, 0.0);
    for (var l in allLogs) {
      final date = DateTime.fromMillisecondsSinceEpoch(l.timestamp);
      // Map Dart weekday (1=Mon..7=Sun) to Persian week (0=Sat..6=Fri)
      final pIndex = (date.weekday + 1) % 7;
      if (pIndex >= 0 && pIndex < 7) {
        if (_selectedMetric == 'volume') {
          weeklyActivity[pIndex] += l.totalVolumeKg;
        } else if (_selectedMetric == 'sets') {
          weeklyActivity[pIndex] += l.completedSets.toDouble();
        } else {
          // Estimated active calories: ~7 kcal per minute of lifting
          weeklyActivity[pIndex] += (l.durationMinutes * 7.5);
        }
      }
    }

    // Hero Metric value based on selection (Reference Image 2)
    String heroMetricValue;
    String heroMetricLabel;
    if (_selectedMetric == 'volume') {
      heroMetricValue = PersianUtils.toPersianDigits(totalVolume.toInt());
      heroMetricLabel = 'مجموع تناژ جابجا شده (کیلوگرم)';
    } else if (_selectedMetric == 'sets') {
      heroMetricValue = PersianUtils.toPersianDigits(totalSets);
      heroMetricLabel = 'مجموع کل ست‌های تمرین ثبت‌شده';
    } else {
      final totalCals = (totalDuration * 7.5).toInt();
      heroMetricValue = PersianUtils.toPersianDigits(totalCals);
      heroMetricLabel = 'کالری تخمینی سوخته‌شده در تمرینات (kcal)';
    }

    // Personal Records (PRs): max weight logged per exercise
    final prMap = <String, WorkoutSetLog>{};
    for (var l in allLogs) {
      for (var s in l.sets) {
        if (!prMap.containsKey(s.exerciseName) || s.weightKg > prMap[s.exerciseName]!.weightKg) {
          prMap[s.exerciseName] = s;
        }
      }
    }
    final prList = prMap.entries.toList()
      ..sort((a, b) => b.value.weightKg.compareTo(a.value.weightKg));

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // 1. Top Quick Metric Cards (Reference Image 2: "Streak 12 days, Workouts 47")
        Row(
          children: [
            Expanded(
              child: _buildMetricBadgeCard(
                title: 'استمرار تمرینی',
                value: '${PersianUtils.toPersianDigits(streakDays)} روز',
                icon: Icons.directions_run_rounded,
                color: tokens.lime,
                tokens: tokens,
                theme: theme,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMetricBadgeCard(
                title: 'جلسات کل',
                value: '${PersianUtils.toPersianDigits(totalWorkouts)} جلسه',
                icon: Icons.fitness_center_rounded,
                color: tokens.cyan,
                tokens: tokens,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildMetricBadgeCard(
                title: 'مجموع زمان تمرین',
                value: '${PersianUtils.toPersianDigits(totalDuration)} دقیقه',
                icon: Icons.timer_outlined,
                color: tokens.gold,
                tokens: tokens,
                theme: theme,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMetricBadgeCard(
                title: 'بزرگترین رکورد تناژ',
                value: '${PersianUtils.toPersianDigits(maxVolume.toInt())} kg',
                icon: Icons.line_weight_rounded,
                color: tokens.lime,
                tokens: tokens,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // 2. Metric Switcher Pills (Reference Image 2: Calories active, Weight, Volume)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricPill('تناژ (Volume)', 'volume', tokens),
              const SizedBox(width: 8),
              _buildMetricPill('کالری فعال (Calories)', 'calories', tokens),
              const SizedBox(width: 8),
              _buildMetricPill('ست‌ها (Sets)', 'sets', tokens),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // 3. Hero Metric Value Display (Reference Image 2: "2,340")
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: tokens.cardBackground,
            borderRadius: AppRadii.lgRadius,
            border: Border.all(color: tokens.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heroMetricLabel,
                style: TextStyle(fontSize: 11.5, color: tokens.textMuted),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  heroMetricValue,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: tokens.lime,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Vertical 7-Day Activity Bar Chart (Reference Image 2 & 3)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WeeklyBarChartPainter(
                    values: weeklyActivity,
                    barColor: tokens.lime,
                    trackColor: tokens.cardElevated,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // 5. Personal Records (PRs) Leaderboard
        Container(
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
                children: [
                  Icon(Icons.emoji_events_outlined, size: 20, color: tokens.gold),
                  const SizedBox(width: 8),
                  Text(
                    'رکوردهای وزنی شخصی (Personal Records)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              if (prList.isEmpty)
                Text('هنوز رکوردی ثبت نشده است.', style: TextStyle(color: tokens.textMuted, fontSize: 11))
              else
                ...prList.take(6).map((pr) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.smRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pr.key,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.gold.withOpacity(0.15),
                            borderRadius: AppRadii.xsRadius,
                          ),
                          child: Text(
                            '${PersianUtils.toPersianDigits(pr.value.weightKg.toInt())}kg × ${PersianUtils.toPersianDigits(pr.value.reps)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: tokens.gold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildMetricBadgeCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required AppThemeExtension tokens,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.baseRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: tokens.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String title, String metricKey, AppThemeExtension tokens) {
    final isSelected = _selectedMetric == metricKey;
    return InkWell(
      onTap: () => setState(() => _selectedMetric = metricKey),
      borderRadius: AppRadii.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.lime : tokens.cardElevated,
          borderRadius: AppRadii.roundedPill,
          border: Border.all(
            color: isSelected ? tokens.lime : tokens.borderColor,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

/// نمودار میله‌ای عمودی ۷ روز هفته (Reference Image 2 & 3)
class _WeeklyBarChartPainter extends CustomPainter {
  final List<double> values; // 7 values for Sat..Fri
  final Color barColor;
  final Color trackColor;

  _WeeklyBarChartPainter({
    required this.values,
    required this.barColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final days = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    final count = values.length;
    if (count == 0) return;

    final maxVal = values.reduce(math.max);
    final effectiveMax = maxVal > 0 ? maxVal : 1.0;

    final barWidth = (size.width / count) * 0.45;
    final slotWidth = size.width / count;
    final chartHeight = size.height - 24;

    for (int i = 0; i < count; i++) {
      final xCenter = (i * slotWidth) + (slotWidth / 2);
      final valFrac = (values[i] / effectiveMax).clamp(0.05, 1.0);
      final barHeight = chartHeight * valFrac;
      final topY = chartHeight - barHeight;

      // Track background
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter - (barWidth / 2), 0, barWidth, chartHeight),
        const Radius.circular(4),
      );
      final trackPaint = Paint()..color = trackColor.withOpacity(0.4);
      canvas.drawRRect(trackRect, trackPaint);

      // Active bar
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter - (barWidth / 2), topY, barWidth, barHeight),
        const Radius.circular(4),
      );
      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: [barColor, barColor.withOpacity(0.5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(xCenter - (barWidth / 2), topY, barWidth, barHeight));

      canvas.drawRRect(barRect, barPaint);

      // Day Label Text
      final textSpan = TextSpan(
        text: days[i],
        style: TextStyle(
          color: values[i] > 0 ? Colors.white : Colors.white38,
          fontSize: 10,
          fontWeight: values[i] > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(xCenter - (textPainter.width / 2), chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarChartPainter oldDelegate) => true;
}
