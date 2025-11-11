import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for resuming a paused focus session
///
/// Business Rules:
/// - Session must exist
/// - Session must be in 'paused' status
/// - Cannot resume an in-progress, completed, or cancelled session
/// - Resume time is used to calculate total pause duration
class ResumeFocusSessionUseCase {
  final FocusSessionRepository repository;

  ResumeFocusSessionUseCase(this.repository);

  /// Resumes a paused focus session
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to resume
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Successfully resumed session
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
        // Validate session is paused
        if (session.status != FocusSessionStatus.paused) {
          final statusMessage = session.status == FocusSessionStatus.inProgress
              ? 'Session is already in progress'
              : session.status == FocusSessionStatus.completed
                  ? 'Cannot resume a completed session'
                  : 'Cannot resume a cancelled session';

          return Left(ValidationFailure(
            message: statusMessage,
          ));
        }

        // Resume the session
        return await repository.resumeFocusSession(sessionId);
      },
    );
  }
}
