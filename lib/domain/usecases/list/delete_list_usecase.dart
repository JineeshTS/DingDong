import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/list_repository.dart';

/// Use case for deleting a list (soft delete)
class DeleteListUseCase {
  final ListRepository repository;

  DeleteListUseCase(this.repository);

  Future<Either<Failure, void>> call(String listId) async {
    if (listId.isEmpty) {
      return Left(ValidationFailure(message: 'List ID cannot be empty'));
    }

    return await repository.deleteList(listId);
  }
}
