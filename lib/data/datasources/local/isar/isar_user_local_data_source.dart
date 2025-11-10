import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import '../schemas/user_isar.dart';

/// Isar local data source for User operations (offline storage)
abstract class IsarUserLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update user
  Future<UserIsar> upsertUser(UserIsar user);

  /// Get user by Firebase ID
  Future<UserIsar?> getUserByFirebaseId(String userId);

  /// Get user by email
  Future<UserIsar?> getUserByEmail(String email);

  /// Get current user (assumes single user device)
  Future<UserIsar?> getCurrentUser();

  /// Update user
  Future<UserIsar> updateUser(UserIsar user);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Clear all users (for logout)
  Future<void> clearAllUsers();

  /// Get dirty users (need sync)
  Future<List<UserIsar>> getDirtyUsers();

  /// Mark user as synced
  Future<void> markAsSynced(String userId);

  /// Mark user as dirty (needs sync)
  Future<void> markAsDirty(String userId);

  /// Watch user changes (stream)
  Stream<UserIsar?> watchUser(String userId);
}

/// Isar implementation of user local data source
class IsarUserLocalDataSourceImpl implements IsarUserLocalDataSource {
  Isar? _isar;

  IsarUserLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        UserIsarSchema,
      ], directory: await _getIsarPath());
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Isar database',
        originalException: e,
      );
    }
  }

  Future<String> _getIsarPath() async {
    // In production, use path_provider to get app directory
    // For now, return current directory
    return '.';
  }

  Isar get _db {
    if (_isar == null) {
      throw const CacheException(
        message: 'Isar database not initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  @override
  Future<UserIsar> upsertUser(UserIsar user) async {
    try {
      await _db.writeTxn(() async {
        await _db.userIsars.put(user);
      });

      // Return the inserted/updated user
      final savedUser = await getUserByFirebaseId(user.userId);
      if (savedUser == null) {
        throw const CacheException(
          message: 'Failed to save user to local database',
        );
      }

      return savedUser;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert user',
        originalException: e,
      );
    }
  }

  @override
  Future<UserIsar?> getUserByFirebaseId(String userId) async {
    try {
      final user = await _db.userIsars
          .filter()
          .userIdEqualTo(userId)
          .findFirst();

      return user;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get user by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<UserIsar?> getUserByEmail(String email) async {
    try {
      final user = await _db.userIsars
          .filter()
          .emailEqualTo(email)
          .findFirst();

      return user;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get user by email',
        originalException: e,
      );
    }
  }

  @override
  Future<UserIsar?> getCurrentUser() async {
    try {
      // Get the first non-deleted user
      final user = await _db.userIsars
          .filter()
          .isDeletedEqualTo(false)
          .findFirst();

      return user;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get current user',
        originalException: e,
      );
    }
  }

  @override
  Future<UserIsar> updateUser(UserIsar user) async {
    try {
      final existingUser = await getUserByFirebaseId(user.userId);
      if (existingUser == null) {
        throw const CacheException(
          message: 'User not found in local database',
        );
      }

      // Update timestamp
      user.updatedAt = DateTime.now();
      user.isDirty = true;

      return await upsertUser(user);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update user',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final user = await getUserByFirebaseId(userId);
      if (user == null) return;

      await _db.writeTxn(() async {
        await _db.userIsars.delete(user.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete user',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearAllUsers() async {
    try {
      await _db.writeTxn(() async {
        await _db.userIsars.clear();
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all users',
        originalException: e,
      );
    }
  }

  @override
  Future<List<UserIsar>> getDirtyUsers() async {
    try {
      final users = await _db.userIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return users;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty users',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String userId) async {
    try {
      final user = await getUserByFirebaseId(userId);
      if (user == null) return;

      user.isDirty = false;
      user.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.userIsars.put(user);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark user as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String userId) async {
    try {
      final user = await getUserByFirebaseId(userId);
      if (user == null) return;

      user.isDirty = true;

      await _db.writeTxn(() async {
        await _db.userIsars.put(user);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark user as dirty',
        originalException: e,
      );
    }
  }

  @override
  Stream<UserIsar?> watchUser(String userId) {
    try {
      return _db.userIsars
          .filter()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true)
          .map((users) => users.isNotEmpty ? users.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch user',
        originalException: e,
      );
    }
  }
}
