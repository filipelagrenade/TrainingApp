/// LiftIQ - Streak Calendar Widget
///
/// Visual calendar showing workout days with streak tracking.
///
/// Features:
/// - Monthly calendar view
/// - Workout days marked with filled circles
/// - Current streak count display
/// - Longest streak tracking
/// - Color-coded day markers
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/streak_provider.dart';

/// Compact streak display card for dashboard.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentStreak = ref.watch(currentStreakProvider);
    final longestStreak = ref.watch(longestStreakProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: currentStreak > 0 ? colors.error : colors.onSurfaceVariant,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Workout Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => const StreakCalendarSheet(),
                    );
                  },
                  child: const Text('View Calendar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Streak stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StreakStat(
                  label: 'Current',
                  value: currentStreak,
                  icon: Icons.local_fire_department,
                  color: currentStreak > 0 ? colors.error : colors.onSurfaceVariant,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colors.outlineVariant,
                ),
                _StreakStat(
                  label: 'Longest',
                  value: longestStreak,
                  icon: Icons.emoji_events,
                  color: colors.primary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Motivation text
            if (currentStreak > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _getMotivationEmoji(currentStreak),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMotivationText(currentStreak),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMotivationEmoji(int streak) {
    if (streak >= 100) return '\u{1F451}'; // Crown
    if (streak >= 60) return '\u{1F525}'; // Fire
    if (streak >= 30) return '\u{1F4AA}'; // Flexed bicep
    if (streak >= 14) return '\u{2B50}'; // Star
    if (streak >= 7) return '\u{1F44D}'; // Thumbs up
    return '\u{1F44F}'; // Clapping hands
  }

  String _getMotivationText(int streak) {
    if (streak >= 100) return 'Legendary! Over 100 days of dedication!';
    if (streak >= 60) return 'Two months strong! Nothing can stop you!';
    if (streak >= 30) return 'One month milestone! Keep pushing!';
    if (streak >= 14) return 'Two weeks in! A habit is forming!';
    if (streak >= 7) return 'One week down! You\'re building momentum!';
    if (streak >= 3) return 'Great start! Keep showing up!';
    return 'Every rep counts. Let\'s go!';
  }
}

/// Single streak stat display.
class _StreakStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StreakStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          '$label days',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Full calendar sheet for viewing workout history.
class StreakCalendarSheet extends ConsumerStatefulWidget {
  const StreakCalendarSheet({super.key});

  @override
  ConsumerState<StreakCalendarSheet> createState() => _StreakCalendarSheetState();
}

class _StreakCalendarSheetState extends ConsumerState<StreakCalendarSheet> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final workoutDays = ref.watch(workoutDaysProvider(_focusedDay));
    final currentStreak = ref.watch(currentStreakProvider);
    final longestStreak = ref.watch(longestStreakProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Workout Calendar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Streak summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StreakStat(
                      label: 'Current',
                      value: currentStreak,
                      icon: Icons.local_fire_department,
                      color: colors.error,
                    ),
                    _StreakStat(
                      label: 'Longest',
                      value: longestStreak,
                      icon: Icons.emoji_events,
                      color: colors.tertiary,
                    ),
                    _StreakStat(
                      label: 'This Month',
                      value: workoutDays.length,
                      icon: Icons.fitness_center,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: TableCalendar<void>(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final isWorkoutDay = workoutDays.any(
                        (d) => isSameDay(d, day),
                      );

                      if (isWorkoutDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final isWorkoutDay = workoutDays.any(
                        (d) => isSameDay(d, day),
                      );

                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isWorkoutDay
                              ? colors.primary
                              : colors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isWorkoutDay
                                  ? colors.onPrimary
                                  : colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: colors.onSurface,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    titleCentered: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Legend for calendar markers.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: colors.primary,
          label: 'Workout completed',
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: colors.outline,
          label: 'Today',
          isOutlined: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isOutlined;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isOutlined ? null : color,
            shape: BoxShape.circle,
            border: isOutlined ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
