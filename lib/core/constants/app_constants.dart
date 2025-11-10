/// Application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App metadata
  static const String appName = 'DingDong';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription =
      'Next-generation task management with AI-powered features';

  // App package identifiers
  static const String androidPackageName = 'com.dingdong.app';
  static const String iosPackageName = 'com.dingdong.app';
  static const String appScheme = 'dingdong';

  // API endpoints
  static const String apiBaseUrl = 'https://api.dingdong.app/v1';
  static const String apiTimeout = '30'; // seconds

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Shared Preferences keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String lastSyncTimeKey = 'last_sync_time';
  static const String notificationSettingsKey = 'notification_settings';

  // Feature flags
  static const bool enableAIImageRecognition = true;
  static const bool enableVoiceInput = true;
  static const bool enableLocationReminders = true;
  static const bool enableBiometricAuth = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Limits (Free tier)
  static const int maxListsFree = 20;
  static const int maxTasksPerListFree = 100;
  static const int maxSubtasksPerTaskFree = 9;
  static const int maxRemindersPerTaskFree = 3;
  static const int maxCollaboratorsPerListFree = 1;
  static const int maxFileSizeMBFree = 10;
  static const int maxAIImageScansPerMonthFree = 10;

  // Limits (Premium)
  static const int maxListsPremium = -1; // Unlimited
  static const int maxTasksPerListPremium = -1; // Unlimited
  static const int maxSubtasksPerTaskPremium = -1; // Unlimited
  static const int maxRemindersPerTaskPremium = -1; // Unlimited
  static const int maxCollaboratorsPerListPremium = 10;
  static const int maxFileSizeMBPremium = 100;
  static const int maxAIImageScansPerMonthPremium = -1; // Unlimited

  // Animation durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 350;
  static const int longAnimationDuration = 500;

  // Timeouts
  static const int splashScreenDuration = 2000; // milliseconds
  static const int snackbarDuration = 3000; // milliseconds
  static const int toastDuration = 2000; // milliseconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Pomodoro defaults
  static const int defaultFocusDuration = 25; // minutes
  static const int defaultShortBreakDuration = 5; // minutes
  static const int defaultLongBreakDuration = 15; // minutes
  static const int defaultLongBreakInterval = 4; // sessions

  // Sync settings
  static const int syncIntervalMinutes = 15;
  static const int backgroundSyncIntervalMinutes = 60;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 5;

  // File upload
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
  ];

  // URL patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  // Social media
  static const String twitterHandle = '@dingdongapp';
  static const String twitterUrl = 'https://twitter.com/dingdongapp';
  static const String instagramHandle = '@dingdongapp';
  static const String instagramUrl = 'https://instagram.com/dingdongapp';
  static const String linkedinUrl =
      'https://linkedin.com/company/dingdongapp';

  // Support
  static const String supportEmail = 'support@dingdong.app';
  static const String feedbackEmail = 'feedback@dingdong.app';
  static const String helpCenterUrl = 'https://help.dingdong.app';
  static const String privacyPolicyUrl = 'https://dingdong.app/privacy';
  static const String termsOfServiceUrl = 'https://dingdong.app/terms';

  // External services
  static const String appStoreUrl =
      'https://apps.apple.com/app/dingdong/idXXXXXXXXXX';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.dingdong.app';
  static const String webAppUrl = 'https://app.dingdong.app';

  // Analytics events
  static const String eventTaskCreated = 'task_created';
  static const String eventTaskCompleted = 'task_completed';
  static const String eventListCreated = 'list_created';
  static const String eventReminderSet = 'reminder_set';
  static const String eventAIImageScan = 'ai_image_scan';
  static const String eventPomodoroStarted = 'pomodoro_started';
  static const String eventHabitCheckedIn = 'habit_checked_in';
  static const String eventPremiumUpgrade = 'premium_upgrade';

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String authErrorMessage =
      'Authentication failed. Please log in again.';
  static const String permissionErrorMessage =
      'Permission denied. Please grant the required permissions.';

  // Success messages
  static const String taskCreatedMessage = 'Task created successfully';
  static const String taskUpdatedMessage = 'Task updated successfully';
  static const String taskDeletedMessage = 'Task deleted successfully';
  static const String taskCompletedMessage = 'Task completed! 🎉';
  static const String listCreatedMessage = 'List created successfully';
  static const String listUpdatedMessage = 'List updated successfully';
  static const String listDeletedMessage = 'List deleted successfully';

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String shortDateFormat = 'MM/dd/yyyy';
  static const String iso8601Format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // Asset paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';
  static const String illustrationsPath = 'assets/illustrations/';
  static const String soundsPath = 'assets/sounds/';
  static const String fontsPath = 'assets/fonts/';

  // Default values
  static const String defaultListName = 'My Tasks';
  static const String defaultListIcon = '📋';
  static const String defaultListColor = '#2196F3';
  static const int defaultPriority = 0; // None
  static const String defaultTaskStatus = 'todo';

  // Subscription SKUs (RevenueCat)
  static const String monthlyPremiumSku = 'premium_monthly';
  static const String yearlyPremiumSku = 'premium_yearly';
  static const String monthlyFamilySku = 'family_monthly';
  static const String yearlyFamilySku = 'family_yearly';
  static const String lifetimePremiumSku = 'premium_lifetime';

  // Subscription prices (USD)
  static const double monthlyPremiumPrice = 4.99;
  static const double yearlyPremiumPrice = 39.99;
  static const double monthlyFamilyPrice = 7.99;
  static const double yearlyFamilyPrice = 69.99;
  static const double lifetimePremiumPrice = 199.99;
}
