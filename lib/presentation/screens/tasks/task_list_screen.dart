import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/auth/auth_providers.dart';
import '../../providers/task/task_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/task/task_item.dart';

/// Main view for the task list tab
enum TaskListView {
  today,
  inbox,
  upcoming,
  completed,
}

/// Task list screen - main screen of the app
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  int _selectedIndex = 0;
  TaskListView _currentView = TaskListView.today;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      final notifier = ref.read(taskNotifierProvider.notifier);
      notifier.getTasksDueToday(userId);
      notifier.getOverdueTasks(userId);
      notifier.getUpcomingTasks(userId);
    }
  }

  void _onViewChanged(TaskListView view) {
    setState(() {
      _currentView = view;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _onViewChanged(TaskListView.today);
        break;
      case 1:
        _onViewChanged(TaskListView.inbox);
        break;
      case 2:
        // Calendar - TODO
        break;
      case 3:
        // Focus - TODO
        break;
      case 4:
        _showProfileMenu();
        break;
    }
  }

  void _showProfileMenu() {
    final user = ref.read(currentUserProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User info
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user?.displayName ?? 'User'),
                subtitle: Text(user?.email ?? ''),
              ),
              const Divider(),

              // Settings
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),

              // Sign out
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTaskTap(TaskEntity task) {
    // TODO: Navigate to task detail
    // context.push('/task/${task.id}');
  }

  Future<void> _onTaskComplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
    if (mounted) {
      SuccessSnackBar.show(context, message: 'Task completed!');
    }
  }

  Future<void> _onTaskUncomplete(TaskEntity task) async {
    await ref.read(taskNotifierProvider.notifier).uncompleteTask(task.id);
  }

  void _onCreateTask() {
    // TODO: Navigate to create task screen
    // context.push('/task/create');
    _showQuickAddTaskSheet();
  }

  void _showQuickAddTaskSheet() {
    final taskTitleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskTitleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What do you want to do?',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) async {
                  if (value.trim().isNotEmpty) {
                    Navigator.pop(context);
                    final userId = ref.read(currentUserProvider)?.id;
                    if (userId != null) {
                      final task = TaskEntity.create(
                        title: value.trim(),
                        userId: userId,
                      );
                      await ref
                          .read(taskNotifierProvider.notifier)
                          .createTask(task);
                      _loadTasks(); // Refresh
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () {
                          // TODO: Show date picker
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.flag_outlined),
                        onPressed: () {
                          // TODO: Show priority picker
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.label_outline),
                        onPressed: () {
                          // TODO: Show tag picker
                        },
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final value = taskTitleController.text;
                      if (value.trim().isNotEmpty) {
                        Navigator.pop(context);
                        final userId = ref.read(currentUserProvider)?.id;
                        if (userId != null) {
                          final task = TaskEntity.create(
                            title: value.trim(),
                            userId: userId,
                          );
                          await ref
                              .read(taskNotifierProvider.notifier)
                              .createTask(task);
                          _loadTasks(); // Refresh
                        }
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(taskNotifierProvider.notifier).searchTasks(
            query: query,
            userId: userId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onSubmitted: _performSearch,
              )
            : Text(_getTitle()),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Show filter options
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'completed':
                    _onViewChanged(TaskListView.completed);
                    break;
                  case 'refresh':
                    _loadTasks();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'completed',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('Completed Tasks'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Refresh'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildBody(taskState, isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.center_focus_strong_outlined),
            selectedIcon: Icon(Icons.center_focus_strong),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentView) {
      case TaskListView.today:
        return 'Today';
      case TaskListView.inbox:
        return 'Inbox';
      case TaskListView.upcoming:
        return 'Upcoming';
      case TaskListView.completed:
        return 'Completed';
    }
  }

  Widget _buildBody(TaskState taskState, bool isDark) {
    // Check for errors first
    if (taskState.todayError != null) {
      return ErrorState.generic(
        onRetry: _loadTasks,
      );
    }

    // Determine which tasks to show
    List<TaskEntity> tasks;
    bool isLoading;

    switch (_currentView) {
      case TaskListView.today:
        tasks = taskState.todayTasks;
        isLoading = taskState.isLoadingToday;
        break;
      case TaskListView.inbox:
        tasks = taskState.allTasks.items;
        isLoading = taskState.allTasks.isLoading;
        break;
      case TaskListView.upcoming:
        tasks = taskState.upcomingTasks;
        isLoading = taskState.isLoadingUpcoming;
        break;
      case TaskListView.completed:
        tasks = taskState.completedTasks.items;
        isLoading = taskState.completedTasks.isLoading;
        break;
    }

    // Show loading
    if (isLoading && tasks.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    // Show empty state
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    // Build task list with sections
    return RefreshIndicator(
      onRefresh: () async {
        _loadTasks();
      },
      child: _buildTaskList(tasks, taskState),
    );
  }

  Widget _buildEmptyState() {
    switch (_currentView) {
      case TaskListView.today:
        return EmptyState.todayTasks(onAddTask: _onCreateTask);
      case TaskListView.inbox:
        return EmptyState.tasks(onAddTask: _onCreateTask);
      case TaskListView.upcoming:
        return const EmptyState(
          icon: Icons.upcoming,
          title: 'No upcoming tasks',
          subtitle: 'Tasks due in the next 7 days will appear here',
        );
      case TaskListView.completed:
        return EmptyState.completedTasks();
    }
  }

  Widget _buildTaskList(List<TaskEntity> tasks, TaskState taskState) {
    // Group tasks for "Today" view
    if (_currentView == TaskListView.today) {
      return _buildGroupedTaskList(tasks, taskState);
    }

    // Simple list for other views
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onTap: () => _onTaskTap(task),
          onComplete: () => _onTaskComplete(task),
          onUncomplete: () => _onTaskUncomplete(task),
        );
      },
    );
  }

  Widget _buildGroupedTaskList(List<TaskEntity> todayTasks, TaskState taskState) {
    final overdueTasks = taskState.overdueTasks;

    return CustomScrollView(
      slivers: [
        // Overdue section
        if (overdueTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              'Overdue',
              overdueTasks.length,
              color: AppColors.error,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = overdueTasks[index];
                return TaskItem(
                  task: task,
                  onTap: () => _onTaskTap(task),
                  onComplete: () => _onTaskComplete(task),
                  onUncomplete: () => _onTaskUncomplete(task),
                );
              },
              childCount: overdueTasks.length,
            ),
          ),
        ],

        // Today section
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Today',
            todayTasks.length,
            color: AppColors.primary,
          ),
        ),
        if (todayTasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No tasks for today',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = todayTasks[index];
                return TaskItem(
                  task: task,
                  onTap: () => _onTaskTap(task),
                  onComplete: () => _onTaskComplete(task),
                  onUncomplete: () => _onTaskUncomplete(task),
                );
              },
              childCount: todayTasks.length,
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ??
                  (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
