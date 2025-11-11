import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Apple
///
/// Encapsulates the business logic for Apple OAuth authentication
class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  /// Execute the Apple sign in operation
  ///
  /// Returns:
  /// - Right(UserEntity): Successfully authenticated user via Apple
  /// - Left(Failure): Authentication failure (cancelled, network error, etc.)
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithApple();
  }
}
