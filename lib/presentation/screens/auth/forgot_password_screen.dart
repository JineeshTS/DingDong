import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/auth_provider.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
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

    final result = await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          _emailController.text.trim(),
        );

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
      (_) {
        setState(() => _emailSent = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.verticalSpaceXXL,

          // Icon
          Container(
            padding: AppSpacing.paddingXL,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: AppSpacing.iconXXL,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.verticalSpaceXL,

          // Title
          Text(
            'Forgot Password?',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: AppTypography.bodyMedium.copyWith(
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
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
          AppSpacing.verticalSpaceXL,

          // Reset button
          AppButton(
            onPressed: _handleResetPassword,
            fullWidth: true,
            loading: _isLoading,
            enabled: !_isLoading,
            child: const Text('Send Reset Link'),
          ),
          AppSpacing.verticalSpaceMD,

          // Back to login
          Center(
            child: AppButton(
              onPressed: () => context.go('/login'),
              variant: AppButtonVariant.text,
              child: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.verticalSpaceXXL,

        // Success icon
        Container(
          padding: AppSpacing.paddingXL,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: AppSpacing.iconXXL,
            color: AppColors.success,
          ),
        ),
        AppSpacing.verticalSpaceXL,

        // Success message
        Text(
          'Check Your Email',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          'We\'ve sent a password reset link to',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalSpaceXXS,
        Text(
          _emailController.text.trim(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.semiBold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalSpaceXL,

        // Instructions card
        AppCard(
          padding: AppCardPadding.normal,
          color: AppColors.info.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: AppSpacing.iconSM,
                    color: AppColors.info,
                  ),
                  AppSpacing.horizontalSpaceXS,
                  Text(
                    'Next Steps',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceSM,
              _buildInstructionItem('1. Check your inbox and spam folder'),
              _buildInstructionItem('2. Click the reset link in the email'),
              _buildInstructionItem('3. Create a new password'),
            ],
          ),
        ),
        AppSpacing.verticalSpaceXL,

        // Resend button
        AppButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          variant: AppButtonVariant.outlined,
          fullWidth: true,
          child: const Text('Resend Email'),
        ),
        AppSpacing.verticalSpaceSM,

        // Back to login
        Center(
          child: AppButton(
            onPressed: () => context.go('/login'),
            variant: AppButtonVariant.text,
            child: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: AppSpacing.paddingXXS.copyWith(bottom: AppSpacing.xxs),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.gray700,
        ),
      ),
    );
  }
}
