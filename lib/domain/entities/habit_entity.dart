import 'package:equatable/equatable.dart';

/// Habit entity representing a habit to track
class HabitEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String color;
  final HabitCategory category;
  final HabitFrequency frequency;
  final int targetCount; // Target times per period
  final List<int> targetDaysOfWeek; // For weekly frequency (1-7)
  final DateTime? targetTime; // Preferred time to complete
  final List<HabitCheckIn> checkIns;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckInDate;
  final bool isArchived;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? settings;

  const HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color = '#4CAF50',
    required this.category,
    required this.frequency,
    this.targetCount = 1,
    this.targetDaysOfWeek = const [],
    this.targetTime,
    this.checkIns = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCheckInDate,
    this.isArchived = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.settings,
  });

  /// Check if habit was completed today
  bool get isCompletedToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
        lastCheckInDate!.month == now.month &&
        lastCheckInDate!.day == now.day;
  }

  /// Get completion rate (percentage)
  double getCompletionRate(DateTime startDate, DateTime endDate) {
    final daysInRange = endDate.difference(startDate).inDays + 1;
    final completedDays = checkIns
        .where((checkIn) =>
            checkIn.checkInDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            checkIn.checkInDate.isBefore(endDate.add(const Duration(days: 1))))
        .length;
    return (completedDays / daysInRange) * 100;
  }

  /// Copy with method
  HabitEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    HabitCategory? category,
    HabitFrequency? frequency,
    int? targetCount,
    List<int>? targetDaysOfWeek,
    DateTime? targetTime,
    List<HabitCheckIn>? checkIns,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckInDate,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      targetDaysOfWeek: targetDaysOfWeek ?? this.targetDaysOfWeek,
      targetTime: targetTime ?? this.targetTime,
      checkIns: checkIns ?? this.checkIns,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        icon,
        color,
        category,
        frequency,
        targetCount,
        targetDaysOfWeek,
        targetTime,
        checkIns,
        currentStreak,
        longestStreak,
        lastCheckInDate,
        isArchived,
        isDeleted,
        createdAt,
        updatedAt,
        settings,
      ];
}

/// Habit check-in
class HabitCheckIn extends Equatable {
  final String id;
  final DateTime checkInDate;
  final String? note;
  final int count; // How many times completed (for habits with targetCount > 1)

  const HabitCheckIn({
    required this.id,
    required this.checkInDate,
    this.note,
    this.count = 1,
  });

  @override
  List<Object?> get props => [id, checkInDate, note, count];
}

/// Habit categories
enum HabitCategory {
  healthFitness,
  personalDevelopment,
  workProductivity,
  financeSavings,
  socialRelationships,
  mindfulnessMentalHealth,
  hobbiesInterests,
  custom,
}

/// Habit frequency
enum HabitFrequency {
  daily,
  weekly,
  monthly,
  custom,
}
