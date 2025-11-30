/// Focus/Today view providers module
///
/// Exports all Focus/Today view-related providers, state, and notifiers.
///
/// This module provides Focus/Today view functionality including:
/// - Today's tasks and overdue tasks
/// - Smart "What's Next" suggestions
/// - Time block organization
/// - Morning planning and evening review prompts
/// - Completion tracking and statistics
///
/// ## The Focus/Today View
///
/// The Focus/Today view helps you concentrate on what matters most today by:
///
/// 1. **Today's Tasks**: All tasks due today, organized chronologically
/// 2. **Overdue Tasks**: Tasks that should have been completed earlier
/// 3. **Smart Suggestions**: AI-powered "What's Next" recommendations
/// 4. **Time Blocks**: Morning, afternoon, evening, night organization
/// 5. **Progress Tracking**: Real-time completion percentage
/// 6. **Prompts**: Morning planning and evening review reminders
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/focus/focus.dart';
///
/// class FocusScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch Focus state
///     final focusState = ref.watch(focusNotifierProvider);
///
///     // Get today's tasks
///     final todayTasks = ref.watch(todayTasksProvider);
///
///     // Get next suggested task
///     final nextTask = ref.watch(nextSuggestedTaskProvider);
///
///     // Get greeting
///     final greeting = ref.watch(focusGreetingProvider);
///
///     return Column(
///       children: [
///         Text(greeting),
///         if (nextTask != null)
///           NextTaskCard(task: nextTask),
///         TaskList(tasks: todayTasks),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `focusNotifierProvider` - Main Focus state and notifier
///
/// ### Task Providers
/// - `todayTasksProvider` - Tasks due today
/// - `overdueTasksProvider` - Overdue tasks
/// - `completedTasksTodayProvider` - Tasks completed today
/// - `allIncompleteTasksProvider` - All incomplete tasks (overdue + today)
/// - `nextSuggestedTaskProvider` - Smart "What's Next" suggestion
///
/// ### View State Providers
/// - `focusViewModeProvider` - Current view mode (timeline/list)
/// - `focusShowCompletedTasksProvider` - Show completed tasks setting
/// - `focusGreetingProvider` - Time-based greeting message
/// - `showMorningPromptProvider` - Morning planning prompt visibility
/// - `showEveningPromptProvider` - Evening review prompt visibility
///
/// ### Loading & Error Providers
/// - `isFocusLoadingProvider` - Loading state
/// - `focusErrorProvider` - Error message
///
/// ### Statistics Providers
/// - `focusTotalTasksCountProvider` - Total tasks for today
/// - `focusIncompleteTasksCountProvider` - Incomplete tasks count
/// - `focusCompletedTasksCountProvider` - Completed tasks count today
/// - `focusCompletionPercentageProvider` - Completion percentage (0-100)
/// - `overdueTasksCountProvider` - Overdue tasks count
///
/// ### Time of Day Providers (Family)
/// - `tasksForTimeOfDayProvider` - Tasks for specific time (morning/afternoon/evening/night)
/// - `taskCountForTimeOfDayProvider` - Task count for specific time
///
export 'focus_notifier.dart';
export 'focus_providers.dart';
export 'focus_state.dart';
