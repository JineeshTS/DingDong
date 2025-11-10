import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/list_entity.dart';

/// List repository interface
abstract class ListRepository {
  /// Create a new list
  Future<Either<Failure, ListEntity>> createList(ListEntity list);

  /// Get list by ID
  Future<Either<Failure, ListEntity>> getList(String id);

  /// Get all lists for user
  Future<Either<Failure, List<ListEntity>>> getLists({
    required String userId,
    String? workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get shared lists
  Future<Either<Failure, List<ListEntity>>> getSharedLists(String userId);

  /// Get favorite lists
  Future<Either<Failure, List<ListEntity>>> getFavoriteLists(String userId);

  /// Get nested lists (children of parent)
  Future<Either<Failure, List<ListEntity>>> getNestedLists(String parentListId);

  /// Update list
  Future<Either<Failure, ListEntity>> updateList(ListEntity list);

  /// Delete list (soft delete)
  Future<Either<Failure, void>> deleteList(String id);

  /// Permanently delete list
  Future<Either<Failure, void>> permanentlyDeleteList(String id);

  /// Restore list
  Future<Either<Failure, ListEntity>> restoreList(String id);

  /// Archive list
  Future<Either<Failure, ListEntity>> archiveList(String id);

  /// Unarchive list
  Future<Either<Failure, ListEntity>> unarchiveList(String id);

  /// Toggle favorite
  Future<Either<Failure, ListEntity>> toggleFavorite(String id);

  /// Share list
  Future<Either<Failure, ListEntity>> shareList({
    required String listId,
    required List<String> userIds,
    required ListPermission permission,
  });

  /// Unshare list
  Future<Either<Failure, ListEntity>> unshareList({
    required String listId,
    required String userId,
  });

  /// Update collaborator permission
  Future<Either<Failure, ListEntity>> updateCollaboratorPermission({
    required String listId,
    required String userId,
    required ListPermission permission,
  });

  /// Generate share link
  Future<Either<Failure, String>> generateShareLink({
    required String listId,
    DateTime? expiresAt,
  });

  /// Revoke share link
  Future<Either<Failure, void>> revokeShareLink(String listId);

  /// Accept list invitation
  Future<Either<Failure, ListEntity>> acceptListInvitation(String listId);

  /// Decline list invitation
  Future<Either<Failure, void>> declineListInvitation(String listId);

  /// Watch list (stream)
  Stream<Either<Failure, ListEntity>> watchList(String id);

  /// Watch lists (stream)
  Stream<Either<Failure, List<ListEntity>>> watchLists({
    required String userId,
    String? workspaceId,
  });

  /// Get list statistics
  Future<Either<Failure, Map<String, dynamic>>> getListStatistics(String listId);
}
