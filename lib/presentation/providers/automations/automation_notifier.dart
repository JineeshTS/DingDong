import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/automation_rule_entity.dart';
import 'automation_state.dart';

/// Automation notifier for managing automation rules
class AutomationNotifier extends StateNotifier<AutomationState> {
  AutomationNotifier() : super(const AutomationState()) {
    _loadAutomations();
  }

  static const _storageKey = 'automation_rules';

  /// Load automations from storage
  Future<void> _loadAutomations() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final automationsJson = prefs.getString(_storageKey);

      List<AutomationRuleEntity> userAutomations = [];
      if (automationsJson != null) {
        final List<dynamic> decoded = jsonDecode(automationsJson);
        userAutomations =
            decoded.map((json) => _automationFromJson(json)).toList();
      }

      // Combine user automations with predefined automations
      final allAutomations = [
        ...AutomationTemplates.allPredefinedAutomations,
        ...userAutomations,
      ];

      state = state.copyWith(
        automations: allAutomations,
        predefinedAutomations: AutomationTemplates.allPredefinedAutomations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load automations: $e',
        isLoading: false,
      );
    }
  }

  /// Save automations to storage
  Future<void> _saveAutomations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userAutomations = state.userAutomations;
      final automationsJson = jsonEncode(
        userAutomations.map((a) => _automationToJson(a)).toList(),
      );
      await prefs.setString(_storageKey, automationsJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save automations: $e');
    }
  }

  /// Create a new automation
  Future<void> createAutomation(AutomationRuleEntity automation) async {
    final updatedAutomations = [...state.automations, automation];
    state = state.copyWith(automations: updatedAutomations);
    await _saveAutomations();
  }

  /// Update an automation
  Future<void> updateAutomation(AutomationRuleEntity automation) async {
    final updatedAutomations = state.automations.map((a) {
      return a.id == automation.id ? automation : a;
    }).toList();
    state = state.copyWith(automations: updatedAutomations);
    await _saveAutomations();
  }

  /// Delete an automation
  Future<void> deleteAutomation(String automationId) async {
    final updatedAutomations =
        state.automations.where((a) => a.id != automationId).toList();
    state = state.copyWith(automations: updatedAutomations);
    await _saveAutomations();
  }

  /// Toggle automation enabled/disabled
  Future<void> toggleAutomation(String automationId) async {
    final automation =
        state.automations.firstWhere((a) => a.id == automationId);
    final updatedAutomation = automation.copyWith(
      isEnabled: !automation.isEnabled,
      updatedAt: DateTime.now(),
    );
    await updateAutomation(updatedAutomation);
  }

  /// Increment execution count
  Future<void> incrementExecutionCount(String automationId) async {
    final automation =
        state.automations.firstWhere((a) => a.id == automationId);
    final updatedAutomation = automation.copyWith(
      executionCount: automation.executionCount + 1,
    );
    await updateAutomation(updatedAutomation);
  }

  /// Select automation
  void selectAutomation(AutomationRuleEntity? automation) {
    state = state.copyWith(selectedAutomation: automation);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// JSON serialization
  Map<String, dynamic> _automationToJson(AutomationRuleEntity automation) {
    return {
      'id': automation.id,
      'userId': automation.userId,
      'name': automation.name,
      'description': automation.description,
      'trigger': {
        'type': automation.trigger.type.index,
        'conditions': automation.trigger.conditions,
      },
      'actions': automation.actions
          .map((a) => {
                'type': a.type.index,
                'parameters': a.parameters,
              })
          .toList(),
      'isEnabled': automation.isEnabled,
      'createdAt': automation.createdAt.toIso8601String(),
      'updatedAt': automation.updatedAt.toIso8601String(),
      'executionCount': automation.executionCount,
    };
  }

  AutomationRuleEntity _automationFromJson(Map<String, dynamic> json) {
    return AutomationRuleEntity(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      trigger: AutomationTrigger(
        type: AutomationTriggerType.values[json['trigger']['type']],
        conditions: json['trigger']['conditions']?.cast<String, dynamic>(),
      ),
      actions: (json['actions'] as List<dynamic>)
          .map((a) => AutomationAction(
                type: AutomationActionType.values[a['type']],
                parameters: (a['parameters'] as Map<String, dynamic>).cast<String, dynamic>(),
              ))
          .toList(),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      executionCount: json['executionCount'] ?? 0,
    );
  }
}
