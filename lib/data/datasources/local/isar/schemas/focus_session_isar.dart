import 'package:isar/isar.dart';

part 'focus_session_isar.g.dart';

/// Isar collection for FocusSession entity (local storage)
@collection
class FocusSessionIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase focus session ID
  @Index(unique: true)
  late String sessionId;

  /// User ID
  @Index()
  late String userId;

  /// Task ID (optional)
  @Index()
  String? taskId;

  /// List ID (optional)
  @Index()
  String? listId;

  /// Session type
  @Enumerated(EnumType.name)
  late FocusSessionTypeIsar type;

  /// Session status
  @Index()
  @Enumerated(EnumType.name)
  late FocusSessionStatusIsar status;

  /// Planned duration (in minutes)
  late int plannedDuration;

  /// Actual duration (in minutes)
  int? actualDuration;

  /// Start time
  @Index()
  late DateTime startTime;

  /// End time
  DateTime? endTime;

  /// Paused time
  DateTime? pausedAt;

  /// Resumed time
  DateTime? resumedAt;

  /// Interruptions (stored as JSON string list)
  String? interruptionsJson;

  /// Focus quality score (0-100)
  double? focusQualityScore;

  /// Notes
  String? notes;

  /// Creation timestamp
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}

/// Focus session type enum for Isar
enum FocusSessionTypeIsar {
  pomodoro,
  deepWork,
  shortBreak,
  longBreak,
  custom,
}

/// Focus session status enum for Isar
enum FocusSessionStatusIsar {
  active,
  paused,
  completed,
  cancelled,
}
