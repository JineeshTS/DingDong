import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with email and password
///
/// Encapsulates the business logic for email/password authentication
class SignInWithEmailUseCase {
  final AuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  /// Execute the sign in operation
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns:
  /// - Right(UserEntity): Successfully signed in user
  /// - Left(Failure): Authentication failure (invalid credentials, network error, etc.)
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Validate password
    if (password.isEmpty) {
      return Left(ValidationFailure(message: 'Password cannot be empty'));
    }

    if (password.length < 6) {
      return Left(ValidationFailure(
          message: 'Password must be at least 6 characters'));
    }

    // Delegate to repository
    return await repository.signInWithEmail(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
