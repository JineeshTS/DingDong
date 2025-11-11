import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/list_entity.dart';
import '../../repositories/list_repository.dart';

/// Use case for unarchiving a list
class UnarchiveListUseCase {
  final ListRepository repository;

  UnarchiveListUseCase(this.repository);

  Future<Either<Failure, ListEntity>> call(String listId) async {
    if (listId.isEmpty) {
      return Left(ValidationFailure(message: 'List ID cannot be empty'));
    }

    return await repository.unarchiveList(listId);
  }
}
