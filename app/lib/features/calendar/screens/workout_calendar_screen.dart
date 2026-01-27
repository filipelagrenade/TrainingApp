/// LiftIQ - Workout Calendar Screen
///
/// Displays a calendar view of scheduled and completed workouts.
/// Allows scheduling new workouts and viewing workout history.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/scheduled_workout.dart';
import '../providers/calendar_provider.dart';
import '../widgets/schedule_workout_sheet.dart';

/// Calendar screen showing scheduled and completed workouts.
class WorkoutCalendarScreen extends ConsumerStatefulWidget {
  const WorkoutCalendarScreen({super.key});

  @override
  ConsumerState<WorkoutCalendarScreen> createState() =>
      _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState
    extends ConsumerState<WorkoutCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scheduledWorkoutsAsync = ref.watch(scheduledWorkoutsProvider);
    final scheduledDates = ref.watch(scheduledDatesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Workout Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget
          _buildCalendar(theme, colors, scheduledDates),

          // Divider
          Divider(height: 1, color: colors.outlineVariant),

          // Selected day's workouts
          Expanded(
            child: _buildSelectedDayWorkouts(
              context,
              theme,
              colors,
              scheduledWorkoutsAsync,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scheduleWorkout(context),
        icon: const Icon(Icons.add),
        label: const Text('Schedule'),
      ),
    );
  }

  Widget _buildCalendar(
    ThemeData theme,
    ColorScheme colors,
    Set<DateTime> scheduledDates,
  ) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() => _calendarFormat = format);
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return scheduledDates.contains(normalizedDay) ? [true] : [];
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: colors.onPrimaryContainer),
        selectedDecoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: colors.onPrimary),
        markerDecoration: BoxDecoration(
          color: colors.tertiary,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 1,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: theme.textTheme.labelMedium!,
        titleCentered: true,
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: theme.textTheme.labelSmall!.copyWith(
          color: colors.onSurfaceVariant,
        ),
        weekendStyle: theme.textTheme.labelSmall!.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSelectedDayWorkouts(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    AsyncValue<List<ScheduledWorkout>> scheduledWorkoutsAsync,
  ) {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Select a day to view workouts',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    final workoutsForDay = ref.watch(workoutsForDateProvider(_selectedDay!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                _formatSelectedDate(_selectedDay!),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (workoutsForDay.isNotEmpty)
                Text(
                  '${workoutsForDay.length} workout${workoutsForDay.length > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),

        // Workouts list
        Expanded(
          child: workoutsForDay.isEmpty
              ? _buildEmptyDay(context, theme, colors)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workoutsForDay.length,
                  itemBuilder: (context, index) {
                    return _ScheduledWorkoutCard(
                      workout: workoutsForDay[index],
                      onTap: () =>
                          _showWorkoutOptions(context, workoutsForDay[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDay(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isPast = _selectedDay!.isBefore(DateTime.now());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.history : Icons.event_available,
              size: 48,
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isPast ? 'No workouts recorded' : 'No workouts scheduled',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (!isPast || isToday) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _scheduleWorkout(context),
                icon: const Icon(Icons.add),
                label: Text(isToday ? 'Start Workout' : 'Schedule'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (isSameDay(date, now)) {
      return 'Today';
    }
    if (isSameDay(date, tomorrow)) {
      return 'Tomorrow';
    }
    if (isSameDay(date, yesterday)) {
      return 'Yesterday';
    }

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _scheduleWorkout(BuildContext context) async {
    final config = await showScheduleWorkoutSheet(context);
    if (config == null) return;

    await ref.read(scheduledWorkoutsProvider.notifier).scheduleWorkout(config);

    if (context.mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout scheduled!')),
      );

      // Update selected day to show the new workout
      setState(() {
        _selectedDay = config.scheduledAt;
        _focusedDay = config.scheduledAt;
      });
    }
  }

  void _showWorkoutOptions(BuildContext context, ScheduledWorkout workout) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Workout'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(scheduledWorkoutsProvider.notifier)
                    .startScheduledWorkout(workout.id);
                context.push('/workout/active');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Open edit sheet
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next),
              title: const Text('Skip'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(scheduledWorkoutsProvider.notifier)
                    .skipScheduledWorkout(workout.id);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(scheduledWorkoutsProvider.notifier)
                    .deleteScheduledWorkout(workout.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying a scheduled workout.
class _ScheduledWorkoutCard extends StatelessWidget {
  final ScheduledWorkout workout;
  final VoidCallback onTap;

  const _ScheduledWorkoutCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(colors).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(colors),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workout.formattedTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedDurationMinutes}m',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colors) {
    switch (workout.status) {
      case ScheduledWorkoutStatus.scheduled:
        return workout.isOverdue ? colors.error : colors.tertiary;
      case ScheduledWorkoutStatus.inProgress:
        return colors.primary;
      case ScheduledWorkoutStatus.completed:
        return colors.secondary;
      case ScheduledWorkoutStatus.skipped:
        return colors.outline;
      case ScheduledWorkoutStatus.cancelled:
        return colors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (workout.status) {
      case ScheduledWorkoutStatus.scheduled:
        return workout.isOverdue ? Icons.warning : Icons.schedule;
      case ScheduledWorkoutStatus.inProgress:
        return Icons.play_arrow;
      case ScheduledWorkoutStatus.completed:
        return Icons.check_circle;
      case ScheduledWorkoutStatus.skipped:
        return Icons.skip_next;
      case ScheduledWorkoutStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildStatusBadge(ThemeData theme, ColorScheme colors) {
    if (workout.status == ScheduledWorkoutStatus.scheduled &&
        !workout.isOverdue) {
      return const Icon(Icons.chevron_right);
    }

    String text;
    switch (workout.status) {
      case ScheduledWorkoutStatus.scheduled:
        text = 'OVERDUE';
      case ScheduledWorkoutStatus.inProgress:
        text = 'IN PROGRESS';
      case ScheduledWorkoutStatus.completed:
        text = 'DONE';
      case ScheduledWorkoutStatus.skipped:
        text = 'SKIPPED';
      case ScheduledWorkoutStatus.cancelled:
        text = 'CANCELLED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(colors).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(colors),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
