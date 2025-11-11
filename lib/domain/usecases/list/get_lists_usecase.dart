import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/list_entity.dart';
import '../../repositories/list_repository.dart';

/// Use case for getting user's lists
class GetListsUseCase {
  final ListRepository repository;

  GetListsUseCase(this.repository);

  Future<Either<Failure, List<ListEntity>>> call({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getLists(
      userId: userId,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }
}
