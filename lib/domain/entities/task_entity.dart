import 'package:equatable/equatable.dart';

/// Task entity representing a task in the domain layer
class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String? listId;
  final String? parentTaskId; // For subtasks
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedAt;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final List<String> tags;
  final List<String> assigneeIds;
  final List<String> collaboratorIds;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? energyLevel; // 1-5 (low to high)
  final List<String> contextTags; // @computer, @phone, etc.
  final Map<String, dynamic>? customFields;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? lastModifiedBy;
  final bool isDeleted;
  final List<TaskDependency> dependencies;
  final RecurrenceRule? recurrenceRule;
  final String? recurrenceParentId; // For recurring task instances

  const TaskEntity({
    required this.id,
    required this.userId,
    this.listId,
    this.parentTaskId,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.none,
    this.dueDate,
    this.startDate,
    this.completedAt,
    this.estimatedDuration,
    this.actualDuration,
    this.tags = const [],
    this.assigneeIds = const [],
    this.collaboratorIds = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.energyLevel,
    this.contextTags = const [],
    this.customFields,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.lastModifiedBy,
    this.isDeleted = false,
    this.dependencies = const [],
    this.recurrenceRule,
    this.recurrenceParentId,
  });

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Check if task is due tomorrow
  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  /// Check if task is a subtask
  bool get isSubtask => parentTaskId != null;

  /// Check if task is recurring
  bool get isRecurring => recurrenceRule != null;

  /// Check if task has location
  bool get hasLocation => latitude != null && longitude != null;

  /// Copy with method
  TaskEntity copyWith({
    String? id,
    String? userId,
    String? listId,
    String? parentTaskId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedAt,
    Duration? estimatedDuration,
    Duration? actualDuration,
    List<String>? tags,
    List<String>? assigneeIds,
    List<String>? collaboratorIds,
    String? location,
    double? latitude,
    double? longitude,
    int? energyLevel,
    List<String>? contextTags,
    Map<String, dynamic>? customFields,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
    bool? isDeleted,
    List<TaskDependency>? dependencies,
    RecurrenceRule? recurrenceRule,
    String? recurrenceParentId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listId: listId ?? this.listId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      tags: tags ?? this.tags,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      energyLevel: energyLevel ?? this.energyLevel,
      contextTags: contextTags ?? this.contextTags,
      customFields: customFields ?? this.customFields,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      dependencies: dependencies ?? this.dependencies,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceParentId: recurrenceParentId ?? this.recurrenceParentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        listId,
        parentTaskId,
        title,
        description,
        status,
        priority,
        dueDate,
        startDate,
        completedAt,
        estimatedDuration,
        actualDuration,
        tags,
        assigneeIds,
        collaboratorIds,
        location,
        latitude,
        longitude,
        energyLevel,
        contextTags,
        customFields,
        sortOrder,
        createdAt,
        updatedAt,
        createdBy,
        lastModifiedBy,
        isDeleted,
        dependencies,
        recurrenceRule,
        recurrenceParentId,
      ];
}

/// Task status enum
enum TaskStatus {
  todo,
  inProgress,
  completed,
  cancelled,
}

/// Task priority enum
enum TaskPriority {
  none, // 0
  low, // 1
  medium, // 2
  high, // 3
  critical, // 4
}

/// Task dependency
class TaskDependency extends Equatable {
  final String taskId;
  final TaskDependencyType type;

  const TaskDependency({
    required this.taskId,
    required this.type,
  });

  @override
  List<Object> get props => [taskId, type];
}

/// Task dependency types
enum TaskDependencyType {
  blockedBy, // This task is blocked by another task
  blocking, // This task blocks another task
}

/// Recurrence rule
class RecurrenceRule extends Equatable {
  final RecurrenceFrequency frequency;
  final int interval; // Every X days/weeks/months/years
  final List<int>? daysOfWeek; // 1-7 (Monday-Sunday)
  final int? dayOfMonth; // 1-31
  final int? weekOfMonth; // 1-5 (first, second, etc.)
  final int? monthOfYear; // 1-12
  final DateTime? endDate;
  final int? occurrences;
  final RecurrenceCompletionBehavior completionBehavior;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.weekOfMonth,
    this.monthOfYear,
    this.endDate,
    this.occurrences,
    this.completionBehavior = RecurrenceCompletionBehavior.fromDueDate,
  });

  @override
  List<Object?> get props => [
        frequency,
        interval,
        daysOfWeek,
        dayOfMonth,
        weekOfMonth,
        monthOfYear,
        endDate,
        occurrences,
        completionBehavior,
      ];
}

/// Recurrence frequency
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Recurrence completion behavior
enum RecurrenceCompletionBehavior {
  fromDueDate, // Next occurrence based on original due date
  fromCompletionDate, // Next occurrence X days after completion
}
