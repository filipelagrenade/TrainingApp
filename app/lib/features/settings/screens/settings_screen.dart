/// LiftIQ - Settings Screen
///
/// Main settings screen with all user preferences.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sync_status_indicator.dart';
import '../models/user_settings.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// Main settings screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Units Section
          _SectionHeader(title: 'Units'),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Weight Unit'),
            subtitle: Text(settings.weightUnit == WeightUnit.kg ? 'Kilograms (kg)' : 'Pounds (lbs)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showWeightUnitPicker(context, ref, settings.weightUnit),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Distance Unit'),
            subtitle: Text(settings.distanceUnit == DistanceUnit.km ? 'Kilometers (km)' : 'Miles (mi)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDistanceUnitPicker(context, ref, settings.distanceUnit),
          ),

          const Divider(),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(settings.selectedTheme.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, settings.selectedTheme),
          ),

          const Divider(),

          // Workout Settings Section
          _SectionHeader(title: 'Workout'),
          SwitchListTile(
            secondary: const Icon(Icons.trending_up),
            title: const Text('Weight Suggestions'),
            subtitle: const Text('Show AI-powered weight recommendations'),
            value: settings.showWeightSuggestions,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setShowWeightSuggestions(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.tips_and_updates_outlined),
            title: const Text('Form Cues'),
            subtitle: const Text('Show exercise form tips'),
            value: settings.showFormCues,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setShowFormCues(value),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Rest Timer'),
            subtitle: Text('Default: ${settings.restTimer.defaultRestSeconds}s'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestTimerSettings(context, ref, settings.restTimer),
          ),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: const Text('Default Sets'),
            subtitle: Text('${settings.defaultSets} sets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDefaultSetsPicker(context, ref, settings.defaultSets),
          ),

          const Divider(),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationSettings(context, ref, settings.notifications),
          ),

          const Divider(),

          // Privacy Section
          _SectionHeader(title: 'Privacy'),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacySettings(context, ref, settings.privacy),
          ),

          const Divider(),

          // Sync Section
          _SectionHeader(title: 'Cloud Sync'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SyncStatusCard(),
          ),

          const Divider(),

          // Data Section
          _SectionHeader(title: 'Your Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your data'),
            onTap: () => _showDataExportDialog(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: colors.error),
            title: Text('Delete Account', style: TextStyle(color: colors.error)),
            subtitle: const Text('Permanently delete your account'),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          const Divider(),

          // Workout Section
          _SectionHeader(title: 'Workout'),
          SwitchListTile(
            secondary: const Icon(Icons.swipe),
            title: const Text('Swipe to Complete Sets'),
            subtitle: const Text('Swipe right to complete, left to delete'),
            value: settings.swipeToComplete,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setSwipeToComplete(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('Smart Rest Timer'),
            subtitle: const Text('Adjusts duration based on exercise type and effort'),
            value: settings.restTimer.useSmartRest,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setSmartRestTimer(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_events),
            title: const Text('PR Celebration'),
            subtitle: const Text('Show celebration animation on new personal records'),
            value: settings.showPRCelebration,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setShowPRCelebration(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.music_note),
            title: const Text('Music Controls'),
            subtitle: const Text('Show music player during workouts'),
            value: settings.showMusicControls,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setShowMusicControls(value),
          ),

          const Divider(),

          // General Section
          _SectionHeader(title: 'General'),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            value: settings.hapticFeedback,
            onChanged: (value) => ref.read(userSettingsProvider.notifier).setHapticFeedback(value),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to Defaults'),
            onTap: () => _showResetConfirmation(context, ref),
          ),

          const Divider(),

          // About Section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),

          const Divider(),

          // Account Section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.logout, color: colors.error),
            title: Text('Sign Out', style: TextStyle(color: colors.error)),
            onTap: () => _showSignOutDialog(context, ref),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showWeightUnitPicker(BuildContext context, WidgetRef ref, WeightUnit current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<WeightUnit>(
              title: const Text('Pounds (lbs)'),
              value: WeightUnit.lbs,
              groupValue: current,
              onChanged: (value) {
                ref.read(userSettingsProvider.notifier).setWeightUnit(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<WeightUnit>(
              title: const Text('Kilograms (kg)'),
              value: WeightUnit.kg,
              groupValue: current,
              onChanged: (value) {
                ref.read(userSettingsProvider.notifier).setWeightUnit(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDistanceUnitPicker(BuildContext context, WidgetRef ref, DistanceUnit current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<DistanceUnit>(
              title: const Text('Miles (mi)'),
              value: DistanceUnit.miles,
              groupValue: current,
              onChanged: (value) {
                ref.read(userSettingsProvider.notifier).setDistanceUnit(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<DistanceUnit>(
              title: const Text('Kilometers (km)'),
              value: DistanceUnit.km,
              groupValue: current,
              onChanged: (value) {
                ref.read(userSettingsProvider.notifier).setDistanceUnit(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, LiftIQTheme current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final theme in LiftIQTheme.values)
                  RadioListTile<LiftIQTheme>(
                    title: Text(theme.displayName),
                    subtitle: Text(theme.description),
                    value: theme,
                    groupValue: current,
                    onChanged: (value) {
                      ref.read(userSettingsProvider.notifier).setSelectedTheme(value!);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRestTimerSettings(BuildContext context, WidgetRef ref, RestTimerSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _RestTimerSettingsSheet(settings: settings),
    );
  }

  void _showDefaultSetsPicker(BuildContext context, WidgetRef ref, int current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Sets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 1; i <= 6; i++)
              RadioListTile<int>(
                title: Text('$i sets'),
                value: i,
                groupValue: current,
                onChanged: (value) {
                  ref.read(userSettingsProvider.notifier).setDefaultSets(value!);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref, NotificationSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _NotificationSettingsSheet(settings: settings),
    );
  }

  void _showPrivacySettings(BuildContext context, WidgetRef ref, PrivacySettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PrivacySettingsSheet(settings: settings),
    );
  }

  void _showDataExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Your Data'),
        content: const Text(
          'We will prepare a download containing all your data. '
          'This includes workouts, settings, and any other information associated with your account.\n\n'
          'You will receive a notification when your export is ready (usually within 24 hours).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(gdprProvider.notifier).requestDataExport();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export requested!')),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action is irreversible. All your data including workouts, '
          'templates, and progress will be permanently deleted after 30 days.\n\n'
          'You can cancel this request within the 30-day period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(gdprProvider.notifier).requestAccountDeletion();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion scheduled. You can cancel within 30 days.'),
                ),
              );
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(userSettingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Rest timer settings bottom sheet.
class _RestTimerSettingsSheet extends ConsumerWidget {
  final RestTimerSettings settings;

  const _RestTimerSettingsSheet({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rest Timer Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Default Rest Time'),
            subtitle: Text('${settings.defaultRestSeconds} seconds'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: settings.defaultRestSeconds > 30
                      ? () => ref.read(userSettingsProvider.notifier)
                          .setDefaultRestTime(settings.defaultRestSeconds - 15)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: settings.defaultRestSeconds < 300
                      ? () => ref.read(userSettingsProvider.notifier)
                          .setDefaultRestTime(settings.defaultRestSeconds + 15)
                      : null,
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-start after set'),
            value: settings.autoStart,
            onChanged: (value) => ref.read(userSettingsProvider.notifier)
                .setRestTimerSettings(settings.copyWith(autoStart: value)),
          ),
          SwitchListTile(
            title: const Text('Vibrate on complete'),
            value: settings.vibrateOnComplete,
            onChanged: (value) => ref.read(userSettingsProvider.notifier)
                .setRestTimerSettings(settings.copyWith(vibrateOnComplete: value)),
          ),
          SwitchListTile(
            title: const Text('Sound on complete'),
            value: settings.soundOnComplete,
            onChanged: (value) => ref.read(userSettingsProvider.notifier)
                .setRestTimerSettings(settings.copyWith(soundOnComplete: value)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Notification settings bottom sheet.
class _NotificationSettingsSheet extends ConsumerWidget {
  final NotificationSettings settings;

  const _NotificationSettingsSheet({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: scrollController,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Master toggle for all notifications'),
              value: settings.enabled,
              onChanged: (value) => ref.read(userSettingsProvider.notifier)
                  .toggleNotification('enabled', value),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Workout Reminders'),
              value: settings.workoutReminders && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('workoutReminders', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('PR Celebrations'),
              value: settings.prCelebrations && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('prCelebrations', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Rest Timer Alerts'),
              value: settings.restTimerAlerts && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('restTimerAlerts', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Social Activity'),
              subtitle: const Text('Likes, follows, comments'),
              value: settings.socialActivity && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('socialActivity', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Challenge Updates'),
              value: settings.challengeUpdates && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('challengeUpdates', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('AI Coach Tips'),
              subtitle: const Text('Personalized training advice'),
              value: settings.aiCoachTips && settings.enabled,
              onChanged: settings.enabled
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .toggleNotification('aiCoachTips', value)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Privacy settings bottom sheet.
class _PrivacySettingsSheet extends ConsumerWidget {
  final PrivacySettings settings;

  const _PrivacySettingsSheet({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: scrollController,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text('Anyone can view your profile'),
              value: settings.publicProfile,
              onChanged: (value) => ref.read(userSettingsProvider.notifier)
                  .togglePrivacy('publicProfile', value),
            ),
            SwitchListTile(
              title: const Text('Show Workout History'),
              value: settings.showWorkoutHistory && settings.publicProfile,
              onChanged: settings.publicProfile
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .togglePrivacy('showWorkoutHistory', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Show Personal Records'),
              value: settings.showPRs && settings.publicProfile,
              onChanged: settings.publicProfile
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .togglePrivacy('showPRs', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Show Streak'),
              value: settings.showStreak && settings.publicProfile,
              onChanged: settings.publicProfile
                  ? (value) => ref.read(userSettingsProvider.notifier)
                      .togglePrivacy('showStreak', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Appear in Search'),
              value: settings.appearInSearch,
              onChanged: (value) => ref.read(userSettingsProvider.notifier)
                  .togglePrivacy('appearInSearch', value),
            ),
          ],
        ),
      ),
    );
  }
}
