/// Focus Timer State Management
///
/// This module provides complete Pomodoro timer functionality including:
/// - Timer state management with countdown
/// - Session lifecycle (start, pause, resume, complete, cancel)
/// - Automatic break/focus transitions
/// - Pomodoro cycle tracking
/// - Session statistics and history
/// - Task linking for focused work
///
/// Key Components:
/// - [FocusTimerState]: Immutable state with timer data
/// - [FocusTimerNotifier]: Business logic for timer operations
/// - [focusTimerNotifierProvider]: Main provider for timer state
/// - 20+ derived providers for granular UI access
///
/// Usage:
/// ```dart
/// // Start a Pomodoro session
/// ref.read(focusTimerNotifierProvider.notifier).startPomodoro();
///
/// // Watch remaining time
/// final remainingTime = ref.watch(formattedRemainingTimeProvider);
///
/// // Pause/Resume
/// ref.read(focusTimerNotifierProvider.notifier).pauseSession();
/// ref.read(focusTimerNotifierProvider.notifier).resumeSession();
/// ```
library focus_timer;

export 'focus_timer_state.dart';
export 'focus_timer_notifier.dart';
export 'focus_timer_providers.dart';
