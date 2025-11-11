/// Design System Export File
/// Import this file to access all design system components
///
/// Usage:
/// ```dart
/// import 'package:dingdong/config/theme/design_system.dart';
///
/// // Access colors
/// Color primaryColor = AppColors.primary;
///
/// // Access typography
/// TextStyle heading = AppTypography.headlineLarge;
///
/// // Access spacing
/// EdgeInsets padding = AppSpacing.paddingMD;
///
/// // Access constants
/// double maxWidth = AppConstants.maxDesktopWidth;
/// ```

// Export all design system components
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_constants.dart';
export 'app_theme.dart';
export 'theme_service.dart';
