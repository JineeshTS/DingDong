import 'package:flutter/material.dart';
import '../../../providers/focus_timer/focus_timer_state.dart';

/// Timer Controls Widget
///
/// Provides controls for the Pomodoro timer:
/// - Start/Pause/Resume button
/// - Stop button
/// - Skip button
class TimerControls extends StatelessWidget {
  final TimerStatus timerStatus;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback? onSkip;
  final bool isLoading;

  const TimerControls({
    super.key,
    required this.timerStatus,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    this.onSkip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button (only when timer is running or paused)
        if (timerStatus != TimerStatus.idle) ...[
          _buildStopButton(context),
          const SizedBox(width: 16),
        ],

        // Primary action button (Start/Pause/Resume)
        _buildPrimaryButton(context),

        // Skip button (only when timer is running or paused)
        if (timerStatus != TimerStatus.idle && onSkip != null) ...[
          const SizedBox(width: 16),
          _buildSkipButton(context),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    VoidCallback? onPressed;
    IconData icon;
    String label;

    switch (timerStatus) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        onPressed = onStart;
        icon = Icons.play_arrow_rounded;
        label = 'Start';
        break;
      case TimerStatus.running:
        onPressed = onPause;
        icon = Icons.pause_rounded;
        label = 'Pause';
        break;
      case TimerStatus.paused:
        onPressed = onResume;
        icon = Icons.play_arrow_rounded;
        label = 'Resume';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.large(
          onPressed: isLoading ? null : onPressed,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 36),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: isLoading ? null : onStop,
          backgroundColor:
              Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          child: const Icon(Icons.stop_rounded),
        ),
        const SizedBox(height: 8),
        Text(
          'Stop',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: isLoading ? null : onSkip,
          backgroundColor:
              Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          child: const Icon(Icons.skip_next_rounded),
        ),
        const SizedBox(height: 8),
        Text(
          'Skip',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
