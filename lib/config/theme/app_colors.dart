import 'package:flutter/material.dart';

/// Comprehensive color palette for DingDong app
/// Following Material Design 3 guidelines with accessibility in mind
class AppColors {
  AppColors._(); // Private constructor

  // ==================== Primary Colors ====================
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryContainer = Color(0xFFBBDEFB);

  // ==================== Secondary Colors ====================
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryContainer = Color(0xFFB2DFDB);

  // ==================== Accent Colors ====================
  static const Color accent = Color(0xFFFF6B6B); // Coral Red
  static const Color accentDark = Color(0xFFE63946);
  static const Color accentLight = Color(0xFFFF9999);

  // ==================== Semantic Colors ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF81C784);

  static const Color error = Color(0xFFB00020);
  static const Color errorDark = Color(0xFF8E0000);
  static const Color errorLight = Color(0xFFCF6679);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFD54F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF64B5F6);

  // ==================== Priority Colors ====================
  static const Color priorityNone = Color(0xFF9E9E9E); // Gray
  static const Color priorityLow = Color(0xFF2196F3); // Blue
  static const Color priorityMedium = Color(0xFFFFC107); // Yellow
  static const Color priorityHigh = Color(0xFFFF9800); // Orange
  static const Color priorityCritical = Color(0xFFF44336); // Red

  // ==================== Status Colors ====================
  static const Color statusTodo = Color(0xFF9E9E9E); // Gray
  static const Color statusInProgress = Color(0xFF2196F3); // Blue
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFFF44336); // Red
  static const Color statusOnHold = Color(0xFFFFC107); // Yellow

  // ==================== Tag Colors ====================
  static const List<Color> tagColors = [
    Color(0xFFE57373), // Red
    Color(0xFFF06292), // Pink
    Color(0xFFBA68C8), // Purple
    Color(0xFF9575CD), // Deep Purple
    Color(0xFF7986CB), // Indigo
    Color(0xFF64B5F6), // Blue
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF4DB6AC), // Teal
    Color(0xFF81C784), // Green
    Color(0xFFAED581), // Light Green
    Color(0xFFDCE775), // Lime
    Color(0xFFFFD54F), // Yellow
    Color(0xFFFFB74D), // Orange
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Gray
  ];

  // ==================== Light Theme Colors ====================
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFFAFAFA);
  static const Color lightOnBackground = Color(0xFF212121);
  static const Color lightOnSurface = Color(0xFF212121);
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1F000000);
  static const Color lightDivider = Color(0x1F000000);

  // Text colors - Light theme
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);
  static const Color lightTextHint = Color(0xFF9E9E9E);

  // ==================== Dark Theme Colors ====================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOutline = Color(0xFF424242);
  static const Color darkShadow = Color(0x3F000000);
  static const Color darkDivider = Color(0x1FFFFFFF);

  // Text colors - Dark theme
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextDisabled = Color(0xFF616161);
  static const Color darkTextHint = Color(0xFF757575);

  // ==================== True Black Theme Colors (OLED) ====================
  static const Color trueBlackBackground = Color(0xFF000000);
  static const Color trueBlackSurface = Color(0xFF0A0A0A);
  static const Color trueBlackSurfaceVariant = Color(0xFF161616);

  // ==================== Neutral Grays ====================
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ==================== Overlay Colors ====================
  static const Color scrim = Color(0x99000000); // 60% black
  static const Color overlay = Color(0x14000000); // 8% black
  static const Color hoverOverlay = Color(0x0A000000); // 4% black
  static const Color focusOverlay = Color(0x1F000000); // 12% black
  static const Color pressedOverlay = Color(0x29000000); // 16% black

  // ==================== Special Colors ====================
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ==================== Gradient Definitions ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Helper Methods ====================

  /// Get color by priority level
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return priorityNone;
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

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Check if color is light or dark
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Get contrasting text color for a given background
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? black : white;
  }
}
