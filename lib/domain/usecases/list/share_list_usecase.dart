import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/list_entity.dart';
import '../../repositories/list_repository.dart';

/// Use case for sharing a list with other users
class ShareListUseCase {
  final ListRepository repository;

  ShareListUseCase(this.repository);

  Future<Either<Failure, ListEntity>> call({
    required String listId,
    required List<String> userIds,
    required ListPermission permission,
  }) async {
    if (listId.isEmpty) {
      return Left(ValidationFailure(message: 'List ID cannot be empty'));
    }

    if (userIds.isEmpty) {
      return Left(ValidationFailure(
          message: 'At least one user ID must be provided'));
    }

    if (userIds.length > 50) {
      return Left(ValidationFailure(
          message: 'Cannot share with more than 50 users at once'));
    }

    return await repository.shareList(
      listId: listId,
      userIds: userIds,
      permission: permission,
    );
  }
}
