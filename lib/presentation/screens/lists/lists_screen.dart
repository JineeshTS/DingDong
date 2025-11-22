import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/list_entity.dart';
import '../../providers/auth/auth_providers.dart';
import '../../providers/list/list_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_indicator.dart';

/// Main lists screen showing all user lists
class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLists();
    });
  }

  void _loadLists() {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(listNotifierProvider.notifier).loadLists(userId: userId);
    }
  }

  void _onListTap(ListEntity list) {
    context.push('/list/${list.id}');
  }

  void _onCreateList() {
    _showCreateListDialog();
  }

  void _showCreateListDialog() {
    final nameController = TextEditingController();
    String selectedColor = '#2196F3';
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'List Name',
                  hint: 'Enter list name',
                  autofocus: true,
                ),
                Gap.v16,
                Text(
                  'Color',
                  style: AppTypography.labelMedium(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Gap.v8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '#2196F3', // Blue
                    '#4CAF50', // Green
                    '#FF9800', // Orange
                    '#F44336', // Red
                    '#9C27B0', // Purple
                    '#00BCD4', // Cyan
                    '#795548', // Brown
                    '#607D8B', // Blue Grey
                  ]
                      .map((color) => GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: selectedColor == color
                                    ? [
                                        BoxShadow(
                                          color: Color(int.parse(color.replaceFirst('#', '0xFF')))
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: selectedColor == color
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          ))
                      .toList(),
                ),
                Gap.v16,
                Text(
                  'Icon (optional)',
                  style: AppTypography.labelMedium(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Gap.v8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '📋',
                    '🏠',
                    '💼',
                    '🛒',
                    '💡',
                    '⭐',
                    '🎯',
                    '📚',
                    '🏃',
                    '🎨',
                    '🎵',
                    '✈️',
                  ]
                      .map((emoji) => GestureDetector(
                            onTap: () => setDialogState(() {
                              selectedIcon = selectedIcon == emoji ? null : emoji;
                            }),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selectedIcon == emoji
                                    ? AppColors.primary.withOpacity(0.1)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                border: selectedIcon == emoji
                                    ? Border.all(color: AppColors.primary)
                                    : null,
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(context);
                await _createList(
                  name: nameController.text.trim(),
                  color: selectedColor,
                  icon: selectedIcon,
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createList({
    required String name,
    required String color,
    String? icon,
  }) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final newList = ListEntity(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    );

    await ref.read(listNotifierProvider.notifier).createList(newList);
  }

  Future<void> _toggleFavorite(ListEntity list) async {
    await ref.read(listNotifierProvider.notifier).toggleFavorite(list.id);
  }

  Future<void> _deleteList(ListEntity list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"? Tasks in this list will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(listNotifierProvider.notifier).deleteList(list.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(listNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onCreateList,
            tooltip: 'Create List',
          ),
        ],
      ),
      body: _buildBody(listState, isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateList,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ListState listState, bool isDark) {
    if (listState.isLoading && listState.listsOrEmpty.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (listState.hasError) {
      return ErrorState.generic(onRetry: _loadLists);
    }

    final lists = listState.listsOrEmpty;
    final favorites = lists.where((l) => l.isFavorite && !l.isArchived).toList();
    final active = lists.where((l) => !l.isFavorite && !l.isArchived).toList();

    if (lists.isEmpty) {
      return EmptyState(
        icon: Icons.folder_outlined,
        title: 'No lists yet',
        subtitle: 'Create lists to organize your tasks',
        action: AppButton.primary(
          label: 'Create List',
          onPressed: _onCreateList,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadLists(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Favorites section
          if (favorites.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.star,
              title: 'Favorites',
              count: favorites.length,
              color: AppColors.warning,
            ),
            Gap.v8,
            ...favorites.map((list) => _ListTile(
                  list: list,
                  onTap: () => _onListTap(list),
                  onFavoriteToggle: () => _toggleFavorite(list),
                  onDelete: () => _deleteList(list),
                )),
            Gap.v24,
          ],

          // All lists section
          if (active.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.folder,
              title: 'Lists',
              count: active.length,
              color: AppColors.primary,
            ),
            Gap.v8,
            ...active.map((list) => _ListTile(
                  list: list,
                  onTap: () => _onListTap(list),
                  onFavoriteToggle: () => _toggleFavorite(list),
                  onDelete: () => _deleteList(list),
                )),
          ],

          // Bottom padding
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.labelLarge(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile widget
class _ListTile extends StatelessWidget {
  final ListEntity list;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const _ListTile({
    required this.list,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listColor = Color(int.parse(list.color.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Color/icon indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: listColor.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Center(
                  child: list.icon != null
                      ? Text(list.icon!, style: const TextStyle(fontSize: 20))
                      : Icon(Icons.folder, color: listColor),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // List info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: AppTypography.titleMedium(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (list.description != null && list.description!.isNotEmpty)
                      Text(
                        list.description!,
                        style: AppTypography.bodySmall(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Actions
              IconButton(
                icon: Icon(
                  list.isFavorite ? Icons.star : Icons.star_outline,
                  color: list.isFavorite ? AppColors.warning : null,
                ),
                onPressed: onFavoriteToggle,
                tooltip: list.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text('Delete', style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
