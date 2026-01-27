/// LiftIQ - Schedule Workout Sheet Widget
///
/// Bottom sheet for scheduling a new workout.
/// Allows selecting template, date, time, and reminder settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_workout.dart';
import '../providers/calendar_provider.dart';
import '../../templates/providers/templates_provider.dart';
import '../../templates/models/workout_template.dart';

/// Shows the schedule workout sheet and returns the configuration if created.
Future<ScheduleWorkoutConfig?> showScheduleWorkoutSheet(
  BuildContext context, {
  String? preselectedTemplateId,
}) async {
  return showModalBottomSheet<ScheduleWorkoutConfig>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ScheduleWorkoutSheet(
      preselectedTemplateId: preselectedTemplateId,
    ),
  );
}

/// Bottom sheet for scheduling a workout.
class ScheduleWorkoutSheet extends ConsumerStatefulWidget {
  /// Pre-selected template ID (optional).
  final String? preselectedTemplateId;

  const ScheduleWorkoutSheet({
    super.key,
    this.preselectedTemplateId,
  });

  @override
  ConsumerState<ScheduleWorkoutSheet> createState() =>
      _ScheduleWorkoutSheetState();
}

class _ScheduleWorkoutSheetState extends ConsumerState<ScheduleWorkoutSheet> {
  String? _selectedTemplateId;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _estimatedDuration = 60;
  ReminderTiming _reminderTiming = ReminderTiming.minutes30;
  bool _addToCalendar = true;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTemplateId = widget.preselectedTemplateId;

    // Round time to nearest 15 minutes
    final now = TimeOfDay.now();
    final minutes = ((now.minute + 14) ~/ 15) * 15;
    _selectedTime = TimeOfDay(
      hour: minutes >= 60 ? (now.hour + 1) % 24 : now.hour,
      minute: minutes % 60,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final templatesAsync = ref.watch(templatesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Schedule Workout',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Template selector
                    _buildTemplateSelector(theme, colors, templatesAsync),
                    const SizedBox(height: 20),

                    // Date picker
                    _buildDatePicker(theme, colors),
                    const SizedBox(height: 20),

                    // Time picker
                    _buildTimePicker(theme, colors),
                    const SizedBox(height: 20),

                    // Duration
                    _buildDurationSelector(theme, colors),
                    const SizedBox(height: 20),

                    // Reminder
                    _buildReminderSelector(theme, colors),
                    const SizedBox(height: 20),

                    // Calendar toggle
                    _buildCalendarToggle(theme, colors),
                    const SizedBox(height: 20),

                    // Notes
                    _buildNotesField(theme, colors),
                    const SizedBox(height: 32),

                    // Schedule button
                    _buildScheduleButton(theme, colors),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateSelector(
    ThemeData theme,
    ColorScheme colors,
    AsyncValue<List<WorkoutTemplate>> templatesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Template',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No templates yet. Create one first!',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<String>(
              value: _selectedTemplateId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              hint: const Text('Select a template'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Custom Workout'),
                ),
                ...templates.map((t) => DropdownMenuItem<String>(
                      value: t.id,
                      child: Text(t.name),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTemplateId = value;
                  if (value != null) {
                    final template = templates.firstWhere((t) => t.id == value);
                    _estimatedDuration = template.estimatedDuration ?? 60;
                  }
                });
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading templates: $e'),
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colors.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: colors.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Duration',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [30, 45, 60, 90, 120].map((minutes) {
            final isSelected = _estimatedDuration == minutes;
            return ChoiceChip(
              label: Text('${minutes}m'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _estimatedDuration = minutes);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderSelector(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReminderTiming>(
          value: _reminderTiming,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: ReminderTiming.values.map((timing) {
            return DropdownMenuItem<ReminderTiming>(
              value: timing,
              child: Text(timing.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _reminderTiming = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCalendarToggle(ThemeData theme, ColorScheme colors) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Add to Device Calendar',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Sync this workout with your phone calendar',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      value: _addToCalendar,
      onChanged: (value) => setState(() => _addToCalendar = value),
    );
  }

  Widget _buildNotesField(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Add any notes for this workout...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildScheduleButton(ThemeData theme, ColorScheme colors) {
    return FilledButton.icon(
      onPressed: _scheduleWorkout,
      icon: const Icon(Icons.check),
      label: const Text('Schedule Workout'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _scheduleWorkout() {
    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final config = ScheduleWorkoutConfig(
      templateId: _selectedTemplateId,
      customName: _selectedTemplateId == null ? 'Custom Workout' : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      scheduledAt: scheduledAt,
      estimatedDurationMinutes: _estimatedDuration,
      reminderTiming: _reminderTiming,
      addToCalendar: _addToCalendar,
    );

    Navigator.of(context).pop(config);
  }
}
