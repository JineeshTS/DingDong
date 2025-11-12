import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/calendar/calendar.dart';
import 'calendar_date_cell.dart';

/// Month view calendar widget
///
/// Displays a full month calendar grid with:
/// - Week day headers
/// - All dates in the month
/// - Adjacent month dates (grayed out)
/// - Task indicators on dates
/// - Date selection
class MonthViewCalendar extends ConsumerWidget {
  const MonthViewCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final visibleDates = calendarState.visibleDates;
    final weekStartDay = ref.watch(weekStartDayProvider);

    return Column(
      children: [
        // Week day headers
        _buildWeekHeaders(weekStartDay),
        AppSpacing.verticalSpaceXS,

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: AppSpacing.paddingMD,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: visibleDates.length,
            itemBuilder: (context, index) {
              final date = visibleDates[index];
              return CalendarDateCell(
                date: date,
                onTap: () {
                  ref.read(calendarNotifierProvider.notifier).selectDate(date);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeaders(int weekStartDay) {
    final weekDays = _getWeekDayNames(weekStartDay);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _getWeekDayNames(int weekStartDay) {
    const allDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    if (weekStartDay == 0) {
      return allDays; // Start with Sunday
    } else {
      // Start with Monday (or other day)
      return [
        ...allDays.sublist(weekStartDay),
        ...allDays.sublist(0, weekStartDay),
      ];
    }
  }
}
