import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/list_entity.dart';
import '../../repositories/list_repository.dart';

/// Use case for getting lists shared with user
class GetSharedListsUseCase {
  final ListRepository repository;

  GetSharedListsUseCase(this.repository);

  Future<Either<Failure, List<ListEntity>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getSharedLists(userId);
  }
}
