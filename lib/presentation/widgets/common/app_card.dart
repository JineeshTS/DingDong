import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Custom styled card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Elevated card factory
  factory AppCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) =>
      AppCard(
        key: key,
        padding: padding,
        margin: margin,
        color: color,
        borderRadius: borderRadius,
        elevation: AppSpacing.elevationSm,
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        child: child,
      );

  /// Outlined card factory
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Color? borderColor,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) =>
      AppCard(
        key: key,
        padding: padding,
        margin: margin,
        color: color,
        borderColor: borderColor,
        borderWidth: 1,
        borderRadius: borderRadius,
        elevation: 0,
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        child: child,
      );

  /// Flat card factory (no elevation, no border)
  factory AppCard.flat({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) =>
      AppCard(
        key: key,
        padding: padding,
        margin: margin,
        color: color,
        borderRadius: borderRadius,
        elevation: 0,
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveColor = color ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final effectiveBorderColor = isSelected
        ? AppColors.primary
        : borderColor ??
            (isDark ? AppColors.borderDark : AppColors.borderLight);
    final effectiveBorderRadius = borderRadius ?? AppSpacing.borderRadiusMd;
    final effectiveElevation = elevation ?? AppSpacing.elevationSm;

    Widget card = Card(
      margin: margin ?? EdgeInsets.zero,
      color: effectiveColor,
      elevation: effectiveElevation,
      shadowColor: isDark ? Colors.black54 : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: borderWidth != null || isSelected
            ? BorderSide(
                color: effectiveBorderColor,
                width: isSelected ? 2 : (borderWidth ?? 1),
              )
            : BorderSide.none,
      ),
      clipBehavior: clipBehavior,
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );

    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// Section card with optional header
class AppSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? headerPadding;
  final VoidCallback? onTap;

  const AppSectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.headerPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard.elevated(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Padding(
              padding: headerPadding ?? AppSpacing.cardPadding,
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          if (title != null)
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// List tile card for settings and menu items
class AppListTileCard extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Color? leadingIconBackgroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool isDestructive;

  const AppListTileCard({
    super.key,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconBackgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: leadingIconBackgroundColor ??
                      (isDestructive
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1)),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  leadingIcon,
                  size: AppSpacing.iconMd,
                  color: leadingIconColor ??
                      (isDestructive ? AppColors.error : AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: subtitleColor,
              ),
          ],
        ),
      ),
    );
  }
}
