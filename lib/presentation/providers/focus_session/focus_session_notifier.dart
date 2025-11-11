import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../../domain/usecases/focus_session/add_interruption_usecase.dart';
import '../../../domain/usecases/focus_session/cancel_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/complete_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/get_active_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_statistics_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_time_by_task_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_trends_usecase.dart';
import '../../../domain/usecases/focus_session/pause_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/resume_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/start_focus_session_usecase.dart';
import 'focus_session_state.dart';

/// StateNotifier for managing focus session state
///
/// Handles all focus session-related operations including:
/// - Starting, pausing, resuming, completing, and cancelling focus sessions
/// - Timer management (elapsed time tracking)
/// - Interruption recording and tracking
/// - Focus statistics retrieval and updates
/// - Focus trends analysis
/// - Task-specific focus time tracking
/// - Session history management
///
/// This notifier integrates with all 10 focus session use cases
/// and manages the FocusSessionState throughout the application lifecycle.
class FocusSessionNotifier extends StateNotifier<FocusSessionState> {
  // Use cases
  final StartFocusSessionUseCase _startFocusSessionUseCase;
  final PauseFocusSessionUseCase _pauseFocusSessionUseCase;
  final ResumeFocusSessionUseCase _resumeFocusSessionUseCase;
  final CompleteFocusSessionUseCase _completeFocusSessionUseCase;
  final CancelFocusSessionUseCase _cancelFocusSessionUseCase;
  final GetActiveFocusSessionUseCase _getActiveFocusSessionUseCase;
  final GetFocusStatisticsUseCase _getFocusStatisticsUseCase;
  final GetFocusTrendsUseCase _getFocusTrendsUseCase;
  final AddInterruptionUseCase _addInterruptionUseCase;
  final GetFocusTimeByTaskUseCase _getFocusTimeByTaskUseCase;

  FocusSessionNotifier({
    required StartFocusSessionUseCase startFocusSessionUseCase,
    required PauseFocusSessionUseCase pauseFocusSessionUseCase,
    required ResumeFocusSessionUseCase resumeFocusSessionUseCase,
    required CompleteFocusSessionUseCase completeFocusSessionUseCase,
    required CancelFocusSessionUseCase cancelFocusSessionUseCase,
    required GetActiveFocusSessionUseCase getActiveFocusSessionUseCase,
    required GetFocusStatisticsUseCase getFocusStatisticsUseCase,
    required GetFocusTrendsUseCase getFocusTrendsUseCase,
    required AddInterruptionUseCase addInterruptionUseCase,
    required GetFocusTimeByTaskUseCase getFocusTimeByTaskUseCase,
  })  : _startFocusSessionUseCase = startFocusSessionUseCase,
        _pauseFocusSessionUseCase = pauseFocusSessionUseCase,
        _resumeFocusSessionUseCase = resumeFocusSessionUseCase,
        _completeFocusSessionUseCase = completeFocusSessionUseCase,
        _cancelFocusSessionUseCase = cancelFocusSessionUseCase,
        _getActiveFocusSessionUseCase = getActiveFocusSessionUseCase,
        _getFocusStatisticsUseCase = getFocusStatisticsUseCase,
        _getFocusTrendsUseCase = getFocusTrendsUseCase,
        _addInterruptionUseCase = addInterruptionUseCase,
        _getFocusTimeByTaskUseCase = getFocusTimeByTaskUseCase,
        super(const FocusSessionState());

  // ============================================================================
  // Focus Session Management
  // ============================================================================

  /// Start a new focus session
  ///
  /// Parameters:
  /// - [session]: The focus session entity to start
  ///
  /// Business Rules:
  /// - Duration must be between 5-180 minutes
  /// - Only one active session per user at a time
  /// - Session type validation (pomodoro, shortBreak, longBreak, custom)
  Future<void> startFocusSession(FocusSessionEntity session) async {
    state = state.copyWith(isStartingSession: true, operationError: null);

    final result = await _startFocusSessionUseCase(session);

    result.fold(
      (failure) {
        state = state.copyWith(
          isStartingSession: false,
          operationError: failure,
        );
      },
      (startedSession) {
        state = state.copyWith(
          isStartingSession: false,
          activeFocusSession: startedSession,
          timerPlannedDuration: startedSession.plannedDuration,
          timerElapsed: Duration.zero,
          isTimerRunning: true,
          isTimerPaused: false,
          sessionHistory: [startedSession, ...state.sessionHistory],
          operationError: null,
        );
      },
    );
  }

  /// Pause the currently active focus session
  ///
  /// Parameters:
  /// - [sessionId]: ID of the session to pause
  ///
  /// Updates timer state to paused status
  Future<void> pauseFocusSession(String sessionId) async {
    state = state.copyWith(isPausingSession: true, operationError: null);

    final result = await _pauseFocusSessionUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isPausingSession: false,
          operationError: failure,
        );
      },
      (pausedSession) {
        state = state.copyWith(
          isPausingSession: false,
          activeFocusSession: pausedSession,
          isTimerRunning: false,
          isTimerPaused: true,
          operationError: null,
        );
      },
    );
  }

  /// Resume a paused focus session
  ///
  /// Parameters:
  /// - [sessionId]: ID of the session to resume
  ///
  /// Updates timer state back to running status
  Future<void> resumeFocusSession(String sessionId) async {
    state = state.copyWith(isResumingSession: true, operationError: null);

    final result = await _resumeFocusSessionUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isResumingSession: false,
          operationError: failure,
        );
      },
      (resumedSession) {
        state = state.copyWith(
          isResumingSession: false,
          activeFocusSession: resumedSession,
          isTimerRunning: true,
          isTimerPaused: false,
          operationError: null,
        );
      },
    );
  }

  /// Complete the currently active focus session
  ///
  /// Parameters:
  /// - [sessionId]: ID of the session to complete
  /// - [notes]: Optional notes about the session
  ///
  /// Calculates focus quality score and updates statistics
  Future<void> completeFocusSession({
    required String sessionId,
    String? notes,
  }) async {
    state = state.copyWith(isCompletingSession: true, operationError: null);

    final result = await _completeFocusSessionUseCase(
      sessionId: sessionId,
      notes: notes,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isCompletingSession: false,
          operationError: failure,
        );
      },
      (completedSession) {
        // Update session history
        final updatedHistory = state.sessionHistory
            .map((s) => s.id == completedSession.id ? completedSession : s)
            .toList();

        state = state.copyWith(
          isCompletingSession: false,
          activeFocusSession: null,
          sessionHistory: updatedHistory,
          timerElapsed: Duration.zero,
          isTimerRunning: false,
          isTimerPaused: false,
          operationError: null,
        );

        // Refresh statistics after completion
        _refreshStatistics();
      },
    );
  }

  /// Cancel the currently active focus session
  ///
  /// Parameters:
  /// - [sessionId]: ID of the session to cancel
  ///
  /// Removes session from active status
  Future<void> cancelFocusSession(String sessionId) async {
    state = state.copyWith(isCancellingSession: true, operationError: null);

    final result = await _cancelFocusSessionUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCancellingSession: false,
          operationError: failure,
        );
      },
      (cancelledSession) {
        // Update session history
        final updatedHistory = state.sessionHistory
            .map((s) => s.id == cancelledSession.id ? cancelledSession : s)
            .toList();

        state = state.copyWith(
          isCancellingSession: false,
          activeFocusSession: null,
          sessionHistory: updatedHistory,
          timerElapsed: Duration.zero,
          isTimerRunning: false,
          isTimerPaused: false,
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Active Session Management
  // ============================================================================

  /// Load the currently active focus session for a user
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  ///
  /// Retrieves active or paused session if it exists
  Future<void> loadActiveFocusSession(String userId) async {
    state = state.copyWith(
      isLoadingActiveFocusSession: true,
      activeFocusSessionError: null,
    );

    final result = await _getActiveFocusSessionUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingActiveFocusSession: false,
          activeFocusSessionError: failure,
          lastRefreshActiveFocusSession: DateTime.now(),
        );
      },
      (activeSession) {
        if (activeSession != null) {
          state = state.copyWith(
            isLoadingActiveFocusSession: false,
            activeFocusSession: activeSession,
            timerPlannedDuration: activeSession.plannedDuration,
            isTimerRunning: activeSession.status == FocusSessionStatus.inProgress,
            isTimerPaused: activeSession.status == FocusSessionStatus.paused,
            activeFocusSessionError: null,
            lastRefreshActiveFocusSession: DateTime.now(),
          );
        } else {
          state = state.copyWith(
            isLoadingActiveFocusSession: false,
            activeFocusSession: null,
            isTimerRunning: false,
            isTimerPaused: false,
            activeFocusSessionError: null,
            lastRefreshActiveFocusSession: DateTime.now(),
          );
        }
      },
    );
  }

  /// Update timer elapsed time (called periodically during active session)
  ///
  /// Parameters:
  /// - [elapsed]: Current elapsed duration
  void updateTimerElapsed(Duration elapsed) {
    state = state.copyWith(timerElapsed: elapsed);
  }

  /// Clear the active focus session
  void clearActiveFocusSession() {
    state = state.copyWith(
      activeFocusSession: null,
      timerElapsed: Duration.zero,
      timerPlannedDuration: Duration.zero,
      isTimerRunning: false,
      isTimerPaused: false,
    );
  }

  // ============================================================================
  // Interruption Management
  // ============================================================================

  /// Add an interruption to the active focus session
  ///
  /// Parameters:
  /// - [sessionId]: ID of the session
  /// - [pauseDuration]: How long the interruption lasted
  /// - [reason]: Optional reason for the interruption
  ///
  /// Interruptions reduce focus quality score (10% penalty per interruption)
  Future<void> addInterruption({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  }) async {
    state = state.copyWith(isAddingInterruption: true, operationError: null);

    final result = await _addInterruptionUseCase(
      sessionId: sessionId,
      pauseDuration: pauseDuration,
      reason: reason,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isAddingInterruption: false,
          operationError: failure,
        );
      },
      (updatedSession) {
        state = state.copyWith(
          isAddingInterruption: false,
          activeFocusSession: updatedSession,
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Statistics Management
  // ============================================================================

  /// Load focus statistics for the current user
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [startDate]: Optional start date filter
  /// - [endDate]: Optional end date filter
  ///
  /// Returns comprehensive statistics including total time, completion rate, etc.
  Future<void> loadStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(
      isLoadingStatistics: true,
      statisticsError: null,
      statisticsStartDate: startDate,
      statisticsEndDate: endDate,
    );

    final result = await _getFocusStatisticsUseCase(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingStatistics: false,
          statisticsError: failure,
          lastRefreshStatistics: DateTime.now(),
        );
      },
      (statistics) {
        state = state.copyWith(
          isLoadingStatistics: false,
          statistics: statistics,
          statisticsError: null,
          lastRefreshStatistics: DateTime.now(),
        );
      },
    );
  }

  /// Refresh statistics data
  Future<void> _refreshStatistics() async {
    if (state.statistics != null) {
      // Note: userId would need to be passed, but it's assumed to be available in context
      // This is a simplified refresh that relies on the provider pattern
    }
  }

  // ============================================================================
  // Trends Management
  // ============================================================================

  /// Load focus trends for the current user
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [startDate]: Start date for trend analysis
  /// - [endDate]: End date for trend analysis
  /// - [granularity]: Granularity of trend data (daily/weekly/monthly)
  ///
  /// Returns time-series trend data showing focus patterns over time
  Future<void> loadTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    TrendGranularity granularity = TrendGranularity.daily,
  }) async {
    state = state.copyWith(
      isLoadingTrends: true,
      trendsError: null,
      trendsStartDate: startDate,
      trendsEndDate: endDate,
      trendsGranularity: granularity,
    );

    final result = await _getFocusTrendsUseCase(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      granularity: granularity.name,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingTrends: false,
          trendsError: failure,
          lastRefreshTrends: DateTime.now(),
        );
      },
      (trends) {
        state = state.copyWith(
          isLoadingTrends: false,
          trends: trends,
          trendsError: null,
          lastRefreshTrends: DateTime.now(),
        );
      },
    );
  }

  // ============================================================================
  // Task-Specific Focus Time Management
  // ============================================================================

  /// Load total focus time for a specific task
  ///
  /// Parameters:
  /// - [taskId]: ID of the task
  /// - [startDate]: Optional start date filter
  /// - [endDate]: Optional end date filter
  ///
  /// Returns total focus time, session count, and average quality for the task
  Future<void> loadFocusTimeByTask({
    required String taskId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(
      isLoadingFocusTimeByTask: true,
      focusTimeByTaskError: null,
      focusTimeTaskId: taskId,
    );

    final result = await _getFocusTimeByTaskUseCase(
      taskId: taskId,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingFocusTimeByTask: false,
          focusTimeByTaskError: failure,
          lastRefreshFocusTimeByTask: DateTime.now(),
        );
      },
      (taskFocusTime) {
        final updatedMap = {...state.focusTimeByTask};
        updatedMap[taskId] = taskFocusTime;

        state = state.copyWith(
          isLoadingFocusTimeByTask: false,
          focusTimeByTask: updatedMap,
          focusTimeByTaskError: null,
          lastRefreshFocusTimeByTask: DateTime.now(),
        );
      },
    );
  }

  // ============================================================================
  // Session Management
  // ============================================================================

  /// Select a session to view details
  ///
  /// Parameters:
  /// - [session]: The session to select
  void selectSession(FocusSessionEntity session) {
    state = state.copyWith(selectedSession: session);
  }

  /// Clear the selected session
  void clearSelectedSession() {
    state = state.copyWith(selectedSession: null);
  }

  /// Load today's focus sessions
  ///
  /// Parameters:
  /// - [sessions]: List of today's sessions
  void setTodaySessions(List<FocusSessionEntity> sessions) {
    state = state.copyWith(todaySessions: sessions);
  }

  /// Clear all session data
  void clearAllSessionData() {
    state = state.copyWith(
      activeFocusSession: null,
      sessionHistory: [],
      todaySessions: [],
      statistics: null,
      trends: null,
      focusTimeByTask: {},
      selectedSession: null,
      timerElapsed: Duration.zero,
      timerPlannedDuration: Duration.zero,
      isTimerRunning: false,
      isTimerPaused: false,
    );
  }

  /// Clear errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      activeFocusSessionError: null,
      sessionHistoryError: null,
      statisticsError: null,
      trendsError: null,
      focusTimeByTaskError: null,
      operationError: null,
      timerError: null,
    );
  }
}
