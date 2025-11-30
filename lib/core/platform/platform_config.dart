import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform Configuration Service
///
/// Centralized service for handling platform-specific configurations,
/// feature detection, and platform-dependent behavior across all
/// supported platforms: iOS, Android, Web, macOS, Windows, Linux.
class PlatformConfig {
  PlatformConfig._();

  static final PlatformConfig _instance = PlatformConfig._();
  static PlatformConfig get instance => _instance;

  /// Current platform type
  PlatformType get currentPlatform {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isIOS) return PlatformType.iOS;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isMacOS) return PlatformType.macOS;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.unknown;
  }

  /// Check if running on mobile (iOS or Android)
  bool get isMobile =>
      currentPlatform == PlatformType.iOS ||
      currentPlatform == PlatformType.android;

  /// Check if running on desktop (macOS, Windows, Linux)
  bool get isDesktop =>
      currentPlatform == PlatformType.macOS ||
      currentPlatform == PlatformType.windows ||
      currentPlatform == PlatformType.linux;

  /// Check if running on web
  bool get isWeb => currentPlatform == PlatformType.web;

  /// Check if running on Apple platform (iOS or macOS)
  bool get isApple =>
      currentPlatform == PlatformType.iOS ||
      currentPlatform == PlatformType.macOS;

  /// Get platform-specific features
  PlatformFeatures get features => _getPlatformFeatures();

  PlatformFeatures _getPlatformFeatures() {
    switch (currentPlatform) {
      case PlatformType.iOS:
        return const IOSFeatures();
      case PlatformType.android:
        return const AndroidFeatures();
      case PlatformType.web:
        return const WebFeatures();
      case PlatformType.macOS:
        return const MacOSFeatures();
      case PlatformType.windows:
        return const WindowsFeatures();
      case PlatformType.linux:
        return const LinuxFeatures();
      default:
        return const DefaultFeatures();
    }
  }

  /// Get minimum supported OS version string
  String get minimumOSVersion {
    switch (currentPlatform) {
      case PlatformType.iOS:
        return 'iOS 13.0';
      case PlatformType.android:
        return 'Android 6.0 (API 23)';
      case PlatformType.macOS:
        return 'macOS 10.14';
      case PlatformType.windows:
        return 'Windows 10';
      case PlatformType.linux:
        return 'Ubuntu 18.04 / equivalent';
      case PlatformType.web:
        return 'Modern browsers (Chrome 80+, Firefox 75+, Safari 13+, Edge 80+)';
      default:
        return 'Unknown';
    }
  }
}

/// Platform types
enum PlatformType {
  iOS,
  android,
  web,
  macOS,
  windows,
  linux,
  unknown,
}

/// Abstract class for platform-specific features
abstract class PlatformFeatures {
  const PlatformFeatures();

  /// Whether the platform supports widgets (home screen, lock screen, etc.)
  bool get supportsWidgets;

  /// Whether the platform supports system tray/menu bar
  bool get supportsSystemTray;

  /// Whether the platform supports native notifications
  bool get supportsNotifications;

  /// Whether the platform supports biometric authentication
  bool get supportsBiometrics;

  /// Whether the platform supports keyboard shortcuts
  bool get supportsKeyboardShortcuts;

  /// Whether the platform supports haptic feedback
  bool get supportsHaptics;

  /// Whether the platform supports share extensions
  bool get supportsShareExtension;

  /// Whether the platform supports deep linking
  bool get supportsDeepLinking;

  /// Whether the platform supports background tasks
  bool get supportsBackgroundTasks;

  /// Whether the platform supports offline mode
  bool get supportsOfflineMode;

  /// Whether the platform supports file system access
  bool get supportsFileSystem;

  /// Whether the platform supports camera
  bool get supportsCamera;

  /// Whether the platform supports location services
  bool get supportsLocation;

  /// List of supported features as strings
  List<String> get supportedFeaturesList;
}

/// iOS-specific features
class IOSFeatures extends PlatformFeatures {
  const IOSFeatures();

  @override
  bool get supportsWidgets => true; // Home Screen, Lock Screen, Today widgets

  @override
  bool get supportsSystemTray => false;

  @override
  bool get supportsNotifications => true;

  @override
  bool get supportsBiometrics => true; // Face ID, Touch ID

  @override
  bool get supportsKeyboardShortcuts => true; // iPad with keyboard

  @override
  bool get supportsHaptics => true; // 3D Touch, Haptic Touch

  @override
  bool get supportsShareExtension => true;

  @override
  bool get supportsDeepLinking => true; // Universal Links

  @override
  bool get supportsBackgroundTasks => true;

  @override
  bool get supportsOfflineMode => true;

  @override
  bool get supportsFileSystem => true; // Sandboxed

  @override
  bool get supportsCamera => true;

  @override
  bool get supportsLocation => true;

  /// iOS-specific: Siri Shortcuts support
  bool get supportsSiriShortcuts => true;

  /// iOS-specific: App Clips support
  bool get supportsAppClips => true;

  /// iOS-specific: Apple Watch companion app
  bool get supportsWatchApp => true;

  /// iOS-specific: iCloud sync
  bool get supportsICloud => true;

  @override
  List<String> get supportedFeaturesList => [
        'Home Screen Widgets',
        'Lock Screen Widgets',
        'Today Widgets',
        'Siri Shortcuts',
        'App Clips',
        'Share Extension',
        'Action Extension',
        'Face ID / Touch ID',
        '3D Touch / Haptic Touch',
        'Push Notifications',
        'Universal Links',
        'Background App Refresh',
        'iCloud Sync',
        'Apple Watch App',
      ];
}

/// Android-specific features
class AndroidFeatures extends PlatformFeatures {
  const AndroidFeatures();

  @override
  bool get supportsWidgets => true; // Home Screen widgets

  @override
  bool get supportsSystemTray => false;

  @override
  bool get supportsNotifications => true;

  @override
  bool get supportsBiometrics => true; // Fingerprint, Face Unlock

  @override
  bool get supportsKeyboardShortcuts => true; // Chrome OS, tablets

  @override
  bool get supportsHaptics => true;

  @override
  bool get supportsShareExtension => true;

  @override
  bool get supportsDeepLinking => true; // App Links

  @override
  bool get supportsBackgroundTasks => true;

  @override
  bool get supportsOfflineMode => true;

  @override
  bool get supportsFileSystem => true;

  @override
  bool get supportsCamera => true;

  @override
  bool get supportsLocation => true;

  /// Android-specific: Quick Settings Tiles
  bool get supportsQuickSettings => true;

  /// Android-specific: App Shortcuts (long press icon)
  bool get supportsAppShortcuts => true;

  /// Android-specific: Wear OS companion app
  bool get supportsWearOS => true;

  @override
  List<String> get supportedFeaturesList => [
        'Home Screen Widgets',
        'Quick Settings Tiles',
        'App Shortcuts',
        'Share Intent',
        'Fingerprint / Face Unlock',
        'Haptic Feedback',
        'Push Notifications',
        'App Links (Deep Linking)',
        'Background Services',
        'Wear OS App',
      ];
}

/// Web/PWA-specific features
class WebFeatures extends PlatformFeatures {
  const WebFeatures();

  @override
  bool get supportsWidgets => false;

  @override
  bool get supportsSystemTray => false;

  @override
  bool get supportsNotifications => true; // Web Push Notifications

  @override
  bool get supportsBiometrics => true; // WebAuthn

  @override
  bool get supportsKeyboardShortcuts => true;

  @override
  bool get supportsHaptics => true; // Vibration API

  @override
  bool get supportsShareExtension => true; // Web Share API

  @override
  bool get supportsDeepLinking => true; // URL routing

  @override
  bool get supportsBackgroundTasks => true; // Service Workers

  @override
  bool get supportsOfflineMode => true; // Service Workers

  @override
  bool get supportsFileSystem => true; // File System Access API

  @override
  bool get supportsCamera => true; // MediaDevices API

  @override
  bool get supportsLocation => true; // Geolocation API

  /// Web-specific: PWA installable
  bool get supportsPWAInstall => true;

  /// Web-specific: Service Worker
  bool get supportsServiceWorker => true;

  @override
  List<String> get supportedFeaturesList => [
        'Progressive Web App (PWA)',
        'Install to Home Screen',
        'Offline Support (Service Worker)',
        'Web Push Notifications',
        'Web Share API',
        'Keyboard Shortcuts',
        'WebAuthn (Biometrics)',
        'File System Access',
        'Responsive Design',
        'Cross-browser Support',
      ];
}

/// macOS-specific features
class MacOSFeatures extends PlatformFeatures {
  const MacOSFeatures();

  @override
  bool get supportsWidgets => true; // Notification Center widgets

  @override
  bool get supportsSystemTray => true; // Menu Bar

  @override
  bool get supportsNotifications => true;

  @override
  bool get supportsBiometrics => true; // Touch ID

  @override
  bool get supportsKeyboardShortcuts => true;

  @override
  bool get supportsHaptics => true; // Force Touch trackpad

  @override
  bool get supportsShareExtension => true;

  @override
  bool get supportsDeepLinking => true; // URL Schemes

  @override
  bool get supportsBackgroundTasks => true;

  @override
  bool get supportsOfflineMode => true;

  @override
  bool get supportsFileSystem => true;

  @override
  bool get supportsCamera => true;

  @override
  bool get supportsLocation => true;

  /// macOS-specific: Menu Bar app
  bool get supportsMenuBarApp => true;

  /// macOS-specific: Touch Bar
  bool get supportsTouchBar => true;

  /// macOS-specific: Spotlight integration
  bool get supportsSpotlight => true;

  @override
  List<String> get supportedFeaturesList => [
        'Native Menu Bar',
        'Menu Bar App',
        'Touch Bar Support',
        'Keyboard Shortcuts',
        'System Notifications',
        'Touch ID',
        'Spotlight Integration',
        'Share Extension',
        'iCloud Sync',
        'Notification Center Widgets',
      ];
}

/// Windows-specific features
class WindowsFeatures extends PlatformFeatures {
  const WindowsFeatures();

  @override
  bool get supportsWidgets => true; // Windows 11 widgets

  @override
  bool get supportsSystemTray => true;

  @override
  bool get supportsNotifications => true; // Windows Toast

  @override
  bool get supportsBiometrics => true; // Windows Hello

  @override
  bool get supportsKeyboardShortcuts => true;

  @override
  bool get supportsHaptics => false;

  @override
  bool get supportsShareExtension => true; // Share Contract

  @override
  bool get supportsDeepLinking => true; // Protocol handlers

  @override
  bool get supportsBackgroundTasks => true;

  @override
  bool get supportsOfflineMode => true;

  @override
  bool get supportsFileSystem => true;

  @override
  bool get supportsCamera => true;

  @override
  bool get supportsLocation => true;

  /// Windows-specific: Jump List
  bool get supportsJumpList => true;

  /// Windows-specific: Live Tiles (deprecated in Win 11)
  bool get supportsLiveTiles => true;

  @override
  List<String> get supportedFeaturesList => [
        'System Tray',
        'Jump List',
        'Keyboard Shortcuts',
        'Windows Toast Notifications',
        'Windows Hello',
        'Share Contract',
        'Protocol Handlers',
        'Windows 11 Widgets',
      ];
}

/// Linux-specific features
class LinuxFeatures extends PlatformFeatures {
  const LinuxFeatures();

  @override
  bool get supportsWidgets => false;

  @override
  bool get supportsSystemTray => true; // AppIndicator

  @override
  bool get supportsNotifications => true; // libnotify

  @override
  bool get supportsBiometrics => false; // Limited support

  @override
  bool get supportsKeyboardShortcuts => true;

  @override
  bool get supportsHaptics => false;

  @override
  bool get supportsShareExtension => false;

  @override
  bool get supportsDeepLinking => true; // Desktop files

  @override
  bool get supportsBackgroundTasks => true;

  @override
  bool get supportsOfflineMode => true;

  @override
  bool get supportsFileSystem => true;

  @override
  bool get supportsCamera => true;

  @override
  bool get supportsLocation => true;

  @override
  List<String> get supportedFeaturesList => [
        'System Tray (AppIndicator)',
        'Desktop Notifications',
        'Keyboard Shortcuts',
        'Desktop Integration',
        'Multiple Package Formats (AppImage, Snap, Flatpak, .deb)',
      ];
}

/// Default features for unknown platforms
class DefaultFeatures extends PlatformFeatures {
  const DefaultFeatures();

  @override
  bool get supportsWidgets => false;
  @override
  bool get supportsSystemTray => false;
  @override
  bool get supportsNotifications => true;
  @override
  bool get supportsBiometrics => false;
  @override
  bool get supportsKeyboardShortcuts => true;
  @override
  bool get supportsHaptics => false;
  @override
  bool get supportsShareExtension => false;
  @override
  bool get supportsDeepLinking => false;
  @override
  bool get supportsBackgroundTasks => false;
  @override
  bool get supportsOfflineMode => true;
  @override
  bool get supportsFileSystem => true;
  @override
  bool get supportsCamera => false;
  @override
  bool get supportsLocation => false;
  @override
  List<String> get supportedFeaturesList => ['Basic Features'];
}
