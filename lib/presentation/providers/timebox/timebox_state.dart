import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/timebox_entity.dart';

part 'timebox_state.freezed.dart';

/// Timebox State
///
/// Represents the state of the timebox (daily agenda) feature.
/// Uses Freezed union types for type-safe state management.
///
/// WBS: 3.7.6.1
@freezed
class TimeboxState with _$TimeboxState {
  /// Initial state before any data is loaded
  const factory TimeboxState.initial() = TimeboxInitial;

  /// Loading state while fetching or processing data
  const factory TimeboxState.loading({
    TimeboxEntity? timebox,
    String? message,
  }) = TimeboxLoading;

  /// Success state with loaded timebox data
  const factory TimeboxState.loaded({
    required TimeboxEntity timebox,
  }) = TimeboxLoaded;

  /// Error state when an operation fails
  const factory TimeboxState.error({
    required Failure failure,
    TimeboxEntity? timebox,
  }) = TimeboxError;
}

/// Extension methods for TimeboxState
extension TimeboxStateX on TimeboxState {
  /// Get the timebox if available, null otherwise
  TimeboxEntity? get timeboxOrNull => maybeWhen(
        loaded: (timebox) => timebox,
        loading: (timebox, _) => timebox,
        error: (_, timebox) => timebox,
        orElse: () => null,
      );

  /// Check if state has a timebox
  bool get hasTimebox => timeboxOrNull != null;

  /// Check if state is loading
  bool get isLoading => this is TimeboxLoading;

  /// Check if state has error
  bool get hasError => this is TimeboxError;

  /// Get the failure if in error state
  Failure? get failureOrNull => maybeWhen(
        error: (failure, _) => failure,
        orElse: () => null,
      );

  /// Get slots from timebox
  List<TimeboxSlot> get slots => timeboxOrNull?.slots ?? [];

  /// Get conflicts from timebox
  List<TimeConflict> get conflicts => timeboxOrNull?.conflicts ?? [];

  /// Get summary from timebox
  TimeboxSummary? get summary => timeboxOrNull?.summary;

  /// Get settings from timebox
  TimeboxSettings? get settings => timeboxOrNull?.settings;

  /// Check if there are conflicts
  bool get hasConflicts => conflicts.isNotEmpty;

  /// Get personal slots
  List<TimeboxSlot> get personalSlots =>
      slots.where((s) => s.category == TaskCategory.personal).toList();

  /// Get professional slots
  List<TimeboxSlot> get professionalSlots =>
      slots.where((s) => s.category == TaskCategory.professional).toList();

  /// Get priority slots
  List<TimeboxSlot> get prioritySlots =>
      slots.where((s) => s.isPriority).toList();

  /// Get current/active slot
  TimeboxSlot? get currentSlot {
    final now = DateTime.now();
    try {
      return slots.firstWhere((s) =>
          now.isAfter(s.startTime) &&
          now.isBefore(s.endTime) &&
          s.status != TimeboxSlotStatus.completed);
    } catch (_) {
      return null;
    }
  }

  /// Get upcoming slots (not started yet)
  List<TimeboxSlot> get upcomingSlots {
    final now = DateTime.now();
    return slots
        .where((s) => s.startTime.isAfter(now) && s.status == TimeboxSlotStatus.scheduled)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get completed slots
  List<TimeboxSlot> get completedSlots =>
      slots.where((s) => s.status == TimeboxSlotStatus.completed).toList();

  /// Get overdue slots
  List<TimeboxSlot> get overdueSlots =>
      slots.where((s) => s.isOverdue).toList();
}
