import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/calendar/calendar.dart';

/// Calendar date cell widget
///
/// Displays a single date in the calendar with:
/// - Date number
/// - Task count badge
/// - Today indicator
/// - Selected state
/// - Overdue indicator
/// - Grayed out for adjacent months
class CalendarDateCell extends ConsumerWidget {
  const CalendarDateCell({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = ref.watch(isTodayProvider(date));
    final isSelected = ref.watch(isSelectedProvider(date));
    final isInCurrentMonth = ref.watch(isDateInCurrentMonthProvider(date));
    final taskCount = ref.watch(taskCountForDateProvider(date));
    final hasOverdueTasks = ref.watch(hasOverdueTasksOnDateProvider(date));

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSM,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(isToday, isSelected),
          border: _getBorder(isToday, isSelected),
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        padding: AppSpacing.paddingXS,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}',
                  style: AppTypography.labelLarge.copyWith(
                    color: _getTextColor(
                      isToday,
                      isSelected,
                      isInCurrentMonth,
                    ),
                    fontWeight: isToday || isSelected
                        ? AppTypography.bold
                        : AppTypography.regular,
                  ),
                ),
                if (hasOverdueTasks && taskCount > 0)
                  Icon(
                    Icons.warning,
                    size: 12,
                    color: AppColors.error,
                  ),
              ],
            ),
            // Task indicator
            if (taskCount > 0)
              _buildTaskIndicator(taskCount, hasOverdueTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIndicator(int count, bool hasOverdue) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: hasOverdue
            ? AppColors.error.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: AppTypography.labelSmall.copyWith(
          color: hasOverdue ? AppColors.error : AppColors.primary,
          fontSize: 10,
          fontWeight: AppTypography.semiBold,
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isToday, bool isSelected) {
    if (isSelected) {
      return AppColors.primary;
    }
    if (isToday) {
      return AppColors.primary.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Border? _getBorder(bool isToday, bool isSelected) {
    if (isSelected) {
      return null;
    }
    if (isToday) {
      return Border.all(color: AppColors.primary, width: 2);
    }
    return null;
  }

  Color _getTextColor(bool isToday, bool isSelected, bool isInCurrentMonth) {
    if (isSelected) {
      return AppColors.white;
    }
    if (!isInCurrentMonth) {
      return AppColors.gray400;
    }
    if (isToday) {
      return AppColors.primary;
    }
    return AppColors.gray900;
  }
}
