import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../../domain/usecases/focus_session/get_focus_statistics_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_time_by_task_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_trends_usecase.dart';

part 'focus_session_state.freezed.dart';

/// Focus Session state for the application
///
/// Manages focus session operations, Pomodoro timer, interruption tracking,
/// and focus statistics/trends with comprehensive state management.
///
/// Features:
/// - Pomodoro timer with pause/resume functionality
/// - Session state management (in progress, paused, completed, cancelled)
/// - Interruption tracking with quality score calculation
/// - Focus statistics and trends
/// - Task-linked focus time tracking
/// - Real-time session updates
@freezed
class FocusSessionState with _$FocusSessionState {
  const factory FocusSessionState({
    /// Currently active or paused focus session
    FocusSessionEntity? activeFocusSession,

    /// History of focus sessions for the current user
    @Default([]) List<FocusSessionEntity> sessionHistory,

    /// Today's focus sessions
    @Default([]) List<FocusSessionEntity> todaySessions,

    /// Focus statistics
    FocusStatistics? statistics,

    /// Focus trends data
    FocusTrends? trends,

    /// Focus time per task
    @Default({}) Map<String, TaskFocusTime> focusTimeByTask,

    /// Current timer elapsed time (for UI updates)
    @Default(Duration.zero) Duration timerElapsed,

    /// Current timer total planned duration
    @Default(Duration.zero) Duration timerPlannedDuration,

    /// Whether the timer is running
    @Default(false) bool isTimerRunning,

    /// Whether the timer is paused
    @Default(false) bool isTimerPaused,

    /// Current focus session being edited/viewed
    FocusSessionEntity? selectedSession,

    /// Date range filter for statistics
    DateTime? statisticsStartDate,
    DateTime? statisticsEndDate,

    /// Date range filter for trends
    DateTime? trendsStartDate,
    DateTime? trendsEndDate,

    /// Granularity for trends (daily, weekly, monthly)
    @Default(TrendGranularity.daily) TrendGranularity trendsGranularity,

    /// Filter focus time by this task ID
    String? focusTimeTaskId,

    /// Loading states
    @Default(false) bool isLoadingActiveFocusSession,
    @Default(false) bool isLoadingSessionHistory,
    @Default(false) bool isLoadingStatistics,
    @Default(false) bool isLoadingTrends,
    @Default(false) bool isLoadingFocusTimeByTask,
    @Default(false) bool isLoadingTodaySessions,

    /// Operation loading states
    @Default(false) bool isStartingSession,
    @Default(false) bool isPausingSession,
    @Default(false) bool isResumingSession,
    @Default(false) bool isCompletingSession,
    @Default(false) bool isCancellingSession,
    @Default(false) bool isAddingInterruption,

    /// Error states
    Failure? error,
    Failure? activeFocusSessionError,
    Failure? sessionHistoryError,
    Failure? statisticsError,
    Failure? trendsError,
    Failure? focusTimeByTaskError,
    Failure? operationError,
    Failure? timerError,

    /// Last refresh timestamps
    DateTime? lastRefreshActiveFocusSession,
    DateTime? lastRefreshStatistics,
    DateTime? lastRefreshTrends,
    DateTime? lastRefreshFocusTimeByTask,
  }) = _FocusSessionState;

  const FocusSessionState._();

  /// Check if any focus session list is loading
  bool get isAnyLoading =>
      isLoadingActiveFocusSession ||
      isLoadingSessionHistory ||
      isLoadingStatistics ||
      isLoadingTrends ||
      isLoadingFocusTimeByTask ||
      isLoadingTodaySessions;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isStartingSession ||
      isPausingSession ||
      isResumingSession ||
      isCompletingSession ||
      isCancellingSession ||
      isAddingInterruption;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      activeFocusSessionError != null ||
      sessionHistoryError != null ||
      statisticsError != null ||
      trendsError != null ||
      focusTimeByTaskError != null ||
      operationError != null ||
      timerError != null;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if active focus session needs refresh
  bool get needsRefreshActiveFocusSession =>
      needsRefresh(lastRefreshActiveFocusSession);

  /// Check if statistics need refresh
  bool get needsRefreshStatistics => needsRefresh(lastRefreshStatistics);

  /// Check if trends need refresh
  bool get needsRefreshTrends => needsRefresh(lastRefreshTrends);

  /// Check if focus time by task needs refresh
  bool get needsRefreshFocusTimeByTask =>
      needsRefresh(lastRefreshFocusTimeByTask);

  /// Get total focus time across all sessions
  Duration get totalFocusTime {
    if (statistics == null) return Duration.zero;
    return statistics!.totalFocusTime;
  }

  /// Get session count
  int get totalSessionCount {
    if (statistics == null) return 0;
    return statistics!.totalSessionCount;
  }

  /// Get completion rate
  double get completionRate {
    if (statistics == null) return 0.0;
    return statistics!.completionRate;
  }

  /// Get average quality score
  double get averageQualityScore {
    if (statistics == null) return 0.0;
    return statistics!.averageQualityScore;
  }

  /// Get current streak
  int get currentStreak {
    if (statistics == null) return 0;
    return statistics!.currentStreak;
  }

  /// Get longest streak
  int get longestStreak {
    if (statistics == null) return 0;
    return statistics!.longestStreak;
  }

  /// Check if user has an active focus session
  bool get hasActiveFocusSession =>
      activeFocusSession != null && activeFocusSession!.isActive;

  /// Check if active session is paused
  bool get isActiveFocusSessionPaused =>
      activeFocusSession != null &&
      activeFocusSession!.status == FocusSessionStatus.paused;

  /// Get focus time for a specific task
  Duration getFocusTimeForTask(String taskId) {
    return focusTimeByTask[taskId]?.totalFocusTime ?? Duration.zero;
  }

  /// Get session count for a specific task
  int getSessionCountForTask(String taskId) {
    return focusTimeByTask[taskId]?.sessionCount ?? 0;
  }

  /// Get average quality for a specific task
  double getAverageQualityForTask(String taskId) {
    return focusTimeByTask[taskId]?.averageQualityScore ?? 0.0;
  }
}

/// Trend granularity options
enum TrendGranularity {
  daily,
  weekly,
  monthly,
}
