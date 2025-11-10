import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/list_entity.dart';
import '../../models/list_model.dart';

/// Firebase remote data source for list operations
abstract class FirebaseListRemoteDataSource {
  /// Create a new list
  Future<ListModel> createList(ListModel list);

  /// Get list by ID
  Future<ListModel> getList(String id);

  /// Get all lists for user
  Future<List<ListModel>> getLists({
    required String userId,
    String? workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get shared lists
  Future<List<ListModel>> getSharedLists(String userId);

  /// Get favorite lists
  Future<List<ListModel>> getFavoriteLists(String userId);

  /// Get nested lists (children of parent)
  Future<List<ListModel>> getNestedLists(String parentListId);

  /// Update list
  Future<ListModel> updateList(ListModel list);

  /// Delete list (soft delete)
  Future<void> deleteList(String id);

  /// Permanently delete list
  Future<void> permanentlyDeleteList(String id);

  /// Restore list
  Future<ListModel> restoreList(String id);

  /// Archive list
  Future<ListModel> archiveList(String id);

  /// Unarchive list
  Future<ListModel> unarchiveList(String id);

  /// Toggle favorite
  Future<ListModel> toggleFavorite(String id);

  /// Share list
  Future<ListModel> shareList({
    required String listId,
    required List<String> userIds,
    required String permission,
  });

  /// Unshare list
  Future<ListModel> unshareList({
    required String listId,
    required String userId,
  });

  /// Update collaborator permission
  Future<ListModel> updateCollaboratorPermission({
    required String listId,
    required String userId,
    required String permission,
  });

  /// Generate share link
  Future<String> generateShareLink({
    required String listId,
    DateTime? expiresAt,
  });

  /// Revoke share link
  Future<void> revokeShareLink(String listId);

  /// Accept list invitation
  Future<ListModel> acceptListInvitation(String listId);

  /// Decline list invitation
  Future<void> declineListInvitation(String listId);

  /// Watch list (stream)
  Stream<ListModel> watchList(String id);

  /// Watch lists (stream)
  Stream<List<ListModel>> watchLists({
    required String userId,
    String? workspaceId,
  });

  /// Get list statistics
  Future<Map<String, dynamic>> getListStatistics(String listId);
}

/// Firebase implementation of list remote data source
class FirebaseListRemoteDataSourceImpl implements FirebaseListRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirebaseListRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Future<ListModel> createList(ListModel list) async {
    try {
      final listRef = _firestore.collection('lists').doc(list.id);
      final listData = list.toJson();
      listData['createdAt'] = FieldValue.serverTimestamp();
      listData['updatedAt'] = FieldValue.serverTimestamp();

      await listRef.set(listData);

      // Get the created list with server timestamps
      final snapshot = await listRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create list',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> getList(String id) async {
    try {
      final snapshot = await _firestore.collection('lists').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get list',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListModel>> getLists({
    required String userId,
    String? workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('lists');

      // User must be owner or collaborator
      query = query.where('userId', isEqualTo: userId);

      if (workspaceId != null) {
        query = query.where('workspaceId', isEqualTo: workspaceId);
      }

      if (!includeArchived) {
        query = query.where('isArchived', isEqualTo: false);
      }

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('sortOrder');

      final snapshot = await query.get();

      // Also get lists where user is a collaborator
      final collaboratorQuery = _firestore
          .collection('lists')
          .where('collaborators', arrayContains: {
        'userId': userId,
      });

      final collaboratorSnapshot = await collaboratorQuery.get();

      // Combine both results
      final allLists = <ListModel>[];
      final seenIds = <String>{};

      for (final doc in snapshot.docs) {
        final list = ListModel.fromJson(doc.data());
        if (!seenIds.contains(list.id)) {
          allLists.add(list);
          seenIds.add(list.id);
        }
      }

      for (final doc in collaboratorSnapshot.docs) {
        final list = ListModel.fromJson(doc.data());
        if (!seenIds.contains(list.id)) {
          if (includeDeleted || !list.isDeleted) {
            if (includeArchived || !list.isArchived) {
              allLists.add(list);
              seenIds.add(list.id);
            }
          }
        }
      }

      // Sort by sortOrder
      allLists.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return allLists;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get lists',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListModel>> getSharedLists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('lists')
          .where('collaborators', arrayContains: {
        'userId': userId,
      }).where('isDeleted', isEqualTo: false).get();

      return snapshot.docs
          .map((doc) => ListModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get shared lists',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get shared lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListModel>> getFavoriteLists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs
          .map((doc) => ListModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get favorite lists',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get favorite lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListModel>> getNestedLists(String parentListId) async {
    try {
      final snapshot = await _firestore
          .collection('lists')
          .where('parentListId', isEqualTo: parentListId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs
          .map((doc) => ListModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get nested lists',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get nested lists',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> updateList(ListModel list) async {
    try {
      final listRef = _firestore.collection('lists').doc(list.id);
      final listData = list.toJson();
      listData['updatedAt'] = FieldValue.serverTimestamp();

      await listRef.update(listData);

      // Get the updated list with server timestamps
      final snapshot = await listRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update list',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _firestore.collection('lists').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteList(String id) async {
    try {
      await _firestore.collection('lists').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> restoreList(String id) async {
    try {
      final listRef = _firestore.collection('lists').doc(id);

      await listRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await listRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore list',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> archiveList(String id) async {
    try {
      final listRef = _firestore.collection('lists').doc(id);

      await listRef.update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await listRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to archive list',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to archive list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to archive list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> unarchiveList(String id) async {
    try {
      final listRef = _firestore.collection('lists').doc(id);

      await listRef.update({
        'isArchived': false,
        'archivedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await listRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to unarchive list',
        );
      }

      return ListModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to unarchive list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to unarchive list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> toggleFavorite(String id) async {
    try {
      final listRef = _firestore.collection('lists').doc(id);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);
      final newFavoriteStatus = !list.isFavorite;

      await listRef.update({
        'isFavorite': newFavoriteStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await listRef.get();
      return ListModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to toggle favorite',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to toggle favorite',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> shareList({
    required String listId,
    required List<String> userIds,
    required String permission,
  }) async {
    try {
      final listRef = _firestore.collection('lists').doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);
      final collaborators = List<Map<String, dynamic>>.from(
        list.collaborators.map((c) => {
              'userId': c.userId,
              'permission': c.permission,
              'addedAt': c.addedAt?.toIso8601String(),
              'addedBy': c.addedBy,
            }),
      );

      // Add new collaborators
      for (final userId in userIds) {
        if (!collaborators.any((c) => c['userId'] == userId)) {
          collaborators.add({
            'userId': userId,
            'permission': permission,
            'addedAt': DateTime.now().toIso8601String(),
            'addedBy': list.userId,
          });
        }
      }

      await listRef.update({
        'collaborators': collaborators,
        'shareSettings': {
          ...list.shareSettings?.toJson() ?? {},
          'isShared': true,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await listRef.get();
      return ListModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to share list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to share list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> unshareList({
    required String listId,
    required String userId,
  }) async {
    try {
      final listRef = _firestore.collection('lists').doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);
      final collaborators = List<Map<String, dynamic>>.from(
        list.collaborators
            .where((c) => c.userId != userId)
            .map((c) => {
                  'userId': c.userId,
                  'permission': c.permission,
                  'addedAt': c.addedAt?.toIso8601String(),
                  'addedBy': c.addedBy,
                }),
      );

      await listRef.update({
        'collaborators': collaborators,
        'shareSettings': {
          ...list.shareSettings?.toJson() ?? {},
          'isShared': collaborators.isNotEmpty,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await listRef.get();
      return ListModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to unshare list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to unshare list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> updateCollaboratorPermission({
    required String listId,
    required String userId,
    required String permission,
  }) async {
    try {
      final listRef = _firestore.collection('lists').doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);
      final collaborators = List<Map<String, dynamic>>.from(
        list.collaborators.map((c) => {
              'userId': c.userId,
              'permission': c.userId == userId ? permission : c.permission,
              'addedAt': c.addedAt?.toIso8601String(),
              'addedBy': c.addedBy,
            }),
      );

      await listRef.update({
        'collaborators': collaborators,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await listRef.get();
      return ListModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update collaborator permission',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to update collaborator permission',
        originalException: e,
      );
    }
  }

  @override
  Future<String> generateShareLink({
    required String listId,
    DateTime? expiresAt,
  }) async {
    try {
      final listRef = _firestore.collection('lists').doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);
      final shareToken = _uuid.v4();
      final shareLink = 'https://dingdong.app/share/list/$shareToken';

      await listRef.update({
        'shareSettings': {
          ...list.shareSettings?.toJson() ?? {},
          'isShared': true,
          'shareLink': shareLink,
          'shareLinkToken': shareToken,
          'shareLinkExpiresAt': expiresAt?.toIso8601String(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return shareLink;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to generate share link',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to generate share link',
        originalException: e,
      );
    }
  }

  @override
  Future<void> revokeShareLink(String listId) async {
    try {
      final listRef = _firestore.collection('lists').doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'List not found',
        );
      }

      final list = ListModel.fromJson(snapshot.data()!);

      await listRef.update({
        'shareSettings': {
          ...list.shareSettings?.toJson() ?? {},
          'shareLink': null,
          'shareLinkToken': null,
          'shareLinkExpiresAt': null,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to revoke share link',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to revoke share link',
        originalException: e,
      );
    }
  }

  @override
  Future<ListModel> acceptListInvitation(String listId) async {
    try {
      // In a real implementation, you would:
      // 1. Get the invitation from a separate 'invitations' collection
      // 2. Add the user as a collaborator
      // 3. Delete the invitation
      // For now, just return the list
      return await getList(listId);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to accept list invitation',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to accept list invitation',
        originalException: e,
      );
    }
  }

  @override
  Future<void> declineListInvitation(String listId) async {
    try {
      // In a real implementation, you would:
      // 1. Get the invitation from a separate 'invitations' collection
      // 2. Delete the invitation
      // For now, this is a no-op
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to decline list invitation',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to decline list invitation',
        originalException: e,
      );
    }
  }

  @override
  Stream<ListModel> watchList(String id) {
    try {
      return _firestore
          .collection('lists')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'List not found',
          );
        }
        return ListModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch list',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ListModel>> watchLists({
    required String userId,
    String? workspaceId,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('lists')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (workspaceId != null) {
        query = query.where('workspaceId', isEqualTo: workspaceId);
      }

      query = query.orderBy('sortOrder');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => ListModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch lists',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getListStatistics(String listId) async {
    try {
      // Get list
      final list = await getList(listId);

      // Get tasks for this list
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('listId', isEqualTo: listId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final tasks = tasksSnapshot.docs;
      final totalTasks = tasks.length;
      final completedTasks =
          tasks.where((t) => t.data()['status'] == 'completed').length;
      final activeTasks =
          tasks.where((t) => t.data()['status'] == 'active').length;
      final overdueTasks = tasks.where((t) {
        if (t.data()['status'] == 'completed') return false;
        final dueDate = t.data()['dueDate'];
        if (dueDate == null) return false;
        return (dueDate as Timestamp).toDate().isBefore(DateTime.now());
      }).length;

      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

      return {
        'listId': listId,
        'listName': list.name,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'activeTasks': activeTasks,
        'overdueTasks': overdueTasks,
        'completionRate': completionRate,
        'collaboratorCount': list.collaborators.length,
        'isShared': list.shareSettings?.isShared ?? false,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get list statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get list statistics',
        originalException: e,
      );
    }
  }
}
