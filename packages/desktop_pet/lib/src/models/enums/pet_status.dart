/*
---------------------------------------------------------------
File name:          pet_status.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠状态枚举 - 定义桌宠的生命周期状态和健康状态
---------------------------------------------------------------
*/

/// 桌宠状态枚举
///
/// 定义桌宠的生命周期状态和健康状态
enum PetStatus {
  /// 未出生 - 桌宠还未被创建
  unborn('unborn', '未出生', '🥚'),

  /// 孵化中 - 桌宠正在孵化过程中
  hatching('hatching', '孵化中', '🐣'),

  /// 幼体 - 桌宠刚刚出生
  baby('baby', '幼体', '🐤'),

  /// 成长中 - 桌宠正在成长
  growing('growing', '成长中', '🐥'),

  /// 成年 - 桌宠已经成熟
  adult('adult', '成年', '🐦'),

  /// 活跃 - 桌宠状态良好且活跃
  active('active', '活跃', '✨'),

  /// 健康 - 桌宠身体健康
  healthy('healthy', '健康', '💚'),

  /// 疲倦 - 桌宠需要休息
  tired('tired', '疲倦', '😴'),

  /// 虚弱 - 桌宠体力不足
  weak('weak', '虚弱', '😵'),

  /// 生病 - 桌宠身体不适
  sick('sick', '生病', '🤒'),

  /// 受伤 - 桌宠受到伤害
  injured('injured', '受伤', '🩹'),

  /// 恢复中 - 桌宠正在康复
  recovering('recovering', '恢复中', '🔄'),

  /// 离线 - 桌宠暂时不活跃
  offline('offline', '离线', '💤'),

  /// 维护中 - 桌宠系统正在维护
  maintenance('maintenance', '维护中', '🔧'),

  /// 已删除 - 桌宠已被删除
  deleted('deleted', '已删除', '❌');

  const PetStatus(this.id, this.displayName, this.emoji);

  /// 状态ID
  final String id;

  /// 显示名称
  final String displayName;

  /// 状态表情符号
  final String emoji;

  /// 从ID获取状态
  static PetStatus fromId(String id) => PetStatus.values.firstWhere(
      (PetStatus status) => status.id == id,
      orElse: () => PetStatus.unborn,
    );

  /// 获取生命周期状态
  static List<PetStatus> get lifecycleStatuses => <PetStatus>[
        PetStatus.unborn,
        PetStatus.hatching,
        PetStatus.baby,
        PetStatus.growing,
        PetStatus.adult,
      ];

  /// 获取健康状态
  static List<PetStatus> get healthStatuses => <PetStatus>[
        PetStatus.healthy,
        PetStatus.active,
        PetStatus.tired,
        PetStatus.weak,
        PetStatus.sick,
        PetStatus.injured,
        PetStatus.recovering,
      ];

  /// 获取系统状态
  static List<PetStatus> get systemStatuses => <PetStatus>[
        PetStatus.offline,
        PetStatus.maintenance,
        PetStatus.deleted,
      ];

  /// 判断是否为生命周期状态
  bool get isLifecycle => lifecycleStatuses.contains(this);

  /// 判断是否为健康状态
  bool get isHealth => healthStatuses.contains(this);

  /// 判断是否为系统状态
  bool get isSystem => systemStatuses.contains(this);

  /// 判断是否为活跃状态
  bool get isActive => !<PetStatus>[
      PetStatus.unborn,
      PetStatus.offline,
      PetStatus.maintenance,
      PetStatus.deleted,
    ].contains(this);

  /// 判断是否为健康状态
  bool get isHealthy => <PetStatus>[
      PetStatus.healthy,
      PetStatus.active,
      PetStatus.baby,
      PetStatus.growing,
      PetStatus.adult,
    ].contains(this);

  /// 判断是否需要关注
  bool get needsAttention => <PetStatus>[
      PetStatus.tired,
      PetStatus.weak,
      PetStatus.sick,
      PetStatus.injured,
    ].contains(this);

  /// 判断是否可以互动
  bool get canInteract => !<PetStatus>[
      PetStatus.unborn,
      PetStatus.hatching,
      PetStatus.offline,
      PetStatus.maintenance,
      PetStatus.deleted,
    ].contains(this);

  /// 获取状态优先级（数值越高优先级越高）
  int get priority {
    switch (this) {
      case PetStatus.deleted:
        return 0;
      case PetStatus.maintenance:
        return 1;
      case PetStatus.offline:
        return 2;
      case PetStatus.unborn:
        return 3;
      case PetStatus.hatching:
        return 4;
      case PetStatus.injured:
        return 5;
      case PetStatus.sick:
        return 6;
      case PetStatus.weak:
        return 7;
      case PetStatus.tired:
        return 8;
      case PetStatus.recovering:
        return 9;
      case PetStatus.baby:
        return 10;
      case PetStatus.growing:
        return 11;
      case PetStatus.healthy:
        return 12;
      case PetStatus.adult:
        return 13;
      case PetStatus.active:
        return 14;
    }
  }

  /// 获取状态颜色
  String get colorHex {
    switch (this) {
      case PetStatus.active:
      case PetStatus.healthy:
        return '#4CAF50'; // 绿色
      case PetStatus.baby:
      case PetStatus.growing:
      case PetStatus.adult:
        return '#2196F3'; // 蓝色
      case PetStatus.tired:
      case PetStatus.recovering:
        return '#FF9800'; // 橙色
      case PetStatus.weak:
      case PetStatus.sick:
      case PetStatus.injured:
        return '#F44336'; // 红色
      case PetStatus.unborn:
      case PetStatus.hatching:
        return '#9C27B0'; // 紫色
      case PetStatus.offline:
      case PetStatus.maintenance:
      case PetStatus.deleted:
        return '#9E9E9E'; // 灰色
    }
  }

  @override
  String toString() => displayName;
}
