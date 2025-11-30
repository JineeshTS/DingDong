import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/timebox_entity.dart';
import '../../repositories/timebox_repository.dart';

// ============================================================
// UPDATE TIMEBOX SLOT USE CASE (WBS: 3.7.3.3)
// ============================================================

/// Update Timebox Slot Use Case
class UpdateTimeboxSlotUseCase {
  final TimeboxRepository _repository;

  const UpdateTimeboxSlotUseCase(this._repository);

  Future<Either<Failure, TimeboxEntity>> call(UpdateTimeboxSlotParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.slot.id.isEmpty) {
      return const Left(ValidationFailure(message: 'Slot ID is required'));
    }

    return await _repository.updateSlot(
      timeboxId: params.timeboxId,
      slot: params.slot,
    );
  }
}

class UpdateTimeboxSlotParams extends Equatable {
  final String timeboxId;
  final TimeboxSlot slot;

  const UpdateTimeboxSlotParams({
    required this.timeboxId,
    required this.slot,
  });

  @override
  List<Object?> get props => [timeboxId, slot];
}

// ============================================================
// DELETE TIMEBOX SLOT USE CASE (WBS: 3.7.3.4)
// ============================================================

/// Delete Timebox Slot Use Case
class DeleteTimeboxSlotUseCase {
  final TimeboxRepository _repository;

  const DeleteTimeboxSlotUseCase(this._repository);

  Future<Either<Failure, TimeboxEntity>> call(DeleteTimeboxSlotParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.slotId.isEmpty) {
      return const Left(ValidationFailure(message: 'Slot ID is required'));
    }

    return await _repository.removeSlot(
      timeboxId: params.timeboxId,
      slotId: params.slotId,
    );
  }
}

class DeleteTimeboxSlotParams extends Equatable {
  final String timeboxId;
  final String slotId;

  const DeleteTimeboxSlotParams({
    required this.timeboxId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [timeboxId, slotId];
}

// ============================================================
// RESCHEDULE SLOT USE CASE (WBS: 3.7.3.7)
// ============================================================

/// Reschedule Slot Use Case
class RescheduleSlotUseCase {
  final TimeboxRepository _repository;

  const RescheduleSlotUseCase(this._repository);

  Future<Either<Failure, TimeboxEntity>> call(RescheduleSlotParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.slotId.isEmpty) {
      return const Left(ValidationFailure(message: 'Slot ID is required'));
    }

    if (params.newEndTime.isBefore(params.newStartTime)) {
      return const Left(ValidationFailure(message: 'End time must be after start time'));
    }

    return await _repository.rescheduleSlot(
      timeboxId: params.timeboxId,
      slotId: params.slotId,
      newStartTime: params.newStartTime,
      newEndTime: params.newEndTime,
    );
  }
}

class RescheduleSlotParams extends Equatable {
  final String timeboxId;
  final String slotId;
  final DateTime newStartTime;
  final DateTime newEndTime;

  const RescheduleSlotParams({
    required this.timeboxId,
    required this.slotId,
    required this.newStartTime,
    required this.newEndTime,
  });

  @override
  List<Object?> get props => [timeboxId, slotId, newStartTime, newEndTime];
}

// ============================================================
// COMPLETE TIMEBOX SLOT USE CASE (WBS: 3.7.3.8)
// ============================================================

/// Complete Timebox Slot Use Case
class CompleteTimeboxSlotUseCase {
  final TimeboxRepository _repository;

  const CompleteTimeboxSlotUseCase(this._repository);

  Future<Either<Failure, TimeboxEntity>> call(CompleteTimeboxSlotParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.slotId.isEmpty) {
      return const Left(ValidationFailure(message: 'Slot ID is required'));
    }

    return await _repository.completeSlot(
      timeboxId: params.timeboxId,
      slotId: params.slotId,
    );
  }
}

class CompleteTimeboxSlotParams extends Equatable {
  final String timeboxId;
  final String slotId;

  const CompleteTimeboxSlotParams({
    required this.timeboxId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [timeboxId, slotId];
}

// ============================================================
// SKIP TIMEBOX SLOT USE CASE
// ============================================================

/// Skip Timebox Slot Use Case
class SkipTimeboxSlotUseCase {
  final TimeboxRepository _repository;

  const SkipTimeboxSlotUseCase(this._repository);

  Future<Either<Failure, TimeboxEntity>> call(SkipTimeboxSlotParams params) async {
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.slotId.isEmpty) {
      return const Left(ValidationFailure(message: 'Slot ID is required'));
    }

    return await _repository.skipSlot(
      timeboxId: params.timeboxId,
      slotId: params.slotId,
    );
  }
}

class SkipTimeboxSlotParams extends Equatable {
  final String timeboxId;
  final String slotId;

  const SkipTimeboxSlotParams({
    required this.timeboxId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [timeboxId, slotId];
}

// ============================================================
// GET TIMEBOX SUMMARY USE CASE
// ============================================================

/// Get Timebox Summary Use Case
class GetTimeboxSummaryUseCase {
  final TimeboxRepository _repository;

  const GetTimeboxSummaryUseCase(this._repository);

  Future<Either<Failure, TimeboxSummary>> call(GetTimeboxSummaryParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID is required'));
    }

    return await _repository.getSummaryForDateRange(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTimeboxSummaryParams extends Equatable {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const GetTimeboxSummaryParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  /// Get summary for today
  factory GetTimeboxSummaryParams.today(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return GetTimeboxSummaryParams(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get summary for this week
  factory GetTimeboxSummaryParams.thisWeek(String userId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));
    return GetTimeboxSummaryParams(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

// ============================================================
// WATCH TODAY TIMEBOX USE CASE
// ============================================================

/// Watch Today Timebox Use Case
class WatchTodayTimeboxUseCase {
  final TimeboxRepository _repository;

  const WatchTodayTimeboxUseCase(this._repository);

  Stream<Either<Failure, TimeboxEntity>> call(String userId) {
    return _repository.watchTodayTimebox(userId);
  }
}
