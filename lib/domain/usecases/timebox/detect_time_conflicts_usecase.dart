import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/timebox_entity.dart';
import '../../repositories/timebox_repository.dart';

/// Detect Time Conflicts Use Case
///
/// Analyzes the timebox slots and detects any scheduling conflicts:
/// - Overlapping time slots
/// - Back-to-back tasks without buffer
/// - Tasks exceeding work hours
///
/// WBS: 3.7.3.5
class DetectTimeConflictsUseCase {
  final TimeboxRepository _repository;

  const DetectTimeConflictsUseCase(this._repository);

  /// Execute the use case
  Future<Either<Failure, List<TimeConflict>>> call(DetectTimeConflictsParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    return await _repository.detectConflicts(timeboxId: params.timeboxId);
  }

  /// Detect conflicts locally without repository
  ///
  /// Useful for real-time conflict detection as user drags slots
  List<TimeConflict> detectConflictsLocally({
    required List<TimeboxSlot> slots,
    required TimeboxSettings settings,
  }) {
    final conflicts = <TimeConflict>[];
    final sortedSlots = List<TimeboxSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (var i = 0; i < sortedSlots.length; i++) {
      final slot1 = sortedSlots[i];

      // Check if slot exceeds work hours
      final dayStart = DateTime(
        slot1.startTime.year,
        slot1.startTime.month,
        slot1.startTime.day,
        settings.dayStartHour,
      );
      final dayEnd = DateTime(
        slot1.startTime.year,
        slot1.startTime.month,
        slot1.startTime.day,
        settings.dayEndHour,
      );

      if (slot1.startTime.isBefore(dayStart) || slot1.endTime.isAfter(dayEnd)) {
        conflicts.add(TimeConflict(
          id: 'conflict_${slot1.id}_workhours',
          slot1Id: slot1.id,
          slot1Title: slot1.taskTitle,
          slot2Id: '',
          slot2Title: 'Work Hours',
          overlapStart: slot1.startTime.isBefore(dayStart) ? slot1.startTime : dayEnd,
          overlapEnd: slot1.startTime.isBefore(dayStart) ? dayStart : slot1.endTime,
          type: TimeConflictType.exceedsWorkHours,
          severity: TimeConflictSeverity.warning,
        ));
      }

      // Check for overlaps with subsequent slots
      for (var j = i + 1; j < sortedSlots.length; j++) {
        final slot2 = sortedSlots[j];

        // Check for overlap
        if (slot1.endTime.isAfter(slot2.startTime)) {
          final overlapStart = slot2.startTime;
          final overlapEnd = slot1.endTime.isBefore(slot2.endTime)
              ? slot1.endTime
              : slot2.endTime;

          // Determine conflict type
          TimeConflictType type;
          if (slot1.startTime == slot2.startTime && slot1.endTime == slot2.endTime) {
            type = TimeConflictType.doubleBooked;
          } else if (slot1.startTime.isBefore(slot2.startTime) &&
              slot1.endTime.isAfter(slot2.endTime)) {
            type = TimeConflictType.completeOverlap;
          } else {
            type = TimeConflictType.partialOverlap;
          }

          conflicts.add(TimeConflict(
            id: 'conflict_${slot1.id}_${slot2.id}',
            slot1Id: slot1.id,
            slot1Title: slot1.taskTitle,
            slot2Id: slot2.id,
            slot2Title: slot2.taskTitle,
            overlapStart: overlapStart,
            overlapEnd: overlapEnd,
            type: type,
            severity: TimeConflictSeverity.error,
          ));
        }
        // Check for back-to-back without buffer
        else if (settings.bufferBetweenSlots > 0) {
          final gap = slot2.startTime.difference(slot1.endTime).inMinutes;
          if (gap < settings.bufferBetweenSlots && gap >= 0) {
            conflicts.add(TimeConflict(
              id: 'conflict_${slot1.id}_${slot2.id}_buffer',
              slot1Id: slot1.id,
              slot1Title: slot1.taskTitle,
              slot2Id: slot2.id,
              slot2Title: slot2.taskTitle,
              overlapStart: slot1.endTime,
              overlapEnd: slot2.startTime,
              type: TimeConflictType.backToBack,
              severity: TimeConflictSeverity.info,
            ));
          }
        }
      }
    }

    return conflicts;
  }
}

/// Parameters for DetectTimeConflictsUseCase
class DetectTimeConflictsParams extends Equatable {
  final String timeboxId;

  const DetectTimeConflictsParams({required this.timeboxId});

  @override
  List<Object?> get props => [timeboxId];
}
