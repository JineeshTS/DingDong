import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/list_entity.dart';
import '../../../providers/list/list_providers.dart';

/// Share List Dialog
///
/// Dialog for sharing lists with other users
/// Features:
/// - Share via email/user ID
/// - Permission level selection (View, Comment, Edit, Admin)
/// - List of current collaborators
/// - Copy share link
/// - Revoke access
class ShareListDialog extends ConsumerStatefulWidget {
  final ListEntity list;

  const ShareListDialog({
    super.key,
    required this.list,
  });

  @override
  ConsumerState<ShareListDialog> createState() => _ShareListDialogState();
}

class _ShareListDialogState extends ConsumerState<ShareListDialog> {
  final _emailController = TextEditingController();
  ListPermission _selectedPermission = ListPermission.view;
  bool _isSharing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collaborators = widget.list.shareSettings?.collaborators ?? [];
    final shareLink = widget.list.shareSettings?.shareLink;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.share_outlined),
                  const SizedBox(width: 12),
                  Text(
                    'Share "${widget.list.name}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Share link section
                    if (shareLink != null) ...[
                      Text(
                        'Share Link',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shareLink,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontFamily: 'monospace',
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded),
                                tooltip: 'Copy Link',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: shareLink));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Link copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Add people section
                    Text(
                      'Add People',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Email input
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter email or user ID',
                        prefixIcon: Icon(Icons.person_add_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _shareWithUser(),
                    ),

                    const SizedBox(height: 12),

                    // Permission selector
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ListPermission>(
                            value: _selectedPermission,
                            decoration: const InputDecoration(
                              labelText: 'Permission',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              _buildPermissionItem(
                                ListPermission.view,
                                'Can View',
                                'Can view tasks and lists',
                              ),
                              _buildPermissionItem(
                                ListPermission.comment,
                                'Can Comment',
                                'Can view and comment on tasks',
                              ),
                              _buildPermissionItem(
                                ListPermission.edit,
                                'Can Edit',
                                'Can view, comment, and edit tasks',
                              ),
                              _buildPermissionItem(
                                ListPermission.admin,
                                'Admin',
                                'Full access including sharing',
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPermission = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isSharing ? null : _shareWithUser,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded),
                          label: const Text('Share'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Collaborators section
                    if (collaborators.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'Who has access',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${collaborators.length})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...collaborators.map((collaborator) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                collaborator.userId.substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(collaborator.userId),
                            subtitle: Text(
                              '${_getPermissionLabel(collaborator.permission)} • Shared by ${collaborator.sharedBy}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Remove access',
                              onPressed: () {
                                // TODO: Implement remove access
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Remove access coming soon'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No collaborators yet',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add people to collaborate on this list',
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
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'People you share with can access tasks in this list',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<ListPermission> _buildPermissionItem(
    ListPermission permission,
    String label,
    String description,
  ) {
    return DropdownMenuItem(
      value: permission,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareWithUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email or user ID')),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    // TODO: In a real app, you'd convert email to user ID via a lookup
    final result = await ref.read(listNotifierProvider.notifier).shareList(
          listId: widget.list.id,
          userIds: [email], // Using email as user ID for now
          permission: _selectedPermission,
        );

    setState(() {
      _isSharing = false;
    });

    if (result != null && mounted) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared with $email as ${_getPermissionLabel(_selectedPermission)}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      // Close dialog and refresh
      Navigator.pop(context);
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
}
