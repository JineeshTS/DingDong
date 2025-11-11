import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Google
///
/// Encapsulates the business logic for Google OAuth authentication
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  /// Execute the Google sign in operation
  ///
  /// Returns:
  /// - Right(UserEntity): Successfully authenticated user via Google
  /// - Left(Failure): Authentication failure (cancelled, network error, etc.)
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
