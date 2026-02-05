// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconAsset: json['iconAsset'] as String,
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
      category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
      tier: $enumDecode(_$AchievementTierEnumMap, json['tier']),
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetProgress: (json['targetProgress'] as num).toInt(),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconAsset': instance.iconAsset,
      'color': const ColorConverter().toJson(instance.color),
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'tier': _$AchievementTierEnumMap[instance.tier]!,
      'currentProgress': instance.currentProgress,
      'targetProgress': instance.targetProgress,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.strength: 'strength',
  AchievementCategory.volume: 'volume',
  AchievementCategory.milestones: 'milestones',
  AchievementCategory.social: 'social',
};

const _$AchievementTierEnumMap = {
  AchievementTier.bronze: 'bronze',
  AchievementTier.silver: 'silver',
  AchievementTier.gold: 'gold',
  AchievementTier.platinum: 'platinum',
};
