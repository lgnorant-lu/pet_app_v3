/*
---------------------------------------------------------------
File name:          pet_behavior.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠行为模型
---------------------------------------------------------------
*/

import '../enums/pet_mood.dart';
import '../enums/pet_activity.dart';
import '../enums/pet_status.dart';

/// 桌宠行为模型
///
/// 定义桌宠的行为规则和行为状态
class PetBehavior {
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
    List<String> tags = const [],
  }) {
    return PetBehavior(
      id: id,
      name: name,
      description: description,
      triggers: [],
      actions: [],
      priority: priority,
      duration: duration,
      cooldown: cooldown,
      canBeInterrupted: canBeInterrupted,
      isAutomatic: isAutomatic,
      tags: tags,
      createdAt: DateTime.now(),
    );
  }

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
  }) {
    return PetBehavior(
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
  }

  /// 检查行为是否可以触发
  bool canTrigger(Map<String, dynamic> context) {
    if (triggers.isEmpty) return true;

    return triggers.any((trigger) => trigger.evaluate(context));
  }

  /// 判断是否包含标签
  bool hasTag(String tag) {
    return tags.contains(tag);
  }

  /// 判断是否为高优先级行为
  bool get isHighPriority => priority >= 8;

  /// 判断是否为低优先级行为
  bool get isLowPriority => priority <= 3;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetBehavior && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'triggers': triggers.map((trigger) => trigger.toJson()).toList(),
      'actions': actions.map((action) => action.toJson()).toList(),
      'priority': priority,
      'duration': duration,
      'cooldown': cooldown,
      'canBeInterrupted': canBeInterrupted,
      'isAutomatic': isAutomatic,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory PetBehavior.fromJson(Map<String, dynamic> json) {
    return PetBehavior(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      triggers:
          (json['triggers'] as List<dynamic>?)
              ?.map((triggerJson) => BehaviorTrigger.fromJson(triggerJson))
              .toList() ??
          [],
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((actionJson) => BehaviorAction.fromJson(actionJson))
              .toList() ??
          [],
      priority: json['priority'] as int,
      duration: json['duration'] as int,
      cooldown: json['cooldown'] as int,
      canBeInterrupted: json['canBeInterrupted'] as bool,
      isAutomatic: json['isAutomatic'] as bool,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() => 'PetBehavior(id: $id, name: $name, priority: $priority)';
}

/// 行为统计数据
class BehaviorStatistics {
  final Map<String, int> executionCounts;
  final Map<String, int> totalDurations; // 以秒为单位
  final Map<String, int> successCounts;
  final Map<String, int> failureCounts;
  final DateTime lastUpdate;

  const BehaviorStatistics({
    required this.executionCounts,
    required this.totalDurations,
    required this.successCounts,
    required this.failureCounts,
    required this.lastUpdate,
  });

  /// 创建初始统计数据
  factory BehaviorStatistics.initial() {
    return BehaviorStatistics(
      executionCounts: const {},
      totalDurations: const {},
      successCounts: const {},
      failureCounts: const {},
      lastUpdate: DateTime.now(),
    );
  }

  /// 记录行为执行
  BehaviorStatistics recordExecution(
    String behaviorId,
    Duration duration,
    bool success,
  ) {
    final newExecutionCounts = Map<String, int>.from(executionCounts);
    final newTotalDurations = Map<String, int>.from(totalDurations);
    final newSuccessCounts = Map<String, int>.from(successCounts);
    final newFailureCounts = Map<String, int>.from(failureCounts);

    // 更新执行次数
    newExecutionCounts[behaviorId] = (newExecutionCounts[behaviorId] ?? 0) + 1;

    // 更新总时长
    newTotalDurations[behaviorId] =
        (newTotalDurations[behaviorId] ?? 0) + duration.inSeconds;

    // 更新成功/失败次数
    if (success) {
      newSuccessCounts[behaviorId] = (newSuccessCounts[behaviorId] ?? 0) + 1;
    } else {
      newFailureCounts[behaviorId] = (newFailureCounts[behaviorId] ?? 0) + 1;
    }

    return BehaviorStatistics(
      executionCounts: newExecutionCounts,
      totalDurations: newTotalDurations,
      successCounts: newSuccessCounts,
      failureCounts: newFailureCounts,
      lastUpdate: DateTime.now(),
    );
  }

  /// 获取成功率
  double getSuccessRate(String behaviorId) {
    final executions = executionCounts[behaviorId] ?? 0;
    if (executions == 0) return 0.0;

    final successes = successCounts[behaviorId] ?? 0;
    return successes / executions;
  }

  /// 获取平均执行时间
  Duration getAverageDuration(String behaviorId) {
    final executions = executionCounts[behaviorId] ?? 0;
    if (executions == 0) return Duration.zero;

    final totalSeconds = totalDurations[behaviorId] ?? 0;
    return Duration(seconds: totalSeconds ~/ executions);
  }

  /// 获取总执行次数
  int get totalExecutions {
    return executionCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// 获取总执行时间
  Duration get totalDuration {
    final totalSeconds = totalDurations.values.fold(
      0,
      (sum, duration) => sum + duration,
    );
    return Duration(seconds: totalSeconds);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'executionCounts': executionCounts,
      'totalDurations': totalDurations,
      'successCounts': successCounts,
      'failureCounts': failureCounts,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory BehaviorStatistics.fromJson(Map<String, dynamic> json) {
    return BehaviorStatistics(
      executionCounts: Map<String, int>.from(json['executionCounts'] ?? {}),
      totalDurations: Map<String, int>.from(json['totalDurations'] ?? {}),
      successCounts: Map<String, int>.from(json['successCounts'] ?? {}),
      failureCounts: Map<String, int>.from(json['failureCounts'] ?? {}),
      lastUpdate: DateTime.parse(
        json['lastUpdate'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  String toString() => 'BehaviorStatistics(totalExecutions: $totalExecutions)';
}

/// 行为触发器
class BehaviorTrigger {
  /// 触发器类型
  final TriggerType type;

  /// 触发条件
  final Map<String, dynamic> conditions;

  /// 触发概率 (0.0-1.0)
  final double probability;

  const BehaviorTrigger({
    required this.type,
    required this.conditions,
    this.probability = 1.0,
  });

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

  bool _evaluateTimeCondition(Map<String, dynamic> context) {
    final now = DateTime.now();
    final hour = conditions['hour'] as int?;
    final minute = conditions['minute'] as int?;

    if (hour != null && now.hour != hour) return false;
    if (minute != null && now.minute != minute) return false;

    return true;
  }

  bool _evaluateMoodCondition(Map<String, dynamic> context) {
    final currentMood = context['mood'] as PetMood?;
    final requiredMood = conditions['mood'] as String?;

    if (currentMood == null || requiredMood == null) return false;

    return currentMood.id == requiredMood;
  }

  bool _evaluateActivityCondition(Map<String, dynamic> context) {
    final currentActivity = context['activity'] as PetActivity?;
    final requiredActivity = conditions['activity'] as String?;

    if (currentActivity == null || requiredActivity == null) return false;

    return currentActivity.id == requiredActivity;
  }

  bool _evaluateStatusCondition(Map<String, dynamic> context) {
    final currentStatus = context['status'] as PetStatus?;
    final requiredStatus = conditions['status'] as String?;

    if (currentStatus == null || requiredStatus == null) return false;

    return currentStatus.id == requiredStatus;
  }

  bool _evaluateStatCondition(Map<String, dynamic> context) {
    final statName = conditions['stat'] as String?;
    final operator = conditions['operator'] as String?;
    final value = conditions['value'] as int?;

    if (statName == null || operator == null || value == null) return false;

    final currentValue = context[statName] as int?;
    if (currentValue == null) return false;

    switch (operator) {
      case '>':
        return currentValue > value;
      case '<':
        return currentValue < value;
      case '>=':
        return currentValue >= value;
      case '<=':
        return currentValue <= value;
      case '==':
        return currentValue == value;
      default:
        return false;
    }
  }

  bool _evaluateInteractionCondition(Map<String, dynamic> context) {
    final lastInteraction = context['lastInteraction'] as DateTime?;
    final minInterval = conditions['minInterval'] as int?; // 分钟

    if (lastInteraction == null || minInterval == null) return false;

    final now = DateTime.now();
    final diff = now.difference(lastInteraction).inMinutes;

    return diff >= minInterval;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'conditions': conditions,
      'probability': probability,
    };
  }

  /// 从JSON创建
  factory BehaviorTrigger.fromJson(Map<String, dynamic> json) {
    return BehaviorTrigger(
      type: TriggerType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TriggerType.random,
      ),
      conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
      probability: (json['probability'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// 行为动作
class BehaviorAction {
  /// 动作类型
  final ActionType type;

  /// 动作参数
  final Map<String, dynamic> parameters;

  /// 动作延迟（毫秒）
  final int delay;

  const BehaviorAction({
    required this.type,
    required this.parameters,
    this.delay = 0,
  });

  /// 执行动作
  Future<void> execute(Map<String, dynamic> context) async {
    if (delay > 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }

    switch (type) {
      case ActionType.changeMood:
        _changeMood(context);
        break;
      case ActionType.changeActivity:
        _changeActivity(context);
        break;
      case ActionType.modifyStat:
        _modifyStat(context);
        break;
      case ActionType.playAnimation:
        _playAnimation(context);
        break;
      case ActionType.showMessage:
        _showMessage(context);
        break;
      case ActionType.move:
        _move(context);
        break;
    }
  }

  void _changeMood(Map<String, dynamic> context) {
    final newMood = parameters['mood'] as String?;
    if (newMood != null) {
      context['mood'] = PetMood.fromId(newMood);
    }
  }

  void _changeActivity(Map<String, dynamic> context) {
    final newActivity = parameters['activity'] as String?;
    if (newActivity != null) {
      context['activity'] = PetActivity.fromId(newActivity);
    }
  }

  void _modifyStat(Map<String, dynamic> context) {
    final statName = parameters['stat'] as String?;
    final change = parameters['change'] as int?;

    if (statName != null && change != null) {
      final currentValue = context[statName] as int? ?? 0;
      context[statName] = (currentValue + change).clamp(0, 100);
    }
  }

  void _playAnimation(Map<String, dynamic> context) {
    final animationName = parameters['animation'] as String?;
    if (animationName != null) {
      context['currentAnimation'] = animationName;
    }
  }

  void _showMessage(Map<String, dynamic> context) {
    final message = parameters['message'] as String?;
    if (message != null) {
      context['message'] = message;
    }
  }

  void _move(Map<String, dynamic> context) {
    final x = parameters['x'] as double?;
    final y = parameters['y'] as double?;

    if (x != null) context['positionX'] = x;
    if (y != null) context['positionY'] = y;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {'type': type.name, 'parameters': parameters, 'delay': delay};
  }

  /// 从JSON创建
  factory BehaviorAction.fromJson(Map<String, dynamic> json) {
    return BehaviorAction(
      type: ActionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActionType.showMessage,
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      delay: json['delay'] as int? ?? 0,
    );
  }
}

/// 触发器类型枚举
enum TriggerType {
  time, // 时间触发
  mood, // 心情触发
  activity, // 活动触发
  status, // 状态触发
  stat, // 属性值触发
  interaction, // 交互触发
  random, // 随机触发
}

/// 动作类型枚举
enum ActionType {
  changeMood, // 改变心情
  changeActivity, // 改变活动
  modifyStat, // 修改属性
  playAnimation, // 播放动画
  showMessage, // 显示消息
  move, // 移动位置
}
