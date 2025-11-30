import '../../../core/services/gmail_service.dart';
import '../../../core/services/outlook_email_service.dart';
import '../../../core/utils/logger.dart';
import '../../entities/email_integration.dart';

/// Use case for fetching emails from an email integration
class FetchEmailsUseCase {
  final GmailService _gmailService;
  final OutlookEmailService _outlookEmailService;
  final _logger = Logger();

  FetchEmailsUseCase(
    this._gmailService,
    this._outlookEmailService,
  );

  /// Fetch emails from integration
  ///
  /// [integration] - Email integration details
  /// [query] - Optional search query
  /// [maxResults] - Maximum number of results (default: 50)
  /// Returns list of emails
  Future<List<Email>> call({
    required EmailIntegration integration,
    EmailSearchQuery? query,
    int maxResults = 50,
  }) async {
    try {
      _logger.info('Fetching emails from integration: ${integration.id}');

      // Validate integration
      if (!integration.isConnected) {
        throw StateError('Integration is not connected');
      }

      if (!integration.isActive) {
        throw StateError('Integration is not active');
      }

      // Get access token
      final accessToken = integration.credentials?['accessToken'] as String?;
      if (accessToken == null) {
        throw StateError('Access token not found');
      }

      // Fetch emails based on provider
      late List<Email> emails;

      switch (integration.provider) {
        case EmailProvider.gmail:
          emails = await _gmailService.fetchEmails(
            accessToken: accessToken,
            query: query,
            maxResults: maxResults,
          );
          break;

        case EmailProvider.outlook:
          emails = await _outlookEmailService.fetchEmails(
            accessToken: accessToken,
            query: query,
            maxResults: maxResults,
          );
          break;

        case EmailProvider.other:
          throw UnimplementedError('Provider not supported');
      }

      _logger.info('Fetched ${emails.length} emails');

      return emails;
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch emails',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
