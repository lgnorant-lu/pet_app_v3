/*
---------------------------------------------------------------
File name:          pet_entity.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠实体模型 - 表示一个完整的桌宠实例
---------------------------------------------------------------
*/

import 'package:desktop_pet/src/models/enums/index.dart';

/// 桌宠实体模型
///
/// 表示一个完整的桌宠实例，包含所有基本属性和状态
class PetEntity {

  const PetEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.color,
    required this.size,
    required this.gender,
    required this.birthday,
    required this.status,
    required this.mood,
    required this.currentActivity,
    required this.level,
    required this.experience,
    required this.health,
    required this.energy,
    required this.hunger,
    required this.happiness,
    required this.cleanliness,
    required this.intelligence,
    required this.social,
    required this.creativity,
    required this.positionX,
    required this.positionY,
    required this.rotation,
    required this.isVisible,
    required this.isInteractable,
    required this.lastInteraction,
    required this.lastFed,
    required this.lastCleaned,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建默认桌宠
  factory PetEntity.createDefault({
    required String name,
    String type = 'cat',
    String breed = 'domestic',
    String color = 'orange',
    String gender = 'unknown',
  }) {
    final DateTime now = DateTime.now();
    final String id = 'pet_${now.millisecondsSinceEpoch}';

    return PetEntity(
      id: id,
      name: name,
      type: type,
      breed: breed,
      color: color,
      size: 1,
      gender: gender,
      birthday: now,
      status: PetStatus.baby,
      mood: PetMood.happy,
      currentActivity: PetActivity.idle,
      level: 1,
      experience: 0,
      health: 100,
      energy: 80,
      hunger: 20,
      happiness: 80,
      cleanliness: 90,
      intelligence: 50,
      social: 50,
      creativity: 50,
      positionX: 0,
      positionY: 0,
      rotation: 0,
      isVisible: true,
      isInteractable: true,
      lastInteraction: now,
      lastFed: now,
      lastCleaned: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从JSON创建
  factory PetEntity.fromJson(Map<String, dynamic> json) => PetEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String,
      color: json['color'] as String,
      size: (json['size'] as num).toDouble(),
      gender: json['gender'] as String,
      birthday: DateTime.parse(json['birthday'] as String),
      status: PetStatus.fromId(json['status'] as String),
      mood: PetMood.fromId(json['mood'] as String),
      currentActivity: PetActivity.fromId(json['currentActivity'] as String),
      level: json['level'] as int,
      experience: json['experience'] as int,
      health: json['health'] as int,
      energy: json['energy'] as int,
      hunger: json['hunger'] as int,
      happiness: json['happiness'] as int,
      cleanliness: json['cleanliness'] as int,
      intelligence: json['intelligence'] as int,
      social: json['social'] as int,
      creativity: json['creativity'] as int,
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      isVisible: json['isVisible'] as bool,
      isInteractable: json['isInteractable'] as bool,
      lastInteraction: DateTime.parse(json['lastInteraction'] as String),
      lastFed: DateTime.parse(json['lastFed'] as String),
      lastCleaned: DateTime.parse(json['lastCleaned'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  /// 桌宠唯一标识符
  final String id;

  /// 桌宠名称
  final String name;

  /// 桌宠类型
  final String type;

  /// 桌宠品种
  final String breed;

  /// 桌宠颜色
  final String color;

  /// 桌宠大小
  final double size;

  /// 桌宠性别
  final String gender;

  /// 桌宠生日
  final DateTime birthday;

  /// 桌宠当前状态
  final PetStatus status;

  /// 桌宠当前心情
  final PetMood mood;

  /// 桌宠当前活动
  final PetActivity currentActivity;

  /// 桌宠等级
  final int level;

  /// 桌宠经验值
  final int experience;

  /// 桌宠健康值 (0-100)
  final int health;

  /// 桌宠能量值 (0-100)
  final int energy;

  /// 桌宠饥饿值 (0-100, 100表示非常饥饿)
  final int hunger;

  /// 桌宠快乐值 (0-100)
  final int happiness;

  /// 桌宠清洁度 (0-100)
  final int cleanliness;

  /// 桌宠智力值 (0-100)
  final int intelligence;

  /// 桌宠社交值 (0-100)
  final int social;

  /// 桌宠创造力 (0-100)
  final int creativity;

  /// 桌宠X坐标位置
  final double positionX;

  /// 桌宠Y坐标位置
  final double positionY;

  /// 桌宠旋转角度
  final double rotation;

  /// 桌宠是否可见
  final bool isVisible;

  /// 桌宠是否可交互
  final bool isInteractable;

  /// 最后交互时间
  final DateTime lastInteraction;

  /// 最后喂食时间
  final DateTime lastFed;

  /// 最后清洁时间
  final DateTime lastCleaned;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 获取桌宠年龄（天数）
  int get ageInDays => DateTime.now().difference(birthday).inDays;

  /// 获取桌宠年龄阶段
  String get ageStage {
    final days = ageInDays;
    if (days < 7) return '幼体';
    if (days < 30) return '少年';
    if (days < 90) return '青年';
    if (days < 365) return '成年';
    return '长者';
  }

  /// 获取总体状态评分 (0-100)
  int get overallScore => ((health + energy + (100 - hunger) + happiness + cleanliness) / 5)
        .round();

  /// 判断是否需要关注
  bool get needsAttention => health < 30 ||
        energy < 20 ||
        hunger > 80 ||
        happiness < 30 ||
        cleanliness < 30 ||
        status.needsAttention;

  /// 判断是否健康
  bool get isHealthy => health > 70 &&
        energy > 30 &&
        hunger < 70 &&
        happiness > 50 &&
        cleanliness > 40;

  /// 复制并更新桌宠
  PetEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    String? color,
    double? size,
    String? gender,
    DateTime? birthday,
    PetStatus? status,
    PetMood? mood,
    PetActivity? currentActivity,
    int? level,
    int? experience,
    int? health,
    int? energy,
    int? hunger,
    int? happiness,
    int? cleanliness,
    int? intelligence,
    int? social,
    int? creativity,
    double? positionX,
    double? positionY,
    double? rotation,
    bool? isVisible,
    bool? isInteractable,
    DateTime? lastInteraction,
    DateTime? lastFed,
    DateTime? lastCleaned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      size: size ?? this.size,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      currentActivity: currentActivity ?? this.currentActivity,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      health: health ?? this.health,
      energy: energy ?? this.energy,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      cleanliness: cleanliness ?? this.cleanliness,
      intelligence: intelligence ?? this.intelligence,
      social: social ?? this.social,
      creativity: creativity ?? this.creativity,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      rotation: rotation ?? this.rotation,
      isVisible: isVisible ?? this.isVisible,
      isInteractable: isInteractable ?? this.isInteractable,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      lastFed: lastFed ?? this.lastFed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'color': color,
      'size': size,
      'gender': gender,
      'birthday': birthday.toIso8601String(),
      'status': status.id,
      'mood': mood.id,
      'currentActivity': currentActivity.id,
      'level': level,
      'experience': experience,
      'health': health,
      'energy': energy,
      'hunger': hunger,
      'happiness': happiness,
      'cleanliness': cleanliness,
      'intelligence': intelligence,
      'social': social,
      'creativity': creativity,
      'positionX': positionX,
      'positionY': positionY,
      'rotation': rotation,
      'isVisible': isVisible,
      'isInteractable': isInteractable,
      'lastInteraction': lastInteraction.toIso8601String(),
      'lastFed': lastFed.toIso8601String(),
      'lastCleaned': lastCleaned.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PetEntity(id: $id, name: $name, type: $type, status: $status, mood: $mood)';
}
