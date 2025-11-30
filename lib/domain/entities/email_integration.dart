import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_integration.freezed.dart';
part 'email_integration.g.dart';

/// Email Integration
///
/// Represents a connection to external email platforms
/// (Gmail, Outlook)
@freezed
class EmailIntegration with _$EmailIntegration {
  const factory EmailIntegration({
    required String id,
    required String userId,
    required EmailProvider provider,
    required String emailAddress,
    required bool isConnected,
    required bool isActive,
    @Default([]) List<String> selectedLabels, // Labels/folders to monitor
    @Default([]) List<String> selectedInboxes, // For multiple account support
    EmailSettings? settings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) = _EmailIntegration;

  factory EmailIntegration.fromJson(Map<String, dynamic> json) =>
      _$EmailIntegrationFromJson(json);
}

/// Email Platform Providers
enum EmailProvider {
  gmail,
  outlook,
  other,
}

/// Email Integration Settings
@freezed
class EmailSettings with _$EmailSettings {
  const factory EmailSettings({
    // Task creation from emails
    @Default(true) bool createTasksFromEmails,
    @Default(true) bool createTasksFromStarred, // Starred/flagged emails
    @Default(false) bool createTasksFromAllEmails, // Auto-create from all
    String? forwardingAddress, // Email-to-task forwarding address
    @Default(true) bool enableEmailForwarding,

    // Email parsing
    @Default(true) bool parseSubjectAsTitle,
    @Default(true) bool parseBodyAsDescription,
    @Default(true) bool parseDueDates,
    @Default(true) bool parsePriority,
    @Default(true) bool extractAttachments,
    @Default(true) bool preserveEmailFormatting,

    // Email linking
    @Default(true) bool linkEmailsToTasks,
    @Default(true) bool showEmailPreview,
    @Default(true) bool syncEmailStatus, // Mark email read when task complete

    // Filtering
    @Default([]) List<String> excludeSenders, // Don't create tasks from these
    @Default([]) List<String> excludeSubjects, // Skip these subject patterns
    @Default([]) List<String> includeLabels, // Only create from these labels
    @Default([]) List<String> excludeLabels, // Don't create from these labels
    @Default(false) bool requireKeyword, // Require keyword in subject/body
    String? keyword, // e.g., "TODO:", "TASK:"

    // Notifications
    @Default(true) bool notifyOnEmailTask,
    @Default(false) bool notifyOnAllEmails,

    // Auto-categorization
    @Default(true) bool autoDetectCategory, // Detect work/personal/etc
    @Default(true) bool createListFromLabel, // Create list matching label
    @Default(true) bool syncLabelsAsTags, // Email labels → Task tags

    // Gmail-specific
    GmailSettings? gmailSettings,

    // Outlook-specific
    OutlookSettings? outlookSettings,
  }) = _EmailSettings;

  factory EmailSettings.fromJson(Map<String, dynamic> json) =>
      _$EmailSettingsFromJson(json);
}

/// Gmail-specific Settings
@freezed
class GmailSettings with _$GmailSettings {
  const factory GmailSettings({
    @Default(true) bool useGmailAddOn,
    @Default(true) bool useContextualSidebar, // Gmail extension
    @Default(true) bool enableQuickAdd, // Quick add from Gmail UI
    @Default(true) bool syncGmailThreads, // Keep email threads together
    @Default([]) List<String> watchLabels, // Real-time watch these labels
  }) = _GmailSettings;

  factory GmailSettings.fromJson(Map<String, dynamic> json) =>
      _$GmailSettingsFromJson(json);
}

/// Outlook-specific Settings
@freezed
class OutlookSettings with _$OutlookSettings {
  const factory OutlookSettings({
    @Default(true) bool useOutlookAddIn,
    @Default(true) bool useTaskPane, // Outlook add-in task pane
    @Default(true) bool enableQuickAdd, // Quick add from Outlook UI
    @Default(true) bool syncOutlookCategories, // Outlook categories → tags
    @Default(true) bool syncOutlookFlags, // Follow up flags → priority
    @Default([]) List<String> watchFolders, // Monitor these folders
  }) = _OutlookSettings;

  factory OutlookSettings.fromJson(Map<String, dynamic> json) =>
      _$OutlookSettingsFromJson(json);
}

/// Email from platform
@freezed
class Email with _$Email {
  const factory Email({
    required String id,
    required String integrationId,
    required EmailProvider provider,
    required String subject,
    required String from,
    required String fromEmail,
    @Default([]) List<String> to,
    @Default([]) List<String> cc,
    @Default([]) List<String> bcc,
    String? body,
    String? bodyPlainText,
    String? bodyHtml,
    DateTime? timestamp,
    @Default([]) List<String> labels, // Gmail labels or Outlook categories
    @Default([]) List<EmailAttachment> attachments,
    @Default(false) bool isStarred,
    @Default(false) bool isRead,
    @Default(false) bool isImportant,
    String? threadId,
    String? linkedTaskId, // If task was created from this email
    String? emailUrl, // Deep link to email
    EmailMetadata? metadata,
  }) = _Email;

  factory Email.fromJson(Map<String, dynamic> json) =>
      _$EmailFromJson(json);
}

/// Email Metadata
@freezed
class EmailMetadata with _$EmailMetadata {
  const factory EmailMetadata({
    String? messageId,
    String? inReplyTo,
    @Default([]) List<String> references,
    Map<String, String>? headers,
  }) = _EmailMetadata;

  factory EmailMetadata.fromJson(Map<String, dynamic> json) =>
      _$EmailMetadataFromJson(json);
}

/// Email Attachment
@freezed
class EmailAttachment with _$EmailAttachment {
  const factory EmailAttachment({
    required String id,
    required String filename,
    String? url,
    String? mimeType,
    int? size,
    String? contentId, // For inline images
    @Default(false) bool isInline,
  }) = _EmailAttachment;

  factory EmailAttachment.fromJson(Map<String, dynamic> json) =>
      _$EmailAttachmentFromJson(json);
}

/// Gmail-specific entities

/// Gmail Label
@freezed
class GmailLabel with _$GmailLabel {
  const factory GmailLabel({
    required String id,
    required String name,
    GmailLabelType? type,
    @Default(0) int messageCount,
    @Default(0) int unreadCount,
  }) = _GmailLabel;

  factory GmailLabel.fromJson(Map<String, dynamic> json) =>
      _$GmailLabelFromJson(json);
}

/// Gmail Label Types
enum GmailLabelType {
  system,
  user,
}

/// Gmail Thread
@freezed
class GmailThread with _$GmailThread {
  const factory GmailThread({
    required String id,
    required String snippet,
    @Default([]) List<String> messageIds,
    DateTime? lastMessageTime,
  }) = _GmailThread;

  factory GmailThread.fromJson(Map<String, dynamic> json) =>
      _$GmailThreadFromJson(json);
}

/// Gmail Watch
@freezed
class GmailWatch with _$GmailWatch {
  const factory GmailWatch({
    required String integrationId,
    required String historyId,
    DateTime? expiration,
  }) = _GmailWatch;

  factory GmailWatch.fromJson(Map<String, dynamic> json) =>
      _$GmailWatchFromJson(json);
}

/// Outlook-specific entities

/// Outlook Folder
@freezed
class OutlookFolder with _$OutlookFolder {
  const factory OutlookFolder({
    required String id,
    required String displayName,
    String? parentFolderId,
    @Default(0) int totalItemCount,
    @Default(0) int unreadItemCount,
    @Default(false) bool isHidden,
  }) = _OutlookFolder;

  factory OutlookFolder.fromJson(Map<String, dynamic> json) =>
      _$OutlookFolderFromJson(json);
}

/// Outlook Category
@freezed
class OutlookCategory with _$OutlookCategory {
  const factory OutlookCategory({
    required String id,
    required String displayName,
    String? color,
  }) = _OutlookCategory;

  factory OutlookCategory.fromJson(Map<String, dynamic> json) =>
      _$OutlookCategoryFromJson(json);
}

/// Outlook Flag Status
enum OutlookFlagStatus {
  notFlagged,
  flagged,
  complete,
}

/// Email-to-Task Conversion Request
@freezed
class EmailToTaskRequest with _$EmailToTaskRequest {
  const factory EmailToTaskRequest({
    required String emailId,
    required String integrationId,
    String? title, // Override subject
    String? description, // Override body
    String? listId,
    String? priority,
    DateTime? dueDate,
    @Default([]) List<String> tags,
    @Default(true) bool linkEmail,
    @Default(true) bool includeAttachments,
    @Default(false) bool markEmailAsRead,
  }) = _EmailToTaskRequest;

  factory EmailToTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailToTaskRequestFromJson(json);
}

/// Email Forwarding Rule
@freezed
class EmailForwardingRule with _$EmailForwardingRule {
  const factory EmailForwardingRule({
    required String id,
    required String integrationId,
    required String forwardingAddress,
    @Default(true) bool isActive,
    String? defaultListId,
    String? defaultPriority,
    @Default([]) List<String> defaultTags,
    @Default(true) bool parseEmailContent,
    DateTime? createdAt,
  }) = _EmailForwardingRule;

  factory EmailForwardingRule.fromJson(Map<String, dynamic> json) =>
      _$EmailForwardingRuleFromJson(json);
}

/// Email Integration Sync Result
@freezed
class EmailSyncResult with _$EmailSyncResult {
  const factory EmailSyncResult({
    required String integrationId,
    required DateTime syncedAt,
    required int emailsProcessed,
    required int tasksCreated,
    required int emailsLinked,
    @Default([]) List<String> newEmailIds,
    @Default([]) List<String> errors,
    String? nextSyncToken, // For incremental sync
  }) = _EmailSyncResult;

  factory EmailSyncResult.fromJson(Map<String, dynamic> json) =>
      _$EmailSyncResultFromJson(json);
}

/// Email Search Query
@freezed
class EmailSearchQuery with _$EmailSearchQuery {
  const factory EmailSearchQuery({
    String? query, // Free-text search
    String? from,
    String? to,
    String? subject,
    @Default([]) List<String> labels,
    @Default([]) List<String> categories,
    DateTime? after,
    DateTime? before,
    bool? hasAttachment,
    bool? isStarred,
    bool? isUnread,
    int? maxResults,
  }) = _EmailSearchQuery;

  factory EmailSearchQuery.fromJson(Map<String, dynamic> json) =>
      _$EmailSearchQueryFromJson(json);
}
