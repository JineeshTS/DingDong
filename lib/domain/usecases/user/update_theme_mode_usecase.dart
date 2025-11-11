import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for updating user theme mode
class UpdateThemeModeUseCase {
  final UserRepository repository;

  UpdateThemeModeUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required String themeMode,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate theme mode
    final validModes = ['light', 'dark', 'system'];
    if (!validModes.contains(themeMode.toLowerCase())) {
      return Left(ValidationFailure(
          message: 'Invalid theme mode. Must be: light, dark, or system'));
    }

    return await repository.updateThemeMode(
      userId: userId,
      themeMode: themeMode,
    );
  }
}
