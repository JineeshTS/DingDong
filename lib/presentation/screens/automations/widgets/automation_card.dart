import 'package:flutter/material.dart';
import '../../../../domain/entities/automation_rule_entity.dart';

/// Automation Card Widget
///
/// Displays an automation rule in a card format
class AutomationCard extends StatelessWidget {
  final AutomationRuleEntity automation;
  final VoidCallback onTap;
  final Function(bool)? onToggle;

  const AutomationCard({
    super.key,
    required this.automation,
    required this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Automation icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTriggerColor(automation.trigger.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getTriggerIcon(automation.trigger.type),
                        color: _getTriggerColor(automation.trigger.type),
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Automation info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          automation.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (automation.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            automation.description!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Toggle switch
                  if (onToggle != null)
                    Switch(
                      value: automation.isEnabled,
                      onChanged: onToggle,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Trigger and actions
              Row(
                children: [
                  // Trigger badge
                  _buildBadge(
                    context,
                    'When: ${_getTriggerLabel(automation.trigger.type)}',
                    Icons.play_arrow_rounded,
                    _getTriggerColor(automation.trigger.type),
                  ),

                  const SizedBox(width: 8),

                  const Icon(Icons.arrow_forward_rounded, size: 16),

                  const SizedBox(width: 8),

                  // Actions badge
                  _buildBadge(
                    context,
                    '${automation.actions.length} ${automation.actions.length == 1 ? 'action' : 'actions'}',
                    Icons.bolt_rounded,
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Metadata
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Execution count
                  if (automation.executionCount > 0)
                    _buildBadge(
                      context,
                      '${automation.executionCount} runs',
                      Icons.analytics_outlined,
                      Colors.grey,
                    ),

                  // Status
                  _buildBadge(
                    context,
                    automation.isEnabled ? 'Active' : 'Inactive',
                    automation.isEnabled
                        ? Icons.check_circle_outline_rounded
                        : Icons.pause_circle_outline_rounded,
                    automation.isEnabled ? Colors.green : Colors.grey,
                  ),

                  // System automation
                  if (automation.userId == 'system')
                    _buildBadge(
                      context,
                      'Predefined',
                      Icons.verified_outlined,
                      Colors.blue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  String _getTriggerLabel(AutomationTriggerType type) {
    switch (type) {
      case AutomationTriggerType.taskCreated:
        return 'Task created';
      case AutomationTriggerType.taskCompleted:
        return 'Task completed';
      case AutomationTriggerType.taskOverdue:
        return 'Task overdue';
      case AutomationTriggerType.taskAssigned:
        return 'Task assigned';
      case AutomationTriggerType.tagAdded:
        return 'Tag added';
      case AutomationTriggerType.dueDateApproaching:
        return 'Due date approaching';
      case AutomationTriggerType.timeBased:
        return 'Time-based';
    }
  }

  IconData _getTriggerIcon(AutomationTriggerType type) {
    switch (type) {
      case AutomationTriggerType.taskCreated:
        return Icons.add_task_rounded;
      case AutomationTriggerType.taskCompleted:
        return Icons.check_circle_outline_rounded;
      case AutomationTriggerType.taskOverdue:
        return Icons.warning_amber_rounded;
      case AutomationTriggerType.taskAssigned:
        return Icons.person_add_outlined;
      case AutomationTriggerType.tagAdded:
        return Icons.label_outlined;
      case AutomationTriggerType.dueDateApproaching:
        return Icons.schedule_rounded;
      case AutomationTriggerType.timeBased:
        return Icons.access_time_rounded;
    }
  }

  Color _getTriggerColor(AutomationTriggerType type) {
    switch (type) {
      case AutomationTriggerType.taskCreated:
        return Colors.green;
      case AutomationTriggerType.taskCompleted:
        return Colors.blue;
      case AutomationTriggerType.taskOverdue:
        return Colors.red;
      case AutomationTriggerType.taskAssigned:
        return Colors.purple;
      case AutomationTriggerType.tagAdded:
        return Colors.orange;
      case AutomationTriggerType.dueDateApproaching:
        return Colors.amber;
      case AutomationTriggerType.timeBased:
        return Colors.teal;
    }
  }
}
