import 'package:flutter/material.dart';

import '../../../../config/theme/design_system.dart';

/// Stat card widget
///
/// Displays a single statistic with icon, label, value, and optional trend
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.trendUp = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final String? trend;
  final bool trendUp;

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
      ),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statColor.withOpacity(0.1),
              statColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and trend
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: statColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  child: Icon(
                    icon,
                    color: statColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: trendUp
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: trendUp ? AppColors.success : AppColors.error,
                        ),
                        SizedBox(width: 2),
                        Text(
                          trend!,
                          style: AppTypography.labelSmall.copyWith(
                            color: trendUp ? AppColors.success : AppColors.error,
                            fontWeight: AppTypography.semiBold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            AppSpacing.verticalSpaceSM,

            // Value
            Text(
              value,
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: AppTypography.bold,
                color: statColor,
              ),
            ),

            SizedBox(height: 4),

            // Label
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),

            // Subtitle
            if (subtitle != null) ...{
              SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                  fontSize: 11,
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
