import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for updating user information
class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    // Validate display name
    if (user.displayName != null && user.displayName!.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Display name cannot be empty'));
    }

    if (user.displayName != null && user.displayName!.length > 50) {
      return Left(ValidationFailure(
          message: 'Display name cannot exceed 50 characters'));
    }

    // Validate bio if provided
    if (user.bio != null && user.bio!.length > 500) {
      return Left(
          ValidationFailure(message: 'Bio cannot exceed 500 characters'));
    }

    return await repository.updateUser(user);
  }
}
