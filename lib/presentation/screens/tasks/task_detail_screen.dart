import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task/task_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_indicator.dart';

/// Task detail screen showing full task information
class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load task data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskNotifierProvider.notifier).getTask(widget.taskId);
    });
  }

  Future<void> _handleComplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task completed!')),
      );
    }
  }

  Future<void> _handleUncomplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).uncompleteTask(task.id);
  }

  Future<void> _handleDelete(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _handleArchive(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).archiveTask(task.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task archived')),
      );
      context.pop();
    }
  }

  Future<void> _handleDuplicate(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).duplicateTask(task.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task duplicated')),
      );
    }
  }

  void _navigateToEdit(TaskEntity task) {
    context.push('/task/${task.id}/edit');
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final task = taskState.selectedTask;
    final isLoading = taskState.isLoadingTask;
    final error = taskState.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _navigateToEdit(task),
              tooltip: 'Edit',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'duplicate':
                    _handleDuplicate(task);
                    break;
                  case 'archive':
                    _handleArchive(task);
                    break;
                  case 'delete':
                    _handleDelete(task);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Archive'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text('Delete', style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildBody(isLoading, error, task),
      bottomNavigationBar: task != null ? _buildBottomBar(task) : null,
    );
  }

  Widget _buildBody(bool isLoading, dynamic error, TaskEntity? task) {
    if (isLoading && task == null) {
      return const Center(child: LoadingIndicator());
    }

    if (error != null) {
      return ErrorState.generic(
        onRetry: () => ref.read(taskNotifierProvider.notifier).getTask(widget.taskId),
      );
    }

    if (task == null) {
      return const ErrorState(
        icon: Icons.task_alt,
        title: 'Task not found',
        subtitle: 'The task you\'re looking for doesn\'t exist or has been deleted.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Priority header
          _TaskStatusHeader(task: task),
          Gap.v16,

          // Title
          _TaskTitle(task: task),
          Gap.v16,

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            _TaskDescription(task: task),
            Gap.v24,
          ],

          // Quick info cards
          _TaskInfoCards(task: task),
          Gap.v24,

          // Tags
          if (task.tags.isNotEmpty) ...[
            _TaskTags(task: task),
            Gap.v24,
          ],

          // Context tags
          if (task.contextTags.isNotEmpty) ...[
            _TaskContextTags(task: task),
            Gap.v24,
          ],

          // Location
          if (task.location != null && task.location!.isNotEmpty) ...[
            _TaskLocation(task: task),
            Gap.v24,
          ],

          // Recurrence info
          if (task.recurrenceRule != null) ...[
            _TaskRecurrence(task: task),
            Gap.v24,
          ],

          // Metadata
          _TaskMetadata(task: task),
          Gap.v24,
        ],
      ),
    );
  }

  Widget _buildBottomBar(TaskEntity task) {
    final isCompleted = task.status == TaskStatus.completed;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: isCompleted
                  ? AppButton.outlined(
                      label: 'Mark Incomplete',
                      leadingIcon: Icons.refresh,
                      onPressed: () => _handleUncomplete(task),
                    )
                  : AppButton.primary(
                      label: 'Mark Complete',
                      leadingIcon: Icons.check,
                      onPressed: () => _handleComplete(task),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task status and priority header
class _TaskStatusHeader extends StatelessWidget {
  final TaskEntity task;

  const _TaskStatusHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.isOverdue;

    return Row(
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(task.status).withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusFull,
            border: Border.all(
              color: _getStatusColor(task.status).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(task.status),
                size: 14,
                color: _getStatusColor(task.status),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(task.status),
                style: AppTypography.labelSmall(
                  color: _getStatusColor(task.status),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Priority badge
        if (task.priority != TaskPriority.none)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.getPriorityColor(task.priority.index).withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag,
                  size: 14,
                  color: AppColors.getPriorityColor(task.priority.index),
                ),
                const SizedBox(width: 4),
                Text(
                  _getPriorityText(task.priority),
                  style: AppTypography.labelSmall(
                    color: AppColors.getPriorityColor(task.priority.index),
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // Overdue indicator
        if (isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Overdue',
                  style: AppTypography.labelSmall(color: AppColors.error),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.completed:
        return AppColors.statusCompleted;
      case TaskStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.circle_outlined;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return 'None';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}

/// Task title section
class _TaskTitle extends StatelessWidget {
  final TaskEntity task;

  const _TaskTitle({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.completed;

    return Text(
      task.title,
      style: AppTypography.headlineMedium(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ).copyWith(
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isCompleted
            ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
            : null,
      ),
    );
  }
}

/// Task description section
class _TaskDescription extends StatelessWidget {
  final TaskEntity task;

  const _TaskDescription({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        Text(
          task.description!,
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

/// Task info cards (dates, duration, energy)
class _TaskInfoCards extends StatelessWidget {
  final TaskEntity task;

  const _TaskInfoCards({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        // Due date
        if (task.dueDate != null)
          _InfoCard(
            icon: Icons.event,
            label: 'Due Date',
            value: _formatDate(task.dueDate!),
            color: task.isOverdue ? AppColors.error : AppColors.primary,
            backgroundColor: cardColor,
          ),

        // Start date
        if (task.startDate != null)
          _InfoCard(
            icon: Icons.play_arrow,
            label: 'Start Date',
            value: _formatDate(task.startDate!),
            color: AppColors.info,
            backgroundColor: cardColor,
          ),

        // Completed date
        if (task.completedAt != null)
          _InfoCard(
            icon: Icons.check_circle,
            label: 'Completed',
            value: _formatDate(task.completedAt!),
            color: AppColors.success,
            backgroundColor: cardColor,
          ),

        // Estimated duration
        if (task.estimatedDuration != null)
          _InfoCard(
            icon: Icons.timer_outlined,
            label: 'Estimated',
            value: _formatDuration(task.estimatedDuration!),
            color: AppColors.secondary,
            backgroundColor: cardColor,
          ),

        // Actual duration
        if (task.actualDuration != null)
          _InfoCard(
            icon: Icons.timer,
            label: 'Actual',
            value: _formatDuration(task.actualDuration!),
            color: AppColors.secondary,
            backgroundColor: cardColor,
          ),

        // Energy level
        if (task.energyLevel != null)
          _InfoCard(
            icon: Icons.bolt,
            label: 'Energy',
            value: _getEnergyText(task.energyLevel!),
            color: _getEnergyColor(task.energyLevel!),
            backgroundColor: cardColor,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat.MMMd().format(date);
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
    return '${duration.inMinutes}m';
  }

  String _getEnergyText(int level) {
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }

  Color _getEnergyColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Info card widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Task tags section
class _TaskTags extends StatelessWidget {
  final TaskEntity task;

  const _TaskTags({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: task.tags.map((tag) {
            final color = AppColors.getTagColor(tag.hashCode);
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                tag,
                style: AppTypography.labelMedium(color: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Task context tags section (@computer, @phone, etc.)
class _TaskContextTags extends StatelessWidget {
  final TaskEntity task;

  const _TaskContextTags({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Context',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: task.contextTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getContextIcon(tag),
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag,
                    style: AppTypography.labelMedium(color: AppColors.secondary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getContextIcon(String tag) {
    final lowerTag = tag.toLowerCase();
    if (lowerTag.contains('computer') || lowerTag.contains('laptop')) {
      return Icons.computer;
    } else if (lowerTag.contains('phone') || lowerTag.contains('mobile')) {
      return Icons.phone_android;
    } else if (lowerTag.contains('home')) {
      return Icons.home;
    } else if (lowerTag.contains('office') || lowerTag.contains('work')) {
      return Icons.business;
    } else if (lowerTag.contains('errand')) {
      return Icons.directions_car;
    } else if (lowerTag.contains('email') || lowerTag.contains('mail')) {
      return Icons.email;
    } else if (lowerTag.contains('call')) {
      return Icons.call;
    }
    return Icons.label_outline;
  }
}

/// Task location section
class _TaskLocation extends StatelessWidget {
  final TaskEntity task;

  const _TaskLocation({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  task.location!,
                  style: AppTypography.bodyMedium(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (task.hasLocation)
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  onPressed: () {
                    // TODO: Open maps
                  },
                  tooltip: 'Open in Maps',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Task recurrence section
class _TaskRecurrence extends StatelessWidget {
  final TaskEntity task;

  const _TaskRecurrence({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rule = task.recurrenceRule!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurrence',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.repeat,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatRecurrence(rule),
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRecurrence(RecurrenceRule rule) {
    final buffer = StringBuffer();

    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        if (rule.interval == 1) {
          buffer.write('Daily');
        } else {
          buffer.write('Every ${rule.interval} days');
        }
        break;
      case RecurrenceFrequency.weekly:
        if (rule.interval == 1) {
          buffer.write('Weekly');
        } else {
          buffer.write('Every ${rule.interval} weeks');
        }
        if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty) {
          buffer.write(' on ');
          buffer.write(rule.daysOfWeek!.map(_getDayName).join(', '));
        }
        break;
      case RecurrenceFrequency.monthly:
        if (rule.interval == 1) {
          buffer.write('Monthly');
        } else {
          buffer.write('Every ${rule.interval} months');
        }
        if (rule.dayOfMonth != null) {
          buffer.write(' on day ${rule.dayOfMonth}');
        }
        break;
      case RecurrenceFrequency.yearly:
        if (rule.interval == 1) {
          buffer.write('Yearly');
        } else {
          buffer.write('Every ${rule.interval} years');
        }
        break;
    }

    if (rule.endDate != null) {
      buffer.write(' until ${DateFormat.MMMd().format(rule.endDate!)}');
    } else if (rule.occurrences != null) {
      buffer.write(' for ${rule.occurrences} times');
    }

    return buffer.toString();
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(day - 1) % 7];
  }
}

/// Task metadata section (created, updated)
class _TaskMetadata extends StatelessWidget {
  final TaskEntity task;

  const _TaskMetadata({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Gap.v8,
        _MetadataRow(
          label: 'Created',
          value: DateFormat.yMMMd().add_jm().format(task.createdAt),
          color: subtitleColor,
        ),
        Gap.v4,
        _MetadataRow(
          label: 'Updated',
          value: DateFormat.yMMMd().add_jm().format(task.updatedAt),
          color: subtitleColor,
        ),
        if (task.listId != null) ...[
          Gap.v4,
          _MetadataRow(
            label: 'List',
            value: task.listId!,
            color: subtitleColor,
          ),
        ],
      ],
    );
  }
}

/// Metadata row widget
class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetadataRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTypography.labelSmall(color: color),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.labelSmall(color: color),
          ),
        ),
      ],
    );
  }
}
