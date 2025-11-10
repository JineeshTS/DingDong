import 'package:equatable/equatable.dart';

/// Activity Log entity representing an action taken in the system
class ActivityLogEntity extends Equatable {
  final String id;
  final String userId;
  final String? workspaceId;
  final ActivityType type;
  final String entityType; // 'task', 'list', 'comment', etc.
  final String entityId;
  final String action; // 'created', 'updated', 'deleted', 'completed', etc.
  final Map<String, dynamic>? changes; // What changed (old vs new values)
  final Map<String, dynamic>? metadata; // Additional context
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceInfo;

  const ActivityLogEntity({
    required this.id,
    required this.userId,
    this.workspaceId,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.changes,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.deviceInfo,
  });

  /// Get human-readable description
  String getDescription() {
    switch (type) {
      case ActivityType.taskCreated:
        return 'created a task';
      case ActivityType.taskUpdated:
        return 'updated a task';
      case ActivityType.taskCompleted:
        return 'completed a task';
      case ActivityType.taskDeleted:
        return 'deleted a task';
      case ActivityType.listCreated:
        return 'created a list';
      case ActivityType.listUpdated:
        return 'updated a list';
      case ActivityType.listShared:
        return 'shared a list';
      case ActivityType.commentAdded:
        return 'added a comment';
      case ActivityType.memberAdded:
        return 'added a member';
      case ActivityType.memberRemoved:
        return 'removed a member';
      default:
        return action;
    }
  }

  /// Copy with method
  ActivityLogEntity copyWith({
    String? id,
    String? userId,
    String? workspaceId,
    ActivityType? type,
    String? entityType,
    String? entityId,
    String? action,
    Map<String, dynamic>? changes,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
  }) {
    return ActivityLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      changes: changes ?? this.changes,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workspaceId,
        type,
        entityType,
        entityId,
        action,
        changes,
        metadata,
        timestamp,
        ipAddress,
        userAgent,
        deviceInfo,
      ];
}

/// Activity types
enum ActivityType {
  // Task activities
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  taskAssigned,
  taskUnassigned,
  taskMoved,
  taskDuplicated,

  // List activities
  listCreated,
  listUpdated,
  listDeleted,
  listShared,
  listUnshared,
  listArchived,
  listRestored,

  // Comment activities
  commentAdded,
  commentUpdated,
  commentDeleted,
  commentReacted,

  // Collaboration activities
  memberAdded,
  memberRemoved,
  memberRoleChanged,
  workspaceCreated,
  workspaceUpdated,

  // Attachment activities
  attachmentAdded,
  attachmentDeleted,

  // Other activities
  userLogin,
  userLogout,
  settingsChanged,
  subscriptionChanged,
}
