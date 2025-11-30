import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task_template_entity.dart';
import 'template_notifier.dart';
import 'template_state.dart';

/// Main template notifier provider
final templateNotifierProvider =
    StateNotifierProvider<TemplateNotifier, TemplateState>(
  (ref) => TemplateNotifier(),
);

/// Provider for all templates
final allTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.templates;
});

/// Provider for user templates
final userTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.userTemplates;
});

/// Provider for predefined templates
final predefinedTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.predefinedTemplates;
});

/// Provider for public/community templates
final publicTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.publicTemplates;
});

/// Provider for filtered templates
final filteredTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.filteredTemplates;
});

/// Provider for most used templates
final mostUsedTemplatesProvider =
    Provider.autoDispose<List<TaskTemplateEntity>>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.mostUsedTemplates;
});

/// Provider for templates by category
final templatesByCategoryProvider = Provider.autoDispose
    .family<List<TaskTemplateEntity>, TaskTemplateCategory>((ref, category) {
  final state = ref.watch(templateNotifierProvider);
  return state.getTemplatesByCategory(category);
});

/// Provider for loading state
final isTemplatesLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.isLoading;
});

/// Provider for error state
final templatesErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.error;
});

/// Provider for selected template
final selectedTemplateProvider =
    Provider.autoDispose<TaskTemplateEntity?>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.selectedTemplate;
});

/// Provider for filter category
final templateFilterCategoryProvider =
    Provider.autoDispose<TaskTemplateCategory?>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.filterCategory;
});

/// Provider for templates count
final templatesCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.templatesCount;
});

/// Provider for user templates count
final userTemplatesCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.userTemplatesCount;
});

/// Provider for public templates count
final publicTemplatesCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(templateNotifierProvider);
  return state.publicTemplatesCount;
});
