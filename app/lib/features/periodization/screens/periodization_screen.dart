/// LiftIQ - Periodization Screen
///
/// Main screen for viewing and managing mesocycles.
/// Shows active mesocycle progress and allows creating new ones.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../programs/providers/user_programs_provider.dart';
import '../../templates/models/training_program.dart';
import '../models/mesocycle.dart';
import '../providers/periodization_provider.dart';
import '../services/mesocycle_program_service.dart';
import '../widgets/week_card.dart';

/// Main periodization planning screen.
///
/// Displays:
/// - Active mesocycle with progress
/// - Week-by-week breakdown
/// - Options to create, edit, or complete mesocycles
class PeriodizationScreen extends ConsumerWidget {
  const PeriodizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Periodization'),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: mesocyclesAsync.when(
        data: (mesocycles) => _buildBody(context, ref, theme, colors, mesocycles),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text('Error loading mesocycles: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(mesocyclesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Mesocycle'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    List<Mesocycle> mesocycles,
  ) {
    // Find active mesocycle
    final activeMesocycle = mesocycles
        .where((m) => m.status == MesocycleStatus.active)
        .firstOrNull;

    if (mesocycles.isEmpty) {
      return _buildEmptyState(context, ref, theme, colors);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active mesocycle section
          if (activeMesocycle != null) ...[
            _buildActiveMesocycleCard(context, ref, theme, colors, activeMesocycle),
            const SizedBox(height: 24),
            Text(
              'Weekly Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...activeMesocycle.weeks.map((week) => WeekCard(
                  week: week,
                  isCurrentWeek: week.weekNumber == activeMesocycle.currentWeek,
                  onTap: () => _showWeekDetails(context, week),
                )),
            const SizedBox(height: 24),
          ],

          // Other mesocycles
          if (mesocycles.where((m) => m.status != MesocycleStatus.active).isNotEmpty) ...[
            Text(
              activeMesocycle != null ? 'Other Mesocycles' : 'Your Mesocycles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...mesocycles
                .where((m) => m.status != MesocycleStatus.active)
                .map((m) => _buildMesocycleListItem(context, ref, theme, colors, m)),
          ],

          // Space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 80,
              color: colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Mesocycles Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a mesocycle to plan your training blocks and periodize your workouts for optimal progress.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create First Mesocycle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMesocycleCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    Mesocycle mesocycle,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mesocycle.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mesocycle.periodizationType.displayName} • ${mesocycle.goal.displayName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Week ${mesocycle.currentWeek} of ${mesocycle.totalWeeks}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(mesocycle.progress * 100).round()}% complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: mesocycle.progress,
                  backgroundColor: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Assigned program info
            if (mesocycle.hasAssignedProgram) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.tertiary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: colors.tertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Program: ${mesocycle.assignedProgramName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (mesocycle.currentWeekData != null)
                            Text(
                              '${(mesocycle.currentWeekData!.volumeMultiplier * 100).round()}% volume · ${(mesocycle.currentWeekData!.intensityMultiplier * 100).round()}% intensity',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Current week info
            if (mesocycle.currentWeekData != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Week: ${mesocycle.currentWeekData!.weekType.displayName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            mesocycle.currentWeekData!.weekType.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _completeWeek(context, ref, mesocycle),
                    child: const Text('Complete Week'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showMesocycleOptions(context, ref, mesocycle),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMesocycleListItem(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    Mesocycle mesocycle,
  ) {
    final statusColor = _getStatusColor(mesocycle.status, colors);
    final isActive = mesocycle.status == MesocycleStatus.active;
    final isPlanned = mesocycle.status == MesocycleStatus.planned;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: isActive ? 2 : 0,
      color: isActive ? statusColor : null,
      child: InkWell(
        onTap: () => _showMesocycleDetails(context, mesocycle),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and status label
              Row(
                children: [
                  Icon(
                    _getStatusIcon(mesocycle.status),
                    color: isActive
                        ? Colors.white.withOpacity(0.8)
                        : statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mesocycle.status.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? Colors.white.withOpacity(0.8)
                          : statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mesocycle name
              Text(
                mesocycle.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isActive ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Stats row
              Text(
                '${mesocycle.totalWeeks} weeks  •  ${mesocycle.goal.displayName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? Colors.white.withOpacity(0.9)
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Action button - full width
              SizedBox(
                width: double.infinity,
                child: isPlanned
                    ? FilledButton.icon(
                        onPressed: () => _startMesocycle(context, ref, mesocycle),
                        style: isActive
                            ? FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: statusColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              )
                            : FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Mesocycle'),
                      )
                    : isActive
                        ? FilledButton.icon(
                            onPressed: () => _showMesocycleDetails(context, mesocycle),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: statusColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _showMesocycleDetails(context, mesocycle),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(MesocycleStatus status, ColorScheme colors) {
    switch (status) {
      case MesocycleStatus.planned:
        return colors.tertiary;
      case MesocycleStatus.active:
        return colors.primary;
      case MesocycleStatus.completed:
        return colors.secondary;
      case MesocycleStatus.abandoned:
        return colors.error;
    }
  }

  IconData _getStatusIcon(MesocycleStatus status) {
    switch (status) {
      case MesocycleStatus.planned:
        return Icons.schedule;
      case MesocycleStatus.active:
        return Icons.play_arrow;
      case MesocycleStatus.completed:
        return Icons.check_circle;
      case MesocycleStatus.abandoned:
        return Icons.cancel;
    }
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MesocycleBuilderScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showWeekDetails(BuildContext context, MesocycleWeek week) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week ${week.weekNumber}: ${week.weekType.displayName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(week.weekType.description),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Volume', '${(week.volumeMultiplier * 100).round()}%'),
            _buildDetailRow(context, 'Intensity', '${(week.intensityMultiplier * 100).round()}%'),
            if (week.rirTarget != null)
              _buildDetailRow(context, 'RIR Target', '${week.rirTarget}'),
            if (week.notes != null) ...[
              const SizedBox(height: 16),
              Text('Notes: ${week.notes}'),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _completeWeek(BuildContext context, WidgetRef ref, Mesocycle mesocycle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Week?'),
        content: Text(
          'Mark Week ${mesocycle.currentWeek} as completed and advance to the next week?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(mesocyclesProvider.notifier).advanceWeek(mesocycle.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Week completed!')),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _startMesocycle(BuildContext context, WidgetRef ref, Mesocycle mesocycle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Mesocycle?'),
        content: Text(
          'Start "${mesocycle.name}"? This will replace any currently active mesocycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(mesocyclesProvider.notifier).startMesocycle(mesocycle.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mesocycle started!')),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showMesocycleOptions(BuildContext context, WidgetRef ref, Mesocycle mesocycle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Mesocycle'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Complete Early'),
              onTap: () {
                Navigator.of(context).pop();
                // Mark as completed
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Abandon Mesocycle',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(mesocyclesProvider.notifier).abandonMesocycle(mesocycle.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMesocycleDetails(BuildContext context, Mesocycle mesocycle) {
    // TODO: Navigate to detail screen
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Periodization'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Periodization is the systematic planning of athletic training. '
                'A mesocycle is a multi-week training block (typically 4-8 weeks) '
                'that focuses on specific training goals.',
              ),
              SizedBox(height: 16),
              Text(
                'Types of Periodization:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Linear: Gradual increase in intensity'),
              Text('• Undulating: Varies intensity daily/weekly'),
              Text('• Block: Distinct training phases'),
              SizedBox(height: 16),
              Text(
                'Week Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Accumulation: High volume, build work capacity'),
              Text('• Intensification: High intensity, build strength'),
              Text('• Deload: Low volume/intensity for recovery'),
              Text('• Peak: Max intensity for testing/competition'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Screen for building a new mesocycle step-by-step.
class MesocycleBuilderScreen extends ConsumerStatefulWidget {
  const MesocycleBuilderScreen({super.key});

  @override
  ConsumerState<MesocycleBuilderScreen> createState() => _MesocycleBuilderScreenState();
}

class _MesocycleBuilderScreenState extends ConsumerState<MesocycleBuilderScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  MesocycleGoal _selectedGoal = MesocycleGoal.hypertrophy;
  int _totalWeeks = 6;
  PeriodizationType _periodizationType = PeriodizationType.linear;
  DateTime _startDate = DateTime.now();
  TrainingProgram? _selectedProgram;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Mesocycle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: List.generate(6, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentStep + 1} of 6',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentStep > 0)
                  TextButton.icon(
                    onPressed: _onStepCancel,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
              ],
            ),
            if (_currentStep > 0) const SizedBox(height: 8),
            Text(
              const ['Select Goal', 'Duration', 'Periodization Type', 'Assign Program', 'Details', 'Review'][_currentStep],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentStep == 0) _buildGoalStep(theme),
            if (_currentStep == 1) _buildDurationStep(theme),
            if (_currentStep == 2) _buildPeriodizationStep(theme),
            if (_currentStep == 3) _buildProgramStep(theme),
            if (_currentStep == 4) _buildDetailsStep(theme),
            if (_currentStep == 5) _buildReviewStep(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStep(ThemeData theme) {
    return Column(
      children: MesocycleGoal.values.map((goal) {
        final isSelected = _selectedGoal == goal;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? theme.colorScheme.primaryContainer : null,
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            title: Text(
              goal.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(goal.description),
            onTap: () {
              setState(() => _selectedGoal = goal);
              // Auto-advance after short delay
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _onStepContinue();
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How many weeks?', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        Slider(
          value: _totalWeeks.toDouble(),
          min: 4,
          max: 12,
          divisions: 8,
          label: '$_totalWeeks weeks',
          onChanged: (value) => setState(() => _totalWeeks = value.round()),
        ),
        Text(
          '$_totalWeeks weeks',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended: 4-8 weeks for most goals',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodizationStep(ThemeData theme) {
    return Column(
      children: PeriodizationType.values.map((type) {
        final isSelected = _periodizationType == type;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? theme.colorScheme.primaryContainer : null,
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            title: Text(
              type.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(type.description),
            onTap: () {
              setState(() => _periodizationType = type);
              // Auto-advance after short delay
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _onStepContinue();
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgramStep(ThemeData theme) {
    final programs = ref.watch(userProgramsProvider);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optionally assign a training program to this mesocycle. '
          'The program\'s workouts will be automatically adjusted based on each week\'s volume and intensity settings.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // No program option
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: _selectedProgram == null ? colors.primaryContainer : null,
          child: ListTile(
            leading: Icon(
              _selectedProgram == null ? Icons.check_circle : Icons.circle_outlined,
              color: _selectedProgram == null ? colors.primary : null,
            ),
            title: Text(
              'No Program',
              style: TextStyle(
                fontWeight: _selectedProgram == null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: const Text('Create mesocycle without linking to a program'),
            onTap: () {
              setState(() => _selectedProgram = null);
            },
          ),
        ),

        if (programs.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
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
                    'No programs created yet. You can create programs in the Programs section.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Your Programs',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...programs.map((program) {
            final isSelected = _selectedProgram?.id == program.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected ? colors.primaryContainer : null,
              child: ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? colors.primary : null,
                ),
                title: Text(
                  program.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${program.templates.length} workouts · ${program.daysPerWeek} days/week',
                ),
                trailing: isSelected
                    ? Chip(
                        label: Text(
                          '${program.templates.length} templates',
                          style: theme.textTheme.labelSmall,
                        ),
                        backgroundColor: colors.primary.withOpacity(0.1),
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedProgram = program);
                },
              ),
            );
          }),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Mesocycle Name',
            hintText: 'e.g., Hypertrophy Block 1',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Focus areas, goals, notes...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Start Date'),
          subtitle: Text(
            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _startDate = date);
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    final endDate = _startDate.add(Duration(days: _totalWeeks * 7));
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Mesocycle',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildReviewRow('Name', _nameController.text.isEmpty ? 'Untitled' : _nameController.text),
        _buildReviewRow('Goal', _selectedGoal.displayName),
        _buildReviewRow('Duration', '$_totalWeeks weeks'),
        _buildReviewRow('Type', _periodizationType.displayName),
        _buildReviewRow('Start', '${_startDate.day}/${_startDate.month}/${_startDate.year}'),
        _buildReviewRow('End', '${endDate.day}/${endDate.month}/${endDate.year}'),
        _buildReviewRow('Program', _selectedProgram?.name ?? 'None'),

        // Show program templates preview if assigned
        if (_selectedProgram != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.tertiary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, size: 18, color: colors.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      'Program Templates',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(_selectedProgram!.templates.take(4).map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${t.name}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ))),
                if (_selectedProgram!.templates.length > 4)
                  Text(
                    '+ ${_selectedProgram!.templates.length - 4} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Create Mesocycle'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 5) {
      // Create the mesocycle
      _createMesocycle();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _createMesocycle() async {
    final name = _nameController.text.isEmpty
        ? '${_selectedGoal.displayName} Block'
        : _nameController.text;

    final config = MesocycleConfig(
      name: name,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      startDate: _startDate,
      totalWeeks: _totalWeeks,
      periodizationType: _periodizationType,
      goal: _selectedGoal,
      assignedProgramId: _selectedProgram?.id,
      assignedProgramName: _selectedProgram?.name,
    );

    await ref.read(mesocyclesProvider.notifier).createMesocycle(config);

    if (mounted) {
      Navigator.of(context).pop();
      final programSuffix = _selectedProgram != null ? ' with ${_selectedProgram!.name}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesocycle "$name" created$programSuffix!')),
      );
    }
  }
}
