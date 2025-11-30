import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/email_integration.dart';
import '../../../domain/usecases/email_integration/connect_email_integration_usecase.dart';
import '../../../domain/usecases/email_integration/create_task_from_email_usecase.dart';
import '../../../domain/usecases/email_integration/fetch_emails_usecase.dart';
import '../../../domain/usecases/email_integration/sync_emails_usecase.dart';
import 'email_integration_state.dart';

/// Email Integration Notifier
///
/// Manages email integration state and operations
class EmailIntegrationNotifier extends StateNotifier<EmailIntegrationState> {
  final ConnectEmailIntegrationUseCase _connectUseCase;
  final FetchEmailsUseCase _fetchEmailsUseCase;
  final CreateTaskFromEmailUseCase _createTaskFromEmailUseCase;
  final SyncEmailsUseCase _syncEmailsUseCase;
  final String userId;
  final _logger = Logger();

  EmailIntegrationNotifier({
    required ConnectEmailIntegrationUseCase connectUseCase,
    required FetchEmailsUseCase fetchEmailsUseCase,
    required CreateTaskFromEmailUseCase createTaskFromEmailUseCase,
    required SyncEmailsUseCase syncEmailsUseCase,
    required this.userId,
  })  : _connectUseCase = connectUseCase,
        _fetchEmailsUseCase = fetchEmailsUseCase,
        _createTaskFromEmailUseCase = createTaskFromEmailUseCase,
        _syncEmailsUseCase = syncEmailsUseCase,
        super(EmailIntegrationState.initial());

  // ============================================================================
  // Integration Management
  // ============================================================================

  /// Connect email integration
  Future<void> connectIntegration(EmailProvider provider) async {
    try {
      state = state.copyWith(isConnecting: true, error: null);

      final integration = await _connectUseCase(
        userId: userId,
        provider: provider,
      );

      state = state.copyWith(
        integrations: [...state.integrations, integration],
        activeIntegration: integration,
        isConnecting: false,
      );

      _logger.info('Email integration connected: ${integration.provider}');
    } catch (e, stackTrace) {
      _logger.error('Failed to connect email integration',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isConnecting: false,
        error: 'Failed to connect: ${e.toString()}',
      );
    }
  }

  /// Disconnect email integration
  Future<void> disconnectIntegration(String integrationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Remove integration from list
      final updatedIntegrations = state.integrations
          .where((i) => i.id != integrationId)
          .toList();

      // Clear active if it was the disconnected one
      EmailIntegration? newActive = state.activeIntegration;
      if (state.activeIntegration?.id == integrationId) {
        newActive = updatedIntegrations.isNotEmpty ? updatedIntegrations.first : null;
      }

      state = state.copyWith(
        integrations: updatedIntegrations,
        activeIntegration: newActive,
        isLoading: false,
      );

      _logger.info('Email integration disconnected: $integrationId');
    } catch (e, stackTrace) {
      _logger.error('Failed to disconnect email integration',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to disconnect: ${e.toString()}',
      );
    }
  }

  /// Set active integration
  void setActiveIntegration(EmailIntegration integration) {
    state = state.copyWith(activeIntegration: integration);
    _logger.info('Active integration changed: ${integration.provider}');
  }

  // ============================================================================
  // Email Operations
  // ============================================================================

  /// Fetch emails from active integration
  Future<void> fetchEmails({
    EmailSearchQuery? query,
    int maxResults = 50,
  }) async {
    try {
      final integration = state.activeIntegration;
      if (integration == null) {
        throw StateError('No active integration');
      }

      state = state.copyWith(
        isFetchingEmails: true,
        error: null,
        searchQuery: query,
      );

      final emails = await _fetchEmailsUseCase(
        integration: integration,
        query: query,
        maxResults: maxResults,
      );

      state = state.copyWith(
        emails: emails,
        isFetchingEmails: false,
      );

      _logger.info('Fetched ${emails.length} emails');
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch emails',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isFetchingEmails: false,
        error: 'Failed to fetch emails: ${e.toString()}',
      );
    }
  }

  /// Sync emails from active integration
  Future<void> syncEmails() async {
    try {
      final integration = state.activeIntegration;
      if (integration == null) {
        throw StateError('No active integration');
      }

      state = state.copyWith(isSyncing: true, error: null);

      final result = await _syncEmailsUseCase(integration: integration);

      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
        lastSyncResult: result,
      );

      _logger.info(
        'Email sync completed: ${result.emailsProcessed} emails processed, '
        '${result.tasksCreated} tasks created',
      );

      // Refresh emails after sync
      await fetchEmails();
    } catch (e, stackTrace) {
      _logger.error('Failed to sync emails',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isSyncing: false,
        error: 'Failed to sync emails: ${e.toString()}',
      );
    }
  }

  /// Create task from email
  Future<void> createTaskFromEmail({
    required String emailId,
    String? listId,
  }) async {
    try {
      final integration = state.activeIntegration;
      if (integration == null) {
        throw StateError('No active integration');
      }

      state = state.copyWith(isLoading: true, error: null);

      final taskRequest = await _createTaskFromEmailUseCase(
        integration: integration,
        emailId: emailId,
        userId: userId,
        listId: listId,
      );

      // In a full implementation, would create the task here
      // using CreateTaskUseCase

      state = state.copyWith(isLoading: false);

      _logger.info('Task created from email: $emailId');
    } catch (e, stackTrace) {
      _logger.error('Failed to create task from email',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create task: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // Selection & Filtering
  // ============================================================================

  /// Select email
  void selectEmail(String emailId) {
    if (!state.selectedEmailIds.contains(emailId)) {
      state = state.copyWith(
        selectedEmailIds: [...state.selectedEmailIds, emailId],
      );
    }
  }

  /// Deselect email
  void deselectEmail(String emailId) {
    state = state.copyWith(
      selectedEmailIds: state.selectedEmailIds.where((id) => id != emailId).toList(),
    );
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedEmailIds: []);
  }

  /// Set search query
  void setSearchQuery(EmailSearchQuery? query) {
    state = state.copyWith(searchQuery: query);
    fetchEmails(query: query);
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await fetchEmails();
  }
}
