import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/automation_rule_entity.dart';
import 'automation_notifier.dart';
import 'automation_state.dart';

/// Main automation notifier provider
final automationNotifierProvider =
    StateNotifierProvider<AutomationNotifier, AutomationState>(
  (ref) => AutomationNotifier(),
);

/// Provider for all automations
final allAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.automations;
});

/// Provider for enabled automations
final enabledAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.enabledAutomations;
});

/// Provider for disabled automations
final disabledAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.disabledAutomations;
});

/// Provider for user automations
final userAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.userAutomations;
});

/// Provider for predefined automations
final predefinedAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.predefinedAutomations;
});

/// Provider for most used automations
final mostUsedAutomationsProvider =
    Provider.autoDispose<List<AutomationRuleEntity>>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.mostUsedAutomations;
});

/// Provider for automations by trigger type
final automationsByTriggerProvider = Provider.autoDispose
    .family<List<AutomationRuleEntity>, AutomationTriggerType>((ref, type) {
  final state = ref.watch(automationNotifierProvider);
  return state.getAutomationsByTrigger(type);
});

/// Provider for loading state
final isAutomationsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.isLoading;
});

/// Provider for error state
final automationsErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.error;
});

/// Provider for selected automation
final selectedAutomationProvider =
    Provider.autoDispose<AutomationRuleEntity?>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.selectedAutomation;
});

/// Provider for automations count
final automationsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.automationsCount;
});

/// Provider for enabled automations count
final enabledAutomationsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.enabledAutomationsCount;
});

/// Provider for disabled automations count
final disabledAutomationsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.disabledAutomationsCount;
});

/// Provider for user automations count
final userAutomationsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(automationNotifierProvider);
  return state.userAutomationsCount;
});
