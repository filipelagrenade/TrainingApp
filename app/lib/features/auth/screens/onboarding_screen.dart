/// LiftIQ Onboarding Screen
///
/// Collects user preferences after account creation:
/// - Unit preference (kg/lbs)
/// - Experience level
/// - Training goals
/// - Privacy policy acceptance
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

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
  bool _acceptedPrivacy = false;

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
                children: List.generate(4, (index) {
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
                    child: Text(_currentPage == 3 ? 'Get Started' : 'Continue'),
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
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // TODO: Save preferences to backend
    // await ref.read(authProvider.notifier).completeOnboarding(
    //   unitPreference: _unitPreference!,
    //   experienceLevel: _experienceLevel!,
    //   primaryGoal: _primaryGoal!,
    // );

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
            subtitle: 'Get stronger on main lifts',
            icon: Icons.fitness_center,
            isSelected: selected == 'STRENGTH',
            onTap: () => onSelected('STRENGTH'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Build Muscle',
            subtitle: 'Gain muscle mass',
            icon: Icons.accessibility_new,
            isSelected: selected == 'HYPERTROPHY',
            onTap: () => onSelected('HYPERTROPHY'),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'General Fitness',
            subtitle: 'Overall health and conditioning',
            icon: Icons.favorite,
            isSelected: selected == 'GENERAL_FITNESS',
            onTap: () => onSelected('GENERAL_FITNESS'),
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

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
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
          child: Row(
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
                    Text(
                      title,
                      style: context.textTheme.titleMedium,
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
        ),
      ),
    );
  }
}
