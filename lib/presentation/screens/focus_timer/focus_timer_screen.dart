import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../providers/focus_timer/focus_timer_providers.dart';
import '../../providers/focus_timer/focus_timer_state.dart';
import 'widgets/circular_timer.dart';
import 'widgets/timer_controls.dart';
import 'widgets/session_type_selector.dart';
import 'widgets/focus_stats_card.dart';

/// Focus Timer Screen
///
/// Main screen for the Pomodoro timer feature with:
/// - Circular timer display
/// - Session controls (start, pause, resume, stop)
/// - Session type selection
/// - Statistics and progress tracking
/// - Task linking
class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  FocusSessionType _selectedType = FocusSessionType.pomodoro;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusTimerNotifierProvider);
    final notifier = ref.read(focusTimerNotifierProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen<String?>(focusTimerErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettingsDialog(context, notifier),
          ),
          // History button
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              // TODO: Navigate to focus session history
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.loadStatistics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Circular Timer
                _buildTimerSection(context, state, notifier),

                const SizedBox(height: 32),

                // Timer Controls
                TimerControls(
                  timerStatus: state.timerStatus,
                  onStart: () => _startSession(notifier),
                  onPause: () => notifier.pauseSession(),
                  onResume: () => notifier.resumeSession(),
                  onStop: () => _showStopConfirmation(context, notifier),
                  onSkip: state.hasActiveSession
                      ? () => _showStopConfirmation(context, notifier)
                      : null,
                  isLoading: state.isLoading,
                ),

                const SizedBox(height: 32),

                // Session Type Selector (only when idle)
                if (state.timerStatus == TimerStatus.idle) ...[
                  Text(
                    'Start a Session',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SessionTypeSelector(
                    currentType: _selectedType,
                    onTypeSelected: (type) {
                      setState(() => _selectedType = type);
                    },
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 24),
                ],

                // Task Link Section (only when not idle)
                if (state.hasActiveSession && state.linkedTaskId != null) ...[
                  _buildTaskLinkCard(context, state),
                  const SizedBox(height: 16),
                ],

                // Statistics Card
                FocusStatsCard(
                  completedPomodoros: state.completedPomodoros,
                  totalSessionsToday: state.totalSessionsToday,
                  totalFocusTimeToday: state.totalFocusTimeToday,
                  currentStreak: state.currentStreak,
                  pomodorosUntilLongBreak: state.pomodorosUntilLongBreak,
                ),

                const SizedBox(height: 16),

                // Tips Card
                _buildTipsCard(context, state),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(
    BuildContext context,
    FocusTimerState state,
    FocusTimerNotifier notifier,
  ) {
    Color timerColor;
    switch (state.currentSessionType) {
      case FocusSessionType.pomodoro:
      case FocusSessionType.custom:
        timerColor = Theme.of(context).colorScheme.primary;
        break;
      case FocusSessionType.shortBreak:
        timerColor = Colors.green;
        break;
      case FocusSessionType.longBreak:
        timerColor = Colors.blue;
        break;
      case null:
        timerColor = Theme.of(context).colorScheme.primary;
    }

    return Center(
      child: CircularTimer(
        progress: state.progress,
        timeText: state.formattedRemainingTime,
        label: state.sessionTypeLabel,
        color: timerColor,
      ),
    );
  }

  Widget _buildTaskLinkCard(BuildContext context, FocusTimerState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.link_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linked Task',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  Text(
                    state.linkedTaskId ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                ref.read(focusTimerNotifierProvider.notifier).unlinkTask();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, FocusTimerState state) {
    String tip;
    IconData icon;

    if (state.timerStatus == TimerStatus.idle) {
      tip = 'Click Start to begin a focused work session. '
          'Stay focused and avoid distractions!';
      icon = Icons.lightbulb_outline_rounded;
    } else if (state.isFocusSession) {
      tip = 'Focus on a single task. Minimize distractions and stay in the zone!';
      icon = Icons.psychology_rounded;
    } else {
      tip = 'Take a break! Stand up, stretch, or take a short walk. '
          'Your brain needs rest too.';
      icon = Icons.spa_rounded;
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession(FocusTimerNotifier notifier) {
    switch (_selectedType) {
      case FocusSessionType.pomodoro:
        notifier.startPomodoro();
        break;
      case FocusSessionType.shortBreak:
        notifier.startShortBreak();
        break;
      case FocusSessionType.longBreak:
        notifier.startLongBreak();
        break;
      case FocusSessionType.custom:
        _showCustomDurationDialog(context, notifier);
        break;
    }
  }

  void _showStopConfirmation(BuildContext context, FocusTimerNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Session?'),
        content: const Text(
          'Are you sure you want to stop the current session? '
          'Your progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.cancelSession();
              Navigator.pop(context);
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _showCustomDurationDialog(
    BuildContext context,
    FocusTimerNotifier notifier,
  ) {
    int minutes = 25;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Duration'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes minutes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: minutes.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: '$minutes min',
                onChanged: (value) {
                  setState(() => minutes = value.toInt());
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.startCustomSession(
                duration: Duration(minutes: minutes),
              );
              Navigator.pop(context);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, FocusTimerNotifier notifier) {
    final state = ref.read(focusTimerNotifierProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Durations',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Focus Duration'),
                subtitle: Text('${state.focusDuration.inMinutes} minutes'),
                leading: const Icon(Icons.timer_rounded),
              ),
              ListTile(
                title: const Text('Short Break'),
                subtitle: Text('${state.shortBreakDuration.inMinutes} minutes'),
                leading: const Icon(Icons.coffee_rounded),
              ),
              ListTile(
                title: const Text('Long Break'),
                subtitle: Text('${state.longBreakDuration.inMinutes} minutes'),
                leading: const Icon(Icons.spa_rounded),
              ),
              const Divider(),
              Text(
                'Auto-Start',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SwitchListTile(
                title: const Text('Auto-start breaks'),
                value: state.autoStartBreaks,
                onChanged: (value) {
                  notifier.updateSettings(autoStartBreaks: value);
                },
              ),
              SwitchListTile(
                title: const Text('Auto-start pomodoros'),
                value: state.autoStartPomodoros,
                onChanged: (value) {
                  notifier.updateSettings(autoStartPomodoros: value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
