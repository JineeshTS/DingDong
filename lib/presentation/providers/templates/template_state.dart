import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/task_template_entity.dart';

part 'template_state.freezed.dart';

/// Template management state
@freezed
class TemplateState with _$TemplateState {
  const factory TemplateState({
    @Default([]) List<TaskTemplateEntity> templates,
    @Default([]) List<TaskTemplateEntity> predefinedTemplates,
    TaskTemplateEntity? selectedTemplate,
    TaskTemplateCategory? filterCategory,
    @Default(false) bool isLoading,
    String? error,
  }) = _TemplateState;

  const TemplateState._();

  /// Get templates by category
  List<TaskTemplateEntity> getTemplatesByCategory(TaskTemplateCategory category) {
    return templates.where((t) => t.category == category).toList();
  }

  /// Get user templates (non-predefined)
  List<TaskTemplateEntity> get userTemplates {
    return templates.where((t) => !t.isPublic).toList();
  }

  /// Get public/community templates
  List<TaskTemplateEntity> get publicTemplates {
    return templates.where((t) => t.isPublic).toList();
  }

  /// Get filtered templates
  List<TaskTemplateEntity> get filteredTemplates {
    if (filterCategory == null) return templates;
    return getTemplatesByCategory(filterCategory!);
  }

  /// Get most used templates
  List<TaskTemplateEntity> get mostUsedTemplates {
    final sorted = List<TaskTemplateEntity>.from(templates)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(5).toList();
  }

  /// Get templates count
  int get templatesCount => templates.length;

  /// Get user templates count
  int get userTemplatesCount => userTemplates.length;

  /// Get public templates count
  int get publicTemplatesCount => publicTemplates.length;
}
