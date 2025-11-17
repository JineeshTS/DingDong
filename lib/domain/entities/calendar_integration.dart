import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_integration.freezed.dart';
part 'calendar_integration.g.dart';

/// Calendar Integration
///
/// Represents a connected calendar service
@freezed
class CalendarIntegration with _$CalendarIntegration {
  const factory CalendarIntegration({
    required String id,
    required String userId,
    required CalendarProvider provider,
    required String accountEmail,
    required String accountName,
    required bool isConnected,
    required bool isSyncEnabled,
    required DateTime connectedAt,
    DateTime? lastSyncAt,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    @Default([]) List<String> selectedCalendarIds,
    @Default({}) Map<String, String> calendarIdToName,
    CalendarSyncSettings? syncSettings,
    String? errorMessage,
  }) = _CalendarIntegration;

  factory CalendarIntegration.fromJson(Map<String, dynamic> json) =>
      _$CalendarIntegrationFromJson(json);

  const CalendarIntegration._();

  /// Check if token is expired
  bool get isTokenExpired {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  /// Check if needs re-authentication
  bool get needsReAuth => !isConnected || isTokenExpired;

  /// Has selected calendars
  bool get hasSelectedCalendars => selectedCalendarIds.isNotEmpty;

  /// Number of synced calendars
  int get syncedCalendarCount => selectedCalendarIds.length;
}

/// Calendar Provider
enum CalendarProvider {
  google,
  outlook,
  apple,
  other,
}

/// Extension for CalendarProvider
extension CalendarProviderX on CalendarProvider {
  String get displayName {
    switch (this) {
      case CalendarProvider.google:
        return 'Google Calendar';
      case CalendarProvider.outlook:
        return 'Outlook Calendar';
      case CalendarProvider.apple:
        return 'Apple Calendar';
      case CalendarProvider.other:
        return 'Other Calendar';
    }
  }

  String get icon {
    switch (this) {
      case CalendarProvider.google:
        return '📅'; // Google icon in real app
      case CalendarProvider.outlook:
        return '📧'; // Outlook icon
      case CalendarProvider.apple:
        return ''; // Apple icon
      case CalendarProvider.other:
        return '🗓️';
    }
  }
}

/// Calendar Sync Settings
@freezed
class CalendarSyncSettings with _$CalendarSyncSettings {
  const factory CalendarSyncSettings({
    // Sync direction
    @Default(SyncDirection.twoWay) SyncDirection syncDirection,

    // What to sync
    @Default(true) bool syncTasksAsEvents,
    @Default(true) bool syncEventsAsTasks,
    @Default(true) bool syncReminders,
    @Default(true) bool syncRecurringEvents,
    @Default(true) bool syncAttendees,

    // Sync filtering
    @Default(true) bool syncAllDayTasks,
    @Default(true) bool syncOnlyScheduledTasks,
    @Default([]) List<String> syncOnlyFromLists,
    @Default([]) List<String> excludeTags,

    // Color mapping
    @Default({}) Map<String, String> listIdToCalendarColor,

    // Conflict resolution
    @Default(ConflictResolution.calendarWins)
        ConflictResolution conflictResolution,

    // Auto-sync interval (in minutes)
    @Default(30) int autoSyncIntervalMinutes,
    @Default(true) bool autoSyncEnabled,
  }) = _CalendarSyncSettings;

  factory CalendarSyncSettings.fromJson(Map<String, dynamic> json) =>
      _$CalendarSyncSettingsFromJson(json);
}

/// Sync Direction
enum SyncDirection {
  oneWayToCalendar,
  oneWayFromCalendar,
  twoWay,
}

/// Extension for SyncDirection
extension SyncDirectionX on SyncDirection {
  String get displayName {
    switch (this) {
      case SyncDirection.oneWayToCalendar:
        return 'App → Calendar';
      case SyncDirection.oneWayFromCalendar:
        return 'Calendar → App';
      case SyncDirection.twoWay:
        return 'Two-Way Sync';
    }
  }

  String get description {
    switch (this) {
      case SyncDirection.oneWayToCalendar:
        return 'Tasks sync to calendar only';
      case SyncDirection.oneWayFromCalendar:
        return 'Calendar events sync to tasks only';
      case SyncDirection.twoWay:
        return 'Changes sync in both directions';
    }
  }
}

/// Conflict Resolution Strategy
enum ConflictResolution {
  calendarWins,
  appWins,
  newerWins,
  askUser,
}

/// Extension for ConflictResolution
extension ConflictResolutionX on ConflictResolution {
  String get displayName {
    switch (this) {
      case ConflictResolution.calendarWins:
        return 'Calendar Wins';
      case ConflictResolution.appWins:
        return 'App Wins';
      case ConflictResolution.newerWins:
        return 'Newer Wins';
      case ConflictResolution.askUser:
        return 'Ask Me';
    }
  }
}

/// Calendar Event
///
/// Represents a calendar event from external calendar
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String calendarId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    String? location,
    @Default([]) List<String> attendees,
    String? recurrenceRule,
    String? colorId,
    required CalendarProvider provider,
    String? externalId,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
    String? linkedTaskId,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  const CalendarEvent._();

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Is recurring event
  bool get isRecurring => recurrenceRule != null && recurrenceRule!.isNotEmpty;

  /// Has attendees
  bool get hasAttendees => attendees.isNotEmpty;

  /// Is linked to task
  bool get isLinkedToTask => linkedTaskId != null;
}

/// Calendar Sync Result
///
/// Result of a calendar sync operation
@freezed
class CalendarSyncResult with _$CalendarSyncResult {
  const factory CalendarSyncResult({
    required DateTime syncStartedAt,
    required DateTime syncCompletedAt,
    required CalendarProvider provider,
    @Default(0) int eventsImported,
    @Default(0) int eventsExported,
    @Default(0) int eventsUpdated,
    @Default(0) int eventsDeleted,
    @Default(0) int tasksCreated,
    @Default(0) int tasksUpdated,
    @Default(0) int conflictsDetected,
    @Default(0) int conflictsResolved,
    @Default([]) List<SyncError> errors,
    @Default(true) bool success,
  }) = _CalendarSyncResult;

  factory CalendarSyncResult.fromJson(Map<String, dynamic> json) =>
      _$CalendarSyncResultFromJson(json);

  const CalendarSyncResult._();

  /// Total changes made
  int get totalChanges =>
      eventsImported +
      eventsExported +
      eventsUpdated +
      eventsDeleted +
      tasksCreated +
      tasksUpdated;

  /// Has errors
  bool get hasErrors => errors.isNotEmpty;

  /// Duration
  Duration get duration => syncCompletedAt.difference(syncStartedAt);
}

/// Sync Error
@freezed
class SyncError with _$SyncError {
  const factory SyncError({
    required String message,
    String? eventId,
    String? taskId,
    SyncErrorType? type,
  }) = _SyncError;

  factory SyncError.fromJson(Map<String, dynamic> json) =>
      _$SyncErrorFromJson(json);
}

/// Sync Error Type
enum SyncErrorType {
  authenticationFailed,
  networkError,
  conflictDetected,
  invalidData,
  rateLimitExceeded,
  permissionDenied,
  other,
}

/// Calendar List
///
/// Represents a calendar from external provider
@freezed
class ExternalCalendar with _$ExternalCalendar {
  const factory ExternalCalendar({
    required String id,
    required String name,
    String? description,
    String? colorId,
    required bool isPrimary,
    required bool isWritable,
    required CalendarProvider provider,
    String? timeZone,
  }) = _ExternalCalendar;

  factory ExternalCalendar.fromJson(Map<String, dynamic> json) =>
      _$ExternalCalendarFromJson(json);
}

/// Calendar Sync Status
@freezed
class CalendarSyncStatus with _$CalendarSyncStatus {
  const factory CalendarSyncStatus({
    required bool isSyncing,
    required bool hasError,
    String? errorMessage,
    DateTime? lastSyncAt,
    DateTime? nextSyncAt,
    CalendarSyncResult? lastSyncResult,
    @Default(0) int pendingChanges,
  }) = _CalendarSyncStatus;

  factory CalendarSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$CalendarSyncStatusFromJson(json);

  const CalendarSyncStatus._();

  /// Is sync needed
  bool get syncNeeded => pendingChanges > 0;

  /// Time since last sync
  Duration? get timeSinceLastSync {
    if (lastSyncAt == null) return null;
    return DateTime.now().difference(lastSyncAt!);
  }
}
