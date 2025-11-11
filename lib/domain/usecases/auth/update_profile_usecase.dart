import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for updating user profile
///
/// Encapsulates the business logic for profile updates
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  /// Execute the profile update operation
  ///
  /// Parameters:
  /// - [displayName]: New display name (optional)
  /// - [photoUrl]: New photo URL (optional)
  ///
  /// Returns:
  /// - Right(UserEntity): Updated user entity
  /// - Left(Failure): Update failure
  Future<Either<Failure, UserEntity>> call({
    String? displayName,
    String? photoUrl,
  }) async {
    // Validate display name if provided
    if (displayName != null) {
      if (displayName.trim().isEmpty) {
        return Left(
            ValidationFailure(message: 'Display name cannot be empty'));
      }

      if (displayName.trim().length < 2) {
        return Left(ValidationFailure(
            message: 'Display name must be at least 2 characters'));
      }

      if (displayName.trim().length > 50) {
        return Left(ValidationFailure(
            message: 'Display name cannot exceed 50 characters'));
      }
    }

    // Validate photo URL if provided
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (!_isValidUrl(photoUrl)) {
        return Left(ValidationFailure(message: 'Invalid photo URL format'));
      }
    }

    return await repository.updateProfile(
      displayName: displayName?.trim(),
      photoUrl: photoUrl,
    );
  }

  /// Validate URL format
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
