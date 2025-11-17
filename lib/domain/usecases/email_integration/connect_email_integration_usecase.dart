import '../../../core/services/gmail_service.dart';
import '../../../core/services/outlook_email_service.dart';
import '../../../core/utils/logger.dart';
import '../../entities/email_integration.dart';

/// Use case for connecting an email integration (Gmail or Outlook)
///
/// This handles OAuth authentication and stores the integration details
class ConnectEmailIntegrationUseCase {
  final GmailService _gmailService;
  final OutlookEmailService _outlookEmailService;
  final _logger = Logger();

  ConnectEmailIntegrationUseCase(
    this._gmailService,
    this._outlookEmailService,
  );

  /// Connect email integration
  ///
  /// [userId] - User ID
  /// [provider] - Email provider (Gmail or Outlook)
  /// Returns the connected EmailIntegration
  Future<EmailIntegration> call({
    required String userId,
    required EmailProvider provider,
  }) async {
    try {
      _logger.info('Connecting email integration: $provider for user: $userId');

      // Validate provider
      if (provider == EmailProvider.other) {
        throw ArgumentError('Provider "other" is not supported');
      }

      // Authenticate based on provider
      late Map<String, String> authResult;

      switch (provider) {
        case EmailProvider.gmail:
          authResult = await _gmailService.authenticate();
          break;
        case EmailProvider.outlook:
          authResult = await _outlookEmailService.authenticate();
          break;
        case EmailProvider.other:
          throw UnimplementedError('Provider not supported');
      }

      // Extract authentication details
      final emailAddress = authResult['email'] ?? '';
      final accessToken = authResult['accessToken'] ?? '';
      final refreshToken = authResult['refreshToken'] ?? '';

      // Create integration
      final integration = EmailIntegration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        provider: provider,
        emailAddress: emailAddress,
        isConnected: true,
        isActive: true,
        credentials: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresAt': authResult['expiresAt'],
        },
        connectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _logger.info('Email integration connected successfully: ${integration.id}');

      return integration;
    } catch (e, stackTrace) {
      _logger.error('Failed to connect email integration',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
