import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../../domain/usecases/attachment/batch_delete_attachments_usecase.dart';
import '../../../domain/usecases/attachment/delete_attachment_usecase.dart';
import '../../../domain/usecases/attachment/download_attachment_usecase.dart';
import '../../../domain/usecases/attachment/get_attachments_by_task_usecase.dart';
import '../../../domain/usecases/attachment/get_attachments_by_type_usecase.dart';
import '../../../domain/usecases/attachment/get_total_storage_used_usecase.dart';
import '../../../domain/usecases/attachment/mark_as_downloaded_usecase.dart';
import '../../../domain/usecases/attachment/upload_attachment_usecase.dart';
import 'attachment_state.dart';

/// StateNotifier for managing attachment state
///
/// Handles all attachment-related operations including:
/// - Uploading attachments with progress tracking
/// - Downloading attachments
/// - Deleting attachments (soft and permanent)
/// - Batch deletion of multiple attachments
/// - Retrieving attachments by task
/// - Filtering attachments by type
/// - Managing storage quota and statistics
/// - Tracking download activity
///
/// This notifier integrates with all 8 attachment use cases
/// and manages the AttachmentState throughout the application lifecycle.
class AttachmentNotifier extends StateNotifier<AttachmentState> {
  // Use cases
  final UploadAttachmentUseCase _uploadAttachmentUseCase;
  final DownloadAttachmentUseCase _downloadAttachmentUseCase;
  final DeleteAttachmentUseCase _deleteAttachmentUseCase;
  final GetAttachmentsByTaskUseCase _getAttachmentsByTaskUseCase;
  final GetAttachmentsByTypeUseCase _getAttachmentsByTypeUseCase;
  final GetTotalStorageUsedUseCase _getTotalStorageUsedUseCase;
  final BatchDeleteAttachmentsUseCase _batchDeleteAttachmentsUseCase;
  final MarkAsDownloadedUseCase _markAsDownloadedUseCase;

  AttachmentNotifier({
    required UploadAttachmentUseCase uploadAttachmentUseCase,
    required DownloadAttachmentUseCase downloadAttachmentUseCase,
    required DeleteAttachmentUseCase deleteAttachmentUseCase,
    required GetAttachmentsByTaskUseCase getAttachmentsByTaskUseCase,
    required GetAttachmentsByTypeUseCase getAttachmentsByTypeUseCase,
    required GetTotalStorageUsedUseCase getTotalStorageUsedUseCase,
    required BatchDeleteAttachmentsUseCase batchDeleteAttachmentsUseCase,
    required MarkAsDownloadedUseCase markAsDownloadedUseCase,
  })  : _uploadAttachmentUseCase = uploadAttachmentUseCase,
        _downloadAttachmentUseCase = downloadAttachmentUseCase,
        _deleteAttachmentUseCase = deleteAttachmentUseCase,
        _getAttachmentsByTaskUseCase = getAttachmentsByTaskUseCase,
        _getAttachmentsByTypeUseCase = getAttachmentsByTypeUseCase,
        _getTotalStorageUsedUseCase = getTotalStorageUsedUseCase,
        _batchDeleteAttachmentsUseCase = batchDeleteAttachmentsUseCase,
        _markAsDownloadedUseCase = markAsDownloadedUseCase,
        super(const AttachmentState());

  /// Upload an attachment with tier-based size validation
  ///
  /// Parameters:
  /// - [userId]: User ID (owner of the attachment)
  /// - [taskId]: Task ID (optional, required if commentId not provided)
  /// - [commentId]: Comment ID (optional, required if taskId not provided)
  /// - [fileName]: Name of the file being uploaded
  /// - [fileData]: File contents as Uint8List
  /// - [mimeType]: MIME type of the file
  /// - [onProgress]: Optional callback for upload progress (0-100)
  Future<void> uploadAttachment({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
    Function(double)? onProgress,
  }) async {
    state = state.copyWith(
      isUploading: true,
      uploadingFileName: fileName,
      uploadProgress: 0,
      uploadError: null,
      totalFileSizeBytes: fileData.length,
    );

    // Simulate progress updates if callback provided
    if (onProgress != null) {
      for (int i = 0; i < 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        state = state.copyWith(uploadProgress: i.toDouble());
        onProgress(i.toDouble());
      }
    }

    final result = await _uploadAttachmentUseCase(
      userId: userId,
      taskId: taskId,
      commentId: commentId,
      fileName: fileName,
      fileData: fileData,
      mimeType: mimeType,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isUploading: false,
          uploadError: failure,
          uploadProgress: 0,
          uploadingFileName: null,
        );
      },
      (attachment) {
        // Add uploaded attachment to list
        final updatedAttachments = [...state.allAttachments, attachment];

        // Update task attachments if task ID was provided
        List<AttachmentEntity> updatedTaskAttachments = state.taskAttachments;
        if (taskId != null && taskId == state.currentTaskId) {
          updatedTaskAttachments = [...state.taskAttachments, attachment];
        }

        state = state.copyWith(
          isUploading: false,
          uploadError: null,
          uploadProgress: 100,
          uploadingFileName: null,
          allAttachments: updatedAttachments,
          taskAttachments: updatedTaskAttachments,
          lastRefreshAttachments: DateTime.now(),
          totalFileSizeBytes: null,
        );

        // Refresh storage info after successful upload
        refreshStorageInfo(userId);
      },
    );
  }

  /// Download an attachment
  ///
  /// Parameters:
  /// - [attachmentId]: ID of the attachment to download
  /// - [onProgress]: Optional callback for download progress (0-100)
  ///
  /// Returns: File data as Uint8List
  Future<Uint8List?> downloadAttachment({
    required String attachmentId,
    Function(double)? onProgress,
  }) async {
    state = state.copyWith(
      isDownloading: true,
      downloadError: null,
    );

    // Simulate progress updates if callback provided
    if (onProgress != null) {
      for (int i = 0; i < 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        onProgress(i.toDouble());
      }
    }

    final result = await _downloadAttachmentUseCase(attachmentId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDownloading: false,
          downloadError: failure,
        );
        return null;
      },
      (fileData) {
        state = state.copyWith(
          isDownloading: false,
          downloadError: null,
        );
        return fileData;
      },
    );
  }

  /// Delete an attachment
  ///
  /// Parameters:
  /// - [attachmentId]: ID of the attachment to delete
  /// - [userId]: User ID (must be attachment owner)
  /// - [permanent]: If true, permanently delete; otherwise soft delete
  Future<void> deleteAttachment({
    required String attachmentId,
    required String userId,
    bool permanent = false,
  }) async {
    state = state.copyWith(
      isDeleting: true,
      deleteError: null,
    );

    final result = await _deleteAttachmentUseCase(
      attachmentId: attachmentId,
      userId: userId,
      permanent: permanent,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          deleteError: failure,
        );
      },
      (_) {
        // Remove deleted attachment from lists
        final updatedAllAttachments = state.allAttachments
            .where((a) => a.id != attachmentId)
            .toList();

        final updatedTaskAttachments = state.taskAttachments
            .where((a) => a.id != attachmentId)
            .toList();

        final updatedTypeFiltered = state.typeFilteredAttachments
            .where((a) => a.id != attachmentId)
            .toList();

        // Clear selected attachment if it was the deleted one
        AttachmentEntity? updatedSelected = state.selectedAttachment;
        if (state.selectedAttachment?.id == attachmentId) {
          updatedSelected = null;
        }

        state = state.copyWith(
          isDeleting: false,
          deleteError: null,
          allAttachments: updatedAllAttachments,
          taskAttachments: updatedTaskAttachments,
          typeFilteredAttachments: updatedTypeFiltered,
          selectedAttachment: updatedSelected,
          lastRefreshAttachments: DateTime.now(),
        );

        // Refresh storage info after deletion
        if (state.storageInfo != null) {
          refreshStorageInfo(state.storageInfo!.userId);
        }
      },
    );
  }

  /// Get attachments for a specific task
  ///
  /// Parameters:
  /// - [taskId]: ID of the task
  /// - [includeDeleted]: Whether to include soft-deleted attachments
  /// - [type]: Optional filter by attachment type
  Future<void> getAttachmentsByTask({
    required String taskId,
    bool includeDeleted = false,
    AttachmentType? type,
  }) async {
    state = state.copyWith(
      isLoadingTaskAttachments: true,
      currentTaskId: taskId,
    );

    final result = await _getAttachmentsByTaskUseCase(
      taskId: taskId,
      includeDeleted: includeDeleted,
      type: type,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingTaskAttachments: false,
          error: failure,
        );
      },
      (attachments) {
        state = state.copyWith(
          isLoadingTaskAttachments: false,
          taskAttachments: attachments,
          lastRefreshAttachments: DateTime.now(),
        );
      },
    );
  }

  /// Get attachments filtered by type
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [type]: Attachment type to filter by
  /// - [includeDeleted]: Whether to include soft-deleted attachments
  /// - [limit]: Maximum number of attachments to return
  /// - [offset]: Number of attachments to skip (pagination)
  Future<void> getAttachmentsByType({
    required String userId,
    required AttachmentType type,
    bool includeDeleted = false,
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(
      isLoadingTypeFiltered: true,
      currentTypeFilter: type,
    );

    final result = await _getAttachmentsByTypeUseCase(
      userId: userId,
      type: type,
      includeDeleted: includeDeleted,
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingTypeFiltered: false,
          error: failure,
        );
      },
      (attachments) {
        state = state.copyWith(
          isLoadingTypeFiltered: false,
          typeFilteredAttachments: attachments,
          lastRefreshAttachments: DateTime.now(),
        );
      },
    );
  }

  /// Get total storage used and storage quota information
  ///
  /// Parameters:
  /// - [userId]: User ID
  Future<void> getStorageInfo({required String userId}) async {
    state = state.copyWith(
      isLoadingStorage: true,
      storageError: null,
    );

    final result = await _getTotalStorageUsedUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingStorage: false,
          storageError: failure,
        );
      },
      (storageInfo) {
        state = state.copyWith(
          isLoadingStorage: false,
          storageInfo: storageInfo,
          lastRefreshStorage: DateTime.now(),
        );
      },
    );
  }

  /// Batch delete multiple attachments
  ///
  /// Parameters:
  /// - [attachmentIds]: List of attachment IDs to delete (max 50)
  /// - [userId]: User ID (must own all attachments)
  /// - [permanent]: If true, permanently delete; otherwise soft delete
  Future<void> batchDeleteAttachments({
    required List<String> attachmentIds,
    required String userId,
    bool permanent = false,
  }) async {
    state = state.copyWith(
      isBatchDeleting: true,
      batchDeleteError: null,
    );

    final result = await _batchDeleteAttachmentsUseCase(
      attachmentIds: attachmentIds,
      userId: userId,
      permanent: permanent,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isBatchDeleting: false,
          batchDeleteError: failure,
        );
      },
      (batchDeleteResult) {
        // Remove successfully deleted attachments from lists
        final updatedAllAttachments = state.allAttachments
            .where((a) => !batchDeleteResult.successfulIds.contains(a.id))
            .toList();

        final updatedTaskAttachments = state.taskAttachments
            .where((a) => !batchDeleteResult.successfulIds.contains(a.id))
            .toList();

        final updatedTypeFiltered = state.typeFilteredAttachments
            .where((a) => !batchDeleteResult.successfulIds.contains(a.id))
            .toList();

        state = state.copyWith(
          isBatchDeleting: false,
          batchDeleteError: null,
          lastBatchDeleteResult: batchDeleteResult,
          allAttachments: updatedAllAttachments,
          taskAttachments: updatedTaskAttachments,
          typeFilteredAttachments: updatedTypeFiltered,
          lastRefreshAttachments: DateTime.now(),
        );

        // Refresh storage info after batch deletion
        if (state.storageInfo != null) {
          refreshStorageInfo(state.storageInfo!.userId);
        }
      },
    );
  }

  /// Mark an attachment as downloaded and track download statistics
  ///
  /// Parameters:
  /// - [attachmentId]: ID of the attachment
  /// - [userId]: User ID (for tracking)
  /// - [deviceId]: Optional device identifier for tracking downloads per device
  Future<void> markAsDownloaded({
    required String attachmentId,
    required String userId,
    String? deviceId,
  }) async {
    state = state.copyWith(
      isMarkingAsDownloaded: true,
    );

    final result = await _markAsDownloadedUseCase(
      attachmentId: attachmentId,
      userId: userId,
      deviceId: deviceId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isMarkingAsDownloaded: false,
          error: failure,
        );
      },
      (updatedAttachment) {
        // Update attachment in all lists with download tracking
        final updateList = (List<AttachmentEntity> list) => list
            .map((a) => a.id == updatedAttachment.id ? updatedAttachment : a)
            .toList();

        state = state.copyWith(
          isMarkingAsDownloaded: false,
          allAttachments: updateList(state.allAttachments),
          taskAttachments: updateList(state.taskAttachments),
          typeFilteredAttachments: updateList(state.typeFilteredAttachments),
          selectedAttachment: state.selectedAttachment?.id == updatedAttachment.id
              ? updatedAttachment
              : state.selectedAttachment,
        );

        // Get download stats for the attachment
        getDownloadStats(attachmentId);
      },
    );
  }

  /// Get download statistics for an attachment
  ///
  /// Parameters:
  /// - [attachmentId]: ID of the attachment
  Future<void> getDownloadStats(String attachmentId) async {
    state = state.copyWith(
      isLoadingDownloadStats: true,
      downloadStatsError: null,
    );

    final result = await _markAsDownloadedUseCase.getDownloadStats(attachmentId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingDownloadStats: false,
          downloadStatsError: failure,
        );
      },
      (downloadStats) {
        state = state.copyWith(
          isLoadingDownloadStats: false,
          selectedAttachmentDownloadStats: downloadStats,
        );
      },
    );
  }

  /// Refresh storage information
  ///
  /// Parameters:
  /// - [userId]: User ID
  Future<void> refreshStorageInfo(String userId) async {
    if (!state.needsRefreshStorage) return;

    await getStorageInfo(userId: userId);
  }

  /// Refresh all attachment data
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [taskId]: Optional task ID to refresh task attachments
  Future<void> refreshAllAttachments({
    required String userId,
    String? taskId,
  }) async {
    // Refresh storage info
    await refreshStorageInfo(userId);

    // Refresh task attachments if provided
    if (taskId != null) {
      await getAttachmentsByTask(taskId: taskId);
    }
  }

  /// Select an attachment for detail view
  ///
  /// Parameters:
  /// - [attachment]: The attachment to select (null to deselect)
  void selectAttachment(AttachmentEntity? attachment) {
    state = state.copyWith(
      selectedAttachment: attachment,
    );

    // Load download stats if attachment selected
    if (attachment != null) {
      getDownloadStats(attachment.id);
    }
  }

  /// Clear upload error
  void clearUploadError() {
    state = state.copyWith(uploadError: null);
  }

  /// Clear download error
  void clearDownloadError() {
    state = state.copyWith(downloadError: null);
  }

  /// Clear delete error
  void clearDeleteError() {
    state = state.copyWith(deleteError: null);
  }

  /// Clear batch delete error
  void clearBatchDeleteError() {
    state = state.copyWith(batchDeleteError: null);
  }

  /// Clear all errors
  void clearAllErrors() {
    state = state.copyWith(
      error: null,
      uploadError: null,
      downloadError: null,
      deleteError: null,
      batchDeleteError: null,
      storageError: null,
      downloadStatsError: null,
    );
  }

  /// Reset attachment state to initial
  void reset() {
    state = const AttachmentState();
  }
}
