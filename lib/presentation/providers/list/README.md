# List Providers

Comprehensive Riverpod state management for the List domain in DingDong.

## Overview

This package provides a complete state management solution for managing lists (projects) in the application, including:

- Creating and updating lists
- Deleting lists (soft delete)
- Favorite lists management
- Sharing lists with other users
- Archive and unarchive functionality
- Multiple filtered views (active, favorites, shared, archived)
- Derived state providers for convenience
- Full integration with all 10 list use cases

## Files

### Core Files

1. **list_state.dart** - Freezed state class for list management
   - `ListState.initial()` - Initial state
   - `ListState.loading()` - Loading state with optional message
   - `ListState.loaded()` - Successfully loaded lists
   - `ListState.error()` - Error state with failure details

2. **list_notifier.dart** - StateNotifier with business logic
   - Integrates all 10 list use cases
   - Manages state transitions
   - Provides methods for all list operations

3. **list_providers.dart** - Riverpod providers
   - Use case providers (auto-dispose)
   - Main state notifier provider
   - Derived state providers for filtered views
   - Provider families for parameterized access

4. **list.dart** - Barrel export file
   - Convenient single import for all list providers

### Additional Files

5. **list_usage_examples.dart** - Comprehensive usage examples (reference only)
6. **README.md** - This documentation file

## Setup

### 1. Generate Freezed Code

Before using these providers, you must generate the freezed code:

```bash
# Using Dart
dart run build_runner build --delete-conflicting-outputs

# OR using Flutter
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `list_state.freezed.dart` which is required for the state class.

### 2. Import

```dart
import 'package:dingdong/presentation/providers/list/list.dart';
```

## Use Cases Integrated

All 10 list use cases are integrated:

1. **CreateListUseCase** - Create new lists
2. **UpdateListUseCase** - Update existing lists
3. **DeleteListUseCase** - Soft delete lists
4. **GetListsUseCase** - Fetch user's lists
5. **ToggleFavoriteListUseCase** - Toggle favorite status
6. **ArchiveListUseCase** - Archive lists
7. **UnarchiveListUseCase** - Unarchive lists
8. **ShareListUseCase** - Share lists with other users
9. **GetFavoriteListsUseCase** - Fetch favorite lists
10. **GetSharedListsUseCase** - Fetch shared lists

## Core Providers

### Main State Provider

```dart
final listNotifierProvider = StateNotifierProvider<ListNotifier, ListState>
```

The primary provider for list state management. Not auto-disposed to maintain state throughout the app lifecycle.

**Usage:**
```dart
// Watch state
final listState = ref.watch(listNotifierProvider);

// Access notifier for actions
final listNotifier = ref.read(listNotifierProvider.notifier);
```

### Use Case Providers

All auto-dispose providers for individual use cases:

- `createListProvider`
- `updateListProvider`
- `deleteListProvider`
- `getListsProvider`
- `toggleFavoriteListProvider`
- `archiveListProvider`
- `unarchiveListProvider`
- `shareListProvider`
- `getFavoriteListsProvider`
- `getSharedListsProvider`

## Derived State Providers

### List Collection Providers

- **`allListsProvider`** - All lists (including archived)
- **`activeListsProvider`** - Active lists (non-archived, non-deleted)
- **`favoriteListsProvider`** - Favorite lists only
- **`sharedListsProvider`** - Shared lists only
- **`archivedListsProvider`** - Archived lists only
- **`personalListsProvider`** - Personal (non-shared) lists
- **`smartListsProvider`** - Smart/filtered lists
- **`topLevelListsProvider`** - Top-level lists (no parent)
- **`nestedListsProvider`** - Nested lists (with parent)

### Count Providers

- **`activeListsCountProvider`** - Count of active lists
- **`favoriteListsCountProvider`** - Count of favorite lists
- **`sharedListsCountProvider`** - Count of shared lists
- **`archivedListsCountProvider`** - Count of archived lists

### Boolean Check Providers

- **`hasFavoriteListsProvider`** - Has any favorite lists
- **`hasSharedListsProvider`** - Has any shared lists
- **`hasArchivedListsProvider`** - Has any archived lists

### Sorted List Providers

- **`listsSortedByNameProvider`** - Lists sorted alphabetically
- **`listsSortedByCreationDateProvider`** - Lists sorted by creation date (newest first)
- **`listsSortedByUpdateDateProvider`** - Lists sorted by update date
- **`listsSortedBySortOrderProvider`** - Lists sorted by custom sort order

### Status Providers

- **`isListLoadingProvider`** - Current loading state
- **`listErrorProvider`** - Current error (or null)

### Provider Families

- **`listByIdProvider(String listId)`** - Get specific list by ID
- **`listsByWorkspaceProvider(String workspaceId)`** - Get lists by workspace
- **`listsByParentProvider(String parentListId)`** - Get child lists by parent ID

## Common Usage Patterns

### 1. Load Lists on Screen Init

```dart
class MyListsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends ConsumerState<MyListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listNotifierProvider.notifier).loadLists(
            userId: currentUserId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeLists = ref.watch(activeListsProvider);
    final isLoading = ref.watch(isListLoadingProvider);

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return ListView.builder(
      itemCount: activeLists.length,
      itemBuilder: (context, index) {
        final list = activeLists[index];
        return ListTile(title: Text(list.name));
      },
    );
  }
}
```

### 2. Create a New List

```dart
final newList = ListEntity(
  id: uuid.v4(),
  userId: currentUserId,
  name: 'My New List',
  description: 'Description here',
  color: '#2196F3',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdBy: currentUserId,
);

final createdList = await ref
    .read(listNotifierProvider.notifier)
    .createList(newList);

if (createdList != null) {
  // Success!
}
```

### 3. Update a List

```dart
final updatedList = existingList.copyWith(
  name: 'Updated Name',
  updatedAt: DateTime.now(),
  lastModifiedBy: currentUserId,
);

await ref.read(listNotifierProvider.notifier).updateList(updatedList);
```

### 4. Toggle Favorite

```dart
await ref.read(listNotifierProvider.notifier).toggleFavorite(listId);
```

### 5. Archive/Unarchive

```dart
// Archive
await ref.read(listNotifierProvider.notifier).archiveList(listId);

// Unarchive
await ref.read(listNotifierProvider.notifier).unarchiveList(listId);
```

### 6. Share a List

```dart
await ref.read(listNotifierProvider.notifier).shareList(
      listId: listId,
      userIds: ['user-id-1', 'user-id-2'],
      permission: ListPermission.edit,
    );
```

### 7. Delete a List

```dart
final success = await ref
    .read(listNotifierProvider.notifier)
    .deleteList(listId);
```

### 8. Display Favorites

```dart
class FavoritesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteLists = ref.watch(favoriteListsProvider);
    final favoriteCount = ref.watch(favoriteListsCountProvider);

    return Column(
      children: [
        Text('Favorites ($favoriteCount)'),
        Expanded(
          child: ListView.builder(
            itemCount: favoriteLists.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(favoriteLists[index].name));
            },
          ),
        ),
      ],
    );
  }
}
```

### 9. Handle Errors

```dart
// Method 1: Watch error provider
final error = ref.watch(listErrorProvider);
if (error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error.message)),
  );
}

// Method 2: Listen to state changes
ref.listen<ListState>(
  listNotifierProvider,
  (previous, next) {
    next.maybeWhen(
      error: (failure, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      orElse: () {},
    );
  },
);
```

### 10. Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(listNotifierProvider.notifier).refreshLists(
          userId: currentUserId,
        );
  },
  child: ListView(...),
)
```

## State Management Best Practices

### 1. Don't Auto-Dispose Main Provider

The `listNotifierProvider` is NOT auto-disposed because we want to maintain list state throughout the app lifecycle.

### 2. Use Derived Providers

Instead of filtering lists in your widgets, use the derived providers:

```dart
// ❌ Don't do this
final allLists = ref.watch(allListsProvider);
final favorites = allLists.where((l) => l.isFavorite).toList();

// ✅ Do this
final favorites = ref.watch(favoriteListsProvider);
```

### 3. Use Provider Families for Specific Items

```dart
// ✅ Efficient - only rebuilds when this specific list changes
final list = ref.watch(listByIdProvider(listId));

// ❌ Less efficient - rebuilds when any list changes
final allLists = ref.watch(allListsProvider);
final list = allLists.firstWhere((l) => l.id == listId);
```

### 4. Local Updates for Optimistic UI

```dart
// Optimistic update
ref.read(listNotifierProvider.notifier).updateListLocally(updatedList);

// Then update in background
ref.read(listNotifierProvider.notifier).updateList(updatedList);
```

### 5. Clear Errors After Handling

```dart
// After showing error to user
ref.read(listNotifierProvider.notifier).clearError();
```

## ListState Methods

The `ListState` class provides several utility methods and getters:

### Getters

- `listsOrEmpty` - Get lists or empty list
- `errorOrNull` - Get error or null
- `loadingMessageOrNull` - Get loading message or null
- `activeLists` - Get non-archived, non-deleted lists
- `favoriteLists` - Get favorite lists
- `sharedLists` - Get shared lists
- `archivedLists` - Get archived lists
- `personalLists` - Get personal (non-shared) lists
- `smartLists` - Get smart lists
- `nestedLists` - Get nested lists
- `topLevelLists` - Get top-level lists
- `activeListsCount` - Count of active lists
- `favoriteListsCount` - Count of favorite lists
- `sharedListsCount` - Count of shared lists
- `archivedListsCount` - Count of archived lists

### Methods

- `findListById(String listId)` - Find a list by ID
- `getListsByWorkspace(String workspaceId)` - Get lists by workspace
- `getListsByParent(String parentListId)` - Get child lists

## ListNotifier Methods

### Data Loading

- `loadLists({required String userId, bool includeArchived, bool includeDeleted})`
- `loadFavoriteLists(String userId)`
- `loadSharedLists(String userId)`
- `refreshLists({required String userId, bool includeArchived, bool includeDeleted})`

### CRUD Operations

- `createList(ListEntity list)` → `Future<ListEntity?>`
- `updateList(ListEntity list)` → `Future<ListEntity?>`
- `deleteList(String listId)` → `Future<bool>`

### List Actions

- `toggleFavorite(String listId)` → `Future<ListEntity?>`
- `archiveList(String listId)` → `Future<ListEntity?>`
- `unarchiveList(String listId)` → `Future<ListEntity?>`
- `shareList({required String listId, required List<String> userIds, required ListPermission permission})` → `Future<ListEntity?>`

### Local State Management

- `updateListLocally(ListEntity list)` - Update without repository call
- `addListLocally(ListEntity list)` - Add without repository call
- `removeListLocally(String listId)` - Remove without repository call
- `getListById(String listId)` → `ListEntity?` - Get from current state

### State Control

- `clearError()` - Clear error state
- `reset()` - Reset to initial state

## Error Handling

All operations return either the result or null (on error). The error is automatically stored in the state and can be accessed via:

```dart
final error = ref.watch(listErrorProvider);
```

Or by watching the state directly:

```dart
final listState = ref.watch(listNotifierProvider);
listState.maybeWhen(
  error: (failure, _) => Text(failure.message),
  orElse: () => Container(),
);
```

## Testing

### Mocking the Notifier

```dart
final mockListNotifier = MockListNotifier();

ProviderScope(
  overrides: [
    listNotifierProvider.overrideWith((ref) => mockListNotifier),
  ],
  child: MyWidget(),
);
```

### Testing State Changes

```dart
test('creating a list updates state', () async {
  final container = ProviderContainer();

  final notifier = container.read(listNotifierProvider.notifier);

  await notifier.createList(newList);

  final state = container.read(listNotifierProvider);
  expect(state.listsOrEmpty.length, 1);
});
```

## Integration with DI Container

All use cases are resolved from the DI container (`sl<T>()`). Make sure all list use cases are registered in your `injection_container.dart`:

```dart
// List use cases
sl.registerLazySingleton(() => CreateListUseCase(sl()));
sl.registerLazySingleton(() => UpdateListUseCase(sl()));
sl.registerLazySingleton(() => DeleteListUseCase(sl()));
sl.registerLazySingleton(() => GetListsUseCase(sl()));
sl.registerLazySingleton(() => ToggleFavoriteListUseCase(sl()));
sl.registerLazySingleton(() => ArchiveListUseCase(sl()));
sl.registerLazySingleton(() => UnarchiveListUseCase(sl()));
sl.registerLazySingleton(() => ShareListUseCase(sl()));
sl.registerLazySingleton(() => GetFavoriteListsUseCase(sl()));
sl.registerLazySingleton(() => GetSharedListsUseCase(sl()));
```

## See Also

- `list_usage_examples.dart` - Comprehensive usage examples (18 examples)
- Auth providers - Similar pattern for authentication
- Task providers - Similar pattern for task management

## Notes

1. **Freezed Generation**: Always run `build_runner` after modifying `list_state.dart`
2. **State Persistence**: The main provider does NOT auto-dispose to maintain state
3. **Derived Providers**: All derived providers DO auto-dispose for optimal memory management
4. **Error Handling**: Errors are stored in state and can be accessed via `listErrorProvider`
5. **Optimistic Updates**: Use local update methods for instant UI feedback
6. **Provider Families**: Use families for parameterized access to avoid unnecessary rebuilds

## Architecture

```
Presentation Layer (UI)
        ↓
    Providers (this layer)
        ↓
    Use Cases
        ↓
    Repository
        ↓
    Data Sources
```

The providers layer is the bridge between UI and business logic, managing state and coordinating use case execution.
