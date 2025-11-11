import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/focus_session_entity.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for getting the currently active or paused focus session for a user
///
/// Business Rules:
/// - Returns the session with status 'inProgress' or 'paused'
/// - Only one active session should exist per user at a time
/// - Returns null if no active session exists
/// - User ID is required
class GetActiveFocusSessionUseCase {
  final FocusSessionRepository repository;

  GetActiveFocusSessionUseCase(this.repository);

  /// Gets the currently active or paused focus session for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user
  ///
  /// Returns:
  /// - Right(FocusSessionEntity?): Active session if exists, null otherwise
  /// - Left(ValidationFailure): If validation fails
  /// - Left(Failure): For other errors
  Future<Either<Failure, FocusSessionEntity?>> call(String userId) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'User ID is required',
      ));
    }

    // Get the active session
    return await repository.getActiveFocusSession(userId);
  }
}
