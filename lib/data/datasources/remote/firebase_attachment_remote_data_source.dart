import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../models/attachment_model.dart';

/// Firebase remote data source for attachment operations
abstract class FirebaseAttachmentRemoteDataSource {
  /// Upload and create attachment
  Future<AttachmentModel> uploadAttachment({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
  });

  /// Get attachment by ID
  Future<AttachmentModel> getAttachment(String id);

  /// Get all attachments for task
  Future<List<AttachmentModel>> getAttachmentsForTask(String taskId);

  /// Get all attachments for comment
  Future<List<AttachmentModel>> getAttachmentsForComment(String commentId);

  /// Get all attachments for user
  Future<List<AttachmentModel>> getAttachments({
    required String userId,
    String? type,
    bool includeDeleted = false,
  });

  /// Get attachments by type
  Future<List<AttachmentModel>> getAttachmentsByType({
    required String userId,
    required String type,
  });

  /// Update attachment
  Future<AttachmentModel> updateAttachment(AttachmentModel attachment);

  /// Delete attachment (soft delete)
  Future<void> deleteAttachment(String id);

  /// Permanently delete attachment (removes from storage)
  Future<void> permanentlyDeleteAttachment(String id);

  /// Restore attachment
  Future<AttachmentModel> restoreAttachment(String id);

  /// Download attachment data
  Future<Uint8List> downloadAttachment(String id);

  /// Get download URL
  Future<String> getDownloadUrl(String id);

  /// Generate thumbnail for image/video
  Future<String> generateThumbnail(String attachmentId);

  /// Batch delete attachments
  Future<void> batchDeleteAttachments(List<String> attachmentIds);

  /// Delete all attachments for task
  Future<void> deleteAttachmentsForTask(String taskId);

  /// Delete all attachments for comment
  Future<void> deleteAttachmentsForComment(String commentId);

  /// Get total storage used by user
  Future<int> getTotalStorageUsed(String userId);

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStatistics(String userId);

  /// Clean up expired attachments
  Future<int> cleanupExpiredAttachments();

  /// Watch attachments for task (stream)
  Stream<List<AttachmentModel>> watchAttachmentsForTask(String taskId);

  /// Watch attachments for comment (stream)
  Stream<List<AttachmentModel>> watchAttachmentsForComment(String commentId);
}

/// Firebase implementation of attachment remote data source
class FirebaseAttachmentRemoteDataSourceImpl
    implements FirebaseAttachmentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseAttachmentRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<AttachmentModel> uploadAttachment({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
  }) async {
    try {
      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final storagePath = 'attachments/$userId/$timestamp.$extension';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(storagePath);
      final uploadTask = await storageRef.putData(
        fileData,
        SettableMetadata(contentType: mimeType),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get file size
      final metadata = await uploadTask.ref.getMetadata();
      final fileSize = metadata.size ?? fileData.length;

      // Create attachment document
      final attachmentRef = _firestore.collection('attachments').doc();
      final attachmentData = {
        'id': attachmentRef.id,
        'userId': userId,
        'taskId': taskId,
        'commentId': commentId,
        'fileName': fileName,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'url': downloadUrl,
        'storagePath': storagePath,
        'type': _getAttachmentType(mimeType),
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await attachmentRef.set(attachmentData);

      // Get the created attachment with server timestamps
      final snapshot = await attachmentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create attachment',
        );
      }

      return AttachmentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to upload attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to upload attachment',
        originalException: e,
      );
    }
  }

  String _getAttachmentType(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType.contains('pdf')) return 'document';
    if (mimeType.contains('document') || mimeType.contains('word')) {
      return 'document';
    }
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return 'spreadsheet';
    }
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return 'presentation';
    }
    return 'other';
  }

  @override
  Future<AttachmentModel> getAttachment(String id) async {
    try {
      final snapshot = await _firestore.collection('attachments').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Attachment not found',
        );
      }

      return AttachmentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsForTask(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('attachments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttachmentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get attachments for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get attachments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsForComment(String commentId) async {
    try {
      final snapshot = await _firestore
          .collection('attachments')
          .where('commentId', isEqualTo: commentId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttachmentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get attachments for comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get attachments for comment',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachments({
    required String userId,
    String? type,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('attachments')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AttachmentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get attachments',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsByType({
    required String userId,
    required String type,
  }) async {
    return getAttachments(userId: userId, type: type);
  }

  @override
  Future<AttachmentModel> updateAttachment(AttachmentModel attachment) async {
    try {
      final attachmentRef = _firestore.collection('attachments').doc(attachment.id);
      final attachmentData = attachment.toJson();
      attachmentData['updatedAt'] = FieldValue.serverTimestamp();

      await attachmentRef.update(attachmentData);

      // Get the updated attachment with server timestamps
      final snapshot = await attachmentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update attachment',
        );
      }

      return AttachmentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachment(String id) async {
    try {
      await _firestore.collection('attachments').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteAttachment(String id) async {
    try {
      // Get attachment to retrieve storage path
      final attachment = await getAttachment(id);

      // Delete from Firebase Storage
      if (attachment.storagePath != null) {
        final storageRef = _storage.ref().child(attachment.storagePath!);
        await storageRef.delete();
      }

      // Delete thumbnail if exists
      if (attachment.thumbnailUrl != null && attachment.thumbnailPath != null) {
        final thumbnailRef = _storage.ref().child(attachment.thumbnailPath!);
        await thumbnailRef.delete();
      }

      // Delete from Firestore
      await _firestore.collection('attachments').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<AttachmentModel> restoreAttachment(String id) async {
    try {
      final attachmentRef = _firestore.collection('attachments').doc(id);

      await attachmentRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await attachmentRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore attachment',
        );
      }

      return AttachmentModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<Uint8List> downloadAttachment(String id) async {
    try {
      final attachment = await getAttachment(id);

      if (attachment.storagePath == null) {
        throw const ServerException(
          message: 'Attachment storage path not found',
        );
      }

      final storageRef = _storage.ref().child(attachment.storagePath!);
      final data = await storageRef.getData();

      if (data == null) {
        throw const ServerException(
          message: 'Failed to download attachment data',
        );
      }

      return data;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to download attachment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to download attachment',
        originalException: e,
      );
    }
  }

  @override
  Future<String> getDownloadUrl(String id) async {
    try {
      final attachment = await getAttachment(id);

      if (attachment.url != null) {
        return attachment.url!;
      }

      if (attachment.storagePath == null) {
        throw const ServerException(
          message: 'Attachment storage path not found',
        );
      }

      final storageRef = _storage.ref().child(attachment.storagePath!);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get download URL',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get download URL',
        originalException: e,
      );
    }
  }

  @override
  Future<String> generateThumbnail(String attachmentId) async {
    try {
      final attachment = await getAttachment(attachmentId);

      // Only generate thumbnails for images and videos
      if (attachment.type != AttachmentType.image &&
          attachment.type != AttachmentType.video) {
        throw const ValidationException(
          message: 'Thumbnails can only be generated for images and videos',
        );
      }

      // In a real implementation, you would:
      // 1. Download the file
      // 2. Generate a thumbnail using image processing library
      // 3. Upload thumbnail to storage
      // 4. Update attachment with thumbnail URL

      // For now, return a placeholder
      // This should be implemented with Cloud Functions or client-side processing
      return 'placeholder_thumbnail_url';
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to generate thumbnail',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to generate thumbnail',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchDeleteAttachments(List<String> attachmentIds) async {
    try {
      final batch = _firestore.batch();

      for (final attachmentId in attachmentIds) {
        final attachmentRef = _firestore.collection('attachments').doc(attachmentId);
        batch.update(attachmentRef, {
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch delete attachments',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch delete attachments',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachmentsForTask(String taskId) async {
    try {
      final attachments = await getAttachmentsForTask(taskId);
      final attachmentIds = attachments.map((a) => a.id).toList();

      if (attachmentIds.isNotEmpty) {
        await batchDeleteAttachments(attachmentIds);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete attachments for task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete attachments for task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAttachmentsForComment(String commentId) async {
    try {
      final attachments = await getAttachmentsForComment(commentId);
      final attachmentIds = attachments.map((a) => a.id).toList();

      if (attachmentIds.isNotEmpty) {
        await batchDeleteAttachments(attachmentIds);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete attachments for comment',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete attachments for comment',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTotalStorageUsed(String userId) async {
    try {
      final attachments = await getAttachments(userId: userId);

      var totalSize = 0;
      for (final attachment in attachments) {
        totalSize += attachment.fileSize;
      }

      return totalSize;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get total storage used',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get total storage used',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageStatistics(String userId) async {
    try {
      final attachments = await getAttachments(userId: userId);

      var totalSize = 0;
      final typeCounts = <String, int>{};
      final typeSizes = <String, int>{};

      for (final attachment in attachments) {
        totalSize += attachment.fileSize;

        final type = attachment.type.toString().split('.').last;
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
        typeSizes[type] = (typeSizes[type] ?? 0) + attachment.fileSize;
      }

      return {
        'totalAttachments': attachments.length,
        'totalStorageUsed': totalSize,
        'attachmentsByType': typeCounts,
        'storageByType': typeSizes,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get storage statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get storage statistics',
        originalException: e,
      );
    }
  }

  @override
  Future<int> cleanupExpiredAttachments() async {
    try {
      // Get attachments deleted more than 30 days ago
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('attachments')
          .where('isDeleted', isEqualTo: true)
          .where('deletedAt',
              isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      var deletedCount = 0;
      for (final doc in snapshot.docs) {
        await permanentlyDeleteAttachment(doc.id);
        deletedCount++;
      }

      return deletedCount;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to cleanup expired attachments',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to cleanup expired attachments',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<AttachmentModel>> watchAttachmentsForTask(String taskId) {
    try {
      return _firestore
          .collection('attachments')
          .where('taskId', isEqualTo: taskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AttachmentModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch attachments for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<AttachmentModel>> watchAttachmentsForComment(String commentId) {
    try {
      return _firestore
          .collection('attachments')
          .where('commentId', isEqualTo: commentId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AttachmentModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch attachments for comment',
        originalException: e,
      );
    }
  }
}
