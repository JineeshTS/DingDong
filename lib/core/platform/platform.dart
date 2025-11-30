/// Platform Configuration Module
///
/// This module provides platform-specific configuration services for all
/// supported platforms: iOS, Android, Web/PWA, macOS, Windows, and Linux.
///
/// Usage:
/// ```dart
/// import 'package:dingdong/core/platform/platform.dart';
///
/// // Get current platform type
/// final platformType = PlatformConfig.instance.currentPlatform;
///
/// // Check platform capabilities
/// final features = PlatformConfig.instance.features;
/// if (features.supportsWidgets) {
///   // Configure widgets
/// }
///
/// // Use platform-specific config
/// if (PlatformConfig.instance.isIOS) {
///   await IOSConfig.instance.configureSiriShortcuts();
/// } else if (PlatformConfig.instance.isAndroid) {
///   await AndroidConfig.instance.configureWidgets();
/// }
/// ```

library platform;

export 'platform_config.dart';
export 'ios_config.dart';
export 'android_config.dart';
export 'web_config.dart';
export 'macos_config.dart';
export 'windows_config.dart';
export 'linux_config.dart';
