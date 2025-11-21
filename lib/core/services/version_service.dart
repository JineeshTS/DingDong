import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';

/// Version Service
///
/// Manages app version information, update checking, and release tracking.
///
/// Usage:
/// ```dart
/// final version = VersionService.instance;
/// print('Current version: ${version.currentVersion}');
/// final hasUpdate = await version.checkForUpdate();
/// ```
class VersionService {
  VersionService._();

  static final VersionService _instance = VersionService._();
  static VersionService get instance => _instance;

  final _logger = Logger();

  // ============================================================
  // VERSION INFORMATION
  // ============================================================

  /// Current app version
  static const String currentVersion = '1.0.0';

  /// Current build number
  static const int buildNumber = 1;

  /// Version name (for display)
  static const String versionName = 'DingDong 1.0.0';

  /// Build configuration
  static const String buildConfig = String.fromEnvironment(
    'BUILD_CONFIG',
    defaultValue: 'debug',
  );

  /// Build timestamp (set during CI/CD)
  static const String buildTimestamp = String.fromEnvironment(
    'BUILD_TIMESTAMP',
    defaultValue: '',
  );

  /// Git commit hash (set during CI/CD)
  static const String gitCommitHash = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: 'unknown',
  );

  /// Git branch (set during CI/CD)
  static const String gitBranch = String.fromEnvironment(
    'GIT_BRANCH',
    defaultValue: 'unknown',
  );

  /// Is release build
  static const bool isReleaseBuild = bool.fromEnvironment(
    'RELEASE_BUILD',
    defaultValue: false,
  );

  // ============================================================
  // VERSION PARSING
  // ============================================================

  /// Parse semantic version
  SemanticVersion get semanticVersion => SemanticVersion.parse(currentVersion);

  /// Get version display string
  String get displayVersion {
    if (buildConfig == 'release') {
      return 'v$currentVersion';
    }
    return 'v$currentVersion ($buildConfig)';
  }

  /// Get full version string with build info
  String get fullVersionString {
    final buffer = StringBuffer('v$currentVersion');
    buffer.write(' (Build $buildNumber)');

    if (buildConfig != 'release') {
      buffer.write(' [$buildConfig]');
    }

    if (gitCommitHash != 'unknown') {
      buffer.write(' @ ${gitCommitHash.substring(0, 7)}');
    }

    return buffer.toString();
  }

  // ============================================================
  // PLATFORM VERSION INFO
  // ============================================================

  /// Get platform-specific version info
  Map<String, dynamic> get platformVersionInfo {
    return {
      'app_version': currentVersion,
      'build_number': buildNumber,
      'build_config': buildConfig,
      'platform': _platformName,
      'platform_version': _platformVersion,
      'git_commit': gitCommitHash,
      'git_branch': gitBranch,
      'build_timestamp': buildTimestamp,
    };
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  String get _platformVersion {
    if (kIsWeb) return 'web';
    return Platform.operatingSystemVersion;
  }

  // ============================================================
  // UPDATE CHECKING
  // ============================================================

  /// Check if an update is available
  Future<UpdateInfo?> checkForUpdate() async {
    _logger.info('Checking for updates...');

    try {
      // In a real implementation:
      // 1. Fetch latest version from server/store
      // 2. Compare with current version
      // 3. Return update info if available

      // Example API call:
      // final response = await http.get(Uri.parse('$apiBaseUrl/version/latest'));
      // final data = jsonDecode(response.body);
      // final latestVersion = SemanticVersion.parse(data['version']);
      //
      // if (latestVersion > semanticVersion) {
      //   return UpdateInfo(
      //     version: data['version'],
      //     releaseNotes: data['release_notes'],
      //     isForced: data['is_forced'] ?? false,
      //     downloadUrl: data['download_url'],
      //   );
      // }

      return null;
    } catch (e) {
      _logger.error('Failed to check for updates: $e');
      return null;
    }
  }

  /// Check if update is forced (breaking changes)
  Future<bool> isUpdateForced() async {
    final updateInfo = await checkForUpdate();
    return updateInfo?.isForced ?? false;
  }

  /// Get release notes for version
  Future<String?> getReleaseNotes(String version) async {
    _logger.info('Fetching release notes for $version');

    try {
      // Fetch from server
      // final response = await http.get(Uri.parse('$apiBaseUrl/version/$version/notes'));
      // return response.body;

      return null;
    } catch (e) {
      _logger.error('Failed to fetch release notes: $e');
      return null;
    }
  }

  // ============================================================
  // STORE LINKS
  // ============================================================

  /// App Store link (iOS)
  static const String appStoreLink = 'https://apps.apple.com/app/dingdong/id0000000000';

  /// Play Store link (Android)
  static const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.dingdong.app';

  /// Microsoft Store link (Windows)
  static const String microsoftStoreLink = 'ms-windows-store://pdp/?ProductId=0000000000';

  /// Mac App Store link (macOS)
  static const String macAppStoreLink = 'https://apps.apple.com/app/dingdong/id0000000000';

  /// Snap Store link (Linux)
  static const String snapStoreLink = 'snap://dingdong';

  /// Get store link for current platform
  String? get storeLink {
    if (kIsWeb) return null;
    if (Platform.isIOS) return appStoreLink;
    if (Platform.isAndroid) return playStoreLink;
    if (Platform.isWindows) return microsoftStoreLink;
    if (Platform.isMacOS) return macAppStoreLink;
    if (Platform.isLinux) return snapStoreLink;
    return null;
  }

  // ============================================================
  // FEATURE FLAGS
  // ============================================================

  /// Feature flags based on version
  static const Map<String, dynamic> featureFlags = {
    // Features enabled in this version
    'ai_image_recognition': true,
    'voice_input': true,
    'widgets': true,
    'collaborations': true,
    'calendar_sync': true,
    'dark_mode': true,
    'biometric_auth': true,

    // Beta features
    'beta_ai_suggestions': false,
    'beta_smart_scheduling': false,

    // A/B test features
    'ab_new_onboarding': false,
    'ab_gamification': false,
  };

  /// Check if feature is enabled
  bool isFeatureEnabled(String feature) {
    return featureFlags[feature] ?? false;
  }

  // ============================================================
  // MINIMUM SUPPORTED VERSIONS
  // ============================================================

  /// Minimum supported iOS version
  static const String minIOSVersion = '13.0';

  /// Minimum supported Android SDK
  static const int minAndroidSdk = 21; // Android 5.0

  /// Minimum supported macOS version
  static const String minMacOSVersion = '10.14';

  /// Minimum supported Windows version
  static const String minWindowsVersion = '10.0.17763'; // Windows 10 1809

  // ============================================================
  // VERSION COMPARISON HISTORY
  // ============================================================

  /// Check if this is a fresh install
  Future<bool> isFreshInstall() async {
    // Check if there's a stored previous version
    // final prefs = await SharedPreferences.getInstance();
    // return !prefs.containsKey('app_version');

    return false;
  }

  /// Check if app was updated since last launch
  Future<bool> wasJustUpdated() async {
    // final prefs = await SharedPreferences.getInstance();
    // final storedVersion = prefs.getString('app_version');
    // return storedVersion != null && storedVersion != currentVersion;

    return false;
  }

  /// Get previous version (before update)
  Future<String?> getPreviousVersion() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('app_version');

    return null;
  }

  /// Save current version (call after showing update notes)
  Future<void> saveCurrentVersion() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('app_version', currentVersion);
    // await prefs.setInt('build_number', buildNumber);

    _logger.info('Version saved: $currentVersion');
  }

  // ============================================================
  // DEPRECATION WARNINGS
  // ============================================================

  /// API version
  static const String apiVersion = 'v1';

  /// Check if API version is deprecated
  Future<bool> isApiDeprecated() async {
    // Check server for API deprecation status
    return false;
  }

  /// Get migration instructions for deprecated API
  Future<String?> getApiMigrationInstructions() async {
    return null;
  }
}

/// Semantic version representation
class SemanticVersion implements Comparable<SemanticVersion> {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? buildMetadata;

  const SemanticVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
    this.buildMetadata,
  });

  /// Parse version string (e.g., "1.2.3-beta+build.123")
  factory SemanticVersion.parse(String version) {
    final regex = RegExp(
      r'^(\d+)\.(\d+)\.(\d+)(?:-([a-zA-Z0-9.-]+))?(?:\+([a-zA-Z0-9.-]+))?$',
    );

    final match = regex.firstMatch(version);
    if (match == null) {
      throw FormatException('Invalid version format: $version');
    }

    return SemanticVersion(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      preRelease: match.group(4),
      buildMetadata: match.group(5),
    );
  }

  /// Check if this is a pre-release version
  bool get isPreRelease => preRelease != null;

  /// Get version string without metadata
  String get versionString {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (preRelease != null) {
      buffer.write('-$preRelease');
    }
    return buffer.toString();
  }

  /// Get full version string
  @override
  String toString() {
    final buffer = StringBuffer(versionString);
    if (buildMetadata != null) {
      buffer.write('+$buildMetadata');
    }
    return buffer.toString();
  }

  @override
  int compareTo(SemanticVersion other) {
    // Compare major
    if (major != other.major) return major.compareTo(other.major);

    // Compare minor
    if (minor != other.minor) return minor.compareTo(other.minor);

    // Compare patch
    if (patch != other.patch) return patch.compareTo(other.patch);

    // Pre-release versions have lower precedence
    if (preRelease != null && other.preRelease == null) return -1;
    if (preRelease == null && other.preRelease != null) return 1;
    if (preRelease != null && other.preRelease != null) {
      return preRelease!.compareTo(other.preRelease!);
    }

    return 0;
  }

  bool operator <(SemanticVersion other) => compareTo(other) < 0;
  bool operator >(SemanticVersion other) => compareTo(other) > 0;
  bool operator <=(SemanticVersion other) => compareTo(other) <= 0;
  bool operator >=(SemanticVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticVersion &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          preRelease == other.preRelease;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);
}

/// Update information
class UpdateInfo {
  final String version;
  final String? releaseNotes;
  final bool isForced;
  final String? downloadUrl;
  final DateTime? releaseDate;

  const UpdateInfo({
    required this.version,
    this.releaseNotes,
    this.isForced = false,
    this.downloadUrl,
    this.releaseDate,
  });

  SemanticVersion get semanticVersion => SemanticVersion.parse(version);
}
