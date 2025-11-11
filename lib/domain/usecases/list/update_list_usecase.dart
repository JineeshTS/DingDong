import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/list_entity.dart';
import '../../repositories/list_repository.dart';

/// Use case for updating a list
class UpdateListUseCase {
  final ListRepository repository;

  UpdateListUseCase(this.repository);

  Future<Either<Failure, ListEntity>> call(ListEntity list) async {
    // Validate list name
    if (list.name.trim().isEmpty) {
      return Left(ValidationFailure(message: 'List name cannot be empty'));
    }

    if (list.name.trim().length > 100) {
      return Left(ValidationFailure(
          message: 'List name cannot exceed 100 characters'));
    }

    // Validate description if provided
    if (list.description != null && list.description!.length > 500) {
      return Left(ValidationFailure(
          message: 'List description cannot exceed 500 characters'));
    }

    return await repository.updateList(list);
  }
}
