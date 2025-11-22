import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth/auth_providers.dart';
import '../../providers/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/error_state.dart';

/// Login screen with email and social authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors
    ref.read(authNotifierProvider.notifier).clearError();

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    ref.read(authNotifierProvider.notifier).clearError();
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    ref.read(authNotifierProvider.notifier).clearError();
    await ref.read(authNotifierProvider.notifier).signInWithApple();
  }

  Future<void> _handleMicrosoftSignIn() async {
    ref.read(authNotifierProvider.notifier).clearError();
    await ref.read(authNotifierProvider.notifier).signInWithMicrosoft();
  }

  void _navigateToForgotPassword() {
    context.push('/forgot-password');
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Navigate to home on successful authentication
      if (next.isAuthenticated) {
        context.go('/home');
      }
      // Show error snackbar
      if (next.hasError && next.errorOrNull != null) {
        ErrorSnackBar.show(
          context,
          message: next.errorOrNull!.message,
          onRetry: () => ref.read(authNotifierProvider.notifier).clearError(),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    Gap.v24,

                    // Welcome text
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Gap.v8,
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Gap.v32,

                    // Email field
                    AppTextField.email(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      validator: _validateEmail,
                      enabled: !isLoading,
                      onSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    Gap.v16,

                    // Password field
                    AppTextField.password(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      validator: _validatePassword,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    Gap.v8,

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _navigateToForgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    Gap.v24,

                    // Login button
                    AppButton.primary(
                      label: 'Sign In',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading && authState.loadingMessageOrNull == 'Signing in...',
                      isExpanded: true,
                      size: AppButtonSize.large,
                    ),
                    Gap.v24,

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),
                        ),
                      ],
                    ),
                    Gap.v24,

                    // Google Sign In
                    _SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      isLoading: isLoading && authState.loadingMessageOrNull == 'Signing in with Google...',
                    ),
                    Gap.v12,

                    // Apple Sign In
                    _SocialLoginButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      onPressed: isLoading ? null : _handleAppleSignIn,
                      isLoading: isLoading && authState.loadingMessageOrNull == 'Signing in with Apple...',
                    ),
                    Gap.v12,

                    // Microsoft Sign In
                    _SocialLoginButton(
                      icon: Icons.microsoft,
                      label: 'Continue with Microsoft',
                      onPressed: isLoading ? null : _handleMicrosoftSignIn,
                      isLoading: isLoading && authState.loadingMessageOrNull == 'Signing in with Microsoft...',
                    ),
                    Gap.v24,

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : () => context.go('/register'),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Social login button widget
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.outlined(
      label: label,
      leadingIcon: isLoading ? null : icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isExpanded: true,
    );
  }
}
