/// LiftIQ - Exercise Settings Panel
///
/// Expandable settings section for each exercise card.
/// Groups cable attachment, unilateral toggle, weight type, RPE controls,
/// and per-exercise rep range overrides.
library;

import 'package:flutter/material.dart';

import '../models/exercise_log.dart';
import '../models/rep_range.dart';
import '../models/weight_input.dart';

/// Expandable panel for per-exercise settings.
///
/// Shows below the exercise header when the gear icon is tapped.
/// Includes cable attachment, unilateral toggle, weight type, RPE toggle,
/// and custom rep range override.
class ExerciseSettingsPanel extends StatelessWidget {
  /// Whether this exercise uses cable equipment.
  final bool isCableExercise;

  /// Current cable attachment selection.
  final CableAttachment? cableAttachment;

  /// Whether unilateral mode is active.
  final bool isUnilateral;

  /// Current weight input type.
  final WeightInputType weightType;

  /// Whether RPE tracking is enabled.
  final bool rpeEnabled;

  /// Custom rep range override for this exercise (null = use goal default).
  final RepRange? customRepRange;

  /// Called when cable attachment changes.
  final ValueChanged<CableAttachment?> onCableAttachmentChanged;

  /// Called when unilateral is toggled.
  final VoidCallback onUnilateralToggled;

  /// Called when weight type changes.
  final ValueChanged<WeightInputType> onWeightTypeChanged;

  /// Called when RPE toggle changes.
  final ValueChanged<bool> onRpeToggled;

  /// Called when rep range override changes (null to clear).
  final ValueChanged<RepRange?> onRepRangeChanged;

  const ExerciseSettingsPanel({
    super.key,
    required this.isCableExercise,
    this.cableAttachment,
    required this.isUnilateral,
    required this.weightType,
    required this.rpeEnabled,
    this.customRepRange,
    required this.onCableAttachmentChanged,
    required this.onUnilateralToggled,
    required this.onWeightTypeChanged,
    required this.onRpeToggled,
    required this.onRepRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cable Attachment (only for cable exercises)
          if (isCableExercise) ...[
            _SectionLabel(label: 'Cable Attachment', theme: theme),
            const SizedBox(height: 6),
            _buildCableAttachmentChips(theme, colors),
            const SizedBox(height: 12),
          ],

          // Weight Type
          _SectionLabel(label: 'Weight Type', theme: theme),
          const SizedBox(height: 6),
          _buildWeightTypeChips(theme, colors),
          const SizedBox(height: 12),

          // Toggles row
          Row(
            children: [
              // Unilateral toggle
              Expanded(
                child: _ToggleRow(
                  label: 'Unilateral',
                  icon: Icons.back_hand_outlined,
                  isActive: isUnilateral,
                  onTap: onUnilateralToggled,
                  theme: theme,
                  colors: colors,
                ),
              ),
              const SizedBox(width: 12),
              // RPE toggle
              Expanded(
                child: _ToggleRow(
                  label: 'Track RPE',
                  icon: Icons.speed,
                  isActive: rpeEnabled,
                  onTap: () => onRpeToggled(!rpeEnabled),
                  theme: theme,
                  colors: colors,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rep Range Override
          _SectionLabel(label: 'Rep Range Override', theme: theme),
          const SizedBox(height: 6),
          _buildRepRangeSection(theme, colors),
        ],
      ),
    );
  }

  Widget _buildRepRangeSection(ThemeData theme, ColorScheme colors) {
    // Preset options for quick selection
    final presets = [
      (RepRangePreset.strength, 'Strength', '3-5'),
      (RepRangePreset.hypertrophy, 'Hypertrophy', '6-12'),
      (RepRangePreset.endurance, 'Endurance', '15-20'),
    ];

    // Determine which preset is currently selected (if any)
    RepRangePreset? selectedPreset;
    if (customRepRange != null) {
      if (customRepRange!.floor == 3 && customRepRange!.ceiling == 5) {
        selectedPreset = RepRangePreset.strength;
      } else if (customRepRange!.floor == 6 && customRepRange!.ceiling == 12) {
        selectedPreset = RepRangePreset.hypertrophy;
      } else if (customRepRange!.floor == 15 && customRepRange!.ceiling == 20) {
        selectedPreset = RepRangePreset.endurance;
      } else {
        selectedPreset = RepRangePreset.custom;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current override display with clear button
        if (customRepRange != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.repeat, size: 16, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  customRepRange!.displayString,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onRepRangeChanged(null),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Preset chips + custom
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            // Default (no override) chip
            ChoiceChip(
              label: const Text('Default'),
              selected: customRepRange == null,
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: customRepRange == null
                    ? colors.onPrimaryContainer
                    : colors.onSurface,
              ),
              visualDensity: VisualDensity.comfortable,
              onSelected: (_) => onRepRangeChanged(null),
            ),
            // Preset chips
            ...presets.map((entry) {
              final (preset, label, range) = entry;
              final isSelected = selectedPreset == preset;
              return ChoiceChip(
                label: Text('$label ($range)'),
                selected: isSelected,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color:
                      isSelected ? colors.onPrimaryContainer : colors.onSurface,
                ),
                visualDensity: VisualDensity.comfortable,
                onSelected: (_) {
                  if (isSelected) {
                    // Deselect → back to default
                    onRepRangeChanged(null);
                  } else {
                    onRepRangeChanged(preset.defaultRange);
                  }
                },
              );
            }),
          ],
        ),

        // Help text
        const SizedBox(height: 6),
        Text(
          customRepRange == null
              ? 'Using goal-based rep range'
              : 'Overrides the default rep range for this exercise',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCableAttachmentChips(ThemeData theme, ColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CableAttachment.values.map((attachment) {
        final isSelected = cableAttachment == attachment;
        return ChoiceChip(
          label: Text(attachment.label),
          selected: isSelected,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
          ),
          visualDensity: VisualDensity.comfortable,
          onSelected: (_) {
            onCableAttachmentChanged(isSelected ? null : attachment);
          },
        );
      }).toList(),
    );
  }

  Widget _buildWeightTypeChips(ThemeData theme, ColorScheme colors) {
    final types = [
      (WeightInputType.absolute, 'Absolute', Icons.fitness_center),
      (WeightInputType.perSide, 'Per Side', Icons.compare_arrows),
      (WeightInputType.bodyweight, 'Bodyweight', Icons.accessibility_new),
      (WeightInputType.band, 'Band', Icons.power_input),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((entry) {
        final (type, label, icon) = entry;
        final isSelected = weightType == type;
        return ChoiceChip(
          avatar: Icon(icon, size: 16),
          label: Text(label),
          selected: isSelected,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
          ),
          visualDensity: VisualDensity.comfortable,
          onSelected: (_) => onWeightTypeChanged(type),
        );
      }).toList(),
    );
  }
}

/// A small section label.
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A toggle row with icon, label, and active state.
class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colors;

  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primaryContainer.withOpacity(0.5)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? colors.primary.withOpacity(0.5)
                : colors.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Whether any non-default exercise settings are active.
bool hasActiveSettings({
  CableAttachment? cableAttachment,
  required bool isUnilateral,
  required WeightInputType weightType,
  required bool rpeEnabled,
  RepRange? customRepRange,
}) {
  return cableAttachment != null ||
      isUnilateral ||
      weightType != WeightInputType.absolute ||
      rpeEnabled ||
      customRepRange != null;
}
