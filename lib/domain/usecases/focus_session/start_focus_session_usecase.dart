import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for starting a new focus session
///
/// Business Rules:
/// - Duration must be between 5 and 180 minutes
/// - Task ID is optional
/// - Only one active session allowed per user at a time
/// - Session status is set to 'inProgress' by default
/// - Validates there's no existing active session before creating
class StartFocusSessionUseCase {
  final FocusSessionRepository repository;

  StartFocusSessionUseCase(this.repository);

  /// Starts a new focus session
  ///
  /// Parameters:
  /// - [session]: The focus session entity to create
  ///
  /// Returns:
  /// - Right(FocusSessionEntity): Successfully created session
  /// - Left(ValidationFailure): If validation fails
  /// - Left(ConflictFailure): If user already has an active session
  Future<Either<Failure, FocusSessionEntity>> call(
    FocusSessionEntity session,
  ) async {
    // Validate duration (5-180 minutes)
    final durationInMinutes = session.plannedDuration.inMinutes;
    if (durationInMinutes < 5) {
      return Left(ValidationFailure(
        message: 'Focus session duration must be at least 5 minutes',
      ));
    }

    if (durationInMinutes > 180) {
      return Left(ValidationFailure(
        message: 'Focus session duration cannot exceed 180 minutes (3 hours)',
      ));
    }

    // Validate user ID
    if (session.userId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'User ID is required',
      ));
    }

    // Validate session type
    if (session.type == FocusSessionType.pomodoro &&
        session.plannedDuration.inMinutes != 25) {
      return Left(ValidationFailure(
        message: 'Pomodoro sessions must be 25 minutes',
      ));
    }

    if (session.type == FocusSessionType.shortBreak &&
        session.plannedDuration.inMinutes != 5) {
      return Left(ValidationFailure(
        message: 'Short break sessions must be 5 minutes',
      ));
    }

    if (session.type == FocusSessionType.longBreak &&
        session.plannedDuration.inMinutes != 15) {
      return Left(ValidationFailure(
        message: 'Long break sessions must be 15 minutes',
      ));
    }

    // Validate session status is inProgress
    if (session.status != FocusSessionStatus.inProgress) {
      return Left(ValidationFailure(
        message: 'New focus session must have status "inProgress"',
      ));
    }

    // Check for existing active session
    final activeSessionResult = await repository.getActiveFocusSession(
      session.userId,
    );

    return activeSessionResult.fold(
      (failure) => Left(failure),
      (activeSession) {
        // If there's already an active session, return conflict error
        if (activeSession != null) {
          return Left(ConflictFailure(
            message: 'User already has an active focus session. '
                'Please complete or cancel the existing session first.',
            localData: activeSession,
          ));
        }

        // Create the new session
        return repository.createFocusSession(session);
      },
    );
  }
}
