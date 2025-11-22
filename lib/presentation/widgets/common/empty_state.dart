import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import 'app_button.dart';

/// Empty state widget for lists and screens
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.iconSize = 80,
  });

  /// Empty tasks state
  factory EmptyState.tasks({
    VoidCallback? onAddTask,
  }) =>
      EmptyState(
        icon: Icons.task_alt,
        title: 'No tasks yet',
        subtitle: 'Start by creating your first task',
        actionLabel: 'Add Task',
        onAction: onAddTask,
      );

  /// Empty search results state
  factory EmptyState.searchResults({
    String? query,
  }) =>
      EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: query != null
            ? 'No tasks match "$query"'
            : 'Try different keywords',
      );

  /// Empty lists state
  factory EmptyState.lists({
    VoidCallback? onCreateList,
  }) =>
      EmptyState(
        icon: Icons.folder_outlined,
        title: 'No lists yet',
        subtitle: 'Create a list to organize your tasks',
        actionLabel: 'Create List',
        onAction: onCreateList,
      );

  /// Empty completed tasks state
  factory EmptyState.completedTasks() => const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No completed tasks',
        subtitle: 'Complete some tasks to see them here',
      );

  /// Empty reminders state
  factory EmptyState.reminders({
    VoidCallback? onAddReminder,
  }) =>
      EmptyState(
        icon: Icons.notifications_none,
        title: 'No reminders',
        subtitle: 'Add reminders to stay on track',
        actionLabel: 'Add Reminder',
        onAction: onAddReminder,
      );

  /// Empty habits state
  factory EmptyState.habits({
    VoidCallback? onCreateHabit,
  }) =>
      EmptyState(
        icon: Icons.repeat,
        title: 'No habits yet',
        subtitle: 'Start building good habits today',
        actionLabel: 'Create Habit',
        onAction: onCreateHabit,
      );

  /// Empty tags state
  factory EmptyState.tags({
    VoidCallback? onCreateTag,
  }) =>
      EmptyState(
        icon: Icons.label_outline,
        title: 'No tags yet',
        subtitle: 'Create tags to organize your tasks',
        actionLabel: 'Create Tag',
        onAction: onCreateTag,
      );

  /// Empty today's tasks state
  factory EmptyState.todayTasks({
    VoidCallback? onAddTask,
  }) =>
      EmptyState(
        icon: Icons.today,
        title: 'Nothing for today',
        subtitle: 'You have no tasks scheduled for today',
        actionLabel: 'Add Task',
        onAction: onAddTask,
      );

  /// Empty attachments state
  factory EmptyState.attachments({
    VoidCallback? onAddAttachment,
  }) =>
      EmptyState(
        icon: Icons.attachment,
        title: 'No attachments',
        subtitle: 'Add files, images, or documents',
        actionLabel: 'Add Attachment',
        onAction: onAddAttachment,
      );

  /// Empty comments state
  factory EmptyState.comments({
    VoidCallback? onAddComment,
  }) =>
      EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No comments yet',
        subtitle: 'Be the first to comment',
        actionLabel: 'Add Comment',
        onAction: onAddComment,
      );

  /// Empty focus sessions state
  factory EmptyState.focusSessions({
    VoidCallback? onStartSession,
  }) =>
      EmptyState(
        icon: Icons.timer_outlined,
        title: 'No focus sessions',
        subtitle: 'Start a focus session to boost productivity',
        actionLabel: 'Start Focus',
        onAction: onStartSession,
      );

  /// Empty workspaces state
  factory EmptyState.workspaces({
    VoidCallback? onCreateWorkspace,
  }) =>
      EmptyState(
        icon: Icons.workspaces_outline,
        title: 'No workspaces',
        subtitle: 'Create a workspace to collaborate with your team',
        actionLabel: 'Create Workspace',
        onAction: onCreateWorkspace,
      );

  /// Offline state
  factory EmptyState.offline({
    VoidCallback? onRetry,
  }) =>
      EmptyState(
        icon: Icons.cloud_off,
        title: 'You\'re offline',
        subtitle: 'Check your internet connection and try again',
        actionLabel: 'Retry',
        onAction: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                leadingIcon: Icons.add,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact empty state for smaller spaces
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onTap;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconLg,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: content,
      );
    }

    return content;
  }
}
