import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// User repository interface
abstract class UserRepository {
  /// Get user by ID
  Future<Either<Failure, UserEntity>> getUser(String id);

  /// Get user by email
  Future<Either<Failure, UserEntity?>> getUserByEmail(String email);

  /// Update user
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  /// Update user preferences
  Future<Either<Failure, UserEntity>> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  });

  /// Update subscription
  Future<Either<Failure, UserEntity>> updateSubscription({
    required String userId,
    required UserSubscriptionTier tier,
    DateTime? expiresAt,
  });

  /// Enable/disable biometric authentication
  Future<Either<Failure, UserEntity>> setBiometric({
    required String userId,
    required bool enabled,
  });

  /// Set default list
  Future<Either<Failure, UserEntity>> setDefaultList({
    required String userId,
    required String listId,
  });

  /// Update theme mode
  Future<Either<Failure, UserEntity>> updateThemeMode({
    required String userId,
    required ThemeMode themeMode,
  });

  /// Update locale
  Future<Either<Failure, UserEntity>> updateLocale({
    required String userId,
    required String locale,
  });

  /// Deactivate account
  Future<Either<Failure, void>> deactivateAccount(String userId);

  /// Reactivate account
  Future<Either<Failure, UserEntity>> reactivateAccount(String userId);

  /// Export user data
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(String userId);

  /// Watch user (stream)
  Stream<Either<Failure, UserEntity>> watchUser(String id);
}
