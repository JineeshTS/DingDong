import '../../lib/domain/entities/task_entity.dart';
import '../../lib/domain/entities/user_entity.dart';
import '../../lib/domain/entities/list_entity.dart';
import '../../lib/domain/entities/tag_entity.dart';

/// Mock data factory for creating test entities
///
/// Provides pre-configured test data for unit and widget tests
class MockData {
  // ==========================================================================
  // User Mock Data
  // ==========================================================================

  static UserEntity testUser1 = UserEntity(
    id: 'user_1',
    email: 'test@example.com',
    name: 'Test User',
    displayName: 'Test User',
    photoURL: 'https://example.com/avatar.jpg',
    subscriptionPlan: SubscriptionPlan.free,
    subscriptionStatus: SubscriptionStatus.active,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    settings: const UserSettings(
      theme: ThemeMode.light,
      language: 'en',
      notificationsEnabled: true,
      emailNotificationsEnabled: true,
      defaultTaskView: DefaultTaskView.list,
      weekStartsOn: 1,
    ),
  );

  static UserEntity testUser2 = UserEntity(
    id: 'user_2',
    email: 'test2@example.com',
    name: 'Test User 2',
    displayName: 'Test User 2',
    subscriptionPlan: SubscriptionPlan.premium,
    subscriptionStatus: SubscriptionStatus.active,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    settings: const UserSettings(
      theme: ThemeMode.dark,
      language: 'en',
      notificationsEnabled: true,
      emailNotificationsEnabled: true,
      defaultTaskView: DefaultTaskView.kanban,
      weekStartsOn: 0,
    ),
  );

  // ==========================================================================
  // Task Mock Data
  // ==========================================================================

  static TaskEntity taskTodo = TaskEntity(
    id: 'task_1',
    title: 'Buy groceries',
    description: 'Get milk, eggs, and bread',
    userId: 'user_1',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    tags: ['shopping', 'personal'],
    dueDate: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    sortOrder: 0,
  );

  static TaskEntity taskCompleted = TaskEntity(
    id: 'task_2',
    title: 'Complete project proposal',
    description: 'Write and submit the Q1 project proposal',
    userId: 'user_1',
    status: TaskStatus.completed,
    priority: TaskPriority.high,
    tags: ['work', 'important'],
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    sortOrder: 1,
  );

  static TaskEntity taskOverdue = TaskEntity(
    id: 'task_3',
    title: 'Call dentist',
    description: 'Schedule appointment for next month',
    userId: 'user_1',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    tags: ['health'],
    dueDate: DateTime.now().subtract(const Duration(days: 3)),
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    sortOrder: 2,
  );

  static TaskEntity taskToday = TaskEntity(
    id: 'task_4',
    title: 'Team meeting at 2pm',
    description: 'Discuss Q2 roadmap',
    userId: 'user_1',
    status: TaskStatus.todo,
    priority: TaskPriority.critical,
    tags: ['work', 'meetings'],
    dueDate: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    sortOrder: 3,
  );

  static TaskEntity taskNoDate = TaskEntity(
    id: 'task_5',
    title: 'Read "Atomic Habits"',
    description: null,
    userId: 'user_1',
    status: TaskStatus.todo,
    priority: TaskPriority.low,
    tags: ['personal', 'reading'],
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    sortOrder: 4,
  );

  static TaskEntity taskWithSubtasks = TaskEntity(
    id: 'task_6',
    title: 'Plan birthday party',
    description: 'Organize surprise party for Sarah',
    userId: 'user_1',
    status: TaskStatus.inProgress,
    priority: TaskPriority.medium,
    tags: ['personal', 'events'],
    dueDate: DateTime.now().add(const Duration(days: 14)),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now(),
    sortOrder: 5,
  );

  static TaskEntity subtask1 = TaskEntity(
    id: 'subtask_1',
    title: 'Book venue',
    userId: 'user_1',
    status: TaskStatus.completed,
    priority: TaskPriority.medium,
    parentTaskId: 'task_6',
    completedAt: DateTime.now().subtract(const Duration(hours: 12)),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    sortOrder: 0,
  );

  static TaskEntity subtask2 = TaskEntity(
    id: 'subtask_2',
    title: 'Send invitations',
    userId: 'user_1',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    parentTaskId: 'task_6',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    sortOrder: 1,
  );

  // ==========================================================================
  // List Mock Data
  // ==========================================================================

  static ListEntity defaultList = ListEntity(
    id: 'list_1',
    name: 'Personal',
    userId: 'user_1',
    color: '#2196F3',
    icon: 'person',
    isDefault: true,
    sortOrder: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static ListEntity workList = ListEntity(
    id: 'list_2',
    name: 'Work',
    userId: 'user_1',
    color: '#FF9800',
    icon: 'work',
    isDefault: false,
    sortOrder: 1,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static ListEntity sharedList = ListEntity(
    id: 'list_3',
    name: 'Shared Project',
    userId: 'user_1',
    color: '#4CAF50',
    icon: 'group',
    isDefault: false,
    isShared: true,
    sharedWith: ['user_2'],
    sortOrder: 2,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
  );

  // ==========================================================================
  // Tag Mock Data
  // ==========================================================================

  static TagEntity personalTag = TagEntity(
    id: 'tag_1',
    name: 'personal',
    userId: 'user_1',
    color: '#9C27B0',
    usageCount: 15,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  static TagEntity workTag = TagEntity(
    id: 'tag_2',
    name: 'work',
    userId: 'user_1',
    color: '#FF5722',
    usageCount: 32,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  static TagEntity urgentTag = TagEntity(
    id: 'tag_3',
    name: 'urgent',
    userId: 'user_1',
    color: '#F44336',
    usageCount: 8,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  );

  // ==========================================================================
  // Helper Methods
  // ==========================================================================

  /// Get all mock tasks
  static List<TaskEntity> getAllTasks() {
    return [
      taskTodo,
      taskCompleted,
      taskOverdue,
      taskToday,
      taskNoDate,
      taskWithSubtasks,
      subtask1,
      subtask2,
    ];
  }

  /// Get only incomplete tasks
  static List<TaskEntity> getIncompleteTasks() {
    return getAllTasks()
        .where((task) => task.status != TaskStatus.completed)
        .toList();
  }

  /// Get only completed tasks
  static List<TaskEntity> getCompletedTasks() {
    return getAllTasks()
        .where((task) => task.status == TaskStatus.completed)
        .toList();
  }

  /// Get tasks due today
  static List<TaskEntity> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return getAllTasks().where((task) {
      if (task.dueDate == null) return false;
      final taskDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate == today;
    }).toList();
  }

  /// Get overdue tasks
  static List<TaskEntity> getOverdueTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return getAllTasks().where((task) {
      if (task.dueDate == null) return false;
      if (task.status == TaskStatus.completed) return false;
      final taskDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate.isBefore(today);
    }).toList();
  }

  /// Get upcoming tasks (next 7 days)
  static List<TaskEntity> getUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    return getAllTasks().where((task) {
      if (task.dueDate == null) return false;
      if (task.status == TaskStatus.completed) return false;
      final taskDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate.isAfter(today) && taskDate.isBefore(nextWeek);
    }).toList();
  }

  /// Get all mock lists
  static List<ListEntity> getAllLists() {
    return [defaultList, workList, sharedList];
  }

  /// Get all mock tags
  static List<TagEntity> getAllTags() {
    return [personalTag, workTag, urgentTag];
  }

  /// Create a custom task for testing
  static TaskEntity createTask({
    String id = 'custom_task',
    required String title,
    String? description,
    String userId = 'user_1',
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    DateTime? dueDate,
    DateTime? completedAt,
    String? parentTaskId,
    String? listId,
  }) {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      userId: userId,
      status: status,
      priority: priority,
      tags: tags,
      dueDate: dueDate,
      completedAt: completedAt,
      parentTaskId: parentTaskId,
      categoryId: listId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sortOrder: 0,
    );
  }

  /// Create a custom list for testing
  static ListEntity createList({
    String id = 'custom_list',
    required String name,
    String userId = 'user_1',
    String color = '#2196F3',
    String icon = 'list',
    bool isDefault = false,
    bool isShared = false,
    List<String> sharedWith = const [],
  }) {
    return ListEntity(
      id: id,
      name: name,
      userId: userId,
      color: color,
      icon: icon,
      isDefault: isDefault,
      isShared: isShared,
      sharedWith: sharedWith,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a custom tag for testing
  static TagEntity createTag({
    String id = 'custom_tag',
    required String name,
    String userId = 'user_1',
    String color = '#9C27B0',
    int usageCount = 0,
  }) {
    return TagEntity(
      id: id,
      name: name,
      userId: userId,
      color: color,
      usageCount: usageCount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
