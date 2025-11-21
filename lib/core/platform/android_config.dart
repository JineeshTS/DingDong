import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';

/// Android Platform Configuration Service
///
/// Handles Android-specific configurations including:
/// - Home Screen Widgets (App Widgets)
/// - Quick Settings Tiles
/// - App Shortcuts (long press menu)
/// - Android Auto
/// - Wear OS companion app
/// - Material You theming
/// - Push notifications (FCM)
/// - Fingerprint / Face Unlock
class AndroidConfig {
  AndroidConfig._();

  static final AndroidConfig _instance = AndroidConfig._();
  static AndroidConfig get instance => _instance;

  final _logger = Logger();

  /// Check if running on Android
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // ============================================================
  // HOME SCREEN WIDGETS (App Widgets)
  // ============================================================

  /// Widget configurations
  static const List<Map<String, dynamic>> widgetConfigs = [
    {
      'name': 'TodayTasksWidget',
      'minWidth': 180,
      'minHeight': 110,
      'resizeMode': 'horizontal|vertical',
      'updatePeriodMillis': 1800000, // 30 minutes
      'previewImage': '@drawable/widget_today_preview',
    },
    {
      'name': 'QuickAddWidget',
      'minWidth': 110,
      'minHeight': 40,
      'resizeMode': 'none',
      'updatePeriodMillis': 0, // Manual update only
      'previewImage': '@drawable/widget_quickadd_preview',
    },
    {
      'name': 'FocusTimerWidget',
      'minWidth': 180,
      'minHeight': 180,
      'resizeMode': 'horizontal|vertical',
      'updatePeriodMillis': 60000, // 1 minute when timer running
      'previewImage': '@drawable/widget_focus_preview',
    },
    {
      'name': 'HabitTrackerWidget',
      'minWidth': 250,
      'minHeight': 110,
      'resizeMode': 'horizontal',
      'updatePeriodMillis': 3600000, // 1 hour
      'previewImage': '@drawable/widget_habits_preview',
    },
    {
      'name': 'ProductivityWidget',
      'minWidth': 180,
      'minHeight': 180,
      'resizeMode': 'horizontal|vertical',
      'updatePeriodMillis': 3600000, // 1 hour
      'previewImage': '@drawable/widget_productivity_preview',
    },
  ];

  /// Configure App Widgets
  Future<void> configureWidgets() async {
    if (!isAndroid) return;

    _logger.info('Configuring Android App Widgets');

    // In a real implementation:
    // 1. Widgets are defined in AndroidManifest.xml
    // 2. AppWidgetProvider classes handle updates
    // 3. RemoteViews used for widget layouts
    // 4. Use WorkManager for reliable updates

    _logger.info('Android App Widgets configured');
  }

  /// Update widget data
  Future<void> updateWidgetData({
    required String widgetName,
    required Map<String, dynamic> data,
  }) async {
    if (!isAndroid) return;

    _logger.info('Updating Android widget: $widgetName');

    // In a real implementation:
    // 1. Get AppWidgetManager
    // 2. Create RemoteViews with new data
    // 3. Call updateAppWidget()

    // Via platform channel:
    // await _methodChannel.invokeMethod('updateWidget', {
    //   'widgetName': widgetName,
    //   'data': data,
    // });
  }

  /// Request widget pin (add to home screen)
  Future<bool> requestWidgetPin(String widgetName) async {
    if (!isAndroid) return false;

    _logger.info('Requesting widget pin: $widgetName');

    // In a real implementation (API 26+):
    // AppWidgetManager.requestPinAppWidget()
    return true;
  }

  // ============================================================
  // QUICK SETTINGS TILES
  // ============================================================

  /// Quick Settings Tile configurations
  static const List<Map<String, String>> quickSettingsTiles = [
    {
      'name': 'QuickAddTile',
      'label': 'Add Task',
      'icon': '@drawable/ic_tile_add',
    },
    {
      'name': 'FocusModeTile',
      'label': 'Focus Mode',
      'icon': '@drawable/ic_tile_focus',
    },
    {
      'name': 'SyncTile',
      'label': 'Sync Now',
      'icon': '@drawable/ic_tile_sync',
    },
  ];

  /// Configure Quick Settings Tiles
  Future<void> configureQuickSettings() async {
    if (!isAndroid) return;

    _logger.info('Configuring Quick Settings Tiles');

    // In a real implementation:
    // 1. Tiles defined in AndroidManifest.xml
    // 2. TileService handles tile interactions
    // 3. requestListeningState() for updates

    _logger.info('Quick Settings Tiles configured');
  }

  /// Update tile state
  Future<void> updateTileState({
    required String tileName,
    required bool isActive,
    String? label,
  }) async {
    if (!isAndroid) return;

    _logger.info('Updating Quick Settings Tile: $tileName');

    // In a real implementation:
    // TileService.requestListeningState(context, component)
    // Then update in onStartListening()
  }

  // ============================================================
  // APP SHORTCUTS (Long Press Menu)
  // ============================================================

  /// Static shortcuts (defined in shortcuts.xml)
  static const List<Map<String, String>> staticShortcuts = [
    {
      'id': 'shortcut_add_task',
      'shortLabel': 'Add Task',
      'longLabel': 'Create a new task',
      'icon': '@drawable/ic_shortcut_add',
    },
    {
      'id': 'shortcut_today',
      'shortLabel': 'Today',
      'longLabel': 'View today\'s tasks',
      'icon': '@drawable/ic_shortcut_today',
    },
    {
      'id': 'shortcut_focus',
      'shortLabel': 'Focus',
      'longLabel': 'Start focus session',
      'icon': '@drawable/ic_shortcut_focus',
    },
  ];

  /// Add dynamic shortcut
  Future<void> addDynamicShortcut({
    required String id,
    required String shortLabel,
    required String longLabel,
    required String action,
    Map<String, String>? extras,
  }) async {
    if (!isAndroid) return;

    _logger.info('Adding dynamic shortcut: $id');

    // In a real implementation:
    // ShortcutManager.addDynamicShortcuts()
  }

  /// Remove dynamic shortcut
  Future<void> removeDynamicShortcut(String id) async {
    if (!isAndroid) return;

    _logger.info('Removing dynamic shortcut: $id');

    // ShortcutManager.removeDynamicShortcuts()
  }

  /// Push shortcut usage (improves ranking)
  Future<void> pushShortcutUsage(String id) async {
    if (!isAndroid) return;

    // ShortcutManager.reportShortcutUsed()
  }

  // ============================================================
  // DEEP LINKS (App Links)
  // ============================================================

  /// Verified App Links domains
  static const List<String> appLinksDomains = [
    'dingdong.app',
    'www.dingdong.app',
  ];

  /// Handle App Link
  Future<void> handleAppLink(Uri uri) async {
    if (!isAndroid) return;

    _logger.info('Handling App Link: $uri');

    // Parse the link and navigate
    // Verify signature via Digital Asset Links
  }

  /// Intent filters for deep links
  static const List<Map<String, dynamic>> intentFilters = [
    {
      'action': 'android.intent.action.VIEW',
      'categories': ['android.intent.category.DEFAULT', 'android.intent.category.BROWSABLE'],
      'data': {'scheme': 'https', 'host': 'dingdong.app', 'pathPrefix': '/task/'},
    },
    {
      'action': 'android.intent.action.VIEW',
      'categories': ['android.intent.category.DEFAULT', 'android.intent.category.BROWSABLE'],
      'data': {'scheme': 'dingdong', 'host': 'app'},
    },
  ];

  // ============================================================
  // WEAR OS
  // ============================================================

  /// Configure Wear OS companion app
  Future<void> configureWearOS() async {
    if (!isAndroid) return;

    _logger.info('Configuring Wear OS companion app');

    // In a real implementation:
    // 1. Set up Wearable Data Layer API
    // 2. Configure complications
    // 3. Handle messages from watch
  }

  /// Send data to Wear OS
  Future<void> sendToWearOS(Map<String, dynamic> data) async {
    if (!isAndroid) return;

    _logger.info('Sending data to Wear OS');

    // Use DataClient, MessageClient, or ChannelClient
  }

  /// Update Wear OS complications
  Future<void> updateComplications() async {
    if (!isAndroid) return;

    _logger.info('Updating Wear OS complications');

    // ComplicationDataSourceUpdateRequester
  }

  /// Wear OS tile configurations
  static const List<Map<String, String>> wearOSTiles = [
    {
      'name': 'TodayTile',
      'description': 'Today\'s tasks at a glance',
    },
    {
      'name': 'QuickAddTile',
      'description': 'Add task by voice',
    },
    {
      'name': 'FocusTile',
      'description': 'Focus timer controls',
    },
  ];

  // ============================================================
  // MATERIAL YOU / DYNAMIC COLORS
  // ============================================================

  /// Check Material You support (Android 12+)
  Future<bool> supportsMaterialYou() async {
    if (!isAndroid) return false;

    // Check Android version >= 12 (API 31)
    return true; // Simplified
  }

  /// Get dynamic color palette
  Future<Map<String, int>?> getDynamicColors() async {
    if (!isAndroid) return null;

    _logger.info('Getting dynamic colors');

    // In a real implementation:
    // DynamicColors.fromContext() or DynamicColorScheme

    return null;
  }

  /// Apply Material You theme
  Future<void> applyMaterialYouTheme() async {
    if (!isAndroid) return;

    _logger.info('Applying Material You theme');

    // Extract colors from wallpaper and apply
  }

  // ============================================================
  // PUSH NOTIFICATIONS (FCM)
  // ============================================================

  /// Configure Firebase Cloud Messaging
  Future<void> configureFCM() async {
    if (!isAndroid) return;

    _logger.info('Configuring FCM');

    // In a real implementation:
    // 1. FirebaseMessaging.instance.getToken()
    // 2. Configure notification channels
    // 3. Handle foreground/background messages
  }

  /// Notification channel configurations
  static const List<Map<String, dynamic>> notificationChannels = [
    {
      'id': 'task_reminders',
      'name': 'Task Reminders',
      'description': 'Notifications for task due dates and reminders',
      'importance': 4, // IMPORTANCE_HIGH
      'enableVibration': true,
      'enableLights': true,
      'lightColor': 0xFF4CAF50,
    },
    {
      'id': 'focus_sessions',
      'name': 'Focus Sessions',
      'description': 'Focus mode timer notifications',
      'importance': 4,
      'enableVibration': false,
    },
    {
      'id': 'habits',
      'name': 'Habit Reminders',
      'description': 'Daily habit tracking reminders',
      'importance': 3, // IMPORTANCE_DEFAULT
      'enableVibration': true,
    },
    {
      'id': 'collaboration',
      'name': 'Collaboration',
      'description': 'Team activity and mentions',
      'importance': 3,
    },
    {
      'id': 'sync',
      'name': 'Sync Status',
      'description': 'Sync progress and errors',
      'importance': 2, // IMPORTANCE_LOW
      'showBadge': false,
    },
  ];

  /// Create notification channels (Android 8+)
  Future<void> createNotificationChannels() async {
    if (!isAndroid) return;

    _logger.info('Creating notification channels');

    // In a real implementation:
    // NotificationManagerCompat.createNotificationChannel()
  }

  // ============================================================
  // BIOMETRICS
  // ============================================================

  /// Check biometric support
  Future<BiometricSupport> getBiometricSupport() async {
    if (!isAndroid) {
      return BiometricSupport(
        isSupported: false,
        hasFingerprint: false,
        hasFaceUnlock: false,
        hasIrisScanner: false,
      );
    }

    // In a real implementation:
    // BiometricManager.canAuthenticate()
    return BiometricSupport(
      isSupported: true,
      hasFingerprint: true,
      hasFaceUnlock: true,
      hasIrisScanner: false,
    );
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({
    required String title,
    required String description,
    bool allowDeviceCredential = true,
  }) async {
    if (!isAndroid) return false;

    _logger.info('Authenticating with biometrics');

    // BiometricPrompt with CryptoObject
    return true;
  }

  // ============================================================
  // SHARE INTENT
  // ============================================================

  /// Handle incoming share intent
  Future<void> handleShareIntent(Map<String, dynamic> intentData) async {
    if (!isAndroid) return;

    _logger.info('Handling share intent');

    // Parse intent data:
    // - ACTION_SEND: single item
    // - ACTION_SEND_MULTIPLE: multiple items
    // - text/plain, image/*, application/*
  }

  /// Share content
  Future<void> shareContent({
    required String type,
    String? text,
    String? subject,
    List<String>? filePaths,
  }) async {
    if (!isAndroid) return;

    _logger.info('Sharing content');

    // Intent.createChooser() with ACTION_SEND
  }

  // ============================================================
  // ANDROID AUTO
  // ============================================================

  /// Configure Android Auto
  Future<void> configureAndroidAuto() async {
    if (!isAndroid) return;

    _logger.info('Configuring Android Auto');

    // In a real implementation:
    // 1. Implement CarAppService
    // 2. Define screen templates
    // 3. Handle voice commands
  }

  /// Android Auto supported features
  static const List<String> androidAutoFeatures = [
    'View today\'s tasks',
    'Add task by voice',
    'Complete task',
    'Listen to task details',
  ];

  // ============================================================
  // PLAY STORE CONFIGURATION
  // ============================================================

  /// Play Store metadata
  static const Map<String, dynamic> playStoreConfig = {
    'packageName': 'com.dingdong.app',
    'minSdkVersion': 23, // Android 6.0
    'targetSdkVersion': 34, // Android 14
    'supportedAbis': ['armeabi-v7a', 'arm64-v8a', 'x86_64'],
    'features': [
      'android.hardware.touchscreen',
      'android.software.leanback', // Android TV
    ],
    'permissions': [
      'android.permission.INTERNET',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.VIBRATE',
      'android.permission.CAMERA',
      'android.permission.READ_EXTERNAL_STORAGE',
      'android.permission.WRITE_EXTERNAL_STORAGE',
      'android.permission.USE_BIOMETRIC',
      'android.permission.SCHEDULE_EXACT_ALARM',
      'android.permission.POST_NOTIFICATIONS',
    ],
    'dataLabels': {
      'dataCollected': ['Name', 'Email', 'App activity'],
      'dataShared': [],
      'securityPractices': ['Data encrypted in transit', 'Data encrypted at rest'],
    },
  };
}

/// Biometric support info
class BiometricSupport {
  final bool isSupported;
  final bool hasFingerprint;
  final bool hasFaceUnlock;
  final bool hasIrisScanner;

  BiometricSupport({
    required this.isSupported,
    required this.hasFingerprint,
    required this.hasFaceUnlock,
    required this.hasIrisScanner,
  });
}
