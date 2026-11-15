import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  // =========================================================================
  // TYPOGRAPHY (Material Design 3 TextTheme Scale)
  // =========================================================================

  static TextTheme _buildTextTheme(
      Color primaryText, Color secondaryText, Color mutedText) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryText,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: primaryText,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: secondaryText,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mutedText,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryText,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: mutedText,
      ),
    );
  }

  // =========================================================================
  // DARK THEME (Production Athletic Pitch-Black)
  // =========================================================================

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.textOnLime,
      secondary: AppColors.gold,
      onSecondary: AppColors.textOnLime,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainer: AppColors.card,
      surfaceContainerHigh: AppColors.cardElevated,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
      error: AppColors.red,
      onError: Colors.white,
    );

    final textTheme = _buildTextTheme(
      AppColors.textPrimary,
      AppColors.textSecondary,
      AppColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Vazirmatn',
      fontFamilyFallback: const ['Vazirmatn', 'Tahoma', 'Arial', 'sans-serif'],
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.lime,
      focusColor: AppColors.lime.withOpacity(0.35),
      colorScheme: colorScheme,
      textTheme: textTheme,
      cardTheme: const CardTheme(
        color: AppColors.card,
        elevation: AppElevations.level0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: AppElevations.level0,
        scrolledUnderElevation: AppElevations.level0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.lime.withOpacity(0.18),
        indicatorShape: const StadiumBorder(),
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lime, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.lime,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.textOnLime,
          elevation: AppElevations.level0,
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          textStyle:
              textTheme.labelLarge?.copyWith(color: AppColors.textOnLime),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lime,
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: AppColors.lime, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: AppColors.red),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.card,
        elevation: AppElevations.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        elevation: AppElevations.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetRadius),
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: AppColors.lime,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.lime,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.normal),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardElevated,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.lime,
        labelStyle: textTheme.labelMedium ?? const TextStyle(fontSize: 12),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.textOnLime) ??
                const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
        side: const BorderSide(color: AppColors.border),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.textOnLime,
        elevation: AppElevations.level2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedBase),
      ),
      extensions: const [
        AppThemeExtension.dark,
      ],
    );
  }

  // =========================================================================
  // LIGHT THEME (Clean High-Contrast Studio)
  // =========================================================================

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: Color(
          0xFF4C6600), // Deep athletic olive (5.2:1 contrast against light)
      onPrimary: Colors.white,
      secondary: Color(0xFF8C6200),
      onSecondary: Colors.white,
      surface: Color(0xFFF8F9FA),
      onSurface: Color(0xFF191C1E),
      surfaceContainer: Color(0xFFFFFFFF),
      surfaceContainerHigh: Color(0xFFF0F2F5),
      outline: Color(0xFF74777F),
      outlineVariant: Color(0xFFC4C7D0),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
    );

    final textTheme = _buildTextTheme(
      const Color(0xFF191C1E),
      const Color(0xFF44474E),
      const Color(0xFF55606E),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Vazirmatn',
      fontFamilyFallback: const ['Vazirmatn', 'Tahoma', 'Arial', 'sans-serif'],
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      primaryColor: const Color(0xFF4C6600),
      focusColor: const Color(0xFF4C6600).withOpacity(0.25),
      colorScheme: colorScheme,
      textTheme: textTheme,
      cardTheme: const CardTheme(
        color: Color(0xFFFFFFFF),
        elevation: AppElevations.level1,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: AppElevations.level0,
        scrolledUnderElevation: AppElevations.level1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: Color(0xFF191C1E), size: 24),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        indicatorColor: const Color(0xFF4C6600).withOpacity(0.15),
        indicatorShape: const StadiumBorder(),
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF4C6600), size: 24);
          }
          return const IconThemeData(color: Color(0xFF74777F), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFF4C6600),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: Color(0xFF74777F),
            fontWeight: FontWeight.normal,
            fontSize: 12,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C6600),
          foregroundColor: Colors.white,
          elevation: AppElevations.level1,
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF191C1E),
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          side: const BorderSide(color: Color(0xFFC4C7D0)),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4C6600),
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: const Color(0xFF74777F)),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: const Color(0xFF44474E)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: Color(0xFFC4C7D0)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: Color(0xFFC4C7D0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.roundedMd,
          borderSide: BorderSide(color: Color(0xFF4C6600), width: 1.5),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: AppElevations.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: AppElevations.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetRadius),
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: const Color(0xFF4C6600),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF4C6600),
        unselectedLabelColor: const Color(0xFF74777F),
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.normal),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF191C1E),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F2F5),
        selectedColor: const Color(0xFF4C6600),
        labelStyle: textTheme.labelMedium ?? const TextStyle(fontSize: 12),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white) ??
                const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
        side: const BorderSide(color: Color(0xFFC4C7D0)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4C6600),
        foregroundColor: Colors.white,
        elevation: AppElevations.level2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedBase),
      ),
      extensions: const [
        AppThemeExtension.light,
      ],
    );
  }
}
