import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for deactivating user account (soft delete)
class DeactivateAccountUseCase {
  final UserRepository repository;

  DeactivateAccountUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.deactivateAccount(userId);
  }
}
