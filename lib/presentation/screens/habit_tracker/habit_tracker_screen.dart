import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../providers/habit_tracker/habit_tracker_providers.dart';
import '../../providers/habit_tracker/habit_tracker_state.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_stats_card.dart';

/// Habit Tracker Screen
///
/// Main screen for habit tracking featuring:
/// - Daily habit check-ins
/// - Streak tracking
/// - Habit statistics
/// - Habit templates
/// - Multiple view modes
class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitTrackerNotifierProvider);
    final notifier = ref.read(habitTrackerNotifierProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen<String?>(habitTrackerErrorProvider, (previous, next) {
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
        title: const Text('Habits'),
        actions: [
          // Filter button
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(hasActiveFiltersProvider),
              child: const Icon(Icons.filter_list_rounded),
            ),
            onPressed: () => _showFiltersDialog(context, ref),
          ),
          // View mode button
          IconButton(
            icon: Icon(_getViewModeIcon(state.viewMode)),
            onPressed: () => _showViewModeDialog(context, notifier),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.loadHabits();
          },
          child: state.isLoading && state.habits.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats Card
                      HabitStatsCard(
                        totalHabits: state.habitsDueToday.length,
                        completedToday: state.completedToday,
                        completionRate: state.overallTodayCompletionRate,
                        activeStreaks: state.activeStreaks,
                        longestStreak: state.longestStreak,
                      ),

                      const SizedBox(height: 16),

                      // Section header
                      Row(
                        children: [
                          Text(
                            'Today\'s Habits',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${state.habitsDueToday.length} habits',
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

                      const SizedBox(height: 12),

                      // Habits list
                      if (state.habitsDueToday.isEmpty)
                        _buildEmptyState(context)
                      else
                        ...state.habitsDueToday.map((habit) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: HabitCard(
                              habit: habit,
                              onTap: () {
                                // TODO: Navigate to habit detail
                                notifier.selectHabit(habit);
                              },
                              onCheckIn: () {
                                notifier.checkInHabit(habit.id);
                              },
                              isCheckingIn: state.isCheckingIn,
                            ),
                          );
                        }),

                      const SizedBox(height: 16),

                      // Quick tips
                      _buildTipsCard(context),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitDialog(context, notifier),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No habits for today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a habit to get started',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tip: Check in your habits daily to build streaks. '
                'Consistency is key to forming lasting habits!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateHabitDialog(
    BuildContext context,
    HabitTrackerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Habit'),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitTemplates.allTemplates.take(6).map((template) {
                  return ActionChip(
                    avatar: Text(template.icon),
                    label: Text(template.name),
                    onPressed: () {
                      notifier.createHabitFromTemplate(template);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom habit creation coming soon!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
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

  void _showFiltersDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Show archived'),
                value: ref.read(showArchivedProvider),
                onChanged: (value) {
                  ref
                      .read(habitTrackerNotifierProvider.notifier)
                      .toggleShowArchived();
                },
              ),
              const Divider(),
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitCategory.values.map((category) {
                  return FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected:
                        ref.read(filterCategoryProvider) == category,
                    onSelected: (selected) {
                      ref
                          .read(habitTrackerNotifierProvider.notifier)
                          .filterByCategory(selected ? category : null);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          if (ref.watch(hasActiveFiltersProvider))
            TextButton(
              onPressed: () {
                ref.read(habitTrackerNotifierProvider.notifier).clearFilters();
              },
              child: const Text('Clear All'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showViewModeDialog(
    BuildContext context,
    HabitTrackerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('View Mode'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              notifier.changeViewMode(HabitViewMode.list);
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.list_rounded),
                SizedBox(width: 8),
                Text('List'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              notifier.changeViewMode(HabitViewMode.grid);
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.grid_view_rounded),
                SizedBox(width: 8),
                Text('Grid'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              notifier.changeViewMode(HabitViewMode.calendar);
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.calendar_month_rounded),
                SizedBox(width: 8),
                Text('Calendar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getViewModeIcon(HabitViewMode mode) {
    switch (mode) {
      case HabitViewMode.list:
        return Icons.list_rounded;
      case HabitViewMode.grid:
        return Icons.grid_view_rounded;
      case HabitViewMode.calendar:
        return Icons.calendar_month_rounded;
    }
  }

  String _getCategoryLabel(HabitCategory category) {
    switch (category) {
      case HabitCategory.healthFitness:
        return 'Health & Fitness';
      case HabitCategory.personalDevelopment:
        return 'Personal Dev';
      case HabitCategory.workProductivity:
        return 'Work';
      case HabitCategory.financeSavings:
        return 'Finance';
      case HabitCategory.socialRelationships:
        return 'Social';
      case HabitCategory.mindfulnessMentalHealth:
        return 'Mindfulness';
      case HabitCategory.hobbiesInterests:
        return 'Hobbies';
      case HabitCategory.custom:
        return 'Custom';
    }
  }
}
