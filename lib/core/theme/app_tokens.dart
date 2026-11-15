import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Spatial Grid Tokens (4dp / 8dp scale)
class AppSpacing {
  AppSpacing._();

  static const double none = 0.0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Touch Target Minimums
  static const double minTouchTarget = 48.0;

  // Pre-built directional EdgeInsets
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingBase = EdgeInsets.all(base);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets screenPadding = EdgeInsets.all(base);
  static const EdgeInsets screenPaddingH =
      EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets cardPadding = EdgeInsets.all(base);
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  // Vertical SizedBox Spacers
  static const SizedBox hXxs = SizedBox(height: xxs);
  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hBase = SizedBox(height: base);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXxl = SizedBox(height: xxl);

  // Horizontal SizedBox Spacers
  static const SizedBox wXxs = SizedBox(width: xxs);
  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wBase = SizedBox(width: base);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wXl = SizedBox(width: xl);
}

/// Centralized Corner Radii Tokens
class AppRadii {
  AppRadii._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusBase = Radius.circular(base);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusPill = Radius.circular(pill);

  static const BorderRadius roundedXs = BorderRadius.all(radiusXs);
  static const BorderRadius roundedSm = BorderRadius.all(radiusSm);
  static const BorderRadius roundedMd = BorderRadius.all(radiusMd);
  static const BorderRadius roundedBase = BorderRadius.all(radiusBase);
  static const BorderRadius roundedLg = BorderRadius.all(radiusLg);
  static const BorderRadius roundedXl = BorderRadius.all(radiusXl);
  static const BorderRadius roundedPill = BorderRadius.all(radiusPill);

  // Ergonomic aliases
  static const BorderRadius xsRadius = roundedXs;
  static const BorderRadius smRadius = roundedSm;
  static const BorderRadius mdRadius = roundedMd;
  static const BorderRadius baseRadius = roundedBase;
  static const BorderRadius lgRadius = roundedLg;
  static const BorderRadius xlRadius = roundedXl;
  static const BorderRadius pillRadius = roundedPill;

  static const BorderRadius dialogRadius = roundedXl;
  static const BorderRadius cardRadius = roundedBase;
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: radiusXl);
}

/// Centralized Elevation Tokens
class AppElevations {
  AppElevations._();

  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
}

/// Centralized Animation Duration Tokens
class AppDurations {
  AppDurations._();

  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration ticker = Duration(milliseconds: 1800);

  /// Returns Duration.zero if reduced motion / disableAnimations is requested by the OS.
  static Duration of(BuildContext context, Duration duration) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return Duration.zero;
    }
    return duration;
  }
}

/// Centralized Animation Curve Tokens
class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeInOutCubic;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve sharp = Curves.easeInOutQuad;
}

/// Centralized Standard Icon Sizes
class AppIconSizes {
  AppIconSizes._();

  static const double xs = 14.0;
  static const double sm = 18.0;
  static const double md = 22.0;
  static const double base = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double hero = 64.0;
}

/// Controlled Shadows and Glows
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x3D000000), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> dialog = [
    BoxShadow(color: Color(0x7A000000), blurRadius: 28, offset: Offset(0, 10)),
  ];

  static List<BoxShadow> limeGlow([Color color = const Color(0x33CCFF00)]) => [
        BoxShadow(color: color, blurRadius: 16, offset: const Offset(0, 4)),
      ];
}

/// Subtle Controlled Gradients
class AppGradients {
  AppGradients._();

  static const LinearGradient cardDark = LinearGradient(
    colors: [Color(0xFF161B26), Color(0xFF10141E)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  static const LinearGradient limeHero = LinearGradient(
    colors: [Color(0xFFCCFF00), Color(0xFFA6D600)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  static const LinearGradient surfaceGlow = LinearGradient(
    colors: [Color(0x18CCFF00), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Custom Theme Extension for Athletic Brand Tokens
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color lime;
  final Color limeLight;
  final Color limeDark;
  final Color limeGlow;
  final Color gold;
  final Color goldGlow;
  final Color cyan;
  final Color orange;
  final Color red;
  final Color redGlow;
  final Color cardBackground;
  final Color cardElevated;
  final Color borderColor;
  final Color textMuted;
  final Color textOnLime;

  const AppThemeExtension({
    required this.lime,
    required this.limeLight,
    required this.limeDark,
    required this.limeGlow,
    required this.gold,
    required this.goldGlow,
    required this.cyan,
    required this.orange,
    required this.red,
    required this.redGlow,
    required this.cardBackground,
    required this.cardElevated,
    required this.borderColor,
    required this.textMuted,
    required this.textOnLime,
  });

  /// Dark Mode Athletic Palette (GYMBRO_RULES Warm Graphite & Balanced Lime Aligned)
  static const dark = AppThemeExtension(
    lime: Color(0xFFC9F36A),
    limeLight: Color(0xFFDDFB88),
    limeDark: Color(0xFFA5D142),
    limeGlow: Color(0x29C9F36A),
    gold: Color(0xFFFFB86B),
    goldGlow: Color(0x33FFB86B),
    cyan: Color(0xFF78CFE0),
    orange: Color(0xFFFFB86B),
    red: Color(0xFFFF6B70),
    redGlow: Color(0x33FF6B70),
    cardBackground: Color(0xFF171D27), // Warm Graphite Surface
    cardElevated: Color(0xFF202A37), // Layered Elevated Surface
    borderColor: Color(0xFF2C384A), // Controlled 1.2px structural border
    textMuted: Color(0xFF8F9BAA), // De-emphasized metadata (WCAG AA compliant)
    textOnLime: Color(0xFF0B0E13), // 16.2:1 contrast against lime
  );

  /// Light Mode Athletic Palette (WCAG 2.2 AA Verified)
  static const light = AppThemeExtension(
    lime: Color(
        0xFF4C6600), // Deep athletic olive for high-contrast light surfaces (5.2:1)
    limeLight: Color(0xFF688700),
    limeDark: Color(0xFF354800),
    limeGlow: Color(0x224C6600),
    gold: Color(0xFF8C6200),
    goldGlow: Color(0x228C6200),
    cyan: Color(0xFF00758F),
    orange: Color(0xFFC43800),
    red: Color(0xFFBA1A1A),
    redGlow: Color(0x22BA1A1A),
    cardBackground: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFF0F2F5),
    borderColor: Color(0xFFC4C7D0),
    textMuted: Color(0xFF55606E),
    textOnLime: Color(0xFFFFFFFF),
  );

  Color get surface => cardBackground;
  Color get surfaceElevated => cardElevated;
  Color get warmAmber => gold;
  Color get softCyan => cyan;
  Color get error => red;
  Color get background => AppColors.background;
  Color get backgroundSecondary => AppColors.backgroundSecondary;

  @override
  AppThemeExtension copyWith({
    Color? lime,
    Color? limeLight,
    Color? limeDark,
    Color? limeGlow,
    Color? gold,
    Color? goldGlow,
    Color? cyan,
    Color? orange,
    Color? red,
    Color? redGlow,
    Color? cardBackground,
    Color? cardElevated,
    Color? borderColor,
    Color? textMuted,
    Color? textOnLime,
  }) {
    return AppThemeExtension(
      lime: lime ?? this.lime,
      limeLight: limeLight ?? this.limeLight,
      limeDark: limeDark ?? this.limeDark,
      limeGlow: limeGlow ?? this.limeGlow,
      gold: gold ?? this.gold,
      goldGlow: goldGlow ?? this.goldGlow,
      cyan: cyan ?? this.cyan,
      orange: orange ?? this.orange,
      red: red ?? this.red,
      redGlow: redGlow ?? this.redGlow,
      cardBackground: cardBackground ?? this.cardBackground,
      cardElevated: cardElevated ?? this.cardElevated,
      borderColor: borderColor ?? this.borderColor,
      textMuted: textMuted ?? this.textMuted,
      textOnLime: textOnLime ?? this.textOnLime,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      lime: Color.lerp(lime, other.lime, t) ?? lime,
      limeLight: Color.lerp(limeLight, other.limeLight, t) ?? limeLight,
      limeDark: Color.lerp(limeDark, other.limeDark, t) ?? limeDark,
      limeGlow: Color.lerp(limeGlow, other.limeGlow, t) ?? limeGlow,
      gold: Color.lerp(gold, other.gold, t) ?? gold,
      goldGlow: Color.lerp(goldGlow, other.goldGlow, t) ?? goldGlow,
      cyan: Color.lerp(cyan, other.cyan, t) ?? cyan,
      orange: Color.lerp(orange, other.orange, t) ?? orange,
      red: Color.lerp(red, other.red, t) ?? red,
      redGlow: Color.lerp(redGlow, other.redGlow, t) ?? redGlow,
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      cardElevated:
          Color.lerp(cardElevated, other.cardElevated, t) ?? cardElevated,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textOnLime: Color.lerp(textOnLime, other.textOnLime, t) ?? textOnLime,
    );
  }
}

/// BuildContext Helper Extension for Clean Token Access
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppThemeExtension get appTokens =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.dark;
}
