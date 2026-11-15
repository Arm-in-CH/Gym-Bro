import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/app_typography.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/marketplace_models.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/empty_state_widget.dart';

class MarketplaceScreen extends StatefulWidget {
  final AppState state;

  const MarketplaceScreen({super.key, required this.state});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBookingDialog(Trainer trainer) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: tokens.borderColor),
        ),
        title: const Text('رزرو آنلاین در دسترس نیست'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trainer.name,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              trainer.title,
              style: TextStyle(color: tokens.gold, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'تعرفه هر جلسه: ${PersianUtils.formatToman(trainer.hourlyRateToman)}',
              style: TextStyle(
                color: tokens.lime,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'رزرو آنلاین در این نسخه نمونه است. هماهنگی سانس‌ها و ارزیابی فیزیکی با مربی به صورت مستقیم یا از طریق پذیرش باشگاه انجام خواهد گرفت.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.lime,
              foregroundColor: tokens.textOnLime,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.roundedSm,
              ),
            ),
            child: const Text('متوجه شدم',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مجموعه‌های ورزشی و مربیان'),
            Text(
              'فهرست نمونه؛ رزرو و پرداخت آنلاین غیرفعال',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tokens.lime,
          indicatorWeight: 3,
          labelColor: tokens.lime,
          unselectedLabelColor: tokens.textMuted,
          tabs: const [
            Tab(text: 'باشگاه‌های VIP'),
            Tab(text: 'مربیان خصوصی (۱-به-۱)'),
            Tab(text: 'رزروهای من'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGymsTab(context),
          _buildTrainersTab(context),
          _buildBookingsTab(context),
        ],
      ),
    );
  }

  Widget _buildGymsTab(BuildContext context) {
    final tokens = context.appTokens;
    final gyms = widget.state.gyms;

    return AdaptiveContainer(
      child: RefreshIndicator(
        color: tokens.lime,
        backgroundColor: tokens.cardElevated,
        onRefresh: () async {
          await widget.state.refreshData();
        },
        child: gyms.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: EmptyStateWidget(
                    icon: Icons.fitness_center_outlined,
                    title: 'باشگاهی در لیست موجود نیست',
                    subtitle: 'برای به‌روزرسانی صفحه، لیست را به پایین بکشید.',
                    actionLabel: 'تلاش مجدد',
                    onAction: () => widget.state.refreshData(),
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: gyms.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _buildGymCard(context, gyms[index]),
              ),
      ),
    );
  }

  Widget _buildGymCard(BuildContext context, Gym gym) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: tokens.borderColor.withOpacity(0.8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Header / VIP Showcase Banner
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.cardElevated,
                  tokens.cardBackground,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border(
                bottom: BorderSide(color: tokens.borderColor.withOpacity(0.5)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: tokens.lime.withOpacity(0.15),
                          borderRadius: AppRadii.roundedXs,
                        ),
                        child: Icon(Icons.fitness_center_rounded, color: tokens.lime, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          gym.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.lime.withOpacity(0.18),
                    borderRadius: AppRadii.pillRadius,
                    border: Border.all(color: tokens.lime.withOpacity(0.4)),
                  ),
                  child: Text(
                    'VIP CLUB',
                    style: TextStyle(
                      color: tokens.lime,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating and Address Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: Icon(Icons.location_on_outlined,
                                color: tokens.textMuted, size: 14),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              gym.address,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.textMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Semantics(
                      label: 'امتیاز باشگاه',
                      value:
                          '${PersianUtils.toPersianDigits(gym.rating.toString())} از ۵ ستاره',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.gold.withOpacity(0.14),
                          borderRadius: AppRadii.roundedXs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: Icon(Icons.star_rounded, color: tokens.gold, size: 14),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              PersianUtils.toPersianDigits(gym.rating.toString()),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.gold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Amenities Badges (Clean capsules without repetitive icons)
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: gym.amenities.take(3).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: tokens.cardElevated.withOpacity(0.8),
                        borderRadius: AppRadii.roundedSm,
                        border: Border.all(color: tokens.borderColor.withOpacity(0.6)),
                      ),
                      child: Text(
                        amenity,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Tuition / Monthly Fee Showcase with Bold Athletic Typography
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'شهریه ماهانه (نمونه):',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          PersianUtils.formatToman(gym.monthlyFeeToman),
                          style: AppTypography.athleticLarge(context).copyWith(
                            fontSize: 16,
                            color: tokens.lime,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'مبلغ نمونه؛ پرداخت آنلاین فعال نیست',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Action Button (Maintains exact strings for backward compatibility)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: tokens.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgRadius,
                          side: BorderSide(color: tokens.borderColor),
                        ),
                        title: const Text('عضویت آنلاین در دسترس نیست'),
                        content: Text(
                          'این فهرست و قیمت‌ها نمونه‌اند. رزرو سانس، بررسی ظرفیت و پرداخت در این نسخه انجام نمی‌شود و ثبت‌نام به صورت حضوری در پذیرش باشگاه صورت می‌پذیرد.',
                          style: TextStyle(
                            fontSize: 13,
                            color: tokens.textMuted,
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.lime,
                              foregroundColor: tokens.textOnLime,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.roundedSm,
                              ),
                            ),
                            child: const Text('متوجه شدم', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    icon: Icon(Icons.check_circle_outline, size: 15, color: tokens.textOnLime),
                    label: Text(
                      'عضویت آنلاین در دسترس نیست',
                      style: TextStyle(color: tokens.textOnLime, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.lime,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildTrainersTab(BuildContext context) {
    final tokens = context.appTokens;
    final trainers = widget.state.trainers;

    return AdaptiveContainer(
      child: RefreshIndicator(
        color: tokens.lime,
        backgroundColor: tokens.cardElevated,
        onRefresh: () async {
          await widget.state.refreshData();
        },
        child: trainers.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: EmptyStateWidget(
                    icon: Icons.person_off_outlined,
                    title: 'مربی فعالی یافت نشد',
                    subtitle:
                        'ارتباط با سرور مربیان را بررسی کنید و دوباره تلاش نمایید.',
                    actionLabel: 'تلاش مجدد',
                    onAction: () => widget.state.refreshData(),
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: trainers.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _buildTrainerCard(context, trainers[index]),
              ),
      ),
    );
  }

  Widget _buildTrainerCard(BuildContext context, Trainer trainer) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: tokens.borderColor.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.cardElevated,
                    border: Border.all(color: tokens.lime.withOpacity(0.5), width: 1.5),
                  ),
                  child: Center(
                    child: Icon(Icons.sports_gymnastics_rounded, color: tokens.lime, size: 24),
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
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          trainer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.lime.withOpacity(0.15),
                            borderRadius: AppRadii.xsRadius,
                          ),
                          child: Text(
                            'مربی خصوصی ۱-به-۱',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.lime,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trainer.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'امتیاز مربی',
                value:
                    '${PersianUtils.toPersianDigits(trainer.rating.toString())} از ۵ ستاره',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.gold.withOpacity(0.14),
                    borderRadius: AppRadii.roundedXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(Icons.star_rounded, color: tokens.gold, size: 15),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        PersianUtils.toPersianDigits(trainer.rating.toString()),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            trainer.bio,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Hourly Rate Showcase with Athletic Bold Numbers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: tokens.cardElevated.withOpacity(0.5),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعرفه هر جلسه (نمونه):',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        PersianUtils.formatToman(trainer.hourlyRateToman),
                        style: AppTypography.athleticLarge(context).copyWith(
                          fontSize: 18,
                          color: tokens.lime,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showBookingDialog(trainer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.lime,
                    foregroundColor: tokens.textOnLime,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.smRadius),
                  ),
                  child: const Text('بررسی امکان رزرو', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context) {
    final tokens = context.appTokens;
    final bookings = widget.state.bookings;

    return AdaptiveContainer(
      child: RefreshIndicator(
        color: tokens.lime,
        backgroundColor: tokens.cardElevated,
        onRefresh: () async {
          await widget.state.refreshData();
        },
        child: bookings.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 420,
                  child: EmptyStateWidget(
                    icon: Icons.calendar_month_outlined,
                    title: 'هنوز نوبت فعالی ثبت نکرده‌اید',
                    subtitle:
                      'رزرو آنلاین در این نسخه فعال نیست. می‌توانید فهرست مربیان را برای آشنایی مرور کنید.',
                    actionLabel: 'مشاهده لیست مربیان',
                    onAction: () => _tabController.animateTo(1),
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: bookings.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final theme = Theme.of(context);

                  Color statusColor;
                  IconData statusIcon;
                  switch (b.status) {
                    case BookingStatus.pending:
                      statusColor = tokens.gold;
                      statusIcon = Icons.hourglass_empty;
                      break;
                    case BookingStatus.confirmed:
                      statusColor = tokens.cyan;
                      statusIcon = Icons.event_available;
                      break;
                    case BookingStatus.completed:
                      statusColor = tokens.lime;
                      statusIcon = Icons.check_circle_outline;
                      break;
                    case BookingStatus.cancelled:
                      statusColor = tokens.red;
                      statusIcon = Icons.cancel_outlined;
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: tokens.cardBackground,
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(color: tokens.borderColor.withOpacity(0.8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Text(
                              'جلسه با ${b.trainerName}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Semantics(
                              label: 'وضعیت رزرو',
                              value: b.status.displayNameFa,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.18),
                                  borderRadius: AppRadii.smRadius,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ExcludeSemantics(
                                      child: Icon(statusIcon,
                                          size: 12, color: statusColor),
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    Text(
                                      b.status.displayNameFa,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'زمان: ${b.date} (${b.timeSlot}) • نوع: ${b.sessionType}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'تعرفه نمونه: ${PersianUtils.formatToman(b.priceToman)} · پرداختی ثبت نشده',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'این سابقه فقط روی دستگاه ذخیره شده و از مربی یا درگاه پرداخت تأیید نشده است.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.gold,
                          ),
                        ),

                        // State Transitions
                        if (b.status == BookingStatus.pending) ...[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: tokens.cyan,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('تأیید آنلاین در دسترس نیست'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: tokens.red),
                                  ),
                                  child: Text('لغو آنلاین در دسترس نیست',
                                      style: TextStyle(color: tokens.red)),
                                ),
                              ),
                            ],
                          ),
                        ] else if (b.status == BookingStatus.confirmed) ...[
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.lime,
                                foregroundColor: tokens.textOnLime,
                              ),
                              child: const Text('ثبت آنلاین در دسترس نیست'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
