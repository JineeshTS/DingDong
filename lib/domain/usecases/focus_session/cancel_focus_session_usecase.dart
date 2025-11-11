import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for cancelling a focus session
///
/// Business Rules:
/// - Session must exist
/// - Session must be in 'inProgress' or 'paused' status
/// - Cannot cancel an already completed or cancelled session
/// - Cancelled sessions are not counted in statistics/completion rate
/// - Session is marked as cancelled with current timestamp
class CancelFocusSessionUseCase {
  final FocusSessionRepository repository;

  CancelFocusSessionUseCase(this.repository);

  /// Cancels a focus session
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to cancel
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Successfully cancelled session
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
        // Validate session can be cancelled
        if (session.status == FocusSessionStatus.completed) {
          return Left(ValidationFailure(
            message: 'Cannot cancel a completed session',
          ));
        }

        if (session.status == FocusSessionStatus.cancelled) {
          return Left(ValidationFailure(
            message: 'Session is already cancelled',
          ));
        }

        // Session must be in progress or paused
        if (session.status != FocusSessionStatus.inProgress &&
            session.status != FocusSessionStatus.paused) {
          return Left(ValidationFailure(
            message: 'Session must be in progress or paused to be cancelled',
          ));
        }

        // Cancel the session
        return await repository.cancelFocusSession(sessionId);
      },
    );
  }
}
