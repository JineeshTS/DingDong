import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for enabling/disabling biometric authentication
class ToggleBiometricAuthUseCase {
  final UserRepository repository;

  ToggleBiometricAuthUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required bool enabled,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.toggleBiometricAuth(
      userId: userId,
      enabled: enabled,
    );
  }
}
