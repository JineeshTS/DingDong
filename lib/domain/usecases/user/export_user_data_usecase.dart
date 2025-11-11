import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';

/// Use case for exporting user data (GDPR compliance)
class ExportUserDataUseCase {
  final UserRepository repository;

  ExportUserDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.exportUserData(userId);
  }
}
