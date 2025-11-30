import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_image_recognition_service.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/ai_extraction_result.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/create_task_usecase.dart';
import 'ai_image_state.dart';

/// AI Image Recognition Notifier
///
/// Manages state for the flagship AI image recognition feature
class AiImageNotifier extends StateNotifier<AiImageState> {
  final AiImageRecognitionService _aiService;
  final CreateTaskUseCase _createTaskUseCase;
  final _logger = Logger();

  AiImageNotifier({
    required AiImageRecognitionService aiService,
    required CreateTaskUseCase createTaskUseCase,
  })  : _aiService = aiService,
        _createTaskUseCase = createTaskUseCase,
        super(const AiImageState());

  /// Extract tasks from image
  Future<void> extractFromImage({
    required String imagePath,
    ExtractionMode? mode,
  }) async {
    try {
      _logger.info('Starting AI extraction from image');

      // Set loading state
      state = state.copyWith(
        isExtracting: true,
        error: null,
        currentResult: null,
        selectedTaskIndices: [],
      );

      // Extract tasks using AI service
      final result = await _aiService.extractTasksFromImage(
        imagePath: imagePath,
        mode: mode ?? state.mode,
      );

      _logger.info('AI extraction completed: ${result.taskCount} tasks found');

      // Select all tasks by default
      final allIndices = List.generate(result.taskCount, (i) => i);

      // Update state
      state = state.copyWith(
        isExtracting: false,
        currentResult: result,
        selectedTaskIndices: allIndices,
        history: [...state.history, result],
      );
    } catch (e, stackTrace) {
      _logger.error('AI extraction failed', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isExtracting: false,
        error: 'Failed to extract tasks from image: ${e.toString()}',
      );
    }
  }

  /// Toggle task selection
  void toggleTaskSelection(int index) {
    final selected = [...state.selectedTaskIndices];

    if (selected.contains(index)) {
      selected.remove(index);
    } else {
      selected.add(index);
    }

    state = state.copyWith(selectedTaskIndices: selected);
  }

  /// Select all tasks
  void selectAllTasks() {
    if (!state.hasResult) return;

    final allIndices = List.generate(state.taskCount, (i) => i);
    state = state.copyWith(selectedTaskIndices: allIndices);
  }

  /// Deselect all tasks
  void deselectAllTasks() {
    state = state.copyWith(selectedTaskIndices: []);
  }

  /// Update task at index
  void updateTaskAtIndex(int index, ParsedTask updatedTask) {
    if (!state.hasResult) return;

    final tasks = [...state.currentResult!.parsedTasks];
    if (index < tasks.length) {
      tasks[index] = updatedTask;

      state = state.copyWith(
        currentResult: state.currentResult!.copyWith(
          parsedTasks: tasks,
        ),
      );
    }
  }

  /// Create tasks from selected parsed tasks
  Future<int> createTasksFromSelected({
    String? listId,
  }) async {
    if (!state.canCreateTasks) return 0;

    try {
      _logger.info('Creating ${state.selectedTasks.length} tasks from AI extraction');

      state = state.copyWith(
        isCreatingTasks: true,
        error: null,
      );

      int successCount = 0;

      for (final parsedTask in state.selectedTasks) {
        // Convert ParsedTask to TaskEntity
        final task = TaskEntity(
          id: '', // Will be generated
          title: parsedTask.title,
          description: parsedTask.description,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueDate: parsedTask.dueDate,
          priority: parsedTask.priority,
          tags: parsedTask.tags,
          listId: listId,
        );

        // Create task using use case
        final result = await _createTaskUseCase(task);

        result.fold(
          (failure) {
            _logger.error('Failed to create task: ${parsedTask.title}');
          },
          (createdTask) {
            _logger.info('Created task: ${createdTask.title}');
            successCount++;
          },
        );
      }

      _logger.info('Successfully created $successCount/${state.selectedTasks.length} tasks');

      // Clear selection after successful creation
      state = state.copyWith(
        isCreatingTasks: false,
        selectedTaskIndices: [],
      );

      return successCount;
    } catch (e, stackTrace) {
      _logger.error('Failed to create tasks', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isCreatingTasks: false,
        error: 'Failed to create tasks: ${e.toString()}',
      );

      return 0;
    }
  }

  /// Change extraction mode
  void setExtractionMode(ExtractionMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Clear current result
  void clearCurrentResult() {
    state = state.copyWith(
      currentResult: null,
      selectedTaskIndices: [],
      error: null,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear history
  void clearHistory() {
    state = state.copyWith(history: []);
  }

  /// Get result from history
  void loadResultFromHistory(String id) {
    final result = state.history.firstWhere(
      (r) => r.id == id,
      orElse: () => state.history.first,
    );

    final allIndices = List.generate(result.taskCount, (i) => i);

    state = state.copyWith(
      currentResult: result,
      selectedTaskIndices: allIndices,
    );
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
