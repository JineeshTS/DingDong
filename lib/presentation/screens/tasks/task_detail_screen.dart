import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/task_provider.dart';

/// Comprehensive task detail screen showing all task information
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _scrollController = ScrollController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));

    return taskAsync.when(
      data: (task) {
        if (task == null) {
          return _buildNotFound();
        }
        return _buildDetailView(task);
      },
      loading: () => const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      ),
      error: (error, stack) => _buildError(error.toString()),
    );
  }

  Widget _buildDetailView(TaskEntity task) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        actions: [
          AppIconButton(
            icon: Icons.edit,
            onPressed: () => _handleEdit(task),
            tooltip: 'Edit',
          ),
          AppIconButton(
            icon: Icons.delete,
            onPressed: () => _handleDelete(task),
            tooltip: 'Delete',
          ),
          AppIconButton(
            icon: Icons.more_vert,
            onPressed: () => _showMoreMenu(task),
            tooltip: 'More',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task header with completion checkbox
            _buildHeader(task),
            AppSpacing.verticalSpaceMD,

            // Priority and due date section
            _buildMetadataSection(task),
            AppSpacing.verticalSpaceMD,

            // Description section
            if (task.description?.isNotEmpty ?? false) ...[
              _buildDescriptionSection(task),
              AppSpacing.verticalSpaceMD,
            ],

            // Tags section
            if (task.tags.isNotEmpty) ...[
              _buildTagsSection(task),
              AppSpacing.verticalSpaceMD,
            ],

            // Subtasks section
            _buildSubtasksSection(task),
            AppSpacing.verticalSpaceMD,

            // Attachments section
            _buildAttachmentsSection(task),
            AppSpacing.verticalSpaceMD,

            // Comments section
            _buildCommentsSection(task),
            AppSpacing.verticalSpaceMD,

            // Task metadata
            _buildTaskMetadata(task),
            AppSpacing.verticalSpaceXL,
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(task),
    );
  }

  Widget _buildHeader(TaskEntity task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Completion checkbox
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _handleToggleComplete(task),
            activeColor: AppColors.primary,
          ),
        ),
        AppSpacing.horizontalSpaceSM,

        // Task title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: task.isCompleted
                    ? AppTypography.strikethrough(AppTypography.headlineMedium)
                        .copyWith(color: AppColors.gray500)
                    : AppTypography.headlineMedium,
              ),
              AppSpacing.verticalSpaceXXS,
              if (task.isCompleted)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: AppSpacing.iconXS,
                      color: AppColors.success,
                    ),
                    AppSpacing.horizontalSpaceXXS,
                    Text(
                      'Completed',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(TaskEntity task) {
    return AppCard(
      child: Column(
        children: [
          // Priority
          _buildInfoRow(
            icon: Icons.flag,
            iconColor: AppColors.getPriorityColor(task.priority),
            label: 'Priority',
            value: _getPriorityText(task.priority),
            valueColor: AppColors.getPriorityColor(task.priority),
          ),
          if (task.dueDate != null) ...[
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(
              icon: Icons.calendar_today,
              iconColor: _getDueDateColor(task.dueDate!),
              label: 'Due Date',
              value: _formatDueDate(task.dueDate!),
              valueColor: _getDueDateColor(task.dueDate!),
            ),
          ],
          if (task.categoryId != null) ...[
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(
              icon: Icons.folder_outlined,
              iconColor: AppColors.gray600,
              label: 'List',
              value: 'Category', // TODO: Load category name
              valueColor: AppColors.gray900,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSM, color: iconColor),
        AppSpacing.horizontalSpaceSM,
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(TaskEntity task) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notes,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Description',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            task.description!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(TaskEntity task) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_outlined,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Tags',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: task.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusXS,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tag,
                      size: AppSpacing.iconXS,
                      color: AppColors.primary,
                    ),
                    AppSpacing.horizontalSpaceXXS,
                    Text(
                      tag,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection(TaskEntity task) {
    // TODO: Load actual subtasks from provider
    final hasSubtasks = false;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Subtasks',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              AppButton(
                onPressed: () => _handleAddSubtask(task),
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                child: const Text('Add'),
              ),
            ],
          ),
          if (hasSubtasks) ...[
            AppSpacing.verticalSpaceSM,
            // TODO: Display subtasks here
          ] else ...[
            AppSpacing.verticalSpaceSM,
            Center(
              child: Text(
                'No subtasks yet',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(TaskEntity task) {
    // TODO: Load actual attachments from provider
    final hasAttachments = false;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Attachments',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              AppButton(
                onPressed: () => _handleAddAttachment(task),
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                child: const Text('Add'),
              ),
            ],
          ),
          if (hasAttachments) ...[
            AppSpacing.verticalSpaceSM,
            // TODO: Display attachments here
          ] else ...[
            AppSpacing.verticalSpaceSM,
            Center(
              child: Text(
                'No attachments',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(TaskEntity task) {
    // TODO: Load actual comments from provider
    final hasComments = false;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Comments',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              AppButton(
                onPressed: () => _handleAddComment(task),
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                child: const Text('Add'),
              ),
            ],
          ),
          if (hasComments) ...[
            AppSpacing.verticalSpaceSM,
            // TODO: Display comments here
          ] else ...[
            AppSpacing.verticalSpaceSM,
            Center(
              child: Text(
                'No comments yet',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskMetadata(TaskEntity task) {
    return AppCard(
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Information',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          _buildMetadataItem('Created', _formatDateTime(task.createdAt)),
          _buildMetadataItem('Updated', _formatDateTime(task.updatedAt)),
          _buildMetadataItem('Task ID', task.id),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(TaskEntity task) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: task.isCompleted
            ? AppButton(
                onPressed: () => _handleToggleComplete(task),
                variant: AppButtonVariant.outlined,
                fullWidth: true,
                icon: Icons.refresh,
                child: const Text('Mark as Incomplete'),
              )
            : AppButton(
                onPressed: () => _handleToggleComplete(task),
                fullWidth: true,
                icon: Icons.check,
                child: const Text('Mark as Complete'),
              ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: AppSpacing.iconXXL,
                color: AppColors.gray400,
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                'Task not found',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                'This task may have been deleted or does not exist.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceXL,
              AppButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Tasks'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
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
                  ref.invalidate(taskByIdProvider(widget.taskId));
                },
                variant: AppButtonVariant.outlined,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleToggleComplete(TaskEntity task) async {
    if (task.isCompleted) {
      await ref.read(taskNotifierProvider.notifier).uncompleteTask(task.id);
    } else {
      await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
    }
  }

  void _handleEdit(TaskEntity task) {
    // TODO: Navigate to edit screen
    context.push('/home/task/${task.id}/edit');
  }

  Future<void> _handleDelete(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        ),
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

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
      if (!mounted) return;
      context.pop(); // Go back to list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showMoreMenu(TaskEntity task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalSpaceMD,
            Text(
              'Task Options',
              style: AppTypography.titleLarge,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                _handleDuplicate(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _handleShare(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                _handleArchive(task);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _handleDelete(task);
              },
            ),
            AppSpacing.verticalSpaceMD,
          ],
        ),
      ),
    );
  }

  void _handleAddSubtask(TaskEntity task) {
    // TODO: Implement add subtask
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add subtask coming soon')),
    );
  }

  void _handleAddAttachment(TaskEntity task) {
    // TODO: Implement add attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add attachment coming soon')),
    );
  }

  void _handleAddComment(TaskEntity task) {
    // TODO: Implement add comment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add comment coming soon')),
    );
  }

  void _handleDuplicate(TaskEntity task) {
    // TODO: Implement duplicate task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicate task coming soon')),
    );
  }

  void _handleShare(TaskEntity task) {
    // TODO: Implement share task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share task coming soon')),
    );
  }

  void _handleArchive(TaskEntity task) {
    // TODO: Implement archive task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Archive task coming soon')),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'None';
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'None';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      return AppColors.error;
    } else if (taskDate == today) {
      return AppColors.warning;
    }
    return AppColors.gray700;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return 'Overdue by $difference day${difference == 1 ? '' : 's'}';
    } else if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, $year at $hour:$minute';
  }
}
