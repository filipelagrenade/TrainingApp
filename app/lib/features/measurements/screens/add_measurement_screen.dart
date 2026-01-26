/// LiftIQ - Add Measurement Screen
///
/// Screen for adding or editing body measurements.
/// Provides input fields for all measurement types with validation.
///
/// Features:
/// - Numeric inputs with increment/decrement
/// - Date selection
/// - Optional notes
/// - Photo attachment
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/body_measurement.dart';
import '../providers/measurements_provider.dart';

/// Screen for adding a new body measurement.
class AddMeasurementScreen extends ConsumerStatefulWidget {
  /// Creates an add measurement screen.
  const AddMeasurementScreen({super.key, this.existingMeasurement});

  /// If provided, we're editing an existing measurement.
  final BodyMeasurement? existingMeasurement;

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _measurementDate;
  bool _isSaving = false;

  // Controllers for all fields
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _neckController = TextEditingController();
  final _shouldersController = TextEditingController();
  final _chestController = TextEditingController();
  final _leftBicepController = TextEditingController();
  final _rightBicepController = TextEditingController();
  final _leftForearmController = TextEditingController();
  final _rightForearmController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _leftThighController = TextEditingController();
  final _rightThighController = TextEditingController();
  final _leftCalfController = TextEditingController();
  final _rightCalfController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.existingMeasurement != null;

  @override
  void initState() {
    super.initState();
    _measurementDate = widget.existingMeasurement?.measuredAt ?? DateTime.now();

    if (widget.existingMeasurement != null) {
      final m = widget.existingMeasurement!;
      _weightController.text = m.weight?.toString() ?? '';
      _bodyFatController.text = m.bodyFat?.toString() ?? '';
      _neckController.text = m.neck?.toString() ?? '';
      _shouldersController.text = m.shoulders?.toString() ?? '';
      _chestController.text = m.chest?.toString() ?? '';
      _leftBicepController.text = m.leftBicep?.toString() ?? '';
      _rightBicepController.text = m.rightBicep?.toString() ?? '';
      _leftForearmController.text = m.leftForearm?.toString() ?? '';
      _rightForearmController.text = m.rightForearm?.toString() ?? '';
      _waistController.text = m.waist?.toString() ?? '';
      _hipsController.text = m.hips?.toString() ?? '';
      _leftThighController.text = m.leftThigh?.toString() ?? '';
      _rightThighController.text = m.rightThigh?.toString() ?? '';
      _leftCalfController.text = m.leftCalf?.toString() ?? '';
      _rightCalfController.text = m.rightCalf?.toString() ?? '';
      _notesController.text = m.notes ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _neckController.dispose();
    _shouldersController.dispose();
    _chestController.dispose();
    _leftBicepController.dispose();
    _rightBicepController.dispose();
    _leftForearmController.dispose();
    _rightForearmController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _leftThighController.dispose();
    _rightThighController.dispose();
    _leftCalfController.dispose();
    _rightCalfController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final input = CreateMeasurementInput(
      measuredAt: _measurementDate,
      weight: _parseDouble(_weightController.text),
      bodyFat: _parseDouble(_bodyFatController.text),
      neck: _parseDouble(_neckController.text),
      shoulders: _parseDouble(_shouldersController.text),
      chest: _parseDouble(_chestController.text),
      leftBicep: _parseDouble(_leftBicepController.text),
      rightBicep: _parseDouble(_rightBicepController.text),
      leftForearm: _parseDouble(_leftForearmController.text),
      rightForearm: _parseDouble(_rightForearmController.text),
      waist: _parseDouble(_waistController.text),
      hips: _parseDouble(_hipsController.text),
      leftThigh: _parseDouble(_leftThighController.text),
      rightThigh: _parseDouble(_rightThighController.text),
      leftCalf: _parseDouble(_leftCalfController.text),
      rightCalf: _parseDouble(_rightCalfController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final notifier = ref.read(measurementsNotifierProvider.notifier);
    BodyMeasurement? result;

    if (_isEditing) {
      result = await notifier.updateMeasurement(
        widget.existingMeasurement!.id,
        input,
      );
    } else {
      result = await notifier.createMeasurement(input);
    }

    setState(() => _isSaving = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Measurement updated!' : 'Measurement saved!',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _measurementDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _measurementDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(measurementsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Measurement' : 'New Measurement'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date selector
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Measurement Date'),
                subtitle: Text(
                  DateFormat.yMMMd().format(_measurementDate),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 24),

            // Weight section
            _SectionHeader(
              icon: Icons.monitor_weight,
              title: 'Weight & Body Fat',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _weightController,
                    label: 'Weight',
                    suffix: state.weightUnit == WeightUnit.kg ? 'kg' : 'lbs',
                    icon: Icons.scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _bodyFatController,
                    label: 'Body Fat',
                    suffix: '%',
                    icon: Icons.percent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upper body section
            _SectionHeader(
              icon: Icons.accessibility_new,
              title: 'Upper Body',
            ),
            const SizedBox(height: 12),
            _MeasurementField(
              controller: _neckController,
              label: 'Neck',
              suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
            ),
            const SizedBox(height: 12),
            _MeasurementField(
              controller: _shouldersController,
              label: 'Shoulders',
              suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
            ),
            const SizedBox(height: 12),
            _MeasurementField(
              controller: _chestController,
              label: 'Chest',
              suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
            ),
            const SizedBox(height: 24),

            // Arms section
            _SectionHeader(
              icon: Icons.fitness_center,
              title: 'Arms',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _leftBicepController,
                    label: 'Left Bicep',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _rightBicepController,
                    label: 'Right Bicep',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _leftForearmController,
                    label: 'Left Forearm',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _rightForearmController,
                    label: 'Right Forearm',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Core section
            _SectionHeader(
              icon: Icons.circle_outlined,
              title: 'Core',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _waistController,
                    label: 'Waist',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _hipsController,
                    label: 'Hips',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Legs section
            _SectionHeader(
              icon: Icons.directions_walk,
              title: 'Legs',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _leftThighController,
                    label: 'Left Thigh',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _rightThighController,
                    label: 'Right Thigh',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    controller: _leftCalfController,
                    label: 'Left Calf',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MeasurementField(
                    controller: _rightCalfController,
                    label: 'Right Calf',
                    suffix: state.lengthUnit == LengthUnit.cm ? 'cm' : 'in',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notes section
            _SectionHeader(
              icon: Icons.notes,
              title: 'Notes',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Optional notes about this measurement...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }
}

/// Section header with icon.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Measurement input field with increment/decrement buttons.
class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null || num <= 0) {
            return 'Invalid value';
          }
        }
        return null;
      },
    );
  }
}
