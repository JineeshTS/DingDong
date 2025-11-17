import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/email_integration.dart';

part 'email_integration_state.freezed.dart';

/// Email Integration State
///
/// Manages the state for email integrations (Gmail, Outlook)
@freezed
class EmailIntegrationState with _$EmailIntegrationState {
  const factory EmailIntegrationState({
    // Connected integrations
    @Default([]) List<EmailIntegration> integrations,

    // Current active integration
    EmailIntegration? activeIntegration,

    // Fetched emails
    @Default([]) List<Email> emails,

    // Email folders/labels
    @Default([]) List<dynamic> folders, // GmailLabel or OutlookFolder

    // Sync status
    @Default(false) bool isSyncing,
    DateTime? lastSyncedAt,
    EmailSyncResult? lastSyncResult,

    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isConnecting,
    @Default(false) bool isFetchingEmails,

    // Error
    String? error,

    // Selected emails (for bulk actions)
    @Default([]) List<String> selectedEmailIds,

    // Filter/search
    EmailSearchQuery? searchQuery,
  }) = _EmailIntegrationState;

  factory EmailIntegrationState.initial() => const EmailIntegrationState();
}

/// Email Integration Event (for handling async results)
@freezed
class EmailIntegrationEvent with _$EmailIntegrationEvent {
  // Integration events
  const factory EmailIntegrationEvent.integrationConnected({
    required EmailIntegration integration,
  }) = IntegrationConnected;

  const factory EmailIntegrationEvent.integrationDisconnected({
    required String integrationId,
  }) = IntegrationDisconnected;

  // Email events
  const factory EmailIntegrationEvent.emailsFetched({
    required List<Email> emails,
  }) = EmailsFetched;

  const factory EmailIntegrationEvent.emailSynced({
    required EmailSyncResult result,
  }) = EmailSynced;

  const factory EmailIntegrationEvent.taskCreatedFromEmail({
    required String emailId,
    required String taskId,
  }) = TaskCreatedFromEmail;

  // Error events
  const factory EmailIntegrationEvent.error({
    required String message,
  }) = EmailIntegrationError;
}
