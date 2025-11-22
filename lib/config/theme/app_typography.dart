import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application typography system
class AppTypography {
  AppTypography._(); // Private constructor

  // Font families
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilySecondary = 'Poppins';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWidest = 1.0;

  // Display text styles
  static TextStyle displayLarge({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 57,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 45,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle displaySmall({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 36,
        fontWeight: bold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
        color: color,
      );

  // Headline text styles
  static TextStyle headlineLarge({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 32,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 28,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle headlineSmall({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  // Title text styles
  static TextStyle titleLarge({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 22,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 18,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  // Body text styles
  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  // Label text styles
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color,
      );

  // Custom text styles for specific use cases
  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14,
        fontWeight: semiBold,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle buttonSmall({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: semiBold,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color ?? AppColors.textSecondaryLight,
      );

  static TextStyle overline({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 10,
        fontWeight: medium,
        letterSpacing: letterSpacingWidest,
        height: lineHeightNormal,
        color: color ?? AppColors.textTertiaryLight,
      );

  // Task-specific styles
  static TextStyle taskTitle({Color? color, bool completed = false}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16,
        fontWeight: medium,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
        decoration: completed ? TextDecoration.lineThrough : null,
        decorationColor: color,
      );

  static TextStyle taskDescription({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightRelaxed,
        color: color ?? AppColors.textSecondaryLight,
      );

  static TextStyle taskDueDate({Color? color, bool overdue = false}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: overdue ? AppColors.error : (color ?? AppColors.textSecondaryLight),
      );

  // List-specific styles
  static TextStyle listTitle({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 18,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle listSubtitle({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        color: color ?? AppColors.textSecondaryLight,
      );

  // Section header style
  static TextStyle sectionHeader({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 13,
        fontWeight: semiBold,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color ?? AppColors.textSecondaryLight,
      );

  // Counter/badge style
  static TextStyle counter({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: bold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
        color: color ?? Colors.white,
      );

  // Time display style
  static TextStyle time({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 48,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle timeSmall({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
        color: color,
      );

  // Statistics style
  static TextStyle statNumber({Color? color}) => TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 32,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle statLabel({Color? color}) => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
        color: color ?? AppColors.textSecondaryLight,
      );
}

/// Extension on BuildContext for easy text style access
extension AppTypographyExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Convenience getters for text colors
  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get textDisabled =>
      isDarkMode ? AppColors.textDisabledDark : AppColors.textDisabledLight;
}
