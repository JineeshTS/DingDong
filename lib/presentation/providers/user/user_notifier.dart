import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/errors/failures.dart';
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
import 'user_state.dart';

/// StateNotifier for managing user state
///
/// Handles all user-related operations including:
/// - User profile management
/// - Theme and locale preferences
/// - Subscription management
/// - Biometric authentication settings
/// - Account activation/deactivation
/// - User data export (GDPR compliance)
///
/// This notifier integrates with all 10 user use cases
/// and manages the UserState throughout the application lifecycle.
class UserNotifier extends StateNotifier<UserState> {
  final GetUserUseCase _getUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final UpdateUserPreferencesUseCase _updateUserPreferencesUseCase;
  final UpdateSubscriptionUseCase _updateSubscriptionUseCase;
  final ToggleBiometricAuthUseCase _toggleBiometricAuthUseCase;
  final ExportUserDataUseCase _exportUserDataUseCase;
  final DeactivateAccountUseCase _deactivateAccountUseCase;
  final UpdateThemeModeUseCase _updateThemeModeUseCase;
  final UpdateLocaleUseCase _updateLocaleUseCase;
  final ReactivateAccountUseCase _reactivateAccountUseCase;

  UserNotifier({
    required GetUserUseCase getUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required UpdateUserPreferencesUseCase updateUserPreferencesUseCase,
    required UpdateSubscriptionUseCase updateSubscriptionUseCase,
    required ToggleBiometricAuthUseCase toggleBiometricAuthUseCase,
    required ExportUserDataUseCase exportUserDataUseCase,
    required DeactivateAccountUseCase deactivateAccountUseCase,
    required UpdateThemeModeUseCase updateThemeModeUseCase,
    required UpdateLocaleUseCase updateLocaleUseCase,
    required ReactivateAccountUseCase reactivateAccountUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _updateUserPreferencesUseCase = updateUserPreferencesUseCase,
        _updateSubscriptionUseCase = updateSubscriptionUseCase,
        _toggleBiometricAuthUseCase = toggleBiometricAuthUseCase,
        _exportUserDataUseCase = exportUserDataUseCase,
        _deactivateAccountUseCase = deactivateAccountUseCase,
        _updateThemeModeUseCase = updateThemeModeUseCase,
        _updateLocaleUseCase = updateLocaleUseCase,
        _reactivateAccountUseCase = reactivateAccountUseCase,
        super(const UserState.initial());

  /// Get user by ID
  ///
  /// Fetches user data from the repository and updates state
  ///
  /// Parameters:
  /// - [userId]: ID of the user to fetch
  Future<void> getUser(String userId) async {
    state = const UserState.loading(message: 'Loading user data...');

    final result = await _getUserUseCase(userId);

    result.fold(
      (failure) => state = UserState.error(failure: failure),
      (user) => state = UserState.loaded(user: user),
    );
  }

  /// Update user profile
  ///
  /// Updates user information such as display name, photo URL, etc.
  ///
  /// Parameters:
  /// - [user]: Updated user entity
  Future<void> updateUser(UserEntity user) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Updating profile...',
    );

    final result = await _updateUserUseCase(user);

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Update user preferences
  ///
  /// Updates custom user preferences stored as key-value pairs
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [preferences]: Map of preference key-value pairs
  Future<void> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Updating preferences...',
    );

    final result = await _updateUserPreferencesUseCase(
      userId: userId,
      preferences: preferences,
    );

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Update theme mode
  ///
  /// Changes the user's theme preference (light, dark, or system)
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [themeMode]: Theme mode to set ('light', 'dark', or 'system')
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Updating theme...',
    );

    final result = await _updateThemeModeUseCase(
      userId: userId,
      themeMode: themeMode,
    );

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Update locale
  ///
  /// Changes the user's language/locale preference
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [locale]: Locale code (e.g., 'en_US', 'es_ES')
  Future<void> updateLocale({
    required String userId,
    required String locale,
  }) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Updating language...',
    );

    final result = await _updateLocaleUseCase(
      userId: userId,
      locale: locale,
    );

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Update subscription
  ///
  /// Updates the user's subscription tier and expiration date
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [subscriptionTier]: Subscription tier ('free', 'plus', 'premium')
  /// - [expiresAt]: Optional expiration date for paid subscriptions
  Future<void> updateSubscription({
    required String userId,
    required String subscriptionTier,
    DateTime? expiresAt,
  }) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Updating subscription...',
    );

    final result = await _updateSubscriptionUseCase(
      userId: userId,
      subscriptionTier: subscriptionTier,
      expiresAt: expiresAt,
    );

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Toggle biometric authentication
  ///
  /// Enables or disables biometric authentication for the user
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [enabled]: Whether to enable or disable biometric auth
  Future<void> toggleBiometricAuth({
    required String userId,
    required bool enabled,
  }) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: enabled
          ? 'Enabling biometric authentication...'
          : 'Disabling biometric authentication...',
    );

    final result = await _toggleBiometricAuthUseCase(
      userId: userId,
      enabled: enabled,
    );

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Export user data
  ///
  /// Exports all user data for GDPR compliance
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  ///
  /// Returns: Exported data as a map in the state
  Future<void> exportUserData(String userId) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Exporting user data...',
    );

    final result = await _exportUserDataUseCase(userId);

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (data) {
        if (currentUser != null) {
          state = UserState.dataExported(
            data: data,
            user: currentUser,
          );
        } else {
          state = UserState.error(
            failure: const CacheFailure(message: 'User data not available'),
            user: null,
          );
        }
      },
    );
  }

  /// Deactivate account
  ///
  /// Soft deletes the user account (can be reactivated later)
  ///
  /// Parameters:
  /// - [userId]: ID of the user to deactivate
  Future<void> deactivateAccount(String userId) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Deactivating account...',
    );

    final result = await _deactivateAccountUseCase(userId);

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Reactivate account
  ///
  /// Reactivates a previously deactivated account
  ///
  /// Parameters:
  /// - [userId]: ID of the user to reactivate
  Future<void> reactivateAccount(String userId) async {
    final currentUser = state.userOrNull;

    state = UserState.loading(
      user: currentUser,
      message: 'Reactivating account...',
    );

    final result = await _reactivateAccountUseCase(userId);

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (updatedUser) => state = UserState.loaded(user: updatedUser),
    );
  }

  /// Refresh user data
  ///
  /// Reloads the current user's data from the repository
  Future<void> refreshUser() async {
    final currentUser = state.userOrNull;
    if (currentUser == null) return;

    state = UserState.loading(
      user: currentUser,
      message: 'Refreshing user data...',
    );

    final result = await _getUserUseCase(currentUser.id);

    result.fold(
      (failure) => state = UserState.error(
        failure: failure,
        user: currentUser,
      ),
      (user) => state = UserState.loaded(user: user),
    );
  }

  /// Clear error state
  ///
  /// Returns to previous loaded state or initial if no user
  void clearError() {
    final user = state.userOrNull;
    if (user != null) {
      state = UserState.loaded(user: user);
    } else {
      state = const UserState.initial();
    }
  }

  /// Clear exported data state
  ///
  /// Returns to loaded state after data export
  void clearExportedData() {
    final user = state.userOrNull;
    if (user != null) {
      state = UserState.loaded(user: user);
    } else {
      state = const UserState.initial();
    }
  }

  /// Set user directly (useful for testing or after external updates)
  void setUser(UserEntity user) {
    state = UserState.loaded(user: user);
  }
}
