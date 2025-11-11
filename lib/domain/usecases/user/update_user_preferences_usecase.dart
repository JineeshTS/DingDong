import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for updating user preferences
class UpdateUserPreferencesUseCase {
  final UserRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required UserPreferences preferences,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.updatePreferences(
      userId: userId,
      preferences: preferences,
    );
  }
}
