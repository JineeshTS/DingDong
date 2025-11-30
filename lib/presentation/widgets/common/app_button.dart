import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';

/// Button variants
enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  destructive,
}

/// Button sizes
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Custom styled button widget
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.isDisabled = false,
  });

  /// Primary button factory
  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool isExpanded = false,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: AppButtonVariant.primary,
        size: size,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        isExpanded: isExpanded,
      );

  /// Secondary button factory
  factory AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool isExpanded = false,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: AppButtonVariant.secondary,
        size: size,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        isExpanded: isExpanded,
      );

  /// Outlined button factory
  factory AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool isExpanded = false,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: AppButtonVariant.outlined,
        size: size,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        isExpanded: isExpanded,
      );

  /// Text button factory
  factory AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: AppButtonVariant.text,
        size: size,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        isExpanded: false,
      );

  /// Destructive button factory
  factory AppButton.destructive({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    IconData? leadingIcon,
    bool isLoading = false,
    bool isExpanded = false,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: AppButtonVariant.destructive,
        size: size,
        leadingIcon: leadingIcon,
        isLoading: isLoading,
        isExpanded: isExpanded,
      );

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonPaddingSmall;
      case AppButtonSize.medium:
        return AppSpacing.buttonPaddingMedium;
      case AppButtonSize.large:
        return AppSpacing.buttonPaddingLarge;
    }
  }

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case AppButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case AppButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.iconSm;
      case AppButtonSize.medium:
        return AppSpacing.iconMd;
      case AppButtonSize.large:
        return AppSpacing.iconLg;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall();
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return AppTypography.button();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOnPressed =
        isDisabled || isLoading ? null : onPressed;

    Widget buttonContent = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: _iconSize - 4,
            height: _iconSize - 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(isDark),
              ),
            ),
          )
        else if (leadingIcon != null)
          Icon(leadingIcon, size: _iconSize),
        if ((leadingIcon != null || isLoading) && label.isNotEmpty)
          SizedBox(width: AppSpacing.sm),
        if (label.isNotEmpty)
          Text(
            label,
            style: _textStyle.copyWith(color: _getTextColor(isDark)),
          ),
        if (trailingIcon != null && label.isNotEmpty)
          SizedBox(width: AppSpacing.sm),
        if (trailingIcon != null) Icon(trailingIcon, size: _iconSize),
      ],
    );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
            padding: _padding,
            minimumSize: Size(0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          child: buttonContent,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
            padding: _padding,
            minimumSize: Size(0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          child: buttonContent,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _padding,
            minimumSize: Size(0, _height),
            side: BorderSide(
              color: effectiveOnPressed == null
                  ? (isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight)
                  : AppColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          child: buttonContent,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _padding,
            minimumSize: Size(0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          child: buttonContent,
        );
        break;

      case AppButtonVariant.destructive:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
            padding: _padding,
            minimumSize: Size(0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          child: buttonContent,
        );
        break;
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: button,
      );
    }

    return button;
  }

  Color _getTextColor(bool isDark) {
    if (isDisabled) {
      return isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight;
    }

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}

/// Icon-only button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final String? tooltip;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.text,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.color,
  });

  double get _size {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 40;
      case AppButtonSize.large:
        return 48;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.iconSm;
      case AppButtonSize.medium:
        return AppSpacing.iconMd;
      case AppButtonSize.large:
        return AppSpacing.iconLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      width: _size,
      height: _size,
      child: IconButton(
        icon: isLoading
            ? SizedBox(
                width: _iconSize - 4,
                height: _iconSize - 4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? AppColors.primary,
                  ),
                ),
              )
            : Icon(
                icon,
                size: _iconSize,
                color: color,
              ),
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: _size,
          minHeight: _size,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
