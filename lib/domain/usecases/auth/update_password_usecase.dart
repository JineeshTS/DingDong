import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case for updating user password
class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Validate passwords
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      return Left(ValidationFailure(message: 'Passwords cannot be empty'));
    }

    if (currentPassword == newPassword) {
      return Left(ValidationFailure(
          message: 'New password must be different from current password'));
    }

    final passwordValidation = _validatePassword(newPassword);
    if (passwordValidation != null) {
      return Left(ValidationFailure(message: passwordValidation));
    }

    return await repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  String? _validatePassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]')))
      return 'Password must contain uppercase letter';
    if (!password.contains(RegExp(r'[a-z]')))
      return 'Password must contain lowercase letter';
    if (!password.contains(RegExp(r'[0-9]')))
      return 'Password must contain number';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      return 'Password must contain special character';
    return null;
  }
}
