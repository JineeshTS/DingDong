import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/timebox_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/timebox/timebox.dart';

/// Timebox Widgets
///
/// Collection of UI components for the Timebox feature.
///
/// WBS: 3.7.7

// ============================================================
// 3.7.7.1 TIMELINE VIEW
// ============================================================

/// Timeline view showing daily tasks in time slots
class TimeboxTimelineView extends StatelessWidget {
  final TimeboxEntity timebox;
  final void Function(TimeboxSlot slot)? onSlotTap;
  final void Function(TimeboxSlot slot)? onSlotComplete;
  final void Function(TimeboxSlot slot)? onSlotReschedule;

  const TimeboxTimelineView({
    super.key,
    required this.timebox,
    this.onSlotTap,
    this.onSlotComplete,
    this.onSlotReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSlots = List<TimeboxSlot>.from(timebox.slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (sortedSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks scheduled',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add tasks to plan your day',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSlots.length,
      itemBuilder: (context, index) {
        final slot = sortedSlots[index];
        final conflicts = timebox.conflicts
            .where((c) => c.slot1Id == slot.id || c.slot2Id == slot.id)
            .toList();

        return TimeboxSlotCard(
          slot: slot,
          hasConflict: conflicts.isNotEmpty,
          conflicts: conflicts,
          onTap: () => onSlotTap?.call(slot),
          onComplete: () => onSlotComplete?.call(slot),
          onReschedule: () => onSlotReschedule?.call(slot),
        );
      },
    );
  }
}

// ============================================================
// 3.7.7.2 TIME SLOT CARD
// ============================================================

/// Card widget for a single timebox slot
class TimeboxSlotCard extends StatelessWidget {
  final TimeboxSlot slot;
  final bool hasConflict;
  final List<TimeConflict> conflicts;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onReschedule;

  const TimeboxSlotCard({
    super.key,
    required this.slot,
    this.hasConflict = false,
    this.conflicts = const [],
    this.onTap,
    this.onComplete,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(
      int.parse(slot.category.color.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasConflict ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasConflict
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Column
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.timeDisplay.split(' - ')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      slot.timeDisplay.split(' - ')[1],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.durationMinutes} min',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Category Indicator
              Container(
                width: 4,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            slot.taskTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: slot.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (slot.isPriority)
                          const PriorityBadge(),
                        if (hasConflict)
                          const ConflictIndicator(),
                      ],
                    ),

                    // Category & List
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CategoryChip(category: slot.category),
                        if (slot.listName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            slot.listName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Status
                    if (slot.isCurrentlyActive) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'IN PROGRESS',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // Conflict Warning
                    if (hasConflict) ...[
                      const SizedBox(height: 8),
                      ConflictWarning(conflicts: conflicts),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  if (!slot.isCompleted)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onComplete,
                      color: Colors.green,
                      tooltip: 'Complete',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 3.7.7.3 CONFLICT HIGHLIGHT WIDGET
// ============================================================

/// Indicator for time conflicts
class ConflictIndicator extends StatelessWidget {
  const ConflictIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.warning_amber, color: Colors.red[700], size: 16),
    );
  }
}

/// Warning banner for conflicts
class ConflictWarning extends StatelessWidget {
  final List<TimeConflict> conflicts;

  const ConflictWarning({super.key, required this.conflicts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conflicts with: ${conflicts.map((c) => c.slot2Title).join(", ")}',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3.7.7.4 CATEGORY FILTER CHIPS
// ============================================================

/// Filter chips for task categories
class TimeboxCategoryFilter extends ConsumerStatefulWidget {
  const TimeboxCategoryFilter({super.key});

  @override
  ConsumerState<TimeboxCategoryFilter> createState() =>
      _TimeboxCategoryFilterState();
}

class _TimeboxCategoryFilterState extends ConsumerState<TimeboxCategoryFilter> {
  Set<TaskCategory> _selectedCategories = TaskCategory.values.toSet();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TaskCategory.values.map((category) {
          final isSelected = _selectedCategories.contains(category);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              avatar: Text(category.icon),
              selectedColor: Color(
                int.parse(category.color.replaceFirst('#', '0xFF')),
              ).withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single category chip
class CategoryChip extends StatelessWidget {
  final TaskCategory category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(category.color.replaceFirst('#', '0xFF')),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3.7.7.5 PRIORITY BADGE
// ============================================================

/// Badge indicating high/critical priority
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRIORITY',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// DATE PICKER
// ============================================================

/// Date picker for navigating between days
class TimeboxDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;

  const TimeboxDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onDateChanged(
              selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Column(
              children: [
                Text(
                  isToday ? 'Today' : _formatDate(selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _formatFullDate(selectedDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onDateChanged(
              selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      onDateChanged(date);
    }
  }
}

// ============================================================
// SUMMARY HEADER
// ============================================================

/// Summary statistics header
class TimeboxSummaryHeader extends StatelessWidget {
  final TimeboxSummary summary;
  final bool hasConflicts;

  const TimeboxSummaryHeader({
    super.key,
    required this.summary,
    this.hasConflicts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasConflicts
              ? [Colors.orange[100]!, Colors.orange[50]!]
              : [Colors.blue[100]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Tasks',
            value: '${summary.completedTasks}/${summary.totalTasks}',
            icon: Icons.task_alt,
          ),
          _SummaryItem(
            label: 'Personal',
            value: '${summary.personalTasks}',
            icon: Icons.home,
            color: Colors.green,
          ),
          _SummaryItem(
            label: 'Work',
            value: '${summary.professionalTasks}',
            icon: Icons.work,
            color: Colors.blue,
          ),
          _SummaryItem(
            label: 'Priority',
            value: '${summary.priorityTasks}',
            icon: Icons.priority_high,
            color: Colors.red,
          ),
          if (hasConflicts)
            _SummaryItem(
              label: 'Conflicts',
              value: '${summary.conflictCount}',
              icon: Icons.warning,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[700], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color ?? Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
      ],
    );
  }
}

// ============================================================
// BOTTOM SHEETS & DIALOGS
// ============================================================

/// Bottom sheet for adding a new slot
class AddTimeboxSlotSheet extends StatefulWidget {
  final DateTime date;
  final void Function(TimeboxSlot slot) onAdd;

  const AddTimeboxSlotSheet({
    super.key,
    required this.date,
    required this.onAdd,
  });

  @override
  State<AddTimeboxSlotSheet> createState() => _AddTimeboxSlotSheetState();
}

class _AddTimeboxSlotSheetState extends State<AddTimeboxSlotSheet> {
  final _titleController = TextEditingController();
  TaskCategory _category = TaskCategory.personal;
  TaskPriority _priority = TaskPriority.none;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add Task to Agenda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),

          // Time Selection
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Start'),
                  subtitle: Text(_formatTimeOfDay(_startTime)),
                  onTap: () => _selectTime(true),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('End'),
                  subtitle: Text(_formatTimeOfDay(_endTime)),
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<TaskCategory>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: TaskCategory.values.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Text(cat.icon),
                    const SizedBox(width: 8),
                    Text(cat.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 16),

          // Priority
          DropdownButtonFormField<TaskPriority>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: TaskPriority.values.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _priority = value!),
          ),
          const SizedBox(height: 24),

          // Add Button
          ElevatedButton(
            onPressed: _addSlot,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add to Agenda'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _addSlot() {
    if (_titleController.text.isEmpty) return;

    final startDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _endTime.hour,
      _endTime.minute,
    );

    final slot = TimeboxSlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: 'task_${DateTime.now().millisecondsSinceEpoch}',
      taskTitle: _titleController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      category: _category,
      priority: _priority,
    );

    widget.onAdd(slot);
    Navigator.pop(context);
  }
}

/// Bottom sheet for slot details
class TimeboxSlotDetailsSheet extends StatelessWidget {
  final TimeboxSlot slot;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final VoidCallback? onReschedule;
  final VoidCallback? onDelete;

  const TimeboxSlotDetailsSheet({
    super.key,
    required this.slot,
    this.onComplete,
    this.onSkip,
    this.onReschedule,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CategoryChip(category: slot.category),
              const Spacer(),
              if (slot.isPriority) const PriorityBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            slot.taskTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Time
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                slot.timeDisplay,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 16),
              Text(
                '${slot.durationMinutes} minutes',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!slot.isCompleted)
                _ActionButton(
                  icon: Icons.check_circle,
                  label: 'Complete',
                  color: Colors.green,
                  onTap: () {
                    onComplete?.call();
                    Navigator.pop(context);
                  },
                ),
              if (!slot.isCompleted)
                _ActionButton(
                  icon: Icons.skip_next,
                  label: 'Skip',
                  color: Colors.orange,
                  onTap: () {
                    onSkip?.call();
                    Navigator.pop(context);
                  },
                ),
              _ActionButton(
                icon: Icons.schedule,
                label: 'Reschedule',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onReschedule?.call();
                },
              ),
              _ActionButton(
                icon: Icons.delete,
                label: 'Delete',
                color: Colors.red,
                onTap: () {
                  onDelete?.call();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Dialog for rescheduling a slot
class RescheduleSlotDialog extends StatefulWidget {
  final TimeboxSlot slot;
  final void Function(DateTime newStart, DateTime newEnd) onReschedule;

  const RescheduleSlotDialog({
    super.key,
    required this.slot,
    required this.onReschedule,
  });

  @override
  State<RescheduleSlotDialog> createState() => _RescheduleSlotDialogState();
}

class _RescheduleSlotDialogState extends State<RescheduleSlotDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.fromDateTime(widget.slot.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.slot.endTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reschedule Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_formatTimeOfDay(_startTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) setState(() => _startTime = time);
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_formatTimeOfDay(_endTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) setState(() => _endTime = time);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final date = widget.slot.startTime;
            final newStart = DateTime(
              date.year, date.month, date.day,
              _startTime.hour, _startTime.minute,
            );
            final newEnd = DateTime(
              date.year, date.month, date.day,
              _endTime.hour, _endTime.minute,
            );
            widget.onReschedule(newStart, newEnd);
            Navigator.pop(context);
          },
          child: const Text('Reschedule'),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// Dialog for auto-scheduling tasks
class AutoScheduleDialog extends StatelessWidget {
  final DateTime date;
  final void Function(List<TaskEntity> tasks) onSchedule;

  const AutoScheduleDialog({
    super.key,
    required this.date,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto-Schedule Tasks'),
      content: const Text(
        'This will automatically schedule your unscheduled tasks into optimal time slots based on priority and availability.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // In a real implementation, this would fetch unscheduled tasks
            Navigator.pop(context);
            onSchedule([]);
          },
          child: const Text('Auto-Schedule'),
        ),
      ],
    );
  }
}
