import 'package:flutter/material.dart';
import '../../../config/theme/design_system.dart';

/// Button size variants
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Button style variants
enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  destructive,
}

/// Customizable button component using design system
class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    this.loading = false,
    this.enabled = true,
    this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool loading;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;
    final theme = Theme.of(context);

    // Get button padding based on size
    EdgeInsets padding;
    double height;
    TextStyle textStyle;

    switch (size) {
      case AppButtonSize.small:
        padding = AppSpacing.buttonSmallPadding;
        height = AppConstants.buttonSmallHeight;
        textStyle = AppTypography.labelMedium;
        break;
      case AppButtonSize.medium:
        padding = AppSpacing.buttonPadding;
        height = AppConstants.buttonHeight;
        textStyle = AppTypography.button;
        break;
      case AppButtonSize.large:
        padding = AppSpacing.buttonLargePadding;
        height = AppConstants.buttonLargeHeight;
        textStyle = AppTypography.labelLarge;
        break;
    }

    // Build button content
    Widget content = loading
        ? SizedBox(
            width: AppSpacing.iconMD,
            height: AppSpacing.iconMD,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary ||
                        variant == AppButtonVariant.destructive
                    ? AppColors.white
                    : AppColors.primary,
              ),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSpacing.iconSM),
                  AppSpacing.horizontalSpaceXS,
                  child,
                ],
              )
            : child;

    // Build button based on variant
    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            textStyle: textStyle,
            disabledBackgroundColor: AppColors.gray300,
            disabledForegroundColor: AppColors.gray500,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            textStyle: textStyle,
            disabledBackgroundColor: AppColors.gray300,
            disabledForegroundColor: AppColors.gray500,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            side: const BorderSide(
              color: AppColors.primary,
              width: AppSpacing.borderMedium,
            ),
            textStyle: textStyle,
            disabledForegroundColor: AppColors.gray500,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            textStyle: textStyle,
            disabledForegroundColor: AppColors.gray500,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.destructive:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: padding,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            textStyle: textStyle,
            disabledBackgroundColor: AppColors.gray300,
            disabledForegroundColor: AppColors.gray500,
          ),
          child: content,
        );
        break;
    }

    // Wrap with full width if needed
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Icon-only button variant
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.tooltip,
    this.enabled = true,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final String? tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    double iconSize;

    switch (size) {
      case AppButtonSize.small:
        iconSize = AppSpacing.iconSM;
        break;
      case AppButtonSize.medium:
        iconSize = AppSpacing.iconMD;
        break;
      case AppButtonSize.large:
        iconSize = AppSpacing.iconLG;
        break;
    }

    final button = IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: enabled ? onPressed : null,
      color: AppColors.primary,
      disabledColor: AppColors.gray500,
      tooltip: tooltip,
    );

    return button;
  }
}
