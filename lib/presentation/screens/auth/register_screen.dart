import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/auth_provider.dart';

/// Enhanced registration screen using design system
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordRequirements);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_updatePasswordRequirements);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updatePasswordRequirements() {
    setState(() {});
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service and Privacy Policy'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).clearError();

    final result = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (user) {
        // Navigate to onboarding or home
        context.go('/onboarding');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      }
      if (next.hasError && next.errorOrNull != null) {
        ErrorSnackBar.show(
          context,
          message: next.errorOrNull!.message,
          onRetry: () => ref.read(authNotifierProvider.notifier).clearError(),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.verticalSpaceXL,

                // Title
                Text(
                  'Create Account',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  'Sign up to get started with DingDong',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpaceXXL,

                // Name field
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpaceMD,

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
                  hint: 'Create a strong password',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!AppConstants.passwordRegex.hasMatch(value)) {
                      return 'Password must include uppercase, lowercase, and number';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpaceMD,

                // Confirm password field
                AppPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpaceMD,

                // Password requirements hint
                AppCard(
                  padding: AppCardPadding.compact,
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
                            'Password Requirements',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.info,
                              fontWeight: AppTypography.semiBold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpaceXXS,
                      _buildRequirement('At least 8 characters'),
                      _buildRequirement('One uppercase letter'),
                      _buildRequirement('One lowercase letter'),
                      _buildRequirement('One number'),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceMD,

                // Terms and conditions checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() => _acceptedTerms = value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: AppSpacing.sm),
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gray700,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: AppTypography.semiBold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: Navigate to Terms of Service
                                  },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: AppTypography.semiBold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: Navigate to Privacy Policy
                                  },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXL,

                // Register button
                AppButton(
                  onPressed: _handleRegister,
                  fullWidth: true,
                  loading: _isLoading,
                  enabled: !_isLoading,
                  child: const Text('Create Account'),
                ),
                AppSpacing.verticalSpaceXL,

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.gray300)),
                    Padding(
                      padding: AppSpacing.horizontalMD,
                      child: Text(
                        'OR',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.gray300)),
                  ],
                ),
                AppSpacing.verticalSpaceMD,

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTypography.bodyMedium,
                    ),
                    AppButton(
                      onPressed: () => context.go('/login'),
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      child: const Text('Sign In'),
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

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xxs, left: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: AppSpacing.iconXS,
            color: AppColors.gray600,
          ),
          AppSpacing.horizontalSpaceXXS,
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Password requirements checklist
class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequirementItem(
          text: 'At least 8 characters',
          isMet: password.length >= 8,
          textColor: textColor,
        ),
        _RequirementItem(
          text: 'One uppercase letter',
          isMet: RegExp(r'[A-Z]').hasMatch(password),
          textColor: textColor,
        ),
        _RequirementItem(
          text: 'One lowercase letter',
          isMet: RegExp(r'[a-z]').hasMatch(password),
          textColor: textColor,
        ),
        _RequirementItem(
          text: 'One number',
          isMet: RegExp(r'[0-9]').hasMatch(password),
          textColor: textColor,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;
  final Color textColor;

  const _RequirementItem({
    required this.text,
    required this.isMet,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? AppColors.success : textColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppColors.success : textColor,
            ),
          ),
        ],
      ),
    );
  }
}
