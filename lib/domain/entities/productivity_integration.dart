import 'package:freezed_annotation/freezed_annotation.dart';

part 'productivity_integration.freezed.dart';
part 'productivity_integration.g.dart';

/// Productivity App Integration
///
/// Represents a connection to external productivity apps
/// (Notion, Evernote, OneNote, Apple Notes, Google Keep)
@freezed
class ProductivityIntegration with _$ProductivityIntegration {
  const factory ProductivityIntegration({
    required String id,
    required String userId,
    required ProductivityProvider provider,
    required String accountIdentifier, // email, username, or account ID
    required bool isConnected,
    required bool isSyncEnabled,
    DateTime? lastSyncAt,
    ProductivitySyncSettings? syncSettings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens
    DateTime? connectedAt,
    DateTime? updatedAt,
  }) = _ProductivityIntegration;

  factory ProductivityIntegration.fromJson(Map<String, dynamic> json) =>
      _$ProductivityIntegrationFromJson(json);
}

/// Productivity App Providers
enum ProductivityProvider {
  notion,
  evernote,
  oneNote,
  appleNotes,
  googleKeep,
  other,
}

/// Productivity Sync Settings
@freezed
class ProductivitySyncSettings with _$ProductivitySyncSettings {
  const factory ProductivitySyncSettings({
    // Sync direction
    @Default(SyncDirection.twoWay) SyncDirection syncDirection,

    // What to sync
    @Default(true) bool syncNotesAsTasks,
    @Default(true) bool syncTasksToNotes,
    @Default(true) bool syncTags,
    @Default(false) bool syncChecklistsAsTasks,

    // Sync filtering
    @Default([]) List<String> selectedNotebooks, // For Evernote/OneNote
    @Default([]) List<String> selectedDatabases, // For Notion
    @Default([]) List<String> excludeTags,
    @Default(false) bool syncOnlyTaggedItems,

    // Auto-sync
    @Default(true) bool autoSync,
    @Default(15) int autoSyncIntervalMinutes,

    // Conflict resolution
    @Default(ConflictResolution.newerWins) ConflictResolution conflictResolution,
  }) = _ProductivitySyncSettings;

  factory ProductivitySyncSettings.fromJson(Map<String, dynamic> json) =>
      _$ProductivitySyncSettingsFromJson(json);
}

/// Sync Direction
enum SyncDirection {
  oneWayToApp, // Only export tasks to productivity app
  oneWayFromApp, // Only import from productivity app
  twoWay, // Bi-directional sync
}

/// Conflict Resolution Strategy
enum ConflictResolution {
  appWins, // DingDong wins
  productivityAppWins, // External app wins
  newerWins, // Most recently modified wins
  askUser, // Prompt user to choose
}

/// External Note/Page from Productivity App
@freezed
class ProductivityItem with _$ProductivityItem {
  const factory ProductivityItem({
    required String id,
    required String integrationId,
    required ProductivityProvider provider,
    required String title,
    String? content,
    @Default([]) List<String> tags,
    String? notebookId, // For Evernote/OneNote
    String? databaseId, // For Notion
    String? url, // Deep link to item
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isChecklist,
    @Default([]) List<ChecklistItem> checklistItems,
    String? linkedTaskId, // Linked DingDong task
    @Default(false) bool isSynced,
  }) = _ProductivityItem;

  factory ProductivityItem.fromJson(Map<String, dynamic> json) =>
      _$ProductivityItemFromJson(json);
}

/// Checklist Item from Notes
@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String id,
    required String text,
    required bool isCompleted,
    int? order,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

/// Notion Database (for Notion-specific features)
@freezed
class NotionDatabase with _$NotionDatabase {
  const factory NotionDatabase({
    required String id,
    required String title,
    String? description,
    @Default([]) List<NotionProperty> properties,
    String? url,
  }) = _NotionDatabase;

  factory NotionDatabase.fromJson(Map<String, dynamic> json) =>
      _$NotionDatabaseFromJson(json);
}

/// Notion Property Schema
@freezed
class NotionProperty with _$NotionProperty {
  const factory NotionProperty({
    required String id,
    required String name,
    required NotionPropertyType type,
  }) = _NotionProperty;

  factory NotionProperty.fromJson(Map<String, dynamic> json) =>
      _$NotionPropertyFromJson(json);
}

/// Notion Property Types
enum NotionPropertyType {
  title,
  richText,
  number,
  select,
  multiSelect,
  date,
  checkbox,
  url,
  email,
  phoneNumber,
  formula,
  relation,
  rollup,
  createdTime,
  createdBy,
  lastEditedTime,
  lastEditedBy,
}

/// Evernote Notebook
@freezed
class EvernoteNotebook with _$EvernoteNotebook {
  const factory EvernoteNotebook({
    required String guid,
    required String name,
    String? stack, // Notebook stack
    @Default(false) bool isDefault,
    @Default(false) bool isShared,
  }) = _EvernoteNotebook;

  factory EvernoteNotebook.fromJson(Map<String, dynamic> json) =>
      _$EvernoteNotebookFromJson(json);
}

/// OneNote Notebook/Section
@freezed
class OneNoteNotebook with _$OneNoteNotebook {
  const factory OneNoteNotebook({
    required String id,
    required String displayName,
    @Default([]) List<OneNoteSection> sections,
    String? webUrl,
  }) = _OneNoteNotebook;

  factory OneNoteNotebook.fromJson(Map<String, dynamic> json) =>
      _$OneNoteNotebookFromJson(json);
}

@freezed
class OneNoteSection with _$OneNoteSection {
  const factory OneNoteSection({
    required String id,
    required String displayName,
    String? webUrl,
  }) = _OneNoteSection;

  factory OneNoteSection.fromJson(Map<String, dynamic> json) =>
      _$OneNoteSectionFromJson(json);
}

/// Productivity Sync Result
@freezed
class ProductivitySyncResult with _$ProductivitySyncResult {
  const factory ProductivitySyncResult({
    required String integrationId,
    required DateTime syncedAt,
    required int itemsImported,
    required int itemsExported,
    required int itemsUpdated,
    required int conflicts,
    @Default([]) List<SyncError> errors,
    @Default(SyncStatus.success) SyncStatus status,
  }) = _ProductivitySyncResult;

  factory ProductivitySyncResult.fromJson(Map<String, dynamic> json) =>
      _$ProductivitySyncResultFromJson(json);
}

/// Sync Status
enum SyncStatus {
  success,
  partialSuccess,
  failed,
  inProgress,
}

/// Sync Error
@freezed
class SyncError with _$SyncError {
  const factory SyncError({
    required String itemId,
    required String message,
    String? errorCode,
    DateTime? occurredAt,
  }) = _SyncError;

  factory SyncError.fromJson(Map<String, dynamic> json) =>
      _$SyncErrorFromJson(json);
}
