import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/reminder_entity.dart';

part 'reminder_model.freezed.dart';
part 'reminder_model.g.dart';

/// Reminder data model for Firestore serialization
@freezed
class ReminderModel with _$ReminderModel {
  const factory ReminderModel({
    required String id,
    required String userId,
    required String taskId,
    required String type,
    DateTime? triggerTime,
    LocationTriggerModel? locationTrigger,
    ContextTriggerModel? contextTrigger,
    @Default(false) bool isPersistent,
    int? repeatIntervalSeconds,
    @Default(false) bool isEscalating,
    String? customSound,
    @Default(true) bool isEnabled,
    DateTime? lastTriggeredAt,
    @Default(0) int triggerCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _ReminderModel;

  const ReminderModel._();

  factory ReminderModel.fromJson(Map<String, dynamic> json) =>
      _$ReminderModelFromJson(json);

  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      userId: userId,
      taskId: taskId,
      type: _typeFromString(type),
      triggerTime: triggerTime,
      locationTrigger: locationTrigger?.toEntity(),
      contextTrigger: contextTrigger?.toEntity(),
      isPersistent: isPersistent,
      repeatInterval: repeatIntervalSeconds != null
          ? Duration(seconds: repeatIntervalSeconds!)
          : null,
      isEscalating: isEscalating,
      customSound: customSound,
      isEnabled: isEnabled,
      lastTriggeredAt: lastTriggeredAt,
      triggerCount: triggerCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      userId: entity.userId,
      taskId: entity.taskId,
      type: _typeToString(entity.type),
      triggerTime: entity.triggerTime,
      locationTrigger: entity.locationTrigger != null
          ? LocationTriggerModel.fromEntity(entity.locationTrigger!)
          : null,
      contextTrigger: entity.contextTrigger != null
          ? ContextTriggerModel.fromEntity(entity.contextTrigger!)
          : null,
      isPersistent: entity.isPersistent,
      repeatIntervalSeconds: entity.repeatInterval?.inSeconds,
      isEscalating: entity.isEscalating,
      customSound: entity.customSound,
      isEnabled: entity.isEnabled,
      lastTriggeredAt: entity.lastTriggeredAt,
      triggerCount: entity.triggerCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
    );
  }

  static String _typeToString(ReminderType type) {
    return type.toString().split('.').last;
  }

  static ReminderType _typeFromString(String type) {
    switch (type) {
      case 'timeBased':
        return ReminderType.timeBased;
      case 'locationBased':
        return ReminderType.locationBased;
      case 'contextBased':
        return ReminderType.contextBased;
      default:
        return ReminderType.timeBased;
    }
  }
}

/// Location trigger model
@freezed
class LocationTriggerModel with _$LocationTriggerModel {
  const factory LocationTriggerModel({
    required String locationName,
    required double latitude,
    required double longitude,
    @Default(100.0) double radiusMeters,
    required String triggerType,
  }) = _LocationTriggerModel;

  const LocationTriggerModel._();

  factory LocationTriggerModel.fromJson(Map<String, dynamic> json) =>
      _$LocationTriggerModelFromJson(json);

  LocationTrigger toEntity() {
    return LocationTrigger(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      triggerType: triggerType == 'onArrival'
          ? LocationTriggerType.onArrival
          : LocationTriggerType.onDeparture,
    );
  }

  factory LocationTriggerModel.fromEntity(LocationTrigger entity) {
    return LocationTriggerModel(
      locationName: entity.locationName,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusMeters: entity.radiusMeters,
      triggerType: entity.triggerType == LocationTriggerType.onArrival
          ? 'onArrival'
          : 'onDeparture',
    );
  }
}

/// Context trigger model
@freezed
class ContextTriggerModel with _$ContextTriggerModel {
  const factory ContextTriggerModel({
    required String type,
    String? data,
  }) = _ContextTriggerModel;

  const ContextTriggerModel._();

  factory ContextTriggerModel.fromJson(Map<String, dynamic> json) =>
      _$ContextTriggerModelFromJson(json);

  ContextTrigger toEntity() {
    return ContextTrigger(
      type: _typeFromString(type),
      data: data,
    );
  }

  factory ContextTriggerModel.fromEntity(ContextTrigger entity) {
    return ContextTriggerModel(
      type: _typeToString(entity.type),
      data: entity.data,
    );
  }

  static String _typeToString(ContextTriggerType type) {
    return type.toString().split('.').last;
  }

  static ContextTriggerType _typeFromString(String type) {
    switch (type) {
      case 'appOpen':
        return ContextTriggerType.appOpen;
      case 'wifiConnected':
        return ContextTriggerType.wifiConnected;
      case 'bluetoothConnected':
        return ContextTriggerType.bluetoothConnected;
      case 'timeOfDay':
        return ContextTriggerType.timeOfDay;
      default:
        return ContextTriggerType.appOpen;
    }
  }
}
