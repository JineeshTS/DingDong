import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/auth_provider.dart';

/// Enhanced login screen using design system
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) {
        // Navigate to home on success
        context.go('/home');
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) => context.go('/home'),
    );
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).signInWithApple();

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) => context.go('/home'),
    );
  }

  Future<void> _handleMicrosoftSignIn() async {
    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).signInWithMicrosoft();

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) => context.go('/home'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.verticalSpaceXXL,

                // App logo
                Icon(
                  Icons.task_alt,
                  size: AppSpacing.iconXXL + 16,
                  color: AppColors.primary,
                ),
                AppSpacing.verticalSpaceXL,

                // Welcome text
                Text(
                  'Welcome Back!',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  'Sign in to continue to DingDong',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpaceXXL,

                // Email field
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!AppConstants.emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpaceMD,

                // Password field
                AppPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpaceXS,

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    onPressed: () => context.push('/forgot-password'),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                AppSpacing.verticalSpaceXL,

                // Login button
                AppButton(
                  onPressed: _handleLogin,
                  fullWidth: true,
                  loading: _isLoading,
                  enabled: !_isLoading,
                  child: const Text('Sign In'),
                ),
                AppSpacing.verticalSpaceXL,

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.gray300)),
                    Padding(
                      padding: AppSpacing.horizontalMD,
                      child: Text(
                        'OR CONTINUE WITH',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.gray300)),
                  ],
                ),
                AppSpacing.verticalSpaceXL,

                // Social sign-in buttons
                AppButton(
                  onPressed: _handleGoogleSignIn,
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                  enabled: !_isLoading,
                  icon: Icons.g_mobiledata,
                  child: const Text('Continue with Google'),
                ),
                AppSpacing.verticalSpaceSM,

                AppButton(
                  onPressed: _handleAppleSignIn,
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                  enabled: !_isLoading,
                  icon: Icons.apple,
                  child: const Text('Continue with Apple'),
                ),
                AppSpacing.verticalSpaceSM,

                AppButton(
                  onPressed: _handleMicrosoftSignIn,
                  variant: AppButtonVariant.outlined,
                  fullWidth: true,
                  enabled: !_isLoading,
                  icon: Icons.microsoft,
                  child: const Text('Continue with Microsoft'),
                ),
                AppSpacing.verticalSpaceXL,

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTypography.bodyMedium,
                    ),
                    AppButton(
                      onPressed: () => context.go('/register'),
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
