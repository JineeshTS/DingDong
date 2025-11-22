import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/auth/auth_providers.dart';
import '../../providers/task/task_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

/// Task edit/create screen
class TaskEditScreen extends ConsumerStatefulWidget {
  /// Task ID for editing, null for creating
  final String? taskId;

  const TaskEditScreen({
    super.key,
    this.taskId,
  });

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isInitialized = false;

  // Task properties
  TaskPriority _priority = TaskPriority.none;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _dueDate;
  DateTime? _startDate;
  TimeOfDay? _dueTime;
  Duration? _estimatedDuration;
  int? _energyLevel;
  List<String> _tags = [];
  List<String> _contextTags = [];
  String? _listId;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTask();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    await ref.read(taskNotifierProvider.notifier).getTask(widget.taskId!);
    final task = ref.read(taskNotifierProvider).selectedTask;
    if (task != null) {
      _populateFields(task);
    }
  }

  void _populateFields(TaskEntity task) {
    setState(() {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _locationController.text = task.location ?? '';
      _priority = task.priority;
      _status = task.status;
      _dueDate = task.dueDate;
      _startDate = task.startDate;
      _estimatedDuration = task.estimatedDuration;
      _energyLevel = task.energyLevel;
      _tags = List.from(task.tags);
      _contextTags = List.from(task.contextTags);
      _listId = task.listId;
      _isInitialized = true;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      DateTime? fullDueDate = _dueDate;
      if (_dueDate != null && _dueTime != null) {
        fullDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      }

      if (_isEditing) {
        final existingTask = ref.read(taskNotifierProvider).selectedTask!;
        final updatedTask = existingTask.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          dueDate: fullDueDate,
          startDate: _startDate,
          estimatedDuration: _estimatedDuration,
          energyLevel: _energyLevel,
          tags: _tags,
          contextTags: _contextTags,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          listId: _listId,
          updatedAt: now,
          lastModifiedBy: userId,
        );
        await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
      } else {
        final newTask = TaskEntity(
          id: const Uuid().v4(),
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          dueDate: fullDueDate,
          startDate: _startDate,
          estimatedDuration: _estimatedDuration,
          energyLevel: _energyLevel,
          tags: _tags,
          contextTags: _contextTags,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          listId: _listId,
          createdAt: now,
          updatedAt: now,
          createdBy: userId,
        );
        await ref.read(taskNotifierProvider.notifier).createTask(newTask);
      }

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _dueDate = date);

      // Optionally select time
      final time = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? TimeOfDay.now(),
      );

      if (time != null) {
        setState(() => _dueTime = time);
      }
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Priority',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...TaskPriority.values.map((priority) => ListTile(
                  leading: Icon(
                    Icons.flag,
                    color: AppColors.getPriorityColor(priority.index),
                  ),
                  title: Text(_getPriorityName(priority)),
                  trailing: _priority == priority
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _priority = priority);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...TaskStatus.values.map((status) => ListTile(
                  leading: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  title: Text(_getStatusName(status)),
                  trailing: _status == status
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _status = status);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker() {
    final durations = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
      const Duration(hours: 1, minutes: 30),
      const Duration(hours: 2),
      const Duration(hours: 3),
      const Duration(hours: 4),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Estimated Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...durations.map((duration) => ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(_formatDuration(duration)),
                  trailing: _estimatedDuration == duration
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _estimatedDuration = duration);
                    Navigator.pop(context);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear'),
              onTap: () {
                setState(() => _estimatedDuration = null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEnergyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Energy Level Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...[1, 2, 3, 4, 5].map((level) => ListTile(
                  leading: Icon(
                    Icons.bolt,
                    color: _getEnergyColor(level),
                  ),
                  title: Text(_getEnergyText(level)),
                  trailing: _energyLevel == level
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _energyLevel = level);
                    Navigator.pop(context);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear'),
              onTap: () {
                setState(() => _energyLevel = null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showTagInput() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                if (!_tags.contains(value.trim())) {
                  _tags.add(value.trim());
                }
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text;
              if (value.trim().isNotEmpty) {
                setState(() {
                  if (!_tags.contains(value.trim())) {
                    _tags.add(value.trim());
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showContextTagPicker() {
    final commonContexts = [
      '@computer',
      '@phone',
      '@home',
      '@office',
      '@errands',
      '@email',
      '@calls',
      '@waiting',
      '@anywhere',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Context Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...commonContexts.map((ctx) => CheckboxListTile(
                    title: Text(ctx),
                    value: _contextTags.contains(ctx),
                    onChanged: (checked) {
                      setModalState(() {
                        if (checked == true) {
                          _contextTags.add(ctx);
                        } else {
                          _contextTags.remove(ctx);
                        }
                      });
                      setState(() {});
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityName(TaskPriority priority) {
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

  String _getStatusName(TaskStatus status) {
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

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show loading when editing and task not yet loaded
    if (_isEditing && !_isInitialized && taskState.isLoadingTask) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Task'),
        ),
        body: const Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Title
            AppTextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              label: 'Title',
              hint: 'What needs to be done?',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              onSubmitted: (_) => _descriptionFocusNode.requestFocus(),
            ),
            Gap.v16,

            // Description
            AppTextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              label: 'Description',
              hint: 'Add more details...',
              maxLines: 3,
            ),
            Gap.v24,

            // Status & Priority Row
            Row(
              children: [
                Expanded(
                  child: _OptionTile(
                    icon: _getStatusIcon(_status),
                    iconColor: _getStatusColor(_status),
                    label: 'Status',
                    value: _getStatusName(_status),
                    onTap: _showStatusPicker,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _OptionTile(
                    icon: Icons.flag,
                    iconColor: AppColors.getPriorityColor(_priority.index),
                    label: 'Priority',
                    value: _getPriorityName(_priority),
                    onTap: _showPriorityPicker,
                  ),
                ),
              ],
            ),
            Gap.v16,

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: _OptionTile(
                    icon: Icons.event,
                    iconColor: _dueDate != null ? AppColors.primary : null,
                    label: 'Due Date',
                    value: _dueDate != null
                        ? DateFormat.MMMd().format(_dueDate!)
                        : 'Not set',
                    onTap: _selectDueDate,
                    onClear: _dueDate != null
                        ? () => setState(() {
                              _dueDate = null;
                              _dueTime = null;
                            })
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _OptionTile(
                    icon: Icons.play_arrow,
                    iconColor: _startDate != null ? AppColors.info : null,
                    label: 'Start Date',
                    value: _startDate != null
                        ? DateFormat.MMMd().format(_startDate!)
                        : 'Not set',
                    onTap: _selectStartDate,
                    onClear: _startDate != null
                        ? () => setState(() => _startDate = null)
                        : null,
                  ),
                ),
              ],
            ),
            Gap.v16,

            // Duration & Energy Row
            Row(
              children: [
                Expanded(
                  child: _OptionTile(
                    icon: Icons.timer_outlined,
                    iconColor: _estimatedDuration != null ? AppColors.secondary : null,
                    label: 'Duration',
                    value: _estimatedDuration != null
                        ? _formatDuration(_estimatedDuration!)
                        : 'Not set',
                    onTap: _showDurationPicker,
                    onClear: _estimatedDuration != null
                        ? () => setState(() => _estimatedDuration = null)
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _OptionTile(
                    icon: Icons.bolt,
                    iconColor: _energyLevel != null ? _getEnergyColor(_energyLevel!) : null,
                    label: 'Energy',
                    value: _energyLevel != null
                        ? _getEnergyText(_energyLevel!)
                        : 'Not set',
                    onTap: _showEnergyPicker,
                    onClear: _energyLevel != null
                        ? () => setState(() => _energyLevel = null)
                        : null,
                  ),
                ),
              ],
            ),
            Gap.v24,

            // Tags section
            _SectionHeader(
              title: 'Tags',
              actionLabel: 'Add',
              onAction: _showTagInput,
            ),
            Gap.v8,
            if (_tags.isEmpty)
              Text(
                'No tags added',
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                          backgroundColor: AppColors.getTagColor(tag.hashCode).withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: AppColors.getTagColor(tag.hashCode),
                          ),
                        ))
                    .toList(),
              ),
            Gap.v24,

            // Context tags section
            _SectionHeader(
              title: 'Context',
              actionLabel: 'Add',
              onAction: _showContextTagPicker,
            ),
            Gap.v8,
            if (_contextTags.isEmpty)
              Text(
                'No context tags added',
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _contextTags
                    .map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _contextTags.remove(tag)),
                          backgroundColor: AppColors.secondary.withOpacity(0.15),
                          labelStyle: TextStyle(color: AppColors.secondary),
                        ))
                    .toList(),
              ),
            Gap.v24,

            // Location
            AppTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Add a location...',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            Gap.v32,
          ],
        ),
      ),
    );
  }
}

/// Option tile widget for selecting values
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _OptionTile({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final labelColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final valueColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? labelColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall(color: labelColor),
                  ),
                  Text(
                    value,
                    style: AppTypography.labelMedium(color: valueColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: labelColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Section header with optional action
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
