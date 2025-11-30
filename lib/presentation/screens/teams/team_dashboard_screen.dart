import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/workspace_entity.dart';
import '../../providers/workspace/workspace_providers.dart';
import '../../providers/auth_provider.dart';

/// Team Dashboard Screen
///
/// Displays team workspace overview including:
/// - Team statistics and metrics
/// - Team members list
/// - Recent team activity
/// - Quick actions
class TeamDashboardScreen extends ConsumerStatefulWidget {
  final String? workspaceId;

  const TeamDashboardScreen({
    super.key,
    this.workspaceId,
  });

  @override
  ConsumerState<TeamDashboardScreen> createState() =>
      _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends ConsumerState<TeamDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load workspaces on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref
            .read(workspaceNotifierProvider.notifier)
            .loadWorkspaces(userId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamWorkspaces = ref.watch(teamWorkspacesProvider);
    final currentUser = ref.watch(currentUserProvider);

    // If workspaceId is provided, use it; otherwise use the first team workspace
    final workspace = widget.workspaceId != null
        ? ref.watch(workspaceByIdProvider(widget.workspaceId!))
        : teamWorkspaces.isNotEmpty
            ? teamWorkspaces.first
            : null;

    if (workspace == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Team Dashboard'),
        ),
        body: _buildNoWorkspaceState(context),
      );
    }

    final members = ref.watch(workspaceMembersProvider(workspace.id));
    final activeMembers = ref.watch(activeMembersProvider(workspace.id));
    final isOwner = currentUser != null && workspace.isOwner(currentUser.id);
    final isAdmin = currentUser != null && workspace.isAdmin(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(workspace.icon ?? '👥'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                workspace.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isAdmin || isOwner)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Workspace Settings',
              onPressed: () {
                // TODO: Navigate to workspace settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workspace settings coming soon'),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (currentUser != null) {
              await ref
                  .read(workspaceNotifierProvider.notifier)
                  .refreshWorkspaces(userId: currentUser.id);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Overview',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard(
                              context,
                              'Members',
                              '${members.length}',
                              Icons.people_outlined,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              'Active',
                              '${activeMembers.length}',
                              Icons.person_outline_rounded,
                              Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              'Tasks',
                              '0',
                              Icons.task_outlined,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Team Members Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Team Members',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${members.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (members.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No members yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ),
                          )
                        else
                          ...members.map((member) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  member.userId.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(member.email ?? member.userId),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    _getRoleIcon(member.role),
                                    size: 14,
                                    color: _getRoleColor(member.role),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(_getRoleLabel(member.role)),
                                  if (!member.isActive) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '• Inactive',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: member.isActive
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (isAdmin || isOwner)
                              ActionChip(
                                avatar: const Icon(Icons.person_add_outlined,
                                    size: 18),
                                label: const Text('Invite Members'),
                                onPressed: () {
                                  // TODO: Implement invite members
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Invite members coming soon'),
                                    ),
                                  );
                                },
                              ),
                            ActionChip(
                              avatar: const Icon(Icons.task_outlined, size: 18),
                              label: const Text('Create Task'),
                              onPressed: () {
                                // TODO: Navigate to create task
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Create task coming soon'),
                                  ),
                                );
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.list_outlined, size: 18),
                              label: const Text('View Lists'),
                              onPressed: () {
                                // TODO: Navigate to lists
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('View lists coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Workspace Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workspace Info',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'Type',
                          _getWorkspaceTypeLabel(workspace.type),
                        ),
                        _buildInfoRow(
                          context,
                          'Subscription',
                          _getSubscriptionLabel(workspace.subscription.tier),
                        ),
                        _buildInfoRow(
                          context,
                          'Created',
                          _formatDate(workspace.createdAt),
                        ),
                        if (workspace.description != null)
                          _buildInfoRow(
                            context,
                            'Description',
                            workspace.description!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWorkspaceState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspaces_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Team Workspace',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a team workspace to see the dashboard',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return 'Owner';
      case WorkspaceRole.admin:
        return 'Admin';
      case WorkspaceRole.member:
        return 'Member';
      case WorkspaceRole.guest:
        return 'Guest';
    }
  }

  IconData _getRoleIcon(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Icons.star_rounded;
      case WorkspaceRole.admin:
        return Icons.admin_panel_settings_outlined;
      case WorkspaceRole.member:
        return Icons.person_outline_rounded;
      case WorkspaceRole.guest:
        return Icons.visibility_outlined;
    }
  }

  Color _getRoleColor(WorkspaceRole role) {
    switch (role) {
      case WorkspaceRole.owner:
        return Colors.amber;
      case WorkspaceRole.admin:
        return Colors.deepPurple;
      case WorkspaceRole.member:
        return Colors.blue;
      case WorkspaceRole.guest:
        return Colors.grey;
    }
  }

  String _getWorkspaceTypeLabel(WorkspaceType type) {
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

  String _getSubscriptionLabel(WorkspaceSubscriptionTier tier) {
    switch (tier) {
      case WorkspaceSubscriptionTier.free:
        return 'Free';
      case WorkspaceSubscriptionTier.teams:
        return 'Teams';
      case WorkspaceSubscriptionTier.enterprise:
        return 'Enterprise';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
