/// LiftIQ - Exercise Settings Panel
///
/// Expandable settings section for each exercise card.
/// Groups cable attachment, unilateral toggle, weight type, and RPE controls.
library;

import 'package:flutter/material.dart';

import '../models/exercise_log.dart';
import '../models/weight_input.dart';

/// Expandable panel for per-exercise settings.
///
/// Shows below the exercise header when the gear icon is tapped.
/// Includes cable attachment, unilateral toggle, weight type, and RPE toggle.
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

  /// Called when cable attachment changes.
  final ValueChanged<CableAttachment?> onCableAttachmentChanged;

  /// Called when unilateral is toggled.
  final VoidCallback onUnilateralToggled;

  /// Called when weight type changes.
  final ValueChanged<WeightInputType> onWeightTypeChanged;

  /// Called when RPE toggle changes.
  final ValueChanged<bool> onRpeToggled;

  const ExerciseSettingsPanel({
    super.key,
    required this.isCableExercise,
    this.cableAttachment,
    required this.isUnilateral,
    required this.weightType,
    required this.rpeEnabled,
    required this.onCableAttachmentChanged,
    required this.onUnilateralToggled,
    required this.onWeightTypeChanged,
    required this.onRpeToggled,
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
        ],
      ),
    );
  }

  Widget _buildCableAttachmentChips(ThemeData theme, ColorScheme colors) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: CableAttachment.values.map((attachment) {
        final isSelected = cableAttachment == attachment;
        return ChoiceChip(
          label: Text(attachment.label),
          selected: isSelected,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
          ),
          visualDensity: VisualDensity.compact,
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
      spacing: 6,
      runSpacing: 6,
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
          visualDensity: VisualDensity.compact,
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
}) {
  return cableAttachment != null ||
      isUnilateral ||
      weightType != WeightInputType.absolute ||
      rpeEnabled;
}
