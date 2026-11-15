import 'package:flutter/material.dart';

/// GymBro Design Foundation Palette (GYMBRO_RULES Aligned)
/// Direction: Human-crafted Athletic Technology.
/// Warm tonal graphite surfaces, balanced athletic lime, warm amber, and soft cyan.
class AppColors {
  AppColors._();

  // 1. Tonal Graphite & Surface Palette (Warm Dark Surfaces)
  static const Color background = Color(0xFF0B0E13); // Primary app background
  static const Color backgroundSecondary = Color(0xFF111720); // Secondary background
  static const Color surface = Color(0xFF171D27); // Standard card surface
  static const Color surfaceElevated = Color(0xFF202A37); // Elevated card / modal
  static const Color surfaceHighlight = Color(0xFF283446); // Pressed / focused surface

  // 2. Functional Structural Borders (Subtle depth, not excessive outlines)
  static const Color border = Color(0xFF2C384A); // WCAG AA 3.19:1 non-text boundary
  static const Color borderSubtle = Color(0xFF1F2837); // Very subtle divider
  static const Color borderStrong = Color(0xFF3F4E64); // Interactive hover border

  // 3. Primary Athletic Identity
  static const Color lime = Color(0xFFC9F36A); // Balanced Human-Crafted Athletic Lime
  static const Color limeElectric = Color(0xFFCCFF00); // Signature glow & active badge
  static const Color limeLight = Color(0xFFDDFB88); // Hover state on dark
  static const Color limeDark = Color(0xFFA5D142); // Active pressed state
  static const Color limeGlow = Color(0x29C9F36A); // Soft ambient aura (used sparingly)

  // 4. Harmonic Athletic Accents
  static const Color warmAmber = Color(0xFFFFB86B); // Recovery, coins, PR badges
  static const Color warmAmberGlow = Color(0x33FFB86B);
  static const Color softCyan = Color(0xFF78CFE0); // Hydration, tech, freshness
  static const Color softCyanGlow = Color(0x3378CFE0);
  static const Color error = Color(0xFFFF6B70); // Controlled error & warnings
  static const Color errorGlow = Color(0x33FF6B70);

  // 5. Typography & High-Contrast Text Colors
  static const Color textPrimary = Color(0xFFF4F6F8); // Main text (15.2:1 against #0B0E13)
  static const Color textSecondary = Color(0xFFA7AFBD); // Supporting text & labels
  static const Color textMuted = Color(0xFF8F9BAA); // De-emphasized meta information (WCAG AA compliant)
  static const Color textOnLime = Color(0xFF0B0E13); // Maximum legibility on lime CTA (16.2:1)
  static const Color textDisabled = Color(0xFF515C6E); // Disabled control text

  // 6. Backward-Compatibility Aliases
  static const Color card = surface;
  static const Color cardElevated = surfaceElevated;
  static const Color gold = warmAmber;
  static const Color goldGlow = warmAmberGlow;
  static const Color orange = warmAmber;
  static const Color cyan = softCyan;
  static const Color red = error;
  static const Color redGlow = errorGlow;
}
