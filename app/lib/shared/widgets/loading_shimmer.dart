/// LiftIQ - Loading Shimmer Widgets
///
/// Provides shimmer loading placeholder widgets for various UI components.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading placeholder for list items.
///
/// Use this when loading a list of cards or items.
class ShimmerLoadingCard extends StatelessWidget {
  /// Creates a shimmer loading card.
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shimmer loading list for displaying multiple loading placeholders.
class ShimmerLoadingList extends StatelessWidget {
  /// Number of shimmer cards to show.
  final int itemCount;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Creates a shimmer loading list.
  const ShimmerLoadingList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => const ShimmerLoadingCard(),
      );
}

/// A shimmer loading placeholder for stats cards.
class ShimmerStatsCard extends StatelessWidget {
  /// Creates a shimmer stats card.
  const ShimmerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shimmer loading placeholder for profile sections.
class ShimmerProfileCard extends StatelessWidget {
  /// Creates a shimmer profile card.
  const ShimmerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 24),
              // Profile info placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shimmer loading placeholder for charts.
class ShimmerChartPlaceholder extends StatelessWidget {
  /// The height of the chart placeholder.
  final double height;

  /// Creates a shimmer chart placeholder.
  const ShimmerChartPlaceholder({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: Card(
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Chart area placeholder
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A shimmer loading placeholder for workout cards.
class ShimmerWorkoutCard extends StatelessWidget {
  /// Creates a shimmer workout card.
  const ShimmerWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Exercise chips row
              Row(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
