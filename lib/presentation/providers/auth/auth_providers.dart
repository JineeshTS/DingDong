import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_email_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_apple_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_microsoft_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_with_email_usecase.dart';
import '../../../domain/usecases/auth/update_password_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for SignInWithEmailUseCase
///
/// Handles email/password authentication
final signInWithEmailProvider = Provider.autoDispose<SignInWithEmailUseCase>(
  (ref) => sl<SignInWithEmailUseCase>(),
);

/// Provider for SignUpWithEmailUseCase
///
/// Handles email/password registration
final signUpWithEmailProvider = Provider.autoDispose<SignUpWithEmailUseCase>(
  (ref) => sl<SignUpWithEmailUseCase>(),
);

/// Provider for SignInWithGoogleUseCase
///
/// Handles Google OAuth authentication
final signInWithGoogleProvider = Provider.autoDispose<SignInWithGoogleUseCase>(
  (ref) => sl<SignInWithGoogleUseCase>(),
);

/// Provider for SignInWithAppleUseCase
///
/// Handles Apple OAuth authentication
final signInWithAppleProvider = Provider.autoDispose<SignInWithAppleUseCase>(
  (ref) => sl<SignInWithAppleUseCase>(),
);

/// Provider for SignInWithMicrosoftUseCase
///
/// Handles Microsoft OAuth authentication
final signInWithMicrosoftProvider =
    Provider.autoDispose<SignInWithMicrosoftUseCase>(
  (ref) => sl<SignInWithMicrosoftUseCase>(),
);

/// Provider for SignOutUseCase
///
/// Handles user sign out
final signOutProvider = Provider.autoDispose<SignOutUseCase>(
  (ref) => sl<SignOutUseCase>(),
);

/// Provider for GetCurrentUserUseCase
///
/// Retrieves the currently authenticated user
final getCurrentUserProvider = Provider.autoDispose<GetCurrentUserUseCase>(
  (ref) => sl<GetCurrentUserUseCase>(),
);

/// Provider for UpdateProfileUseCase
///
/// Handles user profile updates (display name, photo URL)
final updateProfileProvider = Provider.autoDispose<UpdateProfileUseCase>(
  (ref) => sl<UpdateProfileUseCase>(),
);

/// Provider for UpdatePasswordUseCase
///
/// Handles password change operations
final updatePasswordProvider = Provider.autoDispose<UpdatePasswordUseCase>(
  (ref) => sl<UpdatePasswordUseCase>(),
);

/// Provider for DeleteAccountUseCase
///
/// Handles permanent account deletion
final deleteAccountProvider = Provider.autoDispose<DeleteAccountUseCase>(
  (ref) => sl<DeleteAccountUseCase>(),
);

/// Provider for SendPasswordResetEmailUseCase
///
/// Sends password reset email to user
final sendPasswordResetEmailProvider =
    Provider.autoDispose<SendPasswordResetEmailUseCase>(
  (ref) => sl<SendPasswordResetEmailUseCase>(),
);

// ============================================================================
// Auth State Notifier Provider
// ============================================================================

/// Main authentication state notifier provider
///
/// This is the primary provider for authentication state management.
/// It should NOT be auto-disposed as we want to maintain authentication
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final authState = ref.watch(authNotifierProvider);
/// final authNotifier = ref.read(authNotifierProvider.notifier);
///
/// // Check authentication status
/// if (authState.isAuthenticated) {
///   final user = authState.userOrNull;
///   // Show authenticated UI
/// }
///
/// // Perform authentication actions
/// await authNotifier.signInWithEmail(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(
      signInWithEmailUseCase: ref.read(signInWithEmailProvider),
      signUpWithEmailUseCase: ref.read(signUpWithEmailProvider),
      signInWithGoogleUseCase: ref.read(signInWithGoogleProvider),
      signInWithAppleUseCase: ref.read(signInWithAppleProvider),
      signInWithMicrosoftUseCase: ref.read(signInWithMicrosoftProvider),
      signOutUseCase: ref.read(signOutProvider),
      getCurrentUserUseCase: ref.read(getCurrentUserProvider),
      updateProfileUseCase: ref.read(updateProfileProvider),
      updatePasswordUseCase: ref.read(updatePasswordProvider),
      deleteAccountUseCase: ref.read(deleteAccountProvider),
      sendPasswordResetEmailUseCase: ref.read(sendPasswordResetEmailProvider),
    );
  },
);

// ============================================================================
// Derived State Providers
// ============================================================================
// These providers derive specific values from the auth state for convenience

/// Provider that exposes only the current user
///
/// Returns null if user is not authenticated
///
/// Usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   Text('Welcome ${user.displayName}');
/// }
/// ```
final currentUserProvider = Provider.autoDispose((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userOrNull;
});

/// Provider that exposes authentication status
///
/// Usage:
/// ```dart
/// final isAuthenticated = ref.watch(isAuthenticatedProvider);
/// if (isAuthenticated) {
///   // Navigate to home screen
/// } else {
///   // Show login screen
/// }
/// ```
final isAuthenticatedProvider = Provider.autoDispose<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

/// Provider that exposes loading state
///
/// Useful for showing loading indicators
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isAuthLoadingProvider);
/// if (isLoading) {
///   CircularProgressIndicator();
/// }
/// ```
final isAuthLoadingProvider = Provider.autoDispose<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

/// Provider that exposes authentication error
///
/// Returns null if no error
///
/// Usage:
/// ```dart
/// final error = ref.watch(authErrorProvider);
/// if (error != null) {
///   SnackBar(content: Text(error.message));
/// }
/// ```
final authErrorProvider = Provider.autoDispose((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.errorOrNull;
});

/// Provider for checking if user is premium
///
/// Returns false if user is not authenticated
///
/// Usage:
/// ```dart
/// final isPremium = ref.watch(isPremiumUserProvider);
/// if (isPremium) {
///   // Show premium features
/// }
/// ```
final isPremiumUserProvider = Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isPremium ?? false;
});

/// Provider for checking if user has active subscription
///
/// Returns false if user is not authenticated
///
/// Usage:
/// ```dart
/// final hasActiveSubscription = ref.watch(hasActiveSubscriptionProvider);
/// if (!hasActiveSubscription) {
///   // Show upgrade prompt
/// }
/// ```
final hasActiveSubscriptionProvider = Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isSubscriptionActive ?? false;
});

/// Provider for user's display name
///
/// Returns 'Guest' if user is not authenticated or has no display name
///
/// Usage:
/// ```dart
/// final displayName = ref.watch(userDisplayNameProvider);
/// Text('Hello, $displayName');
/// ```
final userDisplayNameProvider = Provider.autoDispose<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? 'Guest';
});

/// Provider for user's email
///
/// Returns null if user is not authenticated
///
/// Usage:
/// ```dart
/// final email = ref.watch(userEmailProvider);
/// if (email != null) {
///   Text('Logged in as: $email');
/// }
/// ```
final userEmailProvider = Provider.autoDispose<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

/// Provider for user's theme mode
///
/// Returns system theme if user is not authenticated
///
/// Usage:
/// ```dart
/// final themeMode = ref.watch(userThemeModeProvider);
/// MaterialApp(themeMode: themeMode);
/// ```
final userThemeModeProvider = Provider.autoDispose((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.themeMode;
});

/// Provider for user's locale
///
/// Returns 'en' if user is not authenticated
///
/// Usage:
/// ```dart
/// final locale = ref.watch(userLocaleProvider);
/// MaterialApp(locale: Locale(locale));
/// ```
final userLocaleProvider = Provider.autoDispose<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.locale ?? 'en';
});
