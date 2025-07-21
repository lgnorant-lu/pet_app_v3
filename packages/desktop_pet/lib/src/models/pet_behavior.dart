/*
---------------------------------------------------------------
File name:          pet_behavior.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠行为模型 - 定义桌宠的行为规则和行为状态
---------------------------------------------------------------
*/

import 'package:desktop_pet/src/models/enums/index.dart';

/// 桌宠行为模型
///
/// 定义桌宠的行为规则和行为状态
class PetBehavior {

  const PetBehavior({
    required this.id,
    required this.name,
    required this.description,
    required this.triggers,
    required this.actions,
    required this.priority,
    required this.duration,
    required this.cooldown,
    required this.canBeInterrupted,
    required this.isAutomatic,
    required this.tags,
    required this.createdAt,
  });

  /// 创建默认行为
  factory PetBehavior.createDefault({
    required String id,
    required String name,
    String description = '',
    int priority = 5,
    int duration = 30,
    int cooldown = 60,
    bool canBeInterrupted = true,
    bool isAutomatic = true,
    List<String> tags = const <String>[],
  }) => PetBehavior(
      id: id,
      name: name,
      description: description,
      triggers: <BehaviorTrigger>[],
      actions: <BehaviorAction>[],
      priority: priority,
      duration: duration,
      cooldown: cooldown,
      canBeInterrupted: canBeInterrupted,
      isAutomatic: isAutomatic,
      tags: tags,
      createdAt: DateTime.now(),
    );

  /// 从JSON创建
  factory PetBehavior.fromJson(Map<String, dynamic> json) => PetBehavior(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      triggers: (json['triggers'] as List<dynamic>?)
              ?.map((triggerJson) =>
                  BehaviorTrigger.fromJson(triggerJson as Map<String, dynamic>),)
              .toList() ??
          <BehaviorTrigger>[],
      actions: (json['actions'] as List<dynamic>?)
              ?.map((actionJson) =>
                  BehaviorAction.fromJson(actionJson as Map<String, dynamic>),)
              .toList() ??
          <BehaviorAction>[],
      priority: json['priority'] as int,
      duration: json['duration'] as int,
      cooldown: json['cooldown'] as int,
      canBeInterrupted: json['canBeInterrupted'] as bool,
      isAutomatic: json['isAutomatic'] as bool,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? <dynamic>[]),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  /// 行为ID
  final String id;

  /// 行为名称
  final String name;

  /// 行为描述
  final String description;

  /// 触发条件
  final List<BehaviorTrigger> triggers;

  /// 行为动作
  final List<BehaviorAction> actions;

  /// 行为优先级 (1-10, 10最高)
  final int priority;

  /// 行为持续时间（秒）
  final int duration;

  /// 行为冷却时间（秒）
  final int cooldown;

  /// 是否可以被打断
  final bool canBeInterrupted;

  /// 是否为自动行为
  final bool isAutomatic;

  /// 行为标签
  final List<String> tags;

  /// 创建时间
  final DateTime createdAt;

  /// 复制并更新行为
  PetBehavior copyWith({
    String? id,
    String? name,
    String? description,
    List<BehaviorTrigger>? triggers,
    List<BehaviorAction>? actions,
    int? priority,
    int? duration,
    int? cooldown,
    bool? canBeInterrupted,
    bool? isAutomatic,
    List<String>? tags,
    DateTime? createdAt,
  }) => PetBehavior(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      triggers: triggers ?? this.triggers,
      actions: actions ?? this.actions,
      priority: priority ?? this.priority,
      duration: duration ?? this.duration,
      cooldown: cooldown ?? this.cooldown,
      canBeInterrupted: canBeInterrupted ?? this.canBeInterrupted,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );

  /// 检查行为是否可以触发
  bool canTrigger(Map<String, dynamic> context) {
    if (triggers.isEmpty) return true;

    return triggers.any((BehaviorTrigger trigger) => trigger.evaluate(context));
  }

  /// 判断是否包含标签
  bool hasTag(String tag) => tags.contains(tag);

  /// 判断是否为高优先级行为
  bool get isHighPriority => priority >= 8;

  /// 判断是否为低优先级行为
  bool get isLowPriority => priority <= 3;

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'triggers': triggers.map((BehaviorTrigger t) => t.toJson()).toList(),
      'actions': actions.map((BehaviorAction a) => a.toJson()).toList(),
      'priority': priority,
      'duration': duration,
      'cooldown': cooldown,
      'canBeInterrupted': canBeInterrupted,
      'isAutomatic': isAutomatic,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetBehavior && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PetBehavior(id: $id, name: $name, priority: $priority)';
}

/// 行为触发器
class BehaviorTrigger {

  const BehaviorTrigger({
    required this.type,
    required this.conditions,
    this.probability = 1.0,
  });

  /// 从JSON创建
  factory BehaviorTrigger.fromJson(Map<String, dynamic> json) => BehaviorTrigger(
      type: TriggerType.fromId(json['type'] as String),
      conditions: Map<String, dynamic>.from(
          json['conditions'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},),
      probability: (json['probability'] as num?)?.toDouble() ?? 1.0,
    );
  /// 触发器类型
  final TriggerType type;

  /// 触发条件
  final Map<String, dynamic> conditions;

  /// 触发概率 (0.0-1.0)
  final double probability;

  /// 评估触发条件
  bool evaluate(Map<String, dynamic> context) {
    // 检查概率
    if (probability < 1.0) {
      final random = DateTime.now().millisecond / 1000.0;
      if (random > probability) return false;
    }

    switch (type) {
      case TriggerType.time:
        return _evaluateTimeCondition(context);
      case TriggerType.mood:
        return _evaluateMoodCondition(context);
      case TriggerType.activity:
        return _evaluateActivityCondition(context);
      case TriggerType.status:
        return _evaluateStatusCondition(context);
      case TriggerType.stat:
        return _evaluateStatCondition(context);
      case TriggerType.interaction:
        return _evaluateInteractionCondition(context);
      case TriggerType.random:
        return true; // 随机触发已通过概率检查
    }
  }

  /// 评估时间条件
  bool _evaluateTimeCondition(Map<String, dynamic> context) {
    final now = DateTime.now();

    if (conditions.containsKey('hour')) {
      final targetHour = conditions['hour'] as int;
      if (now.hour != targetHour) return false;
    }

    if (conditions.containsKey('timeRange')) {
      final range = conditions['timeRange'] as Map<String, int>;
      final startHour = range['start'] ?? 0;
      final endHour = range['end'] ?? 23;
      if (now.hour < startHour || now.hour > endHour) return false;
    }

    return true;
  }

  /// 评估心情条件
  bool _evaluateMoodCondition(Map<String, dynamic> context) {
    final currentMood = context['mood'] as PetMood?;
    if (currentMood == null) return false;

    if (conditions.containsKey('mood')) {
      final targetMood = PetMood.fromId(conditions['mood'] as String);
      return currentMood == targetMood;
    }

    if (conditions.containsKey('moodType')) {
      final moodType = conditions['moodType'] as String;
      switch (moodType) {
        case 'positive':
          return currentMood.isPositive;
        case 'negative':
          return currentMood.isNegative;
        case 'neutral':
          return currentMood.isNeutral;
      }
    }

    return true;
  }

  /// 评估活动条件
  bool _evaluateActivityCondition(Map<String, dynamic> context) {
    final currentActivity = context['activity'] as PetActivity?;
    if (currentActivity == null) return false;

    if (conditions.containsKey('activity')) {
      final targetActivity = PetActivity.fromId(
        conditions['activity'] as String,
      );
      return currentActivity == targetActivity;
    }

    return true;
  }

  /// 评估状态条件
  bool _evaluateStatusCondition(Map<String, dynamic> context) {
    final currentStatus = context['status'] as PetStatus?;
    if (currentStatus == null) return false;

    if (conditions.containsKey('status')) {
      final targetStatus = PetStatus.fromId(conditions['status'] as String);
      return currentStatus == targetStatus;
    }

    return true;
  }

  /// 评估属性条件
  bool _evaluateStatCondition(Map<String, dynamic> context) {
    for (final entry in conditions.entries) {
      final statName = entry.key;
      final condition = entry.value as Map<String, dynamic>;
      final currentValue = context[statName] as int?;

      if (currentValue == null) continue;

      if (condition.containsKey('min') &&
          currentValue < (condition['min'] as int)) {
        return false;
      }

      if (condition.containsKey('max') &&
          currentValue > (condition['max'] as int)) {
        return false;
      }

      if (condition.containsKey('equals') &&
          currentValue != (condition['equals'] as int)) {
        return false;
      }
    }

    return true;
  }

  /// 评估交互条件
  bool _evaluateInteractionCondition(Map<String, dynamic> context) {
    final lastInteraction = context['lastInteraction'] as DateTime?;
    if (lastInteraction == null) return false;

    if (conditions.containsKey('minMinutesSince')) {
      final minMinutes = conditions['minMinutesSince'] as int;
      final minutesSince = DateTime.now().difference(lastInteraction).inMinutes;
      return minutesSince >= minMinutes;
    }

    return true;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
      'type': type.id,
      'conditions': conditions,
      'probability': probability,
    };
}

/// 行为动作
class BehaviorAction {

  const BehaviorAction({
    required this.type,
    required this.parameters,
    this.delay = 0,
  });

  /// 从JSON创建
  factory BehaviorAction.fromJson(Map<String, dynamic> json) => BehaviorAction(
        type: ActionType.fromId(json['type'] as String),
        parameters: Map<String, dynamic>.from(
            json['parameters'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},),
        delay: json['delay'] as int? ?? 0,
      );
  /// 动作类型
  final ActionType type;

  /// 动作参数
  final Map<String, dynamic> parameters;

  /// 动作延迟（毫秒）
  final int delay;

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.id,
        'parameters': parameters,
        'delay': delay,
      };
}
