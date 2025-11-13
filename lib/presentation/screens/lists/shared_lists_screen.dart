import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/list/list_providers.dart';
import '../../providers/auth_provider.dart';
import 'widgets/list_collaborators_widget.dart';
import 'widgets/share_list_dialog.dart';

/// Shared Lists Screen
///
/// Displays lists that have been shared with the current user
class SharedListsScreen extends ConsumerStatefulWidget {
  const SharedListsScreen({super.key});

  @override
  ConsumerState<SharedListsScreen> createState() => _SharedListsScreenState();
}

class _SharedListsScreenState extends ConsumerState<SharedListsScreen> {
  @override
  void initState() {
    super.initState();
    // Load shared lists on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(listNotifierProvider.notifier).loadSharedLists(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(listNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Filter only shared lists
    final sharedLists = listState.lists.where((list) => list.isShared).toList();

    // Show error if any
    ref.listen(listErrorProvider, (previous, next) {
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
        title: const Text('Shared Lists'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (currentUser != null) {
                ref
                    .read(listNotifierProvider.notifier)
                    .loadSharedLists(currentUser.id);
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
                  .read(listNotifierProvider.notifier)
                  .loadSharedLists(currentUser.id);
            }
          },
          child: listState.isLoading && sharedLists.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : sharedLists.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sharedLists.length,
                      itemBuilder: (context, index) {
                        final list = sharedLists[index];
                        final collaborators = list.shareSettings?.collaborators ?? [];
                        final userPermission = collaborators
                            .where((c) => c.userId == currentUser?.id)
                            .firstOrNull
                            ?.permission;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              // TODO: Navigate to list detail
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening "${list.name}"...'),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // List icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _getListColor(list.color)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            list.icon ?? '📋',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // List name and task count
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              list.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${list.taskCount} ${list.taskCount == 1 ? 'task' : 'tasks'}',
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
                                      ),

                                      // Share icon button
                                      IconButton(
                                        icon: const Icon(Icons.share_outlined),
                                        tooltip: 'Share Settings',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ShareListDialog(list: list),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Collaborators and permission
                                  Row(
                                    children: [
                                      // Collaborators avatars
                                      ListCollaboratorsWidget(list: list),

                                      const Spacer(),

                                      // User's permission badge
                                      if (userPermission != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPermissionColor(
                                                    userPermission)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getPermissionColor(
                                                      userPermission)
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getPermissionIcon(
                                                    userPermission),
                                                size: 14,
                                                color: _getPermissionColor(
                                                    userPermission),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getPermissionLabel(
                                                    userPermission),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: _getPermissionColor(
                                                          userPermission),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No shared lists',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lists shared with you will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getListColor(String? colorString) {
    try {
      if (colorString == null) return const Color(0xFF2196F3);
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  String _getPermissionLabel(ListPermission permission) {
    switch (permission) {
      case ListPermission.view:
        return 'Viewer';
      case ListPermission.comment:
        return 'Commenter';
      case ListPermission.edit:
        return 'Editor';
      case ListPermission.admin:
        return 'Admin';
    }
  }

  IconData _getPermissionIcon(ListPermission permission) {
    switch (permission) {
      case ListPermission.view:
        return Icons.visibility_outlined;
      case ListPermission.comment:
        return Icons.comment_outlined;
      case ListPermission.edit:
        return Icons.edit_outlined;
      case ListPermission.admin:
        return Icons.admin_panel_settings_outlined;
    }
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
