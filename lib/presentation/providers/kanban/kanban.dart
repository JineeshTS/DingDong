/// Kanban board providers module
///
/// Exports all Kanban board-related providers, state, and notifiers.
///
/// This module provides Kanban board functionality including:
/// - Column-based task organization
/// - Drag-and-drop task movement
/// - WIP (Work In Progress) limits
/// - Swimlanes and grouping
/// - Task filtering
/// - Board customization
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/kanban/kanban.dart';
///
/// class KanbanScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch Kanban state
///     final kanbanState = ref.watch(kanbanNotifierProvider);
///     final columns = ref.watch(visibleKanbanColumnsProvider);
///
///     // Get notifier for actions
///     final kanbanNotifier = ref.read(kanbanNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         // Display board columns
///         for (final column in columns)
///           KanbanColumn(
///             column: column,
///             onTaskMoved: (task, toColumnId) async {
///               await kanbanNotifier.moveTask(
///                 task,
///                 column.id,
///                 toColumnId,
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
/// - `kanbanNotifierProvider` - Main Kanban state and notifier
///
/// ### View State Providers
/// - `kanbanViewModeProvider` - Current view mode (columns/swimlanes)
/// - `kanbanColumnsProvider` - All board columns
/// - `visibleKanbanColumnsProvider` - Visible columns only
/// - `kanbanShowCompletedTasksProvider` - Show completed tasks setting
/// - `kanbanSelectedListProvider` - Selected list filter
///
/// ### Column Providers (Family)
/// - `kanbanColumnProvider` - Get column by ID
/// - `tasksInColumnProvider` - Tasks in a specific column
/// - `isColumnAtWipLimitProvider` - Check if column is at WIP limit
/// - `columnTaskCountProvider` - Task count for column
/// - `columnIncompleteCountProvider` - Incomplete tasks count for column
///
/// ### Loading & Error Providers
/// - `isKanbanLoadingProvider` - Loading state
/// - `kanbanErrorProvider` - Error message
///
/// ### Statistics Providers
/// - `kanbanTotalTasksCountProvider` - Total tasks across all columns
/// - `kanbanCompletedTasksCountProvider` - Completed tasks count
/// - `kanbanIncompleteTasksCountProvider` - Incomplete tasks count
/// - `hasWipLimitReachedProvider` - Check if any column is at WIP limit
/// - `kanbanActiveFiltersCountProvider` - Count of active filters
///
export 'kanban_notifier.dart';
export 'kanban_providers.dart';
export 'kanban_state.dart';
