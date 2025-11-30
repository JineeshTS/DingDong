import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task_template_entity.dart';
import '../../providers/templates/template_providers.dart';
import '../../providers/auth_provider.dart';
import 'widgets/template_card.dart';

/// Templates Screen
///
/// Browse and manage task templates:
/// - View predefined templates
/// - Create custom templates
/// - Use templates to create tasks
class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predefinedTemplates = ref.watch(predefinedTemplatesProvider);
    final userTemplates = ref.watch(userTemplatesProvider);
    final isLoading = ref.watch(isTemplatesLoadingProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Templates'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Predefined (${predefinedTemplates.length})',
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
            Tab(
              text: 'My Templates (${userTemplates.length})',
              icon: const Icon(Icons.folder_outlined),
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
                  // Predefined templates tab
                  _buildTemplatesList(
                    context,
                    predefinedTemplates,
                    emptyMessage: 'No predefined templates available',
                  ),

                  // User templates tab
                  _buildTemplatesList(
                    context,
                    userTemplates,
                    emptyMessage: 'No custom templates yet',
                    showCreateButton: true,
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTemplateDialog(context, currentUser?.id),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Template'),
      ),
    );
  }

  Widget _buildTemplatesList(
    BuildContext context,
    List<TaskTemplateEntity> templates, {
    required String emptyMessage,
    bool showCreateButton = false,
  }) {
    if (templates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_add_outlined,
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
              if (showCreateButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTemplateDialog(
                      context, ref.read(currentUserProvider)?.id),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Template'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Group templates by category
    final groupedTemplates = <TaskTemplateCategory, List<TaskTemplateEntity>>{};
    for (final template in templates) {
      groupedTemplates.putIfAbsent(template.category, () => []).add(template);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTemplates.length,
      itemBuilder: (context, index) {
        final category = groupedTemplates.keys.elementAt(index);
        final categoryTemplates = groupedTemplates[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: _getCategoryColor(category),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCategoryLabel(category),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(category),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${categoryTemplates.length})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),

            // Templates in this category
            ...categoryTemplates.map((template) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TemplateCard(
                  template: template,
                  onTap: () => _showTemplateDetails(context, template),
                  onUse: () => _useTemplate(context, template),
                ),
              );
            }),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showTemplateDetails(BuildContext context, TaskTemplateEntity template) {
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

                // Template icon and name
                Row(
                  children: [
                    Text(
                      template.icon ?? '📋',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        template.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
                if (template.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    template.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],

                const SizedBox(height: 24),

                // Template details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (template.templateTitle != null) ...[
                        _buildDetailRow(
                          context,
                          'Task Title',
                          template.templateTitle!,
                          Icons.title_rounded,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (template.templateDescription != null) ...[
                        _buildDetailRow(
                          context,
                          'Description',
                          template.templateDescription!,
                          Icons.description_outlined,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (template.templatePriority != null) ...[
                        _buildDetailRow(
                          context,
                          'Priority',
                          'Level ${template.templatePriority}',
                          Icons.flag_outlined,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (template.templateSubtasks != null &&
                          template.templateSubtasks!.isNotEmpty) ...[
                        Text(
                          'Subtasks',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ...template.templateSubtasks!.map((subtask) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_box_outline_blank,
                                size: 20),
                            title: Text(subtask.title),
                          );
                        }),
                      ],
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Times Used',
                        '${template.usageCount}',
                        Icons.analytics_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Use template button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _useTemplate(context, template);
                    },
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Use This Template'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _useTemplate(BuildContext context, TaskTemplateEntity template) {
    // TODO: Implement create task from template flow
    ref
        .read(templateNotifierProvider.notifier)
        .incrementUsageCount(template.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating task from "${template.name}"...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Template'),
        content: const Text('Template creation form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(TaskTemplateCategory category) {
    switch (category) {
      case TaskTemplateCategory.personal:
        return 'Personal';
      case TaskTemplateCategory.work:
        return 'Work';
      case TaskTemplateCategory.meeting:
        return 'Meeting';
      case TaskTemplateCategory.project:
        return 'Project';
      case TaskTemplateCategory.routine:
        return 'Routine';
      case TaskTemplateCategory.goal:
        return 'Goal';
      case TaskTemplateCategory.shopping:
        return 'Shopping';
      case TaskTemplateCategory.travel:
        return 'Travel';
      case TaskTemplateCategory.health:
        return 'Health';
      case TaskTemplateCategory.learning:
        return 'Learning';
      case TaskTemplateCategory.custom:
        return 'Custom';
    }
  }

  IconData _getCategoryIcon(TaskTemplateCategory category) {
    switch (category) {
      case TaskTemplateCategory.personal:
        return Icons.person_outline_rounded;
      case TaskTemplateCategory.work:
        return Icons.work_outline_rounded;
      case TaskTemplateCategory.meeting:
        return Icons.event_outlined;
      case TaskTemplateCategory.project:
        return Icons.folder_outlined;
      case TaskTemplateCategory.routine:
        return Icons.repeat_rounded;
      case TaskTemplateCategory.goal:
        return Icons.flag_outlined;
      case TaskTemplateCategory.shopping:
        return Icons.shopping_cart_outlined;
      case TaskTemplateCategory.travel:
        return Icons.flight_outlined;
      case TaskTemplateCategory.health:
        return Icons.favorite_border_rounded;
      case TaskTemplateCategory.learning:
        return Icons.school_outlined;
      case TaskTemplateCategory.custom:
        return Icons.tune_rounded;
    }
  }

  Color _getCategoryColor(TaskTemplateCategory category) {
    switch (category) {
      case TaskTemplateCategory.personal:
        return Colors.purple;
      case TaskTemplateCategory.work:
        return Colors.blue;
      case TaskTemplateCategory.meeting:
        return Colors.green;
      case TaskTemplateCategory.project:
        return Colors.orange;
      case TaskTemplateCategory.routine:
        return Colors.teal;
      case TaskTemplateCategory.goal:
        return Colors.red;
      case TaskTemplateCategory.shopping:
        return Colors.pink;
      case TaskTemplateCategory.travel:
        return Colors.cyan;
      case TaskTemplateCategory.health:
        return Colors.red;
      case TaskTemplateCategory.learning:
        return Colors.indigo;
      case TaskTemplateCategory.custom:
        return Colors.grey;
    }
  }
}
