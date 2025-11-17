import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/errors/failures.dart';
import '../../../lib/domain/entities/task_entity.dart';
import '../../../lib/domain/usecases/task/complete_task_usecase.dart';
import '../../fixtures/mock_data.dart';
import '../../mocks/mock_task_repository.dart';

void main() {
  late CompleteTaskUseCase usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = CompleteTaskUseCase(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('CompleteTaskUseCase', () {
    test('should complete task successfully', () async {
      // Arrange
      final task = MockData.taskTodo;
      mockRepository.addTasks([task]);
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CompleteTaskParams(taskId: task.id));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (completedTask) {
          expect(completedTask.id, task.id);
          expect(completedTask.status, TaskStatus.completed);
          expect(completedTask.completedAt, isNotNull);
          expect(completedTask.updatedAt, isNotNull);
        },
      );
    });

    test('should return failure when task not found', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result =
          await usecase.call(const CompleteTaskParams(taskId: 'nonexistent'));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, 'Task not found');
        },
        (task) => fail('Should not succeed'),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final task = MockData.taskTodo;
      mockRepository.addTasks([task]);
      final failure = CacheFailure('Failed to complete task');
      mockRepository.setShouldFail(true, failure: failure);

      // Act
      final result = await usecase.call(CompleteTaskParams(taskId: task.id));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, 'Failed to complete task');
        },
        (task) => fail('Should not succeed'),
      );
    });

    test('should complete task that is already in progress', () async {
      // Arrange
      final task = MockData.taskWithSubtasks; // in progress
      mockRepository.addTasks([task]);
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CompleteTaskParams(taskId: task.id));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (completedTask) {
          expect(completedTask.status, TaskStatus.completed);
          expect(completedTask.completedAt, isNotNull);
        },
      );
    });

    test('should handle completing overdue task', () async {
      // Arrange
      final task = MockData.taskOverdue;
      mockRepository.addTasks([task]);
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CompleteTaskParams(taskId: task.id));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (completedTask) {
          expect(completedTask.status, TaskStatus.completed);
          expect(completedTask.completedAt, isNotNull);
          // Original due date should be preserved
          expect(completedTask.dueDate, task.dueDate);
        },
      );
    });

    test('should preserve task properties when completing', () async {
      // Arrange
      final task = MockData.taskToday;
      mockRepository.addTasks([task]);
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CompleteTaskParams(taskId: task.id));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (completedTask) {
          // All original properties should be preserved
          expect(completedTask.title, task.title);
          expect(completedTask.description, task.description);
          expect(completedTask.priority, task.priority);
          expect(completedTask.tags, task.tags);
          expect(completedTask.dueDate, task.dueDate);
          expect(completedTask.userId, task.userId);
          expect(completedTask.categoryId, task.categoryId);
          // Only status and completedAt should change
          expect(completedTask.status, TaskStatus.completed);
          expect(completedTask.completedAt, isNotNull);
        },
      );
    });
  });
}
