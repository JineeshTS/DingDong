import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user/deactivate_account_usecase.dart';
import '../../../domain/usecases/user/export_user_data_usecase.dart';
import '../../../domain/usecases/user/get_user_usecase.dart';
import '../../../domain/usecases/user/reactivate_account_usecase.dart';
import '../../../domain/usecases/user/toggle_biometric_auth_usecase.dart';
import '../../../domain/usecases/user/update_locale_usecase.dart';
import '../../../domain/usecases/user/update_subscription_usecase.dart';
import '../../../domain/usecases/user/update_theme_mode_usecase.dart';
import '../../../domain/usecases/user/update_user_preferences_usecase.dart';
import '../../../domain/usecases/user/update_user_usecase.dart';
import 'user_notifier.dart';
import 'user_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for GetUserUseCase
///
/// Retrieves user data by ID
final getUserProvider = Provider.autoDispose<GetUserUseCase>(
  (ref) => sl<GetUserUseCase>(),
);

/// Provider for UpdateUserUseCase
///
/// Updates user profile information
final updateUserProvider = Provider.autoDispose<UpdateUserUseCase>(
  (ref) => sl<UpdateUserUseCase>(),
);

/// Provider for UpdateUserPreferencesUseCase
///
/// Updates custom user preferences
final updateUserPreferencesProvider =
    Provider.autoDispose<UpdateUserPreferencesUseCase>(
  (ref) => sl<UpdateUserPreferencesUseCase>(),
);

/// Provider for UpdateSubscriptionUseCase
///
/// Manages user subscription tier and expiration
final updateSubscriptionProvider =
    Provider.autoDispose<UpdateSubscriptionUseCase>(
  (ref) => sl<UpdateSubscriptionUseCase>(),
);

/// Provider for ToggleBiometricAuthUseCase
///
/// Enables/disables biometric authentication
final toggleBiometricAuthProvider =
    Provider.autoDispose<ToggleBiometricAuthUseCase>(
  (ref) => sl<ToggleBiometricAuthUseCase>(),
);

/// Provider for ExportUserDataUseCase
///
/// Exports user data for GDPR compliance
final exportUserDataProvider = Provider.autoDispose<ExportUserDataUseCase>(
  (ref) => sl<ExportUserDataUseCase>(),
);

/// Provider for DeactivateAccountUseCase
///
/// Soft deletes user account
final deactivateAccountProvider = Provider.autoDispose<DeactivateAccountUseCase>(
  (ref) => sl<DeactivateAccountUseCase>(),
);

/// Provider for UpdateThemeModeUseCase
///
/// Updates user's theme preference
final updateThemeModeProvider = Provider.autoDispose<UpdateThemeModeUseCase>(
  (ref) => sl<UpdateThemeModeUseCase>(),
);

/// Provider for UpdateLocaleUseCase
///
/// Updates user's language/locale preference
final updateLocaleProvider = Provider.autoDispose<UpdateLocaleUseCase>(
  (ref) => sl<UpdateLocaleUseCase>(),
);

/// Provider for ReactivateAccountUseCase
///
/// Reactivates a deactivated account
final reactivateAccountProvider = Provider.autoDispose<ReactivateAccountUseCase>(
  (ref) => sl<ReactivateAccountUseCase>(),
);

// ============================================================================
// User State Notifier Provider
// ============================================================================

/// Main user state notifier provider
///
/// This provider manages all user-related state and operations.
/// It is NOT auto-disposed to maintain user state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final userState = ref.watch(userNotifierProvider);
/// final userNotifier = ref.read(userNotifierProvider.notifier);
///
/// // Load user data
/// await userNotifier.getUser(userId);
///
/// // Check if data is loaded
/// if (userState.isLoaded) {
///   final user = userState.userOrNull;
///   // Show user UI
/// }
///
/// // Update theme
/// await userNotifier.updateThemeMode(
///   userId: userId,
///   themeMode: 'dark',
/// );
///
/// // Export user data
/// await userNotifier.exportUserData(userId);
/// if (userState.isDataExported) {
///   final data = userState.exportedDataOrNull;
///   // Process exported data
/// }
/// ```
final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) {
    return UserNotifier(
      getUserUseCase: ref.read(getUserProvider),
      updateUserUseCase: ref.read(updateUserProvider),
      updateUserPreferencesUseCase: ref.read(updateUserPreferencesProvider),
      updateSubscriptionUseCase: ref.read(updateSubscriptionProvider),
      toggleBiometricAuthUseCase: ref.read(toggleBiometricAuthProvider),
      exportUserDataUseCase: ref.read(exportUserDataProvider),
      deactivateAccountUseCase: ref.read(deactivateAccountProvider),
      updateThemeModeUseCase: ref.read(updateThemeModeProvider),
      updateLocaleUseCase: ref.read(updateLocaleProvider),
      reactivateAccountUseCase: ref.read(reactivateAccountProvider),
    );
  },
);

// ============================================================================
// Derived State Providers
// ============================================================================
// These providers derive specific values from the user state for convenience

/// Provider that exposes only the current user
///
/// Returns null if user is not loaded
///
/// Usage:
/// ```dart
/// final user = ref.watch(currentUserFromUserStateProvider);
/// if (user != null) {
///   Text('User: ${user.displayName}');
/// }
/// ```
final currentUserFromUserStateProvider = Provider.autoDispose<UserEntity?>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.userOrNull;
});

/// Provider that exposes user's theme mode
///
/// Returns system theme if user is not loaded
///
/// Usage:
/// ```dart
/// final themeMode = ref.watch(userThemeProvider);
/// MaterialApp(
///   themeMode: themeMode == ThemeMode.light
///     ? ThemeMode.light
///     : themeMode == ThemeMode.dark
///       ? ThemeMode.dark
///       : ThemeMode.system,
/// );
/// ```
final userThemeProvider = Provider.autoDispose<ThemeMode>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.themeMode ?? ThemeMode.system;
});

/// Provider that exposes user's locale
///
/// Returns 'en' if user is not loaded
///
/// Usage:
/// ```dart
/// final locale = ref.watch(userLocaleFromStateProvider);
/// MaterialApp(locale: Locale(locale));
/// ```
final userLocaleFromStateProvider = Provider.autoDispose<String>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.locale ?? 'en';
});

/// Provider that exposes user's subscription tier
///
/// Returns free tier if user is not loaded
///
/// Usage:
/// ```dart
/// final subscriptionTier = ref.watch(userSubscriptionTierProvider);
/// if (subscriptionTier == UserSubscriptionTier.premiumIndividual) {
///   // Show premium features
/// }
/// ```
final userSubscriptionTierProvider =
    Provider.autoDispose<UserSubscriptionTier>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.subscriptionTier ?? UserSubscriptionTier.free;
});

/// Provider for checking if user is premium
///
/// Returns false if user is not loaded
///
/// Usage:
/// ```dart
/// final isPremium = ref.watch(isPremiumFromUserStateProvider);
/// if (isPremium) {
///   // Show premium features
/// }
/// ```
final isPremiumFromUserStateProvider = Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.isPremium ?? false;
});

/// Provider for checking if user has active subscription
///
/// Returns false if user is not loaded
///
/// Usage:
/// ```dart
/// final hasActiveSubscription = ref.watch(hasActiveSubscriptionFromUserStateProvider);
/// if (!hasActiveSubscription) {
///   // Show upgrade prompt
/// }
/// ```
final hasActiveSubscriptionFromUserStateProvider =
    Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.isSubscriptionActive ?? false;
});

/// Provider for checking if biometric auth is enabled
///
/// Returns false if user is not loaded
///
/// Usage:
/// ```dart
/// final biometricEnabled = ref.watch(biometricEnabledProvider);
/// if (biometricEnabled) {
///   // Show biometric authentication option
/// }
/// ```
final biometricEnabledProvider = Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.biometricEnabled ?? false;
});

/// Provider for checking if user account is active
///
/// Returns false if user is not loaded
///
/// Usage:
/// ```dart
/// final isActive = ref.watch(isUserActiveProvider);
/// if (!isActive) {
///   // Show account deactivated message
/// }
/// ```
final isUserActiveProvider = Provider.autoDispose<bool>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.isActive ?? false;
});

/// Provider for user's display name
///
/// Returns 'User' if user is not loaded or has no display name
///
/// Usage:
/// ```dart
/// final displayName = ref.watch(userDisplayNameFromStateProvider);
/// Text('Hello, $displayName');
/// ```
final userDisplayNameFromStateProvider = Provider.autoDispose<String>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.displayName ?? 'User';
});

/// Provider for user's email
///
/// Returns null if user is not loaded
///
/// Usage:
/// ```dart
/// final email = ref.watch(userEmailFromStateProvider);
/// if (email != null) {
///   Text('Email: $email');
/// }
/// ```
final userEmailFromStateProvider = Provider.autoDispose<String?>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.email;
});

/// Provider for user's preferences map
///
/// Returns empty map if user is not loaded or has no preferences
///
/// Usage:
/// ```dart
/// final preferences = ref.watch(userPreferencesProvider);
/// final showNotifications = preferences['showNotifications'] ?? true;
/// ```
final userPreferencesProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.preferences ?? {};
});

/// Provider for user's default list ID
///
/// Returns null if user is not loaded or has no default list
///
/// Usage:
/// ```dart
/// final defaultListId = ref.watch(userDefaultListIdProvider);
/// if (defaultListId != null) {
///   // Load default list
/// }
/// ```
final userDefaultListIdProvider = Provider.autoDispose<String?>((ref) {
  final user = ref.watch(currentUserFromUserStateProvider);
  return user?.defaultListId;
});

/// Provider for checking if user is loading
///
/// Useful for showing loading indicators during user operations
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isUserLoadingProvider);
/// if (isLoading) {
///   CircularProgressIndicator();
/// }
/// ```
final isUserLoadingProvider = Provider.autoDispose<bool>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.isLoading;
});

/// Provider that exposes user error
///
/// Returns null if no error
///
/// Usage:
/// ```dart
/// final error = ref.watch(userErrorProvider);
/// if (error != null) {
///   SnackBar(content: Text(error.message));
/// }
/// ```
final userErrorProvider = Provider.autoDispose((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.errorOrNull;
});

/// Provider for exported user data
///
/// Returns null if no data has been exported
///
/// Usage:
/// ```dart
/// final exportedData = ref.watch(exportedUserDataProvider);
/// if (exportedData != null) {
///   // Process or download exported data
/// }
/// ```
final exportedUserDataProvider =
    Provider.autoDispose<Map<String, dynamic>?>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.exportedDataOrNull;
});
