import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/ai_extraction_result.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/ai/ai_image_providers.dart';

/// AI Task Review Screen
///
/// Review and edit extracted tasks before creating them
class AiTaskReviewScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final ExtractionMode mode;

  const AiTaskReviewScreen({
    super.key,
    required this.imagePath,
    required this.mode,
  });

  @override
  ConsumerState<AiTaskReviewScreen> createState() =>
      _AiTaskReviewScreenState();
}

class _AiTaskReviewScreenState extends ConsumerState<AiTaskReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Start extraction when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExtraction();
    });
  }

  Future<void> _startExtraction() async {
    await ref.read(aiImageNotifierProvider.notifier).extractFromImage(
          imagePath: widget.imagePath,
          mode: widget.mode,
        );
  }

  Future<void> _createTasks() async {
    final notifier = ref.read(aiImageNotifierProvider.notifier);
    final count = await notifier.createTasksFromSelected();

    if (!mounted) return;

    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Created $count task${count > 1 ? "s" : ""} successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back to home
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExtracting = ref.watch(isExtractingProvider);
    final hasResult = ref.watch(hasExtractionResultProvider);
    final isCreating = ref.watch(isCreatingTasksProvider);
    final error = ref.watch(aiErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Tasks'),
        subtitle: const Text('Edit and select tasks to create'),
        actions: [
          if (hasResult && !isExtracting)
            AppIconButton(
              icon: Icons.done_all,
              onPressed: () {
                ref.read(aiImageNotifierProvider.notifier).selectAllTasks();
              },
              tooltip: 'Select all',
            ),
        ],
      ),
      body: _buildBody(isExtracting, hasResult, error),
      bottomNavigationBar: hasResult && !isExtracting
          ? _buildBottomBar(isCreating)
          : null,
    );
  }

  Widget _buildBody(bool isExtracting, bool hasResult, String? error) {
    if (isExtracting) {
      return _buildExtracting();
    }

    if (error != null) {
      return _buildError(error);
    }

    if (!hasResult) {
      return _buildEmptyState();
    }

    return _buildTaskList();
  }

  Widget _buildExtracting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show captured image
          Container(
            width: 200,
            height: 200,
            margin: EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusLG,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppSpacing.borderRadiusLG,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const CircularProgressIndicator(),
          AppSpacing.verticalSpaceMD,
          Text(
            'Extracting tasks from image...',
            style: AppTypography.titleMedium,
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Using AI to recognize text and parse tasks',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'Extraction Failed',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              error,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            AppButton(
              onPressed: _startExtraction,
              child: const Text('Try Again'),
            ),
          ],
        ),
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
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'No Tasks Found',
              style: AppTypography.headlineMedium,
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'We couldn\'t find any tasks in this image. Try capturing again with better lighting.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            AppButton(
              onPressed: () => context.pop(),
              child: const Text('Capture Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final result = ref.watch(currentExtractionResultProvider)!;
    final confidenceLevel = ref.watch(confidenceLevelProvider);

    return Column(
      children: [
        // Stats and confidence
        _buildStatsHeader(result, confidenceLevel),

        // Image preview (small)
        _buildImagePreview(),

        // Divider
        const Divider(height: 1),

        // Task list
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.verticalSpaceMD,
            itemCount: result.taskCount,
            itemBuilder: (context, index) {
              final task = result.parsedTasks[index];
              final isSelected = ref.watch(isTaskSelectedProvider(index));

              return _TaskCard(
                task: task,
                index: index,
                isSelected: isSelected,
                onToggle: () {
                  ref
                      .read(aiImageNotifierProvider.notifier)
                      .toggleTaskSelection(index);
                },
                onEdit: () => _editTask(index, task),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(
    AiExtractionResult result,
    ConfidenceLevel confidenceLevel,
  ) {
    return Container(
      padding: AppSpacing.pagePadding,
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.taskCount} task${result.taskCount != 1 ? "s" : ""} found',
                      style: AppTypography.titleMedium,
                    ),
                    AppSpacing.verticalSpaceXXS,
                    Text(
                      confidenceLevel.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              _ConfidenceBadge(level: confidenceLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 100,
      margin: EdgeInsets.all(AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusMD,
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isCreating) {
    final selectedCount = ref.watch(selectedTasksProvider).length;
    final canCreate = ref.watch(canCreateTasksProvider);

    return SafeArea(
      child: Container(
        padding: AppSpacing.pagePadding,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AppButton(
          onPressed: canCreate ? _createTasks : null,
          fullWidth: true,
          loading: isCreating,
          enabled: !isCreating && canCreate,
          child: Text(
            'Create $selectedCount Task${selectedCount != 1 ? "s" : ""}',
          ),
        ),
      ),
    );
  }

  void _editTask(int index, ParsedTask task) {
    // TODO: Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task editing coming soon')),
    );
  }
}

/// Task card widget
class _TaskCard extends StatelessWidget {
  final ParsedTask task;
  final int index;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TaskCard({
    required this.task,
    required this.index,
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      onTap: onToggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: isSelected,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
          AppSpacing.horizontalSpaceXS,

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),

                // Metadata
                if (task.hasDueDate || task.hasPriority || task.hasTags) ...[
                  AppSpacing.verticalSpaceXS,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      if (task.hasDueDate)
                        _MetadataChip(
                          icon: Icons.calendar_today,
                          label: _formatDate(task.dueDate!),
                          color: AppColors.primary,
                        ),
                      if (task.hasPriority)
                        _MetadataChip(
                          icon: Icons.flag,
                          label: _getPriorityText(task.priority),
                          color: AppColors.getPriorityColor(task.priority),
                        ),
                      ...task.tags.map(
                        (tag) => _MetadataChip(
                          icon: Icons.tag,
                          label: tag,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ],

                // Confidence
                AppSpacing.verticalSpaceXS,
                _ConfidenceIndicator(confidence: task.confidence),
              ],
            ),
          ),

          // Edit button
          AppIconButton(
            icon: Icons.edit,
            onPressed: onEdit,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == today.add(const Duration(days: 1))) return 'Tomorrow';

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

/// Metadata chip
class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 12, color: color),
          SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Confidence indicator
class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const _ConfidenceIndicator({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    final color = _getColor();

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 4,
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          '$percentage% confident',
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  Color _getColor() {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

/// Confidence badge
class _ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel level;

  const _ConfidenceBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 16, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            level.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (level) {
      case ConfidenceLevel.high:
        return AppColors.success;
      case ConfidenceLevel.medium:
        return AppColors.warning;
      case ConfidenceLevel.low:
        return AppColors.error;
      case ConfidenceLevel.none:
        return AppColors.gray600;
    }
  }

  IconData _getIcon() {
    switch (level) {
      case ConfidenceLevel.high:
        return Icons.check_circle;
      case ConfidenceLevel.medium:
        return Icons.info;
      case ConfidenceLevel.low:
        return Icons.warning;
      case ConfidenceLevel.none:
        return Icons.help_outline;
    }
  }
}
