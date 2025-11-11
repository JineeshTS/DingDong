import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../../domain/usecases/attachment/batch_delete_attachments_usecase.dart';
import '../../../domain/usecases/attachment/delete_attachment_usecase.dart';
import '../../../domain/usecases/attachment/download_attachment_usecase.dart';
import '../../../domain/usecases/attachment/get_attachments_by_task_usecase.dart';
import '../../../domain/usecases/attachment/get_attachments_by_type_usecase.dart';
import '../../../domain/usecases/attachment/get_total_storage_used_usecase.dart';
import '../../../domain/usecases/attachment/mark_as_downloaded_usecase.dart';
import '../../../domain/usecases/attachment/upload_attachment_usecase.dart';
import 'attachment_notifier.dart';
import 'attachment_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for UploadAttachmentUseCase
///
/// Handles attachment upload with tier-based size limit validation
final uploadAttachmentProvider = Provider.autoDispose<UploadAttachmentUseCase>(
  (ref) => sl<UploadAttachmentUseCase>(),
);

/// Provider for DownloadAttachmentUseCase
///
/// Handles attachment downloads with expiration and deletion checks
final downloadAttachmentProvider =
    Provider.autoDispose<DownloadAttachmentUseCase>(
  (ref) => sl<DownloadAttachmentUseCase>(),
);

/// Provider for DeleteAttachmentUseCase
///
/// Handles soft and permanent deletion of attachments
final deleteAttachmentProvider = Provider.autoDispose<DeleteAttachmentUseCase>(
  (ref) => sl<DeleteAttachmentUseCase>(),
);

/// Provider for GetAttachmentsByTaskUseCase
///
/// Retrieves attachments for a specific task with type filtering
final getAttachmentsByTaskProvider =
    Provider.autoDispose<GetAttachmentsByTaskUseCase>(
  (ref) => sl<GetAttachmentsByTaskUseCase>(),
);

/// Provider for GetAttachmentsByTypeUseCase
///
/// Retrieves attachments filtered by type with pagination support
final getAttachmentsByTypeProvider =
    Provider.autoDispose<GetAttachmentsByTypeUseCase>(
  (ref) => sl<GetAttachmentsByTypeUseCase>(),
);

/// Provider for GetTotalStorageUsedUseCase
///
/// Calculates storage usage and quota based on subscription tier
final getTotalStorageUsedProvider =
    Provider.autoDispose<GetTotalStorageUsedUseCase>(
  (ref) => sl<GetTotalStorageUsedUseCase>(),
);

/// Provider for BatchDeleteAttachmentsUseCase
///
/// Handles batch deletion of up to 50 attachments at once
final batchDeleteAttachmentsProvider =
    Provider.autoDispose<BatchDeleteAttachmentsUseCase>(
  (ref) => sl<BatchDeleteAttachmentsUseCase>(),
);

/// Provider for MarkAsDownloadedUseCase
///
/// Tracks attachment downloads and download statistics per device
final markAsDownloadedProvider = Provider.autoDispose<MarkAsDownloadedUseCase>(
  (ref) => sl<MarkAsDownloadedUseCase>(),
);

// ============================================================================
// Attachment State Notifier Provider
// ============================================================================

/// Main attachment state notifier provider
///
/// This is the primary provider for attachment state management.
/// It should NOT be auto-disposed as we want to maintain attachment
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final attachmentState = ref.watch(attachmentNotifierProvider);
/// final attachmentNotifier = ref.read(attachmentNotifierProvider.notifier);
///
/// // Get task attachments
/// ref.listen(attachmentNotifierProvider, (previous, next) {
///   if (next.taskAttachments.isNotEmpty) {
///     // Handle task attachments update
///   }
/// });
///
/// // Perform attachment actions
/// await attachmentNotifier.uploadAttachment(
///   userId: userId,
///   taskId: taskId,
///   fileName: 'document.pdf',
///   fileData: fileBytes,
///   mimeType: 'application/pdf',
/// );
/// await attachmentNotifier.deleteAttachment(
///   attachmentId: attachmentId,
///   userId: userId,
/// );
/// ```
final attachmentNotifierProvider =
    StateNotifierProvider<AttachmentNotifier, AttachmentState>(
  (ref) {
    return AttachmentNotifier(
      uploadAttachmentUseCase: ref.read(uploadAttachmentProvider),
      downloadAttachmentUseCase: ref.read(downloadAttachmentProvider),
      deleteAttachmentUseCase: ref.read(deleteAttachmentProvider),
      getAttachmentsByTaskUseCase: ref.read(getAttachmentsByTaskProvider),
      getAttachmentsByTypeUseCase: ref.read(getAttachmentsByTypeProvider),
      getTotalStorageUsedUseCase: ref.read(getTotalStorageUsedProvider),
      batchDeleteAttachmentsUseCase: ref.read(batchDeleteAttachmentsProvider),
      markAsDownloadedUseCase: ref.read(markAsDownloadedProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Attachment Lists
// ============================================================================

/// Provider that exposes all attachments
///
/// Returns list of all attachments in the system
///
/// Usage:
/// ```dart
/// final allAttachments = ref.watch(allAttachmentsProvider);
/// ListView.builder(
///   itemCount: allAttachments.length,
///   itemBuilder: (context, index) => AttachmentTile(
///     attachment: allAttachments[index],
///   ),
/// );
/// ```
final allAttachmentsProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.allAttachments;
  },
);

/// Provider that exposes attachments for the current task
///
/// Returns list of attachments for the currently viewed task
///
/// Usage:
/// ```dart
/// final taskAttachments = ref.watch(taskAttachmentsProvider);
/// ```
final taskAttachmentsProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments;
  },
);

/// Provider that exposes type-filtered attachments
///
/// Returns list of attachments filtered by current type filter
///
/// Usage:
/// ```dart
/// final imageAttachments = ref.watch(typeFilteredAttachmentsProvider);
/// ```
final typeFilteredAttachmentsProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.typeFilteredAttachments;
  },
);

/// Provider that exposes the currently selected attachment
///
/// Returns the attachment selected for detail view or null
///
/// Usage:
/// ```dart
/// final selectedAttachment = ref.watch(selectedAttachmentProvider);
/// if (selectedAttachment != null) {
///   // Show detail view
/// }
/// ```
final selectedAttachmentProvider = Provider<AttachmentEntity?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.selectedAttachment;
  },
);

// ============================================================================
// Derived State Providers - Storage and Quota
// ============================================================================

/// Provider that exposes storage information
///
/// Returns storage usage and quota details for the current user
///
/// Usage:
/// ```dart
/// final storageInfo = ref.watch(storageInfoProvider);
/// if (storageInfo != null) {
///   Text('Used: ${storageInfo.totalStorageUsedFormatted}');
///   Text('Limit: ${storageInfo.storageLimitFormatted}');
/// }
/// ```
final storageInfoProvider = Provider<StorageInfo?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.storageInfo;
  },
);

/// Provider that exposes storage usage percentage
///
/// Returns percentage of storage quota used (0-100)
///
/// Usage:
/// ```dart
/// final usagePercent = ref.watch(storageUsagePercentageProvider);
/// LinearProgressIndicator(value: usagePercent / 100);
/// ```
final storageUsagePercentageProvider = Provider<double>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.storageInfo?.usagePercentage ?? 0.0;
  },
);

/// Provider that checks if storage is nearly full
///
/// Returns true if usage is >90%
///
/// Usage:
/// ```dart
/// final isNearlyFull = ref.watch(isStorageNearlyFullProvider);
/// if (isNearlyFull) {
///   showWarningDialog();
/// }
/// ```
final isStorageNearlyFullProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isStorageNearlyFull;
  },
);

/// Provider that checks if storage is completely full
///
/// Returns true if usage is >95%
final isStorageFullProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isStorageFull;
  },
);

/// Provider that exposes available storage
///
/// Returns available storage in bytes
final availableStorageProvider = Provider<int>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.storageInfo?.availableStorage ?? 0;
  },
);

/// Provider that exposes available storage percentage
///
/// Returns percentage of storage quota available (0-100)
final storageAvailablePercentageProvider = Provider<double>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.storageAvailablePercentage;
  },
);

// ============================================================================
// Derived State Providers - Download Statistics
// ============================================================================

/// Provider that exposes download statistics for selected attachment
///
/// Returns download count, last downloaded time, and device information
///
/// Usage:
/// ```dart
/// final downloadStats = ref.watch(downloadStatsProvider);
/// if (downloadStats != null) {
///   Text('Downloaded ${downloadStats.downloadCount} times');
/// }
/// ```
final downloadStatsProvider = Provider<DownloadStats?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.selectedAttachmentDownloadStats;
  },
);

// ============================================================================
// Derived State Providers - Count Providers
// ============================================================================

/// Provider that exposes total count of all attachments
///
/// Returns number of all attachments
///
/// Usage:
/// ```dart
/// final count = ref.watch(allAttachmentCountProvider);
/// Text('Total: $count');
/// ```
final allAttachmentCountProvider = Provider<int>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.allAttachmentCount;
  },
);

/// Provider that exposes count of task attachments
///
/// Returns number of attachments for current task
///
/// Usage:
/// ```dart
/// final count = ref.watch(taskAttachmentCountProvider);
/// ```
final taskAttachmentCountProvider = Provider<int>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachmentCount;
  },
);

/// Provider that exposes count of type-filtered attachments
///
/// Returns number of attachments matching current type filter
final typeFilteredCountProvider = Provider<int>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.typeFilteredCount;
  },
);

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider that exposes overall loading state
///
/// Returns true if any attachment operation is loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isLoadingAttachmentsProvider);
/// if (isLoading) {
///   return CircularProgressIndicator();
/// }
/// ```
final isLoadingAttachmentsProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isLoadingAttachments;
  },
);

/// Provider that exposes task attachments loading state
///
/// Returns true if task attachments are being loaded
final isLoadingTaskAttachmentsProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isLoadingTaskAttachments;
  },
);

/// Provider that exposes type-filtered attachments loading state
///
/// Returns true if type-filtered attachments are being loaded
final isLoadingTypeFilteredProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isLoadingTypeFiltered;
  },
);

/// Provider that exposes storage info loading state
///
/// Returns true if storage information is being fetched
final isLoadingStorageProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isLoadingStorage;
  },
);

/// Provider that exposes upload loading state
///
/// Returns true if file is currently uploading
///
/// Usage:
/// ```dart
/// final isUploading = ref.watch(isUploadingProvider);
/// final progress = ref.watch(uploadProgressProvider);
/// if (isUploading) {
///   return ProgressBar(progress: progress);
/// }
/// ```
final isUploadingProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isUploading;
  },
);

/// Provider that exposes download loading state
///
/// Returns true if file is currently downloading
final isDownloadingProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isDownloading;
  },
);

/// Provider that exposes delete operation state
///
/// Returns true if attachment is being deleted
final isDeletingProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isDeleting;
  },
);

/// Provider that exposes batch delete operation state
///
/// Returns true if batch delete is in progress
final isBatchDeletingProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isBatchDeleting;
  },
);

/// Provider that exposes any loading state
///
/// Returns true if any operation is loading
final isAnyLoadingProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isAnyLoading;
  },
);

/// Provider that exposes any operation in progress state
///
/// Returns true if any operation (upload, delete, etc.) is in progress
///
/// Usage:
/// ```dart
/// final isOperating = ref.watch(isAnyOperationInProgressProvider);
/// if (isOperating) {
///   // Disable user interactions
/// }
/// ```
final isAnyOperationInProgressProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.isAnyOperationInProgress;
  },
);

// ============================================================================
// Derived State Providers - Upload Progress
// ============================================================================

/// Provider that exposes upload progress
///
/// Returns upload progress as percentage (0-100)
///
/// Usage:
/// ```dart
/// final progress = ref.watch(uploadProgressProvider);
/// LinearProgressIndicator(value: progress / 100);
/// ```
final uploadProgressProvider = Provider<double>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.uploadProgress;
  },
);

/// Provider that exposes uploading file name
///
/// Returns name of file currently being uploaded or null
///
/// Usage:
/// ```dart
/// final fileName = ref.watch(uploadingFileNameProvider);
/// if (fileName != null) {
///   Text('Uploading: $fileName');
/// }
/// ```
final uploadingFileNameProvider = Provider<String?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.uploadingFileName;
  },
);

// ============================================================================
// Derived State Providers - Batch Delete Result
// ============================================================================

/// Provider that exposes last batch delete result
///
/// Returns details of the last batch delete operation
///
/// Usage:
/// ```dart
/// final result = ref.watch(lastBatchDeleteResultProvider);
/// if (result != null && result.isFullSuccess) {
///   showSnackBar('All attachments deleted successfully');
/// }
/// ```
final lastBatchDeleteResultProvider = Provider<BatchDeleteResult?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.lastBatchDeleteResult;
  },
);

// ============================================================================
// Derived State Providers - Error States
// ============================================================================

/// Provider that exposes general error
///
/// Returns the current error or null if no error
///
/// Usage:
/// ```dart
/// final error = ref.watch(attachmentErrorProvider);
/// if (error != null) {
///   showErrorDialog(error.message);
/// }
/// ```
final attachmentErrorProvider = Provider(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.error;
  },
);

/// Provider that exposes upload error
///
/// Returns upload-specific error or null
final uploadErrorProvider = Provider(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.uploadError;
  },
);

/// Provider that exposes download error
///
/// Returns download-specific error or null
final downloadErrorProvider = Provider(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.downloadError;
  },
);

/// Provider that exposes delete error
///
/// Returns delete-specific error or null
final deleteErrorProvider = Provider(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.deleteError;
  },
);

/// Provider that exposes batch delete error
///
/// Returns batch delete-specific error or null
final batchDeleteErrorProvider = Provider(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.batchDeleteError;
  },
);

/// Provider that checks if any error exists
///
/// Returns true if any error state is set
///
/// Usage:
/// ```dart
/// final hasError = ref.watch(hasAnyErrorProvider);
/// if (hasError) {
///   // Show error indicator
/// }
/// ```
final hasAnyErrorProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.hasAnyError;
  },
);

// ============================================================================
// Derived State Providers - Filters
// ============================================================================

/// Provider that exposes current attachment type filter
///
/// Returns the currently active type filter or null if no filter
///
/// Usage:
/// ```dart
/// final typeFilter = ref.watch(currentTypeFilterProvider);
/// ```
final currentTypeFilterProvider = Provider<AttachmentType?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.currentTypeFilter;
  },
);

/// Provider that exposes current task ID filter
///
/// Returns the currently active task ID filter or null
final currentTaskIdFilterProvider = Provider<String?>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.currentTaskId;
  },
);

// ============================================================================
// Derived Computed Providers
// ============================================================================

/// Provider that returns images only from task attachments
///
/// Usage:
/// ```dart
/// final images = ref.watch(taskImagesProvider);
/// ```
final taskImagesProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments
        .where((a) => a.type == AttachmentType.image)
        .toList();
  },
);

/// Provider that returns documents only from task attachments
///
/// Usage:
/// ```dart
/// final documents = ref.watch(taskDocumentsProvider);
/// ```
final taskDocumentsProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments
        .where((a) => a.type == AttachmentType.document)
        .toList();
  },
);

/// Provider that returns videos only from task attachments
final taskVideosProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments
        .where((a) => a.type == AttachmentType.video)
        .toList();
  },
);

/// Provider that returns audio files only from task attachments
final taskAudioProvider = Provider<List<AttachmentEntity>>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments
        .where((a) => a.type == AttachmentType.audio)
        .toList();
  },
);

/// Provider that calculates total storage used by task attachments
///
/// Usage:
/// ```dart
/// final taskStorageUsed = ref.watch(taskStorageUsedProvider);
/// Text('Task: ${taskStorageUsed.fileSizeFormatted}');
/// ```
final taskStorageUsedProvider = Provider<int>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.taskAttachments
        .fold(0, (sum, a) => sum + a.fileSizeBytes);
  },
);

/// Provider that checks if attachment needs refresh
///
/// Usage:
/// ```dart
/// final needsRefresh = ref.watch(attachmentNeedsRefreshProvider);
/// ```
final attachmentNeedsRefreshProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.needsRefreshAttachments;
  },
);

/// Provider that checks if storage needs refresh
final storageNeedsRefreshProvider = Provider<bool>(
  (ref) {
    final state = ref.watch(attachmentNotifierProvider);
    return state.needsRefreshStorage;
  },
);
