/*
---------------------------------------------------------------
File name:          pet_activity.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠活动枚举
---------------------------------------------------------------
*/

/// 桌宠活动枚举
/// 
/// 定义桌宠可以进行的各种活动
enum PetActivity {
  /// 空闲 - 桌宠没有特定活动
  idle('idle', '空闲', '🧘'),
  
  /// 睡觉 - 桌宠正在休息
  sleeping('sleeping', '睡觉', '💤'),
  
  /// 吃东西 - 桌宠正在进食
  eating('eating', '吃东西', '🍽️'),
  
  /// 玩耍 - 桌宠正在娱乐
  playing('playing', '玩耍', '🎮'),
  
  /// 学习 - 桌宠正在学习新技能
  learning('learning', '学习', '📚'),
  
  /// 运动 - 桌宠正在锻炼
  exercising('exercising', '运动', '🏃'),
  
  /// 探索 - 桌宠正在探索环境
  exploring('exploring', '探索', '🔍'),
  
  /// 社交 - 桌宠正在与用户或其他桌宠互动
  socializing('socializing', '社交', '👥'),
  
  /// 工作 - 桌宠正在帮助用户工作
  working('working', '工作', '💼'),
  
  /// 创作 - 桌宠正在进行创意活动
  creating('creating', '创作', '🎨'),
  
  /// 思考 - 桌宠正在深度思考
  thinking('thinking', '思考', '💭'),
  
  /// 清洁 - 桌宠正在整理环境
  cleaning('cleaning', '清洁', '🧹'),
  
  /// 观察 - 桌宠正在观察周围
  watching('watching', '观察', '👀'),
  
  /// 听音乐 - 桌宠正在享受音乐
  listening('listening', '听音乐', '🎵'),
  
  /// 冥想 - 桌宠正在冥想放松
  meditating('meditating', '冥想', '🧘‍♀️');

  const PetActivity(this.id, this.displayName, this.emoji);

  /// 活动ID
  final String id;
  
  /// 显示名称
  final String displayName;
  
  /// 活动表情符号
  final String emoji;

  /// 从ID获取活动
  static PetActivity fromId(String id) {
    return PetActivity.values.firstWhere(
      (activity) => activity.id == id,
      orElse: () => PetActivity.idle,
    );
  }

  /// 获取基础活动（生存必需）
  static List<PetActivity> get basicActivities => [
    PetActivity.idle,
    PetActivity.sleeping,
    PetActivity.eating,
  ];

  /// 获取娱乐活动
  static List<PetActivity> get entertainmentActivities => [
    PetActivity.playing,
    PetActivity.exploring,
    PetActivity.listening,
    PetActivity.watching,
  ];

  /// 获取学习活动
  static List<PetActivity> get learningActivities => [
    PetActivity.learning,
    PetActivity.thinking,
    PetActivity.working,
    PetActivity.creating,
  ];

  /// 获取社交活动
  static List<PetActivity> get socialActivities => [
    PetActivity.socializing,
  ];

  /// 获取健康活动
  static List<PetActivity> get healthActivities => [
    PetActivity.exercising,
    PetActivity.cleaning,
    PetActivity.meditating,
  ];

  /// 判断是否为基础活动
  bool get isBasic => basicActivities.contains(this);

  /// 判断是否为娱乐活动
  bool get isEntertainment => entertainmentActivities.contains(this);

  /// 判断是否为学习活动
  bool get isLearning => learningActivities.contains(this);

  /// 判断是否为社交活动
  bool get isSocial => socialActivities.contains(this);

  /// 判断是否为健康活动
  bool get isHealth => healthActivities.contains(this);

  /// 获取活动持续时间（分钟）
  int get durationMinutes {
    switch (this) {
      case PetActivity.idle:
        return 0; // 无限制
      case PetActivity.sleeping:
        return 480; // 8小时
      case PetActivity.eating:
        return 15;
      case PetActivity.playing:
        return 30;
      case PetActivity.learning:
        return 45;
      case PetActivity.exercising:
        return 20;
      case PetActivity.exploring:
        return 25;
      case PetActivity.socializing:
        return 20;
      case PetActivity.working:
        return 60;
      case PetActivity.creating:
        return 40;
      case PetActivity.thinking:
        return 10;
      case PetActivity.cleaning:
        return 15;
      case PetActivity.watching:
        return 30;
      case PetActivity.listening:
        return 25;
      case PetActivity.meditating:
        return 20;
    }
  }

  /// 获取活动消耗的能量
  int get energyCost {
    switch (this) {
      case PetActivity.idle:
        return 0;
      case PetActivity.sleeping:
        return -20; // 恢复能量
      case PetActivity.eating:
        return -10; // 恢复能量
      case PetActivity.playing:
        return 15;
      case PetActivity.learning:
        return 10;
      case PetActivity.exercising:
        return 25;
      case PetActivity.exploring:
        return 20;
      case PetActivity.socializing:
        return 5;
      case PetActivity.working:
        return 30;
      case PetActivity.creating:
        return 20;
      case PetActivity.thinking:
        return 5;
      case PetActivity.cleaning:
        return 15;
      case PetActivity.watching:
        return 5;
      case PetActivity.listening:
        return 3;
      case PetActivity.meditating:
        return -5; // 恢复能量
    }
  }

  @override
  String toString() => displayName;
}
