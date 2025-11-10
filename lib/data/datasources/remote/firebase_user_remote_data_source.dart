import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';

/// Firebase remote data source for user operations
abstract class FirebaseUserRemoteDataSource {
  /// Get user by ID
  Future<UserModel> getUser(String id);

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email);

  /// Update user
  Future<UserModel> updateUser(UserModel user);

  /// Update user preferences
  Future<UserModel> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  });

  /// Update subscription
  Future<UserModel> updateSubscription({
    required String userId,
    required String tier,
    DateTime? expiresAt,
  });

  /// Enable/disable biometric authentication
  Future<UserModel> setBiometric({
    required String userId,
    required bool enabled,
  });

  /// Set default list
  Future<UserModel> setDefaultList({
    required String userId,
    required String listId,
  });

  /// Update theme mode
  Future<UserModel> updateThemeMode({
    required String userId,
    required String themeMode,
  });

  /// Update locale
  Future<UserModel> updateLocale({
    required String userId,
    required String locale,
  });

  /// Deactivate account
  Future<void> deactivateAccount(String userId);

  /// Reactivate account
  Future<UserModel> reactivateAccount(String userId);

  /// Export user data
  Future<Map<String, dynamic>> exportUserData(String userId);

  /// Watch user (stream)
  Stream<UserModel> watchUser(String id);
}

/// Firebase implementation of user remote data source
class FirebaseUserRemoteDataSourceImpl implements FirebaseUserRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseUserRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> getUser(String id) async {
    try {
      final snapshot = await _firestore.collection('users').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'User not found',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get user',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get user',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return UserModel.fromJson(snapshot.docs.first.data());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get user by email',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user by email',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.id);
      final userData = user.toJson();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      await userRef.update(userData);

      // Get the updated user with server timestamps
      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update user',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update user',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update user',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update preferences',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update preferences',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update preferences',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updateSubscription({
    required String userId,
    required String tier,
    DateTime? expiresAt,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      final updateData = <String, dynamic>{
        'subscriptionTier': tier,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (expiresAt != null) {
        updateData['subscriptionExpiresAt'] = Timestamp.fromDate(expiresAt);
      }

      await userRef.update(updateData);

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update subscription',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update subscription',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update subscription',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> setBiometric({
    required String userId,
    required bool enabled,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'biometricEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update biometric setting',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update biometric setting',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update biometric setting',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> setDefaultList({
    required String userId,
    required String listId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'defaultListId': listId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to set default list',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to set default list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to set default list',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'themeMode': themeMode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update theme mode',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update theme mode',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update theme mode',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> updateLocale({
    required String userId,
    required String locale,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'locale': locale,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update locale',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update locale',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update locale',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deactivateAccount(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to deactivate account',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to deactivate account',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> reactivateAccount(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'isActive': true,
        'deactivatedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to reactivate account',
        );
      }

      return UserModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to reactivate account',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to reactivate account',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      // Get user data
      final user = await getUser(userId);

      // Get all user's tasks
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      final tasks = tasksSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's lists
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .get();

      final lists = listsSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's tags
      final tagsSnapshot = await _firestore
          .collection('tags')
          .where('userId', isEqualTo: userId)
          .get();

      final tags = tagsSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's reminders
      final remindersSnapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .get();

      final reminders = remindersSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's habits
      final habitsSnapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final habits = habitsSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's focus sessions
      final focusSessionsSnapshot = await _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: userId)
          .get();

      final focusSessions =
          focusSessionsSnapshot.docs.map((doc) => doc.data()).toList();

      // Get all user's comments
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .get();

      final comments = commentsSnapshot.docs.map((doc) => doc.data()).toList();

      // Compile all data
      return {
        'user': user.toJson(),
        'tasks': tasks,
        'lists': lists,
        'tags': tags,
        'reminders': reminders,
        'habits': habits,
        'focusSessions': focusSessions,
        'comments': comments,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to export user data',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to export user data',
        originalException: e,
      );
    }
  }

  @override
  Stream<UserModel> watchUser(String id) {
    try {
      return _firestore
          .collection('users')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'User not found',
          );
        }
        return UserModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch user',
        originalException: e,
      );
    }
  }
}
