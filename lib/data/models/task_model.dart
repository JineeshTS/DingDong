import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Task data model for Firestore serialization
@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String userId,
    String? listId,
    String? parentTaskId,
    required String title,
    String? description,
    @Default('todo') String status,
    @Default('none') String priority,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedAt,
    int? estimatedDurationSeconds,
    int? actualDurationSeconds,
    @Default([]) List<String> tags,
    @Default([]) List<String> assigneeIds,
    @Default([]) List<String> collaboratorIds,
    String? location,
    double? latitude,
    double? longitude,
    int? energyLevel,
    @Default([]) List<String> contextTags,
    Map<String, dynamic>? customFields,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    String? lastModifiedBy,
    @Default(false) bool isDeleted,
    @Default([]) List<TaskDependencyModel> dependencies,
    RecurrenceRuleModel? recurrenceRule,
    String? recurrenceParentId,
  }) = _TaskModel;

  const TaskModel._();

  /// From JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// To entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      userId: userId,
      listId: listId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      status: _statusFromString(status),
      priority: _priorityFromString(priority),
      dueDate: dueDate,
      startDate: startDate,
      completedAt: completedAt,
      estimatedDuration: estimatedDurationSeconds != null
          ? Duration(seconds: estimatedDurationSeconds!)
          : null,
      actualDuration: actualDurationSeconds != null
          ? Duration(seconds: actualDurationSeconds!)
          : null,
      tags: tags,
      assigneeIds: assigneeIds,
      collaboratorIds: collaboratorIds,
      location: location,
      latitude: latitude,
      longitude: longitude,
      energyLevel: energyLevel,
      contextTags: contextTags,
      customFields: customFields,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      lastModifiedBy: lastModifiedBy,
      isDeleted: isDeleted,
      dependencies: dependencies.map((d) => d.toEntity()).toList(),
      recurrenceRule: recurrenceRule?.toEntity(),
      recurrenceParentId: recurrenceParentId,
    );
  }

  /// From entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      listId: entity.listId,
      parentTaskId: entity.parentTaskId,
      title: entity.title,
      description: entity.description,
      status: _statusToString(entity.status),
      priority: _priorityToString(entity.priority),
      dueDate: entity.dueDate,
      startDate: entity.startDate,
      completedAt: entity.completedAt,
      estimatedDurationSeconds: entity.estimatedDuration?.inSeconds,
      actualDurationSeconds: entity.actualDuration?.inSeconds,
      tags: entity.tags,
      assigneeIds: entity.assigneeIds,
      collaboratorIds: entity.collaboratorIds,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      energyLevel: entity.energyLevel,
      contextTags: entity.contextTags,
      customFields: entity.customFields,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      lastModifiedBy: entity.lastModifiedBy,
      isDeleted: entity.isDeleted,
      dependencies:
          entity.dependencies.map((d) => TaskDependencyModel.fromEntity(d)).toList(),
      recurrenceRule: entity.recurrenceRule != null
          ? RecurrenceRuleModel.fromEntity(entity.recurrenceRule!)
          : null,
      recurrenceParentId: entity.recurrenceParentId,
    );
  }

  // Helper methods for enum conversions
  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  static TaskStatus _statusFromString(String status) {
    switch (status) {
      case 'todo':
        return TaskStatus.todo;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
  }

  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return 'none';
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.critical:
        return 'critical';
    }
  }

  static TaskPriority _priorityFromString(String priority) {
    switch (priority) {
      case 'none':
        return TaskPriority.none;
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.none;
    }
  }
}

/// Task dependency model
@freezed
class TaskDependencyModel with _$TaskDependencyModel {
  const factory TaskDependencyModel({
    required String taskId,
    required String type,
  }) = _TaskDependencyModel;

  const TaskDependencyModel._();

  factory TaskDependencyModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDependencyModelFromJson(json);

  TaskDependency toEntity() {
    return TaskDependency(
      taskId: taskId,
      type: type == 'blocked_by'
          ? TaskDependencyType.blockedBy
          : TaskDependencyType.blocking,
    );
  }

  factory TaskDependencyModel.fromEntity(TaskDependency entity) {
    return TaskDependencyModel(
      taskId: entity.taskId,
      type: entity.type == TaskDependencyType.blockedBy
          ? 'blocked_by'
          : 'blocking',
    );
  }
}

/// Recurrence rule model
@freezed
class RecurrenceRuleModel with _$RecurrenceRuleModel {
  const factory RecurrenceRuleModel({
    required String frequency,
    @Default(1) int interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    int? weekOfMonth,
    int? monthOfYear,
    DateTime? endDate,
    int? occurrences,
    @Default('from_due_date') String completionBehavior,
  }) = _RecurrenceRuleModel;

  const RecurrenceRuleModel._();

  factory RecurrenceRuleModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRuleModelFromJson(json);

  RecurrenceRule toEntity() {
    return RecurrenceRule(
      frequency: _frequencyFromString(frequency),
      interval: interval,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      weekOfMonth: weekOfMonth,
      monthOfYear: monthOfYear,
      endDate: endDate,
      occurrences: occurrences,
      completionBehavior: _completionBehaviorFromString(completionBehavior),
    );
  }

  factory RecurrenceRuleModel.fromEntity(RecurrenceRule entity) {
    return RecurrenceRuleModel(
      frequency: _frequencyToString(entity.frequency),
      interval: entity.interval,
      daysOfWeek: entity.daysOfWeek,
      dayOfMonth: entity.dayOfMonth,
      weekOfMonth: entity.weekOfMonth,
      monthOfYear: entity.monthOfYear,
      endDate: entity.endDate,
      occurrences: entity.occurrences,
      completionBehavior: _completionBehaviorToString(entity.completionBehavior),
    );
  }

  static String _frequencyToString(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'daily';
      case RecurrenceFrequency.weekly:
        return 'weekly';
      case RecurrenceFrequency.monthly:
        return 'monthly';
      case RecurrenceFrequency.yearly:
        return 'yearly';
    }
  }

  static RecurrenceFrequency _frequencyFromString(String frequency) {
    switch (frequency) {
      case 'daily':
        return RecurrenceFrequency.daily;
      case 'weekly':
        return RecurrenceFrequency.weekly;
      case 'monthly':
        return RecurrenceFrequency.monthly;
      case 'yearly':
        return RecurrenceFrequency.yearly;
      default:
        return RecurrenceFrequency.daily;
    }
  }

  static String _completionBehaviorToString(RecurrenceCompletionBehavior behavior) {
    switch (behavior) {
      case RecurrenceCompletionBehavior.fromDueDate:
        return 'from_due_date';
      case RecurrenceCompletionBehavior.fromCompletionDate:
        return 'from_completion_date';
    }
  }

  static RecurrenceCompletionBehavior _completionBehaviorFromString(String behavior) {
    switch (behavior) {
      case 'from_due_date':
        return RecurrenceCompletionBehavior.fromDueDate;
      case 'from_completion_date':
        return RecurrenceCompletionBehavior.fromCompletionDate;
      default:
        return RecurrenceCompletionBehavior.fromDueDate;
    }
  }
}
