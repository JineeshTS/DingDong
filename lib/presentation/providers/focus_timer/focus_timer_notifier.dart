import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../../domain/usecases/focus_session/start_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/pause_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/resume_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/complete_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/cancel_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/add_interruption_usecase.dart';
import '../../../domain/usecases/focus_session/get_active_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_statistics_usecase.dart';
import 'focus_timer_state.dart';

/// Focus Timer Notifier
///
/// Manages the Pomodoro timer logic including:
/// - Timer countdown with 1-second intervals
/// - Session lifecycle (start, pause, resume, complete, cancel)
/// - Automatic break/focus transitions
/// - Pomodoro cycle tracking
/// - Session statistics
class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final StartFocusSessionUseCase _startFocusSession;
  final PauseFocusSessionUseCase _pauseFocusSession;
  final ResumeFocusSessionUseCase _resumeFocusSession;
  final CompleteFocusSessionUseCase _completeFocusSession;
  final CancelFocusSessionUseCase _cancelFocusSession;
  final AddInterruptionUseCase _addInterruption;
  final GetActiveFocusSessionUseCase _getActiveFocusSession;
  final GetFocusStatisticsUseCase _getFocusStatistics;

  Timer? _timer;
  final String _userId;

  FocusTimerNotifier({
    required String userId,
    required StartFocusSessionUseCase startFocusSession,
    required PauseFocusSessionUseCase pauseFocusSession,
    required ResumeFocusSessionUseCase resumeFocusSession,
    required CompleteFocusSessionUseCase completeFocusSession,
    required CancelFocusSessionUseCase cancelFocusSession,
    required AddInterruptionUseCase addInterruption,
    required GetActiveFocusSessionUseCase getActiveFocusSession,
    required GetFocusStatisticsUseCase getFocusStatistics,
  })  : _userId = userId,
        _startFocusSession = startFocusSession,
        _pauseFocusSession = pauseFocusSession,
        _resumeFocusSession = resumeFocusSession,
        _completeFocusSession = completeFocusSession,
        _cancelFocusSession = cancelFocusSession,
        _addInterruption = addInterruption,
        _getActiveFocusSession = getActiveFocusSession,
        _getFocusStatistics = getFocusStatistics,
        super(const FocusTimerState()) {
    _init();
  }

  /// Initialize timer state
  Future<void> _init() async {
    await checkForActiveSession();
    await loadStatistics();
  }

  /// Check if there's an active session on startup
  Future<void> checkForActiveSession() async {
    final result = await _getActiveFocusSession(_userId);

    result.fold(
      (failure) {
        // No active session or error - start fresh
        state = state.copyWith(error: null);
      },
      (session) {
        if (session != null) {
          // Resume existing session
          final elapsed = DateTime.now().difference(session.startTime);
          final remaining = session.plannedDuration - elapsed;

          if (remaining.inSeconds > 0) {
            state = state.copyWith(
              activeSession: session,
              timerStatus: session.status == FocusSessionStatus.paused
                  ? TimerStatus.paused
                  : TimerStatus.running,
              elapsedTime: elapsed,
              remainingTime: remaining,
              linkedTaskId: session.taskId,
            );

            if (session.status == FocusSessionStatus.inProgress) {
              _startTimer();
            }
          } else {
            // Session expired, complete it
            _completeCurrentSession();
          }
        }
      },
    );
  }

  /// Load focus statistics
  Future<void> loadStatistics() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await _getFocusStatistics(
      _userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    result.fold(
      (failure) => null,
      (stats) {
        state = state.copyWith(
          totalSessionsToday: stats['totalSessions'] as int? ?? 0,
          totalFocusTimeToday:
              stats['totalDuration'] as Duration? ?? Duration.zero,
          currentStreak: stats['currentStreak'] as int? ?? 0,
        );
      },
    );
  }

  /// Start a new Pomodoro session
  Future<void> startPomodoro({String? taskId}) async {
    await startSession(
      type: FocusSessionType.pomodoro,
      duration: state.focusDuration,
      taskId: taskId,
    );
  }

  /// Start a custom focus session
  Future<void> startCustomSession({
    required Duration duration,
    String? taskId,
  }) async {
    await startSession(
      type: FocusSessionType.custom,
      duration: duration,
      taskId: taskId,
    );
  }

  /// Start a short break
  Future<void> startShortBreak() async {
    await startSession(
      type: FocusSessionType.shortBreak,
      duration: state.shortBreakDuration,
    );
  }

  /// Start a long break
  Future<void> startLongBreak() async {
    await startSession(
      type: FocusSessionType.longBreak,
      duration: state.longBreakDuration,
    );
  }

  /// Generic start session method
  Future<void> startSession({
    required FocusSessionType type,
    required Duration duration,
    String? taskId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final session = FocusSessionEntity(
      id: const Uuid().v4(),
      userId: _userId,
      taskId: taskId,
      type: type,
      startTime: DateTime.now(),
      plannedDuration: duration,
      status: FocusSessionStatus.inProgress,
      createdAt: DateTime.now(),
    );

    final result = await _startFocusSession(session);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (createdSession) {
        state = state.copyWith(
          isLoading: false,
          activeSession: createdSession,
          timerStatus: TimerStatus.running,
          remainingTime: duration,
          elapsedTime: Duration.zero,
          linkedTaskId: taskId,
          error: null,
        );
        _startTimer();
      },
    );
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingTime.inSeconds > 0) {
        state = state.copyWith(
          remainingTime: state.remainingTime - const Duration(seconds: 1),
          elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        );
      } else {
        _completeCurrentSession();
      }
    });
  }

  /// Pause the current session
  Future<void> pauseSession() async {
    if (state.activeSession == null) return;

    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.paused);

    final result = await _pauseFocusSession(state.activeSession!.id);

    result.fold(
      (failure) {
        state = state.copyWith(error: _getErrorMessage(failure));
      },
      (pausedSession) {
        state = state.copyWith(
          activeSession: pausedSession,
        );
      },
    );
  }

  /// Resume the paused session
  Future<void> resumeSession() async {
    if (state.activeSession == null) return;

    final result = await _resumeFocusSession(state.activeSession!.id);

    result.fold(
      (failure) {
        state = state.copyWith(error: _getErrorMessage(failure));
      },
      (resumedSession) {
        state = state.copyWith(
          activeSession: resumedSession,
          timerStatus: TimerStatus.running,
        );
        _startTimer();
      },
    );
  }

  /// Complete the current session
  Future<void> _completeCurrentSession() async {
    if (state.activeSession == null) return;

    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.completed);

    final result = await _completeFocusSession(
      state.activeSession!.id,
      notes: null,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: _getErrorMessage(failure));
      },
      (completedSession) {
        // Update session count
        int newCompletedPomodoros = state.completedPomodoros;
        int newPomodorosUntilLongBreak = state.pomodorosUntilLongBreak;

        if (completedSession.type == FocusSessionType.pomodoro) {
          newCompletedPomodoros++;
          newPomodorosUntilLongBreak--;

          if (newPomodorosUntilLongBreak <= 0) {
            newPomodorosUntilLongBreak = state.longBreakInterval;
          }
        }

        // Add to recent sessions
        final recentSessions = [completedSession, ...state.recentSessions]
            .take(10)
            .toList();

        state = state.copyWith(
          activeSession: null,
          timerStatus: TimerStatus.idle,
          remainingTime: Duration.zero,
          elapsedTime: Duration.zero,
          completedPomodoros: newCompletedPomodoros,
          pomodorosUntilLongBreak: newPomodorosUntilLongBreak,
          recentSessions: recentSessions,
          linkedTaskId: null,
        );

        // Reload statistics
        loadStatistics();

        // Auto-start next session if enabled
        _autoStartNextSession(completedSession.type);
      },
    );
  }

  /// Auto-start next session based on settings
  void _autoStartNextSession(FocusSessionType completedType) {
    if (completedType == FocusSessionType.pomodoro ||
        completedType == FocusSessionType.custom) {
      // Just completed a focus session
      if (state.autoStartBreaks) {
        final nextType = state.nextSessionType;
        if (nextType == FocusSessionType.shortBreak) {
          startShortBreak();
        } else if (nextType == FocusSessionType.longBreak) {
          startLongBreak();
        }
      }
    } else {
      // Just completed a break
      if (state.autoStartPomodoros) {
        startPomodoro(taskId: state.linkedTaskId);
      }
    }
  }

  /// Cancel the current session
  Future<void> cancelSession() async {
    if (state.activeSession == null) return;

    _timer?.cancel();

    final result = await _cancelFocusSession(state.activeSession!.id);

    result.fold(
      (failure) {
        state = state.copyWith(error: _getErrorMessage(failure));
      },
      (cancelledSession) {
        state = state.copyWith(
          activeSession: null,
          timerStatus: TimerStatus.idle,
          remainingTime: Duration.zero,
          elapsedTime: Duration.zero,
          linkedTaskId: null,
        );
      },
    );
  }

  /// Add an interruption to current session
  Future<void> addInterruption(String? reason) async {
    if (state.activeSession == null) return;

    final interruption = FocusInterruption(
      timestamp: DateTime.now(),
      reason: reason,
      pauseDuration: Duration.zero,
    );

    await _addInterruption(state.activeSession!.id, interruption);
  }

  /// Update Pomodoro settings
  void updateSettings({
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
  }) {
    state = state.copyWith(
      focusDuration: focusDuration ?? state.focusDuration,
      shortBreakDuration: shortBreakDuration ?? state.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? state.longBreakDuration,
      longBreakInterval: longBreakInterval ?? state.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? state.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? state.autoStartPomodoros,
    );
  }

  /// Link a task to current session
  void linkTask(String taskId) {
    state = state.copyWith(linkedTaskId: taskId);
  }

  /// Unlink task from current session
  void unlinkTask() {
    state = state.copyWith(linkedTaskId: null);
  }

  /// Reset completed pomodoros count
  void resetPomodoroCount() {
    state = state.copyWith(
      completedPomodoros: 0,
      pomodorosUntilLongBreak: state.longBreakInterval,
    );
  }

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is ConflictFailure) {
      return 'You already have an active session';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
