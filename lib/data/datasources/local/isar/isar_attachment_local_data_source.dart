import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/attachment_isar.dart';

/// Isar local data source for Attachment operations (offline storage)
abstract class IsarAttachmentLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update attachment
  Future<AttachmentIsar> upsertAttachment(AttachmentIsar attachment);

  /// Get attachment by Firebase ID
  Future<AttachmentIsar?> getAttachmentByFirebaseId(String attachmentId);

  /// Get attachments by task ID
  Future<List<AttachmentIsar>> getAttachmentsByTask({
    required String taskId,
    bool includeDeleted = false,
  });

  /// Get attachments by comment ID
  Future<List<AttachmentIsar>> getAttachmentsByComment({
    required String commentId,
    bool includeDeleted = false,
  });

  /// Get attachments by user ID
  Future<List<AttachmentIsar>> getAttachmentsByUser({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get attachments by type
  Future<List<AttachmentIsar>> getAttachmentsByType({
    required String userId,
    required AttachmentTypeIsar type,
    bool includeDeleted = false,
  });

  /// Get downloaded attachments
  Future<List<AttachmentIsar>> getDownloadedAttachments({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get recent attachments
  Future<List<AttachmentIsar>> getRecentAttachments({
    required String userId,
    int limit = 20,
  });

  /// Update attachment
  Future<AttachmentIsar> updateAttachment(AttachmentIsar attachment);

  /// Delete attachment (soft delete)
  Future<void> deleteAttachment(String attachmentId);

  /// Permanently delete attachment
  Future<void> permanentlyDeleteAttachment(String attachmentId);

  /// Mark attachment as downloaded
  Future<void> markAsDownloaded({
    required String attachmentId,
    required String localPath,
  });

  /// Update local path
  Future<void> updateLocalPath({
    required String attachmentId,
    required String localPath,
  });

  /// Update thumbnail local path
  Future<void> updateThumbnailLocalPath({
    required String attachmentId,
    required String thumbnailLocalPath,
  });

  /// Batch insert attachments
  Future<void> batchInsertAttachments(List<AttachmentIsar> attachments);

  /// Delete all attachments for task
  Future<void> deleteAttachmentsForTask(String taskId);

  /// Delete all attachments for comment
  Future<void> deleteAttachmentsForComment(String commentId);

  /// Get dirty attachments (need sync)
  Future<List<AttachmentIsar>> getDirtyAttachments();

  /// Mark attachment as synced
  Future<void> markAsSynced(String attachmentId);

  /// Mark attachment as dirty (needs sync)
  Future<void> markAsDirty(String attachmentId);

  /// Clear attachments for user
  Future<void> clearAttachmentsForUser(String userId);

  /// Get attachment count for task
  Future<int> getAttachmentCountForTask(String taskId);

  /// Get attachment count for comment
  Future<int> getAttachmentCountForComment(String commentId);

  /// Get attachment count for user
  Future<int> getAttachmentCountForUser(String userId);

  /// Get total storage used by user (in bytes)
  Future<int> getTotalStorageUsed(String userId);

  /// Watch attachment changes (stream)
  Stream<AttachmentIsar?> watchAttachment(String attachmentId);

  /// Watch attachments for task (stream)
  Stream<List<AttachmentIsar>> watchAttachmentsForTask({
    required String taskId,
  });

  /// Watch attachments for comment (stream)
  Stream<List<AttachmentIsar>> watchAttachmentsForComment({
    required String commentId,
  });
}

/// Isar implementation of attachment local data source
class IsarAttachmentLocalDataSourceImpl implements IsarAttachmentLocalDataSource {
  Isar? _isar;

  IsarAttachmentLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        AttachmentIsarSchema,
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
  Future<AttachmentIsar> upsertAttachment(AttachmentIsar attachment) async {
    try {
      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });

      // Return the inserted/updated attachment
      final savedAttachment = await getAttachmentByFirebaseId(attachment.attachmentId);
      if (savedAttachment == null) {
        throw const CacheException(
          message: 'Failed to save attachment to local database',
        );
      }

      return savedAttachment;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<AttachmentIsar?> getAttachmentByFirebaseId(String attachmentId) async {
    try {
      final attachment = await _db.attachmentIsars
          .filter()
          .attachmentIdEqualTo(attachmentId)
          .findFirst();

      return attachment;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachment by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getAttachmentsByTask({
    required String taskId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.attachmentIsars
          .filter()
          .taskIdEqualTo(taskId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final attachments = await query
          .sortByCreatedAt()
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachments by task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getAttachmentsByComment({
    required String commentId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.attachmentIsars
          .filter()
          .commentIdEqualTo(commentId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final attachments = await query
          .sortByCreatedAt()
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachments by comment',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getAttachmentsByUser({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.attachmentIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final attachments = await query
          .sortByCreatedAtDesc()
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachments by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getAttachmentsByType({
    required String userId,
    required AttachmentTypeIsar type,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.attachmentIsars
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(type);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final attachments = await query
          .sortByCreatedAtDesc()
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachments by type',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getDownloadedAttachments({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.attachmentIsars
          .filter()
          .userIdEqualTo(userId)
          .isDownloadedEqualTo(true);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final attachments = await query
          .sortByCreatedAtDesc()
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get downloaded attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getRecentAttachments({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final attachments = await _db.attachmentIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<AttachmentIsar> updateAttachment(AttachmentIsar attachment) async {
    try {
      final existingAttachment = await getAttachmentByFirebaseId(attachment.attachmentId);
      if (existingAttachment == null) {
        throw const CacheException(
          message: 'Attachment not found in local database',
        );
      }

      // Update timestamp
      attachment.updatedAt = DateTime.now();
      attachment.isDirty = true;

      return await upsertAttachment(attachment);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.isDeleted = true;
      attachment.deletedAt = DateTime.now();
      attachment.updatedAt = DateTime.now();
      attachment.isDirty = true;

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteAttachment(String attachmentId) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      await _db.writeTxn(() async {
        await _db.attachmentIsars.delete(attachment.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDownloaded({
    required String attachmentId,
    required String localPath,
  }) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.isDownloaded = true;
      attachment.localPath = localPath;
      attachment.updatedAt = DateTime.now();
      // Don't mark as dirty - download state is local only

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark attachment as downloaded',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateLocalPath({
    required String attachmentId,
    required String localPath,
  }) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.localPath = localPath;
      attachment.updatedAt = DateTime.now();
      // Don't mark as dirty - local path is local only

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update local path',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateThumbnailLocalPath({
    required String attachmentId,
    required String thumbnailLocalPath,
  }) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.thumbnailLocalPath = thumbnailLocalPath;
      attachment.updatedAt = DateTime.now();
      // Don't mark as dirty - thumbnail path is local only

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update thumbnail local path',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertAttachments(List<AttachmentIsar> attachments) async {
    try {
      await _db.writeTxn(() async {
        await _db.attachmentIsars.putAll(attachments);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachmentsForTask(String taskId) async {
    try {
      final attachments = await getAttachmentsByTask(
        taskId: taskId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final attachment in attachments) {
          attachment.isDeleted = true;
          attachment.deletedAt = DateTime.now();
          attachment.updatedAt = DateTime.now();
          attachment.isDirty = true;
          await _db.attachmentIsars.put(attachment);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete attachments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachmentsForComment(String commentId) async {
    try {
      final attachments = await getAttachmentsByComment(
        commentId: commentId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final attachment in attachments) {
          attachment.isDeleted = true;
          attachment.deletedAt = DateTime.now();
          attachment.updatedAt = DateTime.now();
          attachment.isDirty = true;
          await _db.attachmentIsars.put(attachment);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete attachments for comment',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentIsar>> getDirtyAttachments() async {
    try {
      final attachments = await _db.attachmentIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return attachments;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String attachmentId) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.isDirty = false;
      attachment.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark attachment as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String attachmentId) async {
    try {
      final attachment = await getAttachmentByFirebaseId(attachmentId);
      if (attachment == null) return;

      attachment.isDirty = true;

      await _db.writeTxn(() async {
        await _db.attachmentIsars.put(attachment);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark attachment as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearAttachmentsForUser(String userId) async {
    try {
      final attachments = await getAttachmentsByUser(
        userId: userId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final attachment in attachments) {
          await _db.attachmentIsars.delete(attachment.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear attachments for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getAttachmentCountForTask(String taskId) async {
    try {
      final count = await _db.attachmentIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachment count for task',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getAttachmentCountForComment(String commentId) async {
    try {
      final count = await _db.attachmentIsars
          .filter()
          .commentIdEqualTo(commentId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachment count for comment',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getAttachmentCountForUser(String userId) async {
    try {
      final count = await _db.attachmentIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get attachment count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTotalStorageUsed(String userId) async {
    try {
      final attachments = await getAttachmentsByUser(
        userId: userId,
        includeDeleted: false,
      );

      // Sum up all file sizes
      int totalSize = 0;
      for (final attachment in attachments) {
        totalSize += attachment.fileSize;
      }

      return totalSize;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get total storage used',
        originalException: e,
      );
    }
  }

  @override
  Stream<AttachmentIsar?> watchAttachment(String attachmentId) {
    try {
      return _db.attachmentIsars
          .filter()
          .attachmentIdEqualTo(attachmentId)
          .watch(fireImmediately: true)
          .map((attachments) => attachments.isNotEmpty ? attachments.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch attachment',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<AttachmentIsar>> watchAttachmentsForTask({
    required String taskId,
  }) {
    try {
      return _db.attachmentIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch attachments for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<AttachmentIsar>> watchAttachmentsForComment({
    required String commentId,
  }) {
    try {
      return _db.attachmentIsars
          .filter()
          .commentIdEqualTo(commentId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch attachments for comment',
        originalException: e,
      );
    }
  }
}
