import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';

/// Task creation and editing form screen
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    super.key,
    this.taskId,
  });

  /// Task ID for editing (null for creating new task)
  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  int _selectedPriority = 0;
  List<String> _tags = [];
  bool _isLoading = false;
  TaskEntity? _existingTask;

  bool get _isEditMode => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadTaskData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskData() async {
    if (widget.taskId == null) return;

    // Watch the task to load existing data
    final taskAsync = ref.read(taskByIdProvider(widget.taskId!));
    taskAsync.when(
      data: (task) {
        if (task != null) {
          setState(() {
            _existingTask = task;
            _titleController.text = task.title;
            _descriptionController.text = task.description ?? '';
            _selectedDueDate = task.dueDate;
            _selectedPriority = task.priority.index;
            _tags = List.from(task.tags);
          });
        }
      },
      loading: () {},
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading task: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.close,
          onPressed: _handleCancel,
          tooltip: 'Cancel',
        ),
        title: Text(_isEditMode ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditMode)
            AppIconButton(
              icon: Icons.delete,
              onPressed: _handleDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              AppTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'What needs to be done?',
                prefixIcon: const Icon(Icons.task_outlined),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalSpaceMD,

              // Description field
              AppTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add more details...',
                prefixIcon: const Icon(Icons.notes_outlined),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              AppSpacing.verticalSpaceMD,

              // Due date section
              _buildDueDateSection(),
              AppSpacing.verticalSpaceMD,

              // Priority section
              _buildPrioritySection(),
              AppSpacing.verticalSpaceMD,

              // Tags section
              _buildTagsSection(),
              AppSpacing.verticalSpaceMD,

              // Category section (placeholder)
              _buildCategorySection(),
              AppSpacing.verticalSpaceXL,

              // Save button
              AppButton(
                onPressed: _handleSave,
                loading: _isLoading,
                enabled: !_isLoading,
                fullWidth: true,
                icon: _isEditMode ? Icons.save : Icons.add,
                child: Text(_isEditMode ? 'Save Changes' : 'Create Task'),
              ),
              AppSpacing.verticalSpaceSM,

              // Cancel button
              AppButton(
                onPressed: _handleCancel,
                variant: AppButtonVariant.outlined,
                fullWidth: true,
                enabled: !_isLoading,
                child: const Text('Cancel'),
              ),
              AppSpacing.verticalSpaceXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Due Date',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: _selectedDueDate == null
                    ? AppButton(
                        onPressed: _handleSelectDate,
                        variant: AppButtonVariant.outlined,
                        icon: Icons.event,
                        child: const Text('Select Date'),
                      )
                    : Container(
                        padding: AppSpacing.paddingSM,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppSpacing.borderRadiusSM,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_selectedDueDate!),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _selectedDueDate = null);
                              },
                              icon: const Icon(Icons.close, size: 20),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Priority',
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
            children: [
              _buildPriorityChip(0, 'None', AppColors.gray500),
              _buildPriorityChip(1, 'Low', AppColors.info),
              _buildPriorityChip(2, 'Medium', AppColors.warning),
              _buildPriorityChip(3, 'High', AppColors.error),
              _buildPriorityChip(4, 'Critical', AppColors.tagRed800),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(int priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;

    return InkWell(
      onTap: () {
        setState(() => _selectedPriority = priority);
      },
      borderRadius: AppSpacing.borderRadiusXS,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.gray100,
          borderRadius: AppSpacing.borderRadiusXS,
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag,
              size: AppSpacing.iconXS,
              color: isSelected ? color : AppColors.gray600,
            ),
            AppSpacing.horizontalSpaceXXS,
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.gray700,
                fontWeight:
                    isSelected ? AppTypography.semiBold : AppTypography.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
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
              const Spacer(),
              AppButton(
                onPressed: _handleAddTag,
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                child: const Text('Add Tag'),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            AppSpacing.verticalSpaceSM,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _tags.map((tag) {
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
                      AppSpacing.horizontalSpaceXXS,
                      InkWell(
                        onTap: () {
                          setState(() => _tags.remove(tag));
                        },
                        child: Icon(
                          Icons.close,
                          size: AppSpacing.iconXS,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            AppSpacing.verticalSpaceSM,
            Center(
              child: Text(
                'No tags added',
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

  Widget _buildCategorySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'List / Category',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          AppButton(
            onPressed: _handleSelectCategory,
            variant: AppButtonVariant.outlined,
            icon: Icons.arrow_drop_down,
            child: const Text('Select List'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSelectDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (selectedDate != null) {
      setState(() => _selectedDueDate = selectedDate);
    }
  }

  Future<void> _handleAddTag() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            prefixIcon: Icon(Icons.tag),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && !_tags.contains(result)) {
      setState(() => _tags.add(result));
    }
  }

  void _handleSelectCategory() {
    // TODO: Implement category selector
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category selector coming soon')),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.value?.when(
      data: (user) => user?.id,
      loading: () => null,
      error: (_, __) => null,
    );

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create tasks'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final taskNotifier = ref.read(taskNotifierProvider.notifier);

      if (_isEditMode && _existingTask != null) {
        // Update existing task
        final updatedTask = _existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          priority: TaskPriority.values[_selectedPriority],
          tags: _tags,
          updatedAt: DateTime.now(),
        );

        await taskNotifier.updateTask(updatedTask);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Create new task
        final newTask = TaskEntity.create(
          title: _titleController.text.trim(),
          userId: userId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: _selectedDueDate,
          priority: TaskPriority.values[_selectedPriority],
          tags: _tags,
        );

        await taskNotifier.createTask(newTask);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (!_isEditMode || widget.taskId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
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

    setState(() => _isLoading = true);

    try {
      await ref.read(taskNotifierProvider.notifier).deleteTask(widget.taskId!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home'); // Go back to task list
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting task: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleCancel() {
    if (_titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
