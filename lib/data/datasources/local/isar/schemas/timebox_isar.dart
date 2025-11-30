import 'package:isar/isar.dart';

part 'timebox_isar.g.dart';

/// Isar collection for Timebox entity (local storage)
@collection
class TimeboxIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase timebox ID
  @Index(unique: true)
  late String timeboxId;

  /// User ID (owner)
  @Index()
  late String userId;

  /// Date (normalized to midnight)
  @Index()
  late DateTime date;

  /// Slots (embedded list)
  List<TimeboxSlotIsar>? slots;

  /// Conflicts (embedded list)
  List<TimeConflictIsar>? conflicts;

  /// Summary (embedded object)
  TimeboxSummaryIsar? summary;

  /// Settings (embedded object)
  TimeboxSettingsIsar? settings;

  /// Creation timestamp
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}

/// Embedded timebox slot
@embedded
class TimeboxSlotIsar {
  /// Slot ID
  late String id;

  /// Task ID
  late String taskId;

  /// Task title
  late String taskTitle;

  /// Task description
  String? taskDescription;

  /// Start time
  late DateTime startTime;

  /// End time
  late DateTime endTime;

  /// Category (personal, professional, health, etc.)
  late String category;

  /// Priority (none, low, medium, high, critical)
  String priority = 'none';

  /// Status (scheduled, in_progress, completed, skipped, cancelled)
  String status = 'scheduled';

  /// List ID
  String? listId;

  /// List name
  String? listName;

  /// List color
  String? listColor;

  /// Tags
  List<String>? tags;

  /// Is recurring task
  bool isRecurring = false;

  /// Is all-day event
  bool isAllDay = false;

  /// Notes
  String? notes;
}

/// Embedded time conflict
@embedded
class TimeConflictIsar {
  /// Conflict ID
  late String id;

  /// Conflict type (partialOverlap, completeOverlap, doubleBooked, backToBack, exceedsWorkHours)
  late String type;

  /// Severity (info, warning, error)
  late String severity;

  /// First slot ID
  late String slot1Id;

  /// Second slot ID
  String? slot2Id;

  /// Conflict message
  late String message;

  /// Suggestion to resolve
  String? suggestion;

  /// Detected at timestamp
  late DateTime detectedAt;
}

/// Embedded timebox summary
@embedded
class TimeboxSummaryIsar {
  /// Total tasks
  int totalTasks = 0;

  /// Completed tasks
  int completedTasks = 0;

  /// Pending tasks
  int pendingTasks = 0;

  /// Skipped tasks
  int skippedTasks = 0;

  /// Total scheduled hours
  double totalScheduledHours = 0.0;

  /// Personal tasks count
  int personalTasks = 0;

  /// Professional tasks count
  int professionalTasks = 0;

  /// Health tasks count
  int healthTasks = 0;

  /// Learning tasks count
  int learningTasks = 0;

  /// Errands count
  int errandsTasks = 0;

  /// Social tasks count
  int socialTasks = 0;

  /// Other tasks count
  int otherTasks = 0;

  /// High priority count
  int highPriorityTasks = 0;

  /// Critical priority count
  int criticalPriorityTasks = 0;

  /// Conflict count
  int conflictCount = 0;

  /// Completion rate (0.0 - 1.0)
  double completionRate = 0.0;

  /// Utilization rate (scheduled hours / available hours)
  double utilizationRate = 0.0;
}

/// Embedded timebox settings
@embedded
class TimeboxSettingsIsar {
  /// Day start hour (0-23)
  int dayStartHour = 8;

  /// Day end hour (0-23)
  int dayEndHour = 20;

  /// Work start hour (0-23)
  int workStartHour = 9;

  /// Work end hour (0-23)
  int workEndHour = 17;

  /// Peak hours start (0-23)
  int peakHoursStart = 10;

  /// Peak hours end (0-23)
  int peakHoursEnd = 12;

  /// Buffer between tasks (minutes)
  int bufferMinutes = 15;

  /// Allow conflicts
  bool allowConflicts = false;

  /// Auto-detect conflicts
  bool autoDetectConflicts = true;

  /// Show skipped tasks
  bool showSkippedTasks = false;

  /// Group by category
  bool groupByCategory = true;

  /// Highlight priority tasks
  bool highlightPriorityTasks = true;

  /// Default category
  String defaultCategory = 'personal';

  /// Theme color
  String themeColor = '#2196F3';
}
