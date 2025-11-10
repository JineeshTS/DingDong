import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/comment_isar.dart';

/// Isar local data source for Comment operations (offline storage)
abstract class IsarCommentLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update comment
  Future<CommentIsar> upsertComment(CommentIsar comment);

  /// Get comment by Firebase ID
  Future<CommentIsar?> getCommentByFirebaseId(String commentId);

  /// Get comments by task ID
  Future<List<CommentIsar>> getCommentsByTask({
    required String taskId,
    bool includeDeleted = false,
  });

  /// Get comments by user ID
  Future<List<CommentIsar>> getCommentsByUser({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get replies to a comment (threaded comments)
  Future<List<CommentIsar>> getReplies({
    required String parentCommentId,
    bool includeDeleted = false,
  });

  /// Get root comments for a task (no parent)
  Future<List<CommentIsar>> getRootComments({
    required String taskId,
    bool includeDeleted = false,
  });

  /// Get recent comments for a user
  Future<List<CommentIsar>> getRecentComments({
    required String userId,
    int limit = 20,
  });

  /// Get comments with mentions of a user
  Future<List<CommentIsar>> getCommentsWithMentions({
    required String userId,
    bool includeDeleted = false,
  });

  /// Update comment
  Future<CommentIsar> updateComment(CommentIsar comment);

  /// Delete comment (soft delete)
  Future<void> deleteComment(String commentId);

  /// Permanently delete comment
  Future<void> permanentlyDeleteComment(String commentId);

  /// Batch insert comments
  Future<void> batchInsertComments(List<CommentIsar> comments);

  /// Delete all comments for task
  Future<void> deleteCommentsForTask(String taskId);

  /// Get dirty comments (need sync)
  Future<List<CommentIsar>> getDirtyComments();

  /// Mark comment as synced
  Future<void> markAsSynced(String commentId);

  /// Mark comment as dirty (needs sync)
  Future<void> markAsDirty(String commentId);

  /// Clear comments for user
  Future<void> clearCommentsForUser(String userId);

  /// Get comment count for task
  Future<int> getCommentCountForTask(String taskId);

  /// Get comment count for user
  Future<int> getCommentCountForUser(String userId);

  /// Get reply count for comment
  Future<int> getReplyCount(String commentId);

  /// Watch comment changes (stream)
  Stream<CommentIsar?> watchComment(String commentId);

  /// Watch comments for task (stream)
  Stream<List<CommentIsar>> watchCommentsForTask({
    required String taskId,
  });

  /// Watch replies for comment (stream)
  Stream<List<CommentIsar>> watchReplies({
    required String parentCommentId,
  });
}

/// Isar implementation of comment local data source
class IsarCommentLocalDataSourceImpl implements IsarCommentLocalDataSource {
  Isar? _isar;

  IsarCommentLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        CommentIsarSchema,
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
  Future<CommentIsar> upsertComment(CommentIsar comment) async {
    try {
      await _db.writeTxn(() async {
        await _db.commentIsars.put(comment);
      });

      // Return the inserted/updated comment
      final savedComment = await getCommentByFirebaseId(comment.commentId);
      if (savedComment == null) {
        throw const CacheException(
          message: 'Failed to save comment to local database',
        );
      }

      return savedComment;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert comment',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentIsar?> getCommentByFirebaseId(String commentId) async {
    try {
      final comment = await _db.commentIsars
          .filter()
          .commentIdEqualTo(commentId)
          .findFirst();

      return comment;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comment by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getCommentsByTask({
    required String taskId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.commentIsars
          .filter()
          .taskIdEqualTo(taskId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final comments = await query
          .sortByCreatedAt()
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comments by task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getCommentsByUser({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.commentIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final comments = await query
          .sortByCreatedAtDesc()
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comments by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getReplies({
    required String parentCommentId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.commentIsars
          .filter()
          .parentCommentIdEqualTo(parentCommentId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final comments = await query
          .sortByCreatedAt()
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get replies',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getRootComments({
    required String taskId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.commentIsars
          .filter()
          .taskIdEqualTo(taskId)
          .parentCommentIdIsNull();

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final comments = await query
          .sortByCreatedAt()
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get root comments',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getRecentComments({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final comments = await _db.commentIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent comments',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getCommentsWithMentions({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.commentIsars.filter();

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final allComments = await query.findAll();

      // Filter comments that mention the user
      final commentsWithMentions = allComments.where((comment) =>
        comment.mentions.contains(userId)
      ).toList();

      // Sort by creation time descending
      commentsWithMentions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return commentsWithMentions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comments with mentions',
        originalException: e,
      );
    }
  }

  @override
  Future<CommentIsar> updateComment(CommentIsar comment) async {
    try {
      final existingComment = await getCommentByFirebaseId(comment.commentId);
      if (existingComment == null) {
        throw const CacheException(
          message: 'Comment not found in local database',
        );
      }

      // Update timestamp and mark as edited
      comment.updatedAt = DateTime.now();
      comment.isEdited = true;
      comment.isDirty = true;

      return await upsertComment(comment);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update comment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final comment = await getCommentByFirebaseId(commentId);
      if (comment == null) return;

      comment.isDeleted = true;
      comment.deletedAt = DateTime.now();
      comment.updatedAt = DateTime.now();
      comment.isDirty = true;

      await _db.writeTxn(() async {
        await _db.commentIsars.put(comment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete comment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteComment(String commentId) async {
    try {
      final comment = await getCommentByFirebaseId(commentId);
      if (comment == null) return;

      await _db.writeTxn(() async {
        await _db.commentIsars.delete(comment.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete comment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertComments(List<CommentIsar> comments) async {
    try {
      await _db.writeTxn(() async {
        await _db.commentIsars.putAll(comments);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert comments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteCommentsForTask(String taskId) async {
    try {
      final comments = await getCommentsByTask(
        taskId: taskId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final comment in comments) {
          comment.isDeleted = true;
          comment.deletedAt = DateTime.now();
          comment.updatedAt = DateTime.now();
          comment.isDirty = true;
          await _db.commentIsars.put(comment);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete comments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CommentIsar>> getDirtyComments() async {
    try {
      final comments = await _db.commentIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return comments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty comments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String commentId) async {
    try {
      final comment = await getCommentByFirebaseId(commentId);
      if (comment == null) return;

      comment.isDirty = false;
      comment.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.commentIsars.put(comment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark comment as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String commentId) async {
    try {
      final comment = await getCommentByFirebaseId(commentId);
      if (comment == null) return;

      comment.isDirty = true;

      await _db.writeTxn(() async {
        await _db.commentIsars.put(comment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark comment as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearCommentsForUser(String userId) async {
    try {
      final comments = await getCommentsByUser(
        userId: userId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final comment in comments) {
          await _db.commentIsars.delete(comment.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear comments for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getCommentCountForTask(String taskId) async {
    try {
      final count = await _db.commentIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comment count for task',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getCommentCountForUser(String userId) async {
    try {
      final count = await _db.commentIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get comment count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getReplyCount(String commentId) async {
    try {
      final count = await _db.commentIsars
          .filter()
          .parentCommentIdEqualTo(commentId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reply count',
        originalException: e,
      );
    }
  }

  @override
  Stream<CommentIsar?> watchComment(String commentId) {
    try {
      return _db.commentIsars
          .filter()
          .commentIdEqualTo(commentId)
          .watch(fireImmediately: true)
          .map((comments) => comments.isNotEmpty ? comments.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch comment',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<CommentIsar>> watchCommentsForTask({
    required String taskId,
  }) {
    try {
      return _db.commentIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch comments for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<CommentIsar>> watchReplies({
    required String parentCommentId,
  }) {
    try {
      return _db.commentIsars
          .filter()
          .parentCommentIdEqualTo(parentCommentId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch replies',
        originalException: e,
      );
    }
  }
}
