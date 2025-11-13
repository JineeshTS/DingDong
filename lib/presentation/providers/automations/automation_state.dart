import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/automation_rule_entity.dart';

part 'automation_state.freezed.dart';

/// Automation management state
@freezed
class AutomationState with _$AutomationState {
  const factory AutomationState({
    @Default([]) List<AutomationRuleEntity> automations,
    @Default([]) List<AutomationRuleEntity> predefinedAutomations,
    AutomationRuleEntity? selectedAutomation,
    @Default(false) bool isLoading,
    String? error,
  }) = _AutomationState;

  const AutomationState._();

  /// Get enabled automations
  List<AutomationRuleEntity> get enabledAutomations {
    return automations.where((a) => a.isEnabled).toList();
  }

  /// Get disabled automations
  List<AutomationRuleEntity> get disabledAutomations {
    return automations.where((a) => !a.isEnabled).toList();
  }

  /// Get user automations (non-predefined)
  List<AutomationRuleEntity> get userAutomations {
    return automations.where((a) => a.userId != 'system').toList();
  }

  /// Get automations by trigger type
  List<AutomationRuleEntity> getAutomationsByTrigger(
      AutomationTriggerType type) {
    return automations.where((a) => a.trigger.type == type).toList();
  }

  /// Get most used automations
  List<AutomationRuleEntity> get mostUsedAutomations {
    final sorted = List<AutomationRuleEntity>.from(automations)
      ..sort((a, b) => b.executionCount.compareTo(a.executionCount));
    return sorted.take(5).toList();
  }

  /// Get automations count
  int get automationsCount => automations.length;

  /// Get enabled automations count
  int get enabledAutomationsCount => enabledAutomations.length;

  /// Get disabled automations count
  int get disabledAutomationsCount => disabledAutomations.length;

  /// Get user automations count
  int get userAutomationsCount => userAutomations.length;
}
