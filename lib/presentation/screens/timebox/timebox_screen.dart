import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/timebox_entity.dart';
import '../../providers/timebox/timebox.dart';
import '../../widgets/timebox/timebox_widgets.dart';

/// Timebox Screen
///
/// Main screen for daily agenda planning with:
/// - Timeline view of tasks
/// - Category breakdown (Personal/Professional/Priority)
/// - Time conflict highlighting
/// - Summary statistics
///
/// WBS: 3.7.8
class TimeboxScreen extends ConsumerStatefulWidget {
  final String userId;
  final DateTime? initialDate;

  const TimeboxScreen({
    super.key,
    required this.userId,
    this.initialDate,
  });

  @override
  ConsumerState<TimeboxScreen> createState() => _TimeboxScreenState();
}

class _TimeboxScreenState extends ConsumerState<TimeboxScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadTimebox();
  }

  void _loadTimebox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timeboxNotifierProvider.notifier).loadTimebox(
            userId: widget.userId,
            date: _selectedDate,
          );
    });
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    ref.read(timeboxNotifierProvider.notifier).loadTimebox(
          userId: widget.userId,
          date: newDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final timeboxState = ref.watch(timeboxNotifierProvider);

    // Listen for errors
    ref.listen<TimeboxState>(timeboxNotifierProvider, (previous, next) {
      next.maybeWhen(
        error: (failure, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _changeDate(DateTime.now()),
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAutoScheduleDialog(context),
            tooltip: 'Auto-Schedule',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Navigation
          TimeboxDatePicker(
            selectedDate: _selectedDate,
            onDateChanged: _changeDate,
          ),

          // Summary Header
          if (timeboxState.hasTimebox)
            TimeboxSummaryHeader(
              summary: timeboxState.summary!,
              hasConflicts: timeboxState.hasConflicts,
            ),

          // Category Filter
          const TimeboxCategoryFilter(),

          // Main Content
          Expanded(
            child: timeboxState.when(
              initial: () => const Center(
                child: Text('Select a date to view your agenda'),
              ),
              loading: (_, message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message),
                    ],
                  ],
                ),
              ),
              loaded: (timebox) => TimeboxTimelineView(
                timebox: timebox,
                onSlotTap: (slot) => _showSlotDetails(context, slot),
                onSlotComplete: (slot) => _completeSlot(slot),
                onSlotReschedule: (slot) => _showRescheduleDialog(context, slot),
              ),
              error: (failure, timebox) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(failure.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTimebox,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSlotDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTimeboxSlotSheet(
        date: _selectedDate,
        onAdd: (slot) {
          ref.read(timeboxNotifierProvider.notifier).addSlot(
                taskId: slot.taskId,
                taskTitle: slot.taskTitle,
                taskDescription: slot.taskDescription,
                startTime: slot.startTime,
                endTime: slot.endTime,
                category: slot.category,
                priority: slot.priority,
              );
        },
      ),
    );
  }

  void _showSlotDetails(BuildContext context, TimeboxSlot slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TimeboxSlotDetailsSheet(
        slot: slot,
        onComplete: () => _completeSlot(slot),
        onSkip: () => ref.read(timeboxNotifierProvider.notifier).skipSlot(slot.id),
        onReschedule: () => _showRescheduleDialog(context, slot),
        onDelete: () => ref.read(timeboxNotifierProvider.notifier).deleteSlot(slot.id),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, TimeboxSlot slot) {
    showDialog(
      context: context,
      builder: (context) => RescheduleSlotDialog(
        slot: slot,
        onReschedule: (newStart, newEnd) {
          ref.read(timeboxNotifierProvider.notifier).rescheduleSlot(
                slotId: slot.id,
                newStartTime: newStart,
                newEndTime: newEnd,
              );
        },
      ),
    );
  }

  void _showAutoScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AutoScheduleDialog(
        date: _selectedDate,
        onSchedule: (tasks) {
          ref.read(timeboxNotifierProvider.notifier).autoScheduleTasks(
                userId: widget.userId,
                date: _selectedDate,
                tasks: tasks,
              );
        },
      ),
    );
  }

  void _completeSlot(TimeboxSlot slot) {
    ref.read(timeboxNotifierProvider.notifier).completeSlot(slot.id);
  }
}
