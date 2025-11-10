import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/local/isar/isar_comment_local_data_source.dart';
import '../datasources/local/isar/schemas/comment_isar.dart';
import '../datasources/remote/firebase_comment_remote_data_source.dart';
import '../models/comment_model.dart';

/// Comment repository implementation with offline-first architecture
class CommentRepositoryImpl implements CommentRepository {
  final FirebaseCommentRemoteDataSource remoteDataSource;
  final IsarCommentLocalDataSource localDataSource;

  CommentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CommentEntity>> createComment(
      CommentEntity comment) async {
    try {
      final model = CommentModel.fromEntity(comment);

      // Save to local first
      final isarComment = _modelToIsar(model);
      isarComment.isDirty = true;
      await localDataSource.upsertComment(isarComment);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createComment(model);

        // Update local with server data
        final syncedIsarComment = _modelToIsar(createdModel);
        await localDataSource.upsertComment(syncedIsarComment);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(comment);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create comment: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> getComment(String id) async {
    try {
      // Try local first
      final localComment = await localDataSource.getCommentByFirebaseId(id);

      if (localComment != null) {
        return Right(_isarToEntity(localComment));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getComment(id);

      // Save to local
      final isarComment = _modelToIsar(remoteModel);
      await localDataSource.upsertComment(isarComment);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get comment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCommentsForTask({
    required String taskId,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localComments = await localDataSource.getCommentsByTask(
        taskId: taskId,
        includeDeleted: includeDeleted,
      );

      if (localComments.isNotEmpty) {
        return Right(localComments.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getCommentsForTask(
        taskId: taskId,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarComments = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertComments(isarComments);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Return local data if remote fails
      try {
        final localComments = await localDataSource.getCommentsByTask(
          taskId: taskId,
          includeDeleted: includeDeleted,
        );

        if (localComments.isNotEmpty) {
          return Right(localComments.map(_isarToEntity).toList());
        }
      } catch (_) {}

      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get comments for task: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getReplies(
      String commentId) async {
    try {
      // Try local first
      final localComments = await localDataSource.getReplies(
        parentCommentId: commentId,
        includeDeleted: false,
      );

      if (localComments.isNotEmpty) {
        return Right(localComments.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getReplies(commentId);

      // Save to local
      final isarComments = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertComments(isarComments);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get replies: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCommentsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get from local
      final localComments = await localDataSource.getCommentsByUser(
        userId: userId,
        includeDeleted: false,
      );

      return Right(localComments.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get comments by user: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCommentsMentioningUser(
      String userId) async {
    try {
      // Get from local
      final localComments = await localDataSource.getCommentsWithMentions(
        userId: userId,
        includeDeleted: false,
      );

      return Right(localComments.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get comments mentioning user: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment(
      CommentEntity comment) async {
    try {
      final model = CommentModel.fromEntity(comment);

      // Save to local first
      final isarComment = _modelToIsar(model);
      isarComment.isDirty = true;
      isarComment.isEdited = true;
      await localDataSource.upsertComment(isarComment);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateComment(model);

        // Update local with synced data
        final syncedIsarComment = _modelToIsar(updatedModel);
        await localDataSource.upsertComment(syncedIsarComment);
        await localDataSource.markAsSynced(comment.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(comment);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteComment(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteComment(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteComment(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteComment(id);
      await localDataSource.permanentlyDeleteComment(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> restoreComment(String id) async {
    try {
      final model = await remoteDataSource.restoreComment(id);

      // Update local
      final isarComment = _modelToIsar(model);
      await localDataSource.upsertComment(isarComment);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore comment: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addReaction({
    required String commentId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final model = await remoteDataSource.addReaction(
        commentId: commentId,
        userId: userId,
        emoji: emoji,
      );

      // Update local
      final isarComment = _modelToIsar(model);
      await localDataSource.upsertComment(isarComment);
      await localDataSource.markAsSynced(commentId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add reaction: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> removeReaction({
    required String commentId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final model = await remoteDataSource.removeReaction(
        commentId: commentId,
        userId: userId,
        emoji: emoji,
      );

      // Update local
      final isarComment = _modelToIsar(model);
      await localDataSource.upsertComment(isarComment);
      await localDataSource.markAsSynced(commentId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove reaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> searchComments({
    required String taskId,
    required String query,
  }) async {
    try {
      // Search in local (for offline support)
      final localComments = await localDataSource.getCommentsByTask(
        taskId: taskId,
        includeDeleted: false,
      );

      // Client-side filtering
      final lowerQuery = query.toLowerCase();
      final filtered = localComments.where((comment) {
        return comment.content.toLowerCase().contains(lowerQuery);
      }).toList();

      return Right(filtered.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search comments: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteComments(
      List<String> commentIds) async {
    try {
      // Delete locally
      for (final id in commentIds) {
        await localDataSource.deleteComment(id);
      }

      // Try to delete from remote
      try {
        await remoteDataSource.batchDeleteComments(commentIds);
      } on ServerException {
        // If remote fails, mark as dirty
        for (final id in commentIds) {
          await localDataSource.markAsDirty(id);
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to batch delete comments: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForTask(String taskId) async {
    try {
      await remoteDataSource.deleteCommentsForTask(taskId);
      await localDataSource.deleteCommentsForTask(taskId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to delete comments for task: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCommentCount(String taskId) async {
    try {
      // Get from local (fast)
      final count = await localDataSource.getCommentCountForTask(taskId);

      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get comment count: $e'));
    }
  }

  @override
  Stream<Either<Failure, CommentEntity>> watchComment(String id) {
    try {
      return localDataSource.watchComment(id).map((commentIsar) {
        if (commentIsar == null) {
          return Left(
              CacheFailure(message: 'Comment not found in local database'));
        }
        return Right(_isarToEntity(commentIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch comment: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch comment: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<CommentEntity>>> watchCommentsForTask(
      String taskId) {
    try {
      return localDataSource
          .watchCommentsForTask(taskId: taskId)
          .map((commentsIsar) {
        return Right(commentsIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch comments for task: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch comments for task: $e')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCommentStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getCommentStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get comment statistics: $e'));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert CommentModel to CommentIsar
  CommentIsar _modelToIsar(CommentModel model) {
    return CommentIsar()
      ..commentId = model.id
      ..userId = model.userId
      ..taskId = model.taskId
      ..parentCommentId = model.parentCommentId
      ..content = model.content
      ..mentions = model.mentions
      ..attachmentIds = model.attachmentIds
      ..reactionsJson =
          model.reactions != null ? jsonEncode(model.reactions) : null
      ..isEdited = model.isEdited
      ..isDeleted = model.isDeleted
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert CommentIsar to CommentEntity
  CommentEntity _isarToEntity(CommentIsar isar) {
    return CommentEntity(
      id: isar.commentId,
      userId: isar.userId,
      taskId: isar.taskId,
      parentCommentId: isar.parentCommentId,
      content: isar.content,
      mentions: isar.mentions,
      attachmentIds: isar.attachmentIds,
      reactions: isar.reactionsJson != null
          ? (jsonDecode(isar.reactionsJson!) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, List<String>.from(v as List)))
          : {},
      isEdited: isar.isEdited,
      isDeleted: isar.isDeleted,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }
}
