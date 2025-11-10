import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/focus_session_entity.dart';

part 'focus_session_model.freezed.dart';
part 'focus_session_model.g.dart';

/// Focus session data model for Firestore serialization
@freezed
class FocusSessionModel with _$FocusSessionModel {
  const factory FocusSessionModel({
    required String id,
    required String userId,
    String? taskId,
    String? listId,
    required String type,
    required DateTime startTime,
    DateTime? endTime,
    required int plannedDurationSeconds,
    int? actualDurationSeconds,
    @Default('inProgress') String status,
    @Default(0) int interruptionsCount,
    @Default([]) List<FocusInterruptionModel> interruptions,
    String? notes,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _FocusSessionModel;

  const FocusSessionModel._();

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionModelFromJson(json);

  FocusSessionEntity toEntity() {
    return FocusSessionEntity(
      id: id,
      userId: userId,
      taskId: taskId,
      listId: listId,
      type: _typeFromString(type),
      startTime: startTime,
      endTime: endTime,
      plannedDuration: Duration(seconds: plannedDurationSeconds),
      actualDuration: actualDurationSeconds != null
          ? Duration(seconds: actualDurationSeconds!)
          : null,
      status: _statusFromString(status),
      interruptionsCount: interruptionsCount,
      interruptions: interruptions.map((i) => i.toEntity()).toList(),
      notes: notes,
      metadata: metadata,
      createdAt: createdAt,
    );
  }

  factory FocusSessionModel.fromEntity(FocusSessionEntity entity) {
    return FocusSessionModel(
      id: entity.id,
      userId: entity.userId,
      taskId: entity.taskId,
      listId: entity.listId,
      type: _typeToString(entity.type),
      startTime: entity.startTime,
      endTime: entity.endTime,
      plannedDurationSeconds: entity.plannedDuration.inSeconds,
      actualDurationSeconds: entity.actualDuration?.inSeconds,
      status: _statusToString(entity.status),
      interruptionsCount: entity.interruptionsCount,
      interruptions: entity.interruptions
          .map((i) => FocusInterruptionModel.fromEntity(i))
          .toList(),
      notes: entity.notes,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
    );
  }

  static String _typeToString(FocusSessionType type) {
    return type.toString().split('.').last;
  }

  static FocusSessionType _typeFromString(String type) {
    switch (type) {
      case 'pomodoro':
        return FocusSessionType.pomodoro;
      case 'shortBreak':
        return FocusSessionType.shortBreak;
      case 'longBreak':
        return FocusSessionType.longBreak;
      case 'custom':
        return FocusSessionType.custom;
      default:
        return FocusSessionType.pomodoro;
    }
  }

  static String _statusToString(FocusSessionStatus status) {
    return status.toString().split('.').last;
  }

  static FocusSessionStatus _statusFromString(String status) {
    switch (status) {
      case 'inProgress':
        return FocusSessionStatus.inProgress;
      case 'completed':
        return FocusSessionStatus.completed;
      case 'cancelled':
        return FocusSessionStatus.cancelled;
      case 'paused':
        return FocusSessionStatus.paused;
      default:
        return FocusSessionStatus.inProgress;
    }
  }
}

/// Focus interruption model
@freezed
class FocusInterruptionModel with _$FocusInterruptionModel {
  const factory FocusInterruptionModel({
    required DateTime timestamp,
    String? reason,
    required int pauseDurationSeconds,
  }) = _FocusInterruptionModel;

  const FocusInterruptionModel._();

  factory FocusInterruptionModel.fromJson(Map<String, dynamic> json) =>
      _$FocusInterruptionModelFromJson(json);

  FocusInterruption toEntity() {
    return FocusInterruption(
      timestamp: timestamp,
      reason: reason,
      pauseDuration: Duration(seconds: pauseDurationSeconds),
    );
  }

  factory FocusInterruptionModel.fromEntity(FocusInterruption entity) {
    return FocusInterruptionModel(
      timestamp: entity.timestamp,
      reason: entity.reason,
      pauseDurationSeconds: entity.pauseDuration.inSeconds,
    );
  }
}
