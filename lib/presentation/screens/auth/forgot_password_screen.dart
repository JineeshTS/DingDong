import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth/auth_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/error_state.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _emailSent = true);
    } else {
      ErrorSnackBar.show(
        context,
        message: 'Failed to send reset email. Please try again.',
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reset Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _emailSent
                  ? _EmailSentContent(
                      email: _emailController.text,
                      onResend: () {
                        setState(() => _emailSent = false);
                      },
                      onBackToLogin: () => context.go('/login'),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon
                          Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          Gap.v24,

                          // Title
                          Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          Gap.v8,

                          // Subtitle
                          Text(
                            'Enter your email address and we\'ll send you a link to reset your password.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                            validator: _validateEmail,
                            enabled: !_isLoading,
                            onSubmitted: (_) => _handleResetPassword(),
                            autofocus: true,
                          ),
                          Gap.v24,

                          // Reset button
                          AppButton.primary(
                            label: 'Send Reset Link',
                            onPressed: _isLoading ? null : _handleResetPassword,
                            isLoading: _isLoading,
                            isExpanded: true,
                            size: AppButtonSize.large,
                          ),
                          Gap.v24,

                          // Back to login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Remember your password?',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading ? null : () => context.go('/login'),
                                child: const Text('Sign In'),
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

/// Email sent success content
class _EmailSentContent extends StatelessWidget {
  final String email;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  const _EmailSentContent({
    required this.email,
    required this.onResend,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 40,
            color: AppColors.success,
          ),
        ),
        Gap.v24,

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        Gap.v8,

        // Subtitle
        Text(
          'We\'ve sent a password reset link to',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          textAlign: TextAlign.center,
        ),
        Gap.v4,
        Text(
          email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        Gap.v32,

        // Back to login button
        AppButton.primary(
          label: 'Back to Sign In',
          onPressed: onBackToLogin,
          isExpanded: true,
          size: AppButtonSize.large,
        ),
        Gap.v16,

        // Resend link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the email?",
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            TextButton(
              onPressed: onResend,
              child: const Text('Resend'),
            ),
          ],
        ),
      ],
    );
  }
}
