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
/// Spacing system for DingDong app
/// Uses 4px base unit for consistent spacing throughout the app
class AppSpacing {
  AppSpacing._(); // Private constructor

  // ==================== Base Unit ====================
  static const double baseUnit = 4.0;

  // ==================== Spacing Scale ====================
  /// 4px - Extra extra small
  static const double xxs = baseUnit; // 4

  /// 8px - Extra small
  static const double xs = baseUnit * 2; // 8

  /// 12px - Small
  static const double sm = baseUnit * 3; // 12

  /// 16px - Medium (default)
  static const double md = baseUnit * 4; // 16

  /// 20px - Large
  static const double lg = baseUnit * 5; // 20

  /// 24px - Extra large
  static const double xl = baseUnit * 6; // 24

  /// 32px - Extra extra large
  static const double xxl = baseUnit * 8; // 32

  /// 40px - Extra extra extra large
  static const double xxxl = baseUnit * 10; // 40

  /// 48px - Huge
  static const double huge = baseUnit * 12; // 48

  /// 64px - Extra huge
  static const double xhuge = baseUnit * 16; // 64

  // ==================== Common Padding Presets ====================

  /// No padding
  static const EdgeInsets none = EdgeInsets.zero;

  /// Extra extra small padding (4px all)
  static const EdgeInsets paddingXXS = EdgeInsets.all(xxs);

  /// Extra small padding (8px all)
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Small padding (12px all)
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// Medium padding (16px all)
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// Large padding (20px all)
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// Extra large padding (24px all)
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Extra extra large padding (32px all)
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // ==================== Horizontal Padding ====================

  /// Extra small horizontal padding (8px)
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// Small horizontal padding (12px)
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);

  /// Medium horizontal padding (16px)
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// Large horizontal padding (20px)
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// Extra large horizontal padding (24px)
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  /// Extra extra large horizontal padding (32px)
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // ==================== Vertical Padding ====================

  /// Extra small vertical padding (8px)
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// Small vertical padding (12px)
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);

  /// Medium vertical padding (16px)
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// Large vertical padding (20px)
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// Extra large vertical padding (24px)
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  /// Extra extra large vertical padding (32px)
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // ==================== Page/Screen Padding ====================

  /// Standard page padding (16px horizontal, 24px vertical)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xl,
  );

  /// Mobile page padding (16px all)
  static const EdgeInsets mobilePagePadding = EdgeInsets.all(md);

  /// Tablet page padding (24px all)
  static const EdgeInsets tabletPagePadding = EdgeInsets.all(xl);

  /// Desktop page padding (32px all)
  static const EdgeInsets desktopPagePadding = EdgeInsets.all(xxl);

  // ==================== Card Padding ====================

  /// Card content padding (16px all)
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card compact padding (12px all)
  static const EdgeInsets cardCompactPadding = EdgeInsets.all(sm);

  /// Card spacious padding (24px all)
  static const EdgeInsets cardSpaciousPadding = EdgeInsets.all(xl);

  // ==================== List Item Padding ====================

  /// List item padding (16px horizontal, 12px vertical)
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// List item compact padding (16px horizontal, 8px vertical)
  static const EdgeInsets listItemCompactPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  /// List item spacious padding (20px horizontal, 16px vertical)
  static const EdgeInsets listItemSpaciousPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ==================== Button Padding ====================

  /// Button padding (24px horizontal, 12px vertical)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: sm,
  );

  /// Button small padding (16px horizontal, 8px vertical)
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  /// Button large padding (32px horizontal, 16px vertical)
  static const EdgeInsets buttonLargePadding = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: md,
  );

  // ==================== Input Field Padding ====================

  /// Input field padding (16px horizontal, 12px vertical)
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Input field compact padding (12px horizontal, 8px vertical)
  static const EdgeInsets inputCompactPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  // ==================== Dialog Padding ====================

  /// Dialog content padding (24px all)
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);

  /// Dialog title padding (24px horizontal, 20px top, 16px bottom)
  static const EdgeInsets dialogTitlePadding = EdgeInsets.fromLTRB(xl, lg, xl, md);

  /// Dialog actions padding (16px all)
  static const EdgeInsets dialogActionsPadding = EdgeInsets.all(md);

  // ==================== SizedBox Spacing ====================

  /// Extra small vertical spacing (8px)
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);

  /// Small vertical spacing (12px)
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);

  /// Medium vertical spacing (16px)
  static const SizedBox verticalSpaceMD = SizedBox(height: md);

  /// Large vertical spacing (20px)
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);

  /// Extra large vertical spacing (24px)
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  /// Extra extra large vertical spacing (32px)
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);

  /// Extra small horizontal spacing (8px)
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);

  /// Small horizontal spacing (12px)
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);

  /// Medium horizontal spacing (16px)
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);

  /// Large horizontal spacing (20px)
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);

  /// Extra large horizontal spacing (24px)
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  /// Extra extra large horizontal spacing (32px)
  static const SizedBox horizontalSpaceXXL = SizedBox(width: xxl);

  // ==================== Border Radius ====================

  /// Extra small radius (4px)
  static const double radiusXS = xxs;

  /// Small radius (8px)
  static const double radiusSM = xs;

  /// Medium radius (12px)
  static const double radiusMD = sm;

  /// Large radius (16px)
  static const double radiusLG = md;

  /// Extra large radius (24px)
  static const double radiusXL = xl;

  /// Circular radius (999px)
  static const double radiusCircular = 999.0;

  // ==================== Border Radius Presets ====================

  /// Extra small border radius
  static final BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);

  /// Small border radius
  static final BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);

  /// Medium border radius
  static final BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);

  /// Large border radius
  static final BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);

  /// Extra large border radius
  static final BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);

  /// Circular border radius
  static final BorderRadius borderRadiusCircular = BorderRadius.circular(radiusCircular);

  // ==================== Elevation (Shadow) Levels ====================

  /// No elevation
  static const double elevationNone = 0;

  /// Low elevation (1dp)
  static const double elevationLow = 1;

  /// Medium elevation (2dp)
  static const double elevationMedium = 2;

  /// High elevation (4dp)
  static const double elevationHigh = 4;

  /// Extra high elevation (8dp)
  static const double elevationExtraHigh = 8;

  /// Maximum elevation (16dp)
  static const double elevationMax = 16;

  // ==================== Icon Sizes ====================

  /// Extra small icon (16px)
  static const double iconXS = 16;

  /// Small icon (20px)
  static const double iconSM = 20;

  /// Medium icon (24px)
  static const double iconMD = 24;

  /// Large icon (32px)
  static const double iconLG = 32;

  /// Extra large icon (48px)
  static const double iconXL = 48;

  /// Extra extra large icon (64px)
  static const double iconXXL = 64;

  // ==================== Helper Methods ====================

  /// Custom padding
  static EdgeInsets custom({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.fromLTRB(
      left ?? horizontal ?? 0,
      top ?? vertical ?? 0,
      right ?? horizontal ?? 0,
      bottom ?? vertical ?? 0,
    );
  }

  /// Custom vertical spacing
  static SizedBox verticalSpace(double height) {
    return SizedBox(height: height);
  }

  /// Custom horizontal spacing
  static SizedBox horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  /// Responsive padding based on screen width
  static EdgeInsets responsivePadding(double screenWidth) {
    if (screenWidth < 600) {
      return mobilePagePadding;
    } else if (screenWidth < 1024) {
      return tabletPagePadding;
    } else {
      return desktopPagePadding;
    }
  }
}
