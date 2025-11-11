import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user
///
/// Encapsulates the business logic for retrieving current user information
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Execute the get current user operation
  ///
  /// Returns:
  /// - Right(UserEntity?): Current user if authenticated, null if not
  /// - Left(Failure): Error retrieving user information
  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}
