import 'package:flutter/material.dart';
import '../../../providers/time_tracking/time_tracking_state.dart';

/// Period Selector Widget
///
/// Allows users to select the time period for time tracking data
class PeriodSelector extends StatelessWidget {
  final TimePeriod currentPeriod;
  final Function(TimePeriod) onPeriodSelected;
  final VoidCallback? onCustomRangeTap;

  const PeriodSelector({
    super.key,
    required this.currentPeriod,
    required this.onPeriodSelected,
    this.onCustomRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(
            context,
            period: TimePeriod.today,
            label: 'Today',
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            period: TimePeriod.yesterday,
            label: 'Yesterday',
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            period: TimePeriod.thisWeek,
            label: 'This Week',
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            period: TimePeriod.lastWeek,
            label: 'Last Week',
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            period: TimePeriod.thisMonth,
            label: 'This Month',
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            period: TimePeriod.lastMonth,
            label: 'Last Month',
          ),
          const SizedBox(width: 8),
          _buildCustomRangeChip(context),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context, {
    required TimePeriod period,
    required String label,
  }) {
    final isSelected = currentPeriod == period;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onPeriodSelected(period);
        }
      },
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomRangeChip(BuildContext context) {
    final isSelected = currentPeriod == TimePeriod.custom;

    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range_rounded,
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            'Custom',
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: onCustomRangeTap,
    );
  }
}

/// Compact Period Selector (Dropdown)
class CompactPeriodSelector extends StatelessWidget {
  final TimePeriod currentPeriod;
  final Function(TimePeriod) onPeriodSelected;

  const CompactPeriodSelector({
    super.key,
    required this.currentPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TimePeriod>(
      initialValue: currentPeriod,
      onSelected: onPeriodSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPeriodLabel(currentPeriod),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(TimePeriod.today, 'Today'),
        _buildMenuItem(TimePeriod.yesterday, 'Yesterday'),
        _buildMenuItem(TimePeriod.thisWeek, 'This Week'),
        _buildMenuItem(TimePeriod.lastWeek, 'Last Week'),
        _buildMenuItem(TimePeriod.thisMonth, 'This Month'),
        _buildMenuItem(TimePeriod.lastMonth, 'Last Month'),
      ],
    );
  }

  PopupMenuItem<TimePeriod> _buildMenuItem(TimePeriod period, String label) {
    return PopupMenuItem<TimePeriod>(
      value: period,
      child: Row(
        children: [
          if (currentPeriod == period)
            const Icon(Icons.check_rounded, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return 'Today';
      case TimePeriod.yesterday:
        return 'Yesterday';
      case TimePeriod.thisWeek:
        return 'This Week';
      case TimePeriod.lastWeek:
        return 'Last Week';
      case TimePeriod.thisMonth:
        return 'This Month';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.custom:
        return 'Custom Range';
    }
  }
}
