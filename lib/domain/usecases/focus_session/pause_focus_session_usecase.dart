import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for pausing an active focus session
///
/// Business Rules:
/// - Session must exist
/// - Session must be in 'inProgress' status
/// - Cannot pause an already paused, completed, or cancelled session
/// - Pause time is recorded for quality calculation
class PauseFocusSessionUseCase {
  final FocusSessionRepository repository;

  PauseFocusSessionUseCase(this.repository);

  /// Pauses an active focus session
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to pause
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Successfully paused session
  /// - Left(ValidationFailure): If validation fails
  /// - Left(NotFoundFailure): If session doesn't exist
  Future<Either<Failure, FocusSessionEntity>> call(String sessionId) async {
    // Validate session ID
    if (sessionId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Session ID is required',
      ));
    }

    // Get the session to validate its status
    final sessionResult = await repository.getFocusSession(sessionId);

    return sessionResult.fold(
      (failure) => Left(failure),
      (session) async {
        // Validate session is in progress
        if (session.status != FocusSessionStatus.inProgress) {
          final statusMessage = session.status == FocusSessionStatus.paused
              ? 'Session is already paused'
              : session.status == FocusSessionStatus.completed
                  ? 'Cannot pause a completed session'
                  : 'Cannot pause a cancelled session';

          return Left(ValidationFailure(
            message: statusMessage,
          ));
        }

        // Pause the session
        return await repository.pauseFocusSession(sessionId);
      },
    );
  }
}
