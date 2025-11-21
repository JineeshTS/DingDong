# Timebox Providers

State management for the Timebox (Daily Agenda) feature.

## Overview

The Timebox feature provides daily task scheduling with:
- Personal/Professional/Priority task categorization
- Time conflict detection and highlighting
- Auto-scheduling of tasks into optimal time slots
- Visual daily agenda planning

## WBS Reference

- 3.7.1 Timebox Entity and Models
- 3.7.2 Timebox Repository Interface
- 3.7.3 Timebox Use Cases
- 3.7.4 Timebox Data Layer
- 3.7.5 Timebox Service
- 3.7.6 Timebox State Management (this folder)

## Quick Start

```dart
import 'package:dingdong/presentation/providers/timebox/timebox.dart';

class TimeboxScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state
    final timeboxState = ref.watch(timeboxNotifierProvider);

    // Watch derived providers
    final personalSlots = ref.watch(personalSlotsProvider);
    final professionalSlots = ref.watch(professionalSlotsProvider);
    final prioritySlots = ref.watch(prioritySlotsProvider);
    final conflicts = ref.watch(timeboxConflictsProvider);
    final summary = ref.watch(timeboxSummaryProvider);

    return timeboxState.when(
      initial: () => LoadingWidget(),
      loading: (_, message) => LoadingWidget(message: message),
      loaded: (timebox) => TimeboxView(timebox: timebox),
      error: (failure, _) => ErrorWidget(failure: failure),
    );
  }
}
```

## Available Providers

### Main Provider

- `timeboxNotifierProvider` - Main state notifier

### Derived Providers

| Provider | Returns | Description |
|----------|---------|-------------|
| `currentTimeboxProvider` | `TimeboxEntity?` | Current timebox entity |
| `timeboxSlotsProvider` | `List<TimeboxSlot>` | All slots |
| `timeboxConflictsProvider` | `List<TimeConflict>` | All conflicts |
| `timeboxSummaryProvider` | `TimeboxSummary?` | Summary statistics |
| `timeboxSettingsProvider` | `TimeboxSettings?` | User settings |

### Category Providers

| Provider | Returns | Description |
|----------|---------|-------------|
| `personalSlotsProvider` | `List<TimeboxSlot>` | Personal tasks |
| `professionalSlotsProvider` | `List<TimeboxSlot>` | Professional tasks |
| `prioritySlotsProvider` | `List<TimeboxSlot>` | High/Critical priority |
| `healthSlotsProvider` | `List<TimeboxSlot>` | Health & Fitness |
| `learningSlotsProvider` | `List<TimeboxSlot>` | Learning tasks |

### Status Providers

| Provider | Returns | Description |
|----------|---------|-------------|
| `currentSlotProvider` | `TimeboxSlot?` | Currently active slot |
| `upcomingSlotsProvider` | `List<TimeboxSlot>` | Not started yet |
| `completedSlotsProvider` | `List<TimeboxSlot>` | Completed |
| `overdueSlotsProvider` | `List<TimeboxSlot>` | Past end time |

### Statistics Providers

| Provider | Returns | Description |
|----------|---------|-------------|
| `totalTasksCountProvider` | `int` | Total tasks |
| `completedTasksCountProvider` | `int` | Completed tasks |
| `completionRateProvider` | `double` | 0.0 - 1.0 |
| `conflictCountProvider` | `int` | Number of conflicts |
| `totalScheduledHoursProvider` | `double` | Hours scheduled |
| `utilizationRateProvider` | `double` | Scheduled / Available |

## Notifier Methods

### Loading

```dart
// Load today's timebox
ref.read(timeboxNotifierProvider.notifier).loadTodayTimebox(userId);

// Load specific date
ref.read(timeboxNotifierProvider.notifier).loadTimebox(
  userId: userId,
  date: DateTime(2025, 11, 21),
);
```

### Slot Management

```dart
final notifier = ref.read(timeboxNotifierProvider.notifier);

// Add a slot
await notifier.addSlot(
  taskId: 'task-123',
  taskTitle: 'Team Meeting',
  startTime: DateTime(2025, 11, 21, 10, 0),
  endTime: DateTime(2025, 11, 21, 11, 0),
  category: TaskCategory.professional,
  priority: TaskPriority.high,
);

// Complete a slot
await notifier.completeSlot('slot-123');

// Skip a slot
await notifier.skipSlot('slot-123');

// Reschedule a slot
await notifier.rescheduleSlot(
  slotId: 'slot-123',
  newStartTime: DateTime(2025, 11, 21, 14, 0),
  newEndTime: DateTime(2025, 11, 21, 15, 0),
);

// Delete a slot
await notifier.deleteSlot('slot-123');
```

### Auto-Scheduling

```dart
// Auto-schedule tasks
await notifier.autoScheduleTasks(
  userId: userId,
  date: DateTime.now(),
  tasks: tasksToSchedule,
);

// Preview auto-schedule (without saving)
final previewSlots = notifier.previewAutoSchedule(
  tasks: tasksToSchedule,
  date: DateTime.now(),
);
```

### Conflict Detection

```dart
// Detect conflicts
await notifier.detectConflicts();

// Local conflict detection (real-time)
final conflicts = notifier.detectConflictsLocally();

// Check if adding a slot would cause conflicts
final newSlotConflicts = notifier.checkSlotConflicts(newSlot);
```

### Suggestions

```dart
// Get suggested time slot for a task
final suggestion = notifier.suggestTimeSlot(task);

// Get all available time slots
final available = notifier.getAvailableSlots();

// Infer category for a task
final category = notifier.inferCategory(task, listName: 'Work');
```

## Task Categories

| Category | Color | Icon |
|----------|-------|------|
| Personal | Green (#4CAF50) | Home |
| Professional | Blue (#2196F3) | Briefcase |
| Health | Deep Orange (#FF5722) | Fitness |
| Learning | Purple (#9C27B0) | Book |
| Errands | Orange (#FF9800) | Shopping |
| Social | Pink (#E91E63) | People |
| Other | Blue Grey (#607D8B) | Pin |

## Conflict Types

| Type | Severity | Description |
|------|----------|-------------|
| `partialOverlap` | Error | Tasks partially overlap |
| `completeOverlap` | Error | One task fully covers another |
| `doubleBooked` | Error | Same time slot twice |
| `backToBack` | Info | No buffer between tasks |
| `exceedsWorkHours` | Warning | Outside work hours |

## Best Practices

1. **Load timebox on screen init**:
   ```dart
   @override
   void initState() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(timeboxNotifierProvider.notifier).loadTodayTimebox(userId);
     });
   }
   ```

2. **Listen for side effects**:
   ```dart
   ref.listen<TimeboxState>(timeboxNotifierProvider, (prev, next) {
     next.maybeWhen(
       error: (failure, _) => showSnackBar(failure.message),
       orElse: () {},
     );
   });
   ```

3. **Use derived providers for specific data**:
   ```dart
   // Efficient - only rebuilds when conflicts change
   final conflicts = ref.watch(timeboxConflictsProvider);

   // Less efficient - rebuilds on any state change
   final conflicts = ref.watch(timeboxNotifierProvider).conflicts;
   ```

4. **Check for conflicts before adding**:
   ```dart
   final conflicts = notifier.checkSlotConflicts(newSlot);
   if (conflicts.isNotEmpty) {
     showConflictDialog(conflicts);
   }
   ```
