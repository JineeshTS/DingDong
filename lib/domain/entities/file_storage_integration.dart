import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_storage_integration.freezed.dart';
part 'file_storage_integration.g.dart';

/// File Storage Integration
///
/// Represents a connection to external cloud storage platforms
/// (Google Drive, Dropbox, OneDrive, iCloud Drive)
@freezed
class FileStorageIntegration with _$FileStorageIntegration {
  const factory FileStorageIntegration({
    required String id,
    required String userId,
    required StorageProvider provider,
    required String accountEmail,
    required bool isConnected,
    required bool isActive,
    String? rootFolderId, // Default folder for DingDong files
    @Default([]) List<String> selectedFolderIds, // Folders to sync
    FileStorageSettings? settings,
    Map<String, dynamic>? credentials, // Encrypted OAuth tokens
    int? quotaUsed, // Bytes used
    int? quotaTotal, // Total quota in bytes
    DateTime? connectedAt,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) = _FileStorageIntegration;

  factory FileStorageIntegration.fromJson(Map<String, dynamic> json) =>
      _$FileStorageIntegrationFromJson(json);
}

/// Cloud Storage Platform Providers
enum StorageProvider {
  googleDrive,
  dropbox,
  oneDrive,
  iCloudDrive,
  box,
  other,
}

/// File Storage Integration Settings
@freezed
class FileStorageSettings with _$FileStorageSettings {
  const factory FileStorageSettings({
    // Attachment settings
    @Default(true) bool uploadTaskAttachments,
    @Default(true) bool createTasksFromFiles, // Create tasks from dropped files
    @Default(true) bool linkFilesToTasks,
    @Default(true) bool showFilePreview,
    @Default(true) bool downloadForOffline,

    // Organization settings
    @Default(true) bool createFolderPerList, // Organize by DingDong lists
    @Default(true) bool createFolderPerProject, // Organize by projects
    @Default('DingDong') String rootFolderName,
    @Default(true) bool preserveFolderStructure,

    // Sync settings
    @Default(true) bool autoSync,
    @Default(15) int syncInterval, // Minutes
    @Default(true) bool syncOnAttachmentAdd,
    @Default(true) bool syncOnFileChange,
    @Default(true) bool twoWaySync, // Sync changes from cloud back to app

    // File handling
    @Default(50) int maxFileSizeMB, // Max file size to sync
    @Default([]) List<String> excludeExtensions, // Don't sync these file types
    @Default([]) List<String> includeExtensions, // Only sync these (empty = all)
    @Default(true) bool compressImages,
    @Default(80) int imageQuality, // Compression quality (1-100)
    @Default(true) bool generateThumbnails,

    // Versioning
    @Default(true) bool keepVersionHistory,
    @Default(5) int maxVersions, // Max versions to keep per file

    // Sharing
    @Default(true) bool enableSharing,
    @Default(ShareLinkAccess.viewOnly) ShareLinkAccess defaultShareAccess,
    @Default(false) bool requirePassword,
    @Default(false) bool setExpiration,
    @Default(7) int defaultExpirationDays,

    // Provider-specific settings
    GoogleDriveSettings? googleDriveSettings,
    DropboxSettings? dropboxSettings,
    OneDriveSettings? oneDriveSettings,
  }) = _FileStorageSettings;

  factory FileStorageSettings.fromJson(Map<String, dynamic> json) =>
      _$FileStorageSettingsFromJson(json);
}

/// Share Link Access Level
enum ShareLinkAccess {
  viewOnly, // Can only view
  comment, // Can view and comment
  edit, // Can edit
}

/// Google Drive-specific Settings
@freezed
class GoogleDriveSettings with _$GoogleDriveSettings {
  const factory GoogleDriveSettings({
    @Default(true) bool useSharedDrives, // Support Team Drives
    @Default(true) bool useGoogleDocs, // Open in Google Docs/Sheets/Slides
    @Default(true) bool convertToGoogleFormat, // Convert Office files
    @Default([]) List<String> sharedDriveIds, // Team drives to include
    @Default(true) bool searchAllDrives, // Search across all drives
    @Default(true) bool enableOCR, // OCR for image/PDF search
  }) = _GoogleDriveSettings;

  factory GoogleDriveSettings.fromJson(Map<String, dynamic> json) =>
      _$GoogleDriveSettingsFromJson(json);
}

/// Dropbox-specific Settings
@freezed
class DropboxSettings with _$DropboxSettings {
  const factory DropboxSettings({
    @Default(true) bool useDropboxPaper, // Support Dropbox Paper docs
    @Default(true) bool enableSmartSync, // Selective sync
    @Default(true) bool useTeamFolder, // Team folder support
    @Default(true) bool syncOnlyOnWifi, // Mobile data savings
    @Default(true) bool enableFileRequests, // File request feature
  }) = _DropboxSettings;

  factory DropboxSettings.fromJson(Map<String, dynamic> json) =>
      _$DropboxSettingsFromJson(json);
}

/// OneDrive-specific Settings
@freezed
class OneDriveSettings with _$OneDriveSettings {
  const factory OneDriveSettings({
    @Default(true) bool useSharePoint, // SharePoint integration
    @Default(true) bool useOfficeOnline, // Office Online editing
    @Default(true) bool syncPersonalVault, // Personal Vault support
    @Default([]) List<String> sharePointSiteIds, // SharePoint sites
    @Default(true) bool enableVersionHistory, // OneDrive version history
  }) = _OneDriveSettings;

  factory OneDriveSettings.fromJson(Map<String, dynamic> json) =>
      _$OneDriveSettingsFromJson(json);
}

/// Cloud File/Folder representation
@freezed
class CloudFile with _$CloudFile {
  const factory CloudFile({
    required String id,
    required String integrationId,
    required StorageProvider provider,
    required String name,
    required String path,
    required bool isFolder,
    String? mimeType,
    int? size, // Bytes
    String? thumbnailUrl,
    String? downloadUrl,
    String? webViewUrl, // URL to view in browser
    String? parentFolderId,
    @Default([]) List<String> childIds, // If folder
    String? ownerId,
    String? ownerName,
    @Default(false) bool isShared,
    @Default(false) bool isStarred,
    @Default(false) bool isTrashed,
    String? linkedTaskId, // DingDong task this is attached to
    String? linkedListId, // DingDong list folder
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? metadata,
  }) = _CloudFile;

  factory CloudFile.fromJson(Map<String, dynamic> json) =>
      _$CloudFileFromJson(json);
}

/// File Upload Progress
@freezed
class FileUploadProgress with _$FileUploadProgress {
  const factory FileUploadProgress({
    required String localPath,
    required String fileName,
    required int totalBytes,
    required int uploadedBytes,
    required UploadStatus status,
    String? cloudFileId, // Set when complete
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _FileUploadProgress;

  factory FileUploadProgress.fromJson(Map<String, dynamic> json) =>
      _$FileUploadProgressFromJson(json);
}

/// Upload Status
enum UploadStatus {
  pending,
  uploading,
  processing,
  completed,
  failed,
  cancelled,
}

/// Share Link
@freezed
class ShareLink with _$ShareLink {
  const factory ShareLink({
    required String id,
    required String fileId,
    required String url,
    required ShareLinkAccess access,
    String? password,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? viewCount,
    int? downloadCount,
  }) = _ShareLink;

  factory ShareLink.fromJson(Map<String, dynamic> json) =>
      _$ShareLinkFromJson(json);
}

/// File Version
@freezed
class FileVersion with _$FileVersion {
  const factory FileVersion({
    required String id,
    required String fileId,
    required int versionNumber,
    required int size,
    required String modifiedBy,
    required DateTime modifiedAt,
    String? downloadUrl,
    bool? isCurrent,
  }) = _FileVersion;

  factory FileVersion.fromJson(Map<String, dynamic> json) =>
      _$FileVersionFromJson(json);
}

/// File Storage Sync Result
@freezed
class FileStorageSyncResult with _$FileStorageSyncResult {
  const factory FileStorageSyncResult({
    required String integrationId,
    required StorageProvider provider,
    required DateTime syncedAt,
    required int filesUploaded,
    required int filesDownloaded,
    required int filesUpdated,
    required int filesDeleted,
    required int foldersCreated,
    required int errors,
    @Default([]) List<String> errorMessages,
    int? bytesUploaded,
    int? bytesDownloaded,
  }) = _FileStorageSyncResult;

  factory FileStorageSyncResult.fromJson(Map<String, dynamic> json) =>
      _$FileStorageSyncResultFromJson(json);
}
