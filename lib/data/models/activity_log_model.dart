import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/activity_log_entity.dart';

part 'activity_log_model.freezed.dart';
part 'activity_log_model.g.dart';

/// Activity log data model for Firestore serialization
@freezed
class ActivityLogModel with _$ActivityLogModel {
  const factory ActivityLogModel({
    required String id,
    required String userId,
    String? workspaceId,
    required String type,
    required String entityType,
    required String entityId,
    required String action,
    Map<String, dynamic>? changes,
    Map<String, dynamic>? metadata,
    required DateTime timestamp,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
  }) = _ActivityLogModel;

  const ActivityLogModel._();

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogModelFromJson(json);

  ActivityLogEntity toEntity() {
    return ActivityLogEntity(
      id: id,
      userId: userId,
      workspaceId: workspaceId,
      type: _typeFromString(type),
      entityType: entityType,
      entityId: entityId,
      action: action,
      changes: changes,
      metadata: metadata,
      timestamp: timestamp,
      ipAddress: ipAddress,
      userAgent: userAgent,
      deviceInfo: deviceInfo,
    );
  }

  factory ActivityLogModel.fromEntity(ActivityLogEntity entity) {
    return ActivityLogModel(
      id: entity.id,
      userId: entity.userId,
      workspaceId: entity.workspaceId,
      type: _typeToString(entity.type),
      entityType: entity.entityType,
      entityId: entity.entityId,
      action: entity.action,
      changes: entity.changes,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      deviceInfo: entity.deviceInfo,
    );
  }

  static String _typeToString(ActivityType type) {
    return type.toString().split('.').last;
  }

  static ActivityType _typeFromString(String type) {
    switch (type) {
      case 'taskCreated':
        return ActivityType.taskCreated;
      case 'taskUpdated':
        return ActivityType.taskUpdated;
      case 'taskCompleted':
        return ActivityType.taskCompleted;
      case 'taskDeleted':
        return ActivityType.taskDeleted;
      case 'taskAssigned':
        return ActivityType.taskAssigned;
      case 'taskUnassigned':
        return ActivityType.taskUnassigned;
      case 'taskMoved':
        return ActivityType.taskMoved;
      case 'taskDuplicated':
        return ActivityType.taskDuplicated;
      case 'listCreated':
        return ActivityType.listCreated;
      case 'listUpdated':
        return ActivityType.listUpdated;
      case 'listDeleted':
        return ActivityType.listDeleted;
      case 'listShared':
        return ActivityType.listShared;
      case 'listUnshared':
        return ActivityType.listUnshared;
      case 'listArchived':
        return ActivityType.listArchived;
      case 'listRestored':
        return ActivityType.listRestored;
      case 'commentAdded':
        return ActivityType.commentAdded;
      case 'commentUpdated':
        return ActivityType.commentUpdated;
      case 'commentDeleted':
        return ActivityType.commentDeleted;
      case 'commentReacted':
        return ActivityType.commentReacted;
      case 'memberAdded':
        return ActivityType.memberAdded;
      case 'memberRemoved':
        return ActivityType.memberRemoved;
      case 'memberRoleChanged':
        return ActivityType.memberRoleChanged;
      case 'workspaceCreated':
        return ActivityType.workspaceCreated;
      case 'workspaceUpdated':
        return ActivityType.workspaceUpdated;
      case 'attachmentAdded':
        return ActivityType.attachmentAdded;
      case 'attachmentDeleted':
        return ActivityType.attachmentDeleted;
      case 'userLogin':
        return ActivityType.userLogin;
      case 'userLogout':
        return ActivityType.userLogout;
      case 'settingsChanged':
        return ActivityType.settingsChanged;
      case 'subscriptionChanged':
        return ActivityType.subscriptionChanged;
      default:
        return ActivityType.taskUpdated;
    }
  }
}
