import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
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
import 'focus_session_notifier.dart';
import 'focus_session_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for StartFocusSessionUseCase
///
/// Handles starting new focus sessions (5-180 minutes duration)
final startFocusSessionProvider = Provider.autoDispose<StartFocusSessionUseCase>(
  (ref) => sl<StartFocusSessionUseCase>(),
);

/// Provider for PauseFocusSessionUseCase
///
/// Handles pausing an active focus session
final pauseFocusSessionProvider = Provider.autoDispose<PauseFocusSessionUseCase>(
  (ref) => sl<PauseFocusSessionUseCase>(),
);

/// Provider for ResumeFocusSessionUseCase
///
/// Handles resuming a paused focus session
final resumeFocusSessionProvider =
    Provider.autoDispose<ResumeFocusSessionUseCase>(
  (ref) => sl<ResumeFocusSessionUseCase>(),
);

/// Provider for CompleteFocusSessionUseCase
///
/// Handles completing a focus session and calculating quality score
final completeFocusSessionProvider =
    Provider.autoDispose<CompleteFocusSessionUseCase>(
  (ref) => sl<CompleteFocusSessionUseCase>(),
);

/// Provider for CancelFocusSessionUseCase
///
/// Handles cancelling an active or paused focus session
final cancelFocusSessionProvider =
    Provider.autoDispose<CancelFocusSessionUseCase>(
  (ref) => sl<CancelFocusSessionUseCase>(),
);

/// Provider for GetActiveFocusSessionUseCase
///
/// Retrieves the currently active or paused focus session
final getActiveFocusSessionProvider =
    Provider.autoDispose<GetActiveFocusSessionUseCase>(
  (ref) => sl<GetActiveFocusSessionUseCase>(),
);

/// Provider for GetFocusStatisticsUseCase
///
/// Retrieves comprehensive focus statistics
final getFocusStatisticsProvider =
    Provider.autoDispose<GetFocusStatisticsUseCase>(
  (ref) => sl<GetFocusStatisticsUseCase>(),
);

/// Provider for GetFocusTrendsUseCase
///
/// Retrieves focus trends over time (daily/weekly/monthly)
final getFocusTrendsProvider = Provider.autoDispose<GetFocusTrendsUseCase>(
  (ref) => sl<GetFocusTrendsUseCase>(),
);

/// Provider for AddInterruptionUseCase
///
/// Handles recording interruptions during focus sessions
final addInterruptionProvider = Provider.autoDispose<AddInterruptionUseCase>(
  (ref) => sl<AddInterruptionUseCase>(),
);

/// Provider for GetFocusTimeByTaskUseCase
///
/// Retrieves total focus time for a specific task
final getFocusTimeByTaskProvider =
    Provider.autoDispose<GetFocusTimeByTaskUseCase>(
  (ref) => sl<GetFocusTimeByTaskUseCase>(),
);

// ============================================================================
// Focus Session State Notifier Provider
// ============================================================================

/// Main focus session state notifier provider
///
/// This is the primary provider for focus session state management.
/// It should NOT be auto-disposed as we want to maintain focus session
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final focusSessionState = ref.watch(focusSessionNotifierProvider);
/// final focusSessionNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// // Start a new focus session
/// await focusSessionNotifier.startFocusSession(session);
///
/// // Pause active session
/// await focusSessionNotifier.pauseFocusSession(sessionId);
///
/// // Load statistics
/// await focusSessionNotifier.loadStatistics(userId: userId);
/// ```
final focusSessionNotifierProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSessionState>(
  (ref) {
    return FocusSessionNotifier(
      startFocusSessionUseCase: ref.read(startFocusSessionProvider),
      pauseFocusSessionUseCase: ref.read(pauseFocusSessionProvider),
      resumeFocusSessionUseCase: ref.read(resumeFocusSessionProvider),
      completeFocusSessionUseCase: ref.read(completeFocusSessionProvider),
      cancelFocusSessionUseCase: ref.read(cancelFocusSessionProvider),
      getActiveFocusSessionUseCase: ref.read(getActiveFocusSessionProvider),
      getFocusStatisticsUseCase: ref.read(getFocusStatisticsProvider),
      getFocusTrendsUseCase: ref.read(getFocusTrendsProvider),
      addInterruptionUseCase: ref.read(addInterruptionProvider),
      getFocusTimeByTaskUseCase: ref.read(getFocusTimeByTaskProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Active Session
// ============================================================================

/// Provider that exposes the currently active focus session
///
/// Returns the active or paused session if it exists, null otherwise
///
/// Usage:
/// ```dart
/// final activeSession = ref.watch(activeFocusSessionProvider);
/// if (activeSession != null) {
///   Text('Session: ${activeSession.type.name}');
/// }
/// ```
final activeFocusSessionProvider = Provider<FocusSessionEntity?>(
  (ref) => ref.watch(focusSessionNotifierProvider).activeFocusSession,
);

/// Provider that exposes whether user has an active focus session
///
/// Returns true if there's an active (not paused) focus session
final hasActiveFocusSessionProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).hasActiveFocusSession,
);

/// Provider that exposes whether active session is paused
///
/// Returns true if the active session is in paused status
final isActiveFocusSessionPausedProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isActiveFocusSessionPaused,
);

// ============================================================================
// Derived State Providers - Timer
// ============================================================================

/// Provider that exposes current timer elapsed time
///
/// Used for real-time UI updates during focus sessions
final timerElapsedProvider = Provider<Duration>(
  (ref) => ref.watch(focusSessionNotifierProvider).timerElapsed,
);

/// Provider that exposes timer planned duration
///
/// Returns the total planned duration for the active session
final timerPlannedDurationProvider = Provider<Duration>(
  (ref) => ref.watch(focusSessionNotifierProvider).timerPlannedDuration,
);

/// Provider that exposes whether timer is running
///
/// Returns true if an active session is currently running
final isTimerRunningProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isTimerRunning,
);

/// Provider that exposes whether timer is paused
///
/// Returns true if the active session is paused
final isTimerPausedProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isTimerPaused,
);

/// Provider that exposes remaining time percentage
///
/// Returns a value between 0 and 1 representing progress
final timerProgressProvider = Provider<double>(
  (ref) {
    final state = ref.watch(focusSessionNotifierProvider);
    if (state.timerPlannedDuration.inSeconds == 0) return 0;
    return (state.timerElapsed.inSeconds /
            state.timerPlannedDuration.inSeconds)
        .clamp(0.0, 1.0);
  },
);

// ============================================================================
// Derived State Providers - Sessions
// ============================================================================

/// Provider that exposes session history
///
/// Returns all recorded focus sessions for the user
final sessionHistoryProvider = Provider<List<FocusSessionEntity>>(
  (ref) => ref.watch(focusSessionNotifierProvider).sessionHistory,
);

/// Provider that exposes today's focus sessions
///
/// Returns all focus sessions from today
final todaySessionsProvider = Provider<List<FocusSessionEntity>>(
  (ref) => ref.watch(focusSessionNotifierProvider).todaySessions,
);

/// Provider that exposes today's total focus time
///
/// Calculates total focus time from today's completed sessions
final todayTotalFocusTimeProvider = Provider<Duration>(
  (ref) {
    final sessions = ref.watch(todaySessionsProvider);
    Duration total = Duration.zero;
    for (final session in sessions) {
      if (session.isCompleted && session.actualDuration != null) {
        total += session.actualDuration!;
      }
    }
    return total;
  },
);

/// Provider that exposes today's session count
///
/// Returns number of sessions completed today
final todaySessionCountProvider = Provider<int>(
  (ref) {
    final sessions = ref.watch(todaySessionsProvider);
    return sessions.where((s) => s.isCompleted).length;
  },
);

/// Provider that exposes selected session
///
/// Returns the currently selected session for viewing details
final selectedSessionProvider = Provider<FocusSessionEntity?>(
  (ref) => ref.watch(focusSessionNotifierProvider).selectedSession,
);

// ============================================================================
// Derived State Providers - Statistics
// ============================================================================

/// Provider that exposes focus statistics
///
/// Returns comprehensive statistics including total time, completion rate, etc.
///
/// Usage:
/// ```dart
/// final stats = ref.watch(focusStatisticsProvider);
/// if (stats != null) {
///   Text('Total Time: ${stats.totalFocusTime}');
///   Text('Completion Rate: ${stats.completionRate}%');
/// }
/// ```
final focusStatisticsProvider = Provider<FocusStatistics?>(
  (ref) => ref.watch(focusSessionNotifierProvider).statistics,
);

/// Provider that exposes total focus time
///
/// Returns cumulative focus time from completed sessions
final totalFocusTimeProvider = Provider<Duration>(
  (ref) => ref.watch(focusSessionNotifierProvider).totalFocusTime,
);

/// Provider that exposes total session count
///
/// Returns total number of focus sessions
final totalSessionCountProvider = Provider<int>(
  (ref) => ref.watch(focusSessionNotifierProvider).totalSessionCount,
);

/// Provider that exposes completion rate
///
/// Returns completion rate as percentage (0-100)
final completionRateProvider = Provider<double>(
  (ref) => ref.watch(focusSessionNotifierProvider).completionRate,
);

/// Provider that exposes average focus quality score
///
/// Returns average quality score from all sessions
final averageQualityScoreProvider = Provider<double>(
  (ref) => ref.watch(focusSessionNotifierProvider).averageQualityScore,
);

/// Provider that exposes current focus streak
///
/// Returns number of consecutive days with at least one session
final currentStreakProvider = Provider<int>(
  (ref) => ref.watch(focusSessionNotifierProvider).currentStreak,
);

/// Provider that exposes longest focus streak
///
/// Returns longest streak achieved
final longestStreakProvider = Provider<int>(
  (ref) => ref.watch(focusSessionNotifierProvider).longestStreak,
);

// ============================================================================
// Derived State Providers - Trends
// ============================================================================

/// Provider that exposes focus trends
///
/// Returns time-series trend data showing focus patterns over time
final focusTrendsProvider = Provider<FocusTrends?>(
  (ref) => ref.watch(focusSessionNotifierProvider).trends,
);

/// Provider that exposes trends granularity
///
/// Returns the current granularity of trend data (daily/weekly/monthly)
final trendsGranularityProvider = Provider<TrendGranularity>(
  (ref) => ref.watch(focusSessionNotifierProvider).trendsGranularity,
);

// ============================================================================
// Derived State Providers - Task Focus Time
// ============================================================================

/// Provider that exposes focus time by task
///
/// Returns a map of task IDs to their focus time data
final focusTimeByTaskProvider = Provider<Map<String, TaskFocusTime>>(
  (ref) => ref.watch(focusSessionNotifierProvider).focusTimeByTask,
);

/// Provider family for focus time for a specific task
///
/// Parameters:
/// - [taskId]: The ID of the task
///
/// Usage:
/// ```dart
/// final focusTime = ref.watch(focusTimeForTaskProvider(taskId));
/// Text('Focus Time: ${focusTime.totalFocusTime}');
/// ```
final focusTimeForTaskProvider = Provider.family<Duration, String>(
  (ref, taskId) =>
      ref.watch(focusSessionNotifierProvider).getFocusTimeForTask(taskId),
);

/// Provider family for session count for a specific task
///
/// Parameters:
/// - [taskId]: The ID of the task
final sessionCountForTaskProvider = Provider.family<int, String>(
  (ref, taskId) =>
      ref.watch(focusSessionNotifierProvider).getSessionCountForTask(taskId),
);

/// Provider family for average quality for a specific task
///
/// Parameters:
/// - [taskId]: The ID of the task
final averageQualityForTaskProvider = Provider.family<double, String>(
  (ref, taskId) =>
      ref.watch(focusSessionNotifierProvider).getAverageQualityForTask(taskId),
);

// ============================================================================
// Loading State Providers
// ============================================================================

/// Provider that exposes active focus session loading state
///
/// Returns true while loading the active focus session
final isLoadingActiveFocusSessionProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingActiveFocusSession,
);

/// Provider that exposes session history loading state
///
/// Returns true while loading session history
final isLoadingSessionHistoryProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingSessionHistory,
);

/// Provider that exposes statistics loading state
///
/// Returns true while loading statistics
final isLoadingStatisticsProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingStatistics,
);

/// Provider that exposes trends loading state
///
/// Returns true while loading trends
final isLoadingTrendsProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingTrends,
);

/// Provider that exposes focus time by task loading state
///
/// Returns true while loading task focus time
final isLoadingFocusTimeByTaskProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingFocusTimeByTask,
);

/// Provider that exposes today's sessions loading state
///
/// Returns true while loading today's sessions
final isLoadingTodaySessionsProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isLoadingTodaySessions,
);

/// Provider that checks if any focus session operation is in progress
///
/// Returns true if starting, pausing, resuming, completing, cancelling, etc.
final isAnyFocusSessionOperationInProgressProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isAnyOperationInProgress,
);

/// Provider that checks if any data is loading
///
/// Returns true if any list or data load is in progress
final isAnyFocusSessionDataLoadingProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).isAnyLoading,
);

// ============================================================================
// Error State Providers
// ============================================================================

/// Provider that exposes general focus session error
///
/// Returns the general error if any operation failed
final focusSessionErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).error,
);

/// Provider that exposes active focus session loading error
///
/// Returns error if loading active session failed
final activeFocusSessionErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).activeFocusSessionError,
);

/// Provider that exposes session history loading error
///
/// Returns error if loading session history failed
final sessionHistoryErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).sessionHistoryError,
);

/// Provider that exposes statistics loading error
///
/// Returns error if loading statistics failed
final statisticsErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).statisticsError,
);

/// Provider that exposes trends loading error
///
/// Returns error if loading trends failed
final trendsErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).trendsError,
);

/// Provider that exposes focus time by task loading error
///
/// Returns error if loading task focus time failed
final focusTimeByTaskErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).focusTimeByTaskError,
);

/// Provider that exposes operation error
///
/// Returns error if any operation (start, pause, complete, etc.) failed
final focusSessionOperationErrorProvider = Provider<Failure?>(
  (ref) => ref.watch(focusSessionNotifierProvider).operationError,
);

/// Provider that checks if there are any focus session errors
///
/// Returns true if any error exists
final hasAnyFocusSessionErrorProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).hasAnyError,
);

// ============================================================================
// Computed Providers
// ============================================================================

/// Provider that exposes interrupted sessions
///
/// Returns sessions that had one or more interruptions
final interruptedSessionsProvider = Provider<List<FocusSessionEntity>>(
  (ref) {
    final history = ref.watch(sessionHistoryProvider);
    return history.where((s) => s.interruptionsCount > 0).toList();
  },
);

/// Provider that exposes completed sessions
///
/// Returns all completed focus sessions
final completedSessionsProvider = Provider<List<FocusSessionEntity>>(
  (ref) {
    final history = ref.watch(sessionHistoryProvider);
    return history.where((s) => s.isCompleted).toList();
  },
);

/// Provider that exposes cancelled sessions
///
/// Returns all cancelled focus sessions
final cancelledSessionsProvider = Provider<List<FocusSessionEntity>>(
  (ref) {
    final history = ref.watch(sessionHistoryProvider);
    return history
        .where((s) => s.status == FocusSessionStatus.cancelled)
        .toList();
  },
);

/// Provider that exposes average interruptions per session
///
/// Returns the average number of interruptions across all sessions
final averageInterruptionsProvider = Provider<double>(
  (ref) {
    final completed = ref.watch(completedSessionsProvider);
    if (completed.isEmpty) return 0;
    final total =
        completed.fold(0, (sum, s) => sum + s.interruptionsCount);
    return total / completed.length;
  },
);

/// Provider that exposes sessions by type
///
/// Returns a map of session type to list of sessions
final sessionsByTypeProvider = Provider<Map<FocusSessionType, List<FocusSessionEntity>>>(
  (ref) {
    final history = ref.watch(sessionHistoryProvider);
    final map = <FocusSessionType, List<FocusSessionEntity>>{};
    for (final type in FocusSessionType.values) {
      map[type] = history.where((s) => s.type == type).toList();
    }
    return map;
  },
);

/// Provider that exposes refresh needed status for active session
///
/// Returns true if active focus session data needs refresh
final needsRefreshActiveFocusSessionProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).needsRefreshActiveFocusSession,
);

/// Provider that exposes refresh needed status for statistics
///
/// Returns true if statistics data needs refresh
final needsRefreshStatisticsProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).needsRefreshStatistics,
);

/// Provider that exposes refresh needed status for trends
///
/// Returns true if trends data needs refresh
final needsRefreshTrendsProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).needsRefreshTrends,
);

/// Provider that exposes refresh needed status for task focus time
///
/// Returns true if task focus time data needs refresh
final needsRefreshFocusTimeByTaskProvider = Provider<bool>(
  (ref) => ref.watch(focusSessionNotifierProvider).needsRefreshFocusTimeByTask,
);

/// Provider that exposes highest quality session
///
/// Returns the session with the highest focus quality score
final highestQualitySessionProvider = Provider<FocusSessionEntity?>(
  (ref) {
    final completed = ref.watch(completedSessionsProvider);
    if (completed.isEmpty) return null;
    return completed.reduce((a, b) => a.focusQuality > b.focusQuality ? a : b);
  },
);

/// Provider that exposes lowest quality session
///
/// Returns the session with the lowest focus quality score
final lowestQualitySessionProvider = Provider<FocusSessionEntity?>(
  (ref) {
    final completed = ref.watch(completedSessionsProvider);
    if (completed.isEmpty) return null;
    return completed.reduce((a, b) => a.focusQuality < b.focusQuality ? a : b);
  },
);
