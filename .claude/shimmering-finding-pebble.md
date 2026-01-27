R# LiftIQ UX/UI Enhancement Plan

## Overview

A comprehensive implementation of 5 major UX/UI features to make LiftIQ the best workout tracking app experience, plus an overnight mode script for autonomous development.

### Features to Implement
1. **Plate Calculator** - Visual plate loading guide for barbells
2. **PR Celebrations** - Confetti and animations for personal records
3. **Progress Sparklines** - Mini trend charts next to exercises
4. **Workout Summary Cards** - Shareable post-workout graphics
5. **Modern UI Polish** - Glassmorphism, gradients, skeleton loaders
6. **Overnight Mode Script** - Autonomous development workflow

---

## Implementation Order

| # | Feature | Complexity | Files | Priority |
|---|---------|------------|-------|----------|
| 1 | Overnight Mode Script | Low | 1 new | Setup |
| 2 | PR Celebrations | Medium | 4 new, 4 modify | High Impact |
| 3 | Plate Calculator | Medium | 3 new, 3 modify | High Impact |
| 4 | Progress Sparklines | Low-Medium | 2 new, 2 modify | Enhancement |
| 5 | Workout Summary Cards | Medium | 3 new, 2 modify | Social |
| 6 | Modern UI Polish | Medium | 4 new, 4 modify | Polish |

---

## Feature 1: Overnight Mode Script

### Purpose
Enable autonomous overnight development sessions following CLAUDE.md rules.

### New File
`docs/prompts/overnight-mode-prompt.md`

### Content
```markdown
# LiftIQ Overnight Mode

## Quick Start Prompt
Copy this to start an overnight session:

---
OVERNIGHT MODE ACTIVATED. Follow these rules:

1. Use `dangerouslyDisableSandbox: true` on ALL Bash commands
2. Do NOT stop to ask questions - make reasonable decisions
3. Continue until context reaches ~15%
4. Create handover documents after each major feature
5. Commit after each feature with proper messages
6. Self-correct on errors

Current Plan: [path to plan]
Features: [ordered list]

Begin now.
---

## Pre-flight Checklist
- [ ] Tests passing
- [ ] No uncommitted changes
- [ ] Clear feature priority
- [ ] Plan document ready
```

---

## Feature 2: PR Celebrations

### Purpose
Animated celebration when user hits a personal record - confetti, glow, haptics.

### New Files

#### 1. `app/lib/shared/widgets/pr_celebration_overlay.dart`
```dart
/// Full-screen confetti overlay for PR celebrations
class PRCelebrationOverlay extends StatefulWidget {
  final bool isActive;
  final String exerciseName;
  final double weight;
  final int reps;
  final VoidCallback onComplete;
}

// Implementation:
// - ConfettiController from confetti_widget package
// - 2-3 second duration
// - Multiple confetti blast points
// - Haptic feedback (heavy impact)
// - Auto-dismiss on completion
```

#### 2. `app/lib/shared/widgets/pr_glow_badge.dart`
```dart
/// Animated glowing PR badge
class PRGlowBadge extends StatefulWidget {
  final bool animate;
}

// Implementation:
// - TweenAnimationBuilder for pulsing glow
// - BoxShadow with animated spread/blur
// - Gold/yellow color scheme
// - Trophy icon
```

#### 3. `app/lib/features/workouts/providers/pr_celebration_provider.dart`
```dart
/// State for PR celebration queue
@riverpod
class PRCelebration extends _$PRCelebration {
  // Queue multiple PRs
  // Track which PR is currently showing
  // Auto-advance through queue
}

@freezed
class PRCelebrationState {
  bool isActive;
  String? exerciseName;
  double? weight;
  int? reps;
  double? estimated1RM;
}
```

#### 4. `app/lib/core/services/celebration_service.dart`
```dart
/// Handles haptics and optional sounds
class CelebrationService {
  void triggerPRHaptic(); // HapticFeedback.heavyImpact()
  void playPRSound();     // Optional audio
}
```

### Files to Modify

#### 1. `app/lib/features/workouts/screens/active_workout_screen.dart`
- Wrap body in Stack
- Add PRCelebrationOverlay as overlay
- Watch prCelebrationProvider
- Lines to modify: ~180-200 (build method)

#### 2. `app/lib/features/workouts/widgets/set_input_row.dart`
- Replace static PR badge with PRGlowBadge
- Trigger celebration in onComplete when PR detected
- Lines to modify: 684-699 (PR badge section)

#### 3. `app/lib/features/workouts/providers/current_workout_provider.dart`
- Add PR detection in logSet()
- Emit to prCelebrationProvider
- Lines to modify: 356-404 (logSet method)

#### 4. `app/pubspec.yaml`
```yaml
dependencies:
  confetti_widget: ^0.7.0
```

### Data Flow
```
User completes set → logSet() → PR check →
  If PR: Update set.isPersonalRecord + emit celebration →
  PRCelebrationOverlay activates → confetti + haptic →
  Auto-dismiss after 2.5s
```

---

## Feature 3: Plate Calculator

### Purpose
Visual guide showing which plates to load on each side of the barbell.

### New Files

#### 1. `app/lib/features/workouts/widgets/plate_calculator_widget.dart`
```dart
/// Main plate calculator with barbell visualization
class PlateCalculatorWidget extends StatelessWidget {
  final double targetWeight;
  final WeightUnit unit;
  final PlateConfiguration config;
  final Function(double) onWeightSelected;
}

/// Visual barbell with plates
class BarbellVisualization extends StatelessWidget {
  final List<double> platesPerSide;
  final double barWeight;

  // CustomPaint with:
  // - Horizontal bar in center
  // - Color-coded plates (25kg=red, 20kg=blue, etc.)
  // - Plate labels
  // - Symmetrical display
}

/// Individual plate chip
class PlateChip extends StatelessWidget {
  final double weight;
  final Color color;
  // Standard colors:
  // 25kg/55lbs = Red
  // 20kg/45lbs = Blue
  // 15kg/35lbs = Yellow
  // 10kg/25lbs = Green
  // 5kg/10lbs = White
  // 2.5kg/5lbs = Black
  // 1.25kg/2.5lbs = Chrome
}
```

#### 2. `app/lib/features/workouts/models/plate_configuration.dart`
```dart
@freezed
class PlateConfiguration with _$PlateConfiguration {
  const factory PlateConfiguration({
    @Default(20.0) double barWeight,
    @Default([25, 20, 15, 10, 5, 2.5, 1.25]) List<double> availablePlatesKg,
    @Default([45, 35, 25, 10, 5, 2.5]) List<double> availablePlatesLbs,
    @Default({}) Map<double, int> plateQuantities,
  }) = _PlateConfiguration;
}

/// Calculated breakdown result
@freezed
class PlateBreakdown with _$PlateBreakdown {
  const factory PlateBreakdown({
    required double targetWeight,
    required double barWeight,
    required List<double> platesPerSide,
    required double achievedWeight,
    required bool isExactMatch,
  }) = _PlateBreakdown;
}

/// Greedy algorithm for plate calculation
PlateBreakdown calculatePlates({
  required double targetWeight,
  required double barWeight,
  required List<double> availablePlates,
}) {
  final weightPerSide = (targetWeight - barWeight) / 2;
  final plates = <double>[];
  var remaining = weightPerSide;

  for (final plate in availablePlates.sorted((a,b) => b.compareTo(a))) {
    while (remaining >= plate) {
      plates.add(plate);
      remaining -= plate;
    }
  }

  return PlateBreakdown(
    targetWeight: targetWeight,
    barWeight: barWeight,
    platesPerSide: plates,
    achievedWeight: barWeight + plates.fold(0.0, (a,b) => a+b) * 2,
    isExactMatch: remaining < 0.01,
  );
}
```

#### 3. `app/lib/features/settings/screens/plate_settings_screen.dart`
```dart
/// Configure available plates at user's gym
class PlateSettingsScreen extends ConsumerWidget {
  // Bar weight selector (15kg, 20kg, 25kg / 35lbs, 45lbs)
  // Available plates checklist
  // Plate quantity limits (optional)
}
```

### Files to Modify

#### 1. `app/lib/features/workouts/widgets/set_input_row.dart`
- Add calculator icon button next to weight field when equipment == barbell
- Show PlateCalculatorWidget in bottom sheet on tap
- Lines to modify: 485-530 (weight input section)

#### 2. `app/lib/features/settings/screens/settings_screen.dart`
- Add "Plate Calculator Setup" in Workout section
- Navigate to PlateSettingsScreen
- Lines to modify: ~130-140

#### 3. `app/lib/features/settings/models/user_settings.dart`
- Add PlateConfiguration field
- Lines to modify: ~50-60

### Data Flow
```
User taps plate icon → Bottom sheet opens →
  Enter target weight → Calculate breakdown →
  Show visual barbell → Tap "Apply" →
  Weight field updated
```

---

## Feature 4: Progress Sparklines

### Purpose
Mini trend charts showing exercise weight progression over last 4-8 sessions.

### New Files

#### 1. `app/lib/shared/widgets/sparkline_chart.dart`
```dart
/// Minimal line chart for inline display
class SparklineChart extends StatelessWidget {
  final List<double> data;
  final double height;
  final double width;
  final Color lineColor;
  final bool showTrend; // Up/down arrow

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 2. `app/lib/features/workouts/providers/exercise_sparkline_provider.dart`
```dart
@riverpod
Future<List<double>> exerciseSparkline(
  ExerciseSparklineRef ref,
  String exerciseId,
) async {
  final historyService = ref.watch(workoutHistoryServiceProvider);
  final history = await historyService.getPreviousExercisePerformance(
    exerciseId,
    limit: 8,
  );

  // Extract max weight from each session
  return history
    .map((session) => session.sets
      .map((s) => s.weight)
      .reduce(max))
    .toList()
    .reversed
    .toList();
}
```

### Files to Modify

#### 1. `app/lib/features/workouts/screens/active_workout_screen.dart`
- Add SparklineChart to exercise card header
- Position after exercise name, before history button
- Lines to modify: 730-760 (_ExerciseCard._buildHeader)

#### 2. `app/lib/features/exercises/screens/exercise_detail_screen.dart`
- Add larger sparkline in exercise detail
- Show in stats section

---

## Feature 5: Workout Summary Cards

### Purpose
Shareable post-workout graphics for social media.

### New Files

#### 1. `app/lib/features/workouts/widgets/workout_summary_card.dart`
```dart
/// Shareable workout summary card
class WorkoutSummaryCard extends StatelessWidget {
  final CompletedWorkout workout;
  final ShareCardLayout layout;
  final GlobalKey repaintKey;

  enum ShareCardLayout {
    compact,  // Small card with key stats
    detailed, // Full breakdown
    story,    // 9:16 vertical format
  }
}

// Card includes:
// - App logo/branding
// - Workout name
// - Duration
// - Total volume
// - Exercises completed
// - PRs achieved (highlighted)
// - Date
// - Themed background matching app theme
```

#### 2. `app/lib/features/workouts/screens/workout_share_screen.dart`
```dart
/// Preview and share workout card
class WorkoutShareScreen extends ConsumerWidget {
  final String workoutId;

  // Layout selector
  // Preview area
  // Share button
  // Save to gallery button
}
```

#### 3. `app/lib/core/services/screenshot_service.dart`
```dart
/// Capture and share widgets as images
class ScreenshotService {
  Future<Uint8List> capture(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> share(Uint8List bytes, String caption) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/workout_summary.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: caption);
  }
}
```

### Files to Modify

#### 1. `app/lib/features/workouts/screens/workout_detail_screen.dart`
- Add "Share Card" button to app bar
- Navigate to WorkoutShareScreen
- Lines to modify: 76-100 (app bar actions)

#### 2. `app/lib/features/workouts/screens/active_workout_screen.dart`
- Show share option in completion dialog
- Lines to modify: 961-1000 (completion dialog)

---

## Feature 6: Modern UI Polish

### Purpose
Glassmorphism, gradients, and visual refinements throughout the app.

### New Files

#### 1. `app/lib/shared/widgets/glass_container.dart`
```dart
/// Glassmorphism container with backdrop blur
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: colors.outline.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

#### 2. `app/lib/shared/widgets/gradient_progress.dart`
```dart
/// Progress indicator with gradient fill
class GradientProgressIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Gradient gradient;
  final double height;
  final BorderRadius borderRadius;
}
```

#### 3. `app/lib/shared/widgets/empty_state.dart`
```dart
/// Consistent empty state with illustration
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
}
```

#### 4. `app/lib/core/theme/gradients.dart`
```dart
/// Theme-aware gradient presets
abstract final class LiftIQGradients {
  static LinearGradient primary(ColorScheme colors) => LinearGradient(
    colors: [colors.primary, colors.secondary],
  );

  static LinearGradient success => const LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
  );

  static LinearGradient pr => const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );
}
```

### Files to Modify

#### 1. `app/lib/features/workouts/screens/active_workout_screen.dart`
- Apply glass effect to rest timer bar
- Add subtle shadows to exercise cards

#### 2. `app/lib/features/home/screens/home_screen.dart`
- Use gradient progress for weekly goals
- Apply glass effect to quick action cards

#### 3. `app/lib/features/analytics/screens/progress_screen.dart`
- Add gradient accents to stat cards
- Use shimmer loaders for loading states

#### 4. `app/lib/core/theme/app_theme.dart`
- Add glassmorphism properties to theme extension
- Define blur and opacity values per theme

---

## Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  confetti_widget: ^0.7.0      # PR celebrations
  image_gallery_saver: ^2.0.3  # Save workout cards (optional)
```

Already installed:
- `fl_chart: ^0.67.0` - Sparklines
- `shimmer: ^3.0.0` - Loading states
- `share_plus: ^7.2.2` - Sharing

---

## Verification Plan

### PR Celebrations
1. Complete a set that beats your previous best weight
2. Verify confetti animation plays
3. Verify haptic feedback triggers
4. Verify PR badge shows with glow effect

### Plate Calculator
1. Start workout with barbell exercise
2. Tap plate calculator icon
3. Enter target weight (e.g., 100kg)
4. Verify correct plates shown (e.g., 20+20kg bar, 20+20kg per side)
5. Tap apply, verify weight updates

### Progress Sparklines
1. View active workout with exercise that has history
2. Verify mini chart appears next to exercise name
3. Verify trend arrow shows correct direction

### Workout Summary Cards
1. Complete a workout
2. Go to workout detail
3. Tap "Share Card"
4. Select layout, verify preview
5. Share or save to gallery

### Modern UI Polish
1. Navigate through app
2. Verify glass effects on rest timer, cards
3. Verify gradient progress indicators
4. Verify empty states have illustrations
5. Verify shimmer loaders during data fetch

---

## File Summary

### New Files (17)
```
app/lib/shared/widgets/
├── pr_celebration_overlay.dart
├── pr_glow_badge.dart
├── sparkline_chart.dart
├── glass_container.dart
├── gradient_progress.dart
└── empty_state.dart

app/lib/features/workouts/
├── widgets/
│   ├── plate_calculator_widget.dart
│   └── workout_summary_card.dart
├── models/
│   └── plate_configuration.dart
├── providers/
│   ├── pr_celebration_provider.dart
│   └── exercise_sparkline_provider.dart
└── screens/
    └── workout_share_screen.dart

app/lib/features/settings/screens/
└── plate_settings_screen.dart

app/lib/core/
├── services/
│   ├── celebration_service.dart
│   └── screenshot_service.dart
└── theme/
    └── gradients.dart

docs/prompts/
└── overnight-mode-prompt.md
```

### Files to Modify (8)
```
app/lib/features/workouts/screens/active_workout_screen.dart
app/lib/features/workouts/widgets/set_input_row.dart
app/lib/features/workouts/providers/current_workout_provider.dart
app/lib/features/workouts/screens/workout_detail_screen.dart
app/lib/features/settings/screens/settings_screen.dart
app/lib/features/settings/models/user_settings.dart
app/lib/features/home/screens/home_screen.dart
app/lib/core/theme/app_theme.dart
app/pubspec.yaml
```

---

## Overnight Mode Instructions

When ready to implement, use this prompt:

```
OVERNIGHT MODE ACTIVATED for LiftIQ UX/UI Enhancement.

Rules:
- dangerouslyDisableSandbox: true on ALL Bash commands
- Do NOT ask questions - make reasonable decisions
- Continue until ~15% context remains
- Commit after each feature
- Create handover doc when stopping

Implementation Order:
1. PR Celebrations (add confetti_widget, create overlay, integrate)
2. Plate Calculator (model, widget, settings integration)
3. Progress Sparklines (widget, provider, integrate to workout screen)
4. Workout Summary Cards (card widget, share screen, screenshot service)
5. Modern UI Polish (glass container, gradients, apply throughout)

Start with PR Celebrations. Run build_runner after creating freezed models.
```
