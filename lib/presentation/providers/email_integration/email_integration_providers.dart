import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gmail_service.dart';
import '../../../core/services/outlook_email_service.dart';
import '../../../domain/usecases/email_integration/connect_email_integration_usecase.dart';
import '../../../domain/usecases/email_integration/create_task_from_email_usecase.dart';
import '../../../domain/usecases/email_integration/fetch_emails_usecase.dart';
import '../../../domain/usecases/email_integration/sync_emails_usecase.dart';
import '../auth_provider.dart';
import 'email_integration_notifier.dart';
import 'email_integration_state.dart';

// ============================================================================
// Service Providers
// ============================================================================

/// Provider for Gmail Service
final gmailServiceProvider = Provider<GmailService>((ref) {
  return GmailService();
});

/// Provider for Outlook Email Service
final outlookEmailServiceProvider = Provider<OutlookEmailService>((ref) {
  return OutlookEmailService();
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for ConnectEmailIntegrationUseCase
final connectEmailIntegrationUseCaseProvider =
    Provider<ConnectEmailIntegrationUseCase>((ref) {
  return ConnectEmailIntegrationUseCase(
    ref.read(gmailServiceProvider),
    ref.read(outlookEmailServiceProvider),
  );
});

/// Provider for FetchEmailsUseCase
final fetchEmailsUseCaseProvider = Provider<FetchEmailsUseCase>((ref) {
  return FetchEmailsUseCase(
    ref.read(gmailServiceProvider),
    ref.read(outlookEmailServiceProvider),
  );
});

/// Provider for CreateTaskFromEmailUseCase
final createTaskFromEmailUseCaseProvider =
    Provider<CreateTaskFromEmailUseCase>((ref) {
  return CreateTaskFromEmailUseCase(
    ref.read(gmailServiceProvider),
    ref.read(outlookEmailServiceProvider),
  );
});

/// Provider for SyncEmailsUseCase
final syncEmailsUseCaseProvider = Provider<SyncEmailsUseCase>((ref) {
  return SyncEmailsUseCase(
    ref.read(fetchEmailsUseCaseProvider),
  );
});

// ============================================================================
// Email Integration State Notifier Provider
// ============================================================================

/// Main email integration state notifier provider
///
/// Manages email integration state including connections, emails, and sync.
///
/// Usage:
/// ```dart
/// final emailState = ref.watch(emailIntegrationNotifierProvider);
/// final emailNotifier = ref.read(emailIntegrationNotifierProvider.notifier);
///
/// // Connect integration
/// await emailNotifier.connectIntegration(EmailProvider.gmail);
///
/// // Fetch emails
/// await emailNotifier.fetchEmails();
///
/// // Create task from email
/// await emailNotifier.createTaskFromEmail(emailId: 'email_123');
/// ```
final emailIntegrationNotifierProvider =
    StateNotifierProvider<EmailIntegrationNotifier, EmailIntegrationState>(
        (ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return EmailIntegrationNotifier(
    connectUseCase: ref.read(connectEmailIntegrationUseCaseProvider),
    fetchEmailsUseCase: ref.read(fetchEmailsUseCaseProvider),
    createTaskFromEmailUseCase: ref.read(createTaskFromEmailUseCaseProvider),
    syncEmailsUseCase: ref.read(syncEmailsUseCaseProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for connected integrations
final connectedIntegrationsProvider = Provider.autoDispose((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.integrations;
});

/// Provider for active integration
final activeEmailIntegrationProvider = Provider.autoDispose((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.activeIntegration;
});

/// Provider for fetched emails
final fetchedEmailsProvider = Provider.autoDispose((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.emails;
});

/// Provider for email integration loading state
final isEmailIntegrationLoadingProvider = Provider.autoDispose<bool>((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.isLoading ||
      emailState.isConnecting ||
      emailState.isFetchingEmails ||
      emailState.isSyncing;
});

/// Provider for email integration error
final emailIntegrationErrorProvider = Provider.autoDispose<String?>((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.error;
});

/// Provider for last sync result
final lastEmailSyncResultProvider = Provider.autoDispose((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.lastSyncResult;
});

/// Provider for selected emails count
final selectedEmailsCountProvider = Provider.autoDispose<int>((ref) {
  final emailState = ref.watch(emailIntegrationNotifierProvider);
  return emailState.selectedEmailIds.length;
});
