import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Crash Reporting Service
///
/// Centralizes crash reporting and error tracking across multiple providers:
/// - Firebase Crashlytics
/// - Sentry
/// - Custom error logging
///
/// Usage:
/// ```dart
/// final crashReporting = CrashReportingService.instance;
/// crashReporting.recordError(exception, stackTrace);
/// crashReporting.log('User performed action X');
/// ```
class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService _instance = CrashReportingService._();
  static CrashReportingService get instance => _instance;

  final _logger = Logger();

  bool _initialized = false;
  String? _userId;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize crash reporting service
  Future<void> initialize() async {
    if (_initialized) return;

    _logger.info('Initializing Crash Reporting Service');

    // In a real implementation:
    // 1. Initialize Firebase Crashlytics
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    //
    // 2. Initialize Sentry
    // await SentryFlutter.init((options) {
    //   options.dsn = 'YOUR_SENTRY_DSN';
    //   options.tracesSampleRate = 1.0;
    // });
    //
    // 3. Set up Flutter error handling
    // FlutterError.onError = (details) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    // };
    //
    // 4. Set up Platform error handling
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };

    _setupErrorHandlers();

    _initialized = true;
    _logger.info('Crash Reporting Service initialized');
  }

  /// Set up global error handlers
  void _setupErrorHandlers() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.error('Flutter Error: ${details.exceptionAsString()}');
      recordFlutterError(details);
    };

    // Catch errors outside Flutter framework
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   recordError(error, stack, fatal: true);
    //   return true;
    // };
  }

  // ============================================================
  // USER IDENTIFICATION
  // ============================================================

  /// Set user ID for crash reports
  Future<void> setUserId(String? userId) async {
    _userId = userId;

    if (userId != null) {
      _logger.info('Crash Reporting: User ID set');

      // Firebase Crashlytics
      // await FirebaseCrashlytics.instance.setUserIdentifier(userId);

      // Sentry
      // Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId)));
    } else {
      _logger.info('Crash Reporting: User ID cleared');

      // Firebase Crashlytics
      // await FirebaseCrashlytics.instance.setUserIdentifier('');

      // Sentry
      // Sentry.configureScope((scope) => scope.setUser(null));
    }
  }

  /// Set custom user properties
  Future<void> setUserProperties(Map<String, String> properties) async {
    _logger.debug('Crash Reporting: Setting user properties');

    for (final entry in properties.entries) {
      // Firebase Crashlytics
      // await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);

      // Sentry
      // Sentry.configureScope((scope) => scope.setTag(entry.key, entry.value));
    }
  }

  // ============================================================
  // ERROR RECORDING
  // ============================================================

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? information,
  }) async {
    if (!kReleaseMode) {
      _logger.error('Error: $exception');
      if (stackTrace != null) {
        _logger.error('Stack trace: $stackTrace');
      }
    }

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.recordError(
    //   exception,
    //   stackTrace,
    //   reason: reason,
    //   fatal: fatal,
    //   information: information?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    // );

    // Sentry
    // await Sentry.captureException(
    //   exception,
    //   stackTrace: stackTrace,
    //   hint: Hint.withMap({'reason': reason, ...?information}),
    // );
  }

  /// Record a Flutter framework error
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    _logger.error('Flutter Error: ${details.exceptionAsString()}');

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.recordFlutterError(details);

    // Sentry
    // await Sentry.captureException(
    //   details.exception,
    //   stackTrace: details.stack,
    // );
  }

  /// Record a fatal error (causes crash report)
  Future<void> recordFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: true,
    );
  }

  // ============================================================
  // CUSTOM LOGGING
  // ============================================================

  /// Log a message to crash reporting
  Future<void> log(String message) async {
    if (!kReleaseMode) {
      _logger.debug('Crash Log: $message');
    }

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.log(message);

    // Sentry
    // Sentry.addBreadcrumb(Breadcrumb(message: message));
  }

  /// Set custom key-value pair
  Future<void> setCustomKey(String key, dynamic value) async {
    _logger.debug('Crash Reporting: Setting $key = $value');

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.setCustomKey(key, value);

    // Sentry
    // Sentry.configureScope((scope) => scope.setExtra(key, value));
  }

  /// Set multiple custom key-value pairs
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    for (final entry in keys.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }

  // ============================================================
  // BREADCRUMBS
  // ============================================================

  /// Add a breadcrumb for debugging
  Future<void> addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    BreadcrumbLevel level = BreadcrumbLevel.info,
  }) async {
    _logger.debug('Breadcrumb: $message');

    // Sentry
    // Sentry.addBreadcrumb(Breadcrumb(
    //   message: message,
    //   category: category,
    //   data: data,
    //   level: _mapLevel(level),
    // ));
  }

  /// Add navigation breadcrumb
  Future<void> addNavigationBreadcrumb({
    required String from,
    required String to,
  }) async {
    await addBreadcrumb(
      message: 'Navigation: $from → $to',
      category: 'navigation',
      data: {'from': from, 'to': to},
    );
  }

  /// Add user action breadcrumb
  Future<void> addUserActionBreadcrumb({
    required String action,
    String? target,
    Map<String, dynamic>? data,
  }) async {
    await addBreadcrumb(
      message: 'User Action: $action',
      category: 'user',
      data: {'action': action, 'target': target, ...?data},
    );
  }

  /// Add network breadcrumb
  Future<void> addNetworkBreadcrumb({
    required String method,
    required String url,
    int? statusCode,
    String? reason,
  }) async {
    await addBreadcrumb(
      message: 'HTTP $method $url',
      category: 'http',
      data: {
        'method': method,
        'url': url,
        if (statusCode != null) 'status_code': statusCode,
        if (reason != null) 'reason': reason,
      },
      level: statusCode != null && statusCode >= 400
          ? BreadcrumbLevel.error
          : BreadcrumbLevel.info,
    );
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  /// Record app launch
  Future<void> recordAppLaunch({
    required Duration launchDuration,
    bool isFirstLaunch = false,
  }) async {
    await log('App launched in ${launchDuration.inMilliseconds}ms');
    await setCustomKeys({
      'launch_duration_ms': launchDuration.inMilliseconds,
      'is_first_launch': isFirstLaunch,
    });
  }

  /// Record app backgrounded
  Future<void> recordAppBackgrounded() async {
    await addBreadcrumb(
      message: 'App backgrounded',
      category: 'app.lifecycle',
    );
  }

  /// Record app resumed
  Future<void> recordAppResumed() async {
    await addBreadcrumb(
      message: 'App resumed',
      category: 'app.lifecycle',
    );
  }

  // ============================================================
  // PERFORMANCE MONITORING
  // ============================================================

  /// Start a performance trace
  Future<PerformanceTrace> startTrace(String name) async {
    _logger.debug('Starting trace: $name');

    // Firebase Performance
    // final trace = FirebasePerformance.instance.newTrace(name);
    // await trace.start();
    // return FirebasePerformanceTrace(trace);

    // Sentry
    // final transaction = Sentry.startTransaction(name, 'task');
    // return SentryPerformanceTrace(transaction);

    return _MockPerformanceTrace(name);
  }

  /// Record a metric
  Future<void> recordMetric({
    required String name,
    required int value,
    String? unit,
  }) async {
    _logger.debug('Metric: $name = $value${unit != null ? ' $unit' : ''}');

    // Custom metric recording
  }

  // ============================================================
  // NETWORK MONITORING
  // ============================================================

  /// Record HTTP request metrics
  Future<void> recordHttpMetrics({
    required String url,
    required String method,
    required int requestSize,
    required int responseSize,
    required int statusCode,
    required Duration duration,
  }) async {
    _logger.debug('HTTP Metrics: $method $url - ${statusCode} in ${duration.inMilliseconds}ms');

    // Firebase Performance
    // final metric = FirebasePerformance.instance.newHttpMetric(url, HttpMethod.values.byName(method.toLowerCase()));
    // metric.requestPayloadSize = requestSize;
    // metric.responsePayloadSize = responseSize;
    // metric.httpResponseCode = statusCode;
    // await metric.stop();
  }

  // ============================================================
  // CONSENT & OPT-OUT
  // ============================================================

  /// Enable crash reporting collection
  Future<void> enableCollection() async {
    _logger.info('Crash Reporting: Collection enabled');

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  /// Disable crash reporting collection
  Future<void> disableCollection() async {
    _logger.info('Crash Reporting: Collection disabled');

    // Firebase Crashlytics
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  /// Check if crash reporting is enabled
  Future<bool> isCollectionEnabled() async {
    // Firebase Crashlytics
    // return FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;

    return true;
  }

  // ============================================================
  // TESTING
  // ============================================================

  /// Force a test crash (for testing crash reporting)
  Future<void> testCrash() async {
    if (kDebugMode) {
      _logger.warning('Test crash triggered');

      // Firebase Crashlytics
      // FirebaseCrashlytics.instance.crash();

      throw Exception('Test crash for crash reporting validation');
    }
  }

  /// Record a test non-fatal error
  Future<void> testNonFatal() async {
    await recordError(
      Exception('Test non-fatal error'),
      StackTrace.current,
      reason: 'Test error for crash reporting validation',
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  /// Reset crash reporting (on logout)
  Future<void> reset() async {
    _logger.info('Crash Reporting: Resetting');
    _userId = null;

    // Clear user identifier
    await setUserId(null);
  }
}

/// Breadcrumb severity level
enum BreadcrumbLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Performance trace interface
abstract class PerformanceTrace {
  Future<void> stop();
  Future<void> incrementMetric(String name, int value);
  Future<void> setMetric(String name, int value);
  Future<void> putAttribute(String name, String value);
}

/// Mock performance trace for development
class _MockPerformanceTrace implements PerformanceTrace {
  final String name;
  final DateTime _startTime;
  final Map<String, int> _metrics = {};
  final Map<String, String> _attributes = {};

  _MockPerformanceTrace(this.name) : _startTime = DateTime.now();

  @override
  Future<void> stop() async {
    final duration = DateTime.now().difference(_startTime);
    if (!kReleaseMode) {
      debugPrint('Trace "$name" completed in ${duration.inMilliseconds}ms');
      debugPrint('  Metrics: $_metrics');
      debugPrint('  Attributes: $_attributes');
    }
  }

  @override
  Future<void> incrementMetric(String name, int value) async {
    _metrics[name] = (_metrics[name] ?? 0) + value;
  }

  @override
  Future<void> setMetric(String name, int value) async {
    _metrics[name] = value;
  }

  @override
  Future<void> putAttribute(String name, String value) async {
    _attributes[name] = value;
  }
}
