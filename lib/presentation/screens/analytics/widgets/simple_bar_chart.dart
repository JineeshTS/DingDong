import 'package:flutter/material.dart';

import '../../../../config/theme/design_system.dart';
import '../../../providers/analytics/analytics.dart';

/// Simple bar chart widget
///
/// Displays daily task counts as a bar chart
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.showLabels = true,
  });

  final List<DailyTaskCount> data;
  final double height;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data available',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),
      );
    }

    final maxCount =
        data.map((d) => d.completed).reduce((a, b) => a > b ? a : b);
    final maxValue = maxCount > 0 ? maxCount : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final percentage = item.completed / maxValue;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      Container(
                        height: height * percentage,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),

                      // Label
                      if (showLabels && data.length <= 7) ...{
                        SizedBox(height: 4),
                        Text(
                          _formatDate(item.date),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10,
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      },
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Legend
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Completed', AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateOnly.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
