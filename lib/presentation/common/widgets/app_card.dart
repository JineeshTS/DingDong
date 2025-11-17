import 'package:flutter/material.dart';
import '../../../config/theme/design_system.dart';

/// Card padding variants
enum AppCardPadding {
  none,
  compact,
  normal,
  spacious,
}

/// Customizable card component using design system
class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
    this.padding = AppCardPadding.normal,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  final Widget child;
  final AppCardPadding padding;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get padding based on variant
    EdgeInsets cardPadding;
    switch (padding) {
      case AppCardPadding.none:
        cardPadding = EdgeInsets.zero;
        break;
      case AppCardPadding.compact:
        cardPadding = AppSpacing.cardCompactPadding;
        break;
      case AppCardPadding.normal:
        cardPadding = AppSpacing.cardPadding;
        break;
      case AppCardPadding.spacious:
        cardPadding = AppSpacing.cardSpaciousPadding;
        break;
    }

    return Card(
      elevation: elevation ?? AppSpacing.elevationMedium,
      color: color,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppSpacing.borderRadiusMD,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: borderRadius ?? AppSpacing.borderRadiusMD,
              child: Padding(
                padding: cardPadding,
                child: child,
              ),
            )
          : Padding(
              padding: cardPadding,
              child: child,
            ),
    );
  }
}

/// Header card for sections
class AppHeaderCard extends StatelessWidget {
  const AppHeaderCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium,
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalSpaceXXS,
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
