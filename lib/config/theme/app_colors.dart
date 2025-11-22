import 'package:flutter/material.dart';

/// Application color palette with semantic naming
class AppColors {
  AppColors._(); // Private constructor

  // Primary brand colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryVariant = Color(0xFF0D47A1);

  // Secondary/accent colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF67FFDE);
  static const Color secondaryDark = Color(0xFF00A896);

  // Accent colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9B9B);
  static const Color accentDark = Color(0xFFE64545);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);
  static const Color surfaceVariantDark = Color(0xFF2D2D2D);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF606060);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFF8B0000);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Priority colors
  static const Color priorityNone = Color(0xFF9E9E9E);
  static const Color priorityLow = Color(0xFF2196F3);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityHigh = Color(0xFFFF9800);
  static const Color priorityCritical = Color(0xFFF44336);

  // Task status colors
  static const Color statusTodo = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFB00020);
  static const Color statusOnHold = Color(0xFFFF9800);
  static const Color statusOverdue = Color(0xFFF44336);

  // Calendar colors
  static const List<Color> calendarColors = [
    Color(0xFFE57373), // Red
    Color(0xFF81C784), // Green
    Color(0xFF64B5F6), // Blue
    Color(0xFFFFD54F), // Yellow
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFF8A65), // Orange
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFA1887F), // Brown
    Color(0xFFAED581), // Light Green
  ];

  // Tag colors
  static const List<Color> tagColors = [
    Color(0xFFE53935), // Red
    Color(0xFFD81B60), // Pink
    Color(0xFF8E24AA), // Purple
    Color(0xFF5E35B1), // Deep Purple
    Color(0xFF3949AB), // Indigo
    Color(0xFF1E88E5), // Blue
    Color(0xFF039BE5), // Light Blue
    Color(0xFF00ACC1), // Cyan
    Color(0xFF00897B), // Teal
    Color(0xFF43A047), // Green
    Color(0xFF7CB342), // Light Green
    Color(0xFFC0CA33), // Lime
    Color(0xFFFDD835), // Yellow
    Color(0xFFFFB300), // Amber
    Color(0xFFFB8C00), // Orange
    Color(0xFFF4511E), // Deep Orange
    Color(0xFF6D4C41), // Brown
    Color(0xFF757575), // Grey
    Color(0xFF546E7A), // Blue Grey
    Color(0xFF212121), // Black
  ];

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay colors
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayMedium = Color(0x33000000);
  static const Color overlayDark = Color(0x66000000);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);
  static const Color shadowDark = Color(0x40000000);

  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Divider colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Shimmer colors
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2D2D2D);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);

  // Social media colors
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  static const Color microsoft = Color(0xFF00A4EF);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);

  /// Get priority color by priority level (0-4)
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priorityLow;
      case 2:
        return priorityMedium;
      case 3:
        return priorityHigh;
      case 4:
        return priorityCritical;
      default:
        return priorityNone;
    }
  }

  /// Get tag color by index
  static Color getTagColor(int index) {
    return tagColors[index % tagColors.length];
  }

  /// Get calendar color by index
  static Color getCalendarColor(int index) {
    return calendarColors[index % calendarColors.length];
  }
}

/// Extension on BuildContext for easy color access
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => AppColors.primary;
  Color get secondaryColor => AppColors.secondary;
  Color get accentColor => AppColors.accent;

  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get surfaceVariantColor =>
      isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

  Color get textPrimaryColor =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiaryColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get textDisabledColor =>
      isDarkMode ? AppColors.textDisabledDark : AppColors.textDisabledLight;

  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;
  Color get dividerColor =>
      isDarkMode ? AppColors.dividerDark : AppColors.dividerLight;

  Color get shimmerBaseColor =>
      isDarkMode ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
  Color get shimmerHighlightColor =>
      isDarkMode ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;
}
