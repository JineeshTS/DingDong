import 'package:flutter/material.dart';
import '../../../providers/goals/goals_state.dart';

/// Goal Card Widget
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(goal.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getCategoryLabel(goal.category),
                      style: TextStyle(
                        color: _getCategoryColor(goal.category),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (goal.isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (goal.isOverdue)
                    const Icon(Icons.warning, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                goal.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress / 100,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${goal.progress.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (goal.milestones.isNotEmpty) ...[
                    Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.milestones.where((m) => m.isCompleted).length}/${goal.milestones.length} milestones',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (goal.deadline != null) ...[
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDeadline(goal),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: goal.isOverdue ? Colors.orange : null,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.personal:
        return Colors.blue;
      case GoalCategory.career:
        return Colors.purple;
      case GoalCategory.health:
        return Colors.green;
      case GoalCategory.financial:
        return Colors.teal;
      case GoalCategory.education:
        return Colors.orange;
      case GoalCategory.relationships:
        return Colors.pink;
      case GoalCategory.hobby:
        return Colors.cyan;
      case GoalCategory.travel:
        return Colors.amber;
      case GoalCategory.custom:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(GoalCategory category) {
    switch (category) {
      case GoalCategory.personal:
        return 'Personal';
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.financial:
        return 'Financial';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.hobby:
        return 'Hobby';
      case GoalCategory.travel:
        return 'Travel';
      case GoalCategory.custom:
        return 'Custom';
    }
  }

  String _formatDeadline(Goal goal) {
    if (goal.daysUntilDeadline == null) return '';
    final days = goal.daysUntilDeadline!;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).round()} weeks';
    return '${(days / 30).round()} months';
  }
}
