import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dingdong/core/errors/failures.dart';
import 'package:dingdong/domain/entities/task_entity.dart';
import 'package:dingdong/domain/usecases/task/create_task_usecase.dart';
import 'package:dingdong/domain/usecases/task/get_task_usecase.dart';
import 'package:dingdong/domain/usecases/task/update_task_usecase.dart';
import 'package:dingdong/domain/usecases/task/delete_task_usecase.dart';
import 'package:dingdong/domain/usecases/task/complete_task_usecase.dart';
import 'package:dingdong/domain/usecases/task/get_tasks_due_today_usecase.dart';
import 'package:dingdong/domain/usecases/task/get_overdue_tasks_usecase.dart';
import 'package:dingdong/domain/usecases/task/search_tasks_usecase.dart';
import '../../../../mocks/mock_task_repository.dart';
import '../../../../fixtures/mock_data.dart';

void main() {
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  tearDown(() {
    mockRepository.reset();
  });

  // ============================================================
  // CREATE TASK USE CASE
  // ============================================================

  group('CreateTaskUseCase', () {
    late CreateTaskUseCase usecase;

    setUp(() {
      usecase = CreateTaskUseCase(mockRepository);
    });

    test('should create task successfully', () async {
      // Arrange
      final task = MockData.createTask(title: 'New Task');
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: ${failure.message}'),
        (createdTask) {
          expect(createdTask.title, 'New Task');
        },
      );
    });

    test('should return CacheFailure when repository fails', () async {
      // Arrange
      final task = MockData.createTask(title: 'New Task');
      mockRepository.setShouldFail(true);

      // Act
      final result = await usecase(CreateTaskParams(task: task));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (task) => fail('Expected Left but got Right'),
      );
    });

    test('should create task with all properties', () async {
      // Arrange
      final task = MockData.createTask(
        title: 'Complete Task',
        description: 'With description',
        priority: TaskPriority.high,
        tags: ['work', 'important'],
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (createdTask) {
          expect(createdTask.title, 'Complete Task');
          expect(createdTask.description, 'With description');
          expect(createdTask.priority, TaskPriority.high);
          expect(createdTask.tags, contains('work'));
        },
      );
    });
  });

  // ============================================================
  // GET TASK USE CASE
  // ============================================================

  group('GetTaskUseCase', () {
    late GetTaskUseCase usecase;

    setUp(() {
      usecase = GetTaskUseCase(mockRepository);
      // Pre-populate with tasks
      mockRepository.addTasks([
        MockData.createTask(id: 'task_1', title: 'Task 1'),
        MockData.createTask(id: 'task_2', title: 'Task 2'),
      ]);
    });

    test('should return task when found', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetTaskParams(taskId: 'task_1'));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (task) {
          expect(task.id, 'task_1');
          expect(task.title, 'Task 1');
        },
      );
    });

    test('should return failure when task not found', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetTaskParams(taskId: 'non_existent'));

      // Assert
      expect(result.isLeft(), isTrue);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      mockRepository.setShouldFail(true);

      // Act
      final result = await usecase(GetTaskParams(taskId: 'task_1'));

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  // ============================================================
  // UPDATE TASK USE CASE
  // ============================================================

  group('UpdateTaskUseCase', () {
    late UpdateTaskUseCase usecase;

    setUp(() {
      usecase = UpdateTaskUseCase(mockRepository);
      mockRepository.addTasks([
        MockData.createTask(id: 'task_1', title: 'Original Title'),
      ]);
    });

    test('should update task successfully', () async {
      // Arrange
      mockRepository.setShouldFail(false);
      final updatedTask = MockData.createTask(
        id: 'task_1',
        title: 'Updated Title',
      );

      // Act
      final result = await usecase(UpdateTaskParams(task: updatedTask));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (task) {
          expect(task.title, 'Updated Title');
        },
      );
    });

    test('should update task priority', () async {
      // Arrange
      mockRepository.setShouldFail(false);
      final updatedTask = MockData.createTask(
        id: 'task_1',
        title: 'Original Title',
        priority: TaskPriority.critical,
      );

      // Act
      final result = await usecase(UpdateTaskParams(task: updatedTask));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (task) {
          expect(task.priority, TaskPriority.critical);
        },
      );
    });

    test('should return failure when task does not exist', () async {
      // Arrange
      mockRepository.setShouldFail(false);
      final nonExistentTask = MockData.createTask(
        id: 'non_existent',
        title: 'Does not exist',
      );

      // Act
      final result = await usecase(UpdateTaskParams(task: nonExistentTask));

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  // ============================================================
  // DELETE TASK USE CASE
  // ============================================================

  group('DeleteTaskUseCase', () {
    late DeleteTaskUseCase usecase;

    setUp(() {
      usecase = DeleteTaskUseCase(mockRepository);
      mockRepository.addTasks([
        MockData.createTask(id: 'task_1', title: 'Task to delete'),
      ]);
    });

    test('should delete task successfully', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(DeleteTaskParams(taskId: 'task_1'));

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure when task does not exist', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(DeleteTaskParams(taskId: 'non_existent'));

      // Assert
      expect(result.isLeft(), isTrue);
    });

    test('should soft delete (mark as deleted)', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      await usecase(DeleteTaskParams(taskId: 'task_1'));

      // Verify task is marked as deleted (soft delete)
      final getResult = await mockRepository.getTask('task_1');
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (failure) => fail('Expected Right'),
        (task) => expect(task.status, TaskStatus.deleted),
      );
    });
  });

  // ============================================================
  // COMPLETE TASK USE CASE
  // ============================================================

  group('CompleteTaskUseCase', () {
    late CompleteTaskUseCase usecase;

    setUp(() {
      usecase = CompleteTaskUseCase(mockRepository);
      mockRepository.addTasks([
        MockData.createTask(id: 'task_1', title: 'Task to complete'),
      ]);
    });

    test('should complete task successfully', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(CompleteTaskParams(taskId: 'task_1'));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (task) {
          expect(task.status, TaskStatus.completed);
          expect(task.completedAt, isNotNull);
        },
      );
    });

    test('should set completedAt timestamp', () async {
      // Arrange
      mockRepository.setShouldFail(false);
      final beforeComplete = DateTime.now();

      // Act
      final result = await usecase(CompleteTaskParams(taskId: 'task_1'));

      // Assert
      result.fold(
        (failure) => fail('Expected Right'),
        (task) {
          expect(task.completedAt!.isAfter(beforeComplete), isTrue);
        },
      );
    });

    test('should return failure when task does not exist', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(CompleteTaskParams(taskId: 'non_existent'));

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  // ============================================================
  // GET TASKS DUE TODAY USE CASE
  // ============================================================

  group('GetTasksDueTodayUseCase', () {
    late GetTasksDueTodayUseCase usecase;

    setUp(() {
      usecase = GetTasksDueTodayUseCase(mockRepository);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12, 0);
      final yesterday = DateTime(now.year, now.month, now.day - 1, 12, 0);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0);

      mockRepository.addTasks([
        MockData.createTask(
            id: 'today_1', title: 'Due Today 1', dueDate: today),
        MockData.createTask(
            id: 'today_2', title: 'Due Today 2', dueDate: today),
        MockData.createTask(
            id: 'yesterday', title: 'Due Yesterday', dueDate: yesterday),
        MockData.createTask(
            id: 'tomorrow', title: 'Due Tomorrow', dueDate: tomorrow),
        MockData.createTask(id: 'no_date', title: 'No Due Date'),
      ]);
    });

    test('should return only tasks due today', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetTasksDueTodayParams(userId: 'user_1'));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (tasks) {
          expect(tasks.length, 2);
          expect(tasks.every((t) => t.title.contains('Due Today')), isTrue);
        },
      );
    });

    test('should return empty list when no tasks due today', () async {
      // Arrange
      mockRepository.reset();
      mockRepository.addTasks([
        MockData.createTask(
          id: 'tomorrow',
          title: 'Due Tomorrow',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ]);
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetTasksDueTodayParams(userId: 'user_1'));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) => expect(tasks, isEmpty),
      );
    });
  });

  // ============================================================
  // GET OVERDUE TASKS USE CASE
  // ============================================================

  group('GetOverdueTasksUseCase', () {
    late GetOverdueTasksUseCase usecase;

    setUp(() {
      usecase = GetOverdueTasksUseCase(mockRepository);

      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      mockRepository.addTasks([
        MockData.createTask(
          id: 'overdue_1',
          title: 'Overdue 1',
          dueDate: yesterday,
          status: TaskStatus.todo,
        ),
        MockData.createTask(
          id: 'overdue_2',
          title: 'Overdue 2',
          dueDate: twoDaysAgo,
          status: TaskStatus.todo,
        ),
        MockData.createTask(
          id: 'completed_overdue',
          title: 'Completed Overdue',
          dueDate: yesterday,
          status: TaskStatus.completed,
        ),
        MockData.createTask(
          id: 'future',
          title: 'Future Task',
          dueDate: tomorrow,
          status: TaskStatus.todo,
        ),
      ]);
    });

    test('should return only incomplete overdue tasks', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetOverdueTasksParams(userId: 'user_1'));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (tasks) {
          expect(tasks.length, 2);
          expect(tasks.every((t) => t.title.contains('Overdue')), isTrue);
          expect(
              tasks.every((t) => t.status != TaskStatus.completed), isTrue);
        },
      );
    });

    test('should not include completed tasks even if past due', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(GetOverdueTasksParams(userId: 'user_1'));

      // Assert
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.any((t) => t.id == 'completed_overdue'), isFalse);
        },
      );
    });
  });

  // ============================================================
  // SEARCH TASKS USE CASE
  // ============================================================

  group('SearchTasksUseCase', () {
    late SearchTasksUseCase usecase;

    setUp(() {
      usecase = SearchTasksUseCase(mockRepository);

      mockRepository.addTasks([
        MockData.createTask(
          id: 'task_1',
          title: 'Buy groceries',
          description: 'Get milk, eggs, bread',
          tags: ['shopping', 'personal'],
        ),
        MockData.createTask(
          id: 'task_2',
          title: 'Prepare presentation',
          description: 'For Monday meeting',
          tags: ['work'],
        ),
        MockData.createTask(
          id: 'task_3',
          title: 'Call mom',
          description: 'Birthday wishes',
          tags: ['personal'],
        ),
        MockData.createTask(
          id: 'task_4',
          title: 'Fix bug in shopping cart',
          description: 'Critical issue',
          tags: ['work', 'urgent'],
          priority: TaskPriority.critical,
        ),
      ]);
    });

    test('should find tasks by title', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: 'shopping',
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.length, 2); // "Buy groceries" and "Fix bug in shopping cart"
        },
      );
    });

    test('should find tasks by description', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: 'Monday',
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.title, 'Prepare presentation');
        },
      );
    });

    test('should filter by tags', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: '',
        tags: ['personal'],
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.length, 2);
          expect(tasks.every((t) => t.tags.contains('personal')), isTrue);
        },
      );
    });

    test('should filter by priority', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: '',
        priority: TaskPriority.critical,
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.priority, TaskPriority.critical);
        },
      );
    });

    test('should return empty list when no matches', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: 'xyz123nonexistent',
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) => expect(tasks, isEmpty),
      );
    });

    test('should be case insensitive', () async {
      // Arrange
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase(SearchTasksParams(
        userId: 'user_1',
        query: 'GROCERIES',
      ));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (tasks) {
          expect(tasks.length, greaterThan(0));
        },
      );
    });
  });
}
