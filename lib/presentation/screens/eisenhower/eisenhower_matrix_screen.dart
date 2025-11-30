import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/eisenhower/eisenhower.dart';
import 'widgets/matrix_quadrant_widget.dart';

/// Eisenhower Matrix screen
///
/// Displays tasks in a 2×2 matrix based on urgency and importance:
/// - Q1: Urgent & Important (Do First)
/// - Q2: Not Urgent & Important (Schedule)
/// - Q3: Urgent & Not Important (Delegate)
/// - Q4: Not Urgent & Not Important (Eliminate)
class EisenhowerMatrixScreen extends ConsumerStatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  ConsumerState<EisenhowerMatrixScreen> createState() =>
      _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState
    extends ConsumerState<EisenhowerMatrixScreen> {
  @override
  Widget build(BuildContext context) {
    final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
    final focusQuadrant = ref.watch(eisenhowerFocusQuadrantProvider);
    final isFocusMode = focusQuadrant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFocusMode
            ? '${focusQuadrant.title} Mode'
            : 'Eisenhower Matrix'),
        actions: [
          // Exit focus mode
          if (isFocusMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Exit focus mode',
              onPressed: () {
                ref
                    .read(eisenhowerNotifierProvider.notifier)
                    .setFocusQuadrant(null);
              },
            ),

          // Show completed tasks toggle
          IconButton(
            icon: Icon(
              eisenhowerState.showCompletedTasks
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            tooltip: eisenhowerState.showCompletedTasks
                ? 'Hide completed tasks'
                : 'Show completed tasks',
            onPressed: () {
              ref
                  .read(eisenhowerNotifierProvider.notifier)
                  .toggleShowCompletedTasks();
            },
          ),

          // Settings menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'auto_categorization',
                child: Row(
                  children: [
                    Icon(
                      eisenhowerState.autoCategorization
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                    ),
                    AppSpacing.horizontalSpaceSM,
                    const Text('Auto Categorization'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 12),
                    Text('About Matrix'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'auto_categorization') {
                ref
                    .read(eisenhowerNotifierProvider.notifier)
                    .toggleAutoCategorization();
              } else if (value == 'info') {
                _showAboutDialog(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics bar
          if (!isFocusMode) _buildStatisticsBar(),

          // Error message
          if (eisenhowerState.error != null)
            _buildErrorBanner(eisenhowerState.error!),

          // Matrix or focus view
          Expanded(
            child: eisenhowerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : isFocusMode
                    ? _buildFocusView(focusQuadrant)
                    : _buildMatrixView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(eisenhowerNotifierProvider.notifier).refresh();
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatisticsBar() {
    final totalTasks = ref.watch(eisenhowerTotalTasksCountProvider);
    final incompleteTasks = ref.watch(eisenhowerIncompleteTasksCountProvider);
    final q1Count = ref.watch(urgentImportantCountProvider);
    final q2Count = ref.watch(notUrgentImportantCountProvider);

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
            Icons.grid_view,
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
            'Do First',
            q1Count.toString(),
            AppColors.error,
            Icons.priority_high,
          ),
          AppSpacing.horizontalSpaceSM,
          _buildStatChip(
            'Schedule',
            q2Count.toString(),
            AppColors.primary,
            Icons.schedule,
          ),
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
          Icon(icon, size: 14, color: color),
          AppSpacing.horizontalSpaceXS,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
          AppSpacing.horizontalSpaceXXS,
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: AppTypography.bold,
              fontSize: 13,
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
              ref.read(eisenhowerNotifierProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixView() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // Labels
          _buildAxisLabels(),

          AppSpacing.verticalSpaceSM,

          // 2×2 Grid
          Expanded(
            child: Row(
              children: [
                // Left column (Urgent)
                Expanded(
                  child: Column(
                    children: [
                      // Q1: Urgent & Important
                      Expanded(
                        child: MatrixQuadrantWidget(
                          quadrant: MatrixQuadrant.urgentImportant,
                          onTap: () {
                            ref
                                .read(eisenhowerNotifierProvider.notifier)
                                .setFocusQuadrant(
                                    MatrixQuadrant.urgentImportant);
                          },
                        ),
                      ),

                      AppSpacing.verticalSpaceSM,

                      // Q3: Urgent & Not Important
                      Expanded(
                        child: MatrixQuadrantWidget(
                          quadrant: MatrixQuadrant.urgentNotImportant,
                          onTap: () {
                            ref
                                .read(eisenhowerNotifierProvider.notifier)
                                .setFocusQuadrant(
                                    MatrixQuadrant.urgentNotImportant);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.horizontalSpaceSM,

                // Right column (Not Urgent)
                Expanded(
                  child: Column(
                    children: [
                      // Q2: Not Urgent & Important
                      Expanded(
                        child: MatrixQuadrantWidget(
                          quadrant: MatrixQuadrant.notUrgentImportant,
                          onTap: () {
                            ref
                                .read(eisenhowerNotifierProvider.notifier)
                                .setFocusQuadrant(
                                    MatrixQuadrant.notUrgentImportant);
                          },
                        ),
                      ),

                      AppSpacing.verticalSpaceSM,

                      // Q4: Not Urgent & Not Important
                      Expanded(
                        child: MatrixQuadrantWidget(
                          quadrant: MatrixQuadrant.notUrgentNotImportant,
                          onTap: () {
                            ref
                                .read(eisenhowerNotifierProvider.notifier)
                                .setFocusQuadrant(
                                    MatrixQuadrant.notUrgentNotImportant);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabels() {
    return Row(
      children: [
        // Importance axis (vertical)
        SizedBox(
          width: 80,
          child: RotatedBox(
            quarterTurns: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 14, color: AppColors.gray600),
                AppSpacing.horizontalSpaceXS,
                Text(
                  'IMPORTANT',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: AppTypography.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                AppSpacing.horizontalSpaceXS,
                Icon(Icons.arrow_forward, size: 14, color: AppColors.gray600),
              ],
            ),
          ),
        ),

        Expanded(
          child: Column(
            children: [
              // Urgency axis (horizontal)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 14, color: AppColors.gray600),
                  AppSpacing.horizontalSpaceXS,
                  Text(
                    'URGENT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gray600,
                      fontWeight: AppTypography.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  AppSpacing.horizontalSpaceXS,
                  Icon(Icons.arrow_forward, size: 14, color: AppColors.gray600),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusView(MatrixQuadrant quadrant) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: MatrixQuadrantWidget(quadrant: quadrant),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Eisenhower Matrix'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The Eisenhower Matrix helps you prioritize tasks by urgency and importance.',
                style: AppTypography.bodyMedium,
              ),
              AppSpacing.verticalSpaceMD,
              _buildQuadrantInfo(
                'Q1: Do First',
                'Urgent & Important',
                'Tasks that require immediate attention. Do these first.',
                AppColors.error,
              ),
              AppSpacing.verticalSpaceSM,
              _buildQuadrantInfo(
                'Q2: Schedule',
                'Not Urgent & Important',
                'Long-term development tasks. Schedule time for these.',
                AppColors.primary,
              ),
              AppSpacing.verticalSpaceSM,
              _buildQuadrantInfo(
                'Q3: Delegate',
                'Urgent & Not Important',
                'Tasks that could be delegated to others.',
                AppColors.warning,
              ),
              AppSpacing.verticalSpaceSM,
              _buildQuadrantInfo(
                'Q4: Eliminate',
                'Not Urgent & Not Important',
                'Low-value tasks to minimize or eliminate.',
                AppColors.gray600,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantInfo(
    String title,
    String subtitle,
    String description,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: AppTypography.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
