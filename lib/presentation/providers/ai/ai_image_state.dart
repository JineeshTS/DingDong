import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/ai_extraction_result.dart';

part 'ai_image_state.freezed.dart';

/// AI Image Recognition State
@freezed
class AiImageState with _$AiImageState {
  const factory AiImageState({
    // Current extraction result
    AiExtractionResult? currentResult,

    // Loading state
    @Default(false) bool isExtracting,
    @Default(false) bool isCreatingTasks,

    // Selected tasks to create (indices)
    @Default([]) List<int> selectedTaskIndices,

    // Extraction mode
    @Default(ExtractionMode.auto) ExtractionMode mode,

    // Error
    String? error,

    // History of extractions
    @Default([]) List<AiExtractionResult> history,
  }) = _AiImageState;

  const AiImageState._();

  /// Has current result
  bool get hasResult => currentResult != null;

  /// Has tasks
  bool get hasTasks => currentResult?.hasTasks ?? false;

  /// Number of tasks
  int get taskCount => currentResult?.taskCount ?? 0;

  /// Selected tasks
  List<ParsedTask> get selectedTasks {
    if (currentResult == null) return [];
    return selectedTaskIndices
        .where((i) => i < currentResult!.parsedTasks.length)
        .map((i) => currentResult!.parsedTasks[i])
        .toList();
  }

  /// All tasks selected
  bool get allTasksSelected =>
      hasResult && selectedTaskIndices.length == taskCount;

  /// No tasks selected
  bool get noTasksSelected => selectedTaskIndices.isEmpty;

  /// Has error
  bool get hasError => error != null;

  /// Can create tasks
  bool get canCreateTasks => hasTasks && !isCreatingTasks && !noTasksSelected;
}
