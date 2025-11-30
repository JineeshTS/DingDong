import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import 'app_button.dart';

/// Error state widget for error handling
class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;
  final Widget? customAction;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
    this.customAction,
  });

  /// Generic error state
  factory ErrorState.generic({
    VoidCallback? onRetry,
  }) =>
      ErrorState(
        title: 'Something went wrong',
        message: 'An unexpected error occurred. Please try again.',
        retryLabel: 'Try Again',
        onRetry: onRetry,
      );

  /// Network error state
  factory ErrorState.network({
    VoidCallback? onRetry,
  }) =>
      ErrorState(
        icon: Icons.wifi_off,
        title: 'No Internet Connection',
        message: 'Please check your internet connection and try again.',
        retryLabel: 'Retry',
        onRetry: onRetry,
      );

  /// Server error state
  factory ErrorState.server({
    VoidCallback? onRetry,
  }) =>
      ErrorState(
        icon: Icons.cloud_off,
        title: 'Server Error',
        message: 'Our servers are having issues. Please try again later.',
        retryLabel: 'Retry',
        onRetry: onRetry,
      );

  /// Not found error state
  factory ErrorState.notFound({
    String? itemName,
    VoidCallback? onGoBack,
  }) =>
      ErrorState(
        icon: Icons.search_off,
        title: '${itemName ?? 'Item'} Not Found',
        message: 'The ${itemName?.toLowerCase() ?? 'item'} you\'re looking for doesn\'t exist.',
        retryLabel: 'Go Back',
        onRetry: onGoBack,
      );

  /// Permission denied error state
  factory ErrorState.permissionDenied({
    String? permission,
    VoidCallback? onOpenSettings,
  }) =>
      ErrorState(
        icon: Icons.lock_outline,
        title: 'Permission Required',
        message: permission != null
            ? '$permission permission is required to use this feature.'
            : 'Please grant the required permission.',
        retryLabel: 'Open Settings',
        onRetry: onOpenSettings,
      );

  /// Timeout error state
  factory ErrorState.timeout({
    VoidCallback? onRetry,
  }) =>
      ErrorState(
        icon: Icons.hourglass_empty,
        title: 'Request Timeout',
        message: 'The request took too long. Please try again.',
        retryLabel: 'Retry',
        onRetry: onRetry,
      );

  /// Authentication error state
  factory ErrorState.auth({
    VoidCallback? onLogin,
  }) =>
      ErrorState(
        icon: Icons.person_off,
        title: 'Authentication Required',
        message: 'Please log in to continue.',
        retryLabel: 'Log In',
        onRetry: onLogin,
      );

  /// Session expired error state
  factory ErrorState.sessionExpired({
    VoidCallback? onLogin,
  }) =>
      ErrorState(
        icon: Icons.timer_off,
        title: 'Session Expired',
        message: 'Your session has expired. Please log in again.',
        retryLabel: 'Log In',
        onRetry: onLogin,
      );

  /// Maintenance mode error state
  factory ErrorState.maintenance() => const ErrorState(
        icon: Icons.construction,
        title: 'Under Maintenance',
        message: 'We\'re performing maintenance. Please check back soon.',
      );

  /// Custom error state from Exception
  factory ErrorState.fromException({
    required Object error,
    VoidCallback? onRetry,
  }) {
    String message = 'An unexpected error occurred.';

    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else if (error is Error) {
      message = error.toString();
    }

    return ErrorState(
      title: 'Error',
      message: message,
      retryLabel: onRetry != null ? 'Try Again' : null,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (retryLabel != null && onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton.primary(
                label: retryLabel!,
                onPressed: onRetry,
                leadingIcon: Icons.refresh,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact error state for inline errors
class CompactErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.error,
              onPressed: onRetry,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}

/// Success snackbar helper
class SuccessSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration,
      ),
    );
  }
}
