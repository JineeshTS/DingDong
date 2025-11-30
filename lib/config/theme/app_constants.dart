/// Design system constants for DingDong app
/// Contains all constant values used throughout the application
class AppConstants {
  AppConstants._(); // Private constructor

  // ==================== Breakpoints ====================
  /// Mobile breakpoint (< 600px)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (600px - 1024px)
  static const double tabletBreakpoint = 1024;

  /// Desktop breakpoint (> 1024px)
  static const double desktopBreakpoint = 1024;

  /// Wide desktop breakpoint (> 1440px)
  static const double wideDesktopBreakpoint = 1440;

  // ==================== Animation Durations ====================
  /// Extra fast animation (100ms)
  static const Duration animationXFast = Duration(milliseconds: 100);

  /// Fast animation (200ms)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Normal animation (300ms)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow animation (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Extra slow animation (700ms)
  static const Duration animationXSlow = Duration(milliseconds: 700);

  /// Page transition duration
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// Splash screen duration
  static const Duration splashDuration = Duration(seconds: 2);

  /// Snackbar duration
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Toast duration
  static const Duration toastDuration = Duration(seconds: 2);

  // ==================== Animation Curves ====================
  /// Standard easing curve
  static const standardCurve = Curves.easeInOut;

  /// Emphasized easing curve
  static const emphasizedCurve = Curves.fastOutSlowIn;

  /// Decelerated easing curve
  static const deceleratedCurve = Curves.easeOut;

  /// Accelerated easing curve
  static const acceleratedCurve = Curves.easeIn;

  // ==================== Max Widths ====================
  /// Maximum content width for mobile
  static const double maxMobileWidth = 600;

  /// Maximum content width for tablet
  static const double maxTabletWidth = 1024;

  /// Maximum content width for desktop
  static const double maxDesktopWidth = 1440;

  /// Maximum dialog width
  static const double maxDialogWidth = 600;

  /// Maximum card width
  static const double maxCardWidth = 400;

  // ==================== Heights ====================
  /// App bar height
  static const double appBarHeight = 56;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 80;

  /// Tab bar height
  static const double tabBarHeight = 48;

  /// Button height
  static const double buttonHeight = 48;

  /// Small button height
  static const double buttonSmallHeight = 36;

  /// Large button height
  static const double buttonLargeHeight = 56;

  /// Text field height
  static const double textFieldHeight = 48;

  /// Toolbar height
  static const double toolbarHeight = 56;

  // ==================== List & Grid ====================
  /// List item height
  static const double listItemHeight = 72;

  /// Compact list item height
  static const double listItemCompactHeight = 56;

  /// Spacious list item height
  static const double listItemSpaciousHeight = 88;

  /// Grid item aspect ratio
  static const double gridItemAspectRatio = 1.0;

  /// Grid cross axis spacing
  static const double gridCrossAxisSpacing = 16;

  /// Grid main axis spacing
  static const double gridMainAxisSpacing = 16;

  // ==================== Border & Divider ====================
  /// Thin border width
  static const double borderThin = 1;

  /// Medium border width
  static const double borderMedium = 2;

  /// Thick border width
  static const double borderThick = 4;

  /// Divider thickness
  static const double dividerThickness = 1;

  // ==================== Opacity Levels ====================
  /// Disabled opacity
  static const double opacityDisabled = 0.38;

  /// Medium emphasis opacity
  static const double opacityMedium = 0.60;

  /// High emphasis opacity
  static const double opacityHigh = 0.87;

  /// Overlay opacity
  static const double opacityOverlay = 0.08;

  /// Hover opacity
  static const double opacityHover = 0.04;

  /// Focus opacity
  static const double opacityFocus = 0.12;

  /// Pressed opacity
  static const double opacityPressed = 0.16;

  // ==================== Task-Specific Constants ====================
  /// Maximum task title length
  static const int maxTaskTitleLength = 500;

  /// Maximum task description length
  static const int maxTaskDescriptionLength = 5000;

  /// Maximum subtask depth
  static const int maxSubtaskDepth = 10;

  /// Maximum tags per task
  static const int maxTagsPerTask = 10;

  /// Maximum attachments per task
  static const int maxAttachmentsPerTask = 20;

  /// Maximum file size (MB) - Free tier
  static const double maxFileSizeFree = 10;

  /// Maximum file size (MB) - Premium tier
  static const double maxFileSizePremium = 100;

  // ==================== Pagination ====================
  /// Default page size
  static const int defaultPageSize = 20;

  /// Minimum page size
  static const int minPageSize = 10;

  /// Maximum page size
  static const int maxPageSize = 100;

  // ==================== Cache & Storage ====================
  /// Cache expiration duration (7 days)
  static const Duration cacheExpiration = Duration(days: 7);

  /// Image cache duration (30 days)
  static const Duration imageCacheExpiration = Duration(days: 30);

  /// Session timeout (30 minutes)
  static const Duration sessionTimeout = Duration(minutes: 30);

  // ==================== Debounce & Throttle ====================
  /// Search debounce duration
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Auto-save debounce duration
  static const Duration autoSaveDebounce = Duration(seconds: 2);

  /// Network retry delay
  static const Duration networkRetryDelay = Duration(seconds: 3);

  // ==================== Feature Flags ====================
  /// Enable offline mode
  static const bool enableOfflineMode = true;

  /// Enable analytics
  static const bool enableAnalytics = true;

  /// Enable crash reporting
  static const bool enableCrashReporting = true;

  /// Enable beta features
  static const bool enableBetaFeatures = false;

  // ==================== URLs & Deep Links ====================
  /// App deep link scheme
  static const String deepLinkScheme = 'dingdong';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://dingdong.app/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://dingdong.app/terms';

  /// Support URL
  static const String supportUrl = 'https://support.dingdong.app';

  /// Help center URL
  static const String helpCenterUrl = 'https://help.dingdong.app';

  // ==================== Platform Specific ====================
  /// iOS app store ID
  static const String iosAppStoreId = '0000000000'; // TODO: Update with actual ID

  /// Android package name
  static const String androidPackageName = 'com.dingdong.app'; // TODO: Update

  /// Minimum iOS version
  static const String minIosVersion = '13.0';

  /// Minimum Android version
  static const int minAndroidSdk = 23; // Android 6.0

  // ==================== Localization ====================
  /// Default locale
  static const String defaultLocale = 'en';

  /// Supported locales
  static const List<String> supportedLocales = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese (Simplified)
    'ar', // Arabic
  ];

  // ==================== Date & Time Formats ====================
  /// Short date format (MM/DD/YYYY)
  static const String shortDateFormat = 'MM/dd/yyyy';

  /// Long date format (MMMM DD, YYYY)
  static const String longDateFormat = 'MMMM dd, yyyy';

  /// Time format (12-hour)
  static const String time12HourFormat = 'h:mm a';

  /// Time format (24-hour)
  static const String time24HourFormat = 'HH:mm';

  /// Date time format
  static const String dateTimeFormat = 'MM/dd/yyyy h:mm a';

  // ==================== Regular Expressions ====================
  /// Email validation regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Password validation regex (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
  );

  /// Phone number regex (basic)
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  /// URL regex
  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  // ==================== Error Messages ====================
  /// Generic error message
  static const String genericErrorMessage = 'Something went wrong. Please try again.';

  /// Network error message
  static const String networkErrorMessage = 'No internet connection. Please check your network.';

  /// Unauthorized error message
  static const String unauthorizedErrorMessage = 'You are not authorized to perform this action.';

  /// Not found error message
  static const String notFoundErrorMessage = 'The requested resource was not found.';

  /// Validation error message
  static const String validationErrorMessage = 'Please check your input and try again.';
}
