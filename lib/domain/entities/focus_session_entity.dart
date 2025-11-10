import 'package:equatable/equatable.dart';

/// Focus Session entity representing a Pomodoro/focus session
class FocusSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String? taskId; // Task being worked on
  final String? listId;
  final FocusSessionType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration plannedDuration;
  final Duration? actualDuration;
  final FocusSessionStatus status;
  final int interruptionsCount; // Number of times interrupted
  final List<FocusInterruption> interruptions;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const FocusSessionEntity({
    required this.id,
    required this.userId,
    this.taskId,
    this.listId,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration,
    this.status = FocusSessionStatus.inProgress,
    this.interruptionsCount = 0,
    this.interruptions = const [],
    this.notes,
    this.metadata,
    required this.createdAt,
  });

  /// Check if session is active
  bool get isActive => status == FocusSessionStatus.inProgress;

  /// Check if session is completed
  bool get isCompleted => status == FocusSessionStatus.completed;

  /// Get focus quality score (0-100)
  double get focusQuality {
    if (actualDuration == null || actualDuration!.inSeconds == 0) return 0;

    // Calculate based on: actual vs planned duration and interruptions
    final durationScore = (actualDuration!.inSeconds / plannedDuration.inSeconds).clamp(0.0, 1.0);
    final interruptionPenalty = (interruptionsCount * 0.1).clamp(0.0, 1.0);
    final quality = (durationScore * (1 - interruptionPenalty)) * 100;

    return quality.clamp(0.0, 100.0);
  }

  /// Copy with method
  FocusSessionEntity copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? listId,
    FocusSessionType? type,
    DateTime? startTime,
    DateTime? endTime,
    Duration? plannedDuration,
    Duration? actualDuration,
    FocusSessionStatus? status,
    int? interruptionsCount,
    List<FocusInterruption>? interruptions,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return FocusSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      listId: listId ?? this.listId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      status: status ?? this.status,
      interruptionsCount: interruptionsCount ?? this.interruptionsCount,
      interruptions: interruptions ?? this.interruptions,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        taskId,
        listId,
        type,
        startTime,
        endTime,
        plannedDuration,
        actualDuration,
        status,
        interruptionsCount,
        interruptions,
        notes,
        metadata,
        createdAt,
      ];
}

/// Focus session types
enum FocusSessionType {
  pomodoro, // 25-minute focus session
  shortBreak, // 5-minute break
  longBreak, // 15-minute break
  custom, // Custom duration
}

/// Focus session status
enum FocusSessionStatus {
  inProgress,
  completed,
  cancelled,
  paused,
}

/// Focus interruption
class FocusInterruption extends Equatable {
  final DateTime timestamp;
  final String? reason;
  final Duration pauseDuration;

  const FocusInterruption({
    required this.timestamp,
    this.reason,
    required this.pauseDuration,
  });

  @override
  List<Object?> get props => [timestamp, reason, pauseDuration];
}
