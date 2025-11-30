import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/timebox_service.dart';
import '../../../domain/entities/timebox_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/timebox/timebox.dart';
import 'timebox_state.dart';

/// Timebox Notifier
///
/// Manages the state for the timebox (daily agenda) feature.
/// Handles all timebox-related operations and state updates.
///
/// WBS: 3.7.6.2
class TimeboxNotifier extends StateNotifier<TimeboxState> {
  final GetDailyTimeboxUseCase _getDailyTimebox;
  final CreateTimeboxSlotUseCase _createSlot;
  final UpdateTimeboxSlotUseCase _updateSlot;
  final DeleteTimeboxSlotUseCase _deleteSlot;
  final DetectTimeConflictsUseCase _detectConflicts;
  final AutoScheduleTasksUseCase _autoScheduleTasks;
  final RescheduleSlotUseCase _rescheduleSlot;
  final CompleteTimeboxSlotUseCase _completeSlot;
  final SkipTimeboxSlotUseCase _skipSlot;
  final TimeboxService _timeboxService;

  TimeboxNotifier({
    required GetDailyTimeboxUseCase getDailyTimebox,
    required CreateTimeboxSlotUseCase createSlot,
    required UpdateTimeboxSlotUseCase updateSlot,
    required DeleteTimeboxSlotUseCase deleteSlot,
    required DetectTimeConflictsUseCase detectConflicts,
    required AutoScheduleTasksUseCase autoScheduleTasks,
    required RescheduleSlotUseCase rescheduleSlot,
    required CompleteTimeboxSlotUseCase completeSlot,
    required SkipTimeboxSlotUseCase skipSlot,
    TimeboxService? timeboxService,
  })  : _getDailyTimebox = getDailyTimebox,
        _createSlot = createSlot,
        _updateSlot = updateSlot,
        _deleteSlot = deleteSlot,
        _detectConflicts = detectConflicts,
        _autoScheduleTasks = autoScheduleTasks,
        _rescheduleSlot = rescheduleSlot,
        _completeSlot = completeSlot,
        _skipSlot = skipSlot,
        _timeboxService = timeboxService ?? TimeboxService.instance,
        super(const TimeboxState.initial());

  // ============================================================
  // LOAD TIMEBOX
  // ============================================================

  /// Load timebox for a specific date
  Future<void> loadTimebox({
    required String userId,
    required DateTime date,
  }) async {
    state = TimeboxState.loading(
      timebox: state.timeboxOrNull,
      message: 'Loading daily agenda...',
    );

    final result = await _getDailyTimebox(GetDailyTimeboxParams(
      userId: userId,
      date: date,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(
        failure: failure,
        timebox: state.timeboxOrNull,
      ),
      (timebox) => state = TimeboxState.loaded(timebox: timebox),
    );
  }

  /// Load today's timebox
  Future<void> loadTodayTimebox(String userId) async {
    await loadTimebox(userId: userId, date: DateTime.now());
  }

  // ============================================================
  // SLOT MANAGEMENT
  // ============================================================

  /// Add a new slot to the timebox
  Future<void> addSlot({
    required String taskId,
    required String taskTitle,
    String? taskDescription,
    required DateTime startTime,
    required DateTime endTime,
    required TaskCategory category,
    TaskPriority priority = TaskPriority.none,
    String? listId,
    String? listName,
    String? listColor,
    List<String> tags = const [],
    String? notes,
  }) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Adding task to agenda...',
    );

    final result = await _createSlot(CreateTimeboxSlotParams(
      timeboxId: timebox.id,
      taskId: taskId,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      startTime: startTime,
      endTime: endTime,
      category: category,
      priority: priority,
      listId: listId,
      listName: listName,
      listColor: listColor,
      tags: tags,
      notes: notes,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Update an existing slot
  Future<void> updateSlot(TimeboxSlot slot) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Updating task...',
    );

    final result = await _updateSlot(UpdateTimeboxSlotParams(
      timeboxId: timebox.id,
      slot: slot,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Delete a slot from the timebox
  Future<void> deleteSlot(String slotId) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Removing task...',
    );

    final result = await _deleteSlot(DeleteTimeboxSlotParams(
      timeboxId: timebox.id,
      slotId: slotId,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Reschedule a slot to a new time
  Future<void> rescheduleSlot({
    required String slotId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Rescheduling task...',
    );

    final result = await _rescheduleSlot(RescheduleSlotParams(
      timeboxId: timebox.id,
      slotId: slotId,
      newStartTime: newStartTime,
      newEndTime: newEndTime,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Mark a slot as completed
  Future<void> completeSlot(String slotId) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Completing task...',
    );

    final result = await _completeSlot(CompleteTimeboxSlotParams(
      timeboxId: timebox.id,
      slotId: slotId,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Skip a slot
  Future<void> skipSlot(String slotId) async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Skipping task...',
    );

    final result = await _skipSlot(SkipTimeboxSlotParams(
      timeboxId: timebox.id,
      slotId: slotId,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  // ============================================================
  // AUTO-SCHEDULING
  // ============================================================

  /// Auto-schedule tasks into the timebox
  Future<void> autoScheduleTasks({
    required String userId,
    required DateTime date,
    required List<TaskEntity> tasks,
  }) async {
    final timebox = state.timeboxOrNull;

    state = TimeboxState.loading(
      timebox: timebox,
      message: 'Auto-scheduling ${tasks.length} tasks...',
    );

    final result = await _autoScheduleTasks(AutoScheduleTasksParams(
      userId: userId,
      date: date,
      tasks: tasks,
      settings: timebox?.settings,
    ));

    result.fold(
      (failure) => state = TimeboxState.error(failure: failure, timebox: timebox),
      (updatedTimebox) => state = TimeboxState.loaded(timebox: updatedTimebox),
    );
  }

  /// Preview auto-schedule without saving
  List<TimeboxSlot> previewAutoSchedule({
    required List<TaskEntity> tasks,
    required DateTime date,
  }) {
    final settings = state.settings ?? const TimeboxSettings();
    final existingSlots = state.slots;

    return _timeboxService.autoScheduleTasks(
      tasks: tasks,
      date: date,
      settings: settings,
      existingSlots: existingSlots,
    );
  }

  // ============================================================
  // CONFLICT DETECTION
  // ============================================================

  /// Detect conflicts in the current timebox
  Future<void> detectConflicts() async {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return;

    final result = await _detectConflicts(DetectTimeConflictsParams(
      timeboxId: timebox.id,
    ));

    result.fold(
      (failure) {
        // Don't change state on failure, just log
      },
      (conflicts) {
        // Update timebox with new conflicts
        final updatedTimebox = timebox.copyWith(conflicts: conflicts);
        state = TimeboxState.loaded(timebox: updatedTimebox);
      },
    );
  }

  /// Detect conflicts locally (real-time preview)
  List<TimeConflict> detectConflictsLocally() {
    final settings = state.settings ?? const TimeboxSettings();
    return _timeboxService.detectConflicts(
      slots: state.slots,
      settings: settings,
    );
  }

  /// Check if adding a slot would cause conflicts
  List<TimeConflict> checkSlotConflicts(TimeboxSlot newSlot) {
    final settings = state.settings ?? const TimeboxSettings();
    final allSlots = [...state.slots, newSlot];
    return _timeboxService.detectConflicts(
      slots: allSlots,
      settings: settings,
    );
  }

  // ============================================================
  // SUGGESTIONS
  // ============================================================

  /// Suggest a time slot for a task
  AvailableSlot? suggestTimeSlot(TaskEntity task) {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return null;

    return _timeboxService.suggestTimeSlot(
      task: task,
      date: timebox.date,
      settings: timebox.settings,
      existingSlots: timebox.slots,
    );
  }

  /// Get available time slots
  List<AvailableSlot> getAvailableSlots() {
    final timebox = state.timeboxOrNull;
    if (timebox == null) return [];

    return _timeboxService.getAvailableSlots(
      date: timebox.date,
      settings: timebox.settings,
      existingSlots: timebox.slots,
    );
  }

  /// Infer category for a task
  TaskCategory inferCategory(TaskEntity task, {String? listName}) {
    return _timeboxService.inferCategory(task, listName: listName);
  }

  // ============================================================
  // FILTERING
  // ============================================================

  /// Get slots by category
  List<TimeboxSlot> getSlotsByCategory(TaskCategory category) {
    return state.slots.where((s) => s.category == category).toList();
  }

  /// Get slots by priority
  List<TimeboxSlot> getPrioritySlots() {
    return state.slots.where((s) => s.isPriority).toList();
  }

  /// Get slots by status
  List<TimeboxSlot> getSlotsByStatus(TimeboxSlotStatus status) {
    return state.slots.where((s) => s.status == status).toList();
  }

  // ============================================================
  // RESET
  // ============================================================

  /// Reset state to initial
  void reset() {
    state = const TimeboxState.initial();
  }

  /// Clear error and return to previous valid state
  void clearError() {
    final timebox = state.timeboxOrNull;
    if (timebox != null) {
      state = TimeboxState.loaded(timebox: timebox);
    } else {
      state = const TimeboxState.initial();
    }
  }
}
