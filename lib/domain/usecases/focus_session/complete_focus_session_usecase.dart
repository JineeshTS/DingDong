import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for completing a focus session
///
/// Business Rules:
/// - Session must exist
/// - Session must be in 'inProgress' or 'paused' status
/// - Cannot complete an already completed or cancelled session
/// - Quality score is calculated automatically based on duration and interruptions
/// - If session has a linked task, the task's time tracking is updated
/// - End time is set to current time
/// - Actual duration is calculated from start to end time
class CompleteFocusSessionUseCase {
  final FocusSessionRepository repository;

  CompleteFocusSessionUseCase(this.repository);

  /// Completes a focus session
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to complete
  /// - [notes]: Optional notes about the session
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Successfully completed session with quality score
  /// - Left(ValidationFailure): If validation fails
  /// - Left(NotFoundFailure): If session doesn't exist
  Future<Either<Failure, FocusSessionEntity>> call({
    required String sessionId,
    String? notes,
  }) async {
    // Validate session ID
    if (sessionId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Session ID is required',
      ));
    }

    // Validate notes length if provided
    if (notes != null && notes.length > 1000) {
      return Left(ValidationFailure(
        message: 'Notes cannot exceed 1000 characters',
      ));
    }

    // Get the session to validate its status
    final sessionResult = await repository.getFocusSession(sessionId);

    return sessionResult.fold(
      (failure) => Left(failure),
      (session) async {
        // Validate session can be completed
        if (session.status == FocusSessionStatus.completed) {
          return Left(ValidationFailure(
            message: 'Session is already completed',
          ));
        }

        if (session.status == FocusSessionStatus.cancelled) {
          return Left(ValidationFailure(
            message: 'Cannot complete a cancelled session',
          ));
        }

        // Session must be in progress or paused
        if (session.status != FocusSessionStatus.inProgress &&
            session.status != FocusSessionStatus.paused) {
          return Left(ValidationFailure(
            message: 'Session must be in progress or paused to be completed',
          ));
        }

        // Complete the session
        // The repository will handle:
        // - Setting end time
        // - Calculating actual duration
        // - Quality score calculation (via entity's focusQuality getter)
        // - Updating task time tracking if taskId is present
        return await repository.completeFocusSession(
          sessionId: sessionId,
          notes: notes,
        );
      },
    );
  }
}
