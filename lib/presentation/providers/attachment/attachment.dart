/// Attachment providers module
///
/// Exports all attachment-related providers, state, and notifiers.
///
/// This module provides comprehensive attachment management functionality including:
/// - Upload attachments with tier-based size limits and progress tracking
/// - Download attachments with expiration and deletion checks
/// - Delete attachments (soft and permanent deletion)
/// - Batch delete multiple attachments (up to 50 at a time)
/// - Retrieve attachments by task with optional type filtering
/// - Filter attachments by type (images, documents, videos, audio, archives, etc.)
/// - Manage storage quota with tier-based limits (free: 1GB, plus: 10GB, premium: 100GB)
/// - Track download activity and statistics per device
/// - Real-time storage usage and quota monitoring
/// - Pagination support for large attachment collections
/// - Real-time attachment updates
/// - Derived providers for common queries
///
/// ## Architecture
///
/// The attachment providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`AttachmentState`)
/// - **Notifier**: Business logic and state updates (`AttachmentNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (8 attachment use cases)
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/attachment/attachment.dart';
///
/// class AttachmentListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch task attachments
///     final taskAttachments = ref.watch(taskAttachmentsProvider);
///     final isLoading = ref.watch(isLoadingTaskAttachmentsProvider);
///
///     // Get notifier for actions
///     final attachmentNotifier = ref.read(attachmentNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         if (isLoading)
///           CircularProgressIndicator()
///         else
///           ListView.builder(
///             itemCount: taskAttachments.length,
///             itemBuilder: (context, index) {
///               final attachment = taskAttachments[index];
///               return AttachmentTile(
///                 attachment: attachment,
///                 onDownload: () => attachmentNotifier.downloadAttachment(
///                   attachmentId: attachment.id,
///                 ),
///                 onDelete: () => attachmentNotifier.deleteAttachment(
///                   attachmentId: attachment.id,
///                   userId: userId,
///                 ),
///               );
///             },
///           ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `attachmentNotifierProvider` - Main attachment state and notifier
///
/// ### Attachment List Providers
/// - `allAttachmentsProvider` - All attachments
/// - `taskAttachmentsProvider` - Attachments for current task
/// - `typeFilteredAttachmentsProvider` - Attachments filtered by type
/// - `selectedAttachmentProvider` - Currently selected attachment for detail view
///
/// ### Storage Providers
/// - `storageInfoProvider` - Storage usage and quota information
/// - `storageUsagePercentageProvider` - Percentage of storage used
/// - `isStorageNearlyFullProvider` - Storage >90% full indicator
/// - `isStorageFullProvider` - Storage >95% full indicator
/// - `availableStorageProvider` - Available storage in bytes
/// - `storageAvailablePercentageProvider` - Percentage of storage available
///
/// ### Download Statistics Providers
/// - `downloadStatsProvider` - Download statistics for selected attachment
///
/// ### Count Providers
/// - `allAttachmentCountProvider` - Total attachment count
/// - `taskAttachmentCountProvider` - Task attachments count
/// - `typeFilteredCountProvider` - Type-filtered attachments count
///
/// ### Loading State Providers
/// - `isLoadingAttachmentsProvider` - Overall loading state
/// - `isLoadingTaskAttachmentsProvider` - Task attachments loading state
/// - `isLoadingTypeFilteredProvider` - Type-filtered loading state
/// - `isLoadingStorageProvider` - Storage info loading state
/// - `isUploadingProvider` - Upload in progress indicator
/// - `isDownloadingProvider` - Download in progress indicator
/// - `isDeletingProvider` - Delete in progress indicator
/// - `isBatchDeletingProvider` - Batch delete in progress indicator
/// - `isAnyLoadingProvider` - Any loading operation in progress
/// - `isAnyOperationInProgressProvider` - Any operation in progress
///
/// ### Upload Progress Providers
/// - `uploadProgressProvider` - Upload progress percentage (0-100)
/// - `uploadingFileNameProvider` - Name of file being uploaded
///
/// ### Batch Delete Providers
/// - `lastBatchDeleteResultProvider` - Result of last batch delete operation
///
/// ### Error Providers
/// - `attachmentErrorProvider` - General attachment error
/// - `uploadErrorProvider` - Upload-specific error
/// - `downloadErrorProvider` - Download-specific error
/// - `deleteErrorProvider` - Delete-specific error
/// - `batchDeleteErrorProvider` - Batch delete-specific error
/// - `hasAnyErrorProvider` - Any error state indicator
///
/// ### Filter Providers
/// - `currentTypeFilterProvider` - Currently active type filter
/// - `currentTaskIdFilterProvider` - Currently active task ID filter
///
/// ### Computed Providers
/// - `taskImagesProvider` - Images only from task attachments
/// - `taskDocumentsProvider` - Documents only from task attachments
/// - `taskVideosProvider` - Videos only from task attachments
/// - `taskAudioProvider` - Audio files only from task attachments
/// - `taskStorageUsedProvider` - Total storage used by task attachments
/// - `attachmentNeedsRefreshProvider` - Attachment refresh needed indicator
/// - `storageNeedsRefreshProvider` - Storage refresh needed indicator
///
/// ### Use Case Providers (8 total)
/// - `uploadAttachmentProvider` - Upload attachment use case
/// - `downloadAttachmentProvider` - Download attachment use case
/// - `deleteAttachmentProvider` - Delete attachment use case
/// - `getAttachmentsByTaskProvider` - Get attachments by task use case
/// - `getAttachmentsByTypeProvider` - Get attachments by type use case
/// - `getTotalStorageUsedProvider` - Get storage info use case
/// - `batchDeleteAttachmentsProvider` - Batch delete use case
/// - `markAsDownloadedProvider` - Mark as downloaded use case
///
/// ## Best Practices
///
/// 1. **Watch vs Read**
///    - Use `ref.watch()` to rebuild on state changes
///    - Use `ref.read()` for one-time actions/callbacks
///
/// 2. **Error Handling**
///    - Listen to error providers with `ref.listen()`
///    - Show user-friendly error messages
///    - Clear errors after handling
///
/// 3. **Storage Management**
///    - Check storage availability before uploads
///    - Monitor storage usage with `storageNeedsRefreshProvider`
///    - Warn users when storage is >90% full
///
/// 4. **Upload/Download Progress**
///    - Use `uploadProgressProvider` for progress bars
///    - Provide feedback for long operations
///    - Handle cancellation gracefully
///
/// 5. **Performance**
///    - Use specific providers instead of watching entire state
///    - Leverage auto-dispose providers for temporary data
///    - Implement proper list keys for efficient rebuilds
///
/// 6. **Batch Operations**
///    - Validate IDs before batch delete
///    - Handle partial failures gracefully
///    - Show detailed result information
///
/// 7. **Download Tracking**
///    - Mark downloads to track usage statistics
///    - Use device IDs for multi-device tracking
///    - Monitor recent downloads for offline access
///
export 'attachment_notifier.dart';
export 'attachment_providers.dart';
export 'attachment_state.dart';
