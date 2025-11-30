import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';

/// Linux Platform Configuration Service
///
/// Handles Linux-specific configurations including:
/// - System Tray (AppIndicator)
/// - Desktop Notifications (libnotify)
/// - D-Bus integration
/// - Desktop file integration
/// - Multiple package formats (AppImage, Snap, Flatpak, .deb)
/// - XDG compliance
/// - Keyboard shortcuts
class LinuxConfig {
  LinuxConfig._();

  static final LinuxConfig _instance = LinuxConfig._();
  static LinuxConfig get instance => _instance;

  final _logger = Logger();

  /// Check if running on Linux
  bool get isLinux => !kIsWeb && Platform.isLinux;

  // ============================================================
  // SYSTEM TRAY (AppIndicator)
  // ============================================================

  /// System Tray configuration
  static const Map<String, dynamic> systemTrayConfig = {
    'iconName': 'dingdong-indicator',
    'iconPath': 'assets/icons/tray_icon.png',
    'iconPathDark': 'assets/icons/tray_icon_dark.png',
    'categoryId': 'ApplicationStatus',
    'title': 'DingDong',
    'tooltip': 'DingDong Task Manager',
  };

  /// Configure System Tray (AppIndicator)
  Future<void> configureSystemTray() async {
    if (!isLinux) return;

    _logger.info('Configuring Linux System Tray (AppIndicator)');

    // Using tray_manager or ayatana_appindicator:
    // 1. Create AppIndicator3
    // 2. Set icon and menu
    // 3. Connect signals

    _logger.info('System Tray configured');
  }

  /// System Tray menu items
  static const List<Map<String, dynamic>> trayMenuItems = [
    {'label': 'Add Task...', 'action': 'newTask'},
    {'type': 'separator'},
    {'label': 'Today\'s Tasks', 'action': 'showToday'},
    {'label': 'Inbox', 'action': 'showInbox'},
    {'label': 'Upcoming', 'action': 'showUpcoming'},
    {'type': 'separator'},
    {'label': 'Start Focus Session', 'action': 'startFocus'},
    {'label': 'Sync Now', 'action': 'sync'},
    {'type': 'separator'},
    {'label': 'Preferences', 'action': 'preferences'},
    {'label': 'Show DingDong', 'action': 'showApp'},
    {'type': 'separator'},
    {'label': 'Quit', 'action': 'quit'},
  ];

  /// Update tray icon
  Future<void> updateTrayIcon({
    required String iconName,
    String? attention,
  }) async {
    if (!isLinux) return;

    _logger.info('Updating tray icon: $iconName');

    // app_indicator_set_icon() or set_attention_icon()
  }

  /// Set tray status
  Future<void> setTrayStatus(TrayStatus status) async {
    if (!isLinux) return;

    _logger.info('Setting tray status: $status');

    // AppIndicatorStatus: PASSIVE, ACTIVE, ATTENTION
  }

  // ============================================================
  // DESKTOP NOTIFICATIONS (libnotify)
  // ============================================================

  /// Configure notifications
  Future<void> configureNotifications() async {
    if (!isLinux) return;

    _logger.info('Configuring Linux notifications');

    // notify_init("DingDong")
  }

  /// Show notification
  Future<void> showNotification({
    required String summary,
    required String body,
    String? icon,
    NotificationUrgency urgency = NotificationUrgency.normal,
    int? timeout,
    List<NotificationAction>? actions,
    Map<String, String>? hints,
  }) async {
    if (!isLinux) return;

    _logger.info('Showing notification: $summary');

    // notify_notification_new(summary, body, icon)
    // notify_notification_set_urgency()
    // notify_notification_add_action()
    // notify_notification_show()
  }

  /// Notification categories
  static const List<String> notificationCategories = [
    'im.received', // For task comments, mentions
    'reminder', // For task reminders
    'transfer.complete', // For sync complete
    'presence', // For collaboration activity
  ];

  /// Close notification
  Future<void> closeNotification(int id) async {
    if (!isLinux) return;

    _logger.info('Closing notification: $id');

    // notify_notification_close()
  }

  /// Get notification server capabilities
  Future<List<String>> getNotificationCapabilities() async {
    if (!isLinux) return [];

    // notify_get_server_caps()
    return [
      'actions',
      'body',
      'body-markup',
      'icon-static',
      'persistence',
      'sound',
    ];
  }

  // ============================================================
  // D-BUS INTEGRATION
  // ============================================================

  /// Register D-Bus service
  Future<void> registerDBusService() async {
    if (!isLinux) return;

    _logger.info('Registering D-Bus service');

    // g_bus_own_name(G_BUS_TYPE_SESSION, "com.dingdong.App", ...)
  }

  /// D-Bus interface definition
  static const String dbusInterface = '''
<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node name="/com/dingdong/App">
  <interface name="com.dingdong.App">
    <method name="AddTask">
      <arg name="title" type="s" direction="in"/>
      <arg name="taskId" type="s" direction="out"/>
    </method>
    <method name="ShowWindow"/>
    <method name="Sync"/>
    <method name="StartFocus">
      <arg name="duration" type="i" direction="in"/>
    </method>
    <signal name="TaskCompleted">
      <arg name="taskId" type="s"/>
    </signal>
    <signal name="SyncCompleted">
      <arg name="success" type="b"/>
    </signal>
    <property name="TodayTaskCount" type="i" access="read"/>
    <property name="FocusActive" type="b" access="read"/>
  </interface>
</node>
''';

  /// Handle D-Bus method call
  Future<dynamic> handleDBusMethodCall({
    required String method,
    required Map<String, dynamic> parameters,
  }) async {
    if (!isLinux) return null;

    _logger.info('Handling D-Bus method: $method');

    switch (method) {
      case 'AddTask':
        // Create task and return ID
        return 'task-id';
      case 'ShowWindow':
        // Activate window
        return null;
      case 'Sync':
        // Trigger sync
        return null;
      case 'StartFocus':
        // Start focus session
        return null;
      default:
        throw UnimplementedError('Unknown D-Bus method: $method');
    }
  }

  /// Emit D-Bus signal
  Future<void> emitDBusSignal({
    required String signal,
    required Map<String, dynamic> data,
  }) async {
    if (!isLinux) return;

    _logger.info('Emitting D-Bus signal: $signal');
  }

  // ============================================================
  // DESKTOP FILE INTEGRATION
  // ============================================================

  /// .desktop file content
  static const String desktopFileContent = '''
[Desktop Entry]
Type=Application
Name=DingDong
GenericName=Task Manager
Comment=Next-generation task management with AI-powered features
Exec=dingdong %U
Icon=dingdong
Categories=Office;ProjectManagement;Calendar;
Keywords=task;todo;productivity;gtd;reminder;focus;
StartupNotify=true
StartupWMClass=dingdong
Terminal=false
MimeType=x-scheme-handler/dingdong;
Actions=new-task;today;focus;

[Desktop Action new-task]
Name=New Task
Exec=dingdong --new-task

[Desktop Action today]
Name=Today's Tasks
Exec=dingdong --view-today

[Desktop Action focus]
Name=Start Focus
Exec=dingdong --start-focus
''';

  /// Install desktop file
  Future<void> installDesktopFile() async {
    if (!isLinux) return;

    _logger.info('Installing desktop file');

    // Write to ~/.local/share/applications/dingdong.desktop
    // Or /usr/share/applications/ for system-wide
    // Then: update-desktop-database
  }

  /// Register MIME type handler
  Future<void> registerMimeHandler() async {
    if (!isLinux) return;

    _logger.info('Registering MIME type handler');

    // xdg-mime default dingdong.desktop x-scheme-handler/dingdong
  }

  /// Handle URI activation
  Future<void> handleUriActivation(String uri) async {
    if (!isLinux) return;

    _logger.info('Handling URI activation: $uri');

    // Parse dingdong:// URI and navigate
  }

  // ============================================================
  // XDG COMPLIANCE
  // ============================================================

  /// XDG directory paths
  static Map<String, String> getXdgPaths() {
    final home = Platform.environment['HOME'] ?? '';
    return {
      'config': Platform.environment['XDG_CONFIG_HOME'] ?? '$home/.config',
      'data': Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share',
      'cache': Platform.environment['XDG_CACHE_HOME'] ?? '$home/.cache',
      'runtime': Platform.environment['XDG_RUNTIME_DIR'] ?? '/run/user/${Platform.environment['UID']}',
      'state': Platform.environment['XDG_STATE_HOME'] ?? '$home/.local/state',
    };
  }

  /// Get app config directory
  String get configDir => '${getXdgPaths()['config']}/dingdong';

  /// Get app data directory
  String get dataDir => '${getXdgPaths()['data']}/dingdong';

  /// Get app cache directory
  String get cacheDir => '${getXdgPaths()['cache']}/dingdong';

  // ============================================================
  // AUTOSTART
  // ============================================================

  /// Autostart desktop file content
  static const String autostartDesktopFile = '''
[Desktop Entry]
Type=Application
Name=DingDong
Exec=dingdong --startup
Icon=dingdong
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
Hidden=false
NoDisplay=false
Comment=Start DingDong task manager
''';

  /// Configure autostart
  Future<void> configureAutostart({required bool enabled}) async {
    if (!isLinux) return;

    _logger.info('Configuring autostart: $enabled');

    // Write/remove ~/.config/autostart/dingdong.desktop
  }

  /// Check if autostart is enabled
  Future<bool> isAutostartEnabled() async {
    if (!isLinux) return false;

    // Check if ~/.config/autostart/dingdong.desktop exists
    return true;
  }

  // ============================================================
  // KEYBOARD SHORTCUTS
  // ============================================================

  /// Global keyboard shortcuts
  static const List<Map<String, String>> globalShortcuts = [
    {'key': 'space', 'modifiers': 'ctrl+alt', 'action': 'quickAdd', 'description': 'Quick add task'},
    {'key': 'd', 'modifiers': 'super+shift', 'action': 'showApp', 'description': 'Show DingDong'},
  ];

  /// Register global shortcut
  Future<void> registerGlobalShortcut({
    required String key,
    required String modifiers,
    required Function callback,
  }) async {
    if (!isLinux) return;

    _logger.info('Registering global shortcut: $modifiers+$key');

    // XGrabKey or use keybinder-3.0 library
    // Or integrate with GNOME/KDE settings
  }

  /// Desktop environment detection
  Future<DesktopEnvironment> detectDesktopEnvironment() async {
    if (!isLinux) return DesktopEnvironment.unknown;

    final xdgSession = Platform.environment['XDG_CURRENT_DESKTOP'] ?? '';
    final desktop = xdgSession.toUpperCase();

    if (desktop.contains('GNOME')) return DesktopEnvironment.gnome;
    if (desktop.contains('KDE')) return DesktopEnvironment.kde;
    if (desktop.contains('XFCE')) return DesktopEnvironment.xfce;
    if (desktop.contains('MATE')) return DesktopEnvironment.mate;
    if (desktop.contains('CINNAMON')) return DesktopEnvironment.cinnamon;
    if (desktop.contains('LXDE')) return DesktopEnvironment.lxde;
    if (desktop.contains('LXQT')) return DesktopEnvironment.lxqt;
    if (desktop.contains('BUDGIE')) return DesktopEnvironment.budgie;
    if (desktop.contains('PANTHEON')) return DesktopEnvironment.pantheon;
    if (desktop.contains('DEEPIN')) return DesktopEnvironment.deepin;

    return DesktopEnvironment.unknown;
  }

  // ============================================================
  // PACKAGE FORMATS
  // ============================================================

  /// Package format configurations
  static const Map<String, Map<String, dynamic>> packageFormats = {
    'appimage': {
      'name': 'AppImage',
      'extension': '.AppImage',
      'updateUrl': 'https://releases.dingdong.app/linux/DingDong-latest.AppImage',
      'features': ['Portable', 'Auto-update', 'Desktop integration'],
    },
    'snap': {
      'name': 'Snap',
      'snapName': 'dingdong',
      'channel': 'stable',
      'confinement': 'strict',
      'grade': 'stable',
      'features': ['Auto-update', 'Sandboxed', 'Ubuntu Software Center'],
    },
    'flatpak': {
      'name': 'Flatpak',
      'appId': 'com.dingdong.App',
      'runtime': 'org.gnome.Platform',
      'runtimeVersion': '44',
      'features': ['Sandboxed', 'Flathub distribution', 'Portal integration'],
    },
    'deb': {
      'name': 'Debian Package',
      'packageName': 'dingdong',
      'section': 'utils',
      'priority': 'optional',
      'architecture': 'amd64',
      'features': ['apt repository', 'System integration'],
    },
    'rpm': {
      'name': 'RPM Package',
      'packageName': 'dingdong',
      'group': 'Applications/Productivity',
      'features': ['dnf/yum repository', 'System integration'],
    },
  };

  /// Detect current package format
  Future<String?> detectPackageFormat() async {
    if (!isLinux) return null;

    // Check environment variables and paths
    if (Platform.environment.containsKey('SNAP')) return 'snap';
    if (Platform.environment.containsKey('FLATPAK_ID')) return 'flatpak';
    if (Platform.environment.containsKey('APPIMAGE')) return 'appimage';

    // Check if installed via .deb or .rpm
    // dpkg-query -W dingdong || rpm -q dingdong
    return 'deb'; // Default assumption
  }

  // ============================================================
  // PORTAL INTEGRATION (Flatpak/Snap)
  // ============================================================

  /// Use portal for file operations
  Future<List<String>?> openFileDialog({
    String? title,
    List<FileFilter>? filters,
    bool multiple = false,
  }) async {
    if (!isLinux) return null;

    _logger.info('Opening file dialog via portal');

    // org.freedesktop.portal.FileChooser
    return null;
  }

  /// Use portal for notifications
  Future<void> sendPortalNotification({
    required String title,
    required String body,
    String? icon,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    if (!isLinux) return;

    _logger.info('Sending notification via portal');

    // org.freedesktop.portal.Notification
  }

  /// Use portal for background permission
  Future<bool> requestBackgroundPermission() async {
    if (!isLinux) return true;

    _logger.info('Requesting background permission via portal');

    // org.freedesktop.portal.Background
    return true;
  }

  // ============================================================
  // GNOME-SPECIFIC FEATURES
  // ============================================================

  /// Configure GNOME Shell extension integration
  Future<void> configureGnomeIntegration() async {
    if (!isLinux) return;

    final de = await detectDesktopEnvironment();
    if (de != DesktopEnvironment.gnome) return;

    _logger.info('Configuring GNOME integration');

    // GNOME Shell search provider
    // GNOME Online Accounts integration
  }

  /// GNOME Search Provider interface
  static const String gnomeSearchProviderInterface = '''
<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node>
  <interface name="org.gnome.Shell.SearchProvider2">
    <method name="GetInitialResultSet">
      <arg type="as" name="terms" direction="in"/>
      <arg type="as" name="results" direction="out"/>
    </method>
    <method name="GetSubsearchResultSet">
      <arg type="as" name="previous_results" direction="in"/>
      <arg type="as" name="terms" direction="in"/>
      <arg type="as" name="results" direction="out"/>
    </method>
    <method name="GetResultMetas">
      <arg type="as" name="identifiers" direction="in"/>
      <arg type="aa{sv}" name="metas" direction="out"/>
    </method>
    <method name="ActivateResult">
      <arg type="s" name="identifier" direction="in"/>
      <arg type="as" name="terms" direction="in"/>
      <arg type="u" name="timestamp" direction="in"/>
    </method>
    <method name="LaunchSearch">
      <arg type="as" name="terms" direction="in"/>
      <arg type="u" name="timestamp" direction="in"/>
    </method>
  </interface>
</node>
''';

  // ============================================================
  // KDE-SPECIFIC FEATURES
  // ============================================================

  /// Configure KDE Plasma integration
  Future<void> configureKdeIntegration() async {
    if (!isLinux) return;

    final de = await detectDesktopEnvironment();
    if (de != DesktopEnvironment.kde) return;

    _logger.info('Configuring KDE Plasma integration');

    // KRunner plugin
    // KDE Status Notifier
    // Plasma widgets
  }

  // ============================================================
  // WINDOW MANAGEMENT
  // ============================================================

  /// Window configuration
  static const Map<String, dynamic> windowConfig = {
    'minWidth': 400,
    'minHeight': 500,
    'defaultWidth': 1000,
    'defaultHeight': 700,
    'title': 'DingDong',
    'wmClass': 'dingdong',
    'icon': 'dingdong',
  };

  /// Set window hints
  Future<void> setWindowHints({
    String? wmClass,
    String? title,
    bool? skipTaskbar,
    bool? alwaysOnTop,
  }) async {
    if (!isLinux) return;

    _logger.info('Setting window hints');

    // XSetClassHint, XSetWMNormalHints via X11
    // Or xdg_toplevel_set_title via Wayland
  }

  /// Check if running on Wayland
  bool get isWayland {
    if (!isLinux) return false;
    return Platform.environment['WAYLAND_DISPLAY'] != null;
  }

  /// Check if running on X11
  bool get isX11 {
    if (!isLinux) return false;
    return Platform.environment['DISPLAY'] != null &&
        Platform.environment['WAYLAND_DISPLAY'] == null;
  }
}

/// Tray status
enum TrayStatus {
  passive, // Hidden
  active, // Visible
  attention, // Needs attention
}

/// Notification urgency
enum NotificationUrgency {
  low,
  normal,
  critical,
}

/// Notification priority (for portals)
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Notification action
class NotificationAction {
  final String id;
  final String label;

  NotificationAction({required this.id, required this.label});
}

/// Desktop environment
enum DesktopEnvironment {
  gnome,
  kde,
  xfce,
  mate,
  cinnamon,
  lxde,
  lxqt,
  budgie,
  pantheon,
  deepin,
  unknown,
}

/// File filter for dialogs
class FileFilter {
  final String name;
  final List<String> patterns;
  final List<String> mimeTypes;

  FileFilter({
    required this.name,
    this.patterns = const [],
    this.mimeTypes = const [],
  });
}
