import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';

class MealRecommendationItem {
  final String category;
  final String titleFa;
  final String descriptionFa;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final IconData icon;
  final Color accentColor;

  const MealRecommendationItem({
    required this.category,
    required this.titleFa,
    required this.descriptionFa,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.icon,
    required this.accentColor,
  });
}

class NutritionRecommendationCard extends StatefulWidget {
  final VoidCallback? onLogMeal;

  const NutritionRecommendationCard({
    super.key,
    this.onLogMeal,
  });

  @override
  State<NutritionRecommendationCard> createState() =>
      _NutritionRecommendationCardState();
}

class _NutritionRecommendationCardState
    extends State<NutritionRecommendationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _selectedCategoryIndex = 0;

  static const List<String> _categories = [
    'صبحانه',
    'ناهار',
    'عصرانه ورزشی',
    'شام',
    'میان‌وعده',
  ];

  static const Map<String, List<MealRecommendationItem>> _recommendations = {
    'صبحانه': [
      MealRecommendationItem(
        category: 'صبحانه',
        titleFa: 'تست پروتئینی و تخم‌مرغ آبپز',
        descriptionFa:
            '۲ عدد نان تست پروتئینی، ۱ عدد تخم‌مرغ کامل، ۲ قاشق کره بادام‌زمینی، ۱ گردو و قهوه تلخ',
        calories: 420,
        proteinG: 26,
        carbsG: 34,
        fatG: 18,
        icon: Icons.egg_alt_outlined,
        accentColor: Color(0xFFC9F36A),
      ),
      MealRecommendationItem(
        category: 'صبحانه',
        titleFa: 'املت اسفناج و سفیده تخم‌مرغ',
        descriptionFa:
            '۲ تست پروتئینی، ۱ تخم‌مرغ کامل به همراه یک سفیده، قارچ، گوجه و دانه چیا',
        calories: 380,
        proteinG: 30,
        carbsG: 28,
        fatG: 14,
        icon: Icons.breakfast_dining_outlined,
        accentColor: Color(0xFF00E5FF),
      ),
    ],
    'ناهار': [
      MealRecommendationItem(
        category: 'ناهار',
        titleFa: 'کته با فیله مرغ گریل شده',
        descriptionFa:
            '۱۰ قاشق برنج کته قهوه‌ای یا سفید، ۱۵۰ گرم سینه مرغ گریل، ماست ایسلندی و سالاد فصل',
        calories: 620,
        proteinG: 48,
        carbsG: 62,
        fatG: 12,
        icon: Icons.restaurant_outlined,
        accentColor: Color(0xFFC9F36A),
      ),
      MealRecommendationItem(
        category: 'ناهار',
        titleFa: 'ماهی گریل و ماست ایسلندی',
        descriptionFa:
            '۱۰ قاشق برنج، ۱۵۰ گرم فیله ماهی قزل‌آلا، سبزیجات بخارپز و کپسول امگا-۳',
        calories: 580,
        proteinG: 44,
        carbsG: 55,
        fatG: 15,
        icon: Icons.set_meal_outlined,
        accentColor: Color(0xFFFFB800),
      ),
    ],
    'عصرانه ورزشی': [
      MealRecommendationItem(
        category: 'عصرانه ورزشی',
        titleFa: 'شیک وی و کراتین پس از تمرین',
        descriptionFa:
            '۱ اسکوپ پروتئین Whey ایزوله همراه با ۵ گرم کراتین مونوهیدرات در ۳۰۰ میلی‌لیتر آب',
        calories: 160,
        proteinG: 27,
        carbsG: 4,
        fatG: 2,
        icon: Icons.fitness_center_outlined,
        accentColor: Color(0xFF00E5FF),
      ),
      MealRecommendationItem(
        category: 'عصرانه ورزشی',
        titleFa: 'پیش‌تمرین: تست پنیر و خرما',
        descriptionFa:
            '۲ تست پروتئینی، ۳۰ گرم پنیر کم‌چرب، ۱ عدد گردو، ۲ عدد خرما و یک فنجان قهوه',
        calories: 290,
        proteinG: 16,
        carbsG: 38,
        fatG: 9,
        icon: Icons.bolt_outlined,
        accentColor: Color(0xFFFF9500),
      ),
    ],
    'شام': [
      MealRecommendationItem(
        category: 'شام',
        titleFa: 'استیک فیله گوشت و سیب‌زمینی پخته',
        descriptionFa:
            '۲۰۰ گرم استیک گوشت گوساله یا مرغ، ۱ عدد سیب‌زمینی تنوری، کاهو، گوجه و ۵ زیتون',
        calories: 520,
        proteinG: 46,
        carbsG: 36,
        fatG: 16,
        icon: Icons.dinner_dining_outlined,
        accentColor: Color(0xFFC9F36A),
      ),
      MealRecommendationItem(
        category: 'شام',
        titleFa: 'خوراک عدسی و سالاد فصل',
        descriptionFa:
            'یک کاسه خوراک عدسی غلیظ، ۲ نان تست پروتئینی، روغن زیتون فرابکر و لیموترش',
        calories: 450,
        proteinG: 28,
        carbsG: 58,
        fatG: 10,
        icon: Icons.soup_kitchen_outlined,
        accentColor: Color(0xFF00E5FF),
      ),
    ],
    'میان‌وعده': [
      MealRecommendationItem(
        category: 'میان‌وعده',
        titleFa: 'شیر کم‌چرب و بادام درختی',
        descriptionFa:
            'نصف لیوان شیر کم‌چرب همراه با ۷ عدد بادام خام یا پسته و یک عدد سیب سبز',
        calories: 190,
        proteinG: 9,
        carbsG: 18,
        fatG: 9,
        icon: Icons.local_cafe_outlined,
        accentColor: Color(0xFFFFB800),
      ),
      MealRecommendationItem(
        category: 'میان‌وعده',
        titleFa: 'پروتئین شیر MPC قبل خواب',
        descriptionFa:
            '۱ اسکوپ کازئین یا MPC پروتئین شیر در ۳۰۰ میلی‌لیتر آب برای ریکاوری شبانه عضلات',
        calories: 130,
        proteinG: 25,
        carbsG: 2,
        fatG: 1,
        icon: Icons.bedtime_outlined,
        accentColor: Color(0xFF00E5FF),
      ),
    ],
  };

  int _recommendationSubIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    // Bounded vertical slide inside designated clipping container
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() {
      _selectedCategoryIndex = index;
      _recommendationSubIndex = 0;
    });
    _animController.forward(from: 0.0);
  }

  void _onNextSuggestion() {
    final currentList =
        _recommendations[_categories[_selectedCategoryIndex]] ?? [];
    if (currentList.length <= 1) return;

    setState(() {
      _recommendationSubIndex =
          (_recommendationSubIndex + 1) % currentList.length;
    });
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    final currentCategory = _categories[_selectedCategoryIndex];
    final items = _recommendations[currentCategory] ?? [];
    final activeItem =
        items.isNotEmpty ? items[_recommendationSubIndex % items.length] : null;

    return Semantics(
      container: true,
      label: 'پیشنهادات اختصاصی تغذیه و رژیم ورزشی',
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: AppRadii.roundedLg,
          border: Border.all(color: tokens.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // ClipRRect guarantees that neither child animations nor inner widgets
        // can bleed or draw outside the outer rounded card boundaries.
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header: Title & Subtitle
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.base,
                right: AppSpacing.base,
                top: AppSpacing.base,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tokens.lime.withOpacity(0.18),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(color: tokens.lime.withOpacity(0.35)),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: tokens.lime,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پیشنهاد هوشمند تغذیه ورزشی',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'متناسب با اهداف کالری، تیپ بدنی و برنامه تمرینی شما',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (items.length > 1)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      color: tokens.textMuted,
                      tooltip: 'پیشنهاد بعدی در این وعده',
                      onPressed: _onNextSuggestion,
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Food Category Buttons Bar (Horizontal Scrolling or Wrap with touch bounds >= 48dp)
            SizedBox(
              height: AppSpacing.minTouchTarget,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = index == _selectedCategoryIndex;
                  return Center(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: 'وعده $cat',
                      child: InkWell(
                        onTap: () => _onCategorySelected(index),
                        borderRadius: AppRadii.roundedMd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? tokens.lime : tokens.cardElevated,
                            borderRadius: AppRadii.roundedMd,
                            border: Border.all(
                              color:
                                  isSelected ? tokens.lime : tokens.borderColor,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.bold,
                              color: isSelected
                                  ? tokens.textOnLime
                                  : tokens.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Inner Animated Recommendation Panel with strict clipping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: RepaintBoundary(
                // ClipRRect here ensures the inner animated elements and text
                // cannot bleed outside the inner card panel.
                child: ClipRRect(
                  borderRadius: AppRadii.roundedMd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AppRadii.roundedMd,
                      border: Border.all(color: tokens.borderColor),
                    ),
                    child: activeItem != null
                        ? AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: _buildMealContent(
                                    context,
                                    activeItem,
                                    theme,
                                    tokens,
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox(height: 120),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  Widget _buildMealContent(
    BuildContext context,
    MealRecommendationItem item,
    ThemeData theme,
    AppThemeExtension tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Meal Title & Icon Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.accentColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: item.accentColor.withOpacity(0.4)),
                ),
                child: Icon(
                  item.icon,
                  color: item.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titleFa,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.descriptionFa,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Macros Summary Tags Bar
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildMacroPill(
                label: 'کالری',
                value: '${PersianUtils.toPersianDigits(item.calories)} kcal',
                color: item.accentColor,
                theme: theme,
              ),
              _buildMacroPill(
                label: 'پروتئین',
                value: '${PersianUtils.toPersianDigits(item.proteinG)}g',
                color: tokens.lime,
                theme: theme,
              ),
              _buildMacroPill(
                label: 'کربوهیدرات',
                value: '${PersianUtils.toPersianDigits(item.carbsG)}g',
                color: tokens.cyan,
                theme: theme,
              ),
              _buildMacroPill(
                label: 'چربی',
                value: '${PersianUtils.toPersianDigits(item.fatG)}g',
                color: tokens.gold,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill({
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadii.roundedSm,
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
