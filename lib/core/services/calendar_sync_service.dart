import '../../domain/entities/calendar_integration.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';
import 'google_calendar_service.dart';

/// Calendar Sync Service
///
/// Handles two-way synchronization between tasks and calendar events
class CalendarSyncService {
  final GoogleCalendarService _googleCalendarService;
  final _logger = Logger();

  CalendarSyncService({
    required GoogleCalendarService googleCalendarService,
  }) : _googleCalendarService = googleCalendarService;

  /// Perform full sync
  Future<CalendarSyncResult> performSync({
    required CalendarIntegration integration,
    required List<TaskEntity> tasks,
  }) async {
    final syncStarted = DateTime.now();
    _logger.info('Starting calendar sync for ${integration.provider.displayName}');

    try {
      final settings = integration.syncSettings ?? const CalendarSyncSettings();
      final errors = <SyncError>[];

      int eventsImported = 0;
      int eventsExported = 0;
      int eventsUpdated = 0;
      int tasksCreated = 0;
      int tasksUpdated = 0;

      // Check if token is valid
      if (integration.needsReAuth) {
        throw Exception('Calendar needs re-authentication');
      }

      // Sync based on direction
      if (settings.syncDirection == SyncDirection.twoWay ||
          settings.syncDirection == SyncDirection.oneWayFromCalendar) {
        // Import events from calendar
        final importResult = await _importEventsFromCalendar(
          integration: integration,
          settings: settings,
        );

        eventsImported = importResult['eventsImported'] as int;
        tasksCreated = importResult['tasksCreated'] as int;
        tasksUpdated = importResult['tasksUpdated'] as int;
        errors.addAll(importResult['errors'] as List<SyncError>);
      }

      if (settings.syncDirection == SyncDirection.twoWay ||
          settings.syncDirection == SyncDirection.oneWayToCalendar) {
        // Export tasks to calendar
        final exportResult = await _exportTasksToCalendar(
          integration: integration,
          tasks: tasks,
          settings: settings,
        );

        eventsExported = exportResult['eventsExported'] as int;
        eventsUpdated = exportResult['eventsUpdated'] as int;
        errors.addAll(exportResult['errors'] as List<SyncError>);
      }

      final syncCompleted = DateTime.now();

      _logger.info(
          'Calendar sync completed: +$eventsImported events, +$eventsExported exported');

      return CalendarSyncResult(
        syncStartedAt: syncStarted,
        syncCompletedAt: syncCompleted,
        provider: integration.provider,
        eventsImported: eventsImported,
        eventsExported: eventsExported,
        eventsUpdated: eventsUpdated,
        tasksCreated: tasksCreated,
        tasksUpdated: tasksUpdated,
        errors: errors,
        success: errors.isEmpty,
      );
    } catch (e, stackTrace) {
      _logger.error('Calendar sync failed', error: e, stackTrace: stackTrace);

      return CalendarSyncResult(
        syncStartedAt: syncStarted,
        syncCompletedAt: DateTime.now(),
        provider: integration.provider,
        errors: [
          SyncError(
            message: e.toString(),
            type: SyncErrorType.other,
          ),
        ],
        success: false,
      );
    }
  }

  /// Import events from calendar
  Future<Map<String, dynamic>> _importEventsFromCalendar({
    required CalendarIntegration integration,
    required CalendarSyncSettings settings,
  }) async {
    int eventsImported = 0;
    int tasksCreated = 0;
    int tasksUpdated = 0;
    final errors = <SyncError>[];

    try {
      // Fetch events from each selected calendar
      for (final calendarId in integration.selectedCalendarIds) {
        try {
          final events = await _googleCalendarService.fetchEvents(
            accessToken: integration.accessToken!,
            calendarId: calendarId,
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().add(const Duration(days: 90)),
          );

          eventsImported += events.length;

          // Convert events to tasks if needed
          if (settings.syncEventsAsTasks) {
            for (final event in events) {
              // Check if event should be synced
              if (_shouldSyncEvent(event, settings)) {
                // Here you would create or update task
                // For now, just count
                if (event.linkedTaskId == null) {
                  tasksCreated++;
                } else {
                  tasksUpdated++;
                }
              }
            }
          }
        } catch (e) {
          errors.add(SyncError(
            message: 'Failed to import from calendar $calendarId: $e',
            type: SyncErrorType.other,
          ));
        }
      }
    } catch (e) {
      errors.add(SyncError(
        message: 'Import failed: $e',
        type: SyncErrorType.other,
      ));
    }

    return {
      'eventsImported': eventsImported,
      'tasksCreated': tasksCreated,
      'tasksUpdated': tasksUpdated,
      'errors': errors,
    };
  }

  /// Export tasks to calendar
  Future<Map<String, dynamic>> _exportTasksToCalendar({
    required CalendarIntegration integration,
    required List<TaskEntity> tasks,
    required CalendarSyncSettings settings,
  }) async {
    int eventsExported = 0;
    int eventsUpdated = 0;
    final errors = <SyncError>[];

    try {
      // Filter tasks that should be synced
      final tasksToSync = tasks.where((task) {
        return _shouldSyncTask(task, settings);
      }).toList();

      // Use primary calendar or first selected
      final calendarId = integration.selectedCalendarIds.isNotEmpty
          ? integration.selectedCalendarIds.first
          : 'primary';

      for (final task in tasksToSync) {
        try {
          // Check if task already has a linked event
          if (task.calendarEventId != null) {
            // Update existing event
            await _googleCalendarService.updateEvent(
              accessToken: integration.accessToken!,
              calendarId: calendarId,
              eventId: task.calendarEventId!,
              title: task.title,
              description: task.description,
              startTime: task.scheduledStartTime ?? task.dueDate,
              endTime: task.scheduledEndTime ??
                  task.dueDate?.add(const Duration(hours: 1)),
            );
            eventsUpdated++;
          } else if (task.scheduledStartTime != null) {
            // Create new event for scheduled task
            await _googleCalendarService.createEvent(
              accessToken: integration.accessToken!,
              calendarId: calendarId,
              title: task.title,
              description: task.description,
              startTime: task.scheduledStartTime!,
              endTime: task.scheduledEndTime ??
                  task.scheduledStartTime!.add(const Duration(hours: 1)),
              isAllDay: false,
            );
            eventsExported++;
          }
        } catch (e) {
          errors.add(SyncError(
            message: 'Failed to sync task ${task.id}: $e',
            taskId: task.id,
            type: SyncErrorType.other,
          ));
        }
      }
    } catch (e) {
      errors.add(SyncError(
        message: 'Export failed: $e',
        type: SyncErrorType.other,
      ));
    }

    return {
      'eventsExported': eventsExported,
      'eventsUpdated': eventsUpdated,
      'errors': errors,
    };
  }

  /// Check if task should be synced
  bool _shouldSyncTask(TaskEntity task, CalendarSyncSettings settings) {
    // Don't sync completed tasks
    if (task.isCompleted) return false;

    // Only sync scheduled tasks if setting enabled
    if (settings.syncOnlyScheduledTasks && task.scheduledStartTime == null) {
      return false;
    }

    // Check if task is from selected lists
    if (settings.syncOnlyFromLists.isNotEmpty) {
      if (!settings.syncOnlyFromLists.contains(task.listId)) {
        return false;
      }
    }

    // Check excluded tags
    if (settings.excludeTags.isNotEmpty) {
      for (final excludedTag in settings.excludeTags) {
        if (task.tags.contains(excludedTag)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Check if event should be synced
  bool _shouldSyncEvent(CalendarEvent event, CalendarSyncSettings settings) {
    // All-day events
    if (!settings.syncAllDayTasks && event.isAllDay) {
      return false;
    }

    // Recurring events
    if (!settings.syncRecurringEvents && event.isRecurring) {
      return false;
    }

    return true;
  }

  /// Resolve conflict between task and event
  dynamic _resolveConflict({
    required TaskEntity task,
    required CalendarEvent event,
    required ConflictResolution strategy,
  }) {
    switch (strategy) {
      case ConflictResolution.calendarWins:
        // Use calendar event data
        return event;
      case ConflictResolution.appWins:
        // Use task data
        return task;
      case ConflictResolution.newerWins:
        // Compare timestamps
        final taskUpdated = task.updatedAt;
        final eventUpdated = event.updatedAt ?? event.startTime;
        return taskUpdated.isAfter(eventUpdated) ? task : event;
      case ConflictResolution.askUser:
        // Would show UI to user - for now return null
        return null;
    }
  }

  /// Convert task to calendar event
  CalendarEvent taskToCalendarEvent(
    TaskEntity task,
    String calendarId,
  ) {
    return CalendarEvent(
      id: task.id,
      calendarId: calendarId,
      title: task.title,
      description: task.description,
      startTime: task.scheduledStartTime ?? task.dueDate ?? DateTime.now(),
      endTime: task.scheduledEndTime ??
          task.scheduledStartTime?.add(const Duration(hours: 1)) ??
          task.dueDate?.add(const Duration(hours: 1)) ??
          DateTime.now().add(const Duration(hours: 1)),
      isAllDay: task.scheduledStartTime == null && task.dueDate != null,
      attendees: task.assigneeIds,
      provider: CalendarProvider.google,
      linkedTaskId: task.id,
    );
  }

  /// Convert calendar event to task (simplified)
  Map<String, dynamic> calendarEventToTaskData(CalendarEvent event) {
    return {
      'title': event.title,
      'description': event.description,
      'scheduledStartTime': event.startTime,
      'scheduledEndTime': event.endTime,
      'dueDate': event.isAllDay ? event.startTime : null,
      'calendarEventId': event.id,
      'tags': ['from-calendar'],
    };
  }
}
