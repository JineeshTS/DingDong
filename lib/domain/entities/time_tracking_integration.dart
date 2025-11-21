import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_tracking_integration.freezed.dart';
part 'time_tracking_integration.g.dart';

/// Time Tracking Integration
///
/// Represents a connection to external time tracking platforms
/// (Toggl, RescueTime, Harvest, Clockify)
@freezed
class TimeTrackingIntegration with _$TimeTrackingIntegration {
  const factory TimeTrackingIntegration({
    required String id,
    required String userId,
    required TimeTrackingProvider provider,
    required String accountName,
    required bool isConnected,
    required bool isActive,
    @Default([]) List<String> selectedWorkspaces,
    @Default([]) List<String> selectedProjects,
    TimeTrackingSettings? settings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens or API keys
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) = _TimeTrackingIntegration;

  factory TimeTrackingIntegration.fromJson(Map<String, dynamic> json) =>
      _$TimeTrackingIntegrationFromJson(json);
}

/// Time Tracking Platform Providers
enum TimeTrackingProvider {
  toggl,
  rescueTime,
  harvest,
  clockify,
  other,
}

/// Time Tracking Integration Settings
@freezed
class TimeTrackingSettings with _$TimeTrackingSettings {
  const factory TimeTrackingSettings({
    // Sync settings
    @Default(true) bool syncTimeEntries,
    @Default(true) bool syncProjects,
    @Default(true) bool syncTags,
    @Default(true) bool autoStartTimer,
    @Default(true) bool autoStopTimer,
    @Default(15) int autoSyncInterval, // Minutes

    // Timer behavior
    @Default(true) bool startTimerOnTaskStart,
    @Default(true) bool stopTimerOnTaskComplete,
    @Default(true) bool pauseTimerOnTaskPause,
    @Default(false) bool showTimerInApp,
    @Default(true) bool trackIdleTime,
    @Default(5) int idleTimeThreshold, // Minutes before marking as idle

    // Time entry settings
    @Default(true) bool createTimeEntriesFromFocusSessions,
    @Default(true) bool createTimeEntriesFromPomodoro,
    @Default(true) bool roundTimeEntries,
    @Default(15) int roundingInterval, // Minutes (1, 5, 6, 10, 15, 30)
    @Default(RoundingMethod.nearest) RoundingMethod roundingMethod,

    // Project/task mapping
    @Default(true) bool mapTasksToProjects,
    @Default(true) bool mapListsToProjects,
    @Default(true) bool createProjectsAutomatically,
    @Default({}) Map<String, String> projectMapping, // DingDong list/project → Time tracker project

    // Import settings
    @Default(true) bool importTimeEntries,
    @Default(7) int importDaysBack, // How many days of history to import
    @Default(true) bool importProductivityData, // For RescueTime
    @Default(true) bool importGoals,

    // Reporting
    @Default(true) bool includeInReports,
    @Default(true) bool showProductivityScore, // For RescueTime
    @Default(true) bool trackBillableTime,

    // Provider-specific settings
    TogglSettings? togglSettings,
    RescueTimeSettings? rescueTimeSettings,
    HarvestSettings? harvestSettings,
  }) = _TimeTrackingSettings;

  factory TimeTrackingSettings.fromJson(Map<String, dynamic> json) =>
      _$TimeTrackingSettingsFromJson(json);
}

/// Time Entry Rounding Method
enum RoundingMethod {
  up, // Always round up
  down, // Always round down
  nearest, // Round to nearest interval
}

/// Toggl-specific Settings
@freezed
class TogglSettings with _$TogglSettings {
  const factory TogglSettings({
    String? defaultWorkspaceId,
    @Default([]) List<String> workspaceIds,
    @Default(true) bool syncClients,
    @Default(true) bool syncTags,
    @Default(true) bool syncBillableStatus,
    @Default(true) bool useTogglProjects, // Use Toggl projects or create new
    @Default(false) bool syncToTogglTrack, // Toggl Track vs Toggl Plan
    @Default(true) bool enableWebTimer, // Enable Toggl web timer
    @Default(true) bool enableDesktopApp, // Enable desktop app integration
  }) = _TogglSettings;

  factory TogglSettings.fromJson(Map<String, dynamic> json) =>
      _$TogglSettingsFromJson(json);
}

/// RescueTime-specific Settings
@freezed
class RescueTimeSettings with _$RescueTimeSettings {
  const factory RescueTimeSettings({
    @Default(true) bool importProductivityPulse,
    @Default(true) bool importCategoryBreakdown,
    @Default(true) bool importTopActivities,
    @Default(true) bool importGoals,
    @Default(true) bool importAlerts,
    @Default(true) bool syncFocusTime, // FocusTime feature
    @Default(true) bool blockDistractions, // Auto-block distracting sites
    @Default([]) List<String> focusCategories, // Categories to count as focus
    @Default([]) List<String> distractingCategories, // Categories to block
    @Default(70) int productivityGoal, // Daily productivity score goal (0-100)
  }) = _RescueTimeSettings;

  factory RescueTimeSettings.fromJson(Map<String, dynamic> json) =>
      _$RescueTimeSettingsFromJson(json);
}

/// Harvest-specific Settings
@freezed
class HarvestSettings with _$HarvestSettings {
  const factory HarvestSettings({
    String? accountId,
    @Default([]) List<String> projectIds,
    @Default(true) bool syncClients,
    @Default(true) bool syncExpenses,
    @Default(true) bool syncInvoices,
    @Default(true) bool trackBillableByDefault,
    @Default(true) bool requireNotes,
    @Default(true) bool roundTimeEntries,
    @Default(true) bool enableTimerReminders,
    @Default(true) bool syncTaskAssignments,
    String? defaultTaskId, // Default task for time entries
    String? defaultProjectId, // Default project for new entries
  }) = _HarvestSettings;

  factory HarvestSettings.fromJson(Map<String, dynamic> json) =>
      _$HarvestSettingsFromJson(json);
}

/// Time Entry from external platform
@freezed
class ExternalTimeEntry with _$ExternalTimeEntry {
  const factory ExternalTimeEntry({
    required String id,
    required String integrationId,
    required TimeTrackingProvider provider,
    required String description,
    required DateTime startTime,
    DateTime? endTime,
    required int durationSeconds, // Duration in seconds
    String? projectId,
    String? projectName,
    String? taskId,
    String? taskName,
    String? clientId,
    String? clientName,
    @Default([]) List<String> tags,
    @Default(false) bool isBillable,
    @Default(false) bool isRunning,
    String? linkedTaskId, // DingDong task ID
    String? linkedFocusSessionId, // DingDong focus session ID
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _ExternalTimeEntry;

  factory ExternalTimeEntry.fromJson(Map<String, dynamic> json) =>
      _$ExternalTimeEntryFromJson(json);
}

/// External Project from time tracking platform
@freezed
class TimeTrackingProject with _$TimeTrackingProject {
  const factory TimeTrackingProject({
    required String id,
    required String integrationId,
    required TimeTrackingProvider provider,
    required String name,
    String? clientId,
    String? clientName,
    String? color,
    @Default(false) bool isBillable,
    @Default(false) bool isActive,
    @Default(false) bool isPrivate,
    double? hourlyRate,
    double? budget,
    int? estimatedHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TimeTrackingProject;

  factory TimeTrackingProject.fromJson(Map<String, dynamic> json) =>
      _$TimeTrackingProjectFromJson(json);
}

/// Productivity Data from RescueTime
@freezed
class ProductivityData with _$ProductivityData {
  const factory ProductivityData({
    required String integrationId,
    required DateTime date,
    required int productivityPulse, // 0-100
    required int totalSeconds,
    required int productiveSeconds,
    required int distractingSeconds,
    required int neutralSeconds,
    @Default([]) List<CategoryBreakdown> categories,
    @Default([]) List<ActivityData> topActivities,
    @Default([]) List<GoalProgress> goals,
  }) = _ProductivityData;

  factory ProductivityData.fromJson(Map<String, dynamic> json) =>
      _$ProductivityDataFromJson(json);
}

/// Category Breakdown for RescueTime
@freezed
class CategoryBreakdown with _$CategoryBreakdown {
  const factory CategoryBreakdown({
    required String category,
    required int seconds,
    required int productivityLevel, // -2 to 2 (very distracting to very productive)
  }) = _CategoryBreakdown;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);
}

/// Activity Data for RescueTime
@freezed
class ActivityData with _$ActivityData {
  const factory ActivityData({
    required String name,
    required String category,
    required int seconds,
    required int productivityLevel,
  }) = _ActivityData;

  factory ActivityData.fromJson(Map<String, dynamic> json) =>
      _$ActivityDataFromJson(json);
}

/// Goal Progress for RescueTime
@freezed
class GoalProgress with _$GoalProgress {
  const factory GoalProgress({
    required String name,
    required String type, // productivity, focus_time, specific_app, etc.
    required int targetSeconds,
    required int currentSeconds,
    required double progress, // 0.0 to 1.0+
    @Default(false) bool isCompleted,
  }) = _GoalProgress;

  factory GoalProgress.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressFromJson(json);
}

/// Running Timer State
@freezed
class RunningTimer with _$RunningTimer {
  const factory RunningTimer({
    required String id,
    required String integrationId,
    required TimeTrackingProvider provider,
    required DateTime startTime,
    required String description,
    String? projectId,
    String? projectName,
    String? taskId,
    @Default([]) List<String> tags,
    @Default(false) bool isBillable,
    String? linkedTaskId, // DingDong task being tracked
  }) = _RunningTimer;

  factory RunningTimer.fromJson(Map<String, dynamic> json) =>
      _$RunningTimerFromJson(json);
}

/// Time Tracking Sync Result
@freezed
class TimeTrackingSyncResult with _$TimeTrackingSyncResult {
  const factory TimeTrackingSyncResult({
    required String integrationId,
    required TimeTrackingProvider provider,
    required DateTime syncedAt,
    required int entriesImported,
    required int entriesExported,
    required int entriesUpdated,
    required int projectsSynced,
    required int errors,
    @Default([]) List<String> errorMessages,
    @Default({}) Map<String, dynamic> details,
  }) = _TimeTrackingSyncResult;

  factory TimeTrackingSyncResult.fromJson(Map<String, dynamic> json) =>
      _$TimeTrackingSyncResultFromJson(json);
}
