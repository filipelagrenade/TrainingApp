// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlateConfigurationImpl _$$PlateConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$PlateConfigurationImpl(
      barWeight: (json['barWeight'] as num?)?.toDouble() ?? 20.0,
      availablePlatesKg: (json['availablePlatesKg'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25],
      availablePlatesLbs: (json['availablePlatesLbs'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [45.0, 35.0, 25.0, 10.0, 5.0, 2.5],
      plateQuantities: (json['plateQuantities'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      useKg: json['useKg'] as bool? ?? true,
    );

Map<String, dynamic> _$$PlateConfigurationImplToJson(
        _$PlateConfigurationImpl instance) =>
    <String, dynamic>{
      'barWeight': instance.barWeight,
      'availablePlatesKg': instance.availablePlatesKg,
      'availablePlatesLbs': instance.availablePlatesLbs,
      'plateQuantities': instance.plateQuantities,
      'useKg': instance.useKg,
    };

_$PlateBreakdownImpl _$$PlateBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$PlateBreakdownImpl(
      targetWeight: (json['targetWeight'] as num).toDouble(),
      barWeight: (json['barWeight'] as num).toDouble(),
      platesPerSide: (json['platesPerSide'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      achievedWeight: (json['achievedWeight'] as num).toDouble(),
      isExactMatch: json['isExactMatch'] as bool,
    );

Map<String, dynamic> _$$PlateBreakdownImplToJson(
        _$PlateBreakdownImpl instance) =>
    <String, dynamic>{
      'targetWeight': instance.targetWeight,
      'barWeight': instance.barWeight,
      'platesPerSide': instance.platesPerSide,
      'achievedWeight': instance.achievedWeight,
      'isExactMatch': instance.isExactMatch,
    };
