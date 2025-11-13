import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/workspace_entity.dart';
import '../../../providers/workspace/workspace_providers.dart';
import '../../../config/theme/design_system.dart';

/// Workspace Switcher Widget
///
/// Dropdown/modal for switching between workspaces
class WorkspaceSwitcher extends ConsumerWidget {
  final String? currentWorkspaceId;
  final Function(WorkspaceEntity) onWorkspaceSelected;

  const WorkspaceSwitcher({
    super.key,
    this.currentWorkspaceId,
    required this.onWorkspaceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(activeWorkspacesProvider);
    final currentWorkspace = currentWorkspaceId != null
        ? ref.watch(workspaceByIdProvider(currentWorkspaceId!))
        : null;

    if (workspaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _showWorkspaceSwitcherModal(context, ref, workspaces),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentWorkspace != null) ...[
              Text(
                currentWorkspace.icon ??
                    _getDefaultIcon(currentWorkspace.type),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  currentWorkspace.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              const Icon(Icons.workspaces_outlined),
              const SizedBox(width: 8),
              Text(
                'Select Workspace',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showWorkspaceSwitcherModal(
    BuildContext context,
    WidgetRef ref,
    List<WorkspaceEntity> workspaces,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
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

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Switch Workspace',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${workspaces.length} ${workspaces.length == 1 ? 'workspace' : 'workspaces'}',
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

              const Divider(height: 1),

              // Workspace list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaces[index];
                    final isSelected = workspace.id == currentWorkspaceId;

                    return _WorkspaceSwitcherItem(
                      workspace: workspace,
                      isSelected: isSelected,
                      onTap: () {
                        Navigator.pop(context);
                        onWorkspaceSelected(workspace);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
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
}

class _WorkspaceSwitcherItem extends StatelessWidget {
  final WorkspaceEntity workspace;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkspaceSwitcherItem({
    required this.workspace,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceColor = _parseColor(workspace.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: workspaceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: workspaceColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    workspace.icon ?? _getDefaultIcon(workspace.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_getTypeLabel(workspace.type)} • ${workspace.memberCount} ${workspace.memberCount == 1 ? 'member' : 'members'}',
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

              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
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
}
