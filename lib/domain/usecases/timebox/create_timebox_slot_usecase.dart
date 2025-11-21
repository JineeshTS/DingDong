import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/timebox_entity.dart';
import '../../entities/task_entity.dart';
import '../../repositories/timebox_repository.dart';

/// Create Timebox Slot Use Case
///
/// Creates a new time slot in the daily timebox agenda.
/// Validates time ranges and checks for conflicts.
///
/// WBS: 3.7.3.2
class CreateTimeboxSlotUseCase {
  final TimeboxRepository _repository;

  const CreateTimeboxSlotUseCase(this._repository);

  /// Execute the use case
  Future<Either<Failure, TimeboxEntity>> call(CreateTimeboxSlotParams params) async {
    // Validate parameters
    if (params.timeboxId.isEmpty) {
      return const Left(ValidationFailure(message: 'Timebox ID is required'));
    }

    if (params.taskId.isEmpty) {
      return const Left(ValidationFailure(message: 'Task ID is required'));
    }

    if (params.taskTitle.isEmpty) {
      return const Left(ValidationFailure(message: 'Task title is required'));
    }

    if (params.endTime.isBefore(params.startTime)) {
      return const Left(ValidationFailure(message: 'End time must be after start time'));
    }

    if (params.endTime.isAtSameMomentAs(params.startTime)) {
      return const Left(ValidationFailure(message: 'Slot must have duration'));
    }

    // Create the slot
    final slot = TimeboxSlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: params.taskId,
      taskTitle: params.taskTitle,
      taskDescription: params.taskDescription,
      startTime: params.startTime,
      endTime: params.endTime,
      category: params.category,
      priority: params.priority,
      listId: params.listId,
      listName: params.listName,
      listColor: params.listColor,
      tags: params.tags,
      isRecurring: params.isRecurring,
      isAllDay: params.isAllDay,
      notes: params.notes,
    );

    return await _repository.addSlot(
      timeboxId: params.timeboxId,
      slot: slot,
    );
  }
}

/// Parameters for CreateTimeboxSlotUseCase
class CreateTimeboxSlotParams extends Equatable {
  final String timeboxId;
  final String taskId;
  final String taskTitle;
  final String? taskDescription;
  final DateTime startTime;
  final DateTime endTime;
  final TaskCategory category;
  final TaskPriority priority;
  final String? listId;
  final String? listName;
  final String? listColor;
  final List<String> tags;
  final bool isRecurring;
  final bool isAllDay;
  final String? notes;

  const CreateTimeboxSlotParams({
    required this.timeboxId,
    required this.taskId,
    required this.taskTitle,
    this.taskDescription,
    required this.startTime,
    required this.endTime,
    this.category = TaskCategory.personal,
    this.priority = TaskPriority.none,
    this.listId,
    this.listName,
    this.listColor,
    this.tags = const [],
    this.isRecurring = false,
    this.isAllDay = false,
    this.notes,
  });

  @override
  List<Object?> get props => [
        timeboxId,
        taskId,
        taskTitle,
        taskDescription,
        startTime,
        endTime,
        category,
        priority,
        listId,
        listName,
        listColor,
        tags,
        isRecurring,
        isAllDay,
        notes,
      ];
}
