import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets.dart';

/// Quick add task dialog for fast task creation
///
/// A simplified task creation flow with only essential fields:
/// - Title (required)
/// - Due date (optional)
/// - Priority (optional)
///
/// Usage:
/// ```dart
/// showQuickAddTaskDialog(context);
/// ```
Future<void> showQuickAddTaskDialog(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _QuickAddTaskDialog(),
  );
}

class _QuickAddTaskDialog extends ConsumerStatefulWidget {
  const _QuickAddTaskDialog();

  @override
  ConsumerState<_QuickAddTaskDialog> createState() =>
      _QuickAddTaskDialogState();
}

class _QuickAddTaskDialogState extends ConsumerState<_QuickAddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  int _selectedPriority = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.lg),
          topRight: Radius.circular(AppSpacing.lg),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCircular),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Icon(
                      Icons.add_task,
                      color: AppColors.primary,
                      size: AppSpacing.iconMD,
                    ),
                    AppSpacing.horizontalSpaceSM,
                    Text(
                      'Quick Add Task',
                      style: AppTypography.headlineSmall,
                    ),
                    const Spacer(),
                    AppIconButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceMD,

                // Task title input
                AppTextField(
                  controller: _titleController,
                  label: 'Task Title',
                  hint: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.task_outlined),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleQuickAdd(),
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

                // Quick options row
                Row(
                  children: [
                    // Due date quick selector
                    Expanded(
                      child: _QuickDateButton(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                    AppSpacing.horizontalSpaceXS,
                    // Priority quick selector
                    Expanded(
                      child: _QuickPriorityButton(
                        selectedPriority: _selectedPriority,
                        onPrioritySelected: (priority) {
                          setState(() => _selectedPriority = priority);
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceMD,

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: _handleQuickAdd,
                        loading: _isLoading,
                        enabled: !_isLoading,
                        icon: Icons.add,
                        child: const Text('Add Task'),
                      ),
                    ),
                    AppSpacing.horizontalSpaceXS,
                    AppIconButton(
                      icon: Icons.settings,
                      onPressed: _handleFullForm,
                      tooltip: 'More options',
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceSM,

                // Quick add hint
                Center(
                  child: Text(
                    'Tap "More options" for additional fields',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ),
                AppSpacing.verticalSpaceSM,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleQuickAdd() async {
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
      final newTask = TaskEntity.create(
        title: _titleController.text.trim(),
        userId: userId,
        dueDate: _selectedDate,
        priority: TaskPriority.values[_selectedPriority],
      );

      await ref.read(taskNotifierProvider.notifier).createTask(newTask);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              AppSpacing.horizontalSpaceXS,
              const Text('Task created successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating task: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleFullForm() {
    Navigator.pop(context);
    // Navigate to full form - this will be handled by the caller
    // showing the full TaskFormScreen
  }
}

/// Quick date selector button
class _QuickDateButton extends StatelessWidget {
  const _QuickDateButton({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () => _showDateOptions(context),
      variant: selectedDate != null
          ? AppButtonVariant.primary
          : AppButtonVariant.outlined,
      size: AppButtonSize.small,
      icon: Icons.calendar_today,
      child: Text(
        selectedDate != null ? _formatDate(selectedDate!) : 'Date',
      ),
    );
  }

  Future<void> _showDateOptions(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalSpaceSM,
            Text('Select Due Date', style: AppTypography.titleMedium),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.today, color: AppColors.warning),
              title: const Text('Today'),
              onTap: () {
                Navigator.pop(context);
                onDateSelected(today);
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: AppColors.info),
              title: const Text('Tomorrow'),
              onTap: () {
                Navigator.pop(context);
                onDateSelected(tomorrow);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: AppColors.primary),
              title: const Text('Next Week'),
              onTap: () {
                Navigator.pop(context);
                onDateSelected(nextWeek);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.gray600),
              title: const Text('Pick Date...'),
              onTap: () async {
                Navigator.pop(context);
                final date = await showDatePicker(
                  context: context,
                  initialDate: today,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 365 * 5)),
                );
                if (date != null) {
                  onDateSelected(date);
                }
              },
            ),
            if (selectedDate != null)
              ListTile(
                leading: Icon(Icons.clear, color: AppColors.error),
                title: Text('Clear Date', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  onDateSelected(null);
                },
              ),
            AppSpacing.verticalSpaceSM,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';

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
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Quick priority selector button
class _QuickPriorityButton extends StatelessWidget {
  const _QuickPriorityButton({
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  final int selectedPriority;
  final ValueChanged<int> onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(selectedPriority);
    final label = _getPriorityLabel(selectedPriority);

    return AppButton(
      onPressed: () => _showPriorityOptions(context),
      variant: selectedPriority > 0
          ? AppButtonVariant.primary
          : AppButtonVariant.outlined,
      size: AppButtonSize.small,
      icon: Icons.flag,
      child: Text(label),
    );
  }

  Future<void> _showPriorityOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalSpaceSM,
            Text('Select Priority', style: AppTypography.titleMedium),
            const Divider(),
            _buildPriorityOption(context, 0, 'None', AppColors.gray500),
            _buildPriorityOption(context, 1, 'Low', AppColors.info),
            _buildPriorityOption(context, 2, 'Medium', AppColors.warning),
            _buildPriorityOption(context, 3, 'High', AppColors.error),
            _buildPriorityOption(context, 4, 'Critical', AppColors.tagRed800),
            AppSpacing.verticalSpaceSM,
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    int priority,
    String label,
    Color color,
  ) {
    final isSelected = selectedPriority == priority;

    return ListTile(
      leading: Icon(Icons.flag, color: color),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        onPrioritySelected(priority);
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      case 4:
        return AppColors.tagRed800;
      default:
        return AppColors.gray500;
    }
  }

  String _getPriorityLabel(int priority) {
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
        return 'Priority';
    }
  }
}
