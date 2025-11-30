import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/task_template_entity.dart';
import 'template_state.dart';

/// Template notifier for managing task templates
class TemplateNotifier extends StateNotifier<TemplateState> {
  TemplateNotifier() : super(const TemplateState()) {
    _loadTemplates();
  }

  static const _storageKey = 'task_templates';

  /// Load templates from storage
  Future<void> _loadTemplates() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_storageKey);

      List<TaskTemplateEntity> userTemplates = [];
      if (templatesJson != null) {
        final List<dynamic> decoded = jsonDecode(templatesJson);
        userTemplates = decoded.map((json) => _templateFromJson(json)).toList();
      }

      // Combine user templates with predefined templates
      final allTemplates = [
        ...PredefinedTemplates.allPredefinedTemplates,
        ...userTemplates,
      ];

      state = state.copyWith(
        templates: allTemplates,
        predefinedTemplates: PredefinedTemplates.allPredefinedTemplates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load templates: $e',
        isLoading: false,
      );
    }
  }

  /// Save templates to storage
  Future<void> _saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTemplates = state.userTemplates;
      final templatesJson = jsonEncode(
        userTemplates.map((t) => _templateToJson(t)).toList(),
      );
      await prefs.setString(_storageKey, templatesJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save templates: $e');
    }
  }

  /// Create a new template
  Future<void> createTemplate(TaskTemplateEntity template) async {
    final updatedTemplates = [...state.templates, template];
    state = state.copyWith(templates: updatedTemplates);
    await _saveTemplates();
  }

  /// Update a template
  Future<void> updateTemplate(TaskTemplateEntity template) async {
    final updatedTemplates = state.templates.map((t) {
      return t.id == template.id ? template : t;
    }).toList();
    state = state.copyWith(templates: updatedTemplates);
    await _saveTemplates();
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    final updatedTemplates = state.templates
        .where((t) => t.id != templateId)
        .toList();
    state = state.copyWith(templates: updatedTemplates);
    await _saveTemplates();
  }

  /// Increment usage count
  Future<void> incrementUsageCount(String templateId) async {
    final template = state.templates.firstWhere((t) => t.id == templateId);
    final updatedTemplate = template.copyWith(
      usageCount: template.usageCount + 1,
    );
    await updateTemplate(updatedTemplate);
  }

  /// Set filter category
  void setFilterCategory(TaskTemplateCategory? category) {
    state = state.copyWith(filterCategory: category);
  }

  /// Select template
  void selectTemplate(TaskTemplateEntity? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// JSON serialization
  Map<String, dynamic> _templateToJson(TaskTemplateEntity template) {
    return {
      'id': template.id,
      'userId': template.userId,
      'name': template.name,
      'description': template.description,
      'icon': template.icon,
      'category': template.category.index,
      'isPublic': template.isPublic,
      'usageCount': template.usageCount,
      'createdAt': template.createdAt.toIso8601String(),
      'updatedAt': template.updatedAt.toIso8601String(),
      'templateTitle': template.templateTitle,
      'templateDescription': template.templateDescription,
      'templatePriority': template.templatePriority,
      'templateTags': template.templateTags,
      'templateCategory': template.templateCategory,
      'templateSubtasks': template.templateSubtasks
          ?.map((s) => {'title': s.title, 'order': s.order})
          .toList(),
      'estimatedDurationMinutes': template.estimatedDurationMinutes,
      'variables': template.variables,
    };
  }

  TaskTemplateEntity _templateFromJson(Map<String, dynamic> json) {
    return TaskTemplateEntity(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: TaskTemplateCategory.values[json['category']],
      isPublic: json['isPublic'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      templateTitle: json['templateTitle'],
      templateDescription: json['templateDescription'],
      templatePriority: json['templatePriority'],
      templateTags: (json['templateTags'] as List<dynamic>?)?.cast<String>(),
      templateCategory: json['templateCategory'],
      templateSubtasks: (json['templateSubtasks'] as List<dynamic>?)
          ?.map((s) => TaskTemplateSubtask(
                title: s['title'],
                order: s['order'],
              ))
          .toList(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      variables: (json['variables'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
}
