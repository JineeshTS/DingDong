import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/list_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/auth/auth_providers.dart';
import '../../providers/list/list_providers.dart';
import '../../providers/task/task_providers.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/task/task_item.dart';

/// List detail screen showing tasks in a specific list
class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _quickAddController = TextEditingController();
  final _quickAddFocusNode = FocusNode();
  bool _showQuickAdd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    _quickAddFocusNode.dispose();
    super.dispose();
  }

  void _loadTasks() {
    ref.read(taskNotifierProvider.notifier).getTasksByList(widget.listId);
  }

  void _onTaskTap(TaskEntity task) {
    context.push('/task/${task.id}');
  }

  Future<void> _onTaskComplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
  }

  Future<void> _onTaskUncomplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).uncompleteTask(task.id);
  }

  void _toggleQuickAdd() {
    setState(() {
      _showQuickAdd = !_showQuickAdd;
      if (_showQuickAdd) {
        _quickAddFocusNode.requestFocus();
      }
    });
  }

  Future<void> _quickAddTask() async {
    final title = _quickAddController.text.trim();
    if (title.isEmpty) return;

    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final task = TaskEntity(
      id: const Uuid().v4(),
      userId: userId,
      listId: widget.listId,
      title: title,
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    );

    _quickAddController.clear();
    await ref.read(taskNotifierProvider.notifier).createTask(task);
    _loadTasks();
  }

  void _onCreateTask() {
    context.push('/task/create?listId=${widget.listId}');
  }

  void _showListOptions(ListEntity list) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // List header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(int.parse(list.color.replaceFirst('#', '0xFF')))
                          .withOpacity(0.15),
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: Center(
                      child: list.icon != null
                          ? Text(list.icon!, style: const TextStyle(fontSize: 20))
                          : Icon(
                              Icons.folder,
                              color: Color(int.parse(list.color.replaceFirst('#', '0xFF'))),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Edit list
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit List'),
              onTap: () {
                Navigator.pop(context);
                _showEditListDialog(list);
              },
            ),

            // Toggle favorite
            ListTile(
              leading: Icon(
                list.isFavorite ? Icons.star : Icons.star_outline,
                color: list.isFavorite ? AppColors.warning : null,
              ),
              title: Text(list.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(listNotifierProvider.notifier).toggleFavorite(list.id);
              },
            ),

            // Archive list
            ListTile(
              leading: Icon(
                list.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              title: Text(list.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(context);
                if (list.isArchived) {
                  await ref.read(listNotifierProvider.notifier).unarchiveList(list.id);
                } else {
                  await ref.read(listNotifierProvider.notifier).archiveList(list.id);
                }
              },
            ),

            // Delete list
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete List', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                _confirmDeleteList(list);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditListDialog(ListEntity list) {
    final nameController = TextEditingController(text: list.name);
    final descController = TextEditingController(text: list.description ?? '');
    String selectedColor = list.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Name',
                ),
                Gap.v16,
                AppTextField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Optional description',
                ),
                Gap.v16,
                Text(
                  'Color',
                  style: AppTypography.labelMedium(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Gap.v8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '#2196F3',
                    '#4CAF50',
                    '#FF9800',
                    '#F44336',
                    '#9C27B0',
                    '#00BCD4',
                    '#795548',
                    '#607D8B',
                  ]
                      .map((color) => GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: selectedColor == color
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(context);

                final updatedList = list.copyWith(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  color: selectedColor,
                  updatedAt: DateTime.now(),
                );

                await ref.read(listNotifierProvider.notifier).updateList(updatedList);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteList(ListEntity list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${list.name}"? Tasks in this list will not be deleted.',
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

    if (confirmed == true && mounted) {
      await ref.read(listNotifierProvider.notifier).deleteList(list.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(listByIdProvider(widget.listId));
    final taskState = ref.watch(taskNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get list color
    final listColor = list != null
        ? Color(int.parse(list.color.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (list?.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(list!.icon!, style: const TextStyle(fontSize: 20)),
              ),
            Expanded(
              child: Text(
                list?.name ?? 'List',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (list != null)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showListOptions(list),
            ),
        ],
      ),
      body: Column(
        children: [
          // Quick add bar
          if (_showQuickAdd)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickAddController,
                      focusNode: _quickAddFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Add a task...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _quickAddTask(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleQuickAdd,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _quickAddTask,
                  ),
                ],
              ),
            ),

          // Task list
          Expanded(
            child: _buildTaskList(taskState, listColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAdd ? _quickAddTask : _toggleQuickAdd,
        backgroundColor: listColor,
        child: Icon(_showQuickAdd ? Icons.check : Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TaskState taskState, Color listColor) {
    final tasks = taskState.listTasks.items;
    final isLoading = taskState.listTasks.isLoading;
    final error = taskState.listTasks.error;

    if (isLoading && tasks.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (error != null) {
      return ErrorState.generic(onRetry: _loadTasks);
    }

    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt,
        title: 'No tasks in this list',
        subtitle: 'Add tasks to get started',
      );
    }

    // Separate completed and incomplete tasks
    final incomplete = tasks.where((t) => t.status != TaskStatus.completed).toList();
    final completed = tasks.where((t) => t.status == TaskStatus.completed).toList();

    return RefreshIndicator(
      onRefresh: () async => _loadTasks(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Incomplete tasks
          ...incomplete.map((task) => TaskItem(
                task: task,
                onTap: () => _onTaskTap(task),
                onComplete: () => _onTaskComplete(task),
                onUncomplete: () => _onTaskUncomplete(task),
              )),

          // Completed section
          if (completed.isNotEmpty) ...[
            _CompletedHeader(count: completed.length),
            ...completed.map((task) => TaskItem(
                  task: task,
                  onTap: () => _onTaskTap(task),
                  onComplete: () => _onTaskComplete(task),
                  onUncomplete: () => _onTaskUncomplete(task),
                )),
          ],
        ],
      ),
    );
  }
}

/// Completed tasks section header
class _CompletedHeader extends StatelessWidget {
  final int count;

  const _CompletedHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            'Completed',
            style: AppTypography.labelMedium(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
