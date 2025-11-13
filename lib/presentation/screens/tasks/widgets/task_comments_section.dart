import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/comment_entity.dart';
import '../../../providers/comment/comment_providers.dart';
import '../../../providers/auth_provider.dart';

/// Task Comments Section
///
/// Displays all comments for a task with:
/// - Threaded replies
/// - @mentions
/// - Reactions
/// - Add comment functionality
class TaskCommentsSection extends ConsumerStatefulWidget {
  final String taskId;

  const TaskCommentsSection({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskCommentsSection> createState() => _TaskCommentsSectionState();
}

class _TaskCommentsSectionState extends ConsumerState<TaskCommentsSection> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load comments on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentNotifierProvider.notifier).loadTaskComments(widget.taskId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(taskCommentsProvider(widget.taskId));
    final currentUser = ref.watch(currentUserProvider);
    final isLoading = ref.watch(isCommentLoadingProvider);

    // Filter out replies (only show top-level comments)
    final topLevelComments = comments.where((c) => !c.isReply).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.comment_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${comments.length})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Add comment field
        if (currentUser != null)
          _buildAddCommentField(context, currentUser.id),

        const SizedBox(height: 16),

        // Comments list
        if (isLoading && comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (topLevelComments.isEmpty)
          _buildEmptyState(context)
        else
          ...topLevelComments.map((comment) {
            final replies = comments
                .where((c) => c.parentCommentId == comment.id)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CommentCard(
                comment: comment,
                replies: replies,
                taskId: widget.taskId,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddCommentField(BuildContext context, String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(userId.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              onPressed: _isSubmitting ? null : () => _submitComment(userId),
              tooltip: 'Post Comment',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No comments yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Be the first to comment',
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

  Future<void> _submitComment(String userId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final comment = CommentEntity(
      id: const Uuid().v4(),
      taskId: widget.taskId,
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(commentNotifierProvider.notifier).createComment(comment);

    setState(() {
      _isSubmitting = false;
    });

    _commentController.clear();
  }
}

class _CommentCard extends ConsumerWidget {
  final CommentEntity comment;
  final List<CommentEntity> replies;
  final String taskId;

  const _CommentCard({
    required this.comment,
    required this.replies,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment.userId.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
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
                if (comment.isEdited)
                  Text(
                    'edited',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Comment content
            Text(
              comment.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            // Reactions and actions
            Row(
              children: [
                // Reactions
                if (comment.totalReactions > 0) ...[
                  Wrap(
                    spacing: 4,
                    children: comment.reactions.entries.map((entry) {
                      return Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                ],

                // Actions
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement react
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reactions coming soon')),
                    );
                  },
                  icon: const Icon(Icons.add_reaction_outlined, size: 16),
                  label: const Text('React'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement reply
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reply coming soon')),
                    );
                  },
                  icon: const Icon(Icons.reply_rounded, size: 16),
                  label: const Text('Reply'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),

            // Replies
            if (replies.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              ...replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(left: 32, top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text(
                          reply.userId.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply.userId,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDateTime(reply.createdAt),
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
                            const SizedBox(height: 4),
                            Text(
                              reply.content,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
