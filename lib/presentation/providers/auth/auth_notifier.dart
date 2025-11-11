import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user_entity.dart';
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
import 'auth_state.dart';

/// StateNotifier for managing authentication state
///
/// Handles all authentication-related operations including:
/// - Email/password authentication
/// - Social authentication (Google, Apple, Microsoft)
/// - Profile management
/// - Password management
/// - Account deletion
///
/// This notifier integrates with all 11 authentication use cases
/// and manages the AuthState throughout the application lifecycle.
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithMicrosoftUseCase _signInWithMicrosoftUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;

  AuthNotifier({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInWithMicrosoftUseCase signInWithMicrosoftUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithAppleUseCase = signInWithAppleUseCase,
        _signInWithMicrosoftUseCase = signInWithMicrosoftUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
        super(const AuthState.initial());

  /// Check authentication status on app start
  ///
  /// Retrieves the current user if authenticated, otherwise sets unauthenticated state
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => state = const AuthState.unauthenticated(),
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user: user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  /// Sign in with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading(message: 'Signing in...');

    final result = await _signInWithEmailUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Sign up with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [displayName]: User's display name
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading(message: 'Creating account...');

    final result = await _signUpWithEmailUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    state = const AuthState.loading(message: 'Signing in with Google...');

    final result = await _signInWithGoogleUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Sign in with Apple OAuth
  Future<void> signInWithApple() async {
    state = const AuthState.loading(message: 'Signing in with Apple...');

    final result = await _signInWithAppleUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Sign in with Microsoft OAuth
  Future<void> signInWithMicrosoft() async {
    state = const AuthState.loading(message: 'Signing in with Microsoft...');

    final result = await _signInWithMicrosoftUseCase();

    result.fold(
      (failure) => state = AuthState.error(failure: failure),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = AuthState.loading(
      user: state.userOrNull,
      message: 'Signing out...',
    );

    final result = await _signOutUseCase();

    result.fold(
      (failure) => state = AuthState.error(
        failure: failure,
        user: state.userOrNull,
      ),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Update user profile
  ///
  /// Parameters:
  /// - [displayName]: New display name (optional)
  /// - [photoUrl]: New photo URL (optional)
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final currentUser = state.userOrNull;

    state = AuthState.loading(
      user: currentUser,
      message: 'Updating profile...',
    );

    final result = await _updateProfileUseCase(
      displayName: displayName,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) => state = AuthState.error(
        failure: failure,
        user: currentUser,
      ),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Update user password
  ///
  /// Parameters:
  /// - [currentPassword]: Current password for verification
  /// - [newPassword]: New password to set
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = state.userOrNull;

    state = AuthState.loading(
      user: currentUser,
      message: 'Updating password...',
    );

    final result = await _updatePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => state = AuthState.error(
        failure: failure,
        user: currentUser,
      ),
      (_) => state = AuthState.authenticated(user: currentUser!),
    );
  }

  /// Delete the current user account
  ///
  /// Parameters:
  /// - [password]: Current password for verification
  Future<void> deleteAccount({required String password}) async {
    final currentUser = state.userOrNull;

    state = AuthState.loading(
      user: currentUser,
      message: 'Deleting account...',
    );

    final result = await _deleteAccountUseCase(password: password);

    result.fold(
      (failure) => state = AuthState.error(
        failure: failure,
        user: currentUser,
      ),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Send password reset email
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to
  ///
  /// Returns: true if email sent successfully, false otherwise
  Future<bool> sendPasswordResetEmail({required String email}) async {
    final result = await _sendPasswordResetEmailUseCase(email: email);

    return result.fold(
      (_) => false,
      (_) => true,
    );
  }

  /// Refresh current user data
  ///
  /// Useful after external changes to user data
  Future<void> refreshUser() async {
    final currentUser = state.userOrNull;

    state = AuthState.loading(
      user: currentUser,
      message: 'Refreshing user data...',
    );

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => state = AuthState.error(
        failure: failure,
        user: currentUser,
      ),
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user: user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  /// Clear error state
  ///
  /// Returns to previous state (authenticated or unauthenticated)
  void clearError() {
    final user = state.userOrNull;
    if (user != null) {
      state = AuthState.authenticated(user: user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Set user directly (useful for testing or after external updates)
  void setUser(UserEntity user) {
    state = AuthState.authenticated(user: user);
  }
}
