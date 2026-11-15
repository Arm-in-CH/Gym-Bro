import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/user_level.dart';
import '../models/body_analytics_models.dart';
import '../widgets/level_badge.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/bmi_indicator_card.dart';
import '../widgets/charts/weight_progress_chart.dart';
import '../widgets/charts/body_measurements_chart.dart';
import '../widgets/body_muscle_map.dart';
import 'ai_config_screen.dart';
import 'add_measurement_dialog.dart';
import 'edit_profile_dialog.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import '../core/graphics/graphics.dart';

/// Professional User Profile & Body Analytics Screen (Phase 12).
/// Unifies Athlete Identity, 4-Tier Elite Progression, 3D Segmental Scanning,
/// WHO BMI Spectrum, Interactive Progress Charts, and Comprehensive Anthropometric Tracking.
class ProfileScreen extends StatefulWidget {
  final AppState state;

  const ProfileScreen({super.key, required this.state});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(state: widget.state),
    );
  }

  void _showAddMeasurementDialog({bool isFullBody = false}) {
    showDialog(
      context: context,
      builder: (context) => AddMeasurementDialog(
        state: widget.state,
        initialIsFullBody: isFullBody,
      ),
    );
  }

  Future<void> _confirmDeleteWeightRecord(WeightRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appTokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: context.appTokens.borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 22),
            const SizedBox(width: 8),
            const Text('حذف رکورد وزنی', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'آیا از حذف رکورد وزن ${PersianUtils.toPersianDigits(record.weightKg)} کیلوگرم ثبت‌شده در تاریخ ${PersianUtils.formatPersianDate(record.date)} اطمینان دارید؟',
          style: TextStyle(fontSize: 12.5, color: context.appTokens.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('انصراف', style: TextStyle(color: context.appTokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف رکورد'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.state.deleteWeightRecord(record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('رکورد وزنی با موفقیت حذف شد.'),
            backgroundColor: context.appTokens.cardElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteBodyMeasurement(BodyMeasurementRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appTokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: context.appTokens.borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 22),
            const SizedBox(width: 8),
            const Text('حذف اندازه‌گیری بدن', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'آیا از حذف سایزگیری ثبت‌شده در تاریخ ${PersianUtils.formatPersianDate(record.date)} اطمینان دارید؟ این عملیات قابل بازگشت نیست.',
          style: TextStyle(fontSize: 12.5, color: context.appTokens.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('انصراف', style: TextStyle(color: context.appTokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف اندازه‌گیری'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.state.deleteBodyMeasurement(record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('اندازه‌گیری بدن با موفقیت حذف شد.'),
            backgroundColor: context.appTokens.cardElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final profile = widget.state.userProfile;
    final progress = widget.state.levelProgress;
    final currentWeight = widget.state.currentWeightKg;
    final initialWeight = widget.state.initialWeightKg;
    final targetWeight = profile.targetWeightKg;
    final deltaWeight = currentWeight - initialWeight;
    final isLoss = deltaWeight < 0;
    final progressFraction = widget.state.goalProgressFraction;
    final measurements = widget.state.bodyMeasurements;
    final weightLogs = widget.state.weightRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل و جایگاه ورزشی'),
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_events_outlined, color: tokens.gold),
            tooltip: 'دست‌آوردها و مدال‌ها',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AchievementsScreen(state: widget.state)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.lime),
            tooltip: 'تنظیمات برنامه',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(state: widget.state)),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: tokens.cyan),
            tooltip: 'ویرایش مشخصات',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: AdaptiveContainer(
          child: RefreshIndicator(
            color: tokens.lime,
            backgroundColor: tokens.cardElevated,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 250));
              if (mounted) {
                setState(() {});
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile User Identification Card
                  _buildProfileHeaderCard(tokens, theme, profile),
                  const SizedBox(height: AppSpacing.base),

                  // 2. 4-Tier Status Progression System (WCAG AA & textScale resilient)
                  _buildProgressionCard(tokens, theme, profile, progress),
                  const SizedBox(height: AppSpacing.base),

                  // 3. Quick Metrics Overview (Height, Weight, BMI, Goal)
                  _buildQuickMetricsGrid(tokens, theme, profile, currentWeight),
                  const SizedBox(height: AppSpacing.base),

                  // 4. Goal Progress Card (ActiveX Dark Dashboard Style)
                  _buildGoalProgressCard(tokens, theme, profile, currentWeight, targetWeight, deltaWeight, isLoss, progressFraction),
                  const SizedBox(height: AppSpacing.base),

                  // 5. Interactive front / back muscle map
                  BodyMuscleMap(
                    latestMeasurement: widget.state.latestBodyMeasurement,
                    previousMeasurement: measurements.length > 1 ? measurements[1] : null,
                    exercises: widget.state.exercises,
                    onAddMeasurement: () => _showAddMeasurementDialog(isFullBody: true),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 6. Interactive Weight Progress Chart
                  WeightProgressChart(
                    records: weightLogs,
                    targetWeightKg: targetWeight,
                    onAddRecord: () => _showAddMeasurementDialog(isFullBody: false),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 7. WHO 5-Segment BMI Clinical Spectrum Indicator
                  BmiIndicatorCard(
                    bmi: profile.bmi,
                    heightCm: profile.heightCm,
                    weightKg: currentWeight,
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 8. Body Measurements Circumference Trend Chart
                  BodyMeasurementsChart(
                    records: measurements,
                    onAddMeasurement: () => _showAddMeasurementDialog(isFullBody: true),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 9. Measurement & Weight History Log
                  _buildHistoryCard(tokens, theme, measurements, weightLogs),
                  const SizedBox(height: AppSpacing.base),

                  // 10. Coins Wallet Card
                  _buildCoinsCard(tokens, theme),
                  const SizedBox(height: AppSpacing.base),

                  // 11. AI Engine Config Entry
                  _buildAiEngineCard(tokens),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SECTION WIDGETS =================

  Widget _buildProfileHeaderCard(AppThemeExtension tokens, ThemeData theme, dynamic profile) {
    return Container(
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
              ExcludeSemantics(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.lime.withOpacity(0.18),
                    border: Border.all(color: tokens.lime.withOpacity(0.5), width: 1.5),
                  ),
                  child: Center(
                    child: GymBroIcon(
                      icon: GymBroDashboardIconType.profile,
                      size: 34,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          profile.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: tokens.cardElevated,
                            borderRadius: AppRadii.xsRadius,
                          ),
                          child: Text(
                            profile.gender.displayNameFa,
                            style: TextStyle(fontSize: 9.5, color: tokens.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LevelBadge(level: profile.level),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: tokens.lime, size: 20),
                onPressed: _showEditProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Personal Info Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AppRadii.smRadius,
            ),
            child: Column(
              children: [
                _buildInfoRow('هدف اصلی ورزشی:', profile.parsedFitnessGoal.displayNameFa, tokens.lime),
                const Divider(height: 14, color: Colors.white10),
                _buildInfoRow('سطح تجربه بدنسازی:', profile.fitnessLevel, tokens.cyan),
                const Divider(height: 14, color: Colors.white10),
                _buildInfoRow('سطح فعالیت روزانه:', profile.activityLevel.displayNameFa, tokens.gold),
                const Divider(height: 14, color: Colors.white10),
                _buildInfoRow('فرکانس تمرین:', '${PersianUtils.toPersianDigits(profile.preferredTrainingDays)} جلسه در هفته', tokens.lime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionCard(
    AppThemeExtension tokens,
    ThemeData theme,
    dynamic profile,
    LevelProgressInfo progress,
  ) {
    return Container(
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
              GymBroIcon(
                icon: GymBroDashboardIconType.achievements,
                size: 22,
                active: true,
                activeColor: tokens.gold,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'سیستم رتبه و ارتقای سطح (Elite Status)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 4 Tier Pills (resilient to large text scales)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTierPill(context, 'عضو', profile.level == UserLevel.member),
                const SizedBox(width: 8),
                _buildTierPill(context, 'ورزشکار', profile.level == UserLevel.athlete),
                const SizedBox(width: 8),
                _buildTierPill(context, 'حرفه‌ای', profile.level == UserLevel.pro),
                const SizedBox(width: 8),
                _buildTierPill(context, 'نخبه', profile.level == UserLevel.elite, isElite: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ClipRRect(
            borderRadius: AppRadii.xsRadius,
            child: LinearProgressIndicator(
              value: progress.progressFraction,
              minHeight: 8,
              backgroundColor: tokens.cardElevated,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.gold),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            progress.requirementDescriptionFa,
            style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AchievementsScreen(state: widget.state),
                  ),
                );
              },
              borderRadius: AppRadii.xsRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مشاهده همه مدال‌ها و دست‌آوردها',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tokens.gold),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_left_rounded, size: 16, color: tokens.gold),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierPill(BuildContext context, String name, bool isActive, {bool isElite = false}) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    Color bg;
    Color border;

    if (isActive) {
      bg = isElite ? tokens.gold : tokens.lime;
      border = bg;
    } else {
      bg = tokens.cardElevated;
      border = tokens.borderColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.xsRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            const Icon(Icons.check, size: 14, color: Colors.black),
            const SizedBox(width: 4),
          ],
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetricsGrid(
    AppThemeExtension tokens,
    ThemeData theme,
    dynamic profile,
    double currentWeight,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'وزن کنونی',
                value: PersianUtils.toPersianDigits(currentWeight.toStringAsFixed(1)),
                unit: 'kg',
                color: tokens.lime,
                icon: Icons.scale,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMetricTile(
                title: 'قد کاربر',
                value: PersianUtils.toPersianDigits(profile.heightCm.toInt()),
                unit: 'cm',
                color: tokens.cyan,
                icon: Icons.height,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'شاخص BMI',
                value: PersianUtils.toPersianDigits(profile.bmi.toStringAsFixed(1)),
                unit: profile.bmiCategory.displayNameFa,
                color: profile.bmiCategory.color,
                icon: Icons.speed,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildMetricTile(
                title: 'هدف ورزشی',
                value: profile.parsedFitnessGoal.displayNameFa,
                unit: '',
                color: tokens.gold,
                icon: Icons.flag,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.smRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
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
                  child: Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 3),
                        Text(
                          unit,
                          style: TextStyle(fontSize: 9, color: tokens.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(
    AppThemeExtension tokens,
    ThemeData theme,
    dynamic profile,
    double currentWeight,
    double targetWeight,
    double deltaWeight,
    bool isLoss,
    double? progressFraction,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.cardBackground, tokens.cardElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.lime.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.lime.withOpacity(0.2),
                        border: Border.all(color: tokens.lime),
                      ),
                      child: Center(
                        child: GymBroIcon(
                          icon: GymBroDashboardIconType.goals,
                          size: 20,
                          active: true,
                          activeColor: tokens.lime,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هدف وزنی: ${PersianUtils.toPersianDigits(targetWeight)} کیلوگرم',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            profile.parsedFitnessGoal.displayNameFa,
                            style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${PersianUtils.toPersianDigits(currentWeight.toStringAsFixed(1))} کیلوگرم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: tokens.lime,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    '${isLoss ? "↓" : (deltaWeight > 0 ? "↑" : "")} ${PersianUtils.toPersianDigits(deltaWeight.abs().toStringAsFixed(1))} کیلوگرم از ابتدا',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLoss ? tokens.lime : (deltaWeight > 0 ? tokens.gold : tokens.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Goal Progress Bar
          if (progressFraction != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'پیشرفت به سمت وزن هدف:',
                    style: TextStyle(fontSize: 11, color: tokens.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${PersianUtils.toPersianDigits((progressFraction * 100).toInt())}% محقق شده',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tokens.lime),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 8,
                backgroundColor: const Color(0xFF0A0D14),
                valueColor: AlwaysStoppedAnimation<Color>(tokens.lime),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    AppThemeExtension tokens,
    ThemeData theme,
    List<BodyMeasurementRecord> measurements,
    List<WeightRecord> weightLogs,
  ) {
    final profile = widget.state.userProfile;
    return Container(
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
                child: Row(
                  children: [
                    GymBroIcon(
                      icon: GymBroDashboardIconType.exerciseHistory,
                      size: 20,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تاریخچه و پرونده اندازه‌گیری‌ها',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddMeasurementDialog(isFullBody: true),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('ثبت جدید', style: TextStyle(fontSize: 11.5)),
                style: TextButton.styleFrom(foregroundColor: tokens.lime),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (measurements.isEmpty && weightLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('هنوز رکوردی ثبت نشده است.', style: TextStyle(color: tokens.textMuted, fontSize: 12)),
              ),
            )
          else ...[
            Text('آخرین سایزگیری‌های جامع:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tokens.textMuted)),
            const SizedBox(height: 6),
            ...measurements.take(3).map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.smRadius,
                  border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          PersianUtils.formatPersianDate(m.date),
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: tokens.lime),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16, color: Theme.of(context).colorScheme.error.withOpacity(0.8)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmDeleteBodyMeasurement(m),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (m.waistCm != null) _buildHistoryChip('کمر:', '${PersianUtils.toPersianDigits(m.waistCm)} سانتی‌متر', tokens.cyan),
                        if (m.chestCm != null) _buildHistoryChip('سینه:', '${PersianUtils.toPersianDigits(m.chestCm)} سانتی‌متر', tokens.lime),
                        if (m.rightArmCm != null) _buildHistoryChip('بازو:', '${PersianUtils.toPersianDigits(m.rightArmCm)} سانتی‌متر', tokens.gold),
                        if (m.hipCm != null) _buildHistoryChip('باسن:', '${PersianUtils.toPersianDigits(m.hipCm)} سانتی‌متر', tokens.textMuted),
                        if (m.thighCm != null) _buildHistoryChip('ران:', '${PersianUtils.toPersianDigits(m.thighCm)} سانتی‌متر', tokens.textMuted),
                        if (m.bodyFatPercentage != null) _buildHistoryChip('چربی:', PersianUtils.formatPercentage(m.bodyFatPercentage), tokens.orange),
                      ],
                    ),
                    if (m.note != null && m.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(m.note!, style: TextStyle(fontSize: 10.5, color: tokens.textMuted.withOpacity(0.7), fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.sm),
            Text('آخرین وزن‌کشی‌های ثبت‌شده:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tokens.textMuted)),
            const SizedBox(height: 8),
            ...weightLogs.reversed.take(5).map((w) {
              return _buildWeightHistoryItem(context, w, weightLogs, profile, tokens, theme);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightHistoryItem(
    BuildContext context,
    WeightRecord w,
    List<WeightRecord> allWeightLogs,
    dynamic profile,
    AppThemeExtension tokens,
    ThemeData theme,
  ) {
    final originalIndex = allWeightLogs.indexOf(w);
    final previousRecord = originalIndex > 0 ? allWeightLogs[originalIndex - 1] : null;
    final delta = previousRecord != null ? (w.weightKg - previousRecord.weightKg) : null;

    final heightM = profile.heightCm / 100.0;
    final recordBmi = heightM > 0 ? (w.weightKg / (heightM * heightM)) : profile.bmi;
    final recordCategory = BmiCategory.fromBmi(recordBmi);

    // Trend points leading to or around this record
    final trendValues = allWeightLogs.take(originalIndex + 1).map((e) => e.weightKg).toList();
    final recentPoints = trendValues.length > 5 ? trendValues.sublist(trendValues.length - 5) : trendValues;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AppRadii.smRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          // Weight Value & Subtitle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${PersianUtils.toPersianDigits(w.weightKg.toStringAsFixed(1))} کیلوگرم',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: tokens.lime,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (delta != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (delta < 0 ? tokens.lime : tokens.gold).withOpacity(0.14),
                          borderRadius: AppRadii.xsRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              delta < 0 ? Icons.trending_down : Icons.trending_up,
                              size: 13,
                              color: delta < 0 ? tokens.lime : tokens.gold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${delta < 0 ? "" : "+"}${PersianUtils.toPersianDigits(delta.toStringAsFixed(1))} کیلوگرم',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: delta < 0 ? tokens.lime : tokens.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.cardBackground,
                          borderRadius: AppRadii.xsRadius,
                        ),
                        child: Text(
                          'نقطه مبدأ',
                          style: TextStyle(fontSize: 9.5, color: tokens.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 11, color: tokens.textMuted),
                    Text(
                      PersianUtils.formatPersianDate(w.date),
                      style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                    ),
                    Text('•', style: TextStyle(color: tokens.textMuted, fontSize: 10)),
                    Text(
                      recordCategory.displayNameFa,
                      style: TextStyle(fontSize: 10.5, color: recordCategory.color, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (w.note != null && w.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    w.note!,
                    style: TextStyle(fontSize: 10, color: tokens.textMuted.withOpacity(0.8), fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Mini sparkline trend matching design reference
          if (recentPoints.length >= 2) ...[
            SizedBox(
              width: 52,
              height: 26,
              child: CustomPaint(
                painter: _MiniSparklinePainter(
                  values: recentPoints,
                  lineColor: tokens.lime,
                  glowColor: tokens.lime,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error.withOpacity(0.8)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'حذف رکورد',
            onPressed: () => _confirmDeleteWeightRecord(w),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String label, String value, Color color) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
          TextSpan(text: PersianUtils.toPersianDigits(value), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCoinsCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.gold.withOpacity(0.18),
            ),
            child: GymBroIcon(
              icon: GymBroDashboardIconType.personalRecord,
              size: 22,
              active: true,
              activeColor: tokens.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اعتبار نمایشی جیم‌برو',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'موجودی نمونه: ${PersianUtils.toPersianDigits(widget.state.userProfile.coins)} سکه',
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              'خرید و دریافت جایزه در این نسخه فعال نیست.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: tokens.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiEngineCard(AppThemeExtension tokens) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GymBroIcon(
                  icon: GymBroNavIconType.aiCoach,
                  size: 24,
                  active: true,
                  activeColor: tokens.lime,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('موتور هوش مصنوعی مربی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('تنظیمات Gemini و OpenRouter', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiConfigScreen(state: widget.state)),
              );
            },
            style: OutlinedButton.styleFrom(side: BorderSide(color: tokens.lime)),
            child: Text('تنظیمات AI', style: TextStyle(color: tokens.lime, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valColor) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
        Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: valColor)),
      ],
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color glowColor;

  _MiniSparklinePainter({
    required this.values,
    required this.lineColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = (maxVal - minVal).abs();
    final effectiveRange = range < 0.1 ? 1.0 : range;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minVal) / effectiveRange;
      final y = size.height - (normalized * (size.height - 8)) - 4;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [glowColor.withOpacity(0.35), glowColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(path, linePaint);

    // End point indicator
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(points.last, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) => true;
}
