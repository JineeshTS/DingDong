import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case for sending password reset email
class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) async {
    if (!_isValidEmail(email)) {
      return Left(ValidationFailure(message: 'Invalid email format'));
    }

    return await repository.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}
