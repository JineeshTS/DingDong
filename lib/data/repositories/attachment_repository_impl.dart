import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/attachment_entity.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../datasources/local/isar/isar_attachment_local_data_source.dart';
import '../datasources/local/isar/schemas/attachment_isar.dart';
import '../datasources/remote/firebase_attachment_remote_data_source.dart';
import '../models/attachment_model.dart';

/// Attachment repository implementation with offline-first architecture
class AttachmentRepositoryImpl implements AttachmentRepository {
  final FirebaseAttachmentRemoteDataSource remoteDataSource;
  final IsarAttachmentLocalDataSource localDataSource;

  AttachmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AttachmentEntity>> uploadAttachment({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
  }) async {
    try {
      final model = await remoteDataSource.uploadAttachment(
        userId: userId,
        taskId: taskId,
        commentId: commentId,
        fileName: fileName,
        fileData: fileData,
        mimeType: mimeType,
      );

      // Save to local
      final isarAttachment = _modelToIsar(model);
      await localDataSource.upsertAttachment(isarAttachment);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to upload attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, AttachmentEntity>> getAttachment(String id) async {
    try {
      // Try local first
      final localAttachment =
          await localDataSource.getAttachmentByFirebaseId(id);

      if (localAttachment != null) {
        return Right(_isarToEntity(localAttachment));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getAttachment(id);

      // Save to local
      final isarAttachment = _modelToIsar(remoteModel);
      await localDataSource.upsertAttachment(isarAttachment);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsForTask(
      String taskId) async {
    try {
      // Try local first
      final localAttachments = await localDataSource.getAttachmentsByTask(
        taskId: taskId,
        includeDeleted: false,
      );

      if (localAttachments.isNotEmpty) {
        return Right(localAttachments.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels =
          await remoteDataSource.getAttachmentsForTask(taskId);

      // Save to local
      final isarAttachments = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertAttachments(isarAttachments);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get attachments for task: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsForComment(
      String commentId) async {
    try {
      // Try local first
      final localAttachments = await localDataSource.getAttachmentsByComment(
        commentId: commentId,
        includeDeleted: false,
      );

      if (localAttachments.isNotEmpty) {
        return Right(localAttachments.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels =
          await remoteDataSource.getAttachmentsForComment(commentId);

      // Save to local
      final isarAttachments = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertAttachments(isarAttachments);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get attachments for comment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttachmentEntity>>> getAttachments({
    required String userId,
    AttachmentType? type,
    bool includeDeleted = false,
  }) async {
    try {
      // Get from local
      final localAttachments = type != null
          ? await localDataSource.getAttachmentsByType(
              userId: userId,
              type: _typeToIsar(type),
              includeDeleted: includeDeleted,
            )
          : await localDataSource.getAttachmentsByUser(
              userId: userId,
              includeDeleted: includeDeleted,
            );

      return Right(localAttachments.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get attachments: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsByType({
    required String userId,
    required AttachmentType type,
  }) async {
    try {
      // Get from local
      final localAttachments = await localDataSource.getAttachmentsByType(
        userId: userId,
        type: _typeToIsar(type),
        includeDeleted: false,
      );

      return Right(localAttachments.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get attachments by type: $e'));
    }
  }

  @override
  Future<Either<Failure, AttachmentEntity>> updateAttachment(
      AttachmentEntity attachment) async {
    try {
      final model = AttachmentModel.fromEntity(attachment);

      // Save to local first
      final isarAttachment = _modelToIsar(model);
      isarAttachment.isDirty = true;
      await localDataSource.upsertAttachment(isarAttachment);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateAttachment(model);

        // Update local with synced data
        final syncedIsarAttachment = _modelToIsar(updatedModel);
        await localDataSource.upsertAttachment(syncedIsarAttachment);
        await localDataSource.markAsSynced(attachment.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(attachment);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteAttachment(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteAttachment(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteAttachment(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteAttachment(id);
      await localDataSource.permanentlyDeleteAttachment(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to permanently delete attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getDownloadUrl(String attachmentId) async {
    try {
      final url = await remoteDataSource.getDownloadUrl(attachmentId);

      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get download URL: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadAttachment(
      String attachmentId) async {
    try {
      final data = await remoteDataSource.downloadAttachment(attachmentId);

      // Mark as downloaded locally
      final localAttachment =
          await localDataSource.getAttachmentByFirebaseId(attachmentId);
      if (localAttachment != null) {
        // Would save file locally and update local path in production
        // For now, just mark as downloaded
        await localDataSource.markAsDownloaded(
          attachmentId: attachmentId,
          localPath: '/local/path/${localAttachment.fileName}',
        );
      }

      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to download attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteAttachments(
      List<String> attachmentIds) async {
    try {
      // Delete locally
      for (final id in attachmentIds) {
        await localDataSource.deleteAttachment(id);
      }

      // Try to delete from remote
      try {
        await remoteDataSource.batchDeleteAttachments(attachmentIds);
      } on ServerException {
        // If remote fails, mark as dirty
        for (final id in attachmentIds) {
          await localDataSource.markAsDirty(id);
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to batch delete attachments: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachmentsForTask(String taskId) async {
    try {
      await remoteDataSource.deleteAttachmentsForTask(taskId);
      await localDataSource.deleteAttachmentsForTask(taskId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to delete attachments for task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachmentsForComment(
      String commentId) async {
    try {
      await remoteDataSource.deleteAttachmentsForComment(commentId);
      await localDataSource.deleteAttachmentsForComment(commentId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to delete attachments for comment: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalStorageUsed(String userId) async {
    try {
      // Get from local
      final totalBytes = await localDataSource.getTotalStorageUsed(userId);

      return Right(totalBytes);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get total storage used: $e'));
    }
  }

  @override
  Stream<Either<Failure, AttachmentEntity>> watchAttachment(String id) {
    try {
      return localDataSource.watchAttachment(id).map((attachmentIsar) {
        if (attachmentIsar == null) {
          return Left(
              CacheFailure(message: 'Attachment not found in local database'));
        }
        return Right(_isarToEntity(attachmentIsar));
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch attachment: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch attachment: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<AttachmentEntity>>> watchAttachmentsForTask(
      String taskId) {
    try {
      return localDataSource
          .watchAttachmentsForTask(taskId: taskId)
          .map((attachmentsIsar) {
        return Right(attachmentsIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(CacheFailure(
            message: 'Failed to watch attachments for task: $error'));
      });
    } catch (e) {
      return Stream.value(Left(
          CacheFailure(message: 'Failed to watch attachments for task: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<AttachmentEntity>>> watchAttachmentsForComment(
      String commentId) {
    try {
      return localDataSource
          .watchAttachmentsForComment(commentId: commentId)
          .map((attachmentsIsar) {
        return Right(attachmentsIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(CacheFailure(
            message: 'Failed to watch attachments for comment: $error'));
      });
    } catch (e) {
      return Stream.value(Left(CacheFailure(
          message: 'Failed to watch attachments for comment: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert AttachmentModel to AttachmentIsar
  AttachmentIsar _modelToIsar(AttachmentModel model) {
    return AttachmentIsar()
      ..attachmentId = model.id
      ..userId = model.userId
      ..taskId = model.taskId
      ..commentId = model.commentId
      ..fileName = model.fileName
      ..fileSize = model.fileSize
      ..mimeType = model.mimeType
      ..type = _typeToIsar(_typeFromString(model.type))
      ..url = model.url
      ..localPath = null // Will be set when downloaded
      ..storagePath = model.storagePath
      ..thumbnailUrl = model.thumbnailUrl
      ..thumbnailLocalPath = null
      ..thumbnailPath = model.thumbnailPath
      ..isDownloaded = false
      ..isDeleted = model.isDeleted
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert AttachmentIsar to AttachmentEntity
  AttachmentEntity _isarToEntity(AttachmentIsar isar) {
    return AttachmentEntity(
      id: isar.attachmentId,
      userId: isar.userId,
      taskId: isar.taskId,
      commentId: isar.commentId,
      fileName: isar.fileName,
      fileSize: isar.fileSize,
      mimeType: isar.mimeType,
      type: _typeFromIsar(isar.type),
      url: isar.url,
      storagePath: isar.storagePath,
      thumbnailUrl: isar.thumbnailUrl,
      thumbnailPath: isar.thumbnailPath,
      isDeleted: isar.isDeleted,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }

  /// Convert type string to domain enum
  AttachmentType _typeFromString(String type) {
    switch (type) {
      case 'image':
        return AttachmentType.image;
      case 'video':
        return AttachmentType.video;
      case 'audio':
        return AttachmentType.audio;
      case 'document':
        return AttachmentType.document;
      case 'spreadsheet':
        return AttachmentType.spreadsheet;
      case 'presentation':
        return AttachmentType.presentation;
      case 'other':
        return AttachmentType.other;
      default:
        return AttachmentType.other;
    }
  }

  /// Convert domain type to Isar enum
  AttachmentTypeIsar _typeToIsar(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return AttachmentTypeIsar.image;
      case AttachmentType.video:
        return AttachmentTypeIsar.video;
      case AttachmentType.audio:
        return AttachmentTypeIsar.audio;
      case AttachmentType.document:
        return AttachmentTypeIsar.document;
      case AttachmentType.spreadsheet:
        return AttachmentTypeIsar.spreadsheet;
      case AttachmentType.presentation:
        return AttachmentTypeIsar.presentation;
      case AttachmentType.other:
        return AttachmentTypeIsar.other;
    }
  }

  /// Convert Isar type to domain enum
  AttachmentType _typeFromIsar(AttachmentTypeIsar type) {
    switch (type) {
      case AttachmentTypeIsar.image:
        return AttachmentType.image;
      case AttachmentTypeIsar.video:
        return AttachmentType.video;
      case AttachmentTypeIsar.audio:
        return AttachmentType.audio;
      case AttachmentTypeIsar.document:
        return AttachmentType.document;
      case AttachmentTypeIsar.spreadsheet:
        return AttachmentType.spreadsheet;
      case AttachmentTypeIsar.presentation:
        return AttachmentType.presentation;
      case AttachmentTypeIsar.other:
        return AttachmentType.other;
    }
  }
}
