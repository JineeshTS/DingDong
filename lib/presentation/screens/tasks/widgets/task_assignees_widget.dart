import 'package:flutter/material.dart';
import '../../../../domain/entities/task_entity.dart';

/// Task Assignees Widget
///
/// Displays assignees for a task with:
/// - Avatar display (stacked)
/// - Add assignee button
/// - Assignee management dialog
class TaskAssigneesWidget extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onManageAssignees;
  final int maxAvatars;

  const TaskAssigneesWidget({
    super.key,
    required this.task,
    this.onManageAssignees,
    this.maxAvatars = 3,
  });

  @override
  Widget build(BuildContext context) {
    final assignees = task.assigneeIds;

    return InkWell(
      onTap: onManageAssignees,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Assignees label
            Text(
              'Assigned to:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(width: 8),

            // Avatar stack or placeholder
            if (assignees.isEmpty)
              _buildUnassignedChip(context)
            else
              _buildAssigneeAvatars(context, assignees),
          ],
        ),
      ),
    );
  }

  Widget _buildUnassignedChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            'Unassigned',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeAvatars(BuildContext context, List<String> assignees) {
    final displayedAssignees = assignees.take(maxAvatars).toList();
    final remainingCount = assignees.length - displayedAssignees.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stacked avatars
        SizedBox(
          width: (maxAvatars * 20.0) + 8,
          height: 28,
          child: Stack(
            children: [
              for (var i = 0; i < displayedAssignees.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: _buildAvatar(context, displayedAssignees[i]),
                ),
            ],
          ),
        ),

        // Remaining count
        if (remainingCount > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String userId) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          userId.substring(0, 1).toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }
}

/// Task Assignment Dialog
///
/// Dialog for managing task assignees
class TaskAssignmentDialog extends StatefulWidget {
  final TaskEntity task;
  final Function(List<String> assigneeIds) onAssigned;

  const TaskAssignmentDialog({
    super.key,
    required this.task,
    required this.onAssigned,
  });

  @override
  State<TaskAssignmentDialog> createState() => _TaskAssignmentDialogState();
}

class _TaskAssignmentDialogState extends State<TaskAssignmentDialog> {
  late List<String> _selectedAssignees;
  final _userIdController = TextEditingController();

  // Mock list of available users (in real app, this would come from workspace members)
  final List<String> _availableUsers = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
    'user4@example.com',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAssignees = List.from(widget.task.assigneeIds);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Task'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add user field
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                hintText: 'Enter user ID or email',
                prefixIcon: const Icon(Icons.person_add_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _addUser,
                ),
              ),
              onSubmitted: (_) => _addUser(),
            ),

            const SizedBox(height: 16),

            // Available users section
            if (_availableUsers.isNotEmpty) ...[
              Text(
                'Suggested Users',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableUsers.map((userId) {
                  final isSelected = _selectedAssignees.contains(userId);
                  return FilterChip(
                    label: Text(userId),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAssignees.add(userId);
                        } else {
                          _selectedAssignees.remove(userId);
                        }
                      });
                    },
                    avatar: CircleAvatar(
                      child: Text(userId.substring(0, 1).toUpperCase()),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Currently assigned section
            if (_selectedAssignees.isNotEmpty) ...[
              Text(
                'Assigned (${_selectedAssignees.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedAssignees.length,
                  itemBuilder: (context, index) {
                    final userId = _selectedAssignees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(userId.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(userId),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedAssignees.remove(userId);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No one assigned',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAssigned(_selectedAssignees);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _addUser() {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) return;

    if (!_selectedAssignees.contains(userId)) {
      setState(() {
        _selectedAssignees.add(userId);
        _userIdController.clear();
      });
    }
  }
}
