import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/timer_settings.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/level_badge.dart';
import 'edit_profile_dialog.dart';
import 'ai_config_screen.dart';
import 'design_system_showcase_screen.dart';
import '../core/graphics/graphics.dart';

/// صفحه تنظیمات جامع و پیکربندی شخصی‌سازی جیم‌برو (Phase 22 - Settings Redesign)
class SettingsScreen extends StatefulWidget {
  final AppState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyWorkoutReminder = true;
  bool _waterHydrationReminder = true;

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(state: widget.state),
    ).then((_) => setState(() {}));
  }

  Future<void> _updateTimer({
    int? defaultRestSeconds,
    bool? autoStartTimer,
    bool? soundAlerts,
    bool? vibrationAlerts,
  }) async {
    final current = widget.state.timerSettings;
    final updated = current.copyWith(
      defaultRestSeconds: defaultRestSeconds,
      autoStartTimer: autoStartTimer,
      soundAlerts: soundAlerts,
      vibrationAlerts: vibrationAlerts,
    );
    await widget.state.updateTimerSettings(updated);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmResetHistory() async {
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
            Icon(Icons.warning_amber_rounded, color: Theme.of(ctx).colorScheme.error, size: 24),
            const SizedBox(width: 8),
            const Text('هشدار بازنشانی تاریخچه', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'آیا از حذف تمام سوابق و تاریخچه جلسات تمرینی اطمینان دارید؟ این عملیات قابل بازگشت نیست.',
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
            child: const Text('بله، حذف تاریخچه'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final logs = List.from(widget.state.workoutLogs);
      for (final log in logs) {
        await widget.state.deleteWorkoutHistoryLog(log.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تاریخچه جلسات تمرین پاکسازی شد.'),
            backgroundColor: context.appTokens.cardElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {});
      }
    }
  }

  void _showDataExportDialog() {
    final tokens = context.appTokens;
    final totalSessions = widget.state.workoutLogs.length;
    final totalMeals = widget.state.calorieLogs.length;
    final totalWeights = widget.state.weightRecords.length;
    final totalSizes = widget.state.bodyMeasurements.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: tokens.borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.dataset_outlined, color: tokens.lime, size: 22),
            const SizedBox(width: 8),
            const Text('شناسنامه پرونده ورزشی', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExportRow('تعداد جلسات تمرینی ثبت‌شده:', '$totalSessions جلسه', tokens.lime),
            const SizedBox(height: 8),
            _buildExportRow('تعداد وعده‌های غذایی ثبت‌شده:', '$totalMeals وعده', tokens.cyan),
            const SizedBox(height: 8),
            _buildExportRow('تعداد رکوردهای وزنی:', '$totalWeights رکورد', tokens.gold),
            const SizedBox(height: 8),
            _buildExportRow('تعداد سایزگیری‌های جامع:', '$totalSizes سایزگیری', tokens.lime),
            const SizedBox(height: 12),
            Text(
              'تمام اطلاعات شما بر روی حافظه داخلی دستگاه شما به صورت Offline-First ذخیره شده و هیچ داده‌ای به سرور خارجی ارسال نمی‌گردد.',
              style: TextStyle(fontSize: 11, color: tokens.textMuted, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.lime,
              foregroundColor: tokens.textOnLime,
            ),
            child: const Text('تایید و بازگشت'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
        Text(PersianUtils.toPersianDigits(value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final profile = widget.state.userProfile;
    final timer = widget.state.timerSettings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات و ترجیحات'),
      ),
      body: SafeArea(
        child: AdaptiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Athlete Header Tile (Reference Image 1)
                _buildProfileSummaryCard(tokens, theme, profile),
                const SizedBox(height: AppSpacing.base),

                // 2. Timer & Rest Preferences
                _buildSectionHeader('تنظیمات تایمر استراحت بین ست‌ها', Icons.timer_outlined, tokens),
                const SizedBox(height: 8),
                _buildTimerCard(tokens, theme, timer),
                const SizedBox(height: AppSpacing.base),

                // 3. Notifications & Reminders
                _buildSectionHeader('اعلان‌ها و یادآورهای هوشمند', Icons.notifications_outlined, tokens),
                const SizedBox(height: 8),
                _buildNotificationsCard(tokens, theme),
                const SizedBox(height: AppSpacing.base),

                // 4. Appearance & Language
                _buildSectionHeader('ظاهر، پوسته و زبان', Icons.palette_outlined, tokens),
                const SizedBox(height: 8),
                _buildAppearanceCard(tokens, theme),
                const SizedBox(height: AppSpacing.base),

                // 5. AI Coach Engine Integration
                _buildSectionHeader('موتور هوش مصنوعی مربی', Icons.psychology_outlined, tokens),
                const SizedBox(height: 8),
                _buildAiEngineCard(tokens, theme),
                const SizedBox(height: AppSpacing.base),

                // 6. Data Management & Storage
                _buildSectionHeader('مدیریت داده‌ها و پشتیبان‌گیری', Icons.storage_rounded, tokens),
                const SizedBox(height: 8),
                _buildDataCard(tokens, theme),
                const SizedBox(height: AppSpacing.base),

                // 7. About GymBro
                _buildAboutCard(tokens, theme),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, AppThemeExtension tokens) {
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.lime),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(AppThemeExtension tokens, ThemeData theme, dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.lime.withOpacity(0.18),
              border: Border.all(color: tokens.lime, width: 1.5),
            ),
            child: Center(
              child: GymBroIcon(
                icon: GymBroDashboardIconType.profile,
                size: 28,
                active: true,
                activeColor: tokens.lime,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isNotEmpty ? profile.fullName : 'ورزشکار جیم‌برو',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: TextStyle(fontSize: 11, color: tokens.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                LevelBadge(level: profile.level),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: tokens.lime, size: 20),
            tooltip: 'ویرایش مشخصات',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(AppThemeExtension tokens, ThemeData theme, TimerSettings timer) {
    final restDurations = [30, 45, 60, 90, 120, 180];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'زمان پیش‌فرض استراحت بین هر ست:',
            style: TextStyle(fontSize: 11.5, color: tokens.textMuted),
          ),
          const SizedBox(height: 8),

          // Preset pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: restDurations.map((sec) {
                final isSelected = timer.defaultRestSeconds == sec;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => _updateTimer(defaultRestSeconds: sec),
                    borderRadius: AppRadii.smRadius,
                    child: Semantics(
                      label: PersianUtils.formatSeconds(sec),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? tokens.lime : tokens.cardElevated,
                          borderRadius: AppRadii.smRadius,
                          border: Border.all(
                            color: isSelected ? tokens.lime : tokens.borderColor,
                          ),
                        ),
                        child: Text(
                          '${PersianUtils.toPersianDigits(sec)}s',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : tokens.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: Colors.white10),

          // Switch: Auto Start Timer
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('شروع خودکار تایمر استراحت', style: TextStyle(fontSize: 12.5)),
            subtitle: Text('بلافاصله پس از تایید هر ست تمرینی', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
            value: timer.autoStartTimer,
            activeColor: tokens.lime,
            onChanged: (val) => _updateTimer(autoStartTimer: val),
          ),

          // Switch: Sound Alerts
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('هشدار صوتی و بوق پایان زمان', style: TextStyle(fontSize: 12.5)),
            subtitle: Text('پخش زنگ در ۳ ثانیه پایانی استراحت', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
            value: timer.soundAlerts,
            activeColor: tokens.lime,
            onChanged: (val) => _updateTimer(soundAlerts: val),
          ),

          // Switch: Vibration Alerts
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('لرزش گوشی هنگام پایان تایمر', style: TextStyle(fontSize: 12.5)),
            subtitle: Text('ویبره حسی برای آگاهی در باشگاه', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
            value: timer.vibrationAlerts,
            activeColor: tokens.lime,
            onChanged: (val) => _updateTimer(vibrationAlerts: val),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('یادآور روزانه برنامه تمرینی', style: TextStyle(fontSize: 12.5)),
            subtitle: Text('اعلان در ساعت مقرر تمرینات ورزشی', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
            value: _dailyWorkoutReminder,
            activeColor: tokens.lime,
            onChanged: (val) => setState(() => _dailyWorkoutReminder = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('یادآور هوشمند نوشیدن آب', style: TextStyle(fontSize: 12.5)),
            subtitle: Text('هشدار هیدراتاسیون در فواصل زمانی معین', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
            value: _waterHydrationReminder,
            activeColor: tokens.lime,
            onChanged: (val) => setState(() => _waterHydrationReminder = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('پوسته و تم گرافیکی', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  Text('طراحی نئون دارک اختصاصی مسابقات', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.xsRadius,
                  border: Border.all(color: tokens.lime.withOpacity(0.5)),
                ),
                child: Text('دارک نئون (Dark)', style: TextStyle(fontSize: 11, color: tokens.lime, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('زبان و نگارش برنامه', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  Text('راست‌چین (RTL) با ارقام فارسی', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AppRadii.xsRadius,
                ),
                child: Text('فارسی (Persian)', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DesignSystemShowcaseScreen()),
              );
            },
            borderRadius: AppRadii.mdRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: tokens.lime, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نمایشگاه سیستم طراحی جیم‌برو',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: tokens.lime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'بررسی توکن‌های رنگ، تایپوگرافی وزیرمتن و دکمه‌ها',
                          style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_left_rounded, color: tokens.lime, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiEngineCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('پیکربندی کلیدهای مربی هوشمند', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                Text('تنظیم مدل‌های Gemini 1.5 و OpenRouter', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiConfigScreen(state: widget.state)),
              );
            },
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('تنظیمات AI', style: TextStyle(fontSize: 11.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.cardElevated,
              foregroundColor: tokens.lime,
              side: BorderSide(color: tokens.lime.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('شناسنامه و وضعیت ذخیره‌سازی داده‌ها', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    Text('مشاهده ریز اطلاعات ذخیره‌شده بر روی دستگاه', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _showDataExportDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.cyan,
                  side: BorderSide(color: tokens.cyan.withOpacity(0.5)),
                ),
                child: const Text('مشاهده وضعیت', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('پاکسازی تاریخچه تمرینات', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                    Text('حذف رکوردهای جلسات پیشین تمرینی', style: TextStyle(fontSize: 10.5, color: tokens.textMuted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _confirmResetHistory,
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                child: const Text('حذف تاریخچه', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(AppThemeExtension tokens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withOpacity(0.5),
        borderRadius: AppRadii.baseRadius,
        border: Border.all(color: tokens.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 24, color: tokens.lime),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'جیم‌برو (GymBro Pro) – نگارش ۱.۰.۰ رسمی',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'دستیار تخصصی بدنسازی، تمرینات هدفمند و تغذیه هوشمند',
                  style: TextStyle(fontSize: 10.5, color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
