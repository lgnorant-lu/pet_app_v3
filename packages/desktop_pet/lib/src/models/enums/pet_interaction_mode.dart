/*
---------------------------------------------------------------
File name:          pet_interaction_mode.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠交互模式枚举 - 定义桌宠的交互模式
---------------------------------------------------------------
*/

/// 桌宠交互模式枚举
/// 
/// 定义桌宠与用户的交互模式
enum PetInteractionMode {
  /// 正常模式 - 标准交互
  normal('normal', '正常模式', '🐾'),
  
  /// 专注模式 - 减少打扰
  focus('focus', '专注模式', '🎯'),
  
  /// 游戏模式 - 增强互动
  gaming('gaming', '游戏模式', '🎮'),
  
  /// 学习模式 - 教育互动
  learning('learning', '学习模式', '📚'),
  
  /// 休息模式 - 最小化交互
  resting('resting', '休息模式', '😴'),
  
  /// 社交模式 - 增强社交互动
  social('social', '社交模式', '👥'),
  
  /// 工作模式 - 辅助工作
  working('working', '工作模式', '💼'),
  
  /// 静默模式 - 无声交互
  silent('silent', '静默模式', '🔇');

  const PetInteractionMode(this.id, this.displayName, this.emoji);

  /// 模式ID
  final String id;
  
  /// 显示名称
  final String displayName;
  
  /// 模式表情符号
  final String emoji;

  /// 从ID获取交互模式
  static PetInteractionMode fromId(String id) => PetInteractionMode.values.firstWhere(
      (PetInteractionMode mode) => mode.id == id,
      orElse: () => PetInteractionMode.normal,
    );

  /// 获取交互频率（每小时次数）
  int get interactionFrequency {
    switch (this) {
      case PetInteractionMode.normal:
        return 6;
      case PetInteractionMode.focus:
        return 2;
      case PetInteractionMode.gaming:
        return 12;
      case PetInteractionMode.learning:
        return 8;
      case PetInteractionMode.resting:
        return 1;
      case PetInteractionMode.social:
        return 10;
      case PetInteractionMode.working:
        return 4;
      case PetInteractionMode.silent:
        return 3;
    }
  }

  /// 获取通知级别 (0-3, 0最少，3最多)
  int get notificationLevel {
    switch (this) {
      case PetInteractionMode.normal:
        return 2;
      case PetInteractionMode.focus:
        return 0;
      case PetInteractionMode.gaming:
        return 3;
      case PetInteractionMode.learning:
        return 2;
      case PetInteractionMode.resting:
        return 0;
      case PetInteractionMode.social:
        return 3;
      case PetInteractionMode.working:
        return 1;
      case PetInteractionMode.silent:
        return 0;
    }
  }

  /// 判断是否允许声音
  bool get allowsSound => this != PetInteractionMode.silent && 
           this != PetInteractionMode.focus &&
           this != PetInteractionMode.resting;

  /// 判断是否允许动画
  bool get allowsAnimation => this != PetInteractionMode.focus || 
           this == PetInteractionMode.gaming;

  @override
  String toString() => displayName;
}
