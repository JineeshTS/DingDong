/// Focus Session providers module
///
/// Exports all focus session-related providers, state, and notifiers.
///
/// This module provides comprehensive focus session and Pomodoro timer functionality including:
/// - Focus session management (Start, Pause, Resume, Complete, Cancel)
/// - Pomodoro timer with adjustable duration (5-180 minutes)
/// - Real-time timer tracking with pause/resume
/// - Interruption recording and tracking (affects quality score)
/// - Focus quality score calculation
/// - Session state management (inProgress, paused, completed, cancelled)
/// - Focus statistics and trends analysis
/// - Task-specific focus time tracking
/// - Session history and analytics
/// - Real-time session updates
///
/// ## Architecture
///
/// The focus session providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`FocusSessionState`)
/// - **Notifier**: Business logic and state updates (`FocusSessionNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (10 focus session use cases)
///
/// ## 10 Integrated Use Cases
///
/// 1. **StartFocusSessionUseCase** - Begin a new focus session (5-180 mins)
/// 2. **PauseFocusSessionUseCase** - Pause an active session
/// 3. **ResumeFocusSessionUseCase** - Resume a paused session
/// 4. **CompleteFocusSessionUseCase** - Complete session with quality score
/// 5. **CancelFocusSessionUseCase** - Cancel an active/paused session
/// 6. **GetActiveFocusSessionUseCase** - Retrieve current session
/// 7. **GetFocusStatisticsUseCase** - Get comprehensive statistics
/// 8. **GetFocusTrendsUseCase** - Get daily/weekly/monthly trends
/// 9. **AddInterruptionUseCase** - Record interruption (affects quality)
/// 10. **GetFocusTimeByTaskUseCase** - Get time spent on specific task
///
/// ## Usage Examples
///
/// ### Starting a Focus Session
///
/// ```dart
/// final focusNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// final session = FocusSessionEntity(
///   id: 'session-1',
///   userId: 'user-123',
///   taskId: 'task-456',
///   type: FocusSessionType.pomodoro,
///   startTime: DateTime.now(),
///   plannedDuration: Duration(minutes: 25),
///   status: FocusSessionStatus.inProgress,
///   createdAt: DateTime.now(),
/// );
///
/// await focusNotifier.startFocusSession(session);
/// ```
///
/// ### Watching Active Session
///
/// ```dart
/// class ActiveSessionWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final activeSession = ref.watch(activeFocusSessionProvider);
///     final timerProgress = ref.watch(timerProgressProvider);
///     final isRunning = ref.watch(isTimerRunningProvider);
///
///     if (activeSession == null) {
///       return Text('No active session');
///     }
///
///     return Column(
///       children: [
///         Text('Session Type: ${activeSession.type.name}'),
///         LinearProgressIndicator(value: timerProgress),
///         if (isRunning)
///           ElevatedButton(
///             onPressed: () => ref
///                 .read(focusSessionNotifierProvider.notifier)
///                 .pauseFocusSession(activeSession.id),
///             child: Text('Pause'),
///           ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ### Loading Statistics
///
/// ```dart
/// final focusNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// await focusNotifier.loadStatistics(
///   userId: 'user-123',
///   startDate: DateTime.now().subtract(Duration(days: 7)),
///   endDate: DateTime.now(),
/// );
///
/// final stats = ref.watch(focusStatisticsProvider);
/// print('Total Time: ${stats?.totalFocusTime}');
/// print('Completion Rate: ${stats?.completionRate}%');
/// print('Current Streak: ${stats?.currentStreak} days');
/// ```
///
/// ### Recording Interruption
///
/// ```dart
/// final focusNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// await focusNotifier.addInterruption(
///   sessionId: activeSession.id,
///   pauseDuration: Duration(minutes: 5),
///   reason: 'Phone call',
/// );
/// ```
///
/// ### Tracking Task Focus Time
///
/// ```dart
/// final focusNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// await focusNotifier.loadFocusTimeByTask(
///   taskId: 'task-123',
///   startDate: DateTime.now().subtract(Duration(days: 30)),
///   endDate: DateTime.now(),
/// );
///
/// final focusTime = ref.watch(focusTimeForTaskProvider('task-123'));
/// print('Total Focus: ${focusTime.totalFocusTime}');
/// print('Sessions: ${focusTime.sessionCount}');
/// ```
///
/// ### Viewing Focus Trends
///
/// ```dart
/// final focusNotifier = ref.read(focusSessionNotifierProvider.notifier);
///
/// await focusNotifier.loadTrends(
///   userId: 'user-123',
///   startDate: DateTime.now().subtract(Duration(days: 30)),
///   endDate: DateTime.now(),
///   granularity: TrendGranularity.daily,
/// );
///
/// final trends = ref.watch(focusTrendsProvider);
/// // Use trends data for charts/analytics
/// ```
///
/// ## Available Providers
///
/// ### Main State Provider
/// - `focusSessionNotifierProvider` - Main focus session state and notifier
///
/// ### Active Session Providers
/// - `activeFocusSessionProvider` - Current active session
/// - `hasActiveFocusSessionProvider` - Boolean for active session existence
/// - `isActiveFocusSessionPausedProvider` - Boolean for paused status
///
/// ### Timer Providers
/// - `timerElapsedProvider` - Current elapsed time
/// - `timerPlannedDurationProvider` - Total planned duration
/// - `isTimerRunningProvider` - Timer running status
/// - `isTimerPausedProvider` - Timer paused status
/// - `timerProgressProvider` - Progress as 0-1 value
///
/// ### Session List Providers
/// - `sessionHistoryProvider` - All user sessions
/// - `todaySessionsProvider` - Sessions from today
/// - `completedSessionsProvider` - Completed sessions
/// - `cancelledSessionsProvider` - Cancelled sessions
/// - `interruptedSessionsProvider` - Sessions with interruptions
/// - `sessionsByTypeProvider` - Sessions grouped by type
/// - `selectedSessionProvider` - Currently selected session
///
/// ### Statistics Providers
/// - `focusStatisticsProvider` - Comprehensive statistics
/// - `totalFocusTimeProvider` - Total focus time (Duration)
/// - `totalSessionCountProvider` - Total session count
/// - `completionRateProvider` - Completion rate (0-100)
/// - `averageQualityScoreProvider` - Average quality score
/// - `currentStreakProvider` - Current consecutive days
/// - `longestStreakProvider` - Longest streak achieved
/// - `todayTotalFocusTimeProvider` - Today's total focus time
/// - `todaySessionCountProvider` - Today's session count
/// - `averageInterruptionsProvider` - Average interruptions per session
/// - `highestQualitySessionProvider` - Best quality session
/// - `lowestQualitySessionProvider` - Lowest quality session
///
/// ### Trends Providers
/// - `focusTrendsProvider` - Trend data (daily/weekly/monthly)
/// - `trendsGranularityProvider` - Current trend granularity
///
/// ### Task Focus Time Providers
/// - `focusTimeByTaskProvider` - Map of all task focus times
/// - `focusTimeForTaskProvider(taskId)` - Focus time for specific task
/// - `sessionCountForTaskProvider(taskId)` - Session count for task
/// - `averageQualityForTaskProvider(taskId)` - Quality for task
///
/// ### Loading State Providers
/// - `isLoadingActiveFocusSessionProvider` - Active session loading
/// - `isLoadingSessionHistoryProvider` - History loading
/// - `isLoadingStatisticsProvider` - Statistics loading
/// - `isLoadingTrendsProvider` - Trends loading
/// - `isLoadingFocusTimeByTaskProvider` - Task time loading
/// - `isLoadingTodaySessionsProvider` - Today's sessions loading
/// - `isAnyFocusSessionOperationInProgressProvider` - Any operation
/// - `isAnyFocusSessionDataLoadingProvider` - Any data loading
///
/// ### Error State Providers
/// - `focusSessionErrorProvider` - General error
/// - `activeFocusSessionErrorProvider` - Active session error
/// - `sessionHistoryErrorProvider` - History loading error
/// - `statisticsErrorProvider` - Statistics loading error
/// - `trendsErrorProvider` - Trends loading error
/// - `focusTimeByTaskErrorProvider` - Task time loading error
/// - `focusSessionOperationErrorProvider` - Operation error
/// - `hasAnyFocusSessionErrorProvider` - Any error exists
///
/// ### Refresh Status Providers
/// - `needsRefreshActiveFocusSessionProvider` - Active session refresh needed
/// - `needsRefreshStatisticsProvider` - Statistics refresh needed
/// - `needsRefreshTrendsProvider` - Trends refresh needed
/// - `needsRefreshFocusTimeByTaskProvider` - Task time refresh needed
///
/// ## Best Practices
///
/// 1. **Timer Management**
///    - Update elapsed time from external timer (not managed by notifier)
///    - Use `updateTimerElapsed()` for real-time updates
///    - Check `isTimerRunning` before updating
///
/// 2. **Session Lifecycle**
///    - Start → (Pause/Resume)* → Complete/Cancel
///    - Can only add interruptions to in-progress sessions
///    - Quality score calculated automatically on completion
///
/// 3. **Data Refresh**
///    - Check `needsRefreshXxx` providers before loading
///    - 5-minute threshold for auto-refresh consideration
///    - Statistics require explicit date range
///
/// 4. **Error Handling**
///    - Listen to error providers with `ref.listen()`
///    - Show user-friendly error messages
///    - Clear errors after handling with `clearErrors()`
///
/// 5. **Performance**
///    - Use specific providers instead of watching entire state
///    - Leverage auto-dispose providers for temporary data
///    - Use family providers for task-specific data
///    - Paginate large session histories if needed
///
/// 6. **Statistics & Analytics**
///    - Completion rate = completed / (completed + cancelled)
///    - Quality score = (duration_ratio * (1 - interruption_penalty)) * 100
///    - Streak = consecutive days with at least one session
///    - Trends can be daily, weekly, or monthly
///
/// 7. **Interruptions**
///    - Each interruption = 10% quality penalty
///    - Reason is optional but recommended
///    - Pause duration must be > 0 and < session duration
///
/// 8. **Task Linking**
///    - Sessions can be linked to tasks (taskId is optional)
///    - Track total focus time per task
///    - Useful for project time estimation
export 'focus_session_notifier.dart';
export 'focus_session_providers.dart';
export 'focus_session_state.dart';
