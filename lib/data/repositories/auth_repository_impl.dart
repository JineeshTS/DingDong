import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/isar/isar_user_local_data_source.dart';
import '../datasources/local/isar/schemas/user_isar.dart';
import '../datasources/remote/firebase_auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSource remoteDataSource;
  final IsarUserLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      // Save user to local database
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final model = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Save user to local database
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign up: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final model = await remoteDataSource.signInWithGoogle();

      // Save user to local database
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign in with Google: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final model = await remoteDataSource.signInWithApple();

      // Save user to local database
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign in with Apple: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithMicrosoft() async {
    try {
      final model = await remoteDataSource.signInWithMicrosoft();

      // Save user to local database
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to sign in with Microsoft: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();

      // Clear local user data
      final currentUser = await remoteDataSource.getCurrentUserId();
      if (currentUser != null) {
        await localDataSource.deleteUser(currentUser);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Try to get from remote first (source of truth)
      final userId = await remoteDataSource.getCurrentUserId();

      if (userId == null) {
        return const Right(null);
      }

      // Try local first
      final localUser = await localDataSource.getUserByFirebaseId(userId);

      if (localUser != null) {
        return Right(_isarToEntity(localUser));
      }

      // Fetch full user data from remote
      final model = await remoteDataSource.getCurrentUser();

      if (model == null) {
        return const Right(null);
      }

      // Save to local
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCurrentUserId() async {
    try {
      final userId = await remoteDataSource.getCurrentUserId();

      return Right(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user ID: $e'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((model) async {
      if (model == null) {
        return null;
      }

      // Save to local when auth state changes
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to send password reset email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to send email verification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update password: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      await remoteDataSource.updateEmail(
        newEmail: newEmail,
        password: password,
      );

      // Update local user email
      final userId = await remoteDataSource.getCurrentUserId();
      if (userId != null) {
        final localUser = await localDataSource.getUserByFirebaseId(userId);
        if (localUser != null) {
          localUser.email = newEmail;
          await localDataSource.upsertUser(localUser);
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update email: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final model = await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update local user
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  }) async {
    try {
      final userId = await remoteDataSource.getCurrentUserId();

      await remoteDataSource.deleteAccount(password: password);

      // Delete local user data
      if (userId != null) {
        await localDataSource.permanentlyDeleteUser(userId);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete account: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate({
    required String password,
  }) async {
    try {
      await remoteDataSource.reauthenticate(password: password);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reauthenticate: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailAvailable({
    required String email,
  }) async {
    try {
      final isAvailable = await remoteDataSource.isEmailAvailable(
        email: email,
      );

      return Right(isAvailable);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to check email availability: $e'));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert UserModel to UserIsar
  UserIsar _modelToIsar(UserModel model) {
    return UserIsar()
      ..userId = model.id
      ..email = model.email
      ..displayName = model.displayName
      ..photoUrl = model.photoUrl
      ..bio = model.bio
      ..subscriptionTier = _subscriptionTierToIsar(model.subscriptionTier)
      ..subscriptionExpiresAt = model.subscriptionExpiresAt
      ..preferences = model.preferences != null
          ? _convertPreferencesToIsar(model.preferences!)
          : null
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..lastActive = model.lastActive
      ..isActive = model.isActive
      ..isDeactivated = model.isDeactivated;
  }

  /// Helper to convert preferences to Isar
  UserPreferencesIsar _convertPreferencesToIsar(UserPreferences prefs) {
    return UserPreferencesIsar()
      ..theme = prefs.theme
      ..locale = prefs.locale
      ..defaultListId = prefs.defaultListId
      ..enableNotifications = prefs.enableNotifications
      ..enableSounds = prefs.enableSounds
      ..enableVibration = prefs.enableVibration;
  }

  /// Convert UserIsar to UserEntity
  UserEntity _isarToEntity(UserIsar isar) {
    return UserEntity(
      id: isar.userId,
      email: isar.email,
      displayName: isar.displayName,
      photoUrl: isar.photoUrl,
      bio: isar.bio,
      subscriptionTier: _subscriptionTierFromIsar(isar.subscriptionTier),
      subscriptionExpiresAt: isar.subscriptionExpiresAt,
      preferences: isar.preferences != null
          ? UserPreferences(
              theme: isar.preferences!.theme,
              locale: isar.preferences!.locale,
              defaultListId: isar.preferences!.defaultListId,
              enableNotifications: isar.preferences!.enableNotifications,
              enableSounds: isar.preferences!.enableSounds,
              enableVibration: isar.preferences!.enableVibration,
            )
          : null,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      lastActive: isar.lastActive,
      isActive: isar.isActive,
      isDeactivated: isar.isDeactivated,
    );
  }

  /// Convert subscription tier to Isar enum
  UserSubscriptionTierIsar _subscriptionTierToIsar(String tier) {
    switch (tier) {
      case 'free':
        return UserSubscriptionTierIsar.free;
      case 'plus':
        return UserSubscriptionTierIsar.plus;
      case 'premium':
        return UserSubscriptionTierIsar.premium;
      default:
        return UserSubscriptionTierIsar.free;
    }
  }

  /// Convert Isar subscription tier to string
  String _subscriptionTierFromIsar(UserSubscriptionTierIsar tier) {
    switch (tier) {
      case UserSubscriptionTierIsar.free:
        return 'free';
      case UserSubscriptionTierIsar.plus:
        return 'plus';
      case UserSubscriptionTierIsar.premium:
        return 'premium';
    }
  }
}
