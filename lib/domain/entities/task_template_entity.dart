import 'package:equatable/equatable.dart';
import 'task_entity.dart';

/// Task Template entity representing a reusable task template
class TaskTemplateEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final TaskTemplateCategory category;
  final bool isPublic; // For community templates
  final int usageCount; // Track how many times it's been used
  final DateTime createdAt;
  final DateTime updatedAt;

  // Template fields (nullable - user can customize when creating from template)
  final String? templateTitle;
  final String? templateDescription;
  final int? templatePriority;
  final List<String>? templateTags;
  final String? templateCategory;
  final List<TaskTemplateSubtask>? templateSubtasks;
  final int? estimatedDurationMinutes;

  // Template variables (e.g., {{project_name}}, {{deadline}})
  final Map<String, String>? variables;

  const TaskTemplateEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    required this.category,
    this.isPublic = false,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.templateTitle,
    this.templateDescription,
    this.templatePriority,
    this.templateTags,
    this.templateCategory,
    this.templateSubtasks,
    this.estimatedDurationMinutes,
    this.variables,
  });

  /// Create a task from this template
  TaskEntity toTask({
    required String taskId,
    required String listId,
    Map<String, String>? variableValues,
  }) {
    String applyVariables(String? text) {
      if (text == null || variableValues == null) return text ?? '';
      var result = text;
      variableValues.forEach((key, value) {
        result = result.replaceAll('{{$key}}', value);
      });
      return result;
    }

    return TaskEntity(
      id: taskId,
      userId: userId,
      listId: listId,
      title: applyVariables(templateTitle),
      description: templateDescription != null
          ? applyVariables(templateDescription)
          : null,
      priority: templatePriority ?? 3,
      tags: templateTags ?? [],
      category: templateCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  TaskTemplateEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    TaskTemplateCategory? category,
    bool? isPublic,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? templateTitle,
    String? templateDescription,
    int? templatePriority,
    List<String>? templateTags,
    String? templateCategory,
    List<TaskTemplateSubtask>? templateSubtasks,
    int? estimatedDurationMinutes,
    Map<String, String>? variables,
  }) {
    return TaskTemplateEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      templateTitle: templateTitle ?? this.templateTitle,
      templateDescription: templateDescription ?? this.templateDescription,
      templatePriority: templatePriority ?? this.templatePriority,
      templateTags: templateTags ?? this.templateTags,
      templateCategory: templateCategory ?? this.templateCategory,
      templateSubtasks: templateSubtasks ?? this.templateSubtasks,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      variables: variables ?? this.variables,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        icon,
        category,
        isPublic,
        usageCount,
        createdAt,
        updatedAt,
        templateTitle,
        templateDescription,
        templatePriority,
        templateTags,
        templateCategory,
        templateSubtasks,
        estimatedDurationMinutes,
        variables,
      ];
}

/// Task template categories
enum TaskTemplateCategory {
  personal, // Personal tasks
  work, // Work-related
  meeting, // Meeting templates
  project, // Project templates
  routine, // Daily routines
  goal, // Goal-based templates
  shopping, // Shopping lists
  travel, // Travel planning
  health, // Health & fitness
  learning, // Learning & education
  custom, // User-created
}

/// Template subtask
class TaskTemplateSubtask extends Equatable {
  final String title;
  final int order;

  const TaskTemplateSubtask({
    required this.title,
    required this.order,
  });

  @override
  List<Object?> get props => [title, order];
}

/// Predefined templates
class PredefinedTemplates {
  static const meetingPrep = TaskTemplateEntity(
    id: 'template_meeting_prep',
    userId: 'system',
    name: 'Meeting Preparation',
    description: 'Prepare for an upcoming meeting',
    icon: '📅',
    category: TaskTemplateCategory.meeting,
    isPublic: true,
    createdAt: null,
    updatedAt: null,
    templateTitle: 'Prepare for {{meeting_name}}',
    templateDescription: 'Preparation tasks for the meeting',
    templatePriority: 4,
    templateTags: ['meeting', 'preparation'],
    templateSubtasks: [
      TaskTemplateSubtask(title: 'Review agenda', order: 0),
      TaskTemplateSubtask(title: 'Prepare talking points', order: 1),
      TaskTemplateSubtask(title: 'Gather materials', order: 2),
      TaskTemplateSubtask(title: 'Send calendar invite', order: 3),
    ],
    estimatedDurationMinutes: 30,
    variables: {'meeting_name': 'Weekly Sync'},
  );

  static const projectKickoff = TaskTemplateEntity(
    id: 'template_project_kickoff',
    userId: 'system',
    name: 'Project Kickoff',
    description: 'Start a new project',
    icon: '🚀',
    category: TaskTemplateCategory.project,
    isPublic: true,
    createdAt: null,
    updatedAt: null,
    templateTitle: 'Kickoff: {{project_name}}',
    templateDescription: 'Initial setup for new project',
    templatePriority: 5,
    templateTags: ['project', 'kickoff'],
    templateSubtasks: [
      TaskTemplateSubtask(title: 'Define project goals', order: 0),
      TaskTemplateSubtask(title: 'Create project plan', order: 1),
      TaskTemplateSubtask(title: 'Assign team roles', order: 2),
      TaskTemplateSubtask(title: 'Set up communication channels', order: 3),
      TaskTemplateSubtask(title: 'Schedule kickoff meeting', order: 4),
    ],
    estimatedDurationMinutes: 120,
    variables: {'project_name': 'New Project'},
  );

  static const weeklyReview = TaskTemplateEntity(
    id: 'template_weekly_review',
    userId: 'system',
    name: 'Weekly Review',
    description: 'Review your week',
    icon: '📊',
    category: TaskTemplateCategory.routine,
    isPublic: true,
    createdAt: null,
    updatedAt: null,
    templateTitle: 'Weekly Review - Week of {{week_date}}',
    templateDescription: 'Reflect on the past week and plan ahead',
    templatePriority: 3,
    templateTags: ['review', 'weekly', 'planning'],
    templateSubtasks: [
      TaskTemplateSubtask(title: 'Review completed tasks', order: 0),
      TaskTemplateSubtask(title: 'Review goals progress', order: 1),
      TaskTemplateSubtask(title: 'Identify wins and challenges', order: 2),
      TaskTemplateSubtask(title: 'Plan priorities for next week', order: 3),
    ],
    estimatedDurationMinutes: 45,
    variables: {'week_date': 'Nov 13'},
  );

  static const groceryShopping = TaskTemplateEntity(
    id: 'template_grocery_shopping',
    userId: 'system',
    name: 'Grocery Shopping',
    description: 'Weekly grocery shopping list',
    icon: '🛒',
    category: TaskTemplateCategory.shopping,
    isPublic: true,
    createdAt: null,
    updatedAt: null,
    templateTitle: 'Grocery Shopping - {{week_date}}',
    templateDescription: 'Weekly grocery shopping',
    templatePriority: 3,
    templateTags: ['shopping', 'groceries'],
    templateSubtasks: [
      TaskTemplateSubtask(title: 'Check pantry/fridge', order: 0),
      TaskTemplateSubtask(title: 'Make shopping list', order: 1),
      TaskTemplateSubtask(title: 'Check weekly ads', order: 2),
      TaskTemplateSubtask(title: 'Go shopping', order: 3),
    ],
    estimatedDurationMinutes: 60,
    variables: {'week_date': 'This Week'},
  );

  static const travelPlanning = TaskTemplateEntity(
    id: 'template_travel_planning',
    userId: 'system',
    name: 'Travel Planning',
    description: 'Plan a trip',
    icon: '✈️',
    category: TaskTemplateCategory.travel,
    isPublic: true,
    createdAt: null,
    updatedAt: null,
    templateTitle: 'Plan Trip to {{destination}}',
    templateDescription: 'Planning checklist for upcoming trip',
    templatePriority: 4,
    templateTags: ['travel', 'planning'],
    templateSubtasks: [
      TaskTemplateSubtask(title: 'Book flights', order: 0),
      TaskTemplateSubtask(title: 'Book accommodation', order: 1),
      TaskTemplateSubtask(title: 'Plan activities', order: 2),
      TaskTemplateSubtask(title: 'Check passport/visas', order: 3),
      TaskTemplateSubtask(title: 'Pack luggage', order: 4),
    ],
    estimatedDurationMinutes: 180,
    variables: {'destination': 'City Name'},
  );

  static List<TaskTemplateEntity> get allPredefinedTemplates => [
        meetingPrep,
        projectKickoff,
        weeklyReview,
        groceryShopping,
        travelPlanning,
      ];
}
