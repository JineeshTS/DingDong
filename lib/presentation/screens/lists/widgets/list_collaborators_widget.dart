import 'package:flutter/material.dart';
import '../../../../domain/entities/list_entity.dart';

/// List Collaborators Widget
///
/// Displays avatars of collaborators on a list
class ListCollaboratorsWidget extends StatelessWidget {
  final ListEntity list;
  final int maxAvatars;

  const ListCollaboratorsWidget({
    super.key,
    required this.list,
    this.maxAvatars = 3,
  });

  @override
  Widget build(BuildContext context) {
    final collaborators = list.shareSettings?.collaborators ?? [];

    if (collaborators.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayedCollaborators = collaborators.take(maxAvatars).toList();
    final remainingCount = collaborators.length - displayedCollaborators.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Collaborator avatars (stacked)
        SizedBox(
          width: (maxAvatars * 20.0) + 4,
          height: 28,
          child: Stack(
            children: [
              for (var i = 0; i < displayedCollaborators.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: _buildAvatar(
                    context,
                    displayedCollaborators[i].userId,
                    _getPermissionColor(displayedCollaborators[i].permission),
                  ),
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
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String userId, Color borderColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          userId.substring(0, 1).toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Color _getPermissionColor(ListPermission permission) {
    switch (permission) {
      case ListPermission.view:
        return Colors.grey;
      case ListPermission.comment:
        return Colors.blue;
      case ListPermission.edit:
        return Colors.green;
      case ListPermission.admin:
        return Colors.purple;
    }
  }
}
