import '../utils/logger.dart';

/// Remote Config Service
///
/// Manages remote configuration for feature flags, A/B testing,
/// and dynamic app configuration without app store updates.
///
/// Usage:
/// ```dart
/// final config = RemoteConfigService.instance;
/// await config.initialize();
/// final isEnabled = config.getBool('feature_x');
/// ```
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;

  final _logger = Logger();

  bool _initialized = false;
  final Map<String, dynamic> _cachedValues = {};

  // ============================================================
  // DEFAULT VALUES
  // ============================================================

  /// Default configuration values
  static const Map<String, dynamic> defaults = {
    // Feature Flags
    'feature_ai_enabled': true,
    'feature_voice_input_enabled': true,
    'feature_widgets_enabled': true,
    'feature_collaboration_enabled': true,
    'feature_dark_mode_enabled': true,
    'feature_biometric_enabled': true,

    // Beta Features
    'beta_ai_suggestions': false,
    'beta_smart_scheduling': false,
    'beta_gamification': false,

    // A/B Tests
    'ab_onboarding_variant': 'control',
    'ab_pricing_variant': 'control',
    'ab_home_layout_variant': 'control',

    // Limits
    'max_tasks_free': 100,
    'max_lists_free': 5,
    'max_attachments_per_task': 10,
    'max_collaborators_free': 3,
    'max_file_size_mb': 25,

    // Timeouts
    'sync_interval_seconds': 300,
    'api_timeout_seconds': 30,
    'cache_ttl_hours': 24,

    // URLs
    'support_url': 'https://support.dingdong.app',
    'privacy_url': 'https://dingdong.app/privacy',
    'terms_url': 'https://dingdong.app/terms',
    'feedback_url': 'https://feedback.dingdong.app',

    // Messages
    'maintenance_message': '',
    'update_message': '',
    'announcement_message': '',

    // Minimum Versions
    'min_ios_version': '1.0.0',
    'min_android_version': '1.0.0',
    'min_web_version': '1.0.0',

    // Analytics
    'analytics_enabled': true,
    'crash_reporting_enabled': true,
    'performance_monitoring_enabled': true,
  };

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize remote config
  Future<void> initialize() async {
    if (_initialized) return;

    _logger.info('Initializing Remote Config Service');

    try {
      // In a real implementation:
      // 1. Initialize Firebase Remote Config
      // final remoteConfig = FirebaseRemoteConfig.instance;
      //
      // 2. Set defaults
      // await remoteConfig.setDefaults(defaults);
      //
      // 3. Set fetch settings
      // await remoteConfig.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout: const Duration(minutes: 1),
      //   minimumFetchInterval: const Duration(hours: 1),
      // ));
      //
      // 4. Fetch and activate
      // await remoteConfig.fetchAndActivate();

      // Load defaults to cache
      _cachedValues.addAll(defaults);

      _initialized = true;
      _logger.info('Remote Config Service initialized');
    } catch (e) {
      _logger.error('Failed to initialize Remote Config: $e');
      _cachedValues.addAll(defaults);
      _initialized = true;
    }
  }

  /// Fetch latest config from server
  Future<bool> fetchAndActivate() async {
    _logger.info('Fetching remote config...');

    try {
      // Firebase Remote Config
      // final remoteConfig = FirebaseRemoteConfig.instance;
      // return await remoteConfig.fetchAndActivate();

      return true;
    } catch (e) {
      _logger.error('Failed to fetch remote config: $e');
      return false;
    }
  }

  /// Force fetch (bypasses cache)
  Future<bool> forceFetch() async {
    _logger.info('Force fetching remote config...');

    try {
      // Set minimum fetch interval to 0 temporarily
      // await remoteConfig.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout: const Duration(minutes: 1),
      //   minimumFetchInterval: Duration.zero,
      // ));
      //
      // final result = await remoteConfig.fetchAndActivate();
      //
      // Reset settings
      // await remoteConfig.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout: const Duration(minutes: 1),
      //   minimumFetchInterval: const Duration(hours: 1),
      // ));

      return true;
    } catch (e) {
      _logger.error('Failed to force fetch: $e');
      return false;
    }
  }

  // ============================================================
  // VALUE GETTERS
  // ============================================================

  /// Get string value
  String getString(String key) {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.getString(key);

    final value = _cachedValues[key];
    return value is String ? value : (defaults[key] as String? ?? '');
  }

  /// Get bool value
  bool getBool(String key) {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.getBool(key);

    final value = _cachedValues[key];
    return value is bool ? value : (defaults[key] as bool? ?? false);
  }

  /// Get int value
  int getInt(String key) {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.getInt(key);

    final value = _cachedValues[key];
    return value is int ? value : (defaults[key] as int? ?? 0);
  }

  /// Get double value
  double getDouble(String key) {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.getDouble(key);

    final value = _cachedValues[key];
    return value is double ? value : (defaults[key] as double? ?? 0.0);
  }

  /// Get all values
  Map<String, dynamic> getAll() {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.getAll();

    return Map.from(_cachedValues);
  }

  // ============================================================
  // FEATURE FLAGS
  // ============================================================

  /// Check if feature is enabled
  bool isFeatureEnabled(String feature) {
    return getBool('feature_${feature}_enabled');
  }

  /// Check if beta feature is enabled
  bool isBetaEnabled(String feature) {
    return getBool('beta_$feature');
  }

  /// Get A/B test variant
  String getABVariant(String test) {
    return getString('ab_${test}_variant');
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  /// AI features enabled
  bool get isAIEnabled => isFeatureEnabled('ai');

  /// Voice input enabled
  bool get isVoiceInputEnabled => isFeatureEnabled('voice_input');

  /// Widgets enabled
  bool get isWidgetsEnabled => isFeatureEnabled('widgets');

  /// Collaboration enabled
  bool get isCollaborationEnabled => isFeatureEnabled('collaboration');

  /// Dark mode enabled
  bool get isDarkModeEnabled => isFeatureEnabled('dark_mode');

  /// Biometric auth enabled
  bool get isBiometricEnabled => isFeatureEnabled('biometric');

  /// Analytics enabled
  bool get isAnalyticsEnabled => getBool('analytics_enabled');

  /// Crash reporting enabled
  bool get isCrashReportingEnabled => getBool('crash_reporting_enabled');

  /// Performance monitoring enabled
  bool get isPerformanceMonitoringEnabled => getBool('performance_monitoring_enabled');

  // ============================================================
  // LIMITS
  // ============================================================

  /// Max tasks for free users
  int get maxTasksFree => getInt('max_tasks_free');

  /// Max lists for free users
  int get maxListsFree => getInt('max_lists_free');

  /// Max attachments per task
  int get maxAttachmentsPerTask => getInt('max_attachments_per_task');

  /// Max collaborators for free users
  int get maxCollaboratorsFree => getInt('max_collaborators_free');

  /// Max file size in MB
  int get maxFileSizeMB => getInt('max_file_size_mb');

  // ============================================================
  // TIMEOUTS
  // ============================================================

  /// Sync interval
  Duration get syncInterval => Duration(seconds: getInt('sync_interval_seconds'));

  /// API timeout
  Duration get apiTimeout => Duration(seconds: getInt('api_timeout_seconds'));

  /// Cache TTL
  Duration get cacheTTL => Duration(hours: getInt('cache_ttl_hours'));

  // ============================================================
  // URLS
  // ============================================================

  /// Support URL
  String get supportUrl => getString('support_url');

  /// Privacy policy URL
  String get privacyUrl => getString('privacy_url');

  /// Terms of service URL
  String get termsUrl => getString('terms_url');

  /// Feedback URL
  String get feedbackUrl => getString('feedback_url');

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Maintenance message (empty if no maintenance)
  String get maintenanceMessage => getString('maintenance_message');

  /// Check if app is in maintenance mode
  bool get isMaintenanceMode => maintenanceMessage.isNotEmpty;

  /// Update message (empty if no message)
  String get updateMessage => getString('update_message');

  /// Announcement message (empty if no announcement)
  String get announcementMessage => getString('announcement_message');

  // ============================================================
  // VERSION REQUIREMENTS
  // ============================================================

  /// Minimum required iOS version
  String get minIOSVersion => getString('min_ios_version');

  /// Minimum required Android version
  String get minAndroidVersion => getString('min_android_version');

  /// Minimum required web version
  String get minWebVersion => getString('min_web_version');

  // ============================================================
  // LISTENERS
  // ============================================================

  /// Listen to config changes
  void addOnConfigUpdatedListener(Function(Set<String>) listener) {
    // Firebase Remote Config
    // FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) {
    //   listener(event.updatedKeys);
    // });
  }

  // ============================================================
  // CACHE MANAGEMENT
  // ============================================================

  /// Get last fetch time
  DateTime? get lastFetchTime {
    // Firebase Remote Config
    // return FirebaseRemoteConfig.instance.lastFetchTime;

    return null;
  }

  /// Get last fetch status
  RemoteConfigStatus get lastFetchStatus {
    // Firebase Remote Config
    // final status = FirebaseRemoteConfig.instance.lastFetchStatus;
    // return _mapStatus(status);

    return RemoteConfigStatus.success;
  }

  /// Clear local cache
  Future<void> clearCache() async {
    _logger.info('Clearing remote config cache');
    _cachedValues.clear();
    _cachedValues.addAll(defaults);
  }

  // ============================================================
  // DEBUG
  // ============================================================

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _initialized,
      'last_fetch_time': lastFetchTime?.toIso8601String(),
      'last_fetch_status': lastFetchStatus.name,
      'cached_values_count': _cachedValues.length,
    };
  }

  /// Override value for testing (debug only)
  void debugOverride(String key, dynamic value) {
    _cachedValues[key] = value;
  }
}

/// Remote config fetch status
enum RemoteConfigStatus {
  success,
  failure,
  noFetchYet,
  throttled,
}
