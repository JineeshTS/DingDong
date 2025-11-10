import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/list_entity.dart';
import '../../domain/repositories/list_repository.dart';
import '../datasources/local/isar/isar_list_local_data_source.dart';
import '../datasources/local/isar/schemas/list_isar.dart';
import '../datasources/remote/firebase_list_remote_data_source.dart';
import '../models/list_model.dart';

/// List repository implementation with offline-first architecture
class ListRepositoryImpl implements ListRepository {
  final FirebaseListRemoteDataSource remoteDataSource;
  final IsarListLocalDataSource localDataSource;

  ListRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ListEntity>> createList(ListEntity list) async {
    try {
      final model = ListModel.fromEntity(list);

      // Save to local first
      final isarList = _modelToIsar(model);
      isarList.isDirty = true;
      await localDataSource.upsertList(isarList);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createList(model);

        // Update local with server data
        final syncedIsarList = _modelToIsar(createdModel);
        await localDataSource.upsertList(syncedIsarList);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success (will sync later)
        return Right(list);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> getList(String id) async {
    try {
      // Try local first (offline-first)
      final localList = await localDataSource.getListByFirebaseId(id);

      if (localList != null) {
        return Right(_isarToEntity(localList));
      }

      // If not in local, fetch from remote
      final remoteModel = await remoteDataSource.getList(id);

      // Save to local
      final isarList = _modelToIsar(remoteModel);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get list: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getLists({
    required String userId,
    String? workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localLists = workspaceId != null
          ? await localDataSource.getListsByWorkspace(
              workspaceId: workspaceId,
              includeArchived: includeArchived,
              includeDeleted: includeDeleted,
            )
          : await localDataSource.getListsByUser(
              userId: userId,
              includeArchived: includeArchived,
              includeDeleted: includeDeleted,
            );

      if (localLists.isNotEmpty) {
        return Right(localLists.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getLists(
        userId: userId,
        workspaceId: workspaceId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarLists = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertLists(isarLists);

      // Mark all as synced
      for (final model in remoteModels) {
        await localDataSource.markAsSynced(model.id);
      }

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Return local data if remote fails
      try {
        final localLists = workspaceId != null
            ? await localDataSource.getListsByWorkspace(
                workspaceId: workspaceId,
                includeArchived: includeArchived,
                includeDeleted: includeDeleted,
              )
            : await localDataSource.getListsByUser(
                userId: userId,
                includeArchived: includeArchived,
                includeDeleted: includeDeleted,
              );

        if (localLists.isNotEmpty) {
          return Right(localLists.map(_isarToEntity).toList());
        }
      } catch (_) {}

      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get lists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getSharedLists(String userId) async {
    try {
      // Try local first
      final localLists = await localDataSource.getSharedLists(
        userId: userId,
        includeArchived: false,
      );

      if (localLists.isNotEmpty) {
        return Right(localLists.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getSharedLists(userId);

      // Save to local
      final isarLists = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertLists(isarLists);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get shared lists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getFavoriteLists(
      String userId) async {
    try {
      // Get from local (favorites are local-first)
      final localLists = await localDataSource.getFavoriteLists(
        userId: userId,
        includeArchived: false,
      );

      return Right(localLists.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get favorite lists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getNestedLists(
      String parentListId) async {
    try {
      // Try local first
      final localLists = await localDataSource.getNestedLists(
        parentListId: parentListId,
        includeArchived: false,
        includeDeleted: false,
      );

      if (localLists.isNotEmpty) {
        return Right(localLists.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getNestedLists(parentListId);

      // Save to local
      final isarLists = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertLists(isarLists);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get nested lists: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> updateList(ListEntity list) async {
    try {
      final model = ListModel.fromEntity(list);

      // Save to local first
      final isarList = _modelToIsar(model);
      isarList.isDirty = true;
      await localDataSource.upsertList(isarList);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateList(model);

        // Update local with synced data
        final syncedIsarList = _modelToIsar(updatedModel);
        await localDataSource.upsertList(syncedIsarList);
        await localDataSource.markAsSynced(list.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(list);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteList(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteList(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteList(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteList(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteList(id);
      await localDataSource.permanentlyDeleteList(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> restoreList(String id) async {
    try {
      final model = await remoteDataSource.restoreList(id);

      // Update local
      final isarList = _modelToIsar(model);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> archiveList(String id) async {
    try {
      // Archive locally first
      await localDataSource.archiveList(id);

      // Sync to remote
      try {
        final model = await remoteDataSource.archiveList(id);

        // Update local with server data
        final isarList = _modelToIsar(model);
        await localDataSource.upsertList(isarList);
        await localDataSource.markAsSynced(id);

        return Right(model.toEntity());
      } on ServerException {
        // If remote fails, mark as dirty
        await localDataSource.markAsDirty(id);

        final localList = await localDataSource.getListByFirebaseId(id);
        if (localList != null) {
          return Right(_isarToEntity(localList));
        }
        rethrow;
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to archive list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> unarchiveList(String id) async {
    try {
      // Unarchive locally first
      await localDataSource.unarchiveList(id);

      // Sync to remote
      try {
        final model = await remoteDataSource.unarchiveList(id);

        // Update local with server data
        final isarList = _modelToIsar(model);
        await localDataSource.upsertList(isarList);
        await localDataSource.markAsSynced(id);

        return Right(model.toEntity());
      } on ServerException {
        // If remote fails, mark as dirty
        await localDataSource.markAsDirty(id);

        final localList = await localDataSource.getListByFirebaseId(id);
        if (localList != null) {
          return Right(_isarToEntity(localList));
        }
        rethrow;
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to unarchive list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> toggleFavorite(String id) async {
    try {
      // Toggle locally first (instant UI feedback)
      await localDataSource.toggleFavorite(id);

      // Sync to remote in background (don't wait)
      remoteDataSource.toggleFavorite(id).then((model) {
        final isarList = _modelToIsar(model);
        localDataSource.upsertList(isarList);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        // Mark as dirty if sync fails
        localDataSource.markAsDirty(id);
      });

      // Get updated local list
      final localList = await localDataSource.getListByFirebaseId(id);
      if (localList == null) {
        return Left(CacheFailure(message: 'List not found'));
      }

      return Right(_isarToEntity(localList));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> shareList({
    required String listId,
    required List<String> userIds,
    required ListPermission permission,
  }) async {
    try {
      final model = await remoteDataSource.shareList(
        listId: listId,
        userIds: userIds,
        permission: permission,
      );

      // Update local
      final isarList = _modelToIsar(model);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(listId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to share list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> unshareList({
    required String listId,
    required String userId,
  }) async {
    try {
      final model = await remoteDataSource.unshareList(
        listId: listId,
        userId: userId,
      );

      // Update local
      final isarList = _modelToIsar(model);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(listId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to unshare list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> updateCollaboratorPermission({
    required String listId,
    required String userId,
    required ListPermission permission,
  }) async {
    try {
      final model = await remoteDataSource.updateCollaboratorPermission(
        listId: listId,
        userId: userId,
        permission: permission,
      );

      // Update local
      final isarList = _modelToIsar(model);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(listId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to update collaborator permission: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateShareLink({
    required String listId,
    DateTime? expiresAt,
  }) async {
    try {
      final shareLink = await remoteDataSource.generateShareLink(
        listId: listId,
        expiresAt: expiresAt,
      );

      return Right(shareLink);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to generate share link: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> revokeShareLink(String listId) async {
    try {
      await remoteDataSource.revokeShareLink(listId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to revoke share link: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> acceptListInvitation(String listId) async {
    try {
      final model = await remoteDataSource.acceptListInvitation(listId);

      // Save to local
      final isarList = _modelToIsar(model);
      await localDataSource.upsertList(isarList);
      await localDataSource.markAsSynced(listId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to accept list invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> declineListInvitation(String listId) async {
    try {
      await remoteDataSource.declineListInvitation(listId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to decline list invitation: $e'));
    }
  }

  @override
  Stream<Either<Failure, ListEntity>> watchList(String id) {
    try {
      return localDataSource.watchList(id).map((listIsar) {
        if (listIsar == null) {
          return Left(CacheFailure(message: 'List not found in local database'));
        }
        return Right(_isarToEntity(listIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch list: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch list: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<ListEntity>>> watchLists({
    required String userId,
    String? workspaceId,
  }) {
    try {
      return workspaceId != null
          ? localDataSource
              .watchListsForWorkspace(
                workspaceId: workspaceId,
                includeArchived: false,
              )
              .map((listsIsar) {
              return Right(listsIsar.map(_isarToEntity).toList());
            }).handleError((error) {
              return Left(CacheFailure(message: 'Failed to watch lists: $error'));
            })
          : localDataSource
              .watchListsForUser(
                userId: userId,
                includeArchived: false,
              )
              .map((listsIsar) {
              return Right(listsIsar.map(_isarToEntity).toList());
            }).handleError((error) {
              return Left(CacheFailure(message: 'Failed to watch lists: $error'));
            });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch lists: $e')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getListStatistics(
      String listId) async {
    try {
      final stats = await remoteDataSource.getListStatistics(listId);

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get list statistics: $e'));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert ListModel to ListIsar
  ListIsar _modelToIsar(ListModel model) {
    return ListIsar()
      ..listId = model.id
      ..userId = model.userId
      ..workspaceId = model.workspaceId
      ..parentListId = model.parentListId
      ..name = model.name
      ..description = model.description
      ..color = model.color
      ..icon = model.icon
      ..type = _typeToIsar(model.type)
      ..isFavorite = model.isFavorite
      ..isArchived = model.isArchived
      ..isDeleted = model.isDeleted
      ..isShared = model.shareSettings != null &&
          model.shareSettings!.collaborators.isNotEmpty
      ..sortOrder = model.sortOrder
      ..taskCount = 0 // Will be updated separately
      ..completedTaskCount = 0 // Will be updated separately
      ..collaboratorsJson = model.shareSettings != null
          ? jsonEncode(model.shareSettings!.toJson())
          : null
      ..shareSettingsJson = model.shareSettings != null
          ? jsonEncode(model.shareSettings!.toJson())
          : null
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..archivedAt = model.isArchived ? model.updatedAt : null
      ..deletedAt = model.isDeleted ? model.updatedAt : null;
  }

  /// Convert ListIsar to ListEntity
  ListEntity _isarToEntity(ListIsar isar) {
    return ListEntity(
      id: isar.listId,
      userId: isar.userId,
      workspaceId: isar.workspaceId,
      parentListId: isar.parentListId,
      name: isar.name,
      description: isar.description,
      type: _typeFromIsar(isar.type),
      icon: isar.icon,
      color: isar.color,
      defaultViewType: ListViewType.list, // Not stored in Isar
      defaultSortType: ListSortType.manual, // Not stored in Isar
      sortAscending: true, // Not stored in Isar
      sortOrder: isar.sortOrder,
      isArchived: isar.isArchived,
      isDeleted: isar.isDeleted,
      isFavorite: isar.isFavorite,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      createdBy: isar.userId, // Assuming creator is the user
      lastModifiedBy: null,
      settings: null, // Not stored in Isar for simplicity
      shareSettings: isar.shareSettingsJson != null
          ? ListShareSettingsModel.fromJson(
              jsonDecode(isar.shareSettingsJson!) as Map<String, dynamic>).toEntity()
          : null,
    );
  }

  /// Convert type string to Isar enum
  ListTypeIsar _typeToIsar(String type) {
    switch (type) {
      case 'personal':
        return ListTypeIsar.personal;
      case 'shared':
        return ListTypeIsar.shared;
      case 'smart':
        return ListTypeIsar.smart;
      case 'template':
        return ListTypeIsar.template;
      default:
        return ListTypeIsar.personal;
    }
  }

  /// Convert Isar type to domain enum
  ListType _typeFromIsar(ListTypeIsar type) {
    switch (type) {
      case ListTypeIsar.personal:
        return ListType.personal;
      case ListTypeIsar.shared:
        return ListType.shared;
      case ListTypeIsar.smart:
        return ListType.smart;
      case ListTypeIsar.template:
        return ListType.template;
    }
  }
}
