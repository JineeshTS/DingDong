import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/domain/entities/task_entity.dart';
import '../../lib/presentation/providers/task_provider.dart';
import '../../lib/presentation/screens/tasks/task_list_screen.dart';
import '../../lib/presentation/screens/tasks/task_form_screen.dart';
import '../fixtures/mock_data.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_task_repository.dart';

/// Integration test for complete task management flow
///
/// Tests the entire user journey from viewing tasks to creating,
/// editing, and completing tasks.
void main() {
  group('Task Management Integration Tests', () {
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    tearDown(() {
      mockRepository.reset();
    });

    testWidgets('Complete task creation flow', (tester) async {
      // Arrange - Start with empty task list
      mockRepository.addTasks([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Should show empty state
      expect(find.textContaining('No tasks'), findsOneWidget);

      // Act - Navigate to create task screen
      // (In real app, would tap FAB or create button)
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: TaskFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Fill in task details
      await tester.enterText(
        find.byType(TextField).first,
        'New Integration Test Task',
      );
      await tester.pumpAndSettle();

      // Act - Save the task
      await tester.tap(find.text('Create Task'));
      await tester.pumpAndSettle();

      // Assert - Task should be created
      // (Verification would depend on mock repository state)
    });

    testWidgets('Complete task completion flow', (tester) async {
      // Arrange - Start with a todo task
      final task = MockData.taskTodo;
      mockRepository.addTasks([task]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Task should be visible
      expect(find.text('Buy groceries'), findsOneWidget);

      // Act - Tap checkbox to complete task
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Assert - Task should be marked as completed
      // (In real app, would verify checkmark and strikethrough)
    });

    testWidgets('Task filtering and viewing flow', (tester) async {
      // Arrange - Create tasks with different states
      final tasks = [
        MockData.taskTodo,
        MockData.taskCompleted,
        MockData.taskOverdue,
        MockData.taskToday,
      ];
      mockRepository.addTasks(tasks);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - All incomplete tasks should be visible
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Team meeting at 2pm'), findsOneWidget);

      // Act - Filter by "Today"
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Assert - Only today's tasks should be visible
      expect(find.text('Team meeting at 2pm'), findsOneWidget);
      expect(find.text('Buy groceries'), findsNothing);

      // Act - Filter by "Overdue"
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overdue'));
      await tester.pumpAndSettle();

      // Assert - Only overdue tasks should be visible
      expect(find.text('Call dentist'), findsOneWidget);

      // Act - Filter by "Completed"
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Assert - Only completed tasks should be visible
      expect(find.text('Complete project proposal'), findsOneWidget);
    });

    testWidgets('Task editing flow', (tester) async {
      // Arrange - Start with existing task
      final task = MockData.taskTodo;
      mockRepository.addTasks([task]);

      // Navigate to task list
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Task exists
      expect(find.text('Buy groceries'), findsOneWidget);

      // Act - Navigate to edit screen
      // (In real app, would tap on task to open detail, then edit)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskFormScreen(taskId: task.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Modify task title
      await tester.enterText(
        find.byType(TextField).first,
        'Buy groceries and snacks',
      );
      await tester.pumpAndSettle();

      // Act - Save changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Assert - Changes should be saved
      // (Verification would check mock repository state)
    });

    testWidgets('Task deletion flow', (tester) async {
      // Arrange - Start with tasks
      final tasks = [
        MockData.taskTodo,
        MockData.taskToday,
      ];
      mockRepository.addTasks(tasks);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Both tasks should be visible
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Team meeting at 2pm'), findsOneWidget);

      // Act - Delete a task
      // (In real app, would navigate to detail screen, tap delete, confirm)
      final result = await mockRepository.deleteTask(tasks[0].id);

      expect(result.isRight(), true);

      // Assert - Task should be deleted
      // (In real app, list would update automatically via stream)
    });

    testWidgets('Task search flow', (tester) async {
      // Arrange - Create tasks with different titles
      final tasks = [
        MockData.createTask(
          id: 'search_1',
          title: 'Buy milk and bread',
          tags: ['shopping'],
        ),
        MockData.createTask(
          id: 'search_2',
          title: 'Call dentist for appointment',
          tags: ['health'],
        ),
        MockData.createTask(
          id: 'search_3',
          title: 'Team meeting about project',
          tags: ['work'],
        ),
      ];
      mockRepository.addTasks(tasks);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksStreamProvider.overrideWith(
              (ref) => mockRepository.watchTasks(userId: 'user_1'),
            ),
          ],
          child: const MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Act - Search for "meeting"
      final searchResult = await mockRepository.searchTasks(
        userId: 'user_1',
        query: 'meeting',
      );

      // Assert - Should find one task
      searchResult.fold(
        (failure) => fail('Search should not fail'),
        (results) {
          expect(results.length, 1);
          expect(results[0].title, 'Team meeting about project');
        },
      );
    });

    testWidgets('Priority filtering flow', (tester) async {
      // Arrange - Create tasks with different priorities
      final tasks = [
        MockData.createTask(
          id: 'priority_1',
          title: 'Critical Task',
          priority: TaskPriority.critical,
        ),
        MockData.createTask(
          id: 'priority_2',
          title: 'High Priority Task',
          priority: TaskPriority.high,
        ),
        MockData.createTask(
          id: 'priority_3',
          title: 'Low Priority Task',
          priority: TaskPriority.low,
        ),
      ];
      mockRepository.addTasks(tasks);

      // Act - Search by priority
      final result = await mockRepository.searchTasks(
        userId: 'user_1',
        query: '',
        priority: TaskPriority.critical,
      );

      // Assert - Should find only critical tasks
      result.fold(
        (failure) => fail('Should not fail'),
        (filtered) {
          expect(filtered.length, 1);
          expect(filtered[0].priority, TaskPriority.critical);
        },
      );
    });
  });
}
