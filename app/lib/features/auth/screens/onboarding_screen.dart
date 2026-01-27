/// LiftIQ Onboarding Screen
///
/// Collects user preferences after account creation:
/// - Unit preference (kg/lbs)
/// - Experience level
/// - Training goals
/// - Training frequency
/// - Rep range preference
/// - Privacy policy acceptance
///
/// These settings enable smart defaults for the progressive overload system.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/models/user_settings.dart';
import '../../settings/providers/settings_provider.dart';

/// Onboarding screen for new users.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // User selections
  String? _unitPreference;
  String? _experienceLevel;
  String? _primaryGoal;
  int _trainingFrequency = 4; // Default 4 days/week
  String? _repRangePreference;
  bool _acceptedPrivacy = false;

  // Total number of pages
  static const _totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_totalPages, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? context.colors.primary
                            : context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _UnitPreferencePage(
                    selected: _unitPreference,
                    onSelected: (value) {
                      setState(() => _unitPreference = value);
                    },
                  ),
                  _ExperienceLevelPage(
                    selected: _experienceLevel,
                    onSelected: (value) {
                      setState(() => _experienceLevel = value);
                    },
                  ),
                  _GoalPage(
                    selected: _primaryGoal,
                    onSelected: (value) {
                      setState(() => _primaryGoal = value);
                    },
                  ),
                  _TrainingFrequencyPage(
                    selected: _trainingFrequency,
                    onSelected: (value) {
                      setState(() => _trainingFrequency = value);
                    },
                  ),
                  _RepRangePreferencePage(
                    selected: _repRangePreference,
                    onSelected: (value) {
                      setState(() => _repRangePreference = value);
                    },
                  ),
                  _PrivacyPage(
                    accepted: _acceptedPrivacy,
                    onAccepted: (value) {
                      setState(() => _acceptedPrivacy = value);
                    },
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _goBack,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canProceed ? _proceed : null,
                    child: Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _unitPreference != null;
      case 1:
        return _experienceLevel != null;
      case 2:
        return _primaryGoal != null;
      case 3:
        return true; // Training frequency always has a default
      case 4:
        return _repRangePreference != null;
      case 5:
        return _acceptedPrivacy;
      default:
        return false;
    }
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _proceed() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // Convert string selections to enum values
    final weightUnit = _unitPreference == 'KG' ? WeightUnit.kg : WeightUnit.lbs;

    final experienceLevel = switch (_experienceLevel) {
      'BEGINNER' => ExperienceLevel.beginner,
      'INTERMEDIATE' => ExperienceLevel.intermediate,
      'ADVANCED' => ExperienceLevel.advanced,
      _ => ExperienceLevel.beginner,
    };

    final trainingGoal = switch (_primaryGoal) {
      'STRENGTH' => TrainingGoal.strength,
      'HYPERTROPHY' => TrainingGoal.hypertrophy,
      'GENERAL_FITNESS' => TrainingGoal.generalFitness,
      'ENDURANCE' => TrainingGoal.endurance,
      _ => TrainingGoal.generalFitness,
    };

    final repRangePreference = switch (_repRangePreference) {
      'CONSERVATIVE' => RepRangePreference.conservative,
      'STANDARD' => RepRangePreference.standard,
      'AGGRESSIVE' => RepRangePreference.aggressive,
      _ => RepRangePreference.standard,
    };

    // Save preferences to settings
    ref.read(userSettingsProvider.notifier).completeOnboardingWithProfile(
      weightUnit: weightUnit,
      experienceLevel: experienceLevel,
      trainingGoal: trainingGoal,
      trainingFrequency: _trainingFrequency,
      repRangePreference: repRangePreference,
    );

    if (mounted) {
      context.go('/');
    }
  }
}

/// Unit preference selection page.
class _UnitPreferencePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _UnitPreferencePage({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Units',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred unit for weights',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Kilograms (kg)',
            subtitle: 'Used in most countries',
            icon: Icons.scale,
            isSelected: selected == 'KG',
            onTap: () => onSelected('KG'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Pounds (lbs)',
            subtitle: 'Used in USA, UK',
            icon: Icons.scale,
            isSelected: selected == 'LBS',
            onTap: () => onSelected('LBS'),
          ),
        ],
      ),
    );
  }
}

/// Experience level selection page.
class _ExperienceLevelPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _ExperienceLevelPage({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience Level',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your training',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Beginner',
            subtitle: 'New to weight training',
            icon: Icons.star_outline,
            isSelected: selected == 'BEGINNER',
            onTap: () => onSelected('BEGINNER'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Intermediate',
            subtitle: '1-3 years of consistent training',
            icon: Icons.star_half,
            isSelected: selected == 'INTERMEDIATE',
            onTap: () => onSelected('INTERMEDIATE'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Advanced',
            subtitle: '3+ years, seeking optimization',
            icon: Icons.star,
            isSelected: selected == 'ADVANCED',
            onTap: () => onSelected('ADVANCED'),
          ),
        ],
      ),
    );
  }
}

/// Goal selection page.
class _GoalPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _GoalPage({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Goal',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "What's your main focus?",
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Build Strength',
            subtitle: 'Get stronger on main lifts (3-5 reps)',
            icon: Icons.fitness_center,
            isSelected: selected == 'STRENGTH',
            onTap: () => onSelected('STRENGTH'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Build Muscle',
            subtitle: 'Gain muscle mass (8-12 reps)',
            icon: Icons.accessibility_new,
            isSelected: selected == 'HYPERTROPHY',
            onTap: () => onSelected('HYPERTROPHY'),
            recommended: true,
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'General Fitness',
            subtitle: 'Overall health and conditioning',
            icon: Icons.favorite,
            isSelected: selected == 'GENERAL_FITNESS',
            onTap: () => onSelected('GENERAL_FITNESS'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Endurance',
            subtitle: 'Muscular endurance (15-20 reps)',
            icon: Icons.timer,
            isSelected: selected == 'ENDURANCE',
            onTap: () => onSelected('ENDURANCE'),
          ),
        ],
      ),
    );
  }
}

/// Training frequency selection page.
class _TrainingFrequencyPage extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _TrainingFrequencyPage({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Frequency',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How many days per week do you typically train?',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us calibrate recovery expectations',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          // Day selector chips
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [2, 3, 4, 5, 6, 7].map((days) {
                final isSelected = selected == days;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(days),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primaryContainer
                            : context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$days',
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: isSelected
                                  ? context.colors.onPrimaryContainer
                                  : context.colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'days',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? context.colors.onPrimaryContainer
                                  : context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          // Description based on selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFrequencyDescription(selected),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyDescription(int days) {
    switch (days) {
      case 2:
        return 'Great for beginners or those with limited time. Focus on full-body workouts.';
      case 3:
        return 'Popular split: Push/Pull/Legs or Full Body 3x. Good balance of training and recovery.';
      case 4:
        return 'Common split: Upper/Lower 2x or Push/Pull/Legs/Upper. Great for intermediate lifters.';
      case 5:
        return 'Higher frequency training. Good for advanced lifters with good recovery.';
      case 6:
        return 'High volume training. Make sure you\'re eating and sleeping enough!';
      case 7:
        return 'Daily training requires careful programming. Consider active recovery days.';
      default:
        return '';
    }
  }
}

/// Rep range preference selection page.
class _RepRangePreferencePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _RepRangePreferencePage({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Style',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How do you prefer to train?',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Strength Focus',
            subtitle: 'Heavy weights, lower reps (3-6 range)',
            icon: Icons.fitness_center,
            isSelected: selected == 'CONSERVATIVE',
            onTap: () => onSelected('CONSERVATIVE'),
            description: 'Prioritizes building maximal strength with heavier loads',
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Balanced / Hypertrophy',
            subtitle: 'Moderate weights, medium reps (6-12 range)',
            icon: Icons.balance,
            isSelected: selected == 'STANDARD',
            onTap: () => onSelected('STANDARD'),
            recommended: true,
            description: 'Best all-around approach for muscle and strength',
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Volume Focus',
            subtitle: 'More sets and reps (10-15 range)',
            icon: Icons.show_chart,
            isSelected: selected == 'AGGRESSIVE',
            onTap: () => onSelected('AGGRESSIVE'),
            description: 'Higher volume for maximum muscle stimulation',
          ),
        ],
      ),
    );
  }
}

/// Privacy policy acceptance page.
class _PrivacyPage extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onAccepted;

  const _PrivacyPage({
    required this.accepted,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your data is important to us',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield),
                    title: const Text('Your Data is Secure'),
                    subtitle: const Text('We encrypt all your workout data'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export Anytime'),
                    subtitle: const Text('Download all your data in JSON'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete on Request'),
                    subtitle: const Text('We honor all deletion requests'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: accepted,
            onChanged: (value) => onAccepted(value ?? false),
            title: const Text('I accept the Privacy Policy'),
            subtitle: const Text('Required to continue'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          TextButton(
            onPressed: () {
              // TODO: Show privacy policy
            },
            child: const Text('Read Privacy Policy'),
          ),
        ],
      ),
    );
  }
}

/// Reusable selection card widget.
class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool recommended;
  final String? description;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.recommended = false,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? context.colors.primary
              : context.colors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primaryContainer
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: context.textTheme.titleMedium,
                            ),
                            if (recommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Recommended',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          subtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: context.colors.primary,
                    ),
                ],
              ),
              if (description != null && isSelected) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    description!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
