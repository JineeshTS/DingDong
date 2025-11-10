import 'package:equatable/equatable.dart';

/// Reminder entity representing a reminder in the domain layer
class ReminderEntity extends Equatable {
  final String id;
  final String userId;
  final String taskId;
  final ReminderType type;
  final DateTime? triggerTime; // For time-based reminders
  final LocationTrigger? locationTrigger; // For location-based reminders
  final ContextTrigger? contextTrigger; // For context-based reminders
  final bool isPersistent; // Keeps notifying until acknowledged
  final Duration? repeatInterval; // For persistent reminders (e.g., every 5 minutes)
  final bool isEscalating; // Increase intensity over time
  final String? customSound;
  final bool isEnabled;
  final DateTime? lastTriggeredAt;
  final int triggerCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const ReminderEntity({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.type,
    this.triggerTime,
    this.locationTrigger,
    this.contextTrigger,
    this.isPersistent = false,
    this.repeatInterval,
    this.isEscalating = false,
    this.customSound,
    this.isEnabled = true,
    this.lastTriggeredAt,
    this.triggerCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Check if reminder is overdue (for time-based reminders)
  bool get isOverdue {
    if (type != ReminderType.timeBased || triggerTime == null) return false;
    return triggerTime!.isBefore(DateTime.now());
  }

  /// Check if reminder should trigger
  bool get shouldTrigger {
    if (!isEnabled || isDeleted) return false;

    switch (type) {
      case ReminderType.timeBased:
        return triggerTime != null &&
            DateTime.now().isAfter(triggerTime!) &&
            (lastTriggeredAt == null ||
                (isPersistent &&
                    repeatInterval != null &&
                    DateTime.now()
                        .isAfter(lastTriggeredAt!.add(repeatInterval!))));

      case ReminderType.locationBased:
        // Location checking will be done by geofencing service
        return false;

      case ReminderType.contextBased:
        // Context checking will be done by context service
        return false;
    }
  }

  /// Copy with method
  ReminderEntity copyWith({
    String? id,
    String? userId,
    String? taskId,
    ReminderType? type,
    DateTime? triggerTime,
    LocationTrigger? locationTrigger,
    ContextTrigger? contextTrigger,
    bool? isPersistent,
    Duration? repeatInterval,
    bool? isEscalating,
    String? customSound,
    bool? isEnabled,
    DateTime? lastTriggeredAt,
    int? triggerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      triggerTime: triggerTime ?? this.triggerTime,
      locationTrigger: locationTrigger ?? this.locationTrigger,
      contextTrigger: contextTrigger ?? this.contextTrigger,
      isPersistent: isPersistent ?? this.isPersistent,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      isEscalating: isEscalating ?? this.isEscalating,
      customSound: customSound ?? this.customSound,
      isEnabled: isEnabled ?? this.isEnabled,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      triggerCount: triggerCount ?? this.triggerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        taskId,
        type,
        triggerTime,
        locationTrigger,
        contextTrigger,
        isPersistent,
        repeatInterval,
        isEscalating,
        customSound,
        isEnabled,
        lastTriggeredAt,
        triggerCount,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

/// Reminder types
enum ReminderType {
  timeBased, // Reminder at specific time
  locationBased, // Reminder at/when leaving location
  contextBased, // Reminder based on context (app open, WiFi, etc.)
}

/// Location trigger for location-based reminders
class LocationTrigger extends Equatable {
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusMeters; // Geofence radius
  final LocationTriggerType triggerType;

  const LocationTrigger({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100.0,
    required this.triggerType,
  });

  @override
  List<Object> get props => [
        locationName,
        latitude,
        longitude,
        radiusMeters,
        triggerType,
      ];
}

/// Location trigger types
enum LocationTriggerType {
  onArrival, // Trigger when arriving at location
  onDeparture, // Trigger when leaving location
}

/// Context trigger for context-based reminders
class ContextTrigger extends Equatable {
  final ContextTriggerType type;
  final String? data; // Additional data (e.g., app package name, WiFi SSID, etc.)

  const ContextTrigger({
    required this.type,
    this.data,
  });

  @override
  List<Object?> get props => [type, data];
}

/// Context trigger types
enum ContextTriggerType {
  appOpen, // When specific app is opened
  wifiConnected, // When connected to specific WiFi
  bluetoothConnected, // When connected to specific Bluetooth device
  timeOfDay, // At specific time of day (smart reminder)
}
