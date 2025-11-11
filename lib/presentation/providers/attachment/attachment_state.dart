import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../../domain/usecases/attachment/batch_delete_attachments_usecase.dart';
import '../../../domain/usecases/attachment/get_total_storage_used_usecase.dart';
import '../../../domain/usecases/attachment/mark_as_downloaded_usecase.dart';

part 'attachment_state.freezed.dart';

/// Attachment management state for the application
///
/// Manages attachment operations, lists, and storage tracking with support for
/// multiple attachment types and batch operations.
/// This state is used by [AttachmentNotifier] to track all attachment-related operations.
///
/// Features:
/// - Attachment upload with progress tracking
/// - Attachment retrieval by task, type, and other filters
/// - Batch operations (delete multiple attachments)
/// - Storage quota management with tier-based limits
/// - Download tracking and statistics
/// - File type filtering and organization
/// - Soft delete support with optional permanent deletion
@freezed
class AttachmentState with _$AttachmentState {
  const factory AttachmentState({
    /// All attachments (paginated for future expansion)
    @Default([]) List<AttachmentEntity> allAttachments,

    /// Attachments for currently viewed task
    @Default([]) List<AttachmentEntity> taskAttachments,

    /// Attachments filtered by type (images, documents, etc.)
    @Default([]) List<AttachmentEntity> typeFilteredAttachments,

    /// Currently selected attachment for detail view
    AttachmentEntity? selectedAttachment,

    /// Current attachment type filter
    AttachmentType? currentTypeFilter,

    /// Current task ID filter
    String? currentTaskId,

    /// Upload progress (0-100)
    @Default(0) double uploadProgress,

    /// Currently uploading file name
    String? uploadingFileName,

    /// Storage information for current user
    StorageInfo? storageInfo,

    /// Download statistics for selected attachment
    DownloadStats? selectedAttachmentDownloadStats,

    /// Batch delete operation result
    BatchDeleteResult? lastBatchDeleteResult,

    /// Loading states
    @Default(false) bool isLoadingAttachments,
    @Default(false) bool isLoadingTaskAttachments,
    @Default(false) bool isLoadingTypeFiltered,
    @Default(false) bool isLoadingStorage,
    @Default(false) bool isLoadingDownloadStats,
    @Default(false) bool isUploading,
    @Default(false) bool isDownloading,
    @Default(false) bool isDeleting,
    @Default(false) bool isBatchDeleting,
    @Default(false) bool isMarkingAsDownloaded,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,

    /// Error states
    Failure? error,
    Failure? uploadError,
    Failure? downloadError,
    Failure? deleteError,
    Failure? batchDeleteError,
    Failure? storageError,
    Failure? downloadStatsError,

    /// Last refresh timestamps
    DateTime? lastRefreshAttachments,
    DateTime? lastRefreshStorage,

    /// Upload metadata
    int? totalFileSizeBytes,
  }) = _AttachmentState;

  const AttachmentState._();

  /// Check if any loading operation is in progress
  bool get isAnyLoading =>
      isLoadingAttachments ||
      isLoadingTaskAttachments ||
      isLoadingTypeFiltered ||
      isLoadingStorage ||
      isLoadingDownloadStats ||
      isUploading ||
      isDownloading ||
      isDeleting ||
      isBatchDeleting ||
      isMarkingAsDownloaded ||
      isCreating ||
      isUpdating;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isUploading ||
      isDownloading ||
      isDeleting ||
      isBatchDeleting ||
      isMarkingAsDownloaded ||
      isCreating ||
      isUpdating;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      uploadError != null ||
      downloadError != null ||
      deleteError != null ||
      batchDeleteError != null ||
      storageError != null ||
      downloadStatsError != null;

  /// Get total count of all attachments
  int get allAttachmentCount => allAttachments.length;

  /// Get total count of task attachments
  int get taskAttachmentCount => taskAttachments.length;

  /// Get total count of type-filtered attachments
  int get typeFilteredCount => typeFilteredAttachments.length;

  /// Check if storage quota is available (not 100% used)
  bool get hasStorageAvailable =>
      storageInfo != null && storageInfo!.availableStorage > 0;

  /// Check if storage is nearly full (>90%)
  bool get isStorageNearlyFull => storageInfo?.isNearlyFull ?? false;

  /// Check if storage is completely full (>95%)
  bool get isStorageFull => storageInfo?.isFull ?? false;

  /// Get available storage percentage
  double get storageAvailablePercentage {
    if (storageInfo == null) return 100.0;
    return (100.0 - storageInfo!.usagePercentage).clamp(0, 100);
  }

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if attachments need refresh
  bool get needsRefreshAttachments => needsRefresh(lastRefreshAttachments);

  /// Check if storage info needs refresh
  bool get needsRefreshStorage => needsRefresh(lastRefreshStorage);

  /// Get upload speed in KB/s (if uploading)
  double? get uploadSpeedKbps {
    if (!isUploading || totalFileSizeBytes == null || uploadProgress <= 0) {
      return null;
    }
    // This would need to track upload time separately in actual implementation
    return null;
  }
}
