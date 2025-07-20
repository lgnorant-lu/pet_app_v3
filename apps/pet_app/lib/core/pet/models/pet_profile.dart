/*
---------------------------------------------------------------
File name:          pet_profile.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠档案模型
---------------------------------------------------------------
*/

/// 桌宠档案模型
///
/// 存储桌宠的详细信息和历史记录
class PetProfile {
  /// 桌宠ID
  final String petId;

  /// 桌宠名称
  final String name;

  /// 桌宠昵称
  final String nickname;

  /// 桌宠描述
  final String description;

  /// 桌宠头像URL
  final String? avatarUrl;

  /// 桌宠背景故事
  final String backstory;

  /// 桌宠性格特征
  final List<String> personality;

  /// 桌宠喜好
  final List<String> likes;

  /// 桌宠厌恶
  final List<String> dislikes;

  /// 桌宠技能
  final List<PetSkill> skills;

  /// 桌宠成就
  final List<PetAchievement> achievements;

  /// 桌宠统计数据
  final PetStatistics statistics;

  /// 桌宠关系
  final List<PetRelationship> relationships;

  /// 桌宠记忆
  final List<PetMemory> memories;

  /// 桌宠偏好设置
  final PetPreferences preferences;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const PetProfile({
    required this.petId,
    required this.name,
    required this.nickname,
    required this.description,
    this.avatarUrl,
    required this.backstory,
    required this.personality,
    required this.likes,
    required this.dislikes,
    required this.skills,
    required this.achievements,
    required this.statistics,
    required this.relationships,
    required this.memories,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建默认档案
  factory PetProfile.createDefault({
    required String petId,
    required String name,
    String? nickname,
    String description = '',
    String backstory = '',
  }) {
    final now = DateTime.now();

    return PetProfile(
      petId: petId,
      name: name,
      nickname: nickname ?? name,
      description: description,
      backstory: backstory,
      personality: ['友好', '好奇'],
      likes: ['玩耍', '学习'],
      dislikes: ['孤独', '无聊'],
      skills: [],
      achievements: [],
      statistics: PetStatistics.initial(),
      relationships: [],
      memories: [],
      preferences: PetPreferences.createDefault(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 复制并更新档案
  PetProfile copyWith({
    String? petId,
    String? name,
    String? nickname,
    String? description,
    String? avatarUrl,
    String? backstory,
    List<String>? personality,
    List<String>? likes,
    List<String>? dislikes,
    List<PetSkill>? skills,
    List<PetAchievement>? achievements,
    PetStatistics? statistics,
    List<PetRelationship>? relationships,
    List<PetMemory>? memories,
    PetPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      petId: petId ?? this.petId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backstory: backstory ?? this.backstory,
      personality: personality ?? this.personality,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      statistics: statistics ?? this.statistics,
      relationships: relationships ?? this.relationships,
      memories: memories ?? this.memories,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 添加技能
  PetProfile addSkill(PetSkill skill) {
    final updatedSkills = List<PetSkill>.from(skills);
    final existingIndex = updatedSkills.indexWhere((s) => s.id == skill.id);

    if (existingIndex >= 0) {
      updatedSkills[existingIndex] = skill;
    } else {
      updatedSkills.add(skill);
    }

    return copyWith(skills: updatedSkills);
  }

  /// 添加成就
  PetProfile addAchievement(PetAchievement achievement) {
    if (achievements.any((a) => a.id == achievement.id)) {
      return this; // 成就已存在
    }

    final updatedAchievements = List<PetAchievement>.from(achievements)
      ..add(achievement);

    return copyWith(achievements: updatedAchievements);
  }

  /// 添加记忆
  PetProfile addMemory(PetMemory memory) {
    final updatedMemories = List<PetMemory>.from(memories)..add(memory);

    // 限制记忆数量
    if (updatedMemories.length > 100) {
      updatedMemories.removeAt(0);
    }

    return copyWith(memories: updatedMemories);
  }

  /// 获取技能等级
  int getSkillLevel(String skillId) {
    final skill = skills.firstWhere(
      (s) => s.id == skillId,
      orElse: () => PetSkill(
        id: skillId,
        name: '',
        level: 0,
        experience: 0,
        learnedAt: DateTime.now(),
      ),
    );
    return skill.level;
  }

  /// 判断是否拥有成就
  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.id == achievementId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetProfile && other.petId == petId;
  }

  @override
  int get hashCode => petId.hashCode;

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'name': name,
      'nickname': nickname,
      'description': description,
      'avatarUrl': avatarUrl,
      'backstory': backstory,
      'personality': personality,
      'likes': likes,
      'dislikes': dislikes,
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'achievements': achievements
          .map((achievement) => achievement.toJson())
          .toList(),
      'statistics': statistics.toJson(),
      'relationships': relationships.map((rel) => rel.toJson()).toList(),
      'memories': memories.map((memory) => memory.toJson()).toList(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      petId: json['petId'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      backstory: json['backstory'] as String,
      personality: List<String>.from(json['personality'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      dislikes: List<String>.from(json['dislikes'] ?? []),
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((skillJson) => PetSkill.fromJson(skillJson))
              .toList() ??
          [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map(
                (achievementJson) => PetAchievement.fromJson(achievementJson),
              )
              .toList() ??
          [],
      statistics: PetStatistics.fromJson(json['statistics'] ?? {}),
      relationships:
          (json['relationships'] as List<dynamic>?)
              ?.map((relJson) => PetRelationship.fromJson(relJson))
              .toList() ??
          [],
      memories:
          (json['memories'] as List<dynamic>?)
              ?.map((memoryJson) => PetMemory.fromJson(memoryJson))
              .toList() ??
          [],
      preferences: PetPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() =>
      'PetProfile(petId: $petId, name: $name, nickname: $nickname)';
}

/// 桌宠技能
class PetSkill {
  final String id;
  final String name;
  final String description;
  final int level;
  final int experience;
  final int maxLevel;
  final DateTime learnedAt;

  const PetSkill({
    required this.id,
    required this.name,
    this.description = '',
    required this.level,
    required this.experience,
    this.maxLevel = 10,
    required this.learnedAt,
  });

  factory PetSkill.create({
    required String id,
    required String name,
    String description = '',
    int level = 1,
    int experience = 0,
    int maxLevel = 10,
  }) {
    return PetSkill(
      id: id,
      name: name,
      description: description,
      level: level,
      experience: experience,
      maxLevel: maxLevel,
      learnedAt: DateTime.now(),
    );
  }

  PetSkill copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    int? experience,
    int? maxLevel,
    DateTime? learnedAt,
  }) {
    return PetSkill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      maxLevel: maxLevel ?? this.maxLevel,
      learnedAt: learnedAt ?? this.learnedAt,
    );
  }

  /// 获取升级所需经验
  int get experienceToNextLevel {
    if (level >= maxLevel) return 0;
    return (level * 100) - experience;
  }

  /// 判断是否可以升级
  bool get canLevelUp {
    return level < maxLevel && experience >= (level * 100);
  }

  /// 判断是否已满级
  bool get isMaxLevel => level >= maxLevel;

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'experience': experience,
      'maxLevel': maxLevel,
      'learnedAt': learnedAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetSkill.fromJson(Map<String, dynamic> json) {
    return PetSkill(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      level: json['level'] as int,
      experience: json['experience'] as int,
      maxLevel: json['maxLevel'] as int? ?? 10,
      learnedAt: DateTime.parse(json['learnedAt'] as String),
    );
  }
}

/// 桌宠成就
class PetAchievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final int points;
  final String iconUrl;
  final DateTime unlockedAt;

  const PetAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.points,
    required this.iconUrl,
    required this.unlockedAt,
  });

  factory PetAchievement.create({
    required String id,
    required String name,
    required String description,
    String category = 'general',
    int points = 10,
    String iconUrl = '',
  }) {
    return PetAchievement(
      id: id,
      name: name,
      description: description,
      category: category,
      points: points,
      iconUrl: iconUrl,
      unlockedAt: DateTime.now(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'points': points,
      'iconUrl': iconUrl,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetAchievement.fromJson(Map<String, dynamic> json) {
    return PetAchievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'general',
      points: json['points'] as int? ?? 10,
      iconUrl: json['iconUrl'] as String? ?? '',
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }
}

/// 桌宠统计数据
class PetStatistics {
  final int totalInteractions;
  final int totalPlayTime; // 分钟
  final int totalFeedCount;
  final int totalCleanCount;
  final int totalLearningTime; // 分钟
  final int totalSleepTime; // 分钟
  final Map<String, int> activityCounts;
  final Map<String, int> moodCounts;
  final DateTime firstInteraction;
  final DateTime lastInteraction;

  const PetStatistics({
    required this.totalInteractions,
    required this.totalPlayTime,
    required this.totalFeedCount,
    required this.totalCleanCount,
    required this.totalLearningTime,
    required this.totalSleepTime,
    required this.activityCounts,
    required this.moodCounts,
    required this.firstInteraction,
    required this.lastInteraction,
  });

  factory PetStatistics.initial() {
    final now = DateTime.now();
    return PetStatistics(
      totalInteractions: 0,
      totalPlayTime: 0,
      totalFeedCount: 0,
      totalCleanCount: 0,
      totalLearningTime: 0,
      totalSleepTime: 0,
      activityCounts: {},
      moodCounts: {},
      firstInteraction: now,
      lastInteraction: now,
    );
  }

  PetStatistics copyWith({
    int? totalInteractions,
    int? totalPlayTime,
    int? totalFeedCount,
    int? totalCleanCount,
    int? totalLearningTime,
    int? totalSleepTime,
    Map<String, int>? activityCounts,
    Map<String, int>? moodCounts,
    DateTime? firstInteraction,
    DateTime? lastInteraction,
  }) {
    return PetStatistics(
      totalInteractions: totalInteractions ?? this.totalInteractions,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalFeedCount: totalFeedCount ?? this.totalFeedCount,
      totalCleanCount: totalCleanCount ?? this.totalCleanCount,
      totalLearningTime: totalLearningTime ?? this.totalLearningTime,
      totalSleepTime: totalSleepTime ?? this.totalSleepTime,
      activityCounts: activityCounts ?? this.activityCounts,
      moodCounts: moodCounts ?? this.moodCounts,
      firstInteraction: firstInteraction ?? this.firstInteraction,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'totalInteractions': totalInteractions,
      'totalPlayTime': totalPlayTime,
      'totalFeedCount': totalFeedCount,
      'totalCleanCount': totalCleanCount,
      'totalLearningTime': totalLearningTime,
      'totalSleepTime': totalSleepTime,
      'activityCounts': activityCounts,
      'moodCounts': moodCounts,
      'firstInteraction': firstInteraction.toIso8601String(),
      'lastInteraction': lastInteraction.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetStatistics.fromJson(Map<String, dynamic> json) {
    return PetStatistics(
      totalInteractions: json['totalInteractions'] as int? ?? 0,
      totalPlayTime: json['totalPlayTime'] as int? ?? 0,
      totalFeedCount: json['totalFeedCount'] as int? ?? 0,
      totalCleanCount: json['totalCleanCount'] as int? ?? 0,
      totalLearningTime: json['totalLearningTime'] as int? ?? 0,
      totalSleepTime: json['totalSleepTime'] as int? ?? 0,
      activityCounts: Map<String, int>.from(json['activityCounts'] ?? {}),
      moodCounts: Map<String, int>.from(json['moodCounts'] ?? {}),
      firstInteraction: DateTime.parse(
        json['firstInteraction'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastInteraction: DateTime.parse(
        json['lastInteraction'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// 桌宠关系
class PetRelationship {
  final String targetId;
  final String targetType; // 'user', 'pet', 'npc'
  final String relationshipType;
  final int affection; // 0-100
  final DateTime establishedAt;

  const PetRelationship({
    required this.targetId,
    required this.targetType,
    required this.relationshipType,
    required this.affection,
    required this.establishedAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetType': targetType,
      'relationshipType': relationshipType,
      'affection': affection,
      'establishedAt': establishedAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetRelationship.fromJson(Map<String, dynamic> json) {
    return PetRelationship(
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      relationshipType: json['relationshipType'] as String,
      affection: json['affection'] as int,
      establishedAt: DateTime.parse(json['establishedAt'] as String),
    );
  }
}

/// 桌宠记忆
class PetMemory {
  final String id;
  final String type;
  final String content;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const PetMemory({
    required this.id,
    required this.type,
    required this.content,
    required this.metadata,
    required this.createdAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetMemory.fromJson(Map<String, dynamic> json) {
    return PetMemory(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// 桌宠偏好设置
class PetPreferences {
  final bool autoFeed;
  final bool autoClean;
  final bool autoPlay;
  final int interactionFrequency; // 1-10
  final List<String> favoriteActivities;
  final Map<String, dynamic> customSettings;

  const PetPreferences({
    required this.autoFeed,
    required this.autoClean,
    required this.autoPlay,
    required this.interactionFrequency,
    required this.favoriteActivities,
    required this.customSettings,
  });

  factory PetPreferences.createDefault() {
    return const PetPreferences(
      autoFeed: false,
      autoClean: false,
      autoPlay: true,
      interactionFrequency: 5,
      favoriteActivities: ['playing', 'learning'],
      customSettings: {},
    );
  }

  PetPreferences copyWith({
    bool? autoFeed,
    bool? autoClean,
    bool? autoPlay,
    int? interactionFrequency,
    List<String>? favoriteActivities,
    Map<String, dynamic>? customSettings,
  }) {
    return PetPreferences(
      autoFeed: autoFeed ?? this.autoFeed,
      autoClean: autoClean ?? this.autoClean,
      autoPlay: autoPlay ?? this.autoPlay,
      interactionFrequency: interactionFrequency ?? this.interactionFrequency,
      favoriteActivities: favoriteActivities ?? this.favoriteActivities,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'autoFeed': autoFeed,
      'autoClean': autoClean,
      'autoPlay': autoPlay,
      'interactionFrequency': interactionFrequency,
      'favoriteActivities': favoriteActivities,
      'customSettings': customSettings,
    };
  }

  /// 从JSON创建
  factory PetPreferences.fromJson(Map<String, dynamic> json) {
    return PetPreferences(
      autoFeed: json['autoFeed'] as bool? ?? false,
      autoClean: json['autoClean'] as bool? ?? false,
      autoPlay: json['autoPlay'] as bool? ?? true,
      interactionFrequency: json['interactionFrequency'] as int? ?? 5,
      favoriteActivities: List<String>.from(
        json['favoriteActivities'] ?? ['playing', 'learning'],
      ),
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }
}
