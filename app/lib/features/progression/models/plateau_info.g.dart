// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plateau_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlateauInfoImpl _$$PlateauInfoImplFromJson(Map<String, dynamic> json) =>
    _$PlateauInfoImpl(
      isPlateaued: json['isPlateaued'] as bool,
      sessionsWithoutProgress: (json['sessionsWithoutProgress'] as num).toInt(),
      lastProgressDate: json['lastProgressDate'] == null
          ? null
          : DateTime.parse(json['lastProgressDate'] as String),
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlateauInfoImplToJson(_$PlateauInfoImpl instance) =>
    <String, dynamic>{
      'isPlateaued': instance.isPlateaued,
      'sessionsWithoutProgress': instance.sessionsWithoutProgress,
      'lastProgressDate': instance.lastProgressDate?.toIso8601String(),
      'suggestions': instance.suggestions,
    };
