import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../models/comment_model.dart';

/// Firebase remote data source for comment operations
abstract class FirebaseCommentRemoteDataSource {
  /// Create a new comment
  Future<CommentModel> createComment(CommentModel comment);

  /// Get comment by ID
  Future<CommentModel> getComment(String id);

  /// Get all comments for task
  Future<List<CommentModel>> getCommentsForTask({
    required String taskId,
    bool includeDeleted = false,
  });

  /// Get replies to a comment
  Future<List<CommentModel>> getReplies(String commentId);

  /// Get comments by user
  Future<List<CommentModel>> getCommentsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get comments mentioning user
  Future<List<CommentModel>> getCommentsMentioningUser(String userId);

  /// Update comment
  Future<CommentModel> updateComment(CommentModel comment);

  /// Delete comment (soft delete)
  Future<void> deleteComment(String id);

  /// Permanently delete comment
  Future<void> permanentlyDeleteComment(String id);

  /// Restore comment
  Future<CommentModel> restoreComment(String id);

  /// Add reaction to comment
  Future<CommentModel> addReaction({
    required String commentId,
    required String userId,
    required String emoji,
  });

  /// Remove reaction from comment
  Future<CommentModel> removeReaction({
    required String commentId,
    required String userId,
    required String emoji,
  });

  /// Search comments
  Future<List<CommentModel>> searchComments({
    required String taskId,
    required String query,
  });

  /// Batch delete comments
  Future<void> batchDeleteComments(List<String> commentIds);

  /// Delete all comments for task
  Future<void> deleteCommentsForTask(String taskId);

  /// Get comment count for task
  Future<int> getCommentCount(String taskId);

  /// Watch comment (stream)
  Stream<CommentModel> watchComment(String id);

  /// Watch comments for task (stream)
  Stream<List<CommentModel>> watchCommentsForTask(String taskId);

  /// Get comment statistics
  Future<Map<String, dynamic>> getCommentStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Firebase implementation of comment remote data source
class FirebaseCommentRemoteDataSourceImpl
    implements FirebaseCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseCommentRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CommentModel> createComment(CommentModel comment) async {
    try {
      final commentRef = _firestore.collection('comments').doc(comment.id);
      final commentData = comment.toJson();
      commentData['createdAt'] = FieldValue.serverTimestamp();
      commentData['updatedAt'] = FieldValue.serverTimestamp();

      await commentRef.set(commentData);

      // Get the created comment with server timestamps
      final snapshot = await commentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create comment',
        );
      }

      return CommentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create comment',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentModel> getComment(String id) async {
    try {
      final snapshot = await _firestore.collection('comments').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Comment not found',
        );
      }

      return CommentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get comment',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentModel>> getCommentsForTask({
    required String taskId,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('comments')
          .where('taskId', isEqualTo: taskId);

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comments for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentModel>> getReplies(String commentId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('parentCommentId', isEqualTo: commentId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get replies',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get replies',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comments by user',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comments by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentModel>> getCommentsMentioningUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('mentions', arrayContains: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comments mentioning user',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comments mentioning user',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentModel> updateComment(CommentModel comment) async {
    try {
      final commentRef = _firestore.collection('comments').doc(comment.id);
      final commentData = comment.toJson();
      commentData['updatedAt'] = FieldValue.serverTimestamp();
      commentData['isEdited'] = true;

      await commentRef.update(commentData);

      // Get the updated comment with server timestamps
      final snapshot = await commentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update comment',
        );
      }

      return CommentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update comment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await _firestore.collection('comments').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete comment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteComment(String id) async {
    try {
      await _firestore.collection('comments').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete comment',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentModel> restoreComment(String id) async {
    try {
      final commentRef = _firestore.collection('comments').doc(id);

      await commentRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await commentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore comment',
        );
      }

      return CommentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore comment',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentModel> addReaction({
    required String commentId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final commentRef = _firestore.collection('comments').doc(commentId);
      final snapshot = await commentRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Comment not found',
        );
      }

      final comment = CommentModel.fromJson(snapshot.data()!);
      final reactions = Map<String, List<String>>.from(comment.reactions);

      // Add user to emoji reactions
      if (reactions.containsKey(emoji)) {
        if (!reactions[emoji]!.contains(userId)) {
          reactions[emoji]!.add(userId);
        }
      } else {
        reactions[emoji] = [userId];
      }

      await commentRef.update({
        'reactions': reactions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await commentRef.get();
      return CommentModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to add reaction',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to add reaction',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentModel> removeReaction({
    required String commentId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final commentRef = _firestore.collection('comments').doc(commentId);
      final snapshot = await commentRef.get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Comment not found',
        );
      }

      final comment = CommentModel.fromJson(snapshot.data()!);
      final reactions = Map<String, List<String>>.from(comment.reactions);

      // Remove user from emoji reactions
      if (reactions.containsKey(emoji)) {
        reactions[emoji]!.remove(userId);
        if (reactions[emoji]!.isEmpty) {
          reactions.remove(emoji);
        }
      }

      await commentRef.update({
        'reactions': reactions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedSnapshot = await commentRef.get();
      return CommentModel.fromJson(updatedSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to remove reaction',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to remove reaction',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentModel>> searchComments({
    required String taskId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .get();

      // Client-side filtering for content search
      final lowerQuery = query.toLowerCase();
      final comments = snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .where((comment) => comment.content.toLowerCase().contains(lowerQuery))
          .toList();

      return comments;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search comments',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to search comments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchDeleteComments(List<String> commentIds) async {
    try {
      final batch = _firestore.batch();

      for (final commentId in commentIds) {
        final commentRef = _firestore.collection('comments').doc(commentId);
        batch.update(commentRef, {
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch delete comments',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch delete comments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteCommentsForTask(String taskId) async {
    try {
      final comments = await getCommentsForTask(taskId: taskId);
      final commentIds = comments.map((c) => c.id).toList();

      if (commentIds.isNotEmpty) {
        await batchDeleteComments(commentIds);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete comments for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete comments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getCommentCount(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comment count',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comment count',
        originalException: e,
      );
    }
  }

  @override
  Stream<CommentModel> watchComment(String id) {
    try {
      return _firestore
          .collection('comments')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Comment not found',
          );
        }
        return CommentModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch comment',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<CommentModel>> watchCommentsForTask(String taskId) {
    try {
      return _firestore
          .collection('comments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch comments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCommentStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final comments = await getCommentsByUser(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalComments = comments.length;
      final totalReplies =
          comments.where((c) => c.parentCommentId != null).length;
      final totalTopLevel =
          comments.where((c) => c.parentCommentId == null).length;
      final totalWithAttachments =
          comments.where((c) => c.attachmentIds.isNotEmpty).length;
      final totalEdited = comments.where((c) => c.isEdited).length;

      // Calculate total reactions
      var totalReactions = 0;
      for (final comment in comments) {
        for (final userIds in comment.reactions.values) {
          totalReactions += userIds.length;
        }
      }

      // Calculate average reactions per comment
      final avgReactions = totalComments > 0 ? totalReactions / totalComments : 0.0;

      // Calculate most used emoji
      final emojiCounts = <String, int>{};
      for (final comment in comments) {
        for (final entry in comment.reactions.entries) {
          emojiCounts[entry.key] = (emojiCounts[entry.key] ?? 0) + entry.value.length;
        }
      }

      final mostUsedEmoji = emojiCounts.isNotEmpty
          ? emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;

      return {
        'totalComments': totalComments,
        'totalReplies': totalReplies,
        'totalTopLevel': totalTopLevel,
        'totalWithAttachments': totalWithAttachments,
        'totalEdited': totalEdited,
        'totalReactions': totalReactions,
        'averageReactions': avgReactions,
        'mostUsedEmoji': mostUsedEmoji,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get comment statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comment statistics',
        originalException: e,
      );
    }
  }
}
