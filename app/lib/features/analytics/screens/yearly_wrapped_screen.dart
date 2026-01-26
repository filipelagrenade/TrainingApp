/// LiftIQ - Yearly Wrapped Screen
///
/// Full-screen slide-based presentation of yearly training wrapped.
/// Similar to Spotify Wrapped - swipe through cards showing stats.
///
/// Features:
/// - Animated slide transitions
/// - Progress indicator
/// - Share functionality
/// - Year selection
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/yearly_wrapped.dart';
import '../providers/yearly_wrapped_provider.dart';

/// Screen showing the yearly training wrapped.
class YearlyWrappedScreen extends ConsumerStatefulWidget {
  const YearlyWrappedScreen({super.key});

  @override
  ConsumerState<YearlyWrappedScreen> createState() =>
      _YearlyWrappedScreenState();
}

class _YearlyWrappedScreenState extends ConsumerState<YearlyWrappedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load wrapped on init
    Future.microtask(() {
      final year = DateTime.now().year;
      ref.read(yearlyWrappedProvider.notifier).loadWrapped(year);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(yearlyWrappedProvider);
    final colors = Theme.of(context).colorScheme;

    // Listen to slide changes and sync PageView
    ref.listen<int>(currentSlideProvider, (previous, next) {
      if (_pageController.hasClients && previous != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: state.isLoading
            ? _LoadingView()
            : state.hasError
                ? _ErrorView(message: state.errorMessage)
                : state.hasInsufficientData
                    ? _InsufficientDataView(year: state.selectedYear)
                    : state.hasWrapped
                        ? _WrappedSlideShow(
                            wrapped: state.wrapped!,
                            pageController: _pageController,
                          )
                        : const SizedBox.shrink(),
      ),
    );
  }
}

/// Loading view while wrapped generates.
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Generating your Wrapped...',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crunching the numbers',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error view when wrapped fails to generate.
class _ErrorView extends StatelessWidget {
  final String? message;

  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to generate Wrapped',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

/// View when there's not enough training data.
class _InsufficientDataView extends ConsumerWidget {
  final int year;

  const _InsufficientDataView({required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableYears = ref.watch(availableYearsProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📊',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Not enough data for $year',
              style: context.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You need at least 10 workouts to generate your Wrapped. '
              'Keep training and check back soon!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Try a different year:',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: availableYears
                  .where((y) => y != year)
                  .map((y) => OutlinedButton(
                        onPressed: () => ref
                            .read(yearlyWrappedProvider.notifier)
                            .changeYear(y),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: Text('$y'),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main slideshow view for the wrapped.
class _WrappedSlideShow extends ConsumerWidget {
  final YearlyWrapped wrapped;
  final PageController pageController;

  const _WrappedSlideShow({
    required this.wrapped,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(yearlyWrappedProvider);
    final slides = _buildSlides(wrapped);

    return Stack(
      children: [
        // Slides
        PageView.builder(
          controller: pageController,
          itemCount: slides.length,
          onPageChanged: (index) {
            ref.read(yearlyWrappedProvider.notifier).goToSlide(index);
          },
          itemBuilder: (context, index) => slides[index],
        ),

        // Top bar with progress and close
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(
            progress: state.slideProgress,
            year: wrapped.year,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),

        // Navigation hints
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _NavigationHints(
            isFirst: state.isFirstSlide,
            isLast: state.isLastSlide,
            onPrevious: () =>
                ref.read(yearlyWrappedProvider.notifier).previousSlide(),
            onNext: () =>
                ref.read(yearlyWrappedProvider.notifier).nextSlide(),
            onShare: () =>
                ref.read(yearlyWrappedProvider.notifier).shareCurrentSlide(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSlides(YearlyWrapped wrapped) {
    return [
      // Intro slide
      _IntroSlide(year: wrapped.year),

      // Summary slide
      _SummarySlide(summary: wrapped.summary),

      // Personality slide
      _PersonalitySlide(personality: wrapped.personality),

      // Top exercises (up to 3)
      ...wrapped.topExercises.take(3).map((e) => _TopExerciseSlide(exercise: e)),

      // Top PRs (up to 3)
      ...wrapped.topPRs.take(3).map((pr) => _TopPRSlide(pr: pr)),

      // Milestones slide
      _MilestonesSlide(milestones: wrapped.milestones),

      // Fun facts slide
      _FunFactsSlide(facts: wrapped.funFacts),

      // Year over year (if available)
      if (wrapped.yearOverYear != null)
        _YearOverYearSlide(comparison: wrapped.yearOverYear!),

      // Outro slide
      _OutroSlide(wrapped: wrapped),
    ];
  }
}

/// Top bar with progress indicator.
class _TopBar extends StatelessWidget {
  final double progress;
  final int year;
  final VoidCallback onClose;

  const _TopBar({
    required this.progress,
    required this.year,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          // Year and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$year Wrapped',
                style: context.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Navigation hints at bottom.
class _NavigationHints extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShare;

  const _NavigationHints({
    required this.isFirst,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: isFirst ? null : onPrevious,
          ),

          // Share button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: isLast ? null : onNext,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SLIDE WIDGETS
// ============================================================================

/// Base slide container with gradient background.
class _SlideContainer extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget child;

  const _SlideContainer({
    required this.gradientColors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
      child: child,
    );
  }
}

/// Intro slide.
class _IntroSlide extends StatelessWidget {
  final int year;

  const _IntroSlide({required this.year});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.deepPurple.shade900, Colors.purple.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🏋️',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 32),
          Text(
            'Your $year',
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            'Training Wrapped',
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Swipe to see your year in review',
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.swipe_left, color: Colors.white54, size: 32),
        ],
      ),
    );
  }
}

/// Summary statistics slide.
class _SummarySlide extends StatelessWidget {
  final WrappedSummary summary;

  const _SummarySlide({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.blue.shade900, Colors.cyan.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'This year you completed',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.totalWorkouts}',
            style: context.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 80,
            ),
          ),
          Text(
            'workouts',
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                value: summary.formattedTotalTime,
                label: 'Total Time',
              ),
              _MiniStat(
                value: summary.formattedTotalVolume,
                label: 'Volume',
              ),
              _MiniStat(
                value: '${summary.totalPRs}',
                label: 'PRs',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Personality type slide.
class _PersonalitySlide extends StatelessWidget {
  final TrainingPersonality personality;

  const _PersonalitySlide({required this.personality});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.orange.shade900, Colors.amber.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your training personality is',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            personality.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          Text(
            personality.title,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              personality.description,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: personality.traits
                .map((trait) => Chip(
                      label: Text(trait),
                      backgroundColor: Colors.white24,
                      labelStyle: const TextStyle(color: Colors.white),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Top exercise slide.
class _TopExerciseSlide extends StatelessWidget {
  final TopExercise exercise;

  const _TopExerciseSlide({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: exercise.rank == 1
          ? [Colors.amber.shade800, Colors.orange.shade600]
          : exercise.rank == 2
              ? [Colors.blueGrey.shade700, Colors.blueGrey.shade500]
              : [Colors.brown.shade700, Colors.brown.shade500],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            exercise.rank == 1
                ? 'Your #1 exercise'
                : 'Your #${exercise.rank} exercise',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.rankEmoji,
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.exerciseName,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(value: '${exercise.totalSets}', label: 'Sets'),
              _MiniStat(value: exercise.formattedVolume, label: 'Volume'),
              _MiniStat(
                value: '${exercise.best1RM.round()}kg',
                label: 'Best 1RM',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Performed in ${exercise.sessionCount} sessions',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top PR slide.
class _TopPRSlide extends StatelessWidget {
  final YearlyPR pr;

  const _TopPRSlide({required this.pr});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.red.shade900, Colors.pink.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pr.isAllTimePR ? 'All-Time PR' : 'Personal Record',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text('🏆', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            pr.exerciseName,
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            pr.formattedLift,
            style: context.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Est. 1RM: ${pr.estimated1RM.toStringAsFixed(1)} kg',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          if (pr.improvementText != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${pr.improvementText} since start of year',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Achieved in ${pr.monthAchieved}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Milestones slide.
class _MilestonesSlide extends StatelessWidget {
  final List<YearlyMilestone> milestones;

  const _MilestonesSlide({required this.milestones});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.green.shade900, Colors.teal.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Milestones Achieved',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ...milestones.take(4).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(m.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            m.description,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Fun facts slide.
class _FunFactsSlide extends StatelessWidget {
  final List<WrappedFunFact> facts;

  const _FunFactsSlide({required this.facts});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.indigo.shade900, Colors.blue.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fun Facts',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ...facts.take(3).map((fact) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(fact.emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      fact.fact,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Year over year comparison slide.
class _YearOverYearSlide extends StatelessWidget {
  final YearOverYearComparison comparison;

  const _YearOverYearSlide({required this.comparison});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.deepPurple.shade800, Colors.purple.shade600],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Compared to last year',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ComparisonStat(
                label: 'Workouts',
                change: comparison.workoutCountChange,
              ),
              _ComparisonStat(
                label: 'Volume',
                change: comparison.volumeChange,
              ),
              _ComparisonStat(
                label: 'Strength',
                change: comparison.strengthChange,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              comparison.summaryText,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outro slide.
class _OutroSlide extends StatelessWidget {
  final YearlyWrapped wrapped;

  const _OutroSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    return _SlideContainer(
      gradientColors: [Colors.deepPurple.shade900, Colors.purple.shade700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'What a year!',
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You showed up ${wrapped.summary.totalWorkouts} times and '
            'crushed ${wrapped.summary.totalPRs} personal records.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'Here\'s to an even stronger ${wrapped.year + 1}!',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Share Your Wrapped'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

/// Mini stat display for slides.
class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/// Comparison stat with arrow indicator.
class _ComparisonStat extends StatelessWidget {
  final String label;
  final double change;

  const _ComparisonStat({
    required this.label,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change > 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;

    return Column(
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 4),
        Text(
          '${isPositive ? '+' : ''}${change.toStringAsFixed(0)}%',
          style: context.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
