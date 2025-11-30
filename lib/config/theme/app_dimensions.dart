import 'package:flutter/material.dart';

/// Application dimensions for responsive design
class AppDimensions {
  AppDimensions._(); // Private constructor

  // Breakpoints
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointWide = 1440;

  // Device types
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointTablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointDesktop;

  static bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointWide;

  // Device type enum getter
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointTablet) return DeviceType.mobile;
    if (width < breakpointDesktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Screen size helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double screenAspectRatio(BuildContext context) =>
      MediaQuery.of(context).size.aspectRatio;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // Safe area helpers
  static EdgeInsets safeArea(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static double safeAreaLeft(BuildContext context) =>
      MediaQuery.of(context).padding.left;

  static double safeAreaRight(BuildContext context) =>
      MediaQuery.of(context).padding.right;

  // Keyboard height
  static double keyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  // Grid configuration
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 4;
    if (isTablet(context)) return 8;
    return 12;
  }

  static double gridGutter(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }

  static double gridMargin(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 32;
    return 64;
  }

  // Content width constraints
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 600;
    return 900;
  }

  static double maxFormWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return 400;
  }

  static double maxDialogWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return 400;
  }

  // Navigation configuration
  static bool shouldShowSideNav(BuildContext context) =>
      isTablet(context) || isDesktop(context);

  static bool shouldShowBottomNav(BuildContext context) => isMobile(context);

  static double sideNavWidth(BuildContext context) {
    if (isDesktop(context)) return 280;
    return 256;
  }

  static double sideNavCollapsedWidth = 72;

  // Animation durations based on device
  static Duration animationDuration(BuildContext context) {
    // Reduce motion for accessibility or use shorter durations on desktop
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return const Duration(milliseconds: 300);
  }

  // List configurations
  static double listItemHeight(BuildContext context) {
    if (isMobile(context)) return 56;
    return 64;
  }

  static double taskItemHeight(BuildContext context) {
    if (isMobile(context)) return 72;
    return 80;
  }

  // Card configurations
  static double cardWidth(BuildContext context) {
    if (isMobile(context)) return screenWidth(context) - 32;
    return 320;
  }

  // Bottom sheet configurations
  static double bottomSheetMaxHeight(BuildContext context) =>
      screenHeight(context) * 0.9;

  static double bottomSheetMinHeight(BuildContext context) =>
      screenHeight(context) * 0.3;

  // Modal configurations
  static double modalMaxHeight(BuildContext context) =>
      screenHeight(context) * 0.85;

  static double modalMinHeight(BuildContext context) =>
      screenHeight(context) * 0.4;

  // Image sizes
  static double thumbnailSize(BuildContext context) {
    if (isMobile(context)) return 80;
    return 120;
  }

  static double previewImageSize(BuildContext context) {
    if (isMobile(context)) return 200;
    return 300;
  }

  // Calendar configurations
  static double calendarDaySize(BuildContext context) {
    if (isMobile(context)) return 40;
    return 48;
  }

  static double calendarWeekViewHourHeight(BuildContext context) {
    if (isMobile(context)) return 60;
    return 80;
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension on BuildContext for easy dimension access
extension AppDimensionsExtension on BuildContext {
  // Screen size
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Device type
  bool get isMobile => AppDimensions.isMobile(this);
  bool get isTablet => AppDimensions.isTablet(this);
  bool get isDesktop => AppDimensions.isDesktop(this);
  DeviceType get deviceType => AppDimensions.getDeviceType(this);

  // Orientation
  bool get isLandscape => AppDimensions.isLandscape(this);
  bool get isPortrait => AppDimensions.isPortrait(this);

  // Safe areas
  EdgeInsets get safeArea => AppDimensions.safeArea(this);
  double get safeAreaTop => AppDimensions.safeAreaTop(this);
  double get safeAreaBottom => AppDimensions.safeAreaBottom(this);

  // Keyboard
  double get keyboardHeight => AppDimensions.keyboardHeight(this);
  bool get isKeyboardVisible => AppDimensions.isKeyboardVisible(this);

  // Navigation
  bool get shouldShowSideNav => AppDimensions.shouldShowSideNav(this);
  bool get shouldShowBottomNav => AppDimensions.shouldShowBottomNav(this);
  double get sideNavWidth => AppDimensions.sideNavWidth(this);

  // Content constraints
  double get maxContentWidth => AppDimensions.maxContentWidth(this);
  double get maxFormWidth => AppDimensions.maxFormWidth(this);
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, AppDimensions.getDeviceType(context));
  }
}

/// Conditional widget based on device type
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = AppDimensions.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}
