import '../../../core/services/gmail_service.dart';
import '../../../core/services/outlook_email_service.dart';
import '../../../core/utils/logger.dart';
import '../../entities/email_integration.dart';
import '../../entities/task_entity.dart';

/// Use case for creating a task from an email
///
/// This parses email content and creates a task with the email linked
class CreateTaskFromEmailUseCase {
  final GmailService _gmailService;
  final OutlookEmailService _outlookEmailService;
  final _logger = Logger();

  CreateTaskFromEmailUseCase(
    this._gmailService,
    this._outlookEmailService,
  );

  /// Create task from email
  ///
  /// [integration] - Email integration details
  /// [emailId] - Email ID to convert
  /// [listId] - Optional list ID for the task
  /// [userId] - User ID who owns the task
  /// Returns a TaskEntity and EmailToTaskRequest
  Future<EmailToTaskRequest> call({
    required EmailIntegration integration,
    required String emailId,
    required String userId,
    String? listId,
  }) async {
    try {
      _logger.info('Creating task from email: $emailId');

      // Validate integration
      if (!integration.isConnected) {
        throw StateError('Integration is not connected');
      }

      // Get access token
      final accessToken = integration.credentials?['accessToken'] as String?;
      if (accessToken == null) {
        throw StateError('Access token not found');
      }

      // Create task request based on provider
      late EmailToTaskRequest taskRequest;

      switch (integration.provider) {
        case EmailProvider.gmail:
          taskRequest = await _gmailService.createTaskFromEmail(
            accessToken: accessToken,
            emailId: emailId,
            listId: listId,
          );
          break;

        case EmailProvider.outlook:
          taskRequest = await _outlookEmailService.createTaskFromEmail(
            accessToken: accessToken,
            emailId: emailId,
            listId: listId,
          );
          break;

        case EmailProvider.other:
          throw UnimplementedError('Provider not supported');
      }

      // Add integration ID
      taskRequest = taskRequest.copyWith(
        integrationId: integration.id,
      );

      _logger.info('Task request created from email');

      return taskRequest;
    } catch (e, stackTrace) {
      _logger.error('Failed to create task from email',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
