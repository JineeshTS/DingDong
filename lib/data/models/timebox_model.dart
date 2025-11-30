import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timebox_entity.dart';
import '../../domain/entities/task_entity.dart';

part 'timebox_model.freezed.dart';
part 'timebox_model.g.dart';

/// Timebox Model
///
/// Freezed model for serialization of TimeboxEntity
@freezed
class TimeboxModel with _$TimeboxModel {
  const factory TimeboxModel({
    required String id,
    required String userId,
    required DateTime date,
    @Default([]) List<TimeboxSlotModel> slots,
    @Default([]) List<TimeConflictModel> conflicts,
    required TimeboxSummaryModel summary,
    required TimeboxSettingsModel settings,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TimeboxModel;

  factory TimeboxModel.fromJson(Map<String, dynamic> json) =>
      _$TimeboxModelFromJson(json);

  const TimeboxModel._();

  /// Convert to entity
  TimeboxEntity toEntity() {
    return TimeboxEntity(
      id: id,
      userId: userId,
      date: date,
      slots: slots.map((s) => s.toEntity()).toList(),
      conflicts: conflicts.map((c) => c.toEntity()).toList(),
      summary: summary.toEntity(),
      settings: settings.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory TimeboxModel.fromEntity(TimeboxEntity entity) {
    return TimeboxModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      slots: entity.slots.map((s) => TimeboxSlotModel.fromEntity(s)).toList(),
      conflicts: entity.conflicts.map((c) => TimeConflictModel.fromEntity(c)).toList(),
      summary: TimeboxSummaryModel.fromEntity(entity.summary),
      settings: TimeboxSettingsModel.fromEntity(entity.settings),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Timebox Slot Model
@freezed
class TimeboxSlotModel with _$TimeboxSlotModel {
  const factory TimeboxSlotModel({
    required String id,
    required String taskId,
    required String taskTitle,
    String? taskDescription,
    required DateTime startTime,
    required DateTime endTime,
    required String category,
    @Default('none') String priority,
    @Default('scheduled') String status,
    String? listId,
    String? listName,
    String? listColor,
    @Default([]) List<String> tags,
    @Default(false) bool isRecurring,
    @Default(false) bool isAllDay,
    String? notes,
  }) = _TimeboxSlotModel;

  factory TimeboxSlotModel.fromJson(Map<String, dynamic> json) =>
      _$TimeboxSlotModelFromJson(json);

  const TimeboxSlotModel._();

  /// Convert to entity
  TimeboxSlot toEntity() {
    return TimeboxSlot(
      id: id,
      taskId: taskId,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      startTime: startTime,
      endTime: endTime,
      category: _categoryFromString(category),
      priority: _priorityFromString(priority),
      status: _statusFromString(status),
      listId: listId,
      listName: listName,
      listColor: listColor,
      tags: tags,
      isRecurring: isRecurring,
      isAllDay: isAllDay,
      notes: notes,
    );
  }

  /// Create from entity
  factory TimeboxSlotModel.fromEntity(TimeboxSlot entity) {
    return TimeboxSlotModel(
      id: entity.id,
      taskId: entity.taskId,
      taskTitle: entity.taskTitle,
      taskDescription: entity.taskDescription,
      startTime: entity.startTime,
      endTime: entity.endTime,
      category: entity.category.name,
      priority: entity.priority.name,
      status: entity.status.name,
      listId: entity.listId,
      listName: entity.listName,
      listColor: entity.listColor,
      tags: entity.tags,
      isRecurring: entity.isRecurring,
      isAllDay: entity.isAllDay,
      notes: entity.notes,
    );
  }

  TaskCategory _categoryFromString(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskCategory.personal,
    );
  }

  TaskPriority _priorityFromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.none,
    );
  }

  TimeboxSlotStatus _statusFromString(String value) {
    return TimeboxSlotStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TimeboxSlotStatus.scheduled,
    );
  }
}

/// Time Conflict Model
@freezed
class TimeConflictModel with _$TimeConflictModel {
  const factory TimeConflictModel({
    required String id,
    required String slot1Id,
    required String slot1Title,
    required String slot2Id,
    required String slot2Title,
    required DateTime overlapStart,
    required DateTime overlapEnd,
    required String type,
    @Default('warning') String severity,
    String? resolution,
  }) = _TimeConflictModel;

  factory TimeConflictModel.fromJson(Map<String, dynamic> json) =>
      _$TimeConflictModelFromJson(json);

  const TimeConflictModel._();

  /// Convert to entity
  TimeConflict toEntity() {
    return TimeConflict(
      id: id,
      slot1Id: slot1Id,
      slot1Title: slot1Title,
      slot2Id: slot2Id,
      slot2Title: slot2Title,
      overlapStart: overlapStart,
      overlapEnd: overlapEnd,
      type: _typeFromString(type),
      severity: _severityFromString(severity),
      resolution: resolution,
    );
  }

  /// Create from entity
  factory TimeConflictModel.fromEntity(TimeConflict entity) {
    return TimeConflictModel(
      id: entity.id,
      slot1Id: entity.slot1Id,
      slot1Title: entity.slot1Title,
      slot2Id: entity.slot2Id,
      slot2Title: entity.slot2Title,
      overlapStart: entity.overlapStart,
      overlapEnd: entity.overlapEnd,
      type: entity.type.name,
      severity: entity.severity.name,
      resolution: entity.resolution,
    );
  }

  TimeConflictType _typeFromString(String value) {
    return TimeConflictType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TimeConflictType.partialOverlap,
    );
  }

  TimeConflictSeverity _severityFromString(String value) {
    return TimeConflictSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TimeConflictSeverity.warning,
    );
  }
}

/// Timebox Summary Model
@freezed
class TimeboxSummaryModel with _$TimeboxSummaryModel {
  const factory TimeboxSummaryModel({
    @Default(0) int totalTasks,
    @Default(0) int completedTasks,
    @Default(0) int personalTasks,
    @Default(0) int professionalTasks,
    @Default(0) int priorityTasks,
    @Default(0) int conflictCount,
    @Default(0) int totalScheduledMinutes,
    @Default(0) int availableMinutes,
    @Default(0.0) double completionRate,
  }) = _TimeboxSummaryModel;

  factory TimeboxSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TimeboxSummaryModelFromJson(json);

  const TimeboxSummaryModel._();

  /// Convert to entity
  TimeboxSummary toEntity() {
    return TimeboxSummary(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      personalTasks: personalTasks,
      professionalTasks: professionalTasks,
      priorityTasks: priorityTasks,
      conflictCount: conflictCount,
      totalScheduledMinutes: totalScheduledMinutes,
      availableMinutes: availableMinutes,
      completionRate: completionRate,
    );
  }

  /// Create from entity
  factory TimeboxSummaryModel.fromEntity(TimeboxSummary entity) {
    return TimeboxSummaryModel(
      totalTasks: entity.totalTasks,
      completedTasks: entity.completedTasks,
      personalTasks: entity.personalTasks,
      professionalTasks: entity.professionalTasks,
      priorityTasks: entity.priorityTasks,
      conflictCount: entity.conflictCount,
      totalScheduledMinutes: entity.totalScheduledMinutes,
      availableMinutes: entity.availableMinutes,
      completionRate: entity.completionRate,
    );
  }
}

/// Timebox Settings Model
@freezed
class TimeboxSettingsModel with _$TimeboxSettingsModel {
  const factory TimeboxSettingsModel({
    @Default(8) int dayStartHour,
    @Default(18) int dayEndHour,
    @Default(30) int defaultSlotDuration,
    @Default(5) int bufferBetweenSlots,
    @Default(true) bool showCompletedTasks,
    @Default(true) bool highlightConflicts,
    @Default(true) bool highlightPriorityTasks,
    @Default(true) bool autoScheduleBreaks,
    @Default(15) int breakDuration,
    @Default(90) int breakAfterMinutes,
    @Default(['personal', 'professional', 'health', 'learning', 'errands', 'social', 'other'])
    List<String> visibleCategories,
    @Default('timeline') String viewMode,
  }) = _TimeboxSettingsModel;

  factory TimeboxSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$TimeboxSettingsModelFromJson(json);

  const TimeboxSettingsModel._();

  /// Convert to entity
  TimeboxSettings toEntity() {
    return TimeboxSettings(
      dayStartHour: dayStartHour,
      dayEndHour: dayEndHour,
      defaultSlotDuration: defaultSlotDuration,
      bufferBetweenSlots: bufferBetweenSlots,
      showCompletedTasks: showCompletedTasks,
      highlightConflicts: highlightConflicts,
      highlightPriorityTasks: highlightPriorityTasks,
      autoScheduleBreaks: autoScheduleBreaks,
      breakDuration: breakDuration,
      breakAfterMinutes: breakAfterMinutes,
      visibleCategories: visibleCategories.map(_categoryFromString).toList(),
      viewMode: _viewModeFromString(viewMode),
    );
  }

  /// Create from entity
  factory TimeboxSettingsModel.fromEntity(TimeboxSettings entity) {
    return TimeboxSettingsModel(
      dayStartHour: entity.dayStartHour,
      dayEndHour: entity.dayEndHour,
      defaultSlotDuration: entity.defaultSlotDuration,
      bufferBetweenSlots: entity.bufferBetweenSlots,
      showCompletedTasks: entity.showCompletedTasks,
      highlightConflicts: entity.highlightConflicts,
      highlightPriorityTasks: entity.highlightPriorityTasks,
      autoScheduleBreaks: entity.autoScheduleBreaks,
      breakDuration: entity.breakDuration,
      breakAfterMinutes: entity.breakAfterMinutes,
      visibleCategories: entity.visibleCategories.map((c) => c.name).toList(),
      viewMode: entity.viewMode.name,
    );
  }

  TaskCategory _categoryFromString(String value) {
    return TaskCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskCategory.personal,
    );
  }

  TimeboxViewMode _viewModeFromString(String value) {
    return TimeboxViewMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TimeboxViewMode.timeline,
    );
  }
}
