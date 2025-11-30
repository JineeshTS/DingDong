import 'package:flutter_test/flutter_test.dart';
import 'package:dingdong/domain/entities/task_entity.dart';

void main() {
  group('TaskEntity', () {
    late TaskEntity task;

    setUp(() {
      task = TaskEntity(
        id: 'task_1',
        title: 'Test Task',
        description: 'Test description',
        userId: 'user_1',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        tags: ['work', 'urgent'],
        createdAt: DateTime(2025, 11, 21, 10, 0),
        updatedAt: DateTime(2025, 11, 21, 10, 0),
        sortOrder: 0,
      );
    });

    group('Constructor', () {
      test('should create TaskEntity with required fields', () {
        expect(task.id, 'task_1');
        expect(task.title, 'Test Task');
        expect(task.userId, 'user_1');
        expect(task.status, TaskStatus.todo);
        expect(task.priority, TaskPriority.medium);
      });

      test('should create TaskEntity with default values', () {
        final basicTask = TaskEntity(
          id: 'task_2',
          title: 'Basic Task',
          userId: 'user_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 0,
        );

        expect(basicTask.description, isNull);
        expect(basicTask.dueDate, isNull);
        expect(basicTask.completedAt, isNull);
        expect(basicTask.tags, isEmpty);
      });
    });

    group('isOverdue', () {
      test('should return true when task is past due date and not completed',
          () {
        final overdueTask = task.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.todo,
        );

        expect(overdueTask.isOverdue, isTrue);
      });

      test('should return false when task is completed', () {
        final completedTask = task.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.completed,
        );

        expect(completedTask.isOverdue, isFalse);
      });

      test('should return false when task has no due date', () {
        expect(task.isOverdue, isFalse);
      });

      test('should return false when due date is in the future', () {
        final futureTask = task.copyWith(
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        expect(futureTask.isOverdue, isFalse);
      });
    });

    group('isDueToday', () {
      test('should return true when task is due today', () {
        final now = DateTime.now();
        final todayTask = task.copyWith(
          dueDate: DateTime(now.year, now.month, now.day, 14, 0),
        );

        expect(todayTask.isDueToday, isTrue);
      });

      test('should return false when task is due tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowTask = task.copyWith(
          dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );

        expect(tomorrowTask.isDueToday, isFalse);
      });

      test('should return false when task has no due date', () {
        expect(task.isDueToday, isFalse);
      });
    });

    group('isDueTomorrow', () {
      test('should return true when task is due tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowTask = task.copyWith(
          dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
        );

        expect(tomorrowTask.isDueTomorrow, isTrue);
      });

      test('should return false when task is due today', () {
        final now = DateTime.now();
        final todayTask = task.copyWith(
          dueDate: DateTime(now.year, now.month, now.day, 14, 0),
        );

        expect(todayTask.isDueTomorrow, isFalse);
      });
    });

    group('isCompleted', () {
      test('should return true when status is completed', () {
        final completedTask = task.copyWith(status: TaskStatus.completed);
        expect(completedTask.isCompleted, isTrue);
      });

      test('should return false when status is todo', () {
        expect(task.isCompleted, isFalse);
      });

      test('should return false when status is in_progress', () {
        final inProgressTask = task.copyWith(status: TaskStatus.inProgress);
        expect(inProgressTask.isCompleted, isFalse);
      });
    });

    group('hasSubtasks', () {
      test('should return true when subtaskIds is not empty', () {
        final parentTask = task.copyWith(
          subtaskIds: ['subtask_1', 'subtask_2'],
        );
        expect(parentTask.hasSubtasks, isTrue);
      });

      test('should return false when subtaskIds is empty', () {
        expect(task.hasSubtasks, isFalse);
      });

      test('should return false when subtaskIds is null', () {
        final taskWithNullSubtasks = TaskEntity(
          id: 'task_3',
          title: 'Task without subtasks',
          userId: 'user_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 0,
        );
        expect(taskWithNullSubtasks.hasSubtasks, isFalse);
      });
    });

    group('isSubtask', () {
      test('should return true when parentTaskId is set', () {
        final subtask = task.copyWith(parentTaskId: 'parent_task_1');
        expect(subtask.isSubtask, isTrue);
      });

      test('should return false when parentTaskId is null', () {
        expect(task.isSubtask, isFalse);
      });
    });

    group('hasTags', () {
      test('should return true when task has tags', () {
        expect(task.hasTags, isTrue);
      });

      test('should return false when task has no tags', () {
        final noTagsTask = task.copyWith(tags: []);
        expect(noTagsTask.hasTags, isFalse);
      });
    });

    group('hasReminder', () {
      test('should return true when reminderDate is set', () {
        final reminderTask = task.copyWith(
          reminderDate: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(reminderTask.hasReminder, isTrue);
      });

      test('should return false when reminderDate is null', () {
        expect(task.hasReminder, isFalse);
      });
    });

    group('copyWith', () {
      test('should create a new instance with updated title', () {
        final updated = task.copyWith(title: 'Updated Title');

        expect(updated.title, 'Updated Title');
        expect(updated.id, task.id);
        expect(updated.description, task.description);
      });

      test('should create a new instance with updated status', () {
        final completed = task.copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
        );

        expect(completed.status, TaskStatus.completed);
        expect(completed.completedAt, isNotNull);
      });

      test('should preserve unchanged fields', () {
        final updated = task.copyWith(priority: TaskPriority.high);

        expect(updated.priority, TaskPriority.high);
        expect(updated.title, task.title);
        expect(updated.tags, task.tags);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final task1 = TaskEntity(
          id: 'task_1',
          title: 'Test',
          userId: 'user_1',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          sortOrder: 0,
        );

        final task2 = TaskEntity(
          id: 'task_1',
          title: 'Test',
          userId: 'user_1',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          sortOrder: 0,
        );

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('should not be equal when id differs', () {
        final task1 = task;
        final task2 = task.copyWith(id: 'task_2');

        expect(task1, isNot(equals(task2)));
      });
    });
  });

  group('TaskStatus', () {
    test('should have correct values', () {
      expect(TaskStatus.values.length, greaterThanOrEqualTo(4));
      expect(TaskStatus.values, contains(TaskStatus.todo));
      expect(TaskStatus.values, contains(TaskStatus.inProgress));
      expect(TaskStatus.values, contains(TaskStatus.completed));
      expect(TaskStatus.values, contains(TaskStatus.deleted));
    });
  });

  group('TaskPriority', () {
    test('should have correct values', () {
      expect(TaskPriority.values.length, greaterThanOrEqualTo(4));
      expect(TaskPriority.values, contains(TaskPriority.none));
      expect(TaskPriority.values, contains(TaskPriority.low));
      expect(TaskPriority.values, contains(TaskPriority.medium));
      expect(TaskPriority.values, contains(TaskPriority.high));
    });

    test('priorities should be comparable', () {
      expect(TaskPriority.high.index, greaterThan(TaskPriority.low.index));
      expect(TaskPriority.medium.index, greaterThan(TaskPriority.low.index));
    });
  });
}
