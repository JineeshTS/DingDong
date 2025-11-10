import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/isar/isar_user_local_data_source.dart';
import '../datasources/local/isar/schemas/user_isar.dart';
import '../datasources/remote/firebase_user_remote_data_source.dart';
import '../models/user_model.dart';

/// User repository implementation with offline-first architecture
class UserRepositoryImpl implements UserRepository {
  final FirebaseUserRemoteDataSource remoteDataSource;
  final IsarUserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> getUser(String id) async {
    try {
      // Try to get from local first (offline-first)
      final localUser = await localDataSource.getUserByFirebaseId(id);

      if (localUser != null) {
        // Return local data
        return Right(_isarToEntity(localUser));
      }

      // If not in local, fetch from remote
      final remoteModel = await remoteDataSource.getUser(id);

      // Save to local for future offline access
      final isarUser = _modelToIsar(remoteModel);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByEmail(String email) async {
    try {
      // Try local first
      final localUser = await localDataSource.getUserByEmail(email);

      if (localUser != null) {
        return Right(_isarToEntity(localUser));
      }

      // Try remote
      final remoteModel = await remoteDataSource.getUserByEmail(email);

      if (remoteModel != null) {
        // Save to local
        final isarUser = _modelToIsar(remoteModel);
        await localDataSource.upsertUser(isarUser);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user by email: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);

      // Save to local first (for offline support)
      final isarUser = _modelToIsar(model);
      isarUser.isDirty = true; // Mark as needing sync
      await localDataSource.upsertUser(isarUser);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateUser(model);

        // Update local with synced data
        final syncedIsarUser = _modelToIsar(updatedModel);
        await localDataSource.upsertUser(syncedIsarUser);
        await localDataSource.markAsSynced(user.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success (will sync later)
        return Right(user);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      // Get current user
      final userResult = await getUser(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Update preferences
          final updatedUser = user.copyWith(
            preferences: preferences,
            updatedAt: DateTime.now(),
          );

          return await updateUser(updatedUser);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateSubscription({
    required String userId,
    required UserSubscriptionTier tier,
    DateTime? expiresAt,
  }) async {
    try {
      final model = await remoteDataSource.updateSubscription(
        userId: userId,
        tier: tier,
        expiresAt: expiresAt,
      );

      // Update local
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(userId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> setBiometric({
    required String userId,
    required bool enabled,
  }) async {
    try {
      // Get current user
      final userResult = await getUser(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          final updatedUser = user.copyWith(
            biometricEnabled: enabled,
            updatedAt: DateTime.now(),
          );

          return await updateUser(updatedUser);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to set biometric: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> setDefaultList({
    required String userId,
    required String listId,
  }) async {
    try {
      // Get current user
      final userResult = await getUser(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          final updatedUser = user.copyWith(
            defaultListId: listId,
            updatedAt: DateTime.now(),
          );

          return await updateUser(updatedUser);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to set default list: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateThemeMode({
    required String userId,
    required ThemeMode themeMode,
  }) async {
    try {
      // Get current user
      final userResult = await getUser(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          final updatedUser = user.copyWith(
            themeMode: themeMode,
            updatedAt: DateTime.now(),
          );

          return await updateUser(updatedUser);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update theme mode: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateLocale({
    required String userId,
    required String locale,
  }) async {
    try {
      // Get current user
      final userResult = await getUser(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          final updatedUser = user.copyWith(
            locale: locale,
            updatedAt: DateTime.now(),
          );

          return await updateUser(updatedUser);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update locale: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateAccount(String userId) async {
    try {
      await remoteDataSource.deactivateAccount(userId);

      // Update local
      final localUser = await localDataSource.getUserByFirebaseId(userId);
      if (localUser != null) {
        localUser.isActive = false;
        localUser.deactivatedAt = DateTime.now();
        localUser.updatedAt = DateTime.now();
        await localDataSource.upsertUser(localUser);
        await localDataSource.markAsSynced(userId);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to deactivate account: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> reactivateAccount(String userId) async {
    try {
      final model = await remoteDataSource.reactivateAccount(userId);

      // Update local
      final isarUser = _modelToIsar(model);
      await localDataSource.upsertUser(isarUser);
      await localDataSource.markAsSynced(userId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reactivate account: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(
      String userId) async {
    try {
      final data = await remoteDataSource.exportUserData(userId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to export user data: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserEntity>> watchUser(String id) {
    try {
      return localDataSource.watchUser(id).map((userIsar) {
        if (userIsar == null) {
          return Left(CacheFailure(message: 'User not found in local database'));
        }
        return Right(_isarToEntity(userIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch user: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch user: $e')));
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
      ..phoneNumber = model.phoneNumber
      ..subscriptionTier = _subscriptionTierToIsar(model.subscriptionTier)
      ..subscriptionExpiresAt = model.subscriptionExpiresAt
      ..isSubscriptionActive = model.subscriptionExpiresAt == null ||
          model.subscriptionExpiresAt!.isAfter(DateTime.now())
      ..themeMode = _themeModeToIsar(model.themeMode)
      ..locale = model.locale
      ..biometricEnabled = model.biometricEnabled
      ..defaultListId = model.defaultListId
      ..preferencesJson =
          model.preferences != null ? jsonEncode(model.preferences) : null
      ..isActive = model.isActive
      ..emailVerified = model.emailVerified
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert UserIsar to UserEntity
  UserEntity _isarToEntity(UserIsar isar) {
    return UserEntity(
      id: isar.userId,
      email: isar.email,
      displayName: isar.displayName,
      photoUrl: isar.photoUrl,
      phoneNumber: isar.phoneNumber,
      emailVerified: isar.emailVerified,
      subscriptionTier: _subscriptionTierFromIsar(isar.subscriptionTier),
      subscriptionExpiresAt: isar.subscriptionExpiresAt,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      preferences: isar.preferencesJson != null
          ? jsonDecode(isar.preferencesJson!) as Map<String, dynamic>
          : null,
      isActive: isar.isActive,
      biometricEnabled: isar.biometricEnabled,
      defaultListId: isar.defaultListId,
      themeMode: _themeModeFromIsar(isar.themeMode),
      locale: isar.locale,
    );
  }

  /// Convert subscription tier string to Isar enum
  UserSubscriptionTierIsar _subscriptionTierToIsar(String tier) {
    switch (tier) {
      case 'free':
        return UserSubscriptionTierIsar.free;
      case 'premium_individual':
      case 'premium_family':
      case 'lifetime':
        return UserSubscriptionTierIsar.premium;
      case 'teams':
      case 'enterprise':
        return UserSubscriptionTierIsar.business;
      default:
        return UserSubscriptionTierIsar.free;
    }
  }

  /// Convert Isar subscription tier to domain enum
  UserSubscriptionTier _subscriptionTierFromIsar(UserSubscriptionTierIsar tier) {
    switch (tier) {
      case UserSubscriptionTierIsar.free:
        return UserSubscriptionTier.free;
      case UserSubscriptionTierIsar.premium:
        return UserSubscriptionTier.premiumIndividual;
      case UserSubscriptionTierIsar.business:
        return UserSubscriptionTier.teams;
    }
  }

  /// Convert theme mode string to Isar enum
  ThemeModeIsar _themeModeToIsar(String mode) {
    switch (mode) {
      case 'light':
        return ThemeModeIsar.light;
      case 'dark':
        return ThemeModeIsar.dark;
      case 'system':
        return ThemeModeIsar.system;
      default:
        return ThemeModeIsar.system;
    }
  }

  /// Convert Isar theme mode to domain enum
  ThemeMode _themeModeFromIsar(ThemeModeIsar mode) {
    switch (mode) {
      case ThemeModeIsar.light:
        return ThemeMode.light;
      case ThemeModeIsar.dark:
        return ThemeMode.dark;
      case ThemeModeIsar.system:
        return ThemeMode.system;
    }
  }
}
