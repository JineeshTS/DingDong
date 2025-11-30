import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/workspace_entity.dart';
import '../../providers/workspace/workspace_providers.dart';
import '../../providers/auth_provider.dart';
import 'widgets/workspace_card.dart';

/// Workspaces Screen
///
/// Main screen for managing workspaces:
/// - View all workspaces (personal, team, family, enterprise)
/// - Create new workspaces
/// - Switch between workspaces
/// - Navigate to workspace settings
/// - Manage workspace members
class WorkspacesScreen extends ConsumerStatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  ConsumerState<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends ConsumerState<WorkspacesScreen> {
  String? _selectedWorkspaceId;

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
    final workspaceState = ref.watch(workspaceNotifierProvider);
    final workspaces = ref.watch(activeWorkspacesProvider);
    final teamWorkspaces = ref.watch(teamWorkspacesProvider);
    final personalWorkspaces = ref.watch(personalWorkspacesProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isLoading = ref.watch(isWorkspaceLoadingProvider);

    // Show error if any
    ref.listen(workspaceErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (currentUser != null) {
                ref
                    .read(workspaceNotifierProvider.notifier)
                    .refreshWorkspaces(userId: currentUser.id);
              }
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
          child: isLoading && workspaces.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildStatItem(
                                    context,
                                    'Total',
                                    '${workspaces.length}',
                                    Icons.workspaces_outlined,
                                    Colors.blue,
                                  ),
                                  _buildStatItem(
                                    context,
                                    'Team',
                                    '${teamWorkspaces.length}',
                                    Icons.groups_outlined,
                                    Colors.green,
                                  ),
                                  _buildStatItem(
                                    context,
                                    'Personal',
                                    '${personalWorkspaces.length}',
                                    Icons.person_outline_rounded,
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section: Personal Workspaces
                      if (personalWorkspaces.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Personal Workspaces',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...personalWorkspaces.map((workspace) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: WorkspaceCard(
                              workspace: workspace,
                              isSelected: workspace.id == _selectedWorkspaceId,
                              currentUserId: currentUser?.id,
                              onTap: () {
                                setState(() {
                                  _selectedWorkspaceId = workspace.id;
                                });
                                _showWorkspaceDetailsSheet(context, workspace);
                              },
                              onSettings: () {
                                _showWorkspaceSettingsDialog(
                                    context, workspace);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Section: Team Workspaces
                      if (teamWorkspaces.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.groups_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Team Workspaces',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...teamWorkspaces.map((workspace) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: WorkspaceCard(
                              workspace: workspace,
                              isSelected: workspace.id == _selectedWorkspaceId,
                              currentUserId: currentUser?.id,
                              onTap: () {
                                setState(() {
                                  _selectedWorkspaceId = workspace.id;
                                });
                                _showWorkspaceDetailsSheet(context, workspace);
                              },
                              onSettings: () {
                                _showWorkspaceSettingsDialog(
                                    context, workspace);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Empty state
                      if (workspaces.isEmpty)
                        _buildEmptyState(context),

                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkspaceDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Workspace'),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.workspaces_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No workspaces yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first workspace to get started',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Workspace'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose workspace type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _WorkspaceTypeOption(
                icon: '👤',
                label: 'Personal',
                description: 'For individual use',
                onTap: () {
                  Navigator.pop(context);
                  _createWorkspace(WorkspaceType.personal, user.id);
                },
              ),
              const SizedBox(height: 8),
              _WorkspaceTypeOption(
                icon: '👥',
                label: 'Team',
                description: 'For team collaboration',
                onTap: () {
                  Navigator.pop(context);
                  _createWorkspace(WorkspaceType.team, user.id);
                },
              ),
              const SizedBox(height: 8),
              _WorkspaceTypeOption(
                icon: '🏠',
                label: 'Family',
                description: 'For family organization',
                onTap: () {
                  Navigator.pop(context);
                  _createWorkspace(WorkspaceType.family, user.id);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWorkspace(WorkspaceType type, String userId) async {
    final workspace = WorkspaceEntity(
      id: const Uuid().v4(),
      name: _getDefaultWorkspaceName(type),
      type: type,
      ownerId: userId,
      settings: const WorkspaceSettings(),
      subscription: const WorkspaceSubscription(
        tier: WorkspaceSubscriptionTier.free,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await ref
        .read(workspaceNotifierProvider.notifier)
        .createWorkspace(workspace: workspace, userId: userId);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workspace "${workspace.name}" created!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  String _getDefaultWorkspaceName(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return 'My Personal Workspace';
      case WorkspaceType.team:
        return 'My Team Workspace';
      case WorkspaceType.family:
        return 'My Family Workspace';
      case WorkspaceType.enterprise:
        return 'My Enterprise Workspace';
    }
  }

  void _showWorkspaceDetailsSheet(BuildContext context, WorkspaceEntity workspace) {
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

                // Header
                Row(
                  children: [
                    Text(
                      workspace.icon ?? '👥',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        workspace.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (workspace.description != null)
                  Text(
                    workspace.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),

                const SizedBox(height: 24),

                // Members section
                Text(
                  'Members (${workspace.memberCount})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: workspace.members.length,
                    itemBuilder: (context, index) {
                      final member = workspace.members[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(member.userId.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(member.email ?? member.userId),
                        subtitle: Text(_getRoleLabel(member.role)),
                        trailing: _getRoleIcon(member.role, context),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWorkspaceSettingsDialog(BuildContext context, WorkspaceEntity workspace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workspace Settings'),
        content: const Text('Workspace settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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

  Widget _getRoleIcon(WorkspaceRole role, BuildContext context) {
    IconData icon;
    Color color;

    switch (role) {
      case WorkspaceRole.owner:
        icon = Icons.star_rounded;
        color = Colors.amber;
        break;
      case WorkspaceRole.admin:
        icon = Icons.admin_panel_settings_outlined;
        color = Colors.deepPurple;
        break;
      case WorkspaceRole.member:
        icon = Icons.person_outline_rounded;
        color = Colors.blue;
        break;
      case WorkspaceRole.guest:
        icon = Icons.visibility_outlined;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }
}

class _WorkspaceTypeOption extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _WorkspaceTypeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
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
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
