// ignore_for_file: unused_local_variable, unused_element

/// Authentication Providers Usage Examples
///
/// This file demonstrates how to use the authentication providers
/// in various scenarios throughout the application.
///
/// NOTE: This file is for reference only and should not be imported
/// into your application code.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

// ============================================================================
// Example 1: Simple Login Screen
// ============================================================================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Check if login was successful
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      // Navigate to home screen
      if (mounted) {
        // Navigator.pushReplacement(context, ...);
      }
    } else if (authState.hasError) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.errorOrNull?.message ?? 'Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: !isLoading,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 2: Registration Screen
// ============================================================================

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  Future<void> _handleRegister() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _displayNameController.text,
    );

    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      // Navigate to home or onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _handleRegister,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 3: Social Authentication
// ============================================================================

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => authNotifier.signInWithGoogle(),
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Sign in with Google'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => authNotifier.signInWithApple(),
          icon: const Icon(Icons.apple),
          label: const Text('Sign in with Apple'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => authNotifier.signInWithMicrosoft(),
          icon: const Icon(Icons.microsoft),
          label: const Text('Sign in with Microsoft'),
        ),
      ],
    );
  }
}

// ============================================================================
// Example 4: Profile Screen with Update
// ============================================================================

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.updateProfile(
      displayName: _displayNameController.text,
    );

    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);

    if (user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    // Initialize controller with current display name
    if (_displayNameController.text.isEmpty && user.displayName != null) {
      _displayNameController.text = user.displayName!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 5: Change Password Screen
// ============================================================================

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    final authState = ref.read(authNotifierProvider);
    if (mounted) {
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorOrNull?.message ?? 'Failed to change password'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _changePassword,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 6: Auth State Listener
// ============================================================================

class AuthStateListener extends ConsumerWidget {
  final Widget child;

  const AuthStateListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Navigate based on auth state changes
      next.maybeWhen(
        authenticated: (user) {
          // Navigate to home screen
          // Navigator.pushReplacementNamed(context, '/home');
        },
        unauthenticated: () {
          // Navigate to login screen
          // Navigator.pushReplacementNamed(context, '/login');
        },
        error: (failure, user) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        orElse: () {},
      );
    });

    return child;
  }
}

// ============================================================================
// Example 7: Protected Route
// ============================================================================

class ProtectedScreen extends ConsumerWidget {
  const ProtectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);

    if (!isAuthenticated || user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to access this page'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Welcome ${user.displayName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${user.email}'),
            Text('Premium: ${user.isPremium}'),
            ElevatedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 8: Password Reset
// ============================================================================

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    setState(() => _isLoading = true);

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.sendPasswordResetEmail(
      email: _emailController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 9: Delete Account
// ============================================================================

class DeleteAccountButton extends ConsumerWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Are you sure? This action cannot be undone.'),
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

        if (confirmed == true && context.mounted) {
          // Show password confirmation dialog
          final password = await _showPasswordDialog(context);

          if (password != null && context.mounted) {
            final authNotifier = ref.read(authNotifierProvider.notifier);
            await authNotifier.deleteAccount(password: password);

            final authState = ref.read(authNotifierProvider);
            if (authState.isUnauthenticated && context.mounted) {
              // Navigate to login/welcome screen
            }
          }
        }
      },
      child: const Text('Delete Account'),
    );
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

// ============================================================================
// Example 10: Premium Feature Guard
// ============================================================================

class PremiumFeature extends ConsumerWidget {
  final Widget child;
  final Widget fallback;

  const PremiumFeature({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);

    return isPremium ? child : fallback;
  }
}

// Usage:
class ExamplePremiumUsage extends StatelessWidget {
  const ExamplePremiumUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumFeature(
      child: const Text('Premium Content'),
      fallback: ElevatedButton(
        onPressed: () {
          // Navigate to subscription page
        },
        child: const Text('Upgrade to Premium'),
      ),
    );
  }
}
