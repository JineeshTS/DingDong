import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../models/tag_model.dart';

/// Firebase remote data source for tag operations
abstract class FirebaseTagRemoteDataSource {
  /// Create a new tag
  Future<TagModel> createTag(TagModel tag);

  /// Get tag by ID
  Future<TagModel> getTag(String id);

  /// Get all tags for user
  Future<List<TagModel>> getTags({
    required String userId,
    String? workspaceId,
    bool includeDeleted = false,
  });

  /// Get tags by parent (nested tags)
  Future<List<TagModel>> getTagsByParent(String parentTagId);

  /// Get most used tags
  Future<List<TagModel>> getMostUsedTags({
    required String userId,
    int limit = 10,
  });

  /// Search tags
  Future<List<TagModel>> searchTags({
    required String userId,
    required String query,
  });

  /// Update tag
  Future<TagModel> updateTag(TagModel tag);

  /// Delete tag (soft delete)
  Future<void> deleteTag(String id);

  /// Permanently delete tag
  Future<void> permanentlyDeleteTag(String id);

  /// Restore tag
  Future<TagModel> restoreTag(String id);

  /// Merge tags (combine multiple tags into one)
  Future<TagModel> mergeTags({
    required List<String> sourceTagIds,
    required String targetTagId,
  });

  /// Update usage count
  Future<TagModel> incrementUsageCount(String tagId);

  /// Get tag statistics
  Future<Map<String, dynamic>> getTagStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Watch tag (stream)
  Stream<TagModel> watchTag(String id);

  /// Watch tags (stream)
  Stream<List<TagModel>> watchTags({
    required String userId,
    String? workspaceId,
  });
}

/// Firebase implementation of tag remote data source
class FirebaseTagRemoteDataSourceImpl implements FirebaseTagRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseTagRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final tagRef = _firestore.collection('tags').doc(tag.id);
      final tagData = tag.toJson();
      tagData['createdAt'] = FieldValue.serverTimestamp();
      tagData['updatedAt'] = FieldValue.serverTimestamp();

      await tagRef.set(tagData);

      // Get the created tag with server timestamps
      final snapshot = await tagRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create tag',
        );
      }

      return TagModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create tag',
        originalException: e,
      );
    }
  }

  @override
  Future<TagModel> getTag(String id) async {
    try {
      final snapshot = await _firestore.collection('tags').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Tag not found',
        );
      }

      return TagModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get tag',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagModel>> getTags({
    required String userId,
    String? workspaceId,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('tags')
          .where('userId', isEqualTo: userId);

      if (workspaceId != null) {
        query = query.where('workspaceId', isEqualTo: workspaceId);
      }

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('name');

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => TagModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tags',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagModel>> getTagsByParent(String parentTagId) async {
    try {
      final snapshot = await _firestore
          .collection('tags')
          .where('parentTagId', isEqualTo: parentTagId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => TagModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tags by parent',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tags by parent',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagModel>> getMostUsedTags({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('tags')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('usageCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TagModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get most used tags',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get most used tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagModel>> searchTags({
    required String userId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('tags')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      // Client-side filtering for tag name search
      final lowerQuery = query.toLowerCase();
      final tags = snapshot.docs
          .map((doc) => TagModel.fromJson(doc.data()))
          .where((tag) => tag.name.toLowerCase().contains(lowerQuery))
          .toList();

      return tags;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search tags',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to search tags',
        originalException: e,
      );
    }
  }

  @override
  Future<TagModel> updateTag(TagModel tag) async {
    try {
      final tagRef = _firestore.collection('tags').doc(tag.id);
      final tagData = tag.toJson();
      tagData['updatedAt'] = FieldValue.serverTimestamp();

      await tagRef.update(tagData);

      // Get the updated tag with server timestamps
      final snapshot = await tagRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update tag',
        );
      }

      return TagModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update tag',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    try {
      await _firestore.collection('tags').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete tag',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteTag(String id) async {
    try {
      await _firestore.collection('tags').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete tag',
        originalException: e,
      );
    }
  }

  @override
  Future<TagModel> restoreTag(String id) async {
    try {
      final tagRef = _firestore.collection('tags').doc(id);

      await tagRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await tagRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore tag',
        );
      }

      return TagModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore tag',
        originalException: e,
      );
    }
  }

  @override
  Future<TagModel> mergeTags({
    required List<String> sourceTagIds,
    required String targetTagId,
  }) async {
    try {
      // Get target tag
      final targetTag = await getTag(targetTagId);

      final batch = _firestore.batch();

      // Update all tasks that use source tags to use target tag instead
      for (final sourceTagId in sourceTagIds) {
        if (sourceTagId == targetTagId) continue;

        // Get tasks with this source tag
        final tasksSnapshot = await _firestore
            .collection('tasks')
            .where('tags', arrayContains: sourceTagId)
            .get();

        for (final taskDoc in tasksSnapshot.docs) {
          final taskRef = taskDoc.reference;
          final tags = List<String>.from(taskDoc.data()['tags'] ?? []);

          // Remove source tag and add target tag if not already present
          tags.remove(sourceTagId);
          if (!tags.contains(targetTagId)) {
            tags.add(targetTagId);
          }

          batch.update(taskRef, {
            'tags': tags,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Delete source tag
        final sourceTagRef = _firestore.collection('tags').doc(sourceTagId);
        batch.delete(sourceTagRef);
      }

      // Update target tag usage count
      final targetTagRef = _firestore.collection('tags').doc(targetTagId);
      batch.update(targetTagRef, {
        'usageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Get updated target tag
      return await getTag(targetTagId);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to merge tags',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to merge tags',
        originalException: e,
      );
    }
  }

  @override
  Future<TagModel> incrementUsageCount(String tagId) async {
    try {
      final tagRef = _firestore.collection('tags').doc(tagId);

      await tagRef.update({
        'usageCount': FieldValue.increment(1),
        'lastUsedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await tagRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to increment usage count',
        );
      }

      return TagModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to increment usage count',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to increment usage count',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTagStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get all tags for user
      final tags = await getTags(userId: userId);

      // Get tasks with tag filtering by date
      Query<Map<String, dynamic>> tasksQuery = _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (startDate != null) {
        tasksQuery = tasksQuery.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        tasksQuery = tasksQuery.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final tasksSnapshot = await tasksQuery.get();

      // Calculate tag usage
      final tagUsage = <String, int>{};
      final tagNames = <String, String>{};

      for (final tag in tags) {
        tagUsage[tag.id] = 0;
        tagNames[tag.id] = tag.name;
      }

      for (final taskDoc in tasksSnapshot.docs) {
        final taskTags = List<String>.from(taskDoc.data()['tags'] ?? []);
        for (final tagId in taskTags) {
          if (tagUsage.containsKey(tagId)) {
            tagUsage[tagId] = (tagUsage[tagId] ?? 0) + 1;
          }
        }
      }

      // Find most and least used tags
      final sortedTags = tagUsage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final mostUsedTag = sortedTags.isNotEmpty
          ? {
              'id': sortedTags.first.key,
              'name': tagNames[sortedTags.first.key],
              'count': sortedTags.first.value,
            }
          : null;

      final leastUsedTag = sortedTags.isNotEmpty
          ? {
              'id': sortedTags.last.key,
              'name': tagNames[sortedTags.last.key],
              'count': sortedTags.last.value,
            }
          : null;

      final unusedTags = tags.where((tag) => tagUsage[tag.id] == 0).length;

      return {
        'totalTags': tags.length,
        'usedTags': tags.where((tag) => (tagUsage[tag.id] ?? 0) > 0).length,
        'unusedTags': unusedTags,
        'mostUsedTag': mostUsedTag,
        'leastUsedTag': leastUsedTag,
        'tagUsage': tagUsage.entries
            .map((e) => {
                  'id': e.key,
                  'name': tagNames[e.key],
                  'count': e.value,
                })
            .toList(),
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tag statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tag statistics',
        originalException: e,
      );
    }
  }

  @override
  Stream<TagModel> watchTag(String id) {
    try {
      return _firestore
          .collection('tags')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Tag not found',
          );
        }
        return TagModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch tag',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TagModel>> watchTags({
    required String userId,
    String? workspaceId,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('tags')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (workspaceId != null) {
        query = query.where('workspaceId', isEqualTo: workspaceId);
      }

      query = query.orderBy('name');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => TagModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch tags',
        originalException: e,
      );
    }
  }
}
