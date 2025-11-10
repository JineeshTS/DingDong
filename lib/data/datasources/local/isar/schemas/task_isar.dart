import 'package:isar/isar.dart';

part 'task_isar.g.dart';

/// Isar collection for Task entity (local storage)
@collection
class TaskIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase task ID (indexed for quick lookup)
  @Index(unique: true)
  late String taskId;

  /// User ID (owner of task)
  @Index()
  late String userId;

  /// List ID (task belongs to)
  @Index()
  String? listId;

  /// Workspace ID
  @Index()
  String? workspaceId;

  /// Parent task ID (for subtasks)
  @Index()
  String? parentTaskId;

  /// Task title
  late String title;

  /// Task description (rich text as HTML)
  String? description;

  /// Task status
  @Index()
  @Enumerated(EnumType.name)
  late TaskStatusIsar status;

  /// Task priority
  @Index()
  @Enumerated(EnumType.name)
  late TaskPriorityIsar priority;

  /// Due date
  @Index()
  DateTime? dueDate;

  /// Start date
  DateTime? startDate;

  /// Completed date
  DateTime? completedAt;

  /// Duration estimate (in minutes)
  int? durationEstimate;

  /// Actual duration (in minutes)
  int? actualDuration;

  /// Tags (list of tag IDs)
  List<String> tags = [];

  /// Assigned user IDs
  List<String> assignedToIds = [];

  /// Attachment IDs
  List<String> attachmentIds = [];

  /// Location name
  String? locationName;

  /// Location latitude
  double? locationLat;

  /// Location longitude
  double? locationLng;

  /// Energy level required (low, medium, high)
  @Enumerated(EnumType.name)
  TaskEnergyLevelIsar? energyLevel;

  /// Is recurring task
  bool isRecurring = false;

  /// Recurring parent ID (for generated instances)
  String? recurringParentId;

  /// Recurrence rule (stored as JSON string)
  String? recurrenceRuleJson;

  /// Dependencies (stored as JSON string list)
  String? dependenciesJson;

  /// Custom fields (stored as JSON string)
  String? customFieldsJson;

  /// Sort order
  int sortOrder = 0;

  /// Is favorite
  bool isFavorite = false;

  /// Is archived
  bool isArchived = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Notes
  String? notes;

  /// Creation timestamp
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Deleted timestamp
  DateTime? deletedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;

  // Computed properties helpers (stored for quick access)

  /// Is overdue flag
  bool isOverdue = false;

  /// Is due today flag
  bool isDueToday = false;

  /// Is due this week flag
  bool isDueThisWeek = false;

  /// Subtask count
  int subtaskCount = 0;

  /// Completed subtask count
  int completedSubtaskCount = 0;

  /// Comment count
  int commentCount = 0;

  /// Attachment count
  int attachmentCount = 0;
}

/// Task status enum for Isar
enum TaskStatusIsar {
  active,
  completed,
  cancelled,
}

/// Task priority enum for Isar
enum TaskPriorityIsar {
  none,
  low,
  medium,
  high,
  urgent,
}

/// Task energy level enum for Isar
enum TaskEnergyLevelIsar {
  low,
  medium,
  high,
}

/// Embedded object for task dependencies
@embedded
class TaskDependencyIsar {
  /// Dependent task ID
  late String taskId;

  /// Dependency type
  @Enumerated(EnumType.name)
  late DependencyTypeIsar type;
}

/// Dependency type enum
enum DependencyTypeIsar {
  finishToStart,
  startToStart,
  finishToFinish,
  startToFinish,
}
