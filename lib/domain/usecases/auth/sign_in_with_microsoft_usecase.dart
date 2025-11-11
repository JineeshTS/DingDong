import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Microsoft
class SignInWithMicrosoftUseCase {
  final AuthRepository repository;

  SignInWithMicrosoftUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithMicrosoft();
  }
}
