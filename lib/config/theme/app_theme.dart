import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// App theme configuration using comprehensive design system
class AppTheme {
  AppTheme._(); // Private constructor

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.lightOnSurface,
        outline: AppColors.lightOutline,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      // Typography
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: AppSpacing.elevationNone,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: AppSpacing.elevationMedium,
        margin: AppSpacing.horizontalMD.add(AppSpacing.verticalXS),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          textStyle: AppTypography.button,
          elevation: AppSpacing.elevationLow,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonSmallPadding,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppSpacing.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderMedium,
          ),
        ),
        contentPadding: AppSpacing.inputPadding,
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextHint,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationHigh,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.dividerThickness,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray200,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: AppTypography.tag.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        secondaryLabelStyle: AppTypography.tag.copyWith(
          color: AppColors.white,
        ),
        padding: AppSpacing.paddingXS,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCircular,
        ),
      ),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.darkOnSurface,
        outline: AppColors.darkOutline,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      // Typography
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: AppSpacing.elevationNone,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: AppSpacing.elevationMedium,
        margin: AppSpacing.horizontalMD.add(AppSpacing.verticalXS),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          textStyle: AppTypography.button,
          elevation: AppSpacing.elevationLow,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonSmallPadding,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray900,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppSpacing.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderMedium,
          ),
        ),
        contentPadding: AppSpacing.inputPadding,
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextHint,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationHigh,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.dividerThickness,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray800,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: AppTypography.tag.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        secondaryLabelStyle: AppTypography.tag.copyWith(
          color: AppColors.white,
        ),
        padding: AppSpacing.paddingXS,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCircular,
        ),
      ),
    );
  }
}

// Theme mode provider moved to theme_service.dart
