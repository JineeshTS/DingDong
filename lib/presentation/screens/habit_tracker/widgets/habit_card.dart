import 'package:flutter/material.dart';
import '../../../../domain/entities/habit_entity.dart';

/// Habit Card Widget
///
/// Displays a habit with check-in button and streak information
class HabitCard extends StatelessWidget {
  final HabitEntity habit;
  final VoidCallback onTap;
  final VoidCallback onCheckIn;
  final bool isCheckingIn;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onCheckIn,
    this.isCheckingIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final habitColor = _parseColor(habit.color);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Check-in button
              _buildCheckInButton(context, habitColor),

              const SizedBox(width: 16),

              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (habit.icon != null) ...[
                          Text(
                            habit.icon!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            habit.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (habit.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Streak
                        if (habit.currentStreak > 0) ...[
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} day streak',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Frequency
                        Icon(
                          _getFrequencyIcon(habit.frequency),
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFrequencyLabel(habit.frequency),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.chevron_right_rounded,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context, Color habitColor) {
    final isCompleted = habit.isCompletedToday;

    return InkWell(
      onTap: isCompleted ? null : onCheckIn,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isCompleted
              ? habitColor
              : habitColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: habitColor,
            width: 2,
          ),
        ),
        child: isCheckingIn
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(habitColor),
                  ),
                ),
              )
            : Icon(
                isCompleted
                    ? Icons.check_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: isCompleted ? Colors.white : habitColor,
                size: 32,
              ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50);
    }
  }

  IconData _getFrequencyIcon(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return Icons.today_rounded;
      case HabitFrequency.weekly:
        return Icons.calendar_view_week_rounded;
      case HabitFrequency.monthly:
        return Icons.calendar_month_rounded;
      case HabitFrequency.custom:
        return Icons.edit_calendar_rounded;
    }
  }

  String _getFrequencyLabel(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }
}
