import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/task_provider.dart';

/// Task list screen - main screen showing all tasks
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _scrollController = ScrollController();
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          AppIconButton(
            icon: Icons.search,
            onPressed: _handleSearch,
            tooltip: 'Search',
          ),
          AppIconButton(
            icon: Icons.filter_list,
            onPressed: _showFilterMenu,
            tooltip: 'Filter',
          ),
          AppIconButton(
            icon: Icons.more_vert,
            onPressed: _showMoreMenu,
            tooltip: 'More',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return tasksAsync.when(
      data: (tasks) => _buildTaskList(tasks),
      loading: () => const AppListLoading(message: 'Loading tasks...'),
      error: (error, stack) => _buildError(error.toString()),
    );
  }

  Widget _buildTaskList(List<TaskEntity> allTasks) {
    final filteredTasks = _filterTasks(allTasks);

    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.verticalSpaceMD,
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _TaskListItem(
            task: task,
            onTap: () => _handleTaskTap(task),
            onComplete: () => _handleTaskComplete(task),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(),
              size: AppSpacing.iconXXL + 32,
              color: AppColors.gray300,
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              _getEmptyStateTitle(),
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              _getEmptyStateMessage(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            AppButton(
              onPressed: () => context.push('/home/create'),
              icon: Icons.add,
              child: const Text('Create Your First Task'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSpacing.iconXXL,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'Something went wrong',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            AppButton(
              onPressed: () {
                ref.invalidate(tasksStreamProvider);
              },
              variant: AppButtonVariant.outlined,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (_currentFilter) {
      case TaskFilter.all:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.today:
        return tasks.where((t) {
          if (t.isCompleted) return false;
          if (t.dueDate == null) return false;
          final dueDate = DateTime(
            t.dueDate!.year,
            t.dueDate!.month,
            t.dueDate!.day,
          );
          return dueDate == today;
        }).toList();
      case TaskFilter.upcoming:
        return tasks.where((t) {
          if (t.isCompleted) return false;
          if (t.dueDate == null) return false;
          return t.dueDate!.isAfter(tomorrow);
        }).toList();
      case TaskFilter.overdue:
        return tasks.where((t) {
          if (t.isCompleted) return false;
          if (t.dueDate == null) return false;
          return t.dueDate!.isBefore(today);
        }).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
    }
  }

  String _getTitle() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.today:
        return 'Today';
      case TaskFilter.upcoming:
        return 'Upcoming';
      case TaskFilter.overdue:
        return 'Overdue';
      case TaskFilter.completed:
        return 'Completed';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return Icons.task_alt;
      case TaskFilter.today:
        return Icons.today;
      case TaskFilter.upcoming:
        return Icons.event;
      case TaskFilter.overdue:
        return Icons.warning_amber;
      case TaskFilter.completed:
        return Icons.check_circle_outline;
    }
  }

  String _getEmptyStateTitle() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return 'No tasks yet';
      case TaskFilter.today:
        return 'Nothing due today';
      case TaskFilter.upcoming:
        return 'No upcoming tasks';
      case TaskFilter.overdue:
        return 'All caught up!';
      case TaskFilter.completed:
        return 'No completed tasks';
    }
  }

  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return 'Create your first task to get started';
      case TaskFilter.today:
        return 'You\'re all set for today!';
      case TaskFilter.upcoming:
        return 'You have no tasks scheduled for the future';
      case TaskFilter.overdue:
        return 'Great job staying on top of your tasks!';
      case TaskFilter.completed:
        return 'Complete some tasks to see them here';
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(tasksStreamProvider);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _handleTaskTap(TaskEntity task) {
    context.push('/home/task/${task.id}');
  }

  Future<void> _handleTaskComplete(TaskEntity task) async {
    if (task.isCompleted) {
      await ref.read(taskNotifierProvider.notifier).uncompleteTask(task.id);
    } else {
      await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
    }
  }

  void _handleSearch() {
    // TODO: Implement search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search coming soon')),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalSpaceMD,
            Text(
              'Filter Tasks',
              style: AppTypography.titleLarge,
            ),
            const Divider(),
            ...TaskFilter.values.map((filter) {
              return ListTile(
                leading: Icon(
                  _getFilterIcon(filter),
                  color: _currentFilter == filter
                      ? AppColors.primary
                      : AppColors.gray600,
                ),
                title: Text(
                  _getFilterName(filter),
                  style: TextStyle(
                    color: _currentFilter == filter
                        ? AppColors.primary
                        : AppColors.gray900,
                    fontWeight: _currentFilter == filter
                        ? AppTypography.semiBold
                        : AppTypography.regular,
                  ),
                ),
                trailing: _currentFilter == filter
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _currentFilter = filter);
                  Navigator.pop(context);
                },
              );
            }),
            AppSpacing.verticalSpaceMD,
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    // TODO: Implement more menu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('More options coming soon')),
    );
  }

  IconData _getFilterIcon(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return Icons.list;
      case TaskFilter.today:
        return Icons.today;
      case TaskFilter.upcoming:
        return Icons.event;
      case TaskFilter.overdue:
        return Icons.warning_amber;
      case TaskFilter.completed:
        return Icons.check_circle;
    }
  }

  String _getFilterName(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.today:
        return 'Today';
      case TaskFilter.upcoming:
        return 'Upcoming';
      case TaskFilter.overdue:
        return 'Overdue';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}

/// Task list item widget
class _TaskListItem extends ConsumerWidget {
  const _TaskListItem({
    required this.task,
    required this.onTap,
    required this.onComplete,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onComplete(),
            activeColor: AppColors.primary,
          ),
          AppSpacing.horizontalSpaceXS,

          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: task.isCompleted
                      ? AppTypography.strikethrough(AppTypography.taskTitle)
                          .copyWith(color: AppColors.gray500)
                      : AppTypography.taskTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (task.description?.isNotEmpty ?? false) ...[
                  AppSpacing.verticalSpaceXXS,
                  Text(
                    task.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Metadata
                if (task.dueDate != null || task.priority > 0) ...[
                  AppSpacing.verticalSpaceXS,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      if (task.dueDate != null) _buildDueDateChip(task.dueDate!),
                      if (task.priority > 0) _buildPriorityChip(task.priority),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Priority indicator
          if (task.priority > 2)
            Container(
              width: 4,
              height: 40,
              margin: EdgeInsets.only(left: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDueDateChip(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = taskDate.isBefore(today) && !task.isCompleted;
    final isToday = taskDate == today;

    Color color;
    String text;

    if (isOverdue) {
      color = AppColors.error;
      text = 'Overdue';
    } else if (isToday) {
      color = AppColors.warning;
      text = 'Today';
    } else {
      color = AppColors.gray600;
      text = _formatDate(dueDate);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: color),
          SizedBox(width: AppSpacing.xxs),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(int priority) {
    final color = AppColors.getPriorityColor(priority);
    final text = _getPriorityText(priority);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 12, color: color),
          SizedBox(width: AppSpacing.xxs),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == tomorrow) {
      return 'Tomorrow';
    }

    return '${date.month}/${date.day}';
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return '';
    }
  }
}

/// Task filter options
enum TaskFilter {
  all,
  today,
  upcoming,
  overdue,
  completed,
}
