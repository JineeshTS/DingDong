/// List Providers Usage Examples
///
/// This file provides comprehensive examples of how to use the list providers
/// in various scenarios throughout the application.
///
/// DO NOT import this file in production code. It's for reference only.

// ignore_for_file: unused_local_variable, unreachable_from_main, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/list_entity.dart';
import 'list.dart';

// ============================================================================
// Example 1: Basic List Display
// ============================================================================

class ListsScreenExample extends ConsumerWidget {
  const ListsScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(listNotifierProvider);
    final activeLists = ref.watch(activeListsProvider);
    final isLoading = ref.watch(isListLoadingProvider);

    // Show loading indicator
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if present
    final error = ref.watch(listErrorProvider);
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${error.message}'),
            ElevatedButton(
              onPressed: () {
                ref.read(listNotifierProvider.notifier).clearError();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (activeLists.isEmpty) {
      return const Center(
        child: Text('No lists yet. Create your first list!'),
      );
    }

    // Display lists
    return ListView.builder(
      itemCount: activeLists.length,
      itemBuilder: (context, index) {
        final list = activeLists[index];
        return ListTile(
          leading: Icon(
            list.isFavorite ? Icons.star : Icons.list,
            color: Color(int.parse(list.color.replaceFirst('#', '0xFF'))),
          ),
          title: Text(list.name),
          subtitle: list.description != null ? Text(list.description!) : null,
          trailing: list.isShared ? const Icon(Icons.people) : null,
          onTap: () {
            // Navigate to list detail
          },
        );
      },
    );
  }
}

// ============================================================================
// Example 2: Loading Lists on Screen Init
// ============================================================================

class ListsManagerExample extends ConsumerStatefulWidget {
  const ListsManagerExample({super.key});

  @override
  ConsumerState<ListsManagerExample> createState() =>
      _ListsManagerExampleState();
}

class _ListsManagerExampleState extends ConsumerState<ListsManagerExample> {
  @override
  void initState() {
    super.initState();
    // Load lists when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = 'current-user-id'; // Get from auth provider
      ref.read(listNotifierProvider.notifier).loadLists(
            userId: userId,
            includeArchived: false,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ListsScreenExample();
  }
}

// ============================================================================
// Example 3: Creating a New List
// ============================================================================

class CreateListExample extends ConsumerWidget {
  const CreateListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final userId = 'current-user-id'; // Get from auth provider

        final newList = ListEntity(
          id: 'generated-uuid', // Use uuid package: uuid.v4()
          userId: userId,
          name: 'My New List',
          description: 'A list for my tasks',
          color: '#2196F3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: userId,
        );

        final createdList = await ref
            .read(listNotifierProvider.notifier)
            .createList(newList);

        if (createdList != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('List created successfully!')),
          );
        } else {
          // Error is already in state, show it from error provider
          final error = ref.read(listErrorProvider);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create list: ${error?.message}')),
          );
        }
      },
      child: const Text('Create List'),
    );
  }
}

// ============================================================================
// Example 4: Updating a List
// ============================================================================

class UpdateListExample extends ConsumerWidget {
  final ListEntity list;

  const UpdateListExample({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final updatedList = list.copyWith(
          name: 'Updated List Name',
          description: 'Updated description',
          updatedAt: DateTime.now(),
          lastModifiedBy: 'current-user-id',
        );

        final result = await ref
            .read(listNotifierProvider.notifier)
            .updateList(updatedList);

        if (result != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('List updated successfully!')),
          );
        }
      },
      child: const Text('Update List'),
    );
  }
}

// ============================================================================
// Example 5: Toggling Favorite Status
// ============================================================================

class ToggleFavoriteExample extends ConsumerWidget {
  final ListEntity list;

  const ToggleFavoriteExample({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(list.isFavorite ? Icons.star : Icons.star_border),
      onPressed: () async {
        await ref
            .read(listNotifierProvider.notifier)
            .toggleFavorite(list.id);
      },
    );
  }
}

// ============================================================================
// Example 6: Displaying Favorite Lists
// ============================================================================

class FavoriteListsExample extends ConsumerWidget {
  const FavoriteListsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteLists = ref.watch(favoriteListsProvider);
    final favoriteCount = ref.watch(favoriteListsCountProvider);
    final hasFavorites = ref.watch(hasFavoriteListsProvider);

    if (!hasFavorites) {
      return const Center(
        child: Text('No favorite lists yet'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Favorites ($favoriteCount)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: favoriteLists.length,
            itemBuilder: (context, index) {
              final list = favoriteLists[index];
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(list.name),
                subtitle: list.description != null
                    ? Text(list.description!)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Example 7: Sharing a List
// ============================================================================

class ShareListExample extends ConsumerWidget {
  final ListEntity list;

  const ShareListExample({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // User IDs to share with (from user selection dialog)
        final userIdsToShareWith = ['user-id-1', 'user-id-2'];

        final sharedList = await ref
            .read(listNotifierProvider.notifier)
            .shareList(
              listId: list.id,
              userIds: userIdsToShareWith,
              permission: ListPermission.edit,
            );

        if (sharedList != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'List shared with ${userIdsToShareWith.length} users'),
            ),
          );
        }
      },
      child: const Text('Share List'),
    );
  }
}

// ============================================================================
// Example 8: Displaying Shared Lists
// ============================================================================

class SharedListsExample extends ConsumerWidget {
  const SharedListsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedLists = ref.watch(sharedListsProvider);
    final sharedCount = ref.watch(sharedListsCountProvider);
    final hasShared = ref.watch(hasSharedListsProvider);

    if (!hasShared) {
      return const Center(
        child: Text('No shared lists'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Shared with me ($sharedCount)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sharedLists.length,
            itemBuilder: (context, index) {
              final list = sharedLists[index];
              return ListTile(
                leading: const Icon(Icons.people),
                title: Text(list.name),
                subtitle: Text('Created by ${list.createdBy}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Example 9: Archive and Unarchive Lists
// ============================================================================

class ArchiveListExample extends ConsumerWidget {
  final ListEntity list;

  const ArchiveListExample({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(list.isArchived ? Icons.unarchive : Icons.archive),
      onPressed: () async {
        if (list.isArchived) {
          await ref
              .read(listNotifierProvider.notifier)
              .unarchiveList(list.id);
        } else {
          await ref
              .read(listNotifierProvider.notifier)
              .archiveList(list.id);
        }
      },
    );
  }
}

// ============================================================================
// Example 10: Displaying Archived Lists
// ============================================================================

class ArchivedListsExample extends ConsumerWidget {
  const ArchivedListsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedLists = ref.watch(archivedListsProvider);
    final archivedCount = ref.watch(archivedListsCountProvider);
    final hasArchived = ref.watch(hasArchivedListsProvider);

    if (!hasArchived) {
      return const Center(
        child: Text('No archived lists'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Archived ($archivedCount)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: archivedLists.length,
            itemBuilder: (context, index) {
              final list = archivedLists[index];
              return ListTile(
                leading: const Icon(Icons.archive),
                title: Text(list.name),
                trailing: IconButton(
                  icon: const Icon(Icons.unarchive),
                  onPressed: () {
                    ref
                        .read(listNotifierProvider.notifier)
                        .unarchiveList(list.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Example 11: Deleting a List
// ============================================================================

class DeleteListExample extends ConsumerWidget {
  final ListEntity list;

  const DeleteListExample({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete List'),
            content: Text('Are you sure you want to delete "${list.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final success = await ref
              .read(listNotifierProvider.notifier)
              .deleteList(list.id);

          if (success) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('List deleted')),
            );
          }
        }
      },
    );
  }
}

// ============================================================================
// Example 12: Using List by ID Provider
// ============================================================================

class ListDetailExample extends ConsumerWidget {
  final String listId;

  const ListDetailExample({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(listByIdProvider(listId));

    if (list == null) {
      return const Center(child: Text('List not found'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (list.description != null) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(list.description!),
              const SizedBox(height: 16),
            ],
            Text(
              'Created: ${list.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Updated: ${list.updatedAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 13: Nested Lists / Sublists
// ============================================================================

class NestedListsExample extends ConsumerWidget {
  final String parentListId;

  const NestedListsExample({super.key, required this.parentListId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childLists = ref.watch(listsByParentProvider(parentListId));

    if (childLists.isEmpty) {
      return const Center(
        child: Text('No sublists'),
      );
    }

    return ListView.builder(
      itemCount: childLists.length,
      itemBuilder: (context, index) {
        final list = childLists[index];
        return ListTile(
          leading: const Icon(Icons.subdirectory_arrow_right),
          title: Text(list.name),
          subtitle: Text('Sublist'),
        );
      },
    );
  }
}

// ============================================================================
// Example 14: Sorted Lists Display
// ============================================================================

class SortedListsExample extends ConsumerWidget {
  const SortedListsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Choose your preferred sorting
    final sortedLists = ref.watch(listsSortedByNameProvider);
    // or: ref.watch(listsSortedByCreationDateProvider);
    // or: ref.watch(listsSortedByUpdateDateProvider);
    // or: ref.watch(listsSortedBySortOrderProvider);

    return ListView.builder(
      itemCount: sortedLists.length,
      itemBuilder: (context, index) {
        final list = sortedLists[index];
        return ListTile(
          title: Text(list.name),
        );
      },
    );
  }
}

// ============================================================================
// Example 15: Refresh Lists (Pull to Refresh)
// ============================================================================

class RefreshListsExample extends ConsumerWidget {
  const RefreshListsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLists = ref.watch(activeListsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        final userId = 'current-user-id'; // Get from auth provider
        await ref.read(listNotifierProvider.notifier).refreshLists(
              userId: userId,
            );
      },
      child: ListView.builder(
        itemCount: activeLists.length,
        itemBuilder: (context, index) {
          final list = activeLists[index];
          return ListTile(
            title: Text(list.name),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Example 16: Workspace Lists
// ============================================================================

class WorkspaceListsExample extends ConsumerWidget {
  final String workspaceId;

  const WorkspaceListsExample({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceLists = ref.watch(listsByWorkspaceProvider(workspaceId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Lists in this workspace (${workspaceLists.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: workspaceLists.length,
            itemBuilder: (context, index) {
              final list = workspaceLists[index];
              return ListTile(
                title: Text(list.name),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Example 17: Complete List Management Screen with Tabs
// ============================================================================

class CompleteListsManagementExample extends ConsumerStatefulWidget {
  const CompleteListsManagementExample({super.key});

  @override
  ConsumerState<CompleteListsManagementExample> createState() =>
      _CompleteListsManagementExampleState();
}

class _CompleteListsManagementExampleState
    extends ConsumerState<CompleteListsManagementExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load lists on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = 'current-user-id'; // Get from auth provider
      ref.read(listNotifierProvider.notifier).loadLists(userId: userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = ref.watch(activeListsCountProvider);
    final favoriteCount = ref.watch(favoriteListsCountProvider);
    final sharedCount = ref.watch(sharedListsCountProvider);
    final archivedCount = ref.watch(archivedListsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All ($activeCount)'),
            Tab(text: 'Favorites ($favoriteCount)'),
            Tab(text: 'Shared ($sharedCount)'),
            Tab(text: 'Archived ($archivedCount)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ListsScreenExample(),
          FavoriteListsExample(),
          SharedListsExample(),
          ArchivedListsExample(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create list dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// Example 18: Listening to State Changes
// ============================================================================

class StateListenerExample extends ConsumerWidget {
  const StateListenerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to state changes and react
    ref.listen<ListState>(
      listNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          error: (failure, _) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
    );

    return const ListsScreenExample();
  }
}
