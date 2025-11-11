# Authentication Providers

Comprehensive Riverpod providers and state management for the Authentication domain in DingDong.

## Files Overview

### Core Files

1. **auth_state.dart** - Freezed state class for authentication
   - Defines all possible authentication states (initial, authenticated, unauthenticated, loading, error)
   - Provides helper methods for state checking
   - Immutable state management with Freezed

2. **auth_notifier.dart** - StateNotifier for authentication operations
   - Manages authentication state transitions
   - Integrates all 11 authentication use cases
   - Provides methods for all auth operations (sign in, sign up, sign out, profile updates, etc.)

3. **auth_providers.dart** - Provider definitions
   - Individual providers for all 11 authentication use cases
   - Main `authNotifierProvider` for state management
   - Derived providers for convenient state access

4. **auth.dart** - Barrel file for easy imports
   - Exports all authentication-related files
   - Single import point for auth functionality

5. **auth_usage_examples.dart** - Comprehensive usage examples
   - Real-world examples for all auth scenarios
   - Reference implementation for common patterns

## Authentication Use Cases Covered

All 11 authentication use cases are integrated:

1. ✅ Sign In with Email
2. ✅ Sign Up with Email
3. ✅ Sign In with Google
4. ✅ Sign In with Apple
5. ✅ Sign In with Microsoft
6. ✅ Sign Out
7. ✅ Get Current User
8. ✅ Update Profile
9. ✅ Update Password
10. ✅ Delete Account
11. ✅ Send Password Reset Email

## Setup Instructions

### 1. Generate Freezed Files

Run the following command to generate the required Freezed files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `auth_state.freezed.dart`.

### 2. Initialize Auth State

In your app's main widget, initialize the auth state:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dingdong/presentation/providers/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Check authentication status on app start
    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      home: authState.when(
        initial: () => const SplashScreen(),
        authenticated: (user) => const HomeScreen(),
        unauthenticated: () => const LoginScreen(),
        loading: (user, message) => const LoadingScreen(),
        error: (failure, user) => const ErrorScreen(),
      ),
    );
  }
}
```

## Quick Usage Guide

### Basic Authentication

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dingdong/presentation/providers/auth/auth.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isLoading = ref.watch(isAuthLoadingProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : () async {
        await authNotifier.signInWithEmail(
          email: 'user@example.com',
          password: 'password',
        );
      },
      child: const Text('Sign In'),
    );
  }
}
```

### Watch Current User

```dart
final user = ref.watch(currentUserProvider);
if (user != null) {
  Text('Welcome ${user.displayName}');
}
```

### Check Authentication Status

```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);
if (isAuthenticated) {
  // Show authenticated UI
}
```

### Listen to Auth State Changes

```dart
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.maybeWhen(
    authenticated: (user) => Navigator.pushNamed(context, '/home'),
    unauthenticated: () => Navigator.pushNamed(context, '/login'),
    error: (failure, _) => showError(failure.message),
    orElse: () {},
  );
});
```

## Available Providers

### Use Case Providers (Auto-Dispose)

- `signInWithEmailProvider`
- `signUpWithEmailProvider`
- `signInWithGoogleProvider`
- `signInWithAppleProvider`
- `signInWithMicrosoftProvider`
- `signOutProvider`
- `getCurrentUserProvider`
- `updateProfileProvider`
- `updatePasswordProvider`
- `deleteAccountProvider`
- `sendPasswordResetEmailProvider`

### State Providers

- `authNotifierProvider` - Main auth state notifier
- `currentUserProvider` - Current user entity
- `isAuthenticatedProvider` - Authentication status
- `isAuthLoadingProvider` - Loading state
- `authErrorProvider` - Current error if any

### Derived Providers

- `isPremiumUserProvider` - Check if user is premium
- `hasActiveSubscriptionProvider` - Check subscription status
- `userDisplayNameProvider` - User's display name
- `userEmailProvider` - User's email
- `userThemeModeProvider` - User's theme preference
- `userLocaleProvider` - User's locale preference

## State Management Pattern

The auth state follows these transitions:

```
initial
  ↓
loading ←→ authenticated
  ↓           ↓
error    unauthenticated
```

## Error Handling

All operations return proper `Failure` types:

- `AuthenticationFailure` - Invalid credentials, user not found
- `ValidationFailure` - Invalid input data
- `NetworkFailure` - Network connectivity issues
- `ServerFailure` - Backend errors
- `UnknownFailure` - Unexpected errors

Example:

```dart
final authState = ref.watch(authNotifierProvider);
if (authState.hasError) {
  final error = authState.errorOrNull;
  // Handle specific error types
  if (error is AuthenticationFailure) {
    showDialog(context, 'Invalid credentials');
  }
}
```

## Testing

The providers are designed to be easily testable:

```dart
void main() {
  test('Sign in updates state to authenticated', () async {
    final container = ProviderContainer();
    final notifier = container.read(authNotifierProvider.notifier);

    await notifier.signInWithEmail(
      email: 'test@example.com',
      password: 'password',
    );

    final state = container.read(authNotifierProvider);
    expect(state.isAuthenticated, true);
  });
}
```

## Best Practices

1. **Use derived providers** - Instead of watching the entire auth state, use specific providers like `currentUserProvider` or `isAuthenticatedProvider` for better performance.

2. **Handle loading states** - Always check `isAuthLoadingProvider` to show loading indicators.

3. **Listen for state changes** - Use `ref.listen` to react to authentication changes (navigation, dialogs, etc.).

4. **Clear errors** - Call `authNotifier.clearError()` to reset error states after showing them to users.

5. **Auto-dispose** - Most providers are auto-disposed, but `authNotifierProvider` persists throughout the app lifecycle.

6. **Refresh user data** - Call `authNotifier.refreshUser()` after external changes to user data.

## Architecture

```
UI Layer (Widgets)
      ↓
Providers Layer (Riverpod)
      ↓
Use Cases Layer (Business Logic)
      ↓
Repository Layer (Data Access)
      ↓
Data Sources (Firebase, Isar)
```

The authentication providers follow Clean Architecture principles, keeping the UI layer completely separated from business logic and data access.

## Dependencies

Required packages in `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  freezed_annotation: ^2.4.1
  dartz: ^0.10.1

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
```

## Next Steps

1. Generate Freezed files with build_runner
2. Initialize auth state in your app's main widget
3. Create login/register screens using the examples
4. Implement auth state listeners for navigation
5. Add protected routes that check authentication status
6. Customize error handling based on your UI requirements

## Support

For more examples, see `auth_usage_examples.dart` which contains comprehensive real-world usage patterns for:
- Login/Register screens
- Social authentication
- Profile management
- Password changes
- Account deletion
- Protected routes
- Premium features

---

**Note**: This implementation follows the DingDong project's clean architecture pattern and integrates seamlessly with the existing use cases and dependency injection setup.
