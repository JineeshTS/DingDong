/// Habit providers module
///
/// Exports all habit-related providers, state, and notifiers.
///
/// This module provides comprehensive habit management functionality including:
/// - Habit CRUD operations (Create, Read, Update, Delete)
/// - Habit check-in system with streak tracking
/// - Habit frequency management (daily, weekly, monthly, custom)
/// - Habit categories and templates
/// - Habit statistics and completion rate analytics
/// - Archive and soft delete functionality
/// - Real-time habit updates
/// - Derived providers for common queries
///
/// ## Architecture
///
/// The habit providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`HabitState`)
/// - **Notifier**: Business logic and state updates (`HabitNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (10 habit use cases)
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/habit/habit.dart';
///
/// class HabitListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch active habits
///     final habits = ref.watch(activeHabitsProvider);
///     final todayHabits = ref.watch(habitsDueTodayProvider);
///     final isLoading = ref.watch(isLoadingTodayProvider);
///
///     // Get notifier for actions
///     final habitNotifier = ref.read(habitNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         Text('Habits due today: ${todayHabits.length}'),
///         if (isLoading)
///           CircularProgressIndicator()
///         else
///           ListView.builder(
///             itemCount: todayHabits.length,
///             itemBuilder: (context, index) {
///               final habit = todayHabits[index];
///               return HabitTile(
///                 habit: habit,
///                 onCheckIn: () => habitNotifier.checkInHabit(habitId: habit.id),
///                 onDelete: () => habitNotifier.deleteHabit(habit.id),
///               );
///             },
///           ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `habitNotifierProvider` - Main habit state and notifier
///
/// ### Habit List Providers
/// - `activeHabitsProvider` - Active (non-archived) habits
/// - `archivedHabitsProvider` - Archived habits
/// - `allHabitsProvider` - All habits (active and archived)
/// - `habitsDueTodayProvider` - Habits scheduled for today
/// - `habitsByCategoryProvider` - Habits grouped by category
/// - `habitSearchResultsProvider` - Search results
/// - `selectedHabitProvider` - Currently selected habit
///
/// ### Habit Statistics Providers
/// - `habitStreaksProvider` - Map of habit streaks
/// - `habitStatisticsProvider` - Map of habit statistics
/// - `habitStatisticsByIdProvider` - Statistics for specific habit
/// - `habitStreakByIdProvider` - Current streak for specific habit
/// - `averageCompletionRateProvider` - Overall completion rate
///
/// ### Count Providers
/// - `activeHabitCountProvider` - Count of active habits
/// - `archivedHabitCountProvider` - Count of archived habits
/// - `totalHabitCountProvider` - Total habit count
/// - `habitsDueTodayCountProvider` - Count of habits due today
/// - `completedTodayCountProvider` - Count of completed today habits
/// - `incompleteTodayCountProvider` - Count of incomplete today habits
///
/// ### Loading State Providers
/// - `isLoadingAllProvider` - Loading state for all habits
/// - `isLoadingTodayProvider` - Loading state for today's habits
/// - `isLoadingStatisticsProvider` - Loading state for statistics
/// - `isAnyHabitLoadingProvider` - Any habit list loading
/// - `isAnyHabitOperationInProgressProvider` - Habit operation in progress
/// - `isCreatingHabitProvider` - Create operation in progress
/// - `isUpdatingHabitProvider` - Update operation in progress
/// - `isCheckingInHabitProvider` - Check-in operation in progress
///
/// ### Error Providers
/// - `habitOperationErrorProvider` - Operation errors
/// - `habitTodayErrorProvider` - Today habits errors
/// - `habitStatisticsErrorProvider` - Statistics errors
/// - `hasAnyHabitErrorProvider` - Any error state
///
/// ### Filter Providers
/// - `currentCategoryFilterProvider` - Current category filter
/// - `currentFrequencyFilterProvider` - Current frequency filter
/// - `currentSearchQueryProvider` - Current search query
/// - `habitsByCategoryFilterProvider` - Habits filtered by category
/// - `habitsByFrequencyProvider` - Habits filtered by frequency
///
/// ### Analytics Providers
/// - `habitsWithStreakProvider` - Habits with minimum streak
/// - `completedTodayHabitsProvider` - Completed habits today
/// - `incompleteTodayHabitsProvider` - Incomplete habits today
/// - `todayCompletionPercentageProvider` - Today's completion %
/// - `mostConsistentHabitsProvider` - Habits with highest streaks
/// - `habitsAtRiskProvider` - Habits at risk (long time since check-in)
///
/// ### Refresh State Providers
/// - `needsRefreshAllHabitsProvider` - All habits need refresh
/// - `needsRefreshTodayHabitsProvider` - Today habits need refresh
/// - `needsRefreshStatisticsProvider` - Statistics need refresh
///
/// ### Use Case Providers (10 total)
/// - `createHabitProvider` - Create habit use case
/// - `updateHabitProvider` - Update habit use case
/// - `deleteHabitProvider` - Delete habit use case (soft delete)
/// - `getHabitsProvider` - Get habits use case (with category filter)
/// - `checkInHabitProvider` - Check-in habit use case
/// - `undoCheckInProvider` - Undo check-in use case
/// - `calculateStreakProvider` - Calculate streak use case
/// - `getHabitsDueTodayProvider` - Get habits due today use case
/// - `getHabitStatisticsProvider` - Get habit statistics use case
/// - `archiveHabitProvider` - Archive habit use case
///
/// ## Best Practices
///
/// ### Frequency Management
/// ```dart
/// // Create a daily habit
/// final dailyHabit = HabitEntity(
///   name: 'Morning Exercise',
///   frequency: HabitFrequency.daily,
///   targetCount: 1,
/// );
///
/// // Create a weekly habit (3 days per week)
/// final weeklyHabit = HabitEntity(
///   name: 'Meditation',
///   frequency: HabitFrequency.weekly,
///   targetDaysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
///   targetCount: 3,
/// );
/// ```
///
/// ### Watch vs Read
/// - Use `ref.watch()` to rebuild on state changes
/// - Use `ref.read()` for one-time actions/callbacks
///
/// ### Error Handling
/// ```dart
/// ref.listen(habitOperationErrorProvider, (previous, next) {
///   if (next != null) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text(next)),
///     );
///   }
/// });
/// ```
///
/// ### Check-in Management
/// ```dart
/// final habitNotifier = ref.read(habitNotifierProvider.notifier);
///
/// // Check in today
/// await habitNotifier.checkInHabit(habitId: 'habit-123');
///
/// // Check in for a past date
/// await habitNotifier.checkInHabit(
///   habitId: 'habit-123',
///   date: DateTime.now().subtract(Duration(days: 1)),
///   note: 'Made up for yesterday',
/// );
///
/// // Undo a check-in
/// await habitNotifier.undoCheckIn(habitId: 'habit-123');
/// ```
///
/// ### Streak Tracking
/// ```dart
/// final streaks = ref.watch(habitStreaksProvider);
/// final habit7PlusDayStreaks = ref.watch(habitsWithStreakProvider(7));
/// final mostConsistent = ref.watch(mostConsistentHabitsProvider);
/// ```
///
/// ### Statistics
/// ```dart
/// await habitNotifier.loadHabitStatistics(habitId: 'habit-123');
/// final stats = ref.watch(habitStatisticsByIdProvider('habit-123'));
/// if (stats != null) {
///   print('Completion: ${stats['completionRate']}%');
///   print('Current: ${stats['currentStreak']} days');
///   print('Best: ${stats['longestStreak']} days');
/// }
/// ```
///
/// ### Offline Support
/// - Check refresh timestamps before updating
/// - Implement pull-to-refresh functionality
/// - Handle network failures gracefully
///
/// ## Frequency Types
///
/// - **Daily**: Habit repeated every day
/// - **Weekly**: Habit repeated on specific days of week (1-7)
/// - **Monthly**: Habit repeated monthly
/// - **Custom**: Custom repeat pattern
///
/// ## Categories
///
/// - Health & Fitness
/// - Personal Development
/// - Work & Productivity
/// - Finance & Savings
/// - Social & Relationships
/// - Mindfulness & Mental Health
/// - Hobbies & Interests
/// - Custom
///
export 'habit_notifier.dart';
export 'habit_providers.dart';
export 'habit_state.dart';
