import 'package:flutter/material.dart';

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
