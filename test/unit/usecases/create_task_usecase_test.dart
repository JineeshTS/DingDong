import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/errors/failures.dart';
import '../../../lib/domain/entities/task_entity.dart';
import '../../../lib/domain/usecases/task/create_task_usecase.dart';
import '../../fixtures/mock_data.dart';
import '../../mocks/mock_task_repository.dart';

void main() {
  late CreateTaskUseCase usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = CreateTaskUseCase(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('CreateTaskUseCase', () {
    test('should create task successfully', () async {
      // Arrange
      final task = MockData.createTask(
        title: 'New Test Task',
        description: 'Test description',
        priority: TaskPriority.high,
      );

      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (createdTask) {
          expect(createdTask.id, task.id);
          expect(createdTask.title, 'New Test Task');
          expect(createdTask.description, 'Test description');
          expect(createdTask.priority, TaskPriority.high);
        },
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final task = MockData.createTask(title: 'Test Task');
      final failure = CacheFailure('Failed to create task');
      mockRepository.setShouldFail(true, failure: failure);

      // Act
      final result = await usecase.call(CreateTaskParams(task: task));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, 'Failed to create task');
        },
        (task) => fail('Should not succeed'),
      );
    });

    test('should create task with all optional fields', () async {
      // Arrange
      final task = MockData.createTask(
        title: 'Complex Task',
        description: 'Complex description',
        priority: TaskPriority.critical,
        tags: ['urgent', 'important'],
        dueDate: DateTime.now().add(const Duration(days: 7)),
        listId: 'list_1',
      );

      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (createdTask) {
          expect(createdTask.title, 'Complex Task');
          expect(createdTask.description, 'Complex description');
          expect(createdTask.priority, TaskPriority.critical);
          expect(createdTask.tags, contains('urgent'));
          expect(createdTask.tags, contains('important'));
          expect(createdTask.dueDate, isNotNull);
          expect(createdTask.categoryId, 'list_1');
        },
      );
    });

    test('should create task without optional fields', () async {
      // Arrange
      final task = MockData.createTask(title: 'Simple Task');

      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (createdTask) {
          expect(createdTask.title, 'Simple Task');
          expect(createdTask.description, isNull);
          expect(createdTask.priority, TaskPriority.medium);
          expect(createdTask.tags, isEmpty);
          expect(createdTask.dueDate, isNull);
        },
      );
    });

    test('should handle subtask creation', () async {
      // Arrange
      final parentTask = MockData.taskWithSubtasks;
      mockRepository.addTasks([parentTask]);

      final subtask = MockData.createTask(
        id: 'new_subtask',
        title: 'New Subtask',
        parentTaskId: parentTask.id,
      );

      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CreateTaskParams(task: subtask));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (createdTask) {
          expect(createdTask.title, 'New Subtask');
          expect(createdTask.parentTaskId, parentTask.id);
        },
      );
    });
  });
}
