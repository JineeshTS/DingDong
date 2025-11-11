import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing up with email and password
///
/// Encapsulates the business logic for email/password registration
class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  /// Execute the sign up operation
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [displayName]: User's display name
  ///
  /// Returns:
  /// - Right(UserEntity): Successfully created user
  /// - Left(Failure): Registration failure (email exists, weak password, etc.)
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Check if email is already in use
    final emailCheckResult = await repository.isEmailAvailable(email: email);

    final isAvailable = emailCheckResult.fold(
      (failure) => false, // Assume not available on error
      (available) => available,
    );

    if (!isAvailable) {
      return Left(
          ValidationFailure(message: 'Email is already in use'));
    }

    // Validate password strength
    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      return Left(ValidationFailure(message: passwordValidation));
    }

    // Validate display name
    if (displayName.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Display name cannot be empty'));
    }

    if (displayName.trim().length < 2) {
      return Left(ValidationFailure(
          message: 'Display name must be at least 2 characters'));
    }

    if (displayName.trim().length > 50) {
      return Left(ValidationFailure(
          message: 'Display name cannot exceed 50 characters'));
    }

    // Delegate to repository
    return await repository.signUpWithEmail(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName.trim(),
    );
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  ///
  /// Returns null if valid, error message if invalid
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 128) {
      return 'Password cannot exceed 128 characters';
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null; // Password is valid
  }
}
