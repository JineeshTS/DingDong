import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/focus_session/start_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/pause_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/resume_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/complete_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/cancel_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/add_interruption_usecase.dart';
import '../../../domain/usecases/focus_session/get_active_focus_session_usecase.dart';
import '../../../domain/usecases/focus_session/get_focus_statistics_usecase.dart';
import '../../repositories_providers.dart';
import 'focus_timer_notifier.dart';
import 'focus_timer_state.dart';

// ====================
// Use Case Providers
// ====================

final startFocusSessionUseCaseProvider = Provider<StartFocusSessionUseCase>(
  (ref) => StartFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final pauseFocusSessionUseCaseProvider = Provider<PauseFocusSessionUseCase>(
  (ref) => PauseFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final resumeFocusSessionUseCaseProvider = Provider<ResumeFocusSessionUseCase>(
  (ref) => ResumeFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final completeFocusSessionUseCaseProvider =
    Provider<CompleteFocusSessionUseCase>(
  (ref) => CompleteFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final cancelFocusSessionUseCaseProvider = Provider<CancelFocusSessionUseCase>(
  (ref) => CancelFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final addInterruptionUseCaseProvider = Provider<AddInterruptionUseCase>(
  (ref) => AddInterruptionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final getActiveFocusSessionUseCaseProvider =
    Provider<GetActiveFocusSessionUseCase>(
  (ref) => GetActiveFocusSessionUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

final getFocusStatisticsUseCaseProvider = Provider<GetFocusStatisticsUseCase>(
  (ref) => GetFocusStatisticsUseCase(
    ref.watch(focusSessionRepositoryProvider),
  ),
);

// ====================
// State Notifier Provider
// ====================

/// Focus Timer Notifier Provider
///
/// Main provider for the Pomodoro timer state management
final focusTimerNotifierProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
  (ref) {
    // TODO: Get actual user ID from auth provider
    const userId = 'user_123';

    return FocusTimerNotifier(
      userId: userId,
      startFocusSession: ref.watch(startFocusSessionUseCaseProvider),
      pauseFocusSession: ref.watch(pauseFocusSessionUseCaseProvider),
      resumeFocusSession: ref.watch(resumeFocusSessionUseCaseProvider),
      completeFocusSession: ref.watch(completeFocusSessionUseCaseProvider),
      cancelFocusSession: ref.watch(cancelFocusSessionUseCaseProvider),
      addInterruption: ref.watch(addInterruptionUseCaseProvider),
      getActiveFocusSession: ref.watch(getActiveFocusSessionUseCaseProvider),
      getFocusStatistics: ref.watch(getFocusStatisticsUseCaseProvider),
    );
  },
);

// ====================
// Derived State Providers
// ====================

/// Active Session Provider
final activeSessionProvider = Provider.autoDispose((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.activeSession;
});

/// Timer Status Provider
final timerStatusProvider = Provider.autoDispose<TimerStatus>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.timerStatus;
});

/// Is Timer Running Provider
final isTimerRunningProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.isRunning;
});

/// Is Timer Paused Provider
final isTimerPausedProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.isPaused;
});

/// Remaining Time Provider
final remainingTimeProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.remainingTime;
});

/// Formatted Remaining Time Provider
final formattedRemainingTimeProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.formattedRemainingTime;
});

/// Elapsed Time Provider
final elapsedTimeProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.elapsedTime;
});

/// Progress Provider (0.0 to 1.0)
final timerProgressProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.progress;
});

/// Session Type Label Provider
final sessionTypeLabelProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.sessionTypeLabel;
});

/// Is Focus Session Provider
final isFocusSessionProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.isFocusSession;
});

/// Is Break Session Provider
final isBreakSessionProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.isBreakSession;
});

/// Completed Pomodoros Provider
final completedPomodorosProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.completedPomodoros;
});

/// Pomodoros Until Long Break Provider
final pomodorosUntilLongBreakProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.pomodorosUntilLongBreak;
});

/// Recent Sessions Provider
final recentSessionsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.recentSessions;
});

/// Total Sessions Today Provider
final totalSessionsTodayProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.totalSessionsToday;
});

/// Total Focus Time Today Provider
final totalFocusTimeTodayProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.totalFocusTimeToday;
});

/// Current Streak Provider
final currentStreakProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.currentStreak;
});

/// Linked Task ID Provider
final linkedTaskIdProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.linkedTaskId;
});

/// Focus Timer Settings Provider
final focusTimerSettingsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return {
    'focusDuration': state.focusDuration,
    'shortBreakDuration': state.shortBreakDuration,
    'longBreakDuration': state.longBreakDuration,
    'longBreakInterval': state.longBreakInterval,
    'autoStartBreaks': state.autoStartBreaks,
    'autoStartPomodoros': state.autoStartPomodoros,
  };
});

/// Is Loading Provider
final focusTimerLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.isLoading;
});

/// Error Provider
final focusTimerErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(focusTimerNotifierProvider);
  return state.error;
});
