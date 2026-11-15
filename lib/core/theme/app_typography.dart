import 'package:flutter/material.dart';

/// Centralized Persian & English Typography System for GymBro Design System
/// Aligned with GYMBRO_RULES: High-contrast athletic hierarchy with massive tabular display numbers
/// matching professional fitness engineering (Nike Training Club, Whoop, Hevy).
class AppTypography {
  AppTypography._();

  static const String fontFaPrimary = 'Vazirmatn';
  static const String fontEnPrimary = 'Roboto';
  static const String fontMonospace = 'monospace';
  static const List<String> fallbackFonts = ['Vazirmatn', 'Tahoma', 'Arial', 'sans-serif'];

  // 1. Athletic Hero Display Figures (Timer countdowns, tonnage readouts, massive calories)
  // Sizes: 40sp to 56sp with FontFeature.tabularFigures()
  static TextStyle athleticHero(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w900,
      fontFamily: fontMonospace,
      fontFamilyFallback: const ['Roboto', 'Courier New', 'monospace'],
      color: baseColor,
      letterSpacing: -1.2,
      height: 1.05,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle athleticLarge(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w800,
      fontFamily: fontMonospace,
      fontFamilyFallback: const ['Roboto', 'Courier New', 'monospace'],
      color: baseColor,
      letterSpacing: -0.8,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle athleticMedium(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      fontFamily: fontMonospace,
      fontFamilyFallback: const ['Roboto', 'Courier New', 'monospace'],
      color: baseColor,
      letterSpacing: -0.5,
      height: 1.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // 2. Display Headings (Hero section titles, score readouts)
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 40,
      fontWeight: FontWeight.w900,
      color: baseColor,
      letterSpacing: -0.8,
      height: 1.15,
    );
  }

  static TextStyle displayMedium(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: baseColor,
      letterSpacing: -0.4,
      height: 1.25,
    );
  }

  // 3. Page & Screen Headings (AppBar titles, Modal titles)
  static TextStyle pageTitle(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: baseColor,
      letterSpacing: -0.2,
      height: 1.3,
    );
  }

  // 4. Section & Card Headings (Card headers, group titles)
  static TextStyle sectionTitle(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: baseColor,
      height: 1.35,
    );
  }

  static TextStyle cardTitle(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: baseColor,
      height: 1.35,
    );
  }

  // 5. Body Text (Descriptions, instructions, workout directives)
  static TextStyle body(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.9);
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      color: baseColor,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: baseColor,
      height: 1.45,
    );
  }

  // 6. Captions & Metadata (Timestamps, micro badges, secondary details)
  static TextStyle caption(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: baseColor,
      height: 1.3,
    );
  }

  // 7. Numeric Statistics & High-Tech Digits (Weights, Reps, Calories, Water)
  static TextStyle metricValue(BuildContext context, {Color? color, double size = 30}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      fontFamily: fontMonospace,
      fontFamilyFallback: const ['Roboto', 'Courier New', 'monospace'],
      color: baseColor,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle metricUnit(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      color: baseColor,
    );
  }

  // 8. Button & Interactive Action Labels
  static TextStyle buttonLabel(BuildContext context, {Color? color, bool isLarge = true}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: isLarge ? 14 : 12.5,
      fontWeight: FontWeight.w700,
      color: baseColor,
      letterSpacing: -0.1,
    );
  }
}
