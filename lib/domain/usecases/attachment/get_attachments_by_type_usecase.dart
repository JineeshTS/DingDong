import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attachment_entity.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for retrieving attachments filtered by type
///
/// Allows filtering attachments by type (image, document, pdf, video, audio, etc.)
///
/// Validates:
/// - User ID
/// - Attachment type
/// - Optional pagination parameters
class GetAttachmentsByTypeUseCase {
  final AttachmentRepository repository;

  GetAttachmentsByTypeUseCase(this.repository);

  /// Get attachments filtered by type
  ///
  /// [userId] - ID of the user
  /// [type] - Type of attachment to filter by
  /// [includeDeleted] - Whether to include soft-deleted attachments
  /// [limit] - Maximum number of attachments to return
  /// [offset] - Number of attachments to skip (for pagination)
  Future<Either<Failure, List<AttachmentEntity>>> call({
    required String userId,
    required AttachmentType type,
    bool includeDeleted = false,
    int? limit,
    int? offset,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate pagination parameters
    if (limit != null && limit <= 0) {
      return Left(ValidationFailure(
          message: 'Limit must be greater than 0'));
    }

    if (limit != null && limit > 1000) {
      return Left(ValidationFailure(
          message: 'Limit cannot exceed 1000'));
    }

    if (offset != null && offset < 0) {
      return Left(ValidationFailure(
          message: 'Offset cannot be negative'));
    }

    // Get attachments by type
    final result = await repository.getAttachmentsByType(
      userId: userId,
      type: type,
    );

    // Process results
    return result.fold(
      (failure) => Left(failure),
      (attachments) {
        var filteredAttachments = attachments;

        // Filter out deleted attachments if not included
        if (!includeDeleted) {
          filteredAttachments = filteredAttachments
              .where((attachment) => !attachment.isDeleted)
              .toList();
        }

        // Filter out expired attachments
        filteredAttachments = filteredAttachments
            .where((attachment) => !attachment.isExpired)
            .toList();

        // Sort by upload date (newest first)
        filteredAttachments.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

        // Apply pagination if specified
        if (offset != null) {
          filteredAttachments = filteredAttachments.skip(offset).toList();
        }

        if (limit != null) {
          filteredAttachments = filteredAttachments.take(limit).toList();
        }

        return Right(filteredAttachments);
      },
    );
  }

  /// Get attachments for multiple types
  ///
  /// Useful for getting all images, or all documents, etc.
  Future<Either<Failure, Map<AttachmentType, List<AttachmentEntity>>>>
      callMultipleTypes({
    required String userId,
    required List<AttachmentType> types,
    bool includeDeleted = false,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate types list
    if (types.isEmpty) {
      return Left(ValidationFailure(
          message: 'At least one attachment type must be specified'));
    }

    if (types.length > 10) {
      return Left(ValidationFailure(
          message: 'Cannot query more than 10 types at once'));
    }

    // Get attachments for each type
    final Map<AttachmentType, List<AttachmentEntity>> resultMap = {};

    for (final type in types) {
      final result = await call(
        userId: userId,
        type: type,
        includeDeleted: includeDeleted,
      );

      if (result.isLeft()) {
        return Left(result.fold(
          (failure) => failure,
          (_) => throw Exception('Unexpected error'),
        ));
      }

      resultMap[type] = result.getOrElse(() => []);
    }

    return Right(resultMap);
  }
}
