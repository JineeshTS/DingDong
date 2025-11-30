import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_management_integration.freezed.dart';
part 'project_management_integration.g.dart';

/// Project Management Integration
///
/// Represents a connection to external project management platforms
/// (Jira, Asana, Trello, Monday.com)
@freezed
class ProjectManagementIntegration with _$ProjectManagementIntegration {
  const factory ProjectManagementIntegration({
    required String id,
    required String userId,
    required PMProvider provider,
    required String accountName,
    required bool isConnected,
    required bool isActive,
    @Default([]) List<String> selectedProjects, // Projects/boards to sync
    @Default([]) List<String> selectedWorkspaces, // Workspaces/organizations
    PMSettings? settings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) = _ProjectManagementIntegration;

  factory ProjectManagementIntegration.fromJson(Map<String, dynamic> json) =>
      _$ProjectManagementIntegrationFromJson(json);
}

/// Project Management Platform Providers
enum PMProvider {
  jira,
  asana,
  trello,
  mondayDotCom,
  other,
}

/// Project Management Integration Settings
@freezed
class PMSettings with _$PMSettings {
  const factory PMSettings({
    // Sync settings
    @Default(SyncDirection.twoWay) SyncDirection syncDirection,
    @Default(true) bool syncTasks,
    @Default(true) bool syncProjects,
    @Default(true) bool syncComments,
    @Default(true) bool syncAttachments,
    @Default(true) bool syncStatus,
    @Default(true) bool syncPriority,
    @Default(true) bool syncAssignees,
    @Default(true) bool syncLabels,
    @Default(true) bool syncDueDates,
    @Default(true) bool syncSubtasks,
    @Default(15) int autoSyncInterval, // Minutes

    // Import settings
    @Default(true) bool importExistingTasks,
    @Default(false) bool importCompletedTasks,
    @Default(false) bool importArchivedTasks,
    @Default(true) bool preserveProjectStructure,
    @Default(true) bool preserveTaskHierarchy,

    // Export settings
    @Default(true) bool createRemoteTasks,
    @Default(true) bool updateRemoteTasks,
    @Default(false) bool deleteRemoteTasks,
    @Default(true) bool preserveLinks,

    // Mapping settings
    @Default({}) Map<String, String> statusMapping, // Local → Remote
    @Default({}) Map<String, String> priorityMapping,
    @Default({}) Map<String, String> projectMapping,
    @Default({}) Map<String, String> labelMapping,

    // Conflict resolution
    @Default(ConflictStrategy.remoteWins) ConflictStrategy conflictStrategy,
    @Default(true) bool notifyOnConflict,

    // Filtering
    @Default([]) List<String> excludeProjects,
    @Default([]) List<String> excludeLabels,
    @Default([]) List<String> includeAssignees, // Only sync tasks for these users

    // Notifications
    @Default(true) bool notifyOnNewTasks,
    @Default(true) bool notifyOnUpdates,
    @Default(false) bool notifyOnComments,

    // Provider-specific settings
    JiraSettings? jiraSettings,
    AsanaSettings? asanaSettings,
    TrelloSettings? trelloSettings,
    MondaySettings? mondaySettings,
  }) = _PMSettings;

  factory PMSettings.fromJson(Map<String, dynamic> json) =>
      _$PMSettingsFromJson(json);
}

/// Sync Direction
enum SyncDirection {
  oneWayToRemote, // Only push to remote
  oneWayFromRemote, // Only pull from remote
  twoWay, // Bidirectional sync
}

/// Conflict Resolution Strategy
enum ConflictStrategy {
  localWins, // Prefer local changes
  remoteWins, // Prefer remote changes
  newerWins, // Choose the newer version
  askUser, // Prompt user to resolve
}

/// Jira-specific Settings
@freezed
class JiraSettings with _$JiraSettings {
  const factory JiraSettings({
    required String siteUrl, // e.g., yourcompany.atlassian.net
    String? cloudId, // For Jira Cloud
    @Default(true) bool isCloud, // Cloud vs Server/Data Center
    @Default([]) List<String> issueTypes, // Bug, Task, Story, etc.
    @Default({}) Map<String, String> customFieldMapping,
    @Default(true) bool syncSprints,
    @Default(true) bool syncEpics,
    @Default(true) bool syncVersions,
    @Default(true) bool syncComponents,
    @Default(true) bool syncWorklog,
    @Default(true) bool enableJQL, // Advanced query support
    String? jqlFilter, // Custom JQL for filtering
  }) = _JiraSettings;

  factory JiraSettings.fromJson(Map<String, dynamic> json) =>
      _$JiraSettingsFromJson(json);
}

/// Asana-specific Settings
@freezed
class AsanaSettings with _$AsanaSettings {
  const factory AsanaSettings({
    @Default([]) List<String> workspaceIds,
    @Default(true) bool syncSections,
    @Default(true) bool syncMilestones,
    @Default(true) bool syncCustomFields,
    @Default(true) bool syncTags,
    @Default(true) bool syncFollowers,
    @Default(true) bool syncDependencies,
    @Default(false) bool syncOnlyMyTasks, // Only sync tasks assigned to user
  }) = _AsanaSettings;

  factory AsanaSettings.fromJson(Map<String, dynamic> json) =>
      _$AsanaSettingsFromJson(json);
}

/// Trello-specific Settings
@freezed
class TrelloSettings with _$TrelloSettings {
  const factory TrelloSettings({
    @Default([]) List<String> boardIds,
    @Default(true) bool syncLists,
    @Default(true) bool syncCards,
    @Default(true) bool syncChecklists,
    @Default(true) bool syncLabels,
    @Default(true) bool syncMembers,
    @Default(true) bool syncDueComplete,
    @Default(true) bool syncPowerUps,
    @Default(false) bool syncArchivedCards,
    @Default(false) bool syncClosedBoards,
  }) = _TrelloSettings;

  factory TrelloSettings.fromJson(Map<String, dynamic> json) =>
      _$TrelloSettingsFromJson(json);
}

/// Monday.com-specific Settings
@freezed
class MondaySettings with _$MondaySettings {
  const factory MondaySettings({
    @Default([]) List<String> boardIds,
    @Default([]) List<String> workspaceIds,
    @Default(true) bool syncGroups,
    @Default(true) bool syncColumns,
    @Default(true) bool syncSubitems,
    @Default(true) bool syncUpdates,
    @Default(true) bool syncFiles,
    @Default(true) bool syncTimeline,
    @Default(true) bool syncStatus,
    @Default(true) bool syncPeople,
    @Default({}) Map<String, String> columnMapping, // Column type mapping
  }) = _MondaySettings;

  factory MondaySettings.fromJson(Map<String, dynamic> json) =>
      _$MondaySettingsFromJson(json);
}

/// External Project/Board
@freezed
class ExternalProject with _$ExternalProject {
  const factory ExternalProject({
    required String id,
    required String integrationId,
    required PMProvider provider,
    required String name,
    String? description,
    String? key, // Jira project key
    String? url,
    String? iconUrl,
    @Default([]) List<String> memberIds,
    @Default([]) List<String> labels,
    @Default(false) bool isArchived,
    @Default(false) bool isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _ExternalProject;

  factory ExternalProject.fromJson(Map<String, dynamic> json) =>
      _$ExternalProjectFromJson(json);
}

/// External Task/Issue/Card
@freezed
class ExternalTask with _$ExternalTask {
  const factory ExternalTask({
    required String id,
    required String integrationId,
    required String projectId,
    required PMProvider provider,
    required String title,
    String? description,
    String? status,
    String? priority,
    String? type, // Issue type, card type, etc.
    @Default([]) List<String> assigneeIds,
    @Default([]) List<String> labels,
    @Default([]) List<String> tags,
    DateTime? dueDate,
    DateTime? startDate,
    String? url,
    String? key, // Jira issue key, etc.
    @Default([]) List<ExternalAttachment> attachments,
    @Default([]) List<ExternalComment> comments,
    @Default([]) List<String> subtaskIds,
    String? parentTaskId,
    String? linkedTaskId, // Local task ID
    @Default(false) bool isCompleted,
    @Default(false) bool isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? metadata,
  }) = _ExternalTask;

  factory ExternalTask.fromJson(Map<String, dynamic> json) =>
      _$ExternalTaskFromJson(json);
}

/// External Comment
@freezed
class ExternalComment with _$ExternalComment {
  const factory ExternalComment({
    required String id,
    required String taskId,
    required String authorId,
    required String authorName,
    required String content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorAvatarUrl,
  }) = _ExternalComment;

  factory ExternalComment.fromJson(Map<String, dynamic> json) =>
      _$ExternalCommentFromJson(json);
}

/// External Attachment
@freezed
class ExternalAttachment with _$ExternalAttachment {
  const factory ExternalAttachment({
    required String id,
    required String name,
    required String url,
    String? mimeType,
    int? size,
    DateTime? createdAt,
    String? uploaderId,
    String? uploaderName,
  }) = _ExternalAttachment;

  factory ExternalAttachment.fromJson(Map<String, dynamic> json) =>
      _$ExternalAttachmentFromJson(json);
}

/// Sync Result
@freezed
class PMSyncResult with _$PMSyncResult {
  const factory PMSyncResult({
    required String integrationId,
    required PMProvider provider,
    required DateTime syncedAt,
    required int tasksImported,
    required int tasksExported,
    required int tasksUpdated,
    required int tasksSkipped,
    required int errors,
    @Default([]) List<String> errorMessages,
    @Default({}) Map<String, dynamic> details,
  }) = _PMSyncResult;

  factory PMSyncResult.fromJson(Map<String, dynamic> json) =>
      _$PMSyncResultFromJson(json);
}
