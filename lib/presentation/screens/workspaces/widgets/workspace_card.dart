import 'package:flutter/material.dart';
import '../../../../domain/entities/workspace_entity.dart';
import '../../../config/theme/design_system.dart';

/// Workspace Card Widget
///
/// Displays a workspace with icon, name, member count, and type
class WorkspaceCard extends StatelessWidget {
  final WorkspaceEntity workspace;
  final VoidCallback onTap;
  final VoidCallback? onSettings;
  final bool isSelected;
  final String? currentUserId;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.onTap,
    this.onSettings,
    this.isSelected = false,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceColor = _parseColor(workspace.color);
    final userRole = _getUserRole();

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
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
                  // Workspace icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: workspaceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: workspaceColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        workspace.icon ?? _getDefaultIcon(workspace.type),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Workspace info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                workspace.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                        if (workspace.description != null) ...{
                          const SizedBox(height: 4),
                          Text(
                            workspace.description!,
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
                        },
                      ],
                    ),
                  ),

                  // Settings button
                  if (onSettings != null && (workspace.isOwner(currentUserId ?? '') || workspace.isAdmin(currentUserId ?? '')))
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      iconSize: 20,
                      onPressed: onSettings,
                      tooltip: 'Workspace Settings',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Type badge
                  _buildBadge(
                    context,
                    _getTypeLabel(workspace.type),
                    _getTypeIcon(workspace.type),
                    _getTypeColor(workspace.type),
                  ),

                  // Member count
                  _buildBadge(
                    context,
                    '${workspace.memberCount} ${workspace.memberCount == 1 ? 'member' : 'members'}',
                    Icons.people_outline_rounded,
                    Colors.blue,
                  ),

                  // User role
                  if (userRole != null)
                    _buildBadge(
                      context,
                      userRole,
                      _getRoleIcon(userRole),
                      _getRoleColor(userRole),
                    ),

                  // Subscription tier
                  _buildBadge(
                    context,
                    _getTierLabel(workspace.subscription.tier),
                    Icons.workspace_premium_outlined,
                    _getTierColor(workspace.subscription.tier),
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
                ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorString) {
    try {
      if (colorString == null) return const Color(0xFF2196F3);
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  String? _getUserRole() {
    if (currentUserId == null) return null;

    if (workspace.isOwner(currentUserId!)) {
      return 'Owner';
    }

    final member = workspace.getMember(currentUserId!);
    if (member == null) return null;

    switch (member.role) {
      case WorkspaceRole.admin:
        return 'Admin';
      case WorkspaceRole.member:
        return 'Member';
      case WorkspaceRole.guest:
        return 'Guest';
      default:
        return null;
    }
  }

  String _getDefaultIcon(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return '👤';
      case WorkspaceType.team:
        return '👥';
      case WorkspaceType.family:
        return '🏠';
      case WorkspaceType.enterprise:
        return '🏢';
    }
  }

  String _getTypeLabel(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return 'Personal';
      case WorkspaceType.team:
        return 'Team';
      case WorkspaceType.family:
        return 'Family';
      case WorkspaceType.enterprise:
        return 'Enterprise';
    }
  }

  IconData _getTypeIcon(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Icons.person_outline_rounded;
      case WorkspaceType.team:
        return Icons.groups_outlined;
      case WorkspaceType.family:
        return Icons.home_outlined;
      case WorkspaceType.enterprise:
        return Icons.business_outlined;
    }
  }

  Color _getTypeColor(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return Colors.purple;
      case WorkspaceType.team:
        return Colors.blue;
      case WorkspaceType.family:
        return Colors.green;
      case WorkspaceType.enterprise:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Icons.star_rounded;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'member':
        return Icons.person_outline_rounded;
      case 'guest':
        return Icons.visibility_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.amber;
      case 'admin':
        return Colors.deepPurple;
      case 'member':
        return Colors.blue;
      case 'guest':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getTierLabel(WorkspaceSubscriptionTier tier) {
    switch (tier) {
      case WorkspaceSubscriptionTier.free:
        return 'Free';
      case WorkspaceSubscriptionTier.teams:
        return 'Teams';
      case WorkspaceSubscriptionTier.enterprise:
        return 'Enterprise';
    }
  }

  Color _getTierColor(WorkspaceSubscriptionTier tier) {
    switch (tier) {
      case WorkspaceSubscriptionTier.free:
        return Colors.grey;
      case WorkspaceSubscriptionTier.teams:
        return Colors.blue;
      case WorkspaceSubscriptionTier.enterprise:
        return Colors.purple;
    }
  }
}
