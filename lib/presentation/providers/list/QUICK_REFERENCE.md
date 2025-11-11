# List Providers Quick Reference

## Import

```dart
import 'package:dingdong/presentation/providers/list/list.dart';
```

## Main Provider

```dart
// Watch state
final listState = ref.watch(listNotifierProvider);

// Read notifier (for actions)
final notifier = ref.read(listNotifierProvider.notifier);
```

## Common Operations

### Load Lists

```dart
await notifier.loadLists(userId: userId);
await notifier.loadFavoriteLists(userId);
await notifier.loadSharedLists(userId);
await notifier.refreshLists(userId: userId);
```

### Create

```dart
final list = ListEntity(/* ... */);
final created = await notifier.createList(list);
```

### Update

```dart
final updated = list.copyWith(name: 'New Name');
await notifier.updateList(updated);
```

### Delete

```dart
final success = await notifier.deleteList(listId);
```

### Toggle Favorite

```dart
await notifier.toggleFavorite(listId);
```

### Archive/Unarchive

```dart
await notifier.archiveList(listId);
await notifier.unarchiveList(listId);
```

### Share

```dart
await notifier.shareList(
  listId: listId,
  userIds: ['user1', 'user2'],
  permission: ListPermission.edit,
);
```

## List Collection Providers

```dart
final all = ref.watch(allListsProvider);
final active = ref.watch(activeListsProvider);
final favorites = ref.watch(favoriteListsProvider);
final shared = ref.watch(sharedListsProvider);
final archived = ref.watch(archivedListsProvider);
final personal = ref.watch(personalListsProvider);
final smart = ref.watch(smartListsProvider);
final topLevel = ref.watch(topLevelListsProvider);
final nested = ref.watch(nestedListsProvider);
```

## Count Providers

```dart
final activeCount = ref.watch(activeListsCountProvider);
final favoriteCount = ref.watch(favoriteListsCountProvider);
final sharedCount = ref.watch(sharedListsCountProvider);
final archivedCount = ref.watch(archivedListsCountProvider);
```

## Boolean Providers

```dart
final hasFavorites = ref.watch(hasFavoriteListsProvider);
final hasShared = ref.watch(hasSharedListsProvider);
final hasArchived = ref.watch(hasArchivedListsProvider);
```

## Sorted Providers

```dart
final byName = ref.watch(listsSortedByNameProvider);
final byCreation = ref.watch(listsSortedByCreationDateProvider);
final byUpdate = ref.watch(listsSortedByUpdateDateProvider);
final byOrder = ref.watch(listsSortedBySortOrderProvider);
```

## Status Providers

```dart
final isLoading = ref.watch(isListLoadingProvider);
final error = ref.watch(listErrorProvider);
```

## Provider Families

```dart
// Single list
final list = ref.watch(listByIdProvider(listId));

// Lists by workspace
final workspaceLists = ref.watch(listsByWorkspaceProvider(workspaceId));

// Child lists
final children = ref.watch(listsByParentProvider(parentId));
```

## State Checks

```dart
listState.isLoading
listState.isLoaded
listState.isInitial
listState.hasError
listState.listsOrEmpty
listState.errorOrNull
listState.loadingMessageOrNull
```

## Local Updates (Optimistic UI)

```dart
notifier.updateListLocally(list);
notifier.addListLocally(list);
notifier.removeListLocally(listId);
```

## Error Handling

```dart
// Method 1: Watch error provider
if (ref.watch(listErrorProvider) != null) {
  // Show error
}

// Method 2: Listen to state
ref.listen<ListState>(listNotifierProvider, (prev, next) {
  next.maybeWhen(
    error: (failure, _) => showError(failure.message),
    orElse: () {},
  );
});

// Method 3: Clear error
notifier.clearError();
```

## Complete Example

```dart
class MyListsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyListsScreen> createState() => _State();
}

class _State extends ConsumerState<MyListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listNotifierProvider.notifier).loadLists(
        userId: 'user-id',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(activeListsProvider);
    final isLoading = ref.watch(isListLoadingProvider);

    if (isLoading) return const CircularProgressIndicator();

    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return ListTile(
          title: Text(list.name),
          trailing: IconButton(
            icon: Icon(list.isFavorite ? Icons.star : Icons.star_border),
            onPressed: () => ref
                .read(listNotifierProvider.notifier)
                .toggleFavorite(list.id),
          ),
        );
      },
    );
  }
}
```

## Important Notes

1. Run `dart run build_runner build --delete-conflicting-outputs` before first use
2. Main provider does NOT auto-dispose (maintains state)
3. All derived providers DO auto-dispose (optimal memory)
4. Use derived providers instead of filtering in widgets
5. Use provider families for specific items to avoid rebuilds
6. Errors are stored in state, access via `listErrorProvider`
