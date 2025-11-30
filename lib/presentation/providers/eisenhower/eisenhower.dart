/// Eisenhower Matrix providers module
///
/// Exports all Eisenhower Matrix-related providers, state, and notifiers.
///
/// This module provides Eisenhower Matrix functionality including:
/// - Task categorization by urgency and importance
/// - 2×2 matrix quadrant organization
/// - Auto-categorization logic
/// - Focus mode for individual quadrants
/// - Task filtering
///
/// ## The Eisenhower Matrix
///
/// The Eisenhower Matrix (also called Urgent-Important Matrix) helps prioritize
/// tasks by categorizing them into four quadrants:
///
/// 1. **Urgent & Important** (Do First): Tasks requiring immediate attention
/// 2. **Not Urgent & Important** (Schedule): Important long-term goals
/// 3. **Urgent & Not Important** (Delegate): Tasks that could be delegated
/// 4. **Not Urgent & Not Important** (Eliminate): Low-value tasks to minimize
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/eisenhower/eisenhower.dart';
///
/// class EisenhowerScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch Eisenhower state
///     final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
///
///     // Get tasks for a specific quadrant
///     final urgentImportantTasks = ref.watch(
///       tasksInQuadrantProvider(MatrixQuadrant.urgentImportant),
///     );
///
///     // Get notifier for actions
///     final eisenhowerNotifier = ref.read(eisenhowerNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         // Display matrix quadrants
///         for (final quadrant in MatrixQuadrant.values)
///           MatrixQuadrantWidget(
///             quadrant: quadrant,
///             onTap: () => eisenhowerNotifier.setFocusQuadrant(quadrant),
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
/// - `eisenhowerNotifierProvider` - Main Eisenhower state and notifier
///
/// ### View State Providers
/// - `eisenhowerFocusQuadrantProvider` - Current focus quadrant
/// - `eisenhowerShowCompletedTasksProvider` - Show completed tasks setting
/// - `eisenhowerAutoCategorization` - Auto-categorization enabled
/// - `eisenhowerSelectedListProvider` - Selected list filter
/// - `isEisenhowerFocusModeProvider` - Focus mode state
///
/// ### Quadrant Providers (Family)
/// - `tasksInQuadrantProvider` - Get tasks for a specific quadrant
/// - `quadrantTaskCountProvider` - Task count for quadrant
/// - `quadrantIncompleteCountProvider` - Incomplete tasks count for quadrant
///
/// ### Loading & Error Providers
/// - `isEisenhowerLoadingProvider` - Loading state
/// - `eisenhowerErrorProvider` - Error message
///
/// ### Statistics Providers
/// - `eisenhowerTotalTasksCountProvider` - Total tasks across all quadrants
/// - `eisenhowerCompletedTasksCountProvider` - Completed tasks count
/// - `eisenhowerIncompleteTasksCountProvider` - Incomplete tasks count
/// - `urgentImportantCountProvider` - Q1 tasks count
/// - `notUrgentImportantCountProvider` - Q2 tasks count
/// - `urgentNotImportantCountProvider` - Q3 tasks count
/// - `notUrgentNotImportantCountProvider` - Q4 tasks count
///
export 'eisenhower_notifier.dart';
export 'eisenhower_providers.dart';
export 'eisenhower_state.dart';
