/*
---------------------------------------------------------------
File name:          action_type.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        行为动作类型枚举 - 定义桌宠行为的动作类型
---------------------------------------------------------------
*/

/// 动作类型枚举
/// 
/// 定义桌宠行为可以执行的各种动作类型
enum ActionType {
  /// 改变心情 - 修改桌宠的心情状态
  changeMood('changeMood', '改变心情'),
  
  /// 改变活动 - 切换桌宠的当前活动
  changeActivity('changeActivity', '改变活动'),
  
  /// 修改属性 - 调整桌宠的数值属性
  modifyStat('modifyStat', '修改属性'),
  
  /// 播放动画 - 播放桌宠动画效果
  playAnimation('playAnimation', '播放动画'),
  
  /// 显示消息 - 显示桌宠消息或对话
  showMessage('showMessage', '显示消息'),
  
  /// 移动位置 - 改变桌宠的位置
  move('move', '移动位置');

  const ActionType(this.id, this.displayName);

  /// 动作类型ID
  final String id;
  
  /// 显示名称
  final String displayName;

  /// 从ID获取动作类型
  static ActionType fromId(String id) => ActionType.values.firstWhere(
      (ActionType type) => type.id == id,
      orElse: () => ActionType.showMessage,
    );

  @override
  String toString() => displayName;
}
