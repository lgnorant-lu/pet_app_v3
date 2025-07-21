/*
---------------------------------------------------------------
File name:          trigger_type.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        行为触发器类型枚举 - 定义桌宠行为的触发条件类型
---------------------------------------------------------------
*/

/// 触发器类型枚举
/// 
/// 定义桌宠行为的各种触发条件类型
enum TriggerType {
  /// 时间触发 - 基于时间条件触发
  time('time', '时间触发'),
  
  /// 心情触发 - 基于桌宠心情状态触发
  mood('mood', '心情触发'),
  
  /// 活动触发 - 基于桌宠当前活动触发
  activity('activity', '活动触发'),
  
  /// 状态触发 - 基于桌宠生命状态触发
  status('status', '状态触发'),
  
  /// 属性值触发 - 基于桌宠数值属性触发
  stat('stat', '属性触发'),
  
  /// 交互触发 - 基于用户交互触发
  interaction('interaction', '交互触发'),
  
  /// 随机触发 - 随机概率触发
  random('random', '随机触发');

  const TriggerType(this.id, this.displayName);

  /// 触发器类型ID
  final String id;
  
  /// 显示名称
  final String displayName;

  /// 从ID获取触发器类型
  static TriggerType fromId(String id) => TriggerType.values.firstWhere(
      (TriggerType type) => type.id == id,
      orElse: () => TriggerType.random,
    );

  @override
  String toString() => displayName;
}
