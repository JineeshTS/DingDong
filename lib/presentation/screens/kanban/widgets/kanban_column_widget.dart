import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/design_system.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../providers/kanban/kanban.dart';
import 'kanban_card_widget.dart';

/// Kanban column widget
///
/// Displays a single column in the Kanban board with:
/// - Column header with name and task count
/// - Task cards with drag-and-drop
/// - WIP limit indicator
/// - Add task button
/// - Collapse/expand functionality
class KanbanColumnWidget extends ConsumerWidget {
  const KanbanColumnWidget({
    super.key,
    required this.column,
  });

  final KanbanColumn column;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAtWipLimit = column.isAtWipLimit;

    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: isAtWipLimit ? AppColors.warning : AppColors.gray200,
          width: isAtWipLimit ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column header
          _buildHeader(ref, isAtWipLimit),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray200,
          ),

          // Task list with drag-and-drop
          if (!column.isCollapsed)
            Expanded(
              child: _buildTaskList(ref),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, bool isAtWipLimit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref
              .read(kanbanNotifierProvider.notifier)
              .toggleColumnCollapsed(column.id);
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusMD),
          topRight: Radius.circular(AppSpacing.radiusMD),
        ),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Collapse/expand icon
              Icon(
                column.isCollapsed
                    ? Icons.chevron_right
                    : Icons.expand_more,
                size: 20,
                color: AppColors.gray600,
              ),
              AppSpacing.horizontalSpaceXS,

              // Column name
              Expanded(
                child: Text(
                  column.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Task count
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isAtWipLimit
                      ? AppColors.warning.withOpacity(0.2)
                      : AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${column.taskCount}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: AppTypography.bold,
                        color: isAtWipLimit ? AppColors.warning : AppColors.gray700,
                      ),
                    ),
                    if (column.wipLimit != null) ...{
                      Text(
                        '/',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        '${column.wipLimit}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    },
                  ],
                ),
              ),

              // More options
              AppSpacing.horizontalSpaceXS,
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.gray600,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'set_wip',
                    child: Row(
                      children: [
                        Icon(Icons.rule, size: 18),
                        AppSpacing.horizontalSpaceSM,
                        const Text('Set WIP Limit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'hide',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 18),
                        AppSpacing.horizontalSpaceSM,
                        const Text('Hide Column'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'set_wip') {
                    _showWipLimitDialog(ref);
                  } else if (value == 'hide') {
                    ref
                        .read(kanbanNotifierProvider.notifier)
                        .toggleColumnVisibility(column.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(WidgetRef ref) {
    if (column.tasks.isEmpty) {
      return _buildEmptyState();
    }

    return DragTarget<TaskEntity>(
      onAccept: (task) async {
        // Find the source column
        final kanbanState = ref.read(kanbanNotifierProvider);
        String? fromColumnId;

        for (final col in kanbanState.columns) {
          if (col.tasks.any((t) => t.id == task.id)) {
            fromColumnId = col.id;
            break;
          }
        }

        if (fromColumnId != null && fromColumnId != column.id) {
          await ref
              .read(kanbanNotifierProvider.notifier)
              .moveTask(task, fromColumnId, column.id);
        }
      },
      onWillAccept: (task) {
        // Don't accept if at WIP limit
        if (column.isAtWipLimit && column.wipLimit != null) {
          return false;
        }
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isHovering
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: ReorderableListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: column.tasks.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(kanbanNotifierProvider.notifier)
                  .reorderTaskInColumn(column.id, oldIndex, newIndex);
            },
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final task = column.tasks[index];
              return ReorderableDragStartListener(
                key: ValueKey(task.id),
                index: index,
                child: LongPressDraggable<TaskEntity>(
                  data: task,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    child: SizedBox(
                      width: 280,
                      child: Opacity(
                        opacity: 0.8,
                        child: KanbanCardWidget(task: task),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: KanbanCardWidget(task: task),
                  ),
                  child: KanbanCardWidget(task: task),
                ),
              );
            },
          ),
        );
      },
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
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.gray300,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'No tasks',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWipLimitDialog(WidgetRef ref) {
    // This would show a dialog to set WIP limit
    // For now, we'll use a simple implementation
    // In a real app, you'd show a proper dialog with text field
  }
}
