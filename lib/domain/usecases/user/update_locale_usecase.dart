import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for updating user locale/language
class UpdateLocaleUseCase {
  final UserRepository repository;

  UpdateLocaleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required String locale,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (locale.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Locale cannot be empty'));
    }

    // Validate locale format (e.g., en_US, es_ES)
    if (!_isValidLocale(locale)) {
      return Left(ValidationFailure(
          message: 'Invalid locale format. Expected format: en_US'));
    }

    return await repository.updateLocale(
      userId: userId,
      locale: locale,
    );
  }

  bool _isValidLocale(String locale) {
    // Basic validation for locale format (language_COUNTRY)
    final localeRegex = RegExp(r'^[a-z]{2}_[A-Z]{2}$');
    return localeRegex.hasMatch(locale);
  }
}
