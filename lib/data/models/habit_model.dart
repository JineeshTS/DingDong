import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/habit_entity.dart';

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

/// Habit data model for Firestore serialization
@freezed
class HabitModel with _$HabitModel {
  const factory HabitModel({
    required String id,
    required String userId,
    required String name,
    String? description,
    String? icon,
    @Default('#4CAF50') String color,
    required String category,
    required String frequency,
    @Default(1) int targetCount,
    @Default([]) List<int> targetDaysOfWeek,
    DateTime? targetTime,
    @Default([]) List<HabitCheckInModel> checkIns,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    DateTime? lastCheckInDate,
    @Default(false) bool isArchived,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? settings,
  }) = _HabitModel;

  const HabitModel._();

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);

  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      icon: icon,
      color: color,
      category: _categoryFromString(category),
      frequency: _frequencyFromString(frequency),
      targetCount: targetCount,
      targetDaysOfWeek: targetDaysOfWeek,
      targetTime: targetTime,
      checkIns: checkIns.map((c) => c.toEntity()).toList(),
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCheckInDate: lastCheckInDate,
      isArchived: isArchived,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      settings: settings,
    );
  }

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      color: entity.color,
      category: _categoryToString(entity.category),
      frequency: _frequencyToString(entity.frequency),
      targetCount: entity.targetCount,
      targetDaysOfWeek: entity.targetDaysOfWeek,
      targetTime: entity.targetTime,
      checkIns: entity.checkIns.map((c) => HabitCheckInModel.fromEntity(c)).toList(),
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      lastCheckInDate: entity.lastCheckInDate,
      isArchived: entity.isArchived,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      settings: entity.settings,
    );
  }

  static String _categoryToString(HabitCategory category) {
    return category.toString().split('.').last;
  }

  static HabitCategory _categoryFromString(String category) {
    switch (category) {
      case 'healthFitness':
        return HabitCategory.healthFitness;
      case 'personalDevelopment':
        return HabitCategory.personalDevelopment;
      case 'workProductivity':
        return HabitCategory.workProductivity;
      case 'financeSavings':
        return HabitCategory.financeSavings;
      case 'socialRelationships':
        return HabitCategory.socialRelationships;
      case 'mindfulnessMentalHealth':
        return HabitCategory.mindfulnessMentalHealth;
      case 'hobbiesInterests':
        return HabitCategory.hobbiesInterests;
      case 'custom':
        return HabitCategory.custom;
      default:
        return HabitCategory.custom;
    }
  }

  static String _frequencyToString(HabitFrequency frequency) {
    return frequency.toString().split('.').last;
  }

  static HabitFrequency _frequencyFromString(String frequency) {
    switch (frequency) {
      case 'daily':
        return HabitFrequency.daily;
      case 'weekly':
        return HabitFrequency.weekly;
      case 'monthly':
        return HabitFrequency.monthly;
      case 'custom':
        return HabitFrequency.custom;
      default:
        return HabitFrequency.daily;
    }
  }
}

/// Habit check-in model
@freezed
class HabitCheckInModel with _$HabitCheckInModel {
  const factory HabitCheckInModel({
    required String id,
    required DateTime checkInDate,
    String? note,
    @Default(1) int count,
  }) = _HabitCheckInModel;

  const HabitCheckInModel._();

  factory HabitCheckInModel.fromJson(Map<String, dynamic> json) =>
      _$HabitCheckInModelFromJson(json);

  HabitCheckIn toEntity() {
    return HabitCheckIn(
      id: id,
      checkInDate: checkInDate,
      note: note,
      count: count,
    );
  }

  factory HabitCheckInModel.fromEntity(HabitCheckIn entity) {
    return HabitCheckInModel(
      id: entity.id,
      checkInDate: entity.checkInDate,
      note: entity.note,
      count: entity.count,
    );
  }
}
