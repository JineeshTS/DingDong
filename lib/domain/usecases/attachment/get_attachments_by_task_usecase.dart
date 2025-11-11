import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attachment_entity.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for retrieving all attachments for a specific task
///
/// Validates:
/// - Task ID
/// - Optional filtering by attachment type
/// - Option to include or exclude deleted attachments
class GetAttachmentsByTaskUseCase {
  final AttachmentRepository repository;

  GetAttachmentsByTaskUseCase(this.repository);

  /// Get attachments for a task
  ///
  /// [taskId] - ID of the task
  /// [includeDeleted] - Whether to include soft-deleted attachments
  /// [type] - Optional filter by attachment type
  Future<Either<Failure, List<AttachmentEntity>>> call({
    required String taskId,
    bool includeDeleted = false,
    AttachmentType? type,
  }) async {
    // Validate task ID
    if (taskId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    // Get attachments for task
    final result = await repository.getAttachmentsForTask(taskId);

    // Filter results if needed
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

        // Filter by type if specified
        if (type != null) {
          filteredAttachments = filteredAttachments
              .where((attachment) => attachment.type == type)
              .toList();
        }

        // Sort by upload date (newest first)
        filteredAttachments.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

        return Right(filteredAttachments);
      },
    );
  }
}
