import 'package:flutter/material.dart';

/// Application spacing constants using 4px base unit
class AppSpacing {
  AppSpacing._(); // Private constructor

  // Base unit (4px)
  static const double unit = 4.0;

  // Spacing scale
  static const double xxs = 2.0;  // 0.5 unit
  static const double xs = 4.0;   // 1 unit
  static const double sm = 8.0;   // 2 units
  static const double md = 12.0;  // 3 units
  static const double lg = 16.0;  // 4 units
  static const double xl = 20.0;  // 5 units
  static const double xxl = 24.0; // 6 units
  static const double xxxl = 32.0; // 8 units

  // Named spacing for specific use cases
  static const double none = 0.0;
  static const double tight = 4.0;
  static const double normal = 8.0;
  static const double relaxed = 12.0;
  static const double loose = 16.0;
  static const double spacious = 24.0;

  // Page padding
  static const double pagePaddingHorizontal = 16.0;
  static const double pagePaddingVertical = 16.0;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pagePaddingHorizontal,
    vertical: pagePaddingVertical,
  );
  static const EdgeInsets pagePaddingHorizontalOnly = EdgeInsets.symmetric(
    horizontal: pagePaddingHorizontal,
  );

  // Card padding
  static const double cardPaddingHorizontal = 16.0;
  static const double cardPaddingVertical = 12.0;
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: cardPaddingHorizontal,
    vertical: cardPaddingVertical,
  );

  // List item padding
  static const double listItemPaddingHorizontal = 16.0;
  static const double listItemPaddingVertical = 12.0;
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: listItemPaddingHorizontal,
    vertical: listItemPaddingVertical,
  );

  // Button padding
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );
  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );

  // Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );

  // Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  static const EdgeInsets dialogContentPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 20.0,
  );

  // Bottom sheet padding
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    24.0,
  );

  // Section spacing
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 8.0;
  static const double formFieldSpacing = 16.0;

  // Gap sizes for Row/Column with MainAxisAlignment.spaceBetween
  static const double gapXs = 4.0;
  static const double gapSm = 8.0;
  static const double gapMd = 12.0;
  static const double gapLg = 16.0;
  static const double gapXl = 24.0;

  // Widget-specific spacing
  static const double iconTextGap = 8.0;
  static const double avatarTextGap = 12.0;
  static const double chipSpacing = 8.0;
  static const double tagSpacing = 6.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Common border radius
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Top-only border radius
  static const BorderRadius borderRadiusTopMd = BorderRadius.only(
    topLeft: Radius.circular(radiusMd),
    topRight: Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusTopLg = BorderRadius.only(
    topLeft: Radius.circular(radiusLg),
    topRight: Radius.circular(radiusLg),
  );

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Avatar sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;
  static const double avatarXxl = 96.0;

  // Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // Input field height
  static const double inputHeight = 48.0;

  // App bar height
  static const double appBarHeight = 56.0;
  static const double appBarHeightExpanded = 128.0;

  // Bottom navigation height
  static const double bottomNavHeight = 80.0;

  // Floating action button
  static const double fabSize = 56.0;
  static const double fabSizeMini = 40.0;
  static const double fabSizeExtended = 48.0;

  // Minimum touch target
  static const double minTouchTarget = 48.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Maximum content width (for tablets/desktop)
  static const double maxContentWidth = 600.0;
  static const double maxContentWidthWide = 900.0;
  static const double maxDialogWidth = 400.0;
}

/// SizedBox shortcuts for common gaps
class Gap {
  Gap._();

  // Horizontal gaps
  static const Widget h4 = SizedBox(width: AppSpacing.xs);
  static const Widget h8 = SizedBox(width: AppSpacing.sm);
  static const Widget h12 = SizedBox(width: AppSpacing.md);
  static const Widget h16 = SizedBox(width: AppSpacing.lg);
  static const Widget h20 = SizedBox(width: AppSpacing.xl);
  static const Widget h24 = SizedBox(width: AppSpacing.xxl);
  static const Widget h32 = SizedBox(width: AppSpacing.xxxl);

  // Vertical gaps
  static const Widget v4 = SizedBox(height: AppSpacing.xs);
  static const Widget v8 = SizedBox(height: AppSpacing.sm);
  static const Widget v12 = SizedBox(height: AppSpacing.md);
  static const Widget v16 = SizedBox(height: AppSpacing.lg);
  static const Widget v20 = SizedBox(height: AppSpacing.xl);
  static const Widget v24 = SizedBox(height: AppSpacing.xxl);
  static const Widget v32 = SizedBox(height: AppSpacing.xxxl);
  static const Widget v48 = SizedBox(height: 48.0);
  static const Widget v64 = SizedBox(height: 64.0);
}

/// Extension for responsive padding
extension AppSpacingExtension on BuildContext {
  EdgeInsets get pagePadding => AppSpacing.pagePadding;
  EdgeInsets get cardPadding => AppSpacing.cardPadding;
  EdgeInsets get listItemPadding => AppSpacing.listItemPadding;
}
