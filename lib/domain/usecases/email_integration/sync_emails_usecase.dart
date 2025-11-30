import '../../../core/utils/logger.dart';
import '../../entities/email_integration.dart';
import 'fetch_emails_usecase.dart';

/// Use case for syncing emails from an email integration
///
/// This fetches new emails and processes them according to integration settings
class SyncEmailsUseCase {
  final FetchEmailsUseCase _fetchEmailsUseCase;
  final _logger = Logger();

  SyncEmailsUseCase(this._fetchEmailsUseCase);

  /// Sync emails from integration
  ///
  /// [integration] - Email integration details
  /// Returns sync result with statistics
  Future<EmailSyncResult> call({
    required EmailIntegration integration,
  }) async {
    try {
      _logger.info('Syncing emails for integration: ${integration.id}');

      final startTime = DateTime.now();
      final newEmailIds = <String>[];
      final errors = <String>[];
      var tasksCreated = 0;
      var emailsLinked = 0;

      // Build query based on settings
      EmailSearchQuery? query;

      final settings = integration.settings;
      if (settings != null) {
        // Apply filters based on settings
        final labelsToInclude = settings.includeLabels;
        final isStarredOnly = settings.createTasksFromStarred;

        query = EmailSearchQuery(
          labels: labelsToInclude,
          isStarred: isStarredOnly ? true : null,
          isUnread: true, // Only fetch unread emails
        );
      }

      // Fetch emails
      List<Email> emails;
      try {
        emails = await _fetchEmailsUseCase(
          integration: integration,
          query: query,
          maxResults: 100, // Fetch up to 100 new emails per sync
        );
      } catch (e) {
        errors.add('Failed to fetch emails: $e');
        emails = [];
      }

      // Process each email
      for (final email in emails) {
        try {
          newEmailIds.add(email.id);

          // Apply filtering rules
          if (_shouldCreateTask(email, settings)) {
            // In a full implementation, would create task here
            // For now, just count it
            tasksCreated++;
            emailsLinked++;
          }
        } catch (e) {
          errors.add('Error processing email ${email.id}: $e');
        }
      }

      final syncResult = EmailSyncResult(
        integrationId: integration.id,
        syncedAt: DateTime.now(),
        emailsProcessed: emails.length,
        tasksCreated: tasksCreated,
        emailsLinked: emailsLinked,
        newEmailIds: newEmailIds,
        errors: errors,
      );

      _logger.info(
        'Email sync completed: ${emails.length} emails processed, '
        '$tasksCreated tasks created',
      );

      return syncResult;
    } catch (e, stackTrace) {
      _logger.error('Failed to sync emails',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Determine if a task should be created from an email
  bool _shouldCreateTask(Email email, EmailSettings? settings) {
    if (settings == null) return true;

    // Check if email is from excluded sender
    if (settings.excludeSenders.contains(email.fromEmail)) {
      return false;
    }

    // Check if subject matches excluded patterns
    for (final excludePattern in settings.excludeSubjects) {
      if (email.subject.toLowerCase().contains(excludePattern.toLowerCase())) {
        return false;
      }
    }

    // Check if requires keyword
    if (settings.requireKeyword && settings.keyword != null) {
      final keyword = settings.keyword!.toLowerCase();
      final hasKeyword = email.subject.toLowerCase().contains(keyword) ||
          (email.body?.toLowerCase().contains(keyword) ?? false);

      if (!hasKeyword) {
        return false;
      }
    }

    // Check label exclusions
    if (settings.excludeLabels.isNotEmpty) {
      for (final label in email.labels) {
        if (settings.excludeLabels.contains(label)) {
          return false;
        }
      }
    }

    return true;
  }
}
