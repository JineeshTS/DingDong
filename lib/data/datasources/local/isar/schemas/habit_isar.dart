import 'package:isar/isar.dart';

part 'habit_isar.g.dart';

/// Isar collection for Habit entity (local storage)
@collection
class HabitIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase habit ID
  @Index(unique: true)
  late String habitId;

  /// User ID
  @Index()
  late String userId;

  /// Habit name
  late String name;

  /// Habit description
  String? description;

  /// Habit category
  @Index()
  String? category;

  /// Habit icon
  String? icon;

  /// Habit color (hex code)
  String color = '#10B981';

  /// Frequency type (daily, weekly, monthly, custom)
  @Enumerated(EnumType.name)
  late HabitFrequencyTypeIsar frequencyType;

  /// Frequency data (stored as JSON string)
  String? frequencyJson;

  /// Target count per period
  int targetCount = 1;

  /// Unit name (e.g., "glasses of water", "pages read")
  String? unit;

  /// Current streak (consecutive days)
  @Index()
  int currentStreak = 0;

  /// Best streak (all time)
  int bestStreak = 0;

  /// Check-ins (stored as JSON string list)
  String? checkInsJson;

  /// Last check-in date
  DateTime? lastCheckIn;

  /// Is archived
  @Index()
  bool isArchived = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Creation timestamp
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Archived timestamp
  DateTime? archivedAt;

  /// Deleted timestamp
  DateTime? deletedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}

/// Habit frequency type enum for Isar
enum HabitFrequencyTypeIsar {
  daily,
  weekly,
  monthly,
  custom,
}
