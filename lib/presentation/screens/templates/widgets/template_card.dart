import 'package:flutter/material.dart';
import '../../../../domain/entities/task_template_entity.dart';

/// Template Card Widget
///
/// Displays a task template in a card format
class TemplateCard extends StatelessWidget {
  final TaskTemplateEntity template;
  final VoidCallback onTap;
  final VoidCallback? onUse;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onUse,
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
                  // Template icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(template.category)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        template.icon ?? '📋',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Template info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (template.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            template.description!,
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

                  // Use button
                  if (onUse != null)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      tooltip: 'Use Template',
                      onPressed: onUse,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Template metadata
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Category badge
                  _buildBadge(
                    context,
                    _getCategoryLabel(template.category),
                    _getCategoryIcon(template.category),
                    _getCategoryColor(template.category),
                  ),

                  // Usage count
                  if (template.usageCount > 0)
                    _buildBadge(
                      context,
                      '${template.usageCount} uses',
                      Icons.analytics_outlined,
                      Colors.grey,
                    ),

                  // Subtasks count
                  if (template.templateSubtasks != null &&
                      template.templateSubtasks!.isNotEmpty)
                    _buildBadge(
                      context,
                      '${template.templateSubtasks!.length} subtasks',
                      Icons.checklist_rounded,
                      Colors.blue,
                    ),

                  // Duration estimate
                  if (template.estimatedDurationMinutes != null)
                    _buildBadge(
                      context,
                      '~${template.estimatedDurationMinutes}min',
                      Icons.timer_outlined,
                      Colors.orange,
                    ),

                  // Public badge
                  if (template.isPublic)
                    _buildBadge(
                      context,
                      'Public',
                      Icons.public_outlined,
                      Colors.green,
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
