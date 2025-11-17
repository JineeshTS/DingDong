# CLAUDE.md - AI Assistant Guide for DingDong

**Project**: DingDong - Next-Generation Task Management Application
**Architecture**: Clean Architecture with Flutter
**Last Updated**: November 17, 2025
**Current Phase**: Presentation Layer (100% Complete - 118/118 providers)

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Design Patterns](#architecture--design-patterns)
3. [Codebase Structure](#codebase-structure)
4. [Development Workflow](#development-workflow)
5. [State Management](#state-management)
6. [Code Conventions](#code-conventions)
7. [Testing Strategy](#testing-strategy)
8. [Common Tasks](#common-tasks)
9. [Error Handling](#error-handling)
10. [Code Generation](#code-generation)
11. [File Organization Rules](#file-organization-rules)
12. [Git Workflow](#git-workflow)
13. [Important References](#important-references)
14. [AI Assistant Guidelines](#ai-assistant-guidelines)

---

## 🎯 Project Overview

### What is DingDong?

DingDong is a **production-ready, full-featured** task management application built with Flutter, designed to surpass competitors like TickTick with:

- **AI-Powered Features**: Image recognition for task creation from photos, handwritten notes, receipts
- **Cross-Platform**: iOS, Android, Web, macOS, Windows, Linux
- **Real-time Sync**: Offline-first architecture with Firebase Cloud Firestore
- **50+ Integrations**: Google Calendar, Slack, Notion, email clients, and more
- **Enterprise Features**: Team workspaces, collaboration, advanced analytics

### Key Metrics

- **Total Dart Files**: 258+
- **Total Lines of Code**: ~52,500+
- **Domains**: 11 (Auth, Task, List, User, Tag, Reminder, Comment, Attachment, Habit, FocusSession, Workspace)
- **Use Cases**: 118 business logic operations
- **Providers**: 118 Riverpod state management providers
- **Repositories**: 11 with offline-first logic
- **Test Coverage Target**: 80%+

### Development Status

**Overall Progress: 92% Complete**

✅ **Phase 1**: Project Foundation (100%)
✅ **Phase 2**: Data Layer (100%)
✅ **Phase 3**: Business Logic Layer (100%)
✅ **Phase 4**: Presentation Layer - State Management (100%)
✅ **Phase 5**: Views & Visualization (100%)
✅ **Phase 6**: Productivity Features (100%)
✅ **Phase 7**: Collaboration & Teams (100%)
✅ **Phase 8**: AI & Automation (100%)
🔄 **Phase 9**: Integrations (16% - In Progress)
⏳ **Phase 10**: Cross-Platform (Pending)
⏳ **Phase 11**: Testing & QA (Pending)
⏳ **Phase 12**: Deployment (Pending)

**Current Focus**: Completing Google Calendar and Outlook integrations (Phase 9)

---

## 🏗 Architecture & Design Patterns

### Clean Architecture Layers

```
┌─────────────────────────────────────────────┐
│         Presentation Layer (UI)              │
│  • Screens, Widgets, Routes                  │
│  • Providers (Riverpod State Management)     │
│  • State Notifiers                           │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Domain Layer (Business Logic)        │
│  • Entities (Business Models)                │
│  • Use Cases (Business Operations)           │
│  • Repository Interfaces                     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Data Layer (Data Access)             │
│  • Repository Implementations                │
│  • Remote Data Sources (Firebase)            │
│  • Local Data Sources (Isar)                 │
│  • Data Models (JSON Serialization)          │
└─────────────────────────────────────────────┘
```

### Core Design Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: Higher layers don't depend on lower layers directly
3. **Offline-First**: All data available locally, sync in background
4. **Immutability**: All data models are immutable (Freezed)
5. **Functional Error Handling**: Using `Either<Failure, Result>` from Dartz
6. **Type Safety**: Comprehensive use of Dart's strong typing

### Key Technologies

- **State Management**: Riverpod 2.4.9 (NOT Provider, NOT BLoC)
- **Navigation**: GoRouter 13.0.0
- **Dependency Injection**: GetIt 7.6.4
- **Local Database**: Isar 3.1.0+1 (NOT Hive, NOT sqflite)
- **Remote Database**: Firebase Cloud Firestore
- **Code Generation**: build_runner, Freezed, json_serializable, Isar generator
- **Functional Programming**: Dartz (for Either, Option)

### Design System

DingDong uses a comprehensive design system for consistent UI/UX across all platforms. **ALWAYS use design system components instead of raw Material widgets.**

**Design Tokens** (`lib/config/theme/`):
- `app_colors.dart` - Color palette (AppColors.primary, AppColors.error, etc.)
- `app_typography.dart` - Text styles (AppTypography.headlineLarge, AppTypography.bodyMedium, etc.)
- `app_spacing.dart` - Spacing constants (AppSpacing.pagePadding, AppSpacing.verticalSpaceMD, etc.)
- `app_constants.dart` - App-wide constants (breakpoints, dimensions, validation rules)
- `app_theme.dart` - ThemeData configuration
- `theme_service.dart` - Theme management service

**Common Widgets** (`lib/presentation/common/widgets/`):
- `AppButton` - Primary, secondary, outlined, text button variants
- `AppTextField` - Consistent text input with validation
- `AppPasswordField` - Password input with visibility toggle
- `AppCard` - Consistent card containers
- `AppLoading` - Loading indicators
- `QuickAddTaskDialog` - Quick task creation dialog

**Usage Example**:
```dart
import 'package:dingdong/config/theme/design_system.dart';
import 'package:dingdong/presentation/common/widgets/widgets.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            Text('Hello', style: AppTypography.headlineLarge),
            AppSpacing.verticalSpaceMD,
            AppButton(
              onPressed: () {},
              child: Text('Click Me'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**IMPORTANT**:
- ✅ DO use design system components (AppButton, AppTextField, AppColors, AppTypography)
- ❌ DON'T use raw Material widgets (ElevatedButton, TextField, Colors.blue, etc.)
- ✅ DO follow the spacing system (AppSpacing constants)
- ❌ DON'T use hardcoded spacing values (e.g., SizedBox(height: 16))

---

## 📁 Codebase Structure

### Directory Layout

```
lib/
├── core/                           # Core utilities and shared code
│   ├── constants/                  # App-wide constants
│   │   ├── app_constants.dart     # General constants
│   │   ├── firebase_constants.dart # Firebase collection names
│   │   └── storage_constants.dart  # Local storage keys
│   ├── di/                        # Dependency Injection
│   │   └── injection_container.dart # GetIt setup (520 lines)
│   ├── errors/                    # Error handling
│   │   ├── exceptions.dart        # Exception classes
│   │   └── failures.dart          # Failure classes (for Either)
│   ├── utils/                     # Utility functions
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── logger.dart
│   └── theme/                     # Theme data
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── domain/                         # Business Logic Layer
│   ├── entities/                   # Domain entities (11 entities)
│   │   ├── user_entity.dart       # User business model
│   │   ├── task_entity.dart       # Task with 30+ properties
│   │   ├── list_entity.dart       # List/Project entity
│   │   ├── tag_entity.dart
│   │   ├── reminder_entity.dart
│   │   ├── comment_entity.dart
│   │   ├── attachment_entity.dart
│   │   ├── habit_entity.dart
│   │   ├── focus_session_entity.dart
│   │   ├── workspace_entity.dart
│   │   └── activity_log_entity.dart
│   ├── repositories/               # Repository interfaces
│   │   ├── auth_repository.dart   # 15 methods
│   │   ├── task_repository.dart   # 40+ methods
│   │   ├── list_repository.dart   # 24 methods
│   │   └── ... (11 total)
│   └── usecases/                   # Business operations (118 use cases)
│       ├── auth/                   # 11 auth use cases
│       ├── task/                   # 25 task use cases
│       ├── list/                   # 10 list use cases
│       ├── user/                   # 10 user use cases
│       ├── reminder/               # 8 reminder use cases
│       ├── tag/                    # 8 tag use cases
│       ├── comment/                # 8 comment use cases
│       ├── attachment/             # 8 attachment use cases
│       ├── habit/                  # 10 habit use cases
│       ├── focus_session/          # 10 focus session use cases
│       └── workspace/              # 10 workspace use cases
│
├── data/                           # Data Access Layer
│   ├── models/                     # Data models (21 models)
│   │   ├── user_model.dart        # Freezed + JSON serialization
│   │   ├── task_model.dart
│   │   └── ... (Firestore models)
│   ├── datasources/
│   │   ├── remote/                 # Firebase data sources (11 files)
│   │   │   ├── firebase_auth_remote_datasource.dart
│   │   │   ├── firebase_task_remote_datasource.dart
│   │   │   └── ... (Real-time listeners, CRUD)
│   │   └── local/                  # Isar data sources (11 files)
│   │       ├── isar_user_local_datasource.dart
│   │       ├── isar_task_local_datasource.dart
│   │       └── ... (Offline storage, sync tracking)
│   └── repositories/               # Repository implementations (11 files)
│       ├── auth_repository_impl.dart
│       ├── task_repository_impl.dart
│       └── ... (Offline-first logic)
│
├── presentation/                   # Presentation Layer
│   ├── providers/                  # Riverpod providers (118 providers)
│   │   ├── auth/
│   │   │   ├── auth_state.dart         # Freezed state
│   │   │   ├── auth_notifier.dart      # StateNotifier (14 methods)
│   │   │   ├── auth_providers.dart     # Provider definitions
│   │   │   ├── auth.dart               # Barrel file
│   │   │   ├── auth_usage_examples.dart
│   │   │   └── README.md               # Comprehensive guide
│   │   ├── task/                       # 25 task providers
│   │   ├── list/                       # 10 list providers
│   │   ├── user/                       # 10 user providers
│   │   └── ... (11 domain provider folders)
│   ├── screens/                    # Screen widgets
│   │   ├── auth/                   # Login, Register, etc.
│   │   ├── tasks/                  # Task management screens
│   │   ├── calendar/               # Calendar views
│   │   └── ... (Screen folders)
│   ├── widgets/                    # Reusable widgets
│   │   └── common/                 # Shared widgets
│   ├── routes/                     # Navigation
│   │   ├── app_router.dart        # GoRouter configuration
│   │   └── main_scaffold.dart     # Main app scaffold with bottom nav
│   └── common/                     # Common presentation code
│       └── widgets/                # Common widgets library
│           ├── app_button.dart    # Design system button
│           ├── app_text_field.dart # Design system text field
│           ├── app_card.dart      # Design system card
│           ├── app_loading.dart   # Loading indicators
│           ├── quick_add_task_dialog.dart # Quick task creation
│           └── widgets.dart       # Barrel file
│
├── config/                         # Configuration
│   └── theme/                      # Design System
│       ├── design_system.dart     # Barrel file (import this!)
│       ├── app_colors.dart        # Color palette
│       ├── app_typography.dart    # Text styles
│       ├── app_spacing.dart       # Spacing system
│       ├── app_constants.dart     # UI constants
│       ├── app_theme.dart         # ThemeData config
│       └── theme_service.dart     # Theme management
│
└── main.dart                       # App entry point
```

### Important Files by Size

1. `injection_container.dart` - 520 lines (DI setup)
2. `task_notifier.dart` - 1,255 lines (Task state management)
3. `firebase_task_remote_datasource.dart` - ~1,200 lines
4. `isar_task_local_datasource.dart` - ~800 lines
5. `task_repository_impl.dart` - ~900 lines

---

## 🔄 Development Workflow

### CRITICAL: Standard Operating Procedures (SOP)

**⚠️ MANDATORY PROCESS - NO EXCEPTIONS**

This project follows **STRICT** development procedures outlined in `SOP.md`. You MUST follow these steps:

#### 1. Feature Development Process

1. **Review Requirements**
   - Read `REQUIREMENTS.md` for feature specs
   - Check `WBS.md` for task breakdown
   - Check `PROGRESS.md` for current status

2. **Design & Plan**
   - Design architecture/approach
   - Identify dependencies
   - Update todo list

3. **Implement Feature**
   - Write code following Clean Architecture
   - Follow Dart style guide
   - Add inline comments for complex logic
   - Keep commits atomic

4. **Write Tests** (MANDATORY)
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for flows
   - Target: 80%+ coverage

5. **Test EVERYTHING** (MANDATORY)
   - Run ALL automated tests
   - Test the new feature manually
   - Test ALL previous features manually
   - Test on all target platforms
   - NO EXCEPTIONS

6. **Fix Issues ONE AT A TIME**
   - Document issue clearly
   - Root Cause Analysis (RCA)
   - Impact Analysis
   - Implement fix
   - Test fix + run ALL tests
   - Test ALL features again
   - NEVER batch fixes

7. **Quality Gates** (Must Pass All)
   - ✅ All tests passing (100%)
   - ✅ All previous features working (100%)
   - ✅ No linting errors
   - ✅ Code formatted
   - ✅ Documentation updated
   - ✅ No known bugs
   - ✅ Performance benchmarks met

### 2. Daily Development Commands

```bash
# Get dependencies
flutter pub get

# Code generation (Freezed, JSON, Isar, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development (auto-generate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run on device
flutter run

# Run in debug mode
flutter run --debug

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

### 3. Development Best Practices

**DO:**
- ✅ Follow Clean Architecture strictly
- ✅ Use Riverpod for ALL state management
- ✅ Make all models immutable (Freezed)
- ✅ Use Either<Failure, Result> for error handling
- ✅ Write comprehensive tests
- ✅ Document complex logic
- ✅ Use meaningful names
- ✅ Keep functions small (< 20 lines preferred)
- ✅ Run code generation after model changes
- ✅ Commit frequently with clear messages

**DON'T:**
- ❌ Skip testing (NEVER)
- ❌ Batch multiple fixes together
- ❌ Mix presentation and business logic
- ❌ Use mutable state
- ❌ Ignore linting warnings
- ❌ Create technical debt
- ❌ Take shortcuts
- ❌ Push broken code

---

## 🎨 State Management

### Riverpod Pattern (Standard Across All Domains)

Each domain follows this exact structure:

```
presentation/providers/{domain}/
├── {domain}_state.dart           # Freezed state definition
├── {domain}_notifier.dart        # StateNotifier implementation
├── {domain}_providers.dart       # Provider definitions
├── {domain}.dart                 # Barrel file (exports all)
├── {domain}_usage_examples.dart  # Comprehensive examples
└── README.md                     # Documentation
```

### State Definition Pattern

```dart
// Example: auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/errors/failures.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.authenticated({
    required UserEntity user,
  }) = _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.loading({
    UserEntity? user,
    String? message,
  }) = _Loading;

  const factory AuthState.error({
    required Failure failure,
    UserEntity? user,
  }) = _Error;
}

// Extension for convenience
extension AuthStateX on AuthState {
  bool get isAuthenticated => this is _Authenticated;
  bool get isLoading => this is _Loading;
  bool get hasError => this is _Error;

  UserEntity? get userOrNull => maybeWhen(
    authenticated: (user) => user,
    loading: (user, _) => user,
    error: (_, user) => user,
    orElse: () => null,
  );

  Failure? get errorOrNull => maybeWhen(
    error: (failure, _) => failure,
    orElse: () => null,
  );
}
```

### StateNotifier Pattern

```dart
// Example: auth_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/sign_in_with_email_usecase.dart';
// ... import all use cases
import '../../../core/errors/failures.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  // ... inject all use cases

  AuthNotifier({
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    // ... all use cases as named parameters
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        // ... initialize all
        super(const AuthState.initial());

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = AuthState.loading(message: 'Signing in...');

    // Execute use case
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: email, password: password),
    );

    // Handle result
    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  // ... implement all methods
}
```

### Provider Definition Pattern

```dart
// Example: auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

// ============================================================
// USE CASE PROVIDERS (Auto-dispose for memory efficiency)
// ============================================================

final signInWithEmailProvider = Provider.autoDispose(
  (ref) => getIt<SignInWithEmailUseCase>(),
);

// ... all use case providers

// ============================================================
// STATE NOTIFIER PROVIDER (Main state management)
// ============================================================

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    // ... all use cases
  ),
);

// ============================================================
// DERIVED PROVIDERS (Convenience accessors)
// ============================================================

/// Current authenticated user (null if not authenticated)
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).userOrNull;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Check if auth operation is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// Current auth error if any
final authErrorProvider = Provider<Failure?>((ref) {
  return ref.watch(authNotifierProvider).errorOrNull;
});
```

### How to Use Providers in UI

```dart
// In a StatelessWidget
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state
    final authState = ref.watch(authNotifierProvider);

    // Or watch derived providers
    final isLoading = ref.watch(isAuthLoadingProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Listen to state changes for side effects
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user) {
          // Navigate to home
          context.go('/home');
        },
        error: (failure, _) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: authState.when(
        initial: () => const Center(child: Text('Welcome')),
        loading: (_, message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
        authenticated: (user) => Text('Hello ${user.displayName}'),
        unauthenticated: () => const LoginForm(),
        error: (failure, _) => ErrorWidget(failure.message),
      ),
    );
  }
}

// In a StatefulWidget
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    // Read the notifier (not watch, since we're in a callback)
    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Column(
      children: [
        TextField(controller: _emailController),
        TextField(controller: _passwordController, obscureText: true),
        ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
```

### Completed Provider Domains

All 11 domains have complete state management:

1. ✅ **Auth** (11 providers) - `lib/presentation/providers/auth/`
2. ✅ **Task** (25 providers) - `lib/presentation/providers/task/`
3. ✅ **List** (10 providers) - `lib/presentation/providers/list/`
4. ✅ **User** (10 providers) - `lib/presentation/providers/user/`
5. ✅ **Reminder** (8 providers) - `lib/presentation/providers/reminder/`
6. ✅ **Tag** (8 providers) - `lib/presentation/providers/tag/`
7. ✅ **Comment** (8 providers) - `lib/presentation/providers/comment/`
8. ✅ **Attachment** (8 providers) - `lib/presentation/providers/attachment/`
9. ✅ **Habit** (10 providers) - `lib/presentation/providers/habit/`
10. ✅ **FocusSession** (10 providers) - `lib/presentation/providers/focus_session/`
11. ✅ **Workspace** (10 providers) - `lib/presentation/providers/workspace/`

Each domain has a README.md with comprehensive documentation and examples.

---

## 📝 Code Conventions

### Naming Conventions

**Files:**
- Entities: `{name}_entity.dart` (e.g., `task_entity.dart`)
- Models: `{name}_model.dart` (e.g., `task_model.dart`)
- Use Cases: `{action}_{entity}_usecase.dart` (e.g., `create_task_usecase.dart`)
- Repositories: `{entity}_repository.dart` (interface), `{entity}_repository_impl.dart` (implementation)
- Data Sources: `{provider}_{entity}_{type}_datasource.dart` (e.g., `firebase_task_remote_datasource.dart`)
- Providers: `{entity}_providers.dart`, `{entity}_notifier.dart`, `{entity}_state.dart`
- Screens: `{name}_screen.dart` (e.g., `login_screen.dart`)
- Widgets: `{name}_widget.dart` or descriptive name

**Classes:**
- Entities: `{Name}Entity` (e.g., `TaskEntity`)
- Models: `{Name}Model` (e.g., `TaskModel`)
- Use Cases: `{Action}{Entity}UseCase` (e.g., `CreateTaskUseCase`)
- Repositories: `{Entity}Repository` (interface), `{Entity}RepositoryImpl` (implementation)
- Data Sources: `{Provider}{Entity}{Type}DataSource` (e.g., `FirebaseTaskRemoteDataSource`)
- Notifiers: `{Entity}Notifier` (e.g., `AuthNotifier`)
- States: `{Entity}State` (e.g., `AuthState`)

**Variables & Methods:**
- Use camelCase: `currentUser`, `signInWithEmail`, `isDueToday`
- Booleans: Start with `is`, `has`, `can`: `isCompleted`, `hasSubtasks`, `canEdit`
- Private: Prefix with underscore: `_firestore`, `_signInWithEmail`

### Code Style

```dart
// Good - Immutable entity with business logic
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final DateTime? dueDate;
  final TaskStatus status;

  const TaskEntity({
    required this.id,
    required this.title,
    this.dueDate,
    this.status = TaskStatus.todo,
  });

  // Business logic methods
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [id, title, dueDate, status];
}

// Good - Use case with Either pattern
class CreateTaskUseCase {
  final TaskRepository _repository;

  const CreateTaskUseCase(this._repository);

  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) async {
    // Validation
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Title cannot be empty'));
    }

    // Execute
    return await _repository.createTask(/* ... */);
  }
}

// Good - Repository with offline-first logic
class TaskRepositoryImpl implements TaskRepository {
  final FirebaseTaskRemoteDataSource _remoteDataSource;
  final IsarTaskLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      // Always write to local first
      await _localDataSource.createTask(task.toModel());

      // Try to sync to remote if online
      if (await _networkInfo.isConnected) {
        final remoteTask = await _remoteDataSource.createTask(task.toModel());
        // Update local with server data
        await _localDataSource.updateTask(remoteTask);
        return Right(remoteTask.toEntity());
      }

      // Return local data if offline
      return Right(task);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}
```

### Documentation Standards

```dart
/// Creates a new task in the system.
///
/// This use case handles task creation with validation and business rules:
/// - Validates required fields (title, userId)
/// - Sets default values (createdAt, updatedAt, status)
/// - Ensures title is not empty or whitespace only
/// - Applies user-specific business rules (premium features, limits)
///
/// Returns [TaskEntity] on success, or [Failure] on error:
/// - [ValidationFailure] if validation fails
/// - [AuthenticationFailure] if user is not authenticated
/// - [SubscriptionFailure] if premium feature requires subscription
/// - [ServerFailure] if remote operation fails
/// - [NetworkFailure] if network is unavailable
///
/// Example:
/// ```dart
/// final result = await createTask(CreateTaskParams(
///   title: 'Buy groceries',
///   dueDate: DateTime.now().add(Duration(days: 1)),
/// ));
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (task) => print('Created: ${task.title}'),
/// );
/// ```
class CreateTaskUseCase {
  // ...
}
```

---

## 🧪 Testing Strategy

### Test Structure

```
test/
├── unit/                       # Unit tests
│   ├── domain/
│   │   ├── entities/          # Entity tests
│   │   └── usecases/          # Use case tests
│   ├── data/
│   │   ├── models/            # Model tests
│   │   ├── repositories/      # Repository tests
│   │   └── datasources/       # Data source tests
│   └── core/                  # Core utility tests
├── widget/                     # Widget tests
│   ├── screens/               # Screen widget tests
│   └── widgets/               # Component tests
└── integration/                # Integration tests
    ├── auth_flow_test.dart
    ├── task_flow_test.dart
    └── ...
```

### Test Examples

```dart
// Unit test example - Use Case
void main() {
  late CreateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = CreateTaskUseCase(mockRepository);
  });

  group('CreateTaskUseCase', () {
    final tParams = CreateTaskParams(
      title: 'Test Task',
      userId: 'user-123',
    );

    final tTask = TaskEntity(
      id: 'task-123',
      title: 'Test Task',
      userId: 'user-123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should create task successfully', () async {
      // Arrange
      when(() => mockRepository.createTask(any()))
          .thenAnswer((_) async => Right(tTask));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(tTask));
      verify(() => mockRepository.createTask(any())).called(1);
    });

    test('should return ValidationFailure when title is empty', () async {
      // Arrange
      final invalidParams = CreateTaskParams(title: '', userId: 'user-123');

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<ValidationFailure, TaskEntity>>());
      verifyNever(() => mockRepository.createTask(any()));
    });
  });
}

// Widget test example
void main() {
  testWidgets('LoginScreen shows error on failed login', (tester) async {
    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Enter credentials
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'wrong_password',
    );

    // Tap login button
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/usecases/create_task_usecase_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## ❌ Error Handling

### Failure Types

```dart
// lib/core/errors/failures.dart

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic exception;

  const Failure({required this.message, this.code, this.exception});
}

class ServerFailure extends Failure { /* ... */ }
class CacheFailure extends Failure { /* ... */ }
class NetworkFailure extends Failure { /* ... */ }
class AuthenticationFailure extends Failure { /* ... */ }
class ValidationFailure extends Failure { /* ... */ }
class PermissionFailure extends Failure { /* ... */ }
class SubscriptionFailure extends Failure { /* ... */ }
class UnknownFailure extends Failure { /* ... */ }
```

### Exception Handling Pattern

```dart
// In Repository Implementation
@override
Future<Either<Failure, TaskEntity>> getTask(String taskId) async {
  try {
    // Try remote first if online
    if (await _networkInfo.isConnected) {
      final remoteTask = await _remoteDataSource.getTask(taskId);
      // Cache locally
      await _localDataSource.updateTask(remoteTask);
      return Right(remoteTask.toEntity());
    }

    // Fall back to local
    final localTask = await _localDataSource.getTask(taskId);
    return Right(localTask.toEntity());

  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, code: e.code));
  } on CacheException catch (e) {
    return Left(CacheFailure(message: e.message));
  } on SocketException {
    return Left(const NetworkFailure(message: 'No internet connection'));
  } on FormatException {
    return Left(const ValidationFailure(message: 'Invalid data format'));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString(), exception: e));
  }
}
```

### UI Error Handling

```dart
// In a screen
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.maybeWhen(
    error: (failure, _) {
      String errorMessage;

      if (failure is AuthenticationFailure) {
        errorMessage = 'Invalid email or password';
      } else if (failure is NetworkFailure) {
        errorMessage = 'No internet connection';
      } else if (failure is ValidationFailure) {
        errorMessage = failure.message;
      } else {
        errorMessage = 'An unexpected error occurred';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    },
    orElse: () {},
  );
});
```

---

## 🔧 Code Generation

### When to Run Code Generation

Run build_runner when you modify:
- **Freezed models** (any @freezed class)
- **JSON serializable models** (any @JsonSerializable class)
- **Isar schemas** (any @collection class)
- **Riverpod providers** (if using riverpod_generator - not currently used)

### Code Generation Commands

```bash
# One-time build (recommended after git pull or major changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes - great for active development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild (if you have issues)
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generated Files Pattern

For each source file, generated files are created:
- `auth_state.dart` → `auth_state.freezed.dart`
- `task_model.dart` → `task_model.freezed.dart` + `task_model.g.dart`
- `isar_task_schema.dart` → `isar_task_schema.g.dart`

**IMPORTANT**: Never edit generated files manually. They will be overwritten.

### Freezed Pattern

```dart
// Before generation
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated({required UserEntity user}) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}

// After running build_runner, auth_state.freezed.dart is generated
// and provides: when, map, maybeWhen, maybeMap, copyWith, ==, hashCode
```

---

## 📂 File Organization Rules

### When Creating New Files

1. **Follow the layer structure**: Determine which layer (domain/data/presentation) the code belongs to

2. **Use correct naming**: Follow the naming conventions above

3. **Create barrel files**: For each folder with multiple files, create an index file:
   ```dart
   // lib/domain/entities/entities.dart
   export 'task_entity.dart';
   export 'user_entity.dart';
   export 'list_entity.dart';
   // ... all entities
   ```

4. **Group related files**: Keep related files together in the same folder

5. **One class per file**: Generally one public class per file (except for small helper classes)

### Domain Layer Rules

- **Entities** must:
  - Extend `Equatable`
  - Be immutable (all fields final)
  - Contain ONLY business logic (no UI, no data access)
  - Have meaningful computed properties (getters)

- **Use Cases** must:
  - Have a single `call` method
  - Accept a params object (or NoParams)
  - Return `Future<Either<Failure, Result>>`
  - Contain business validation logic
  - Be injected via constructor

- **Repository Interfaces** must:
  - Define method signatures only
  - Return `Future<Either<Failure, Entity>>`
  - Use domain entities (not models)

### Data Layer Rules

- **Models** must:
  - Use `@freezed` annotation
  - Implement JSON serialization (`@JsonSerializable`)
  - Have `toEntity()` and `fromEntity()` methods
  - Mirror entity structure but with serialization

- **Data Sources** must:
  - Handle raw data access (Firebase, Isar, API)
  - Throw exceptions (not return Either)
  - Use models (not entities)
  - Be injected via constructor

- **Repository Implementations** must:
  - Implement the repository interface
  - Handle offline-first logic
  - Convert exceptions to failures
  - Convert models to entities

### Presentation Layer Rules

- **Providers** must:
  - Follow the domain provider pattern
  - Use Riverpod (not BLoC, not Provider)
  - Have state, notifier, and providers files
  - Include comprehensive documentation

- **Screens** must:
  - Be stateless when possible (use ConsumerWidget)
  - Use StatefulWidget only when necessary
  - Watch providers for state
  - Use `ref.read` for callbacks
  - Handle navigation

- **Widgets** must:
  - Be reusable
  - Accept required data via constructor
  - Be presentation-only (no business logic)

---

## 🔀 Git Workflow

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `perf`: Performance improvements
- `chore`: Build/tooling changes

**Examples:**
```bash
feat(tasks): add recurring task support
fix(auth): resolve Google Sign-In on iOS
refactor(data): optimize offline sync logic
test(domain): add use case tests for task creation
docs(readme): update setup instructions
```

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch (if team environment)
- `feature/*`: Feature branches
- `fix/*`: Bug fix branches
- `hotfix/*`: Critical fixes

### Before Committing

```bash
# 1. Format code
flutter format lib/

# 2. Analyze code
flutter analyze

# 3. Run tests
flutter test

# 4. Check for uncommitted generated files
git status

# 5. Commit
git add .
git commit -m "feat(tasks): add task creation UI"

# 6. Push
git push origin feature/task-creation
```

---

## 📚 Important References

### Documentation Files (MUST READ)

1. **REQUIREMENTS.md** - Complete feature requirements
2. **WBS.md** - Work Breakdown Structure (2000+ tasks)
3. **SOP.md** - Standard Operating Procedures (MANDATORY PROCESS)
4. **SETUP_GUIDE.md** - Development environment setup
5. **PROGRESS.md** - Current development status
6. **CHANGELOG.md** - Version history and changes

### Provider Documentation

Each domain has comprehensive documentation:
- `lib/presentation/providers/auth/README.md` - Auth providers guide
- `lib/presentation/providers/task/README.md` - Task providers guide
- `lib/presentation/providers/list/README.md` - List providers guide
- ... (all 11 domains)

### Key Code References

- **Dependency Injection**: `lib/core/di/injection_container.dart`
- **Error Handling**: `lib/core/errors/failures.dart`, `lib/core/errors/exceptions.dart`
- **Theme System**: `lib/core/theme/app_theme.dart`
- **Navigation**: `lib/presentation/routes/app_router.dart`

---

## 🤖 AI Assistant Guidelines

### When Working on This Project

**ALWAYS:**

1. ✅ **Read SOP.md first** - Understand the mandatory development process
2. ✅ **Check PROGRESS.md** - Know what's already done and what's next
3. ✅ **Follow Clean Architecture** - Respect layer boundaries strictly
4. ✅ **Use existing patterns** - Look at similar code for consistency
5. ✅ **Write tests** - No exceptions, test everything
6. ✅ **Run code generation** - After any model/freezed changes
7. ✅ **Update documentation** - Keep README files current
8. ✅ **Test all features** - Not just new code, everything
9. ✅ **One issue at a time** - Never batch fixes
10. ✅ **Ask for clarification** - If requirements are unclear

**NEVER:**

1. ❌ **Skip testing** - This is the #1 rule
2. ❌ **Mix layers** - Don't put business logic in UI, data access in domain
3. ❌ **Use different state management** - Only Riverpod
4. ❌ **Ignore linting** - Fix all warnings
5. ❌ **Create mutable state** - Everything is immutable
6. ❌ **Batch multiple fixes** - One at a time only
7. ❌ **Skip quality gates** - All must pass
8. ❌ **Take shortcuts** - This is a production app, not an MVP

### Understanding the Current State

**Completed (100%):**
- ✅ Project foundation and architecture
- ✅ All 11 domain entities with business logic
- ✅ All 21 Freezed data models
- ✅ All 11 repository interfaces
- ✅ All 22 data sources (Firebase + Isar)
- ✅ All 11 repository implementations
- ✅ All 118 use cases
- ✅ Dependency injection setup
- ✅ All 118 Riverpod providers
- ✅ All 11 state notifiers

**In Progress:**
- ⏳ UI screens implementation
- ⏳ Widget library
- ⏳ Navigation flow
- ⏳ Theme customization

**Not Started:**
- ❌ Testing (unit, widget, integration)
- ❌ Advanced features (AI, integrations)
- ❌ Platform-specific implementations
- ❌ Performance optimization

### Common Tasks

#### Task 1: Add a New Feature

```bash
# 1. Check requirements and WBS
# Read REQUIREMENTS.md and WBS.md for specifications

# 2. Identify the domain and use case
# Determine which domain (Task, List, User, etc.) this belongs to

# 3. Implement in layers (bottom-up):

# a) Domain Layer (if new entity/use case needed)
# - Create/update entity in lib/domain/entities/
# - Create use case in lib/domain/usecases/{domain}/
# - Update repository interface in lib/domain/repositories/

# b) Data Layer (if new data needed)
# - Create/update model in lib/data/models/
# - Update data sources in lib/data/datasources/
# - Update repository implementation in lib/data/repositories/
# - Run code generation: flutter pub run build_runner build --delete-conflicting-outputs

# c) Presentation Layer
# - Update state in lib/presentation/providers/{domain}/{domain}_state.dart
# - Add method to notifier in lib/presentation/providers/{domain}/{domain}_notifier.dart
# - Add provider in lib/presentation/providers/{domain}/{domain}_providers.dart
# - Create UI in lib/presentation/screens/ or lib/presentation/widgets/
# - Run code generation if needed

# 4. Write tests
# - Unit tests for use case
# - Widget tests for UI
# - Integration tests for flow

# 5. Run quality checks
flutter analyze
flutter format lib/
flutter test

# 6. Update documentation
# - Update PROGRESS.md
# - Update relevant README files
# - Update CHANGELOG.md

# 7. Commit with proper message
git add .
git commit -m "feat(domain): add new feature"
```

#### Task 2: Fix a Bug

```bash
# 1. Document the issue
# - What: Describe the bug
# - Where: Which file/component
# - How to reproduce: Steps
# - Expected vs actual behavior

# 2. Root Cause Analysis (RCA)
# - Trace execution flow
# - Identify the source
# - Check related code

# 3. Impact Analysis
# - Which components are affected?
# - What are the dependencies?
# - What could break if we fix this?

# 4. Implement fix (ONE ISSUE AT A TIME)
# - Make the fix
# - Run all tests
# - Test all features manually

# 5. Verify
# - Bug is fixed
# - No regressions
# - All tests pass

# 6. Document and commit
# - Update CHANGELOG.md
# - Commit with fix(scope): message
```

#### Task 3: Add a New Screen

```bash
# 1. Create screen file
# lib/presentation/screens/{feature}/{screen_name}_screen.dart

# 2. Use ConsumerWidget or ConsumerStatefulWidget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/{domain}/{domain}.dart';

class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final state = ref.watch(someNotifierProvider);

    // Listen for side effects
    ref.listen<SomeState>(someNotifierProvider, (previous, next) {
      // Handle navigation, dialogs, snackbars
    });

    return Scaffold(
      appBar: AppBar(title: const Text('New Screen')),
      body: state.when(
        // Handle states
      ),
    );
  }
}

# 3. Add route
# Update lib/presentation/routes/app_router.dart

# 4. Test the screen
# Create widget test in test/widget/screens/

# 5. Update documentation
```

### Performance Considerations

- **Minimize provider watches**: Only watch what you need
- **Use .select()**: When watching specific fields
  ```dart
  final userName = ref.watch(currentUserProvider.select((user) => user?.displayName));
  ```
- **Use .autoDispose**: For providers that aren't always needed
- **Lazy loading**: Load data when needed, not all at once
- **Pagination**: For large lists
- **Debouncing**: For search and text input
- **Image optimization**: Use cached_network_image with proper sizing
- **Memory management**: Dispose controllers and listeners

### Debugging Tips

```dart
// Add logger to track state changes
import 'package:logger/logger.dart';

final logger = Logger();

class TaskNotifier extends StateNotifier<TaskState> {
  // ...

  Future<void> createTask(CreateTaskParams params) async {
    logger.d('Creating task: ${params.title}');
    state = TaskState.loading();

    final result = await _createTask(params);

    result.fold(
      (failure) {
        logger.e('Failed to create task: ${failure.message}');
        state = TaskState.error(failure: failure);
      },
      (task) {
        logger.i('Task created successfully: ${task.id}');
        state = TaskState.success(task: task);
      },
    );
  }
}

// Use Flutter DevTools
// - Provider inspector
// - Widget inspector
// - Performance overlay
// - Network inspector

// Print state changes in debug mode
ref.listen<TaskState>(taskNotifierProvider, (previous, next) {
  if (kDebugMode) {
    print('Task state changed: $previous → $next');
  }
});
```

### Code Review Checklist

Before submitting code, verify:

- [ ] Follows Clean Architecture (correct layer)
- [ ] Uses Riverpod for state management
- [ ] All models are immutable (Freezed)
- [ ] Error handling uses Either<Failure, Result>
- [ ] All tests written and passing
- [ ] No linting warnings
- [ ] Code is formatted
- [ ] Documentation updated
- [ ] No hardcoded values (use constants)
- [ ] No console logs in production code
- [ ] Proper null safety
- [ ] Meaningful variable/method names
- [ ] Functions are small and focused
- [ ] No code duplication
- [ ] Comments explain WHY, not WHAT
- [ ] CHANGELOG.md updated
- [ ] PROGRESS.md updated

---

## 🎓 Learning Resources

### Clean Architecture
- [Uncle Bob's Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

### Riverpod
- [Official Riverpod Documentation](https://riverpod.dev)
- [Riverpod Architecture Guide](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)

### Freezed
- [Freezed Package](https://pub.dev/packages/freezed)
- [Freezed with Riverpod](https://codewithandrea.com/articles/flutter-freezed-data-classes/)

### Firebase
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

### Isar
- [Isar Database](https://isar.dev)
- [Isar Quick Start](https://isar.dev/tutorials/quickstart.html)

---

## 📞 Support & Questions

### Where to Look for Answers

1. **This file (CLAUDE.md)** - Comprehensive guide for AI assistants
2. **SOP.md** - Process and procedures
3. **README.md** - Project overview
4. **Provider README files** - Domain-specific guidance
5. **Existing code** - Look at similar implementations
6. **Comments in code** - Important context and notes

### When Stuck

1. Check if similar functionality exists
2. Review the architecture diagrams
3. Read the use case for business logic
4. Check the provider documentation
5. Look at the tests for examples
6. Ask for clarification if requirements are unclear

---

**Last Updated**: November 17, 2025
**Maintained By**: DingDong Development Team
**Version**: 1.0.0

---

## 🚀 Quick Start for AI Assistants

```bash
# 1. Understand the project
cat CLAUDE.md          # This file
cat SOP.md             # Mandatory procedures
cat PROGRESS.md        # Current state

# 2. Set up environment
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run

# 4. Before any code changes
flutter analyze
flutter test

# 5. After code changes
flutter format lib/
flutter analyze
flutter test
git commit -m "type(scope): description"

# 6. Remember
# - Follow Clean Architecture
# - Use Riverpod for state
# - Write tests (NO EXCEPTIONS)
# - Test everything (new + old features)
# - One issue at a time
# - Update documentation
```

**Welcome to DingDong! Build with quality, test thoroughly, deliver excellence.** 🎉
