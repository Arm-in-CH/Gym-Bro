import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/achievement_model.dart';
import '../widgets/adaptive_container.dart';
import '../core/graphics/graphics.dart';

/// صفحه اختصاصی دست‌آوردهای ورزشی و مدال‌های قهرمانی (Phase 22 - الهام‌گرفته از سیستم مدال‌های Activity Hub)
class AchievementsScreen extends StatefulWidget {
  final AppState state;

  const AchievementsScreen({super.key, required this.state});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementCategory? _selectedCategory;

  void _showAchievementDetail(AchievementItem item) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(
            color: item.isUnlocked ? item.category.primaryColor : tokens.borderColor,
            width: item.isUnlocked ? 1.5 : 1.0,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing badge icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (item.isUnlocked ? item.category.primaryColor : tokens.cardElevated).withOpacity(0.2),
                border: Border.all(
                  color: item.isUnlocked ? item.category.primaryColor : tokens.borderColor,
                  width: 2.0,
                ),
                boxShadow: item.isUnlocked
                    ? [
                        BoxShadow(
                          color: item.category.primaryColor.withOpacity(0.35),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  item.badgeIcon,
                  size: 36,
                  color: item.isUnlocked ? item.category.primaryColor : tokens.textMuted,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Level & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AppRadii.xsRadius,
                  ),
                  child: Text(
                    'سطح ${PersianUtils.toPersianDigits(item.tierLevel)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.category.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: tokens.textMuted, height: 1.4),
            ),
            const SizedBox(height: AppSpacing.md),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: tokens.cardElevated,
                borderRadius: AppRadii.smRadius,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.isUnlocked ? 'وضعیت: آزاد شده' : 'پیشرفت تا آزادسازی:',
                        style: TextStyle(fontSize: 11, color: tokens.textMuted),
                      ),
                      Text(
                        '${PersianUtils.toPersianDigits(item.currentValue)} / ${PersianUtils.toPersianDigits(item.targetValue)} ${item.unit}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: item.isUnlocked ? tokens.lime : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progressFraction,
                      minHeight: 6,
                      backgroundColor: tokens.cardBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.isUnlocked ? tokens.lime : item.category.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              'این دستاورد بر اساس رکوردهای ذخیره‌شده محاسبه می‌شود؛ پاداش سکه‌ای فعال نیست.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('بستن', style: TextStyle(color: tokens.lime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final allAchievements = AchievementItem.computeAllAchievements(widget.state);

    final unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
    final totalCount = allAchievements.length;
    final totalProgress = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    const categories = AchievementCategory.values;
    final filteredCategories = _selectedCategory != null
        ? [_selectedCategory!]
        : categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دست‌آوردها و مدال‌ها'),
      ),
      body: SafeArea(
        child: AdaptiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Achievement Summary Card (Reference Image 3 style)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tokens.cardBackground, tokens.cardElevated],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(color: tokens.gold.withOpacity(0.4)),
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
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tokens.gold.withOpacity(0.2),
                                    border: Border.all(color: tokens.gold),
                                  ),
                                  child: GymBroIcon(
                                    icon: GymBroDashboardIconType.achievements,
                                    size: 24,
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
                                        'مدال‌های قهرمانی جیم‌برو',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${PersianUtils.toPersianDigits(unlockedCount)} از ${PersianUtils.toPersianDigits(totalCount)} دست‌آورد کسب‌شده',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: tokens.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Overall Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalProgress,
                          minHeight: 8,
                          backgroundColor: tokens.cardElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(tokens.gold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryFilterPill(
                        title: 'همه دست‌آوردها',
                        isSelected: _selectedCategory == null,
                        color: tokens.lime,
                        onTap: () => setState(() => _selectedCategory = null),
                        tokens: tokens,
                      ),
                      ...categories.map((cat) {
                        return _buildCategoryFilterPill(
                          title: cat.titleFa.split('(').first.trim(),
                          isSelected: _selectedCategory == cat,
                          color: cat.primaryColor,
                          onTap: () => setState(() => _selectedCategory = cat),
                          tokens: tokens,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Categorized Achievement Groups (Reference Image 3)
                ...filteredCategories.map((cat) {
                  final items = allAchievements
                      .where((a) => a.category == cat)
                      .toList()
                    ..sort((a, b) => a.tierLevel.compareTo(b.tierLevel));

                  return _buildCategorySection(cat, items, tokens, theme);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterPill({
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required AppThemeExtension tokens,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : tokens.cardBackground,
            borderRadius: AppRadii.roundedPill,
            border: Border.all(
              color: isSelected ? color : tokens.borderColor,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : tokens.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    AchievementCategory category,
    List<AchievementItem> items,
    AppThemeExtension tokens,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: tokens.cardBackground,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: tokens.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.primaryColor.withOpacity(0.18),
                ),
                child: Icon(category.icon, size: 16, color: category.primaryColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.titleFa,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 4-Tier Badges Row / Wrap (Reference Image 3: Level 1 to 4)
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 4;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: _buildBadgeItem(item, tokens, theme),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(
    AchievementItem item,
    AppThemeExtension tokens,
    ThemeData theme,
  ) {
    final isUnlocked = item.isUnlocked;
    final primaryColor = item.category.primaryColor;

    return InkWell(
      onTap: () => _showAchievementDetail(item),
      borderRadius: AppRadii.smRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hexagonal / Round Badge Container
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? primaryColor.withOpacity(0.2)
                      : tokens.cardElevated.withOpacity(0.6),
                  border: Border.all(
                    color: isUnlocked ? primaryColor : tokens.borderColor.withOpacity(0.6),
                    width: isUnlocked ? 2.0 : 1.0,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? item.badgeIcon : Icons.lock_outline_rounded,
                    size: 22,
                    color: isUnlocked ? primaryColor : tokens.textMuted.withOpacity(0.6),
                  ),
                ),
              ),

              // Level indicator pill at bottom of icon
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isUnlocked ? primaryColor : tokens.cardBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isUnlocked ? Colors.black26 : tokens.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    PersianUtils.toPersianDigits(item.tierLevel),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : tokens.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? theme.colorScheme.onSurface : tokens.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Subtitle / Target ratio
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isUnlocked
                  ? 'کسب شد'
                  : '${PersianUtils.toPersianDigits(item.currentValue)}/${PersianUtils.toPersianDigits(item.targetValue)}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? tokens.lime : tokens.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
