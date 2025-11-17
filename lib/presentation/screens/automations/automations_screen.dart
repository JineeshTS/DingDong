import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/automation_rule_entity.dart';
import '../../providers/automations/automation_providers.dart';
import 'widgets/automation_card.dart';

/// Automations Screen
///
/// Browse and manage automation rules:
/// - View predefined automations
/// - Create custom automations
/// - Enable/disable automations
/// - View automation statistics
class AutomationsScreen extends ConsumerStatefulWidget {
  const AutomationsScreen({super.key});

  @override
  ConsumerState<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends ConsumerState<AutomationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAutomations = ref.watch(allAutomationsProvider);
    final enabledAutomations = ref.watch(enabledAutomationsProvider);
    final predefinedAutomations = ref.watch(predefinedAutomationsProvider);
    final userAutomations = ref.watch(userAutomationsProvider);
    final isLoading = ref.watch(isAutomationsLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Rules'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All (${allAutomations.length})',
              icon: const Icon(Icons.all_inclusive_rounded),
            ),
            Tab(
              text: 'Active (${enabledAutomations.length})',
              icon: const Icon(Icons.check_circle_outline_rounded),
            ),
            Tab(
              text: 'Predefined (${predefinedAutomations.length})',
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // All automations tab
                  _buildAutomationsList(
                    context,
                    allAutomations,
                    emptyMessage: 'No automations configured',
                  ),

                  // Active automations tab
                  _buildAutomationsList(
                    context,
                    enabledAutomations,
                    emptyMessage: 'No active automations',
                  ),

                  // Predefined automations tab
                  _buildAutomationsList(
                    context,
                    predefinedAutomations,
                    emptyMessage: 'No predefined automations available',
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAutomationDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Automation'),
      ),
    );
  }

  Widget _buildAutomationsList(
    BuildContext context,
    List<AutomationRuleEntity> automations, {
    required String emptyMessage,
  }) {
    if (automations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_fix_high_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showCreateAutomationDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Automation'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: automations.length,
      itemBuilder: (context, index) {
        final automation = automations[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AutomationCard(
            automation: automation,
            onTap: () => _showAutomationDetails(context, automation),
            onToggle: (value) {
              ref
                  .read(automationNotifierProvider.notifier)
                  .toggleAutomation(automation.id);
            },
          ),
        );
      },
    );
  }

  void _showAutomationDetails(
      BuildContext context, AutomationRuleEntity automation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Automation name
                Text(
                  automation.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (automation.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    automation.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],

                const SizedBox(height: 24),

                // Automation details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Trigger section
                      Text(
                        'Trigger',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                _getTriggerIcon(automation.trigger.type),
                                color: _getTriggerColor(automation.trigger.type),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getTriggerLabel(automation.trigger.type),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions section
                      Text(
                        'Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...automation.actions.map((action) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  _getActionIcon(action.type),
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getActionLabel(action.type),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Statistics
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildStatRow(
                                context,
                                'Status',
                                automation.isEnabled ? 'Active' : 'Inactive',
                                automation.isEnabled
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const Divider(),
                              _buildStatRow(
                                context,
                                'Times Executed',
                                '${automation.executionCount}',
                                Colors.blue,
                              ),
                              const Divider(),
                              _buildStatRow(
                                context,
                                'Created',
                                _formatDate(automation.createdAt),
                                Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(automationNotifierProvider.notifier)
                              .toggleAutomation(automation.id);
                        },
                        icon: Icon(automation.isEnabled
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        label: Text(
                            automation.isEnabled ? 'Disable' : 'Enable'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement edit automation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit automation coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _showCreateAutomationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Automation'),
        content: const Text('Automation creation form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTriggerLabel(AutomationTriggerType type) {
    switch (type) {
      case AutomationTriggerType.taskCreated:
        return 'When a task is created';
      case AutomationTriggerType.taskCompleted:
        return 'When a task is completed';
      case AutomationTriggerType.taskOverdue:
        return 'When a task becomes overdue';
      case AutomationTriggerType.taskAssigned:
        return 'When a task is assigned';
      case AutomationTriggerType.tagAdded:
        return 'When a tag is added';
      case AutomationTriggerType.dueDateApproaching:
        return 'When due date is approaching';
      case AutomationTriggerType.timeBased:
        return 'At a specific time';
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

  String _getActionLabel(AutomationActionType type) {
    switch (type) {
      case AutomationActionType.createTask:
        return 'Create a task';
      case AutomationActionType.updateTask:
        return 'Update task';
      case AutomationActionType.sendNotification:
        return 'Send notification';
      case AutomationActionType.moveToList:
        return 'Move to list';
      case AutomationActionType.assignToUser:
        return 'Assign to user';
      case AutomationActionType.postComment:
        return 'Post comment';
      case AutomationActionType.addTag:
        return 'Add tag';
      case AutomationActionType.setPriority:
        return 'Set priority';
      case AutomationActionType.setDueDate:
        return 'Set due date';
    }
  }

  IconData _getActionIcon(AutomationActionType type) {
    switch (type) {
      case AutomationActionType.createTask:
        return Icons.add_task_rounded;
      case AutomationActionType.updateTask:
        return Icons.edit_outlined;
      case AutomationActionType.sendNotification:
        return Icons.notifications_outlined;
      case AutomationActionType.moveToList:
        return Icons.drive_file_move_outlined;
      case AutomationActionType.assignToUser:
        return Icons.person_add_outlined;
      case AutomationActionType.postComment:
        return Icons.comment_outlined;
      case AutomationActionType.addTag:
        return Icons.label_outlined;
      case AutomationActionType.setPriority:
        return Icons.flag_outlined;
      case AutomationActionType.setDueDate:
        return Icons.event_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
