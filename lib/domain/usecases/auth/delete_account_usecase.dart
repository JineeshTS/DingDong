import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case for deleting user account
class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String password,
  }) async {
    if (password.isEmpty) {
      return Left(
          ValidationFailure(message: 'Password required for account deletion'));
    }

    return await repository.deleteAccount(password: password);
  }
}
