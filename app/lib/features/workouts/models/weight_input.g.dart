// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightAbsoluteImpl _$$WeightAbsoluteImplFromJson(Map<String, dynamic> json) =>
    _$WeightAbsoluteImpl(
      weight: (json['weight'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WeightAbsoluteImplToJson(
        _$WeightAbsoluteImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'unit': instance.unit,
      'runtimeType': instance.$type,
    };

_$WeightPlatesImpl _$$WeightPlatesImplFromJson(Map<String, dynamic> json) =>
    _$WeightPlatesImpl(
      platesPerSide: (json['platesPerSide'] as num).toInt(),
      additionalPerSide: (json['additionalPerSide'] as num?)?.toDouble() ?? 0.0,
      barWeight: (json['barWeight'] as num?)?.toDouble() ?? 20.0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WeightPlatesImplToJson(_$WeightPlatesImpl instance) =>
    <String, dynamic>{
      'platesPerSide': instance.platesPerSide,
      'additionalPerSide': instance.additionalPerSide,
      'barWeight': instance.barWeight,
      'runtimeType': instance.$type,
    };

_$WeightBandImpl _$$WeightBandImplFromJson(Map<String, dynamic> json) =>
    _$WeightBandImpl(
      resistance: $enumDecode(_$BandResistanceEnumMap, json['resistance']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WeightBandImplToJson(_$WeightBandImpl instance) =>
    <String, dynamic>{
      'resistance': _$BandResistanceEnumMap[instance.resistance]!,
      'quantity': instance.quantity,
      'runtimeType': instance.$type,
    };

const _$BandResistanceEnumMap = {
  BandResistance.extraLight: 'extraLight',
  BandResistance.light: 'light',
  BandResistance.medium: 'medium',
  BandResistance.heavy: 'heavy',
  BandResistance.extraHeavy: 'extraHeavy',
  BandResistance.max: 'max',
};

_$WeightBodyweightImpl _$$WeightBodyweightImplFromJson(
        Map<String, dynamic> json) =>
    _$WeightBodyweightImpl(
      additionalWeight: (json['additionalWeight'] as num?)?.toDouble() ?? 0.0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WeightBodyweightImplToJson(
        _$WeightBodyweightImpl instance) =>
    <String, dynamic>{
      'additionalWeight': instance.additionalWeight,
      'runtimeType': instance.$type,
    };

_$WeightPerSideImpl _$$WeightPerSideImplFromJson(Map<String, dynamic> json) =>
    _$WeightPerSideImpl(
      weightPerSide: (json['weightPerSide'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WeightPerSideImplToJson(_$WeightPerSideImpl instance) =>
    <String, dynamic>{
      'weightPerSide': instance.weightPerSide,
      'unit': instance.unit,
      'runtimeType': instance.$type,
    };
