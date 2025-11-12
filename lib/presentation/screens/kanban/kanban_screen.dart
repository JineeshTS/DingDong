import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/kanban/kanban.dart';
import 'widgets/kanban_column_widget.dart';

/// Kanban board screen
///
/// Displays tasks in a Kanban board format with:
/// - Customizable columns
/// - Drag-and-drop task movement
/// - WIP limits
/// - Task filtering
/// - Column management
class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  @override
  Widget build(BuildContext context) {
    final kanbanState = ref.watch(kanbanNotifierProvider);
    final visibleColumns = ref.watch(visibleKanbanColumnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          // Show completed tasks toggle
          IconButton(
            icon: Icon(
              kanbanState.showCompletedTasks
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            tooltip: kanbanState.showCompletedTasks
                ? 'Hide completed tasks'
                : 'Show completed tasks',
            onPressed: () {
              ref
                  .read(kanbanNotifierProvider.notifier)
                  .toggleShowCompletedTasks();
            },
          ),

          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filters',
                onPressed: () {
                  _showFilterMenu(context);
                },
              ),
              // Active filters badge
              if (ref.watch(kanbanActiveFiltersCountProvider) > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${ref.watch(kanbanActiveFiltersCountProvider)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(kanbanNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics bar
          _buildStatisticsBar(),

          // Error message
          if (kanbanState.error != null) _buildErrorBanner(kanbanState.error!),

          // Board columns
          Expanded(
            child: kanbanState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleColumns.isEmpty
                    ? _buildEmptyState()
                    : _buildKanbanBoard(visibleColumns),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsBar() {
    final totalTasks = ref.watch(kanbanTotalTasksCountProvider);
    final completedTasks = ref.watch(kanbanCompletedTasksCountProvider);
    final incompleteTasks = ref.watch(kanbanIncompleteTasksCountProvider);
    final hasWipLimit = ref.watch(hasWipLimitReachedProvider);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatChip(
            'Total',
            totalTasks.toString(),
            AppColors.gray600,
            Icons.task_alt,
          ),
          AppSpacing.horizontalSpaceSM,
          _buildStatChip(
            'Active',
            incompleteTasks.toString(),
            AppColors.primary,
            Icons.pending_actions,
          ),
          AppSpacing.horizontalSpaceSM,
          _buildStatChip(
            'Done',
            completedTasks.toString(),
            AppColors.success,
            Icons.check_circle,
          ),
          if (hasWipLimit) ...{
            AppSpacing.horizontalSpaceSM,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                border: Border.all(
                  color: AppColors.warning,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  AppSpacing.horizontalSpaceXS,
                  Text(
                    'WIP Limit Reached',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          AppSpacing.horizontalSpaceXS,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
          AppSpacing.horizontalSpaceXXS,
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: AppTypography.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: AppSpacing.paddingMD,
      color: AppColors.error.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Text(
              error,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.error, size: 20),
            onPressed: () {
              ref.read(kanbanNotifierProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(List<KanbanColumn> columns) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((column) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: KanbanColumnWidget(column: column),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_column_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'No columns available',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Create columns to organize your tasks',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: AppTypography.bold,
                ),
              ),
              AppSpacing.verticalSpaceMD,
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Filter by List'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show list filter dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.label),
                title: const Text('Filter by Tags'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show tags filter dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Filter by Priority'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show priority filter dialog
                },
              ),
              AppSpacing.verticalSpaceSM,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(kanbanNotifierProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All Filters'),
                ),
              ),
              AppSpacing.verticalSpaceSM,
            ],
          ),
        );
      },
    );
  }
}
