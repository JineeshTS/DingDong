import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for adding an interruption to an active focus session
///
/// Business Rules:
/// - Session must exist
/// - Session must be in 'inProgress' status
/// - Cannot add interruption to paused, completed, or cancelled sessions
/// - Interruption affects the focus quality score (each interruption reduces quality by 10%)
/// - Pause duration must be positive
/// - Reason is optional but recommended
/// - Interruption is recorded with timestamp
class AddInterruptionUseCase {
  final FocusSessionRepository repository;

  AddInterruptionUseCase(this.repository);

  /// Adds an interruption to an active focus session
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session
  /// - [pauseDuration]: How long the interruption lasted
  /// - [reason]: Optional description of the interruption
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Updated session with the interruption recorded
  /// - Left(ValidationFailure): If validation fails
  /// - Left(NotFoundFailure): If session doesn't exist
  Future<Either<Failure, FocusSessionEntity>> call({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  }) async {
    // Validate session ID
    if (sessionId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Session ID is required',
      ));
    }

    // Validate pause duration
    if (pauseDuration.inSeconds <= 0) {
      return Left(ValidationFailure(
        message: 'Pause duration must be positive',
      ));
    }

    // Validate pause duration is reasonable (not more than planned session duration)
    if (pauseDuration.inMinutes > 60) {
      return Left(ValidationFailure(
        message: 'Pause duration cannot exceed 60 minutes',
      ));
    }

    // Validate reason length if provided
    if (reason != null && reason.length > 500) {
      return Left(ValidationFailure(
        message: 'Interruption reason cannot exceed 500 characters',
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
              ? 'Cannot add interruption to a paused session. Resume it first.'
              : session.status == FocusSessionStatus.completed
                  ? 'Cannot add interruption to a completed session'
                  : 'Cannot add interruption to a cancelled session';

          return Left(ValidationFailure(
            message: statusMessage,
          ));
        }

        // Add the interruption
        return await repository.addInterruption(
          sessionId: sessionId,
          pauseDuration: pauseDuration,
          reason: reason,
        );
      },
    );
  }
}
