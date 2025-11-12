import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/focus/focus.dart';
import 'widgets/today_task_card.dart';

/// Focus/Today screen
///
/// Displays today's tasks with smart suggestions and progress tracking:
/// - Greeting based on time of day
/// - "What's Next" smart suggestion
/// - Overdue tasks (if any)
/// - Today's tasks organized chronologically
/// - Progress indicator
/// - Completed tasks (optional)
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on init
    Future.microtask(() {
      ref.read(focusNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusNotifierProvider);
    final greeting = ref.watch(focusGreetingProvider);
    final nextTask = ref.watch(nextSuggestedTaskProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final completedTasks = ref.watch(completedTasksTodayProvider);
    final showCompleted = ref.watch(focusShowCompletedTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
        actions: [
          // Show completed toggle
          IconButton(
            icon: Icon(
              showCompleted ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: showCompleted
                ? 'Hide completed tasks'
                : 'Show completed tasks',
            onPressed: () {
              ref
                  .read(focusNotifierProvider.notifier)
                  .toggleShowCompletedTasks();
            },
          ),

          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(focusNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(focusNotifierProvider.notifier).refresh();
        },
        child: focusState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting and date
                    _buildHeader(greeting),

                    AppSpacing.verticalSpaceMD,

                    // Progress indicator
                    _buildProgressIndicator(),

                    AppSpacing.verticalSpaceMD,

                    // Morning prompt
                    if (focusState.showMorningPrompt) ...{
                      _buildMorningPrompt(),
                      AppSpacing.verticalSpaceMD,
                    },

                    // Evening prompt
                    if (focusState.showEveningPrompt) ...{
                      _buildEveningPrompt(),
                      AppSpacing.verticalSpaceMD,
                    },

                    // What's Next suggestion
                    if (nextTask != null) ...{
                      _buildNextTaskSuggestion(nextTask),
                      AppSpacing.verticalSpaceMD,
                    },

                    // Overdue tasks
                    if (overdueTasks.isNotEmpty) ...{
                      _buildSectionHeader(
                        'Overdue',
                        overdueTasks.where((t) => !t.isCompleted).length,
                        AppColors.error,
                      ),
                      AppSpacing.verticalSpaceSM,
                      ...overdueTasks.map((task) {
                        if (task.isCompleted && !showCompleted) {
                          return const SizedBox.shrink();
                        }
                        return TodayTaskCard(
                          task: task,
                          isOverdue: true,
                        );
                      }),
                      AppSpacing.verticalSpaceMD,
                    },

                    // Today's tasks
                    if (todayTasks.isNotEmpty) ...{
                      _buildSectionHeader(
                        'Today',
                        todayTasks.where((t) => !t.isCompleted).length,
                        AppColors.primary,
                      ),
                      AppSpacing.verticalSpaceSM,
                      ...todayTasks.map((task) {
                        if (task.isCompleted && !showCompleted) {
                          return const SizedBox.shrink();
                        }
                        return TodayTaskCard(task: task);
                      }),
                      AppSpacing.verticalSpaceMD,
                    },

                    // Completed tasks
                    if (showCompleted && completedTasks.isNotEmpty) ...{
                      _buildSectionHeader(
                        'Completed',
                        completedTasks.length,
                        AppColors.success,
                      ),
                      AppSpacing.verticalSpaceSM,
                      ...completedTasks.map((task) {
                        return TodayTaskCard(task: task, showTime: false);
                      }),
                      AppSpacing.verticalSpaceMD,
                    },

                    // Empty state
                    if (overdueTasks.isEmpty && todayTasks.isEmpty) ...{
                      _buildEmptyState(),
                    },

                    // Bottom padding
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(String greeting) {
    final now = DateTime.now();
    final formattedDate = _formatDate(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          formattedDate,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final total = ref.watch(focusTotalTasksCountProvider);
    final completed = ref.watch(focusCompletedTasksCountProvider);
    final incomplete = ref.watch(focusIncompleteTasksCountProvider);
    final percentage = ref.watch(focusCompletionPercentageProvider);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.list_alt),
              _buildStatItem('Pending', incomplete.toString(), Icons.pending_actions),
              _buildStatItem('Done', completed.toString(), Icons.check_circle),
            ],
          ),

          AppSpacing.verticalSpaceSM,

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            child: LinearProgressIndicator(
              value: total > 0 ? percentage / 100 : 0,
              minHeight: 8,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          // Percentage text
          Text(
            '${percentage.toStringAsFixed(0)}% Complete',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: AppTypography.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildMorningPrompt() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_sunny, color: AppColors.warning, size: 32),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Morning Planning',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: AppTypography.bold,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Take a moment to review your tasks for today',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: AppColors.gray600),
            onPressed: () {
              ref.read(focusNotifierProvider.notifier).dismissMorningPrompt();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEveningPrompt() {
    final completed = ref.watch(focusCompletedTasksCountProvider);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.nights_stay, color: AppColors.success, size: 32),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evening Review',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: AppTypography.bold,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Great work! You completed $completed task${completed > 1 ? 's' : ''} today',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: AppColors.gray600),
            onPressed: () {
              ref.read(focusNotifierProvider.notifier).dismissEveningPrompt();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextTaskSuggestion(task) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.white, size: 20),
              AppSpacing.horizontalSpaceXS,
              Text(
                'What\'s Next',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          InkWell(
            onTap: () => context.push('/home/task/${task.id}'),
            child: Text(
              task.title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
                fontWeight: AppTypography.semiBold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...{
            SizedBox(height: AppSpacing.xs),
            Text(
              task.description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          },
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpacing.horizontalSpaceXS,
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        AppSpacing.horizontalSpaceXS,
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: AppTypography.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success.withOpacity(0.5),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'All Clear!',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: AppTypography.bold,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'You have no tasks for today',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            ElevatedButton.icon(
              onPressed: () => context.push('/home/create'),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, $monthName ${date.day}, ${date.year}';
  }
}
