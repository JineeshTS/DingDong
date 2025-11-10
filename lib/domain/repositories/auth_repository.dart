import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
///
/// Defines contracts for authentication operations
/// Implementation will be in data layer
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Sign in with Microsoft
  Future<Either<Failure, UserEntity>> signInWithMicrosoft();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Get current user ID (lightweight check)
  Future<Either<Failure, String?>> getCurrentUserId();

  /// Listen to auth state changes
  Stream<UserEntity?> get authStateChanges;

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Verify email
  Future<Either<Failure, void>> sendEmailVerification();

  /// Update password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Update email
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String password,
  });

  /// Update profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  });

  /// Re-authenticate user
  Future<Either<Failure, void>> reauthenticate({
    required String password,
  });

  /// Check if email is available
  Future<Either<Failure, bool>> isEmailAvailable({
    required String email,
  });
}
