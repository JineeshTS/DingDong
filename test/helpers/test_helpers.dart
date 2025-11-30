import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers and utilities for DingDong tests
class TestHelpers {
  /// Pump a widget wrapped with ProviderScope for Riverpod testing
  ///
  /// Usage:
  /// ```dart
  /// await tester.pumpProviderScope(
  ///   child: MyWidget(),
  ///   overrides: [myProvider.overrideWith((ref) => mockValue)],
  /// );
  /// ```
  static Future<void> pumpProviderScope(
    WidgetTester tester, {
    required Widget child,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  /// Pump a widget wrapped with MaterialApp for theme and routing testing
  ///
  /// Usage:
  /// ```dart
  /// await tester.pumpMaterialApp(child: MyWidget());
  /// ```
  static Future<void> pumpMaterialApp(
    WidgetTester tester, {
    required Widget child,
    ThemeData? theme,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: theme,
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  /// Pump and settle a widget (waits for all animations)
  static Future<void> pumpAndSettleProviderScope(
    WidgetTester tester, {
    required Widget child,
    List<Override> overrides = const [],
  }) async {
    await pumpProviderScope(tester, child: child, overrides: overrides);
    await tester.pumpAndSettle();
  }

  /// Find a widget by type
  static Finder findWidgetByType<T extends Widget>() {
    return find.byType(T);
  }

  /// Find a widget by key
  static Finder findWidgetByKey(Key key) {
    return find.byKey(key);
  }

  /// Find text widget
  static Finder findText(String text) {
    return find.text(text);
  }

  /// Find text containing substring
  static Finder findTextContaining(String substring) {
    return find.text(substring, findRichText: true);
  }

  /// Find icon by icon data
  static Finder findIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Verify widget exists
  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Verify widget does not exist
  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  /// Verify text exists
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify text does not exist
  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Tap a widget by finder
  static Future<void> tapWidget(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  /// Tap a button by text
  static Future<void> tapButtonByText(
      WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
  }

  /// Enter text into a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Scroll until visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester, {
    required Finder itemFinder,
    required Finder scrollableFinder,
    double scrollDelta = 100,
  }) async {
    await tester.scrollUntilVisible(
      itemFinder,
      scrollDelta,
      scrollable: scrollableFinder,
    );
  }

  /// Drag a widget
  static Future<void> drag(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Long press a widget
  static Future<void> longPress(WidgetTester tester, Finder finder) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  /// Verify that a snackbar is shown with specific text
  static void expectSnackBarWithText(String text) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(text), findsOneWidget);
  }

  /// Verify that a dialog is shown
  static void expectDialog() {
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  /// Verify loading indicator is shown
  static void expectLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verify loading indicator is not shown
  static void expectNoLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  /// Wait for a specific duration (use sparingly, prefer pumpAndSettle)
  static Future<void> wait(WidgetTester tester, Duration duration) async {
    await tester.pump(duration);
  }

  /// Pump frames for animations
  static Future<void> pumpFrames(
    WidgetTester tester, {
    int frames = 10,
    Duration duration = const Duration(milliseconds: 16),
  }) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump(duration);
    }
  }
}

/// Custom matchers for tests
class CustomMatchers {
  /// Matcher for Right value in Either
  static Matcher isRight() => const TypeMatcher<Right>();

  /// Matcher for Left value in Either
  static Matcher isLeft() => const TypeMatcher<Left>();

  /// Matcher for specific failure type
  static Matcher isFailureOfType<T>() => isA<T>();

  /// Matcher for date equality (ignoring time)
  static Matcher isSameDate(DateTime date) => predicate<DateTime>(
        (actual) =>
            actual.year == date.year &&
            actual.month == date.month &&
            actual.day == date.day,
        'is same date as $date',
      );

  /// Matcher for date range
  static Matcher isDateBetween(DateTime start, DateTime end) =>
      predicate<DateTime>(
        (actual) => actual.isAfter(start) && actual.isBefore(end),
        'is between $start and $end',
      );

  /// Matcher for list containing specific item
  static Matcher containsItem<T>(T item) => predicate<List<T>>(
        (list) => list.contains(item),
        'contains $item',
      );

  /// Matcher for empty list
  static Matcher isEmptyList() => predicate<List>(
        (list) => list.isEmpty,
        'is empty list',
      );

  /// Matcher for non-empty list
  static Matcher isNonEmptyList() => predicate<List>(
        (list) => list.isNotEmpty,
        'is non-empty list',
      );

  /// Matcher for list of specific length
  static Matcher hasLength(int length) => predicate<List>(
        (list) => list.length == length,
        'has length $length',
      );
}

/// Test data builders for fluent test data creation
class TaskBuilder {
  String _id = 'test_task_id';
  String _title = 'Test Task';
  String? _description;
  String _userId = 'test_user_id';
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  List<String> _tags = [];
  DateTime? _dueDate;
  DateTime? _completedAt;
  String? _parentTaskId;
  String? _listId;

  TaskBuilder withId(String id) {
    _id = id;
    return this;
  }

  TaskBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  TaskBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  TaskBuilder withUserId(String userId) {
    _userId = userId;
    return this;
  }

  TaskBuilder withStatus(TaskStatus status) {
    _status = status;
    return this;
  }

  TaskBuilder withPriority(TaskPriority priority) {
    _priority = priority;
    return this;
  }

  TaskBuilder withTags(List<String> tags) {
    _tags = tags;
    return this;
  }

  TaskBuilder withDueDate(DateTime dueDate) {
    _dueDate = dueDate;
    return this;
  }

  TaskBuilder withCompletedAt(DateTime completedAt) {
    _completedAt = completedAt;
    return this;
  }

  TaskBuilder withParentTaskId(String parentTaskId) {
    _parentTaskId = parentTaskId;
    return this;
  }

  TaskBuilder withListId(String listId) {
    _listId = listId;
    return this;
  }

  TaskBuilder asCompleted() {
    _status = TaskStatus.completed;
    _completedAt = DateTime.now();
    return this;
  }

  TaskBuilder asCritical() {
    _priority = TaskPriority.critical;
    return this;
  }

  TaskBuilder asOverdue() {
    _dueDate = DateTime.now().subtract(const Duration(days: 1));
    return this;
  }

  TaskBuilder asDueToday() {
    _dueDate = DateTime.now();
    return this;
  }

  TaskEntity build() {
    return TaskEntity(
      id: _id,
      title: _title,
      description: _description,
      userId: _userId,
      status: _status,
      priority: _priority,
      tags: _tags,
      dueDate: _dueDate,
      completedAt: _completedAt,
      parentTaskId: _parentTaskId,
      categoryId: _listId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sortOrder: 0,
    );
  }
}
