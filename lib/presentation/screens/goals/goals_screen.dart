import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../providers/goals/goals_providers.dart';
import '../../providers/goals/goals_state.dart';
import 'widgets/goal_card.dart';

/// Goals Screen
///
/// Main screen for goals and milestones featuring:
/// - Goals list with progress tracking
/// - Goal templates for quick creation
/// - Milestone management
/// - SMART goals framework
/// - Progress statistics
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(filteredGoalsProvider);
    final notifier = ref.read(goalsNotifierProvider.notifier);
    final stats = ref.watch(goalsNotifierProvider);

    ref.listen<String?>(goalsErrorProvider, (previous, next) {
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
        title: const Text('Goals & Milestones'),
        actions: [
          PopupMenuButton<GoalFilter>(
            initialValue: ref.watch(currentGoalFilterProvider),
            onSelected: (filter) => notifier.changeFilter(filter),
            itemBuilder: (context) => [
              const PopupMenuItem(value: GoalFilter.all, child: Text('All')),
              const PopupMenuItem(value: GoalFilter.active, child: Text('Active')),
              const PopupMenuItem(value: GoalFilter.completed, child: Text('Completed')),
              const PopupMenuItem(value: GoalFilter.archived, child: Text('Archived')),
            ],
          ),
        ],
      ),
      body: stats.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Total',
                                value: '${stats.totalGoals}',
                                icon: Icons.flag,
                              ),
                              _StatItem(
                                label: 'Active',
                                value: '${stats.activeGoals}',
                                icon: Icons.trending_up,
                                color: Colors.blue,
                              ),
                              _StatItem(
                                label: 'Completed',
                                value: '${stats.completedGoals}',
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overall Progress',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: stats.overallProgress / 100,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${stats.overallProgress.toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Goals List
                  if (goals.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No goals yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first goal to get started',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...goals.map((goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GoalCard(
                            goal: goal,
                            onTap: () => _showGoalDetails(context, ref, goal),
                          ),
                        )),

                  const SizedBox(height: 16),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context, GoalsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose from templates',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              ...GoalTemplates.allTemplates.map((template) {
                return ListTile(
                  title: Text(template.title),
                  subtitle: Text(template.description ?? ''),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    notifier.createGoalFromTemplate(template);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(BuildContext context, WidgetRef ref, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        goal.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                      ),
                      onPressed: () {
                        ref.read(goalsNotifierProvider.notifier).toggleGoalCompletion(goal.id);
                      },
                    ),
                  ],
                ),
                if (goal.description != null) Text(goal.description!),
                const SizedBox(height: 16),
                Text(
                  'Progress: ${goal.progress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: goal.progress,
                  max: 100,
                  divisions: 20,
                  label: '${goal.progress.toStringAsFixed(0)}%',
                  onChanged: (value) {
                    ref.read(goalsNotifierProvider.notifier).updateGoalProgress(goal.id, value);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Milestones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: goal.milestones.length,
                    itemBuilder: (context, index) {
                      final milestone = goal.milestones[index];
                      return CheckboxListTile(
                        title: Text(milestone.title),
                        value: milestone.isCompleted,
                        onChanged: (value) {
                          ref.read(goalsNotifierProvider.notifier)
                              .toggleMilestoneCompletion(goal.id, milestone.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
