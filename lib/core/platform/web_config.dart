import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';

/// Web/PWA Platform Configuration Service
///
/// Handles Web-specific configurations including:
/// - Progressive Web App (PWA) features
/// - Service Worker for offline support
/// - Web Push Notifications
/// - Web Share API
/// - Web App Manifest
/// - IndexedDB for local storage
/// - WebAuthn for biometrics
/// - Keyboard shortcuts
class WebConfig {
  WebConfig._();

  static final WebConfig _instance = WebConfig._();
  static WebConfig get instance => _instance;

  final _logger = Logger();

  /// Check if running on web
  bool get isWeb => kIsWeb;

  // ============================================================
  // PWA CONFIGURATION
  // ============================================================

  /// Web App Manifest configuration
  static const Map<String, dynamic> webManifest = {
    'name': 'DingDong - Task Manager',
    'short_name': 'DingDong',
    'description': 'Next-generation task management with AI-powered features',
    'start_url': '/',
    'display': 'standalone',
    'orientation': 'any',
    'background_color': '#FFFFFF',
    'theme_color': '#4CAF50',
    'categories': ['productivity', 'utilities'],
    'lang': 'en',
    'dir': 'ltr',
    'scope': '/',
    'icons': [
      {'src': '/icons/icon-72.png', 'sizes': '72x72', 'type': 'image/png'},
      {'src': '/icons/icon-96.png', 'sizes': '96x96', 'type': 'image/png'},
      {'src': '/icons/icon-128.png', 'sizes': '128x128', 'type': 'image/png'},
      {'src': '/icons/icon-144.png', 'sizes': '144x144', 'type': 'image/png'},
      {'src': '/icons/icon-152.png', 'sizes': '152x152', 'type': 'image/png'},
      {'src': '/icons/icon-192.png', 'sizes': '192x192', 'type': 'image/png', 'purpose': 'any maskable'},
      {'src': '/icons/icon-384.png', 'sizes': '384x384', 'type': 'image/png'},
      {'src': '/icons/icon-512.png', 'sizes': '512x512', 'type': 'image/png', 'purpose': 'any maskable'},
    ],
    'screenshots': [
      {'src': '/screenshots/desktop.png', 'sizes': '1920x1080', 'type': 'image/png', 'form_factor': 'wide'},
      {'src': '/screenshots/mobile.png', 'sizes': '390x844', 'type': 'image/png', 'form_factor': 'narrow'},
    ],
    'shortcuts': [
      {
        'name': 'Add Task',
        'short_name': 'Add',
        'description': 'Create a new task',
        'url': '/task/new',
        'icons': [{'src': '/icons/shortcut-add.png', 'sizes': '96x96'}],
      },
      {
        'name': 'Today\'s Tasks',
        'short_name': 'Today',
        'description': 'View today\'s tasks',
        'url': '/today',
        'icons': [{'src': '/icons/shortcut-today.png', 'sizes': '96x96'}],
      },
      {
        'name': 'Focus Mode',
        'short_name': 'Focus',
        'description': 'Start a focus session',
        'url': '/focus',
        'icons': [{'src': '/icons/shortcut-focus.png', 'sizes': '96x96'}],
      },
    ],
    'related_applications': [
      {'platform': 'play', 'url': 'https://play.google.com/store/apps/details?id=com.dingdong.app'},
      {'platform': 'itunes', 'url': 'https://apps.apple.com/app/dingdong/id1234567890'},
    ],
    'prefer_related_applications': false,
    'share_target': {
      'action': '/share',
      'method': 'POST',
      'enctype': 'multipart/form-data',
      'params': {
        'title': 'title',
        'text': 'text',
        'url': 'url',
        'files': [
          {'name': 'files', 'accept': ['image/*', 'application/pdf']},
        ],
      },
    },
  };

  /// Check if PWA is installed
  Future<bool> isPWAInstalled() async {
    if (!isWeb) return false;

    // In a real implementation (JavaScript interop):
    // Check window.matchMedia('(display-mode: standalone)').matches
    // Or check navigator.standalone (iOS Safari)
    return false;
  }

  /// Prompt PWA installation
  Future<bool> promptInstall() async {
    if (!isWeb) return false;

    _logger.info('Prompting PWA installation');

    // In a real implementation:
    // 1. Listen for 'beforeinstallprompt' event
    // 2. Store the event
    // 3. Call event.prompt() when user requests install
    // 4. Check event.userChoice

    return false;
  }

  // ============================================================
  // SERVICE WORKER
  // ============================================================

  /// Service Worker configuration
  static const Map<String, dynamic> serviceWorkerConfig = {
    'cacheName': 'dingdong-cache-v1',
    'cacheStrategy': 'stale-while-revalidate',
    'offlineFallback': '/offline.html',
    'precacheResources': [
      '/',
      '/index.html',
      '/main.dart.js',
      '/flutter.js',
      '/manifest.json',
      '/assets/fonts/MaterialIcons-Regular.otf',
    ],
    'runtimeCache': [
      {
        'pattern': '/api/*',
        'strategy': 'network-first',
        'maxAge': 3600, // 1 hour
      },
      {
        'pattern': '/images/*',
        'strategy': 'cache-first',
        'maxAge': 86400, // 24 hours
      },
    ],
    'backgroundSync': {
      'queue': 'task-sync-queue',
      'maxRetentionTime': 86400000, // 24 hours
    },
  };

  /// Register Service Worker
  Future<bool> registerServiceWorker() async {
    if (!isWeb) return false;

    _logger.info('Registering Service Worker');

    // In a real implementation:
    // navigator.serviceWorker.register('/flutter_service_worker.js')

    return true;
  }

  /// Check Service Worker status
  Future<ServiceWorkerStatus> getServiceWorkerStatus() async {
    if (!isWeb) return ServiceWorkerStatus.unsupported;

    // navigator.serviceWorker.ready
    return ServiceWorkerStatus.active;
  }

  /// Send message to Service Worker
  Future<void> sendToServiceWorker(Map<String, dynamic> message) async {
    if (!isWeb) return;

    _logger.info('Sending message to Service Worker');

    // navigator.serviceWorker.controller.postMessage()
  }

  /// Trigger background sync
  Future<void> triggerBackgroundSync(String tag) async {
    if (!isWeb) return;

    _logger.info('Triggering background sync: $tag');

    // registration.sync.register(tag)
  }

  // ============================================================
  // WEB PUSH NOTIFICATIONS
  // ============================================================

  /// Request notification permission
  Future<NotificationPermission> requestNotificationPermission() async {
    if (!isWeb) return NotificationPermission.denied;

    _logger.info('Requesting notification permission');

    // Notification.requestPermission()
    return NotificationPermission.granted;
  }

  /// Get push subscription
  Future<String?> getPushSubscription() async {
    if (!isWeb) return null;

    // registration.pushManager.subscribe()
    return null;
  }

  /// Show notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? badge,
    String? tag,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
  }) async {
    if (!isWeb) return;

    _logger.info('Showing notification: $title');

    // new Notification(title, options) or
    // registration.showNotification()
  }

  /// Notification actions
  static const List<Map<String, String>> notificationActions = [
    {'action': 'complete', 'title': 'Complete'},
    {'action': 'snooze', 'title': 'Snooze'},
    {'action': 'view', 'title': 'View'},
  ];

  // ============================================================
  // WEB SHARE API
  // ============================================================

  /// Check if Web Share API is supported
  Future<bool> canShare() async {
    if (!isWeb) return false;

    // navigator.share !== undefined && navigator.canShare !== undefined
    return true;
  }

  /// Share content using Web Share API
  Future<bool> share({
    String? title,
    String? text,
    String? url,
    List<WebShareFile>? files,
  }) async {
    if (!isWeb) return false;

    _logger.info('Sharing via Web Share API');

    // navigator.share({ title, text, url, files })
    return true;
  }

  /// Handle share target (receiving shares)
  Future<void> handleShareTarget(Map<String, dynamic> shareData) async {
    if (!isWeb) return;

    _logger.info('Handling share target');

    // Parse URL search params from share_target action
  }

  // ============================================================
  // INDEXEDDB / LOCAL STORAGE
  // ============================================================

  /// Initialize IndexedDB
  Future<void> initializeIndexedDB() async {
    if (!isWeb) return;

    _logger.info('Initializing IndexedDB');

    // indexedDB.open('dingdong', version)
  }

  /// IndexedDB stores
  static const List<Map<String, dynamic>> indexedDBStores = [
    {
      'name': 'tasks',
      'keyPath': 'id',
      'indexes': ['dueDate', 'listId', 'status', 'syncStatus'],
    },
    {
      'name': 'lists',
      'keyPath': 'id',
      'indexes': ['workspaceId', 'syncStatus'],
    },
    {
      'name': 'attachments',
      'keyPath': 'id',
      'indexes': ['taskId', 'syncStatus'],
    },
    {
      'name': 'syncQueue',
      'keyPath': 'id',
      'indexes': ['timestamp', 'type'],
    },
  ];

  /// Get storage usage
  Future<StorageEstimate?> getStorageEstimate() async {
    if (!isWeb) return null;

    // navigator.storage.estimate()
    return StorageEstimate(usage: 0, quota: 0);
  }

  /// Request persistent storage
  Future<bool> requestPersistentStorage() async {
    if (!isWeb) return false;

    _logger.info('Requesting persistent storage');

    // navigator.storage.persist()
    return true;
  }

  // ============================================================
  // WEBAUTHN / BIOMETRICS
  // ============================================================

  /// Check WebAuthn support
  Future<bool> isWebAuthnSupported() async {
    if (!isWeb) return false;

    // window.PublicKeyCredential !== undefined
    return true;
  }

  /// Check platform authenticator availability
  Future<bool> isPlatformAuthenticatorAvailable() async {
    if (!isWeb) return false;

    // PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()
    return true;
  }

  /// Register WebAuthn credential
  Future<Map<String, dynamic>?> registerWebAuthn({
    required String userId,
    required String userName,
    required String displayName,
  }) async {
    if (!isWeb) return null;

    _logger.info('Registering WebAuthn credential');

    // navigator.credentials.create({ publicKey: options })
    return null;
  }

  /// Authenticate with WebAuthn
  Future<Map<String, dynamic>?> authenticateWebAuthn({
    required List<String> credentialIds,
  }) async {
    if (!isWeb) return null;

    _logger.info('Authenticating with WebAuthn');

    // navigator.credentials.get({ publicKey: options })
    return null;
  }

  // ============================================================
  // KEYBOARD SHORTCUTS
  // ============================================================

  /// Global keyboard shortcuts
  static const List<Map<String, String>> keyboardShortcuts = [
    {'key': 'n', 'modifiers': 'ctrl', 'action': 'newTask', 'description': 'New task'},
    {'key': 't', 'modifiers': 'ctrl', 'action': 'today', 'description': 'Go to Today'},
    {'key': 'f', 'modifiers': 'ctrl', 'action': 'search', 'description': 'Search'},
    {'key': '/', 'modifiers': '', 'action': 'quickSearch', 'description': 'Quick search'},
    {'key': 'Escape', 'modifiers': '', 'action': 'close', 'description': 'Close dialog'},
    {'key': 'Enter', 'modifiers': 'ctrl', 'action': 'save', 'description': 'Save'},
    {'key': 's', 'modifiers': 'ctrl', 'action': 'sync', 'description': 'Sync now'},
    {'key': '1', 'modifiers': 'ctrl', 'action': 'inbox', 'description': 'Go to Inbox'},
    {'key': '2', 'modifiers': 'ctrl', 'action': 'upcoming', 'description': 'Go to Upcoming'},
    {'key': 'p', 'modifiers': 'ctrl+shift', 'action': 'commandPalette', 'description': 'Command palette'},
  ];

  /// Task-specific shortcuts
  static const List<Map<String, String>> taskShortcuts = [
    {'key': 'c', 'modifiers': '', 'action': 'complete', 'description': 'Complete task'},
    {'key': 'e', 'modifiers': '', 'action': 'edit', 'description': 'Edit task'},
    {'key': 'd', 'modifiers': '', 'action': 'setDueDate', 'description': 'Set due date'},
    {'key': 'p', 'modifiers': '', 'action': 'setPriority', 'description': 'Set priority'},
    {'key': 'l', 'modifiers': '', 'action': 'moveToList', 'description': 'Move to list'},
    {'key': 't', 'modifiers': '', 'action': 'addTag', 'description': 'Add tag'},
    {'key': 'Delete', 'modifiers': '', 'action': 'delete', 'description': 'Delete task'},
    {'key': 'j', 'modifiers': '', 'action': 'next', 'description': 'Next task'},
    {'key': 'k', 'modifiers': '', 'action': 'previous', 'description': 'Previous task'},
  ];

  /// Register keyboard shortcuts
  void registerKeyboardShortcuts() {
    if (!isWeb) return;

    _logger.info('Registering keyboard shortcuts');

    // document.addEventListener('keydown', handler)
  }

  // ============================================================
  // RESPONSIVE DESIGN
  // ============================================================

  /// Breakpoints
  static const Map<String, int> breakpoints = {
    'mobile': 0,
    'tablet': 600,
    'desktop': 1024,
    'wide': 1440,
  };

  /// Get current viewport size
  Future<ViewportSize?> getViewportSize() async {
    if (!isWeb) return null;

    // window.innerWidth, window.innerHeight
    return ViewportSize(width: 1920, height: 1080);
  }

  /// Check if viewport matches media query
  Future<bool> matchesMediaQuery(String query) async {
    if (!isWeb) return false;

    // window.matchMedia(query).matches
    return true;
  }

  // ============================================================
  // BROWSER APIS
  // ============================================================

  /// Check online status
  Future<bool> isOnline() async {
    if (!isWeb) return true;

    // navigator.onLine
    return true;
  }

  /// Get connection type
  Future<ConnectionInfo?> getConnectionInfo() async {
    if (!isWeb) return null;

    // navigator.connection
    return ConnectionInfo(
      type: 'wifi',
      downlink: 10.0,
      rtt: 50,
      saveData: false,
    );
  }

  /// Request fullscreen
  Future<void> requestFullscreen() async {
    if (!isWeb) return;

    _logger.info('Requesting fullscreen');

    // document.documentElement.requestFullscreen()
  }

  /// Exit fullscreen
  Future<void> exitFullscreen() async {
    if (!isWeb) return;

    // document.exitFullscreen()
  }

  /// Vibrate (Vibration API)
  Future<void> vibrate(List<int> pattern) async {
    if (!isWeb) return;

    // navigator.vibrate(pattern)
  }

  /// Copy to clipboard
  Future<bool> copyToClipboard(String text) async {
    if (!isWeb) return false;

    _logger.info('Copying to clipboard');

    // navigator.clipboard.writeText(text)
    return true;
  }

  /// Read from clipboard
  Future<String?> readFromClipboard() async {
    if (!isWeb) return null;

    // navigator.clipboard.readText()
    return null;
  }

  // ============================================================
  // FILE SYSTEM ACCESS API
  // ============================================================

  /// Check File System Access API support
  Future<bool> isFileSystemAccessSupported() async {
    if (!isWeb) return false;

    // window.showOpenFilePicker !== undefined
    return true;
  }

  /// Open file picker
  Future<List<WebFile>?> openFilePicker({
    bool multiple = false,
    List<String>? acceptTypes,
  }) async {
    if (!isWeb) return null;

    _logger.info('Opening file picker');

    // window.showOpenFilePicker(options)
    return null;
  }

  /// Save file
  Future<bool> saveFile({
    required String suggestedName,
    required List<int> data,
    String? mimeType,
  }) async {
    if (!isWeb) return false;

    _logger.info('Saving file: $suggestedName');

    // window.showSaveFilePicker(options)
    return true;
  }

  // ============================================================
  // WEB HOSTING CONFIGURATION
  // ============================================================

  /// Deployment configuration
  static const Map<String, dynamic> deploymentConfig = {
    'firebase': {
      'projectId': 'dingdong-app',
      'site': 'dingdong-app',
      'hosting': {
        'public': 'build/web',
        'ignore': ['firebase.json', '**/.*', '**/node_modules/**'],
        'rewrites': [
          {'source': '**', 'destination': '/index.html'},
        ],
        'headers': [
          {
            'source': '**/*.@(js|css)',
            'headers': [
              {'key': 'Cache-Control', 'value': 'max-age=31536000'},
            ],
          },
          {
            'source': 'flutter_service_worker.js',
            'headers': [
              {'key': 'Cache-Control', 'value': 'max-age=0'},
            ],
          },
        ],
      },
    },
    'cors': {
      'allowedOrigins': ['https://dingdong.app', 'https://www.dingdong.app'],
      'allowedMethods': ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      'allowedHeaders': ['Content-Type', 'Authorization'],
    },
    'csp': {
      'default-src': ["'self'"],
      'script-src': ["'self'", "'unsafe-inline'"],
      'style-src': ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
      'font-src': ["'self'", 'https://fonts.gstatic.com'],
      'img-src': ["'self'", 'data:', 'https:'],
      'connect-src': ["'self'", 'https://*.firebaseio.com', 'https://*.googleapis.com'],
    },
  };
}

/// Service Worker status
enum ServiceWorkerStatus {
  installing,
  installed,
  activating,
  active,
  redundant,
  unsupported,
}

/// Notification permission
enum NotificationPermission {
  default_,
  granted,
  denied,
}

/// Notification action
class NotificationAction {
  final String action;
  final String title;
  final String? icon;

  NotificationAction({
    required this.action,
    required this.title,
    this.icon,
  });
}

/// Web share file
class WebShareFile {
  final String name;
  final String type;
  final List<int> data;

  WebShareFile({
    required this.name,
    required this.type,
    required this.data,
  });
}

/// Storage estimate
class StorageEstimate {
  final int usage;
  final int quota;

  StorageEstimate({required this.usage, required this.quota});

  double get usagePercent => quota > 0 ? usage / quota : 0;
}

/// Viewport size
class ViewportSize {
  final int width;
  final int height;

  ViewportSize({required this.width, required this.height});
}

/// Connection info
class ConnectionInfo {
  final String type;
  final double downlink;
  final int rtt;
  final bool saveData;

  ConnectionInfo({
    required this.type,
    required this.downlink,
    required this.rtt,
    required this.saveData,
  });
}

/// Web file
class WebFile {
  final String name;
  final int size;
  final String type;
  final DateTime lastModified;

  WebFile({
    required this.name,
    required this.size,
    required this.type,
    required this.lastModified,
  });
}
