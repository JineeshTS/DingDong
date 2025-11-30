# Testing Infrastructure

Comprehensive testing infrastructure for the DingDong task management application.

## Directory Structure

```
test/
├── fixtures/           # Mock data and test fixtures
│   └── mock_data.dart  # Predefined test data for entities
├── helpers/            # Test helper utilities
│   └── test_helpers.dart  # Common test utilities and matchers
├── mocks/              # Mock implementations
│   └── mock_task_repository.dart  # Mock repository for testing
├── unit/               # Unit tests
│   ├── usecases/       # Use case tests
│   └── repositories/   # Repository tests
├── widget/             # Widget tests
│   ├── components/     # UI component tests
│   └── screens/        # Screen widget tests
└── integration/        # Integration tests
    └── task_management_flow_test.dart  # End-to-end flow tests
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/usecases/create_task_usecase_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Run Tests by Type

#### Unit Tests Only
```bash
flutter test test/unit/
```

#### Widget Tests Only
```bash
flutter test test/widget/
```

#### Integration Tests Only
```bash
flutter test test/integration/
```

## Writing Tests

### Unit Tests

Unit tests focus on testing individual use cases and business logic in isolation.

```dart
import 'package:flutter_test/flutter_test.dart';
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
      final task = MockData.createTask(title: 'Test Task');
      mockRepository.setShouldFail(false);

      // Act
      final result = await usecase.call(CreateTaskParams(task: task));

      // Assert
      expect(result.isRight(), true);
    });
  });
}
```

### Widget Tests

Widget tests verify UI component behavior and user interactions.

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/presentation/common/widgets/widgets.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('should render button with text', (tester) async {
      // Arrange & Act
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () {},
          child: const Text('Click Me'),
        ),
      );

      // Assert
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool wasPressed = false;
      await TestHelpers.pumpMaterialApp(
        tester,
        child: AppButton(
          onPressed: () => wasPressed = true,
          child: const Text('Tap Me'),
        ),
      );

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });
  });
}
```

### Integration Tests

Integration tests verify complete user flows across multiple screens and components.

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../lib/presentation/screens/tasks/task_list_screen.dart';
import '../fixtures/mock_data.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_task_repository.dart';

void main() {
  group('Task Management Integration Tests', () {
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    testWidgets('Complete task creation flow', (tester) async {
      // Test entire flow from empty state to task created
    });
  });
}
```

## Test Utilities

### Mock Data (fixtures/mock_data.dart)

Provides predefined test data for entities:

```dart
// Get mock tasks
final tasks = MockData.getAllTasks();
final todayTasks = MockData.getTodayTasks();
final overdueTasks = MockData.getOverdueTasks();

// Create custom task
final customTask = MockData.createTask(
  title: 'Custom Task',
  priority: TaskPriority.high,
  tags: ['test'],
);

// Use TaskBuilder for fluent task creation
final task = TaskBuilder()
  .withTitle('Test Task')
  .withPriority(TaskPriority.high)
  .asOverdue()
  .build();
```

### Test Helpers (helpers/test_helpers.dart)

Common testing utilities:

```dart
// Pump widgets with providers
await TestHelpers.pumpProviderScope(tester, child: widget);
await TestHelpers.pumpMaterialApp(tester, child: widget);

// Find widgets
TestHelpers.findText('Hello');
TestHelpers.findIcon(Icons.add);
TestHelpers.findWidgetByType<AppButton>();

// Interactions
await TestHelpers.tapWidget(tester, finder);
await TestHelpers.enterText(tester, finder, 'text');
await TestHelpers.tapButtonByText(tester, 'Submit');

// Assertions
TestHelpers.expectWidgetExists<AppButton>();
TestHelpers.expectTextExists('Hello');
TestHelpers.expectLoadingIndicator();
TestHelpers.expectSnackBarWithText('Success');

// Custom matchers
expect(result, CustomMatchers.isRight());
expect(date, CustomMatchers.isSameDate(DateTime.now()));
expect(list, CustomMatchers.hasLength(5));
```

### Mock Repositories (mocks/)

Mock implementations for testing:

```dart
final mockRepository = MockTaskRepository();

// Add test data
mockRepository.addTasks([task1, task2]);

// Configure to fail
mockRepository.setShouldFail(true, failure: CacheFailure('Error'));

// Reset state
mockRepository.reset();

// Use in tests
final result = await mockRepository.createTask(task);
final stream = mockRepository.watchTasks(userId: 'user_1');
```

## Testing Best Practices

### 1. Test Organization
- **Group Related Tests**: Use `group()` to organize related test cases
- **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
- **AAA Pattern**: Follow Arrange-Act-Assert pattern for clarity

### 2. Test Isolation
- **setUp/tearDown**: Use setUp() and tearDown() to ensure test isolation
- **Reset Mocks**: Always reset mock state between tests
- **Independent Tests**: Each test should be independent and runnable alone

### 3. Coverage Goals
- **Unit Tests**: Aim for 80%+ coverage of use cases and business logic
- **Widget Tests**: Cover all critical UI components and user interactions
- **Integration Tests**: Cover main user flows and critical paths

### 4. Naming Conventions
- Unit test files: `*_usecase_test.dart`, `*_repository_test.dart`
- Widget test files: `*_test.dart` for components, `*_screen_test.dart` for screens
- Integration test files: `*_flow_test.dart`

### 5. Async Testing
- Always use `async` and `await` properly
- Use `pumpAndSettle()` to wait for all animations
- Use `pump()` with duration for specific timing

### 6. Provider Testing
- Use `ProviderScope` with `overrides` to mock providers
- Test both data and error states
- Test loading states where applicable

### 7. Performance
- Keep tests fast - unit tests should run in milliseconds
- Use `skip: true` for slow or flaky tests temporarily
- Run tests in parallel when possible

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## Debugging Tests

### Run Tests in Debug Mode
```bash
flutter test --debug
```

### Print Debug Information
```dart
debugPrint('Current state: $state');
```

### Visual Debugging
```dart
await tester.pumpAndSettle();
await tester.pump(Duration(seconds: 10)); // Pause to inspect
```

## Common Issues

### Issue: Widget not found
- **Solution**: Ensure widget is rendered with `pumpAndSettle()`
- Check if widget is behind navigation or modals

### Issue: Async test timeout
- **Solution**: Increase timeout or fix slow operations
- Use `testWidgets(timeout: Timeout(Duration(seconds: 30)))`

### Issue: Provider not overridden
- **Solution**: Wrap widget in `ProviderScope` with correct overrides
- Verify provider is being watched, not just read

### Issue: Navigation tests fail
- **Solution**: Set up full router with `MaterialApp.router`
- Or use `MockGoRouter` for isolated testing

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing Guide](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)

## Test Coverage Report

Generate and view coverage reports:

```bash
# Generate coverage
flutter test --coverage

# Convert to HTML
genhtml coverage/lcov.info -o coverage/html

# View in browser
open coverage/html/index.html
```

Target Coverage:
- **Overall**: 70%+
- **Use Cases**: 80%+
- **Repositories**: 75%+
- **UI Components**: 60%+
- **Critical Flows**: 90%+

---

For questions or issues with testing, please refer to the main project documentation or open an issue on GitHub.
