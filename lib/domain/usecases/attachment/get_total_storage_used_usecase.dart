import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/attachment_repository.dart';
import '../../repositories/user_repository.dart';

/// Use case for calculating total storage used by a user
///
/// Returns storage information including:
/// - Total storage used in bytes
/// - Storage limit based on subscription tier
/// - Available storage
/// - Storage usage percentage
/// - Breakdown by attachment type
class GetTotalStorageUsedUseCase {
  final AttachmentRepository attachmentRepository;
  final UserRepository userRepository;

  GetTotalStorageUsedUseCase({
    required this.attachmentRepository,
    required this.userRepository,
  });

  /// Get total storage used by user
  ///
  /// Returns a map with storage information
  Future<Either<Failure, StorageInfo>> call(String userId) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Get user to check subscription tier
    final userResult = await userRepository.getUser(userId);
    if (userResult.isLeft()) {
      return Left(NotFoundFailure(message: 'User not found'));
    }

    final user = userResult.getOrElse(() => throw Exception('Unexpected error'));

    // Get total storage used
    final storageResult = await attachmentRepository.getTotalStorageUsed(userId);
    if (storageResult.isLeft()) {
      return Left(storageResult.fold(
        (failure) => failure,
        (_) => throw Exception('Unexpected error'),
      ));
    }

    final totalStorageUsed = storageResult.getOrElse(
      () => throw Exception('Unexpected error'),
    );

    // Get storage limit based on subscription tier
    final storageLimit = _getStorageLimitForTier(user.subscriptionTier);

    // Calculate available storage
    final availableStorage = storageLimit - totalStorageUsed;

    // Calculate usage percentage
    final usagePercentage = (totalStorageUsed / storageLimit * 100).clamp(0, 100);

    // Get storage statistics (breakdown by type)
    final statsResult = await attachmentRepository.getStorageStatistics(userId);
    final statistics = statsResult.fold(
      (_) => <String, dynamic>{},
      (stats) => stats,
    );

    return Right(StorageInfo(
      userId: userId,
      totalStorageUsed: totalStorageUsed,
      storageLimit: storageLimit,
      availableStorage: availableStorage,
      usagePercentage: usagePercentage,
      subscriptionTier: user.subscriptionTier,
      statistics: statistics,
    ));
  }

  /// Get storage limit in bytes based on subscription tier
  int _getStorageLimitForTier(UserSubscriptionTier tier) {
    switch (tier) {
      case UserSubscriptionTier.free:
        return 1024 * 1024 * 1024; // 1GB
      case UserSubscriptionTier.premiumIndividual:
      case UserSubscriptionTier.premiumFamily:
        return 10 * 1024 * 1024 * 1024; // 10GB
      case UserSubscriptionTier.teams:
      case UserSubscriptionTier.enterprise:
      case UserSubscriptionTier.lifetime:
        return 100 * 1024 * 1024 * 1024; // 100GB
    }
  }
}

/// Storage information model
class StorageInfo {
  final String userId;
  final int totalStorageUsed;
  final int storageLimit;
  final int availableStorage;
  final double usagePercentage;
  final UserSubscriptionTier subscriptionTier;
  final Map<String, dynamic> statistics;

  StorageInfo({
    required this.userId,
    required this.totalStorageUsed,
    required this.storageLimit,
    required this.availableStorage,
    required this.usagePercentage,
    required this.subscriptionTier,
    required this.statistics,
  });

  /// Get total storage used in human-readable format
  String get totalStorageUsedFormatted => _formatBytes(totalStorageUsed);

  /// Get storage limit in human-readable format
  String get storageLimitFormatted => _formatBytes(storageLimit);

  /// Get available storage in human-readable format
  String get availableStorageFormatted => _formatBytes(availableStorage);

  /// Check if storage is nearly full (>90%)
  bool get isNearlyFull => usagePercentage >= 90;

  /// Check if storage is full (>95%)
  bool get isFull => usagePercentage >= 95;

  /// Format bytes to human-readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalStorageUsed': totalStorageUsed,
      'totalStorageUsedFormatted': totalStorageUsedFormatted,
      'storageLimit': storageLimit,
      'storageLimitFormatted': storageLimitFormatted,
      'availableStorage': availableStorage,
      'availableStorageFormatted': availableStorageFormatted,
      'usagePercentage': usagePercentage,
      'subscriptionTier': subscriptionTier.name,
      'isNearlyFull': isNearlyFull,
      'isFull': isFull,
      'statistics': statistics,
    };
  }
}
