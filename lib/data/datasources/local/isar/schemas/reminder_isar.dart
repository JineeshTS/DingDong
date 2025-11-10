import 'package:isar/isar.dart';

part 'reminder_isar.g.dart';

/// Isar collection for Reminder entity (local storage)
@collection
class ReminderIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase reminder ID
  @Index(unique: true)
  late String reminderId;

  /// User ID
  @Index()
  late String userId;

  /// Task ID
  @Index()
  String? taskId;

  /// Reminder type
  @Index()
  @Enumerated(EnumType.name)
  late ReminderTypeIsar type;

  /// Reminder time
  @Index()
  DateTime? reminderTime;

  /// Is enabled
  @Index()
  bool isEnabled = true;

  /// Is triggered
  @Index()
  bool isTriggered = false;

  /// Triggered timestamp
  DateTime? triggeredAt;

  /// Custom message
  String? message;

  /// Location trigger (stored as JSON string)
  String? locationTriggerJson;

  /// Context trigger (stored as JSON string)
  String? contextTriggerJson;

  /// Repeat interval (in minutes, 0 = no repeat)
  int repeatInterval = 0;

  /// Is deleted (soft delete)
  bool isDeleted = false;

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
}

/// Reminder type enum for Isar
enum ReminderTypeIsar {
  time,
  location,
  context,
}
