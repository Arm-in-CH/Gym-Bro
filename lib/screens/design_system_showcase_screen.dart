import 'package:flutter/material.dart';
import '../core/localization/persian_utils.dart';
import '../widgets/common/gymbro_design_system.dart';

/// Visual Demonstration & Design Foundation Showcase for GymBro (Phase 1)
/// Demonstrates tokens, typography, button hierarchy, inputs, surfaces, and Persian RTL flow.
class DesignSystemShowcaseScreen extends StatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  State<DesignSystemShowcaseScreen> createState() => _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState extends State<DesignSystemShowcaseScreen> {
  int _selectedFilterIndex = 0;
  bool _isLoadingPrimary = false;
  final TextEditingController _textController = TextEditingController(text: '۸۵٫۵');

  final List<String> _filters = const ['همه تمرینات', 'سینه و پشت', 'پا و شکم', 'هوازی'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: const Text('پایه‌ریزی سیستم طراحی جیم‌برو'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GymBroBrandLogo(size: 32, withGlow: true),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Philosophy & Token Description Banner
              _buildPhilosophyBanner(tokens),
              AppSpacing.hLg,

              // 2. Color Palette & Tonal Surfaces Section
              const GymBroSectionHeader(
                title: 'پالت رنگی و سطوح گرم گرافیت',
                subtitle: 'استفاده از سطوح لایه‌بندی‌شده به جای مشکی مطلق (Rulebook)',
              ),
              AppSpacing.hSm,
              _buildColorPalette(tokens),
              AppSpacing.hLg,

              // 3. Typographic Hierarchy Section
              const GymBroSectionHeader(
                title: 'سلسله‌مراتب تایپوگرافی (وزیرمتن)',
                subtitle: 'تنوع وزن‌های قلم متناسب با نقش اطلاعات بدون پررنگی مفرط',
              ),
              AppSpacing.hSm,
              _buildTypographyShowcase(context, tokens),
              AppSpacing.hLg,

              // 4. Button Hierarchy & Interactive States
              const GymBroSectionHeader(
                title: 'سلسله‌مراتب دکمه‌ها و تعامل لمسی',
                subtitle: 'مقیاس لمسی ۹۸٪، ابعاد استاندارد حداقل ۴۸dp و کنترل درخشش',
              ),
              AppSpacing.hSm,
              _buildButtonsShowcase(tokens),
              AppSpacing.hLg,

              // 5. Input Fields & RTL Validation
              const GymBroSectionHeader(
                title: 'فیلدهای ورودی و سازگاری با ارقام فارسی',
                subtitle: 'وضعیت‌های پیش‌فرض، فوکوس، خطا و غیرفعال با جهت‌گیری بومی RTL',
              ),
              AppSpacing.hSm,
              _buildInputsShowcase(tokens),
              AppSpacing.hLg,

              // 6. Surface Treatments & Card Diversity
              const GymBroSectionHeader(
                title: 'تنوع سطوح و ساختار کارت‌ها',
                subtitle: 'ترکیب‌بندی اختصاصی برای هر وظیفه و جلوگیری از کارت‌های یکنواخت',
              ),
              AppSpacing.hSm,
              _buildSurfacesShowcase(tokens, theme),
              AppSpacing.hXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhilosophyBanner(AppThemeExtension tokens) {
    return GymBroHeroCard(
      content: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.lime.withOpacity(0.15),
              borderRadius: AppRadii.mdRadius,
            ),
            child: Icon(Icons.palette_outlined, color: tokens.lime, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Human-crafted Athletic Technology',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: tokens.lime,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'زبان بصری متمایز، رنگ لایم کنترل‌شده، سطوح گرافیت و تعامل دقیق لمسی.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: tokens.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette(AppThemeExtension tokens) {
    final colors = [
      {'name': 'Background', 'hex': '#0B0E13', 'color': AppColors.background},
      {'name': 'Secondary', 'hex': '#111720', 'color': AppColors.backgroundSecondary},
      {'name': 'Surface', 'hex': '#171D27', 'color': AppColors.surface},
      {'name': 'Elevated', 'hex': '#202A37', 'color': AppColors.surfaceElevated},
      {'name': 'Primary Lime', 'hex': '#C9F36A', 'color': AppColors.lime, 'isDark': true},
      {'name': 'Warm Amber', 'hex': '#FFB86B', 'color': AppColors.warmAmber, 'isDark': true},
      {'name': 'Soft Cyan', 'hex': '#78CFE0', 'color': AppColors.softCyan, 'isDark': true},
      {'name': 'Error', 'hex': '#FF6B70', 'color': AppColors.error},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: colors.map((c) {
        final color = c['color'] as Color;
        final name = c['name'] as String;
        final hex = c['hex'] as String;
        final isDarkText = c['isDark'] == true;

        return Container(
          width: 105,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.mdRadius,
            border: Border.all(color: tokens.borderColor.withOpacity(0.3), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDarkText ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hex,
                style: TextStyle(
                  fontSize: 9.5,
                  fontFamily: 'monospace',
                  color: isDarkText ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypographyShowcase(BuildContext context, AppThemeExtension tokens) {
    return GymBroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Display Large', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              Text('۳۲sp • w800', style: TextStyle(fontSize: 10, color: tokens.textMuted, fontFamily: 'monospace')),
            ],
          ),
          Text('باشگاه هوشمند جیم‌برو', style: AppTypography.displayLarge(context)),
          const Divider(height: 24, thickness: 0.8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Page Title', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              Text('۱۸sp • w700', style: TextStyle(fontSize: 10, color: tokens.textMuted, fontFamily: 'monospace')),
            ],
          ),
          Text('برنامه تمرینی قدرتی سینه و پشت', style: AppTypography.pageTitle(context)),
          const Divider(height: 24, thickness: 0.8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Metric Numeric Value', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              Text('۲۶sp • Monospace', style: TextStyle(fontSize: 10, color: tokens.textMuted, fontFamily: 'monospace')),
            ],
          ),
          Row(
            children: [
              Text(
                PersianUtils.toPersianDigits('2,850'),
                style: AppTypography.metricValue(context, size: 26, color: tokens.lime),
              ),
              const SizedBox(width: 6),
              Text('کیلوگرم تناژ جابجاشده', style: AppTypography.metricUnit(context)),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body Text', style: TextStyle(fontSize: 11, color: tokens.textMuted)),
              Text('۱۳.۵sp • Regular', style: TextStyle(fontSize: 10, color: tokens.textMuted, fontFamily: 'monospace')),
            ],
          ),
          Text(
            'تمرکز روی بخش منفی حرکت به مدت ۲ ثانیه، حفظ انقباض پیک در اوج دامنه و رعایت زمان استراحت ۹۰ ثانیه‌ای.',
            style: AppTypography.body(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsShowcase(AppThemeExtension tokens) {
    return Column(
      children: [
        // Primary Button with Loading Toggle
        GymBroPrimaryButton(
          text: _isLoadingPrimary ? 'در حال همگام‌سازی...' : 'شروع جلسه تمرین امروز',
          isLoading: _isLoadingPrimary,
          prefixIcon: const Icon(Icons.play_arrow_rounded, size: 20),
          onPressed: () {
            setState(() => _isLoadingPrimary = true);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isLoadingPrimary = false);
            });
          },
        ),
        AppSpacing.hSm,

        // Secondary & Outline Buttons Row
        Row(
          children: [
            Expanded(
              child: GymBroSecondaryButton(
                text: 'ویرایش برنامه',
                isFullWidth: true,
                prefixIcon: const Icon(Icons.tune_rounded, size: 18),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GymBroOutlineButton(
                text: 'افزودن ست جدید',
                icon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () {},
              ),
            ),
          ],
        ),
        AppSpacing.hSm,

        // Ghost Button & Tactile Icon Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GymBroGhostButton(
              text: 'انصراف و لغو تغییرات',
              icon: const Icon(Icons.close_rounded, size: 16),
              onPressed: () {},
            ),
            Row(
              children: [
                GymBroIconButton(
                  icon: Icon(Icons.volume_up_outlined, color: tokens.lime, size: 20),
                  tooltip: 'صدای تایمر',
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.sm),
                GymBroIconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  tooltip: 'اشتراک‌گذاری',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        AppSpacing.hSm,

        // Pill Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: GymBroPillFilter(
                  label: _filters[i],
                  isSelected: _selectedFilterIndex == i,
                  onTap: () => setState(() => _selectedFilterIndex = i),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInputsShowcase(AppThemeExtension tokens) {
    return Column(
      children: [
        GymBroTextField(
          label: 'وزن ناشتای صبحگاهی (کیلوگرم)',
          hintText: 'مثال: ۸۴٫۵',
          controller: _textController,
          prefixIcon: Icon(Icons.monitor_weight_outlined, color: tokens.lime, size: 20),
          suffixIcon: Text('kg', style: TextStyle(color: tokens.textMuted, fontWeight: FontWeight.bold)),
        ),
        AppSpacing.hSm,
        const GymBroTextField(
          label: 'تکرار مورد نظر',
          hintText: 'مثال: ۱۲',
          errorText: 'تعداد تکرار باید بین ۱ تا ۱۰۰ باشد',
          prefixIcon: Icon(Icons.fitness_center_rounded, size: 20),
        ),
        AppSpacing.hSm,
        const GymBroTextField(
          label: 'فیلد غیرفعال (قفل شده)',
          hintText: 'عضویت طلایی فعال نیست',
          enabled: false,
          prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
        ),
      ],
    );
  }

  Widget _buildSurfacesShowcase(AppThemeExtension tokens, ThemeData theme) {
    return Column(
      children: [
        // Metric Cards Row
        Row(
          children: [
            Expanded(
              child: GymBroMetricCard(
                title: 'کالری فعال',
                value: PersianUtils.toPersianDigits('824'),
                unit: 'kcal',
                delta: '+12%',
                icon: Icon(Icons.local_fire_department_rounded, color: tokens.warmAmber, size: 18),
                accentColor: tokens.warmAmber,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GymBroMetricCard(
                title: 'ضربان قلب',
                value: PersianUtils.toPersianDigits('123'),
                unit: 'bpm',
                delta: 'نرمال',
                icon: Icon(Icons.favorite_rounded, color: tokens.softCyan, size: 18),
                accentColor: tokens.softCyan,
              ),
            ),
          ],
        ),
        AppSpacing.hSm,

        // Layered Elevated Card
        GymBroElevatedCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'PPL',
                    style: TextStyle(
                      color: tokens.lime,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سطح کارت برجسته (Elevated Surface #202A37)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'عمق بصری با سایه کنترل‌شده و مرز ۱ پیکسلی بدون نئون شدید.',
                      style: TextStyle(fontSize: 11, color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
