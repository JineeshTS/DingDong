import 'package:equatable/equatable.dart';

/// Automation Rule entity for task automation
class AutomationRuleEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final AutomationTrigger trigger;
  final List<AutomationAction> actions;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int executionCount; // Track how many times it's been triggered

  const AutomationRuleEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.trigger,
    required this.actions,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.executionCount = 0,
  });

  AutomationRuleEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    AutomationTrigger? trigger,
    List<AutomationAction>? actions,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? executionCount,
  }) {
    return AutomationRuleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      trigger: trigger ?? this.trigger,
      actions: actions ?? this.actions,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      executionCount: executionCount ?? this.executionCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        trigger,
        actions,
        isEnabled,
        createdAt,
        updatedAt,
        executionCount,
      ];
}

/// Automation trigger types
enum AutomationTriggerType {
  taskCreated, // When a task is created
  taskCompleted, // When a task is marked complete
  taskOverdue, // When a task becomes overdue
  taskAssigned, // When a task is assigned
  tagAdded, // When a specific tag is added
  dueDateApproaching, // When due date is approaching (configurable)
  timeBased, // At a specific time/date
}

/// Automation trigger
class AutomationTrigger extends Equatable {
  final AutomationTriggerType type;
  final Map<String, dynamic>? conditions; // Additional conditions

  const AutomationTrigger({
    required this.type,
    this.conditions,
  });

  @override
  List<Object?> get props => [type, conditions];
}

/// Automation action types
enum AutomationActionType {
  createTask, // Create a new task
  updateTask, // Update an existing task
  sendNotification, // Send a notification
  moveToList, // Move task to different list
  assignToUser, // Assign task to a user
  postComment, // Post a comment on task
  addTag, // Add a tag to task
  setPriority, // Set task priority
  setDueDate, // Set task due date
}

/// Automation action
class AutomationAction extends Equatable {
  final AutomationActionType type;
  final Map<String, dynamic> parameters; // Action parameters

  const AutomationAction({
    required this.type,
    required this.parameters,
  });

  @override
  List<Object?> get props => [type, parameters];
}

/// Predefined automation templates
class AutomationTemplates {
  static const autoCompleteSubtasks = AutomationRuleEntity(
    id: 'auto_complete_subtasks',
    userId: 'system',
    name: 'Auto-complete parent when all subtasks done',
    description: 'Automatically mark parent task as complete when all subtasks are completed',
    trigger: AutomationTrigger(type: AutomationTriggerType.taskCompleted),
    actions: [
      AutomationAction(
        type: AutomationActionType.updateTask,
        parameters: {'action': 'checkParentCompletion'},
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static const overdueNotification = AutomationRuleEntity(
    id: 'overdue_notification',
    userId: 'system',
    name: 'Send notification for overdue tasks',
    description: 'Send a notification when a task becomes overdue',
    trigger: AutomationTrigger(type: AutomationTriggerType.taskOverdue),
    actions: [
      AutomationAction(
        type: AutomationActionType.sendNotification,
        parameters: {
          'title': 'Task Overdue',
          'message': 'You have an overdue task',
        },
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static const dueDateReminder = AutomationRuleEntity(
    id: 'due_date_reminder',
    userId: 'system',
    name: 'Remind me 1 day before due date',
    description: 'Send a reminder notification 1 day before task is due',
    trigger: AutomationTrigger(
      type: AutomationTriggerType.dueDateApproaching,
      conditions: {'hours': 24},
    ),
    actions: [
      AutomationAction(
        type: AutomationActionType.sendNotification,
        parameters: {
          'title': 'Task Due Soon',
          'message': 'Task is due tomorrow',
        },
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static const autoAssignHighPriority = AutomationRuleEntity(
    id: 'auto_assign_high_priority',
    userId: 'system',
    name: 'Auto-assign high priority tasks',
    description: 'Automatically assign high priority tasks to team lead',
    trigger: AutomationTrigger(
      type: AutomationTriggerType.taskCreated,
      conditions: {'priority': 5},
    ),
    actions: [
      AutomationAction(
        type: AutomationActionType.assignToUser,
        parameters: {'userId': 'team_lead'},
      ),
      AutomationAction(
        type: AutomationActionType.sendNotification,
        parameters: {
          'title': 'High Priority Task',
          'message': 'Assigned to team lead',
        },
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static const weeklyReviewReminder = AutomationRuleEntity(
    id: 'weekly_review_reminder',
    userId: 'system',
    name: 'Weekly review reminder',
    description: 'Create a weekly review task every Sunday',
    trigger: AutomationTrigger(
      type: AutomationTriggerType.timeBased,
      conditions: {
        'schedule': 'weekly',
        'dayOfWeek': 0, // Sunday
        'hour': 18, // 6 PM
      },
    ),
    actions: [
      AutomationAction(
        type: AutomationActionType.createTask,
        parameters: {
          'title': 'Weekly Review',
          'description': 'Review your week and plan for the next one',
          'priority': 4,
          'tags': ['review', 'weekly'],
        },
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static const urgentTaskAlert = AutomationRuleEntity(
    id: 'urgent_task_alert',
    userId: 'system',
    name: 'Alert on urgent tag',
    description: 'Send notification when "urgent" tag is added to a task',
    trigger: AutomationTrigger(
      type: AutomationTriggerType.tagAdded,
      conditions: {'tag': 'urgent'},
    ),
    actions: [
      AutomationAction(
        type: AutomationActionType.setPriority,
        parameters: {'priority': 5},
      ),
      AutomationAction(
        type: AutomationActionType.sendNotification,
        parameters: {
          'title': 'Urgent Task',
          'message': 'Task marked as urgent',
        },
      ),
    ],
    isEnabled: true,
    createdAt: null,
    updatedAt: null,
  );

  static List<AutomationRuleEntity> get allPredefinedAutomations => [
        autoCompleteSubtasks,
        overdueNotification,
        dueDateReminder,
        autoAssignHighPriority,
        weeklyReviewReminder,
        urgentTaskAlert,
      ];
}
