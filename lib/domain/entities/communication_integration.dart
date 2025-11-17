import 'package:freezed_annotation/freezed_annotation.dart';

part 'communication_integration.freezed.dart';
part 'communication_integration.g.dart';

/// Communication Tool Integration
///
/// Represents a connection to external communication platforms
/// (Slack, Microsoft Teams, Discord)
@freezed
class CommunicationIntegration with _$CommunicationIntegration {
  const factory CommunicationIntegration({
    required String id,
    required String userId,
    required CommunicationProvider provider,
    required String workspaceId, // Slack workspace, Teams tenant, Discord guild
    required String workspaceName,
    required bool isConnected,
    required bool isActive,
    @Default([]) List<String> selectedChannels, // Channels to monitor
    CommunicationSettings? settings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens
    DateTime? connectedAt,
    DateTime? updatedAt,
  }) = _CommunicationIntegration;

  factory CommunicationIntegration.fromJson(Map<String, dynamic> json) =>
      _$CommunicationIntegrationFromJson(json);
}

/// Communication Platform Providers
enum CommunicationProvider {
  slack,
  microsoftTeams,
  discord,
  other,
}

/// Communication Integration Settings
@freezed
class CommunicationSettings with _$CommunicationSettings {
  const factory CommunicationSettings({
    // Task creation from messages
    @Default(true) bool createTasksFromMessages,
    @Default(true) bool createTasksFromReactions, // React with emoji to create task
    @Default('✅') String taskReactionEmoji,

    // Notifications
    @Default(true) bool sendTaskNotifications,
    @Default(true) bool sendReminderNotifications,
    @Default(true) bool sendCompletionNotifications,
    String? notificationChannelId, // Default channel for notifications

    // Bot commands
    @Default(true) bool enableBotCommands,
    @Default('/task') String commandPrefix,

    // Message parsing
    @Default(true) bool parseTasksFromMentions,
    @Default(true) bool parseDueDates,
    @Default(true) bool parsePriority,

    // Filtering
    @Default([]) List<String> excludeUsers, // Don't create tasks from these users
    @Default([]) List<String> excludeChannels,
    @Default(false) bool requireKeyword, // Require keyword like "TODO:" to create task
    String? keyword,
  }) = _CommunicationSettings;

  factory CommunicationSettings.fromJson(Map<String, dynamic> json) =>
      _$CommunicationSettingsFromJson(json);
}

/// Channel/Room in communication platform
@freezed
class CommunicationChannel with _$CommunicationChannel {
  const factory CommunicationChannel({
    required String id,
    required String name,
    CommunicationChannelType? type,
    String? topic,
    @Default(false) bool isPrivate,
    @Default(false) bool isArchived,
  }) = _CommunicationChannel;

  factory CommunicationChannel.fromJson(Map<String, dynamic> json) =>
      _$CommunicationChannelFromJson(json);
}

/// Channel types
enum CommunicationChannelType {
  publicChannel,
  privateChannel,
  directMessage,
  group,
}

/// Message from communication platform
@freezed
class CommunicationMessage with _$CommunicationMessage {
  const factory CommunicationMessage({
    required String id,
    required String integrationId,
    required CommunicationProvider provider,
    required String channelId,
    required String channelName,
    required String userId,
    required String username,
    required String text,
    DateTime? timestamp,
    String? threadId, // For threaded messages
    @Default([]) List<String> mentions, // @mentioned users
    @Default([]) List<String> reactions, // Emoji reactions
    @Default([]) List<Attachment> attachments,
    String? linkedTaskId, // If task was created from this message
    String? messageUrl, // Deep link to message
  }) = _CommunicationMessage;

  factory CommunicationMessage.fromJson(Map<String, dynamic> json) =>
      _$CommunicationMessageFromJson(json);
}

/// Attachment in message
@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String filename,
    String? url,
    String? mimeType,
    int? size,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}

/// Slack-specific entities

/// Slack Workspace
@freezed
class SlackWorkspace with _$SlackWorkspace {
  const factory SlackWorkspace({
    required String id,
    required String name,
    String? domain,
    String? iconUrl,
  }) = _SlackWorkspace;

  factory SlackWorkspace.fromJson(Map<String, dynamic> json) =>
      _$SlackWorkspaceFromJson(json);
}

/// Slack Slash Command
@freezed
class SlackCommand with _$SlackCommand {
  const factory SlackCommand({
    required String command,
    required String text,
    required String userId,
    required String userName,
    required String channelId,
    required String channelName,
    String? triggerId,
  }) = _SlackCommand;

  factory SlackCommand.fromJson(Map<String, dynamic> json) =>
      _$SlackCommandFromJson(json);
}

/// Microsoft Teams-specific entities

/// Teams Tenant
@freezed
class TeamsTenant with _$TeamsTenant {
  const factory TeamsTenant({
    required String id,
    required String displayName,
  }) = _TeamsTenant;

  factory TeamsTenant.fromJson(Map<String, dynamic> json) =>
      _$TeamsTenantFromJson(json);
}

/// Teams Team
@freezed
class TeamsTeam with _$TeamsTeam {
  const factory TeamsTeam({
    required String id,
    required String displayName,
    String? description,
    String? webUrl,
  }) = _TeamsTeam;

  factory TeamsTeam.fromJson(Map<String, dynamic> json) =>
      _$TeamsTeamFromJson(json);
}

/// Discord-specific entities

/// Discord Guild (Server)
@freezed
class DiscordGuild with _$DiscordGuild {
  const factory DiscordGuild({
    required String id,
    required String name,
    String? iconUrl,
    int? memberCount,
  }) = _DiscordGuild;

  factory DiscordGuild.fromJson(Map<String, dynamic> json) =>
      _$DiscordGuildFromJson(json);
}

/// Bot Command Response
@freezed
class BotCommandResponse with _$BotCommandResponse {
  const factory BotCommandResponse({
    required String text,
    @Default(false) bool isEphemeral, // Only visible to user who triggered
    @Default([]) List<BotAction> actions,
  }) = _BotCommandResponse;

  factory BotCommandResponse.fromJson(Map<String, dynamic> json) =>
      _$BotCommandResponseFromJson(json);
}

/// Bot Action (buttons, etc.)
@freezed
class BotAction with _$BotAction {
  const factory BotAction({
    required String id,
    required String label,
    BotActionType? type,
    String? value,
  }) = _BotAction;

  factory BotAction.fromJson(Map<String, dynamic> json) =>
      _$BotActionFromJson(json);
}

/// Bot Action Types
enum BotActionType {
  button,
  select,
  datePicker,
  textInput,
}

/// Communication Integration Result
@freezed
class CommunicationSyncResult with _$CommunicationSyncResult {
  const factory CommunicationSyncResult({
    required String integrationId,
    required DateTime syncedAt,
    required int messagesProcessed,
    required int tasksCreated,
    required int notificationsSent,
    @Default([]) List<String> errors,
  }) = _CommunicationSyncResult;

  factory CommunicationSyncResult.fromJson(Map<String, dynamic> json) =>
      _$CommunicationSyncResultFromJson(json);
}
