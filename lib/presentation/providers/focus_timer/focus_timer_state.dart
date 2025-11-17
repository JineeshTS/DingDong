import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/focus_session_entity.dart';

part 'focus_timer_state.freezed.dart';

/// Focus Timer State
///
/// Manages the state of the Pomodoro timer including:
/// - Active session
/// - Timer countdown
/// - Session history
/// - Pomodoro settings
@freezed
class FocusTimerState with _$FocusTimerState {
  const factory FocusTimerState({
    // Active session
    FocusSessionEntity? activeSession,

    // Timer state
    @Default(TimerStatus.idle) TimerStatus timerStatus,
    @Default(Duration.zero) Duration remainingTime,
    @Default(Duration.zero) Duration elapsedTime,

    // Pomodoro settings
    @Default(Duration(minutes: 25)) Duration focusDuration,
    @Default(Duration(minutes: 5)) Duration shortBreakDuration,
    @Default(Duration(minutes: 15)) Duration longBreakDuration,
    @Default(4) int longBreakInterval,
    @Default(true) bool autoStartBreaks,
    @Default(true) bool autoStartPomodoros,

    // Session tracking
    @Default(0) int completedPomodoros,
    @Default(0) int pomodorosUntilLongBreak,

    // Recent sessions
    @Default([]) List<FocusSessionEntity> recentSessions,

    // Statistics
    @Default(0) int totalSessionsToday,
    @Default(Duration.zero) Duration totalFocusTimeToday,
    @Default(0) int currentStreak,

    // UI state
    @Default(false) bool isLoading,
    String? error,

    // Task association
    String? linkedTaskId,
  }) = _FocusTimerState;

  const FocusTimerState._();

  /// Check if timer is running
  bool get isRunning => timerStatus == TimerStatus.running;

  /// Check if timer is paused
  bool get isPaused => timerStatus == TimerStatus.paused;

  /// Check if there's an active session
  bool get hasActiveSession => activeSession != null;

  /// Get current session type
  FocusSessionType? get currentSessionType => activeSession?.type;

  /// Check if current session is a focus session
  bool get isFocusSession =>
      currentSessionType == FocusSessionType.pomodoro ||
      currentSessionType == FocusSessionType.custom;

  /// Check if current session is a break
  bool get isBreakSession =>
      currentSessionType == FocusSessionType.shortBreak ||
      currentSessionType == FocusSessionType.longBreak;

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    if (activeSession == null) return 0.0;
    final total = activeSession!.plannedDuration.inSeconds;
    if (total == 0) return 0.0;
    final elapsed = elapsedTime.inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Format remaining time as MM:SS
  String get formattedRemainingTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format elapsed time as MM:SS
  String get formattedElapsedTime {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get session type label
  String get sessionTypeLabel {
    if (activeSession == null) return 'Ready';
    switch (activeSession!.type) {
      case FocusSessionType.pomodoro:
        return 'Focus Time';
      case FocusSessionType.shortBreak:
        return 'Short Break';
      case FocusSessionType.longBreak:
        return 'Long Break';
      case FocusSessionType.custom:
        return 'Custom Focus';
    }
  }

  /// Get next session type based on pomodoro count
  FocusSessionType get nextSessionType {
    if (!hasActiveSession) return FocusSessionType.pomodoro;

    if (isFocusSession) {
      // After focus, determine break type
      if (pomodorosUntilLongBreak <= 1) {
        return FocusSessionType.longBreak;
      }
      return FocusSessionType.shortBreak;
    } else {
      // After break, start pomodoro
      return FocusSessionType.pomodoro;
    }
  }

  /// Get duration for session type
  Duration getDurationForType(FocusSessionType type) {
    switch (type) {
      case FocusSessionType.pomodoro:
        return focusDuration;
      case FocusSessionType.shortBreak:
        return shortBreakDuration;
      case FocusSessionType.longBreak:
        return longBreakDuration;
      case FocusSessionType.custom:
        return focusDuration;
    }
  }
}

/// Timer Status
enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}
