import 'package:flutter/material.dart';
import '../../core/localization/persian_utils.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/graphics/graphics.dart';
import '../../models/user_profile.dart';
import '../../models/user_level.dart';
import '../level_badge.dart';

class DashboardHeader extends StatelessWidget {
  final UserProfile? profile;
  final AppThemeExtension tokens;
  final VoidCallback onOpenAiCoach;
  final VoidCallback? onOpenProfile;

  const DashboardHeader({
    super.key,
    required this.profile,
    required this.tokens,
    required this.onOpenAiCoach,
    this.onOpenProfile,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صبح بخیر';
    } else if (hour >= 12 && hour < 17) {
      return 'ظهر بخیر';
    } else if (hour >= 17 && hour < 21) {
      return 'عصر بخیر';
    } else {
      return 'شب بخیر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final persianDate = PersianUtils.formatPersianDate(now);

    final avatarWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenProfile,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tokens.lime.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: tokens.lime.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/app_logo_small.png',
            semanticLabel: 'لوگوی برنامه جیم‌برو - رفتن به پروفایل کاربری',
            width: 48,
            height: 48,
            cacheWidth: 96,
            cacheHeight: 96,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ExcludeSemantics(
              child: Container(
                color: tokens.cardElevated,
                child: const GymBroBrandLogo(
                  size: 48,
                  withGlow: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final String firstName = profile?.firstName ?? '';
    final String greetingTitle = firstName.trim().isNotEmpty
        ? '$greeting، $firstName عزیز'
        : '$greeting، ورزشکار عزیز';
    final int streakDays = profile?.streakDays ?? 0;
    final int coins = profile?.coins ?? 0;
    final UserLevel level = profile?.level ?? UserLevel.athlete;

    final streakPill = Semantics(
      label: 'روزهای استمرار',
      value: '${PersianUtils.toPersianDigits(streakDays)} روز',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'استمرار شما: ${PersianUtils.toPersianDigits(streakDays)} روز متوالی بدون وقفه!',
              ),
              backgroundColor: tokens.cardElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.cardElevated,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: tokens.lime.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 16, color: Color(0xFFFF5722)),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${PersianUtils.toPersianDigits(streakDays)} روز',
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final coinsPill = Semantics(
      label: 'اعتبار نمایشی',
      value: '${PersianUtils.toPersianDigits(coins)} سکه نمونه',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'موجودی نمایشی: ${PersianUtils.toPersianDigits(coins)} سکه. خرید و جایزه در این نسخه فعال نیست.',
              ),
              backgroundColor: tokens.cardElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.cardElevated,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: tokens.gold.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GymBroIcon(
                icon: GymBroDashboardIconType.personalRecord,
                size: 15,
                active: true,
                activeColor: tokens.gold,
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${PersianUtils.toPersianDigits(coins)} سکه',
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Anti-truncation logic for RTL:
        // When width < 420 (most phones in portrait mode), stack the user profile row
        // and metric pills so greetingTitle gets 100% width and never truncates!
        final isCompact = constraints.maxWidth < 420;

        final userProfileSection = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatarWidget,
            AppSpacing.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greetingTitle,
                    style: AppTypography.sectionTitle(context).copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      LevelBadge(level: level),
                      Text(
                        'امروز $persianDate',
                        style: AppTypography.caption(context).copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              userProfileSection,
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 6,
                children: [
                  streakPill,
                  coinsPill,
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: userProfileSection),
            AppSpacing.wSm,
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                streakPill,
                coinsPill,
              ],
            ),
          ],
        );
      },
    );
  }
}
