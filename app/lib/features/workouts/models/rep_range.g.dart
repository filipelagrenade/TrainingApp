// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepRangeImpl _$$RepRangeImplFromJson(Map<String, dynamic> json) =>
    _$RepRangeImpl(
      floor: (json['floor'] as num?)?.toInt() ?? 8,
      ceiling: (json['ceiling'] as num?)?.toInt() ?? 12,
      sessionsAtCeilingRequired:
          (json['sessionsAtCeilingRequired'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$$RepRangeImplToJson(_$RepRangeImpl instance) =>
    <String, dynamic>{
      'floor': instance.floor,
      'ceiling': instance.ceiling,
      'sessionsAtCeilingRequired': instance.sessionsAtCeilingRequired,
    };
