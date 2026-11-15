import 'package:flutter/material.dart';

/// Centralized Persian & English Typography System for GymBro Design System
/// Aligned with GYMBRO_RULES: Disciplined typographic hierarchy with balanced weights.
class AppTypography {
  AppTypography._();

  static const String fontFaPrimary = 'Vazirmatn';
  static const String fontEnPrimary = 'Roboto';
  static const String fontMonospace = 'monospace';
  static const List<String> fallbackFonts = ['Vazirmatn', 'Tahoma', 'Arial', 'sans-serif'];

  // 1. Display Headings (Hero metrics, stopwatch countdowns, large score readouts)
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: baseColor,
      letterSpacing: -0.6,
      height: 1.2,
    );
  }

  static TextStyle displayMedium(BuildContext context, {Color? color}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontFamily: fontFaPrimary,
      fontFamilyFallback: fallbackFonts,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: baseColor,
      letterSpacing: -0.4,
      height: 1.25,
    );
  }

  // 2. Page & Screen Headings (AppBar titles, Modal titles)
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

  // 3. Section & Card Headings (Card headers, group titles)
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

  // 4. Body Text (Descriptions, instructions, workout directives)
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

  // 5. Captions & Metadata (Timestamps, micro badges, secondary details)
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

  // 6. Numeric Statistics & High-Tech Digits (Weights, Reps, Calories, Water)
  static TextStyle metricValue(BuildContext context, {Color? color, double size = 22}) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      fontFamily: fontMonospace,
      fontFamilyFallback: const ['Courier New', 'monospace'],
      color: baseColor,
      letterSpacing: -0.2,
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

  // 7. Button & Interactive Action Labels
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
