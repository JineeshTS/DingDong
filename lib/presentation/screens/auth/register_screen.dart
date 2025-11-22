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

/// Registration screen with email signup
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

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

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
        const SnackBar(
          content: Text('Please accept the Terms of Service'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).clearError();

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
                  children: [
                    Text(
                      'Join DingDong',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Gap.v8,
                    Text(
                      'Create an account to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Gap.v32,

                    // Name field
                    AppTextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                      enabled: !isLoading,
                      onSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    Gap.v16,

                    // Email field
                    AppTextField.email(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      validator: _validateEmail,
                      enabled: !isLoading,
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),
                    Gap.v16,

                    // Password field
                    AppTextField.password(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Password',
                      hint: 'Create a strong password',
                      validator: _validatePassword,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                    ),
                    Gap.v8,

                    // Password requirements
                    _PasswordRequirements(password: _passwordController.text),
                    Gap.v16,

                    // Confirm password field
                    AppTextField.password(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      validator: _validateConfirmPassword,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleRegister(),
                    ),
                    Gap.v24,

                    // Terms and conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _acceptedTerms = !_acceptedTerms;
                                    });
                                  },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap.v24,

                    // Register button
                    AppButton.primary(
                      label: 'Create Account',
                      onPressed: isLoading ? null : _handleRegister,
                      isLoading: isLoading,
                      isExpanded: true,
                      size: AppButtonSize.large,
                    ),
                    Gap.v24,

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : () => context.go('/login'),
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
