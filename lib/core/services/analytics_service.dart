import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Analytics Service
///
/// Centralizes analytics tracking across multiple providers:
/// - Firebase Analytics
/// - Mixpanel
/// - Custom analytics
///
/// Usage:
/// ```dart
/// final analytics = AnalyticsService.instance;
/// analytics.trackEvent('task_created', {'priority': 'high'});
/// analytics.setUserProperty('subscription_plan', 'premium');
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  final _logger = Logger();

  bool _initialized = false;
  String? _userId;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_initialized) return;

    _logger.info('Initializing Analytics Service');

    // In a real implementation:
    // 1. Initialize Firebase Analytics
    // 2. Initialize Mixpanel
    // 3. Configure user consent

    _initialized = true;
    _logger.info('Analytics Service initialized');
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) async {
    _userId = userId;

    if (userId != null) {
      _logger.info('Analytics: User ID set');

      // Firebase Analytics
      // await FirebaseAnalytics.instance.setUserId(id: userId);

      // Mixpanel
      // Mixpanel.identify(userId);
    } else {
      _logger.info('Analytics: User ID cleared');

      // Firebase Analytics
      // await FirebaseAnalytics.instance.setUserId(id: null);

      // Mixpanel
      // Mixpanel.reset();
    }
  }

  // ============================================================
  // USER PROPERTIES
  // ============================================================

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    _logger.debug('Analytics: Set user property $name = $value');

    // Firebase Analytics
    // await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);

    // Mixpanel
    // Mixpanel.registerSuperProperties({name: value});
  }

  /// Set multiple user properties
  Future<void> setUserProperties(Map<String, String?> properties) async {
    for (final entry in properties.entries) {
      await setUserProperty(name: entry.key, value: entry.value);
    }
  }

  // ============================================================
  // EVENT TRACKING
  // ============================================================

  /// Track custom event
  Future<void> trackEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    if (!kReleaseMode) {
      _logger.debug('Analytics: $name ${parameters ?? {}}');
    }

    // Firebase Analytics
    // await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

    // Mixpanel
    // Mixpanel.track(name, properties: parameters);
  }

  // ============================================================
  // SCREEN TRACKING
  // ============================================================

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _logger.debug('Analytics: Screen view - $screenName');

    // Firebase Analytics
    // await FirebaseAnalytics.instance.setCurrentScreen(
    //   screenName: screenName,
    //   screenClassOverride: screenClass,
    // );

    // Mixpanel
    // Mixpanel.track('Screen View', properties: {'screen_name': screenName});
  }

  // ============================================================
  // PREDEFINED EVENTS
  // ============================================================

  // Auth Events
  Future<void> trackSignUp(String method) =>
      trackEvent('sign_up', parameters: {'method': method});

  Future<void> trackLogin(String method) =>
      trackEvent('login', parameters: {'method': method});

  Future<void> trackLogout() => trackEvent('logout');

  // Task Events
  Future<void> trackTaskCreated({
    String? listId,
    String? priority,
    bool hasDueDate = false,
    bool hasReminder = false,
    int tagCount = 0,
  }) =>
      trackEvent('task_created', parameters: {
        'list_id': listId,
        'priority': priority,
        'has_due_date': hasDueDate,
        'has_reminder': hasReminder,
        'tag_count': tagCount,
      });

  Future<void> trackTaskCompleted({
    String? taskId,
    bool wasOverdue = false,
    int daysBeforeDue = 0,
  }) =>
      trackEvent('task_completed', parameters: {
        'was_overdue': wasOverdue,
        'days_before_due': daysBeforeDue,
      });

  Future<void> trackTaskDeleted() => trackEvent('task_deleted');

  Future<void> trackTaskMoved({
    required String fromListId,
    required String toListId,
  }) =>
      trackEvent('task_moved', parameters: {
        'from_list_id': fromListId,
        'to_list_id': toListId,
      });

  // List Events
  Future<void> trackListCreated({String? color, bool isShared = false}) =>
      trackEvent('list_created', parameters: {
        'color': color,
        'is_shared': isShared,
      });

  Future<void> trackListShared({int memberCount = 1}) =>
      trackEvent('list_shared', parameters: {
        'member_count': memberCount,
      });

  // Focus Session Events
  Future<void> trackFocusSessionStarted({
    required int duration,
    String? taskId,
  }) =>
      trackEvent('focus_session_started', parameters: {
        'duration_minutes': duration,
        'has_task': taskId != null,
      });

  Future<void> trackFocusSessionCompleted({
    required int duration,
    required int actualDuration,
  }) =>
      trackEvent('focus_session_completed', parameters: {
        'planned_duration': duration,
        'actual_duration': actualDuration,
        'completed_percentage': (actualDuration / duration * 100).round(),
      });

  Future<void> trackFocusSessionCancelled({required int elapsedTime}) =>
      trackEvent('focus_session_cancelled', parameters: {
        'elapsed_time': elapsedTime,
      });

  // Habit Events
  Future<void> trackHabitCreated({
    required String frequency,
    required int targetCount,
  }) =>
      trackEvent('habit_created', parameters: {
        'frequency': frequency,
        'target_count': targetCount,
      });

  Future<void> trackHabitCompleted({required int currentStreak}) =>
      trackEvent('habit_completed', parameters: {
        'current_streak': currentStreak,
      });

  // Integration Events
  Future<void> trackIntegrationConnected({required String integration}) =>
      trackEvent('integration_connected', parameters: {
        'integration': integration,
      });

  Future<void> trackIntegrationDisconnected({required String integration}) =>
      trackEvent('integration_disconnected', parameters: {
        'integration': integration,
      });

  // AI Events
  Future<void> trackAIImageRecognition({
    required bool success,
    int tasksCreated = 0,
  }) =>
      trackEvent('ai_image_recognition', parameters: {
        'success': success,
        'tasks_created': tasksCreated,
      });

  Future<void> trackAINLPParsing({required bool success}) =>
      trackEvent('ai_nlp_parsing', parameters: {
        'success': success,
      });

  // Subscription Events
  Future<void> trackSubscriptionStarted({
    required String plan,
    required String source,
  }) =>
      trackEvent('subscription_started', parameters: {
        'plan': plan,
        'source': source,
      });

  Future<void> trackSubscriptionCancelled({required String plan}) =>
      trackEvent('subscription_cancelled', parameters: {
        'plan': plan,
      });

  Future<void> trackSubscriptionRenewed({required String plan}) =>
      trackEvent('subscription_renewed', parameters: {
        'plan': plan,
      });

  // Feature Usage Events
  Future<void> trackFeatureUsed(String featureName) =>
      trackEvent('feature_used', parameters: {
        'feature': featureName,
      });

  Future<void> trackSearchPerformed({
    required String query,
    int resultCount = 0,
  }) =>
      trackEvent('search_performed', parameters: {
        'query_length': query.length,
        'result_count': resultCount,
      });

  // Error Events
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) =>
      trackEvent('app_error', parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      });

  // ============================================================
  // TIMING EVENTS
  // ============================================================

  /// Track timing event (e.g., app launch time)
  Future<void> trackTiming({
    required String category,
    required String variable,
    required int valueMs,
    String? label,
  }) async {
    _logger.debug('Analytics: Timing $category/$variable = ${valueMs}ms');

    // Custom event for timing
    await trackEvent('timing_event', parameters: {
      'category': category,
      'variable': variable,
      'value_ms': valueMs,
      'label': label,
    });
  }

  // ============================================================
  // CONSENT MANAGEMENT
  // ============================================================

  /// Set analytics consent
  Future<void> setAnalyticsConsent({
    required bool analyticsEnabled,
    required bool personalizationEnabled,
  }) async {
    _logger.info(
        'Analytics: Consent updated - analytics: $analyticsEnabled, personalization: $personalizationEnabled');

    // Firebase Analytics
    // await FirebaseAnalytics.instance.setConsent(
    //   analyticsStorageConsentGranted: analyticsEnabled,
    //   adStorageConsentGranted: false,
    //   adUserDataConsentGranted: false,
    //   adPersonalizationConsentGranted: personalizationEnabled,
    // );
  }

  /// Opt out of analytics
  Future<void> optOut() async {
    _logger.info('Analytics: User opted out');

    // Firebase Analytics
    // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);

    // Mixpanel
    // Mixpanel.optOutTracking();
  }

  /// Opt back in to analytics
  Future<void> optIn() async {
    _logger.info('Analytics: User opted in');

    // Firebase Analytics
    // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // Mixpanel
    // Mixpanel.optInTracking();
  }

  // ============================================================
  // RESET
  // ============================================================

  /// Reset analytics (on logout)
  Future<void> reset() async {
    _logger.info('Analytics: Resetting');
    _userId = null;

    // Firebase Analytics
    // await FirebaseAnalytics.instance.resetAnalyticsData();

    // Mixpanel
    // Mixpanel.reset();
  }
}
