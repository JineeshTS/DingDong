import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/ai_image_recognition_service.dart';
import '../../../domain/entities/ai_extraction_result.dart';
import 'ai_image_notifier.dart';
import 'ai_image_state.dart';

/// AI Image Recognition Service Provider
final aiImageServiceProvider = Provider<AiImageRecognitionService>((ref) {
  return AiImageRecognitionService();
});

/// AI Image Recognition State Notifier Provider
final aiImageNotifierProvider =
    StateNotifierProvider<AiImageNotifier, AiImageState>((ref) {
  return AiImageNotifier(
    aiService: ref.watch(aiImageServiceProvider),
    createTaskUseCase: getIt(),
  );
});

/// Current extraction result provider
final currentExtractionResultProvider = Provider<AiExtractionResult?>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.currentResult));
});

/// Has result provider
final hasExtractionResultProvider = Provider<bool>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.hasResult));
});

/// Is extracting provider
final isExtractingProvider = Provider<bool>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.isExtracting));
});

/// Is creating tasks provider
final isCreatingTasksProvider = Provider<bool>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.isCreatingTasks));
});

/// Task count provider
final extractedTaskCountProvider = Provider<int>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.taskCount));
});

/// Selected task indices provider
final selectedTaskIndicesProvider = Provider<List<int>>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.selectedTaskIndices));
});

/// Selected tasks provider
final selectedTasksProvider = Provider<List<ParsedTask>>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.selectedTasks));
});

/// All tasks selected provider
final allTasksSelectedProvider = Provider<bool>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.allTasksSelected));
});

/// Can create tasks provider
final canCreateTasksProvider = Provider<bool>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.canCreateTasks));
});

/// Extraction mode provider
final extractionModeProvider = Provider<ExtractionMode>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.mode));
});

/// AI error provider
final aiErrorProvider = Provider<String?>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.error));
});

/// Extraction history provider
final extractionHistoryProvider = Provider<List<AiExtractionResult>>((ref) {
  return ref.watch(aiImageNotifierProvider.select((s) => s.history));
});

/// History count provider
final historyCountProvider = Provider<int>((ref) {
  return ref.watch(extractionHistoryProvider.select((h) => h.length));
});

/// Parsed task by index provider (family)
final parsedTaskByIndexProvider =
    Provider.family<ParsedTask?, int>((ref, index) {
  final result = ref.watch(currentExtractionResultProvider);
  if (result == null || index >= result.parsedTasks.length) {
    return null;
  }
  return result.parsedTasks[index];
});

/// Is task selected provider (family)
final isTaskSelectedProvider = Provider.family<bool, int>((ref, index) {
  final selected = ref.watch(selectedTaskIndicesProvider);
  return selected.contains(index);
});

/// Confidence level provider
final confidenceLevelProvider = Provider<ConfidenceLevel>((ref) {
  final result = ref.watch(currentExtractionResultProvider);
  if (result == null) return ConfidenceLevel.none;

  if (result.isHighConfidence) return ConfidenceLevel.high;
  if (result.isMediumConfidence) return ConfidenceLevel.medium;
  if (result.isLowConfidence) return ConfidenceLevel.low;
  return ConfidenceLevel.none;
});

/// Confidence level enum
enum ConfidenceLevel {
  none,
  low,
  medium,
  high,
}

/// Extension for confidence level
extension ConfidenceLevelX on ConfidenceLevel {
  String get displayName {
    switch (this) {
      case ConfidenceLevel.none:
        return 'No Data';
      case ConfidenceLevel.low:
        return 'Low Confidence';
      case ConfidenceLevel.medium:
        return 'Medium Confidence';
      case ConfidenceLevel.high:
        return 'High Confidence';
    }
  }

  String get description {
    switch (this) {
      case ConfidenceLevel.none:
        return 'No extraction performed yet';
      case ConfidenceLevel.low:
        return 'Please review and edit the extracted tasks carefully';
      case ConfidenceLevel.medium:
        return 'Extraction looks good, but please verify';
      case ConfidenceLevel.high:
        return 'High confidence in the extracted tasks';
    }
  }
}
