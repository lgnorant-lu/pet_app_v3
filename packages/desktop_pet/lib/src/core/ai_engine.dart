/*
---------------------------------------------------------------
File name:          ai_engine.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠AI引擎 - 负责桌宠的智能行为决策、学习和适应
---------------------------------------------------------------
*/

import 'dart:math';
import 'package:desktop_pet/src/models/index.dart';

/// 桌宠AI引擎
///
/// 负责桌宠的智能行为决策、学习和适应
class PetAIEngine {
  final Random _random = Random();
  final Map<String, AIMemory> _memories = <String, AIMemory>{};
  final Map<String, double> _behaviorWeights = <String, double>{};

  /// 初始化AI引擎
  void initialize() {
    _initializeBehaviorWeights();
  }

  /// 初始化行为权重
  void _initializeBehaviorWeights() {
    // 基础行为权重
    _behaviorWeights['survival'] = 1.0;
    _behaviorWeights['social'] = 0.8;
    _behaviorWeights['entertainment'] = 0.6;
    _behaviorWeights['learning'] = 0.7;
    _behaviorWeights['exploration'] = 0.5;
  }

  /// 智能决策下一个行为
  PetBehavior? decideNextBehavior(
    PetEntity pet,
    List<PetBehavior> availableBehaviors,
    Map<String, dynamic> context,
  ) {
    if (availableBehaviors.isEmpty) return null;

    // 评估所有可用行为
    final behaviorScores = <PetBehavior, double>{};

    for (final behavior in availableBehaviors) {
      final score = _evaluateBehavior(pet, behavior, context);
      behaviorScores[behavior] = score;
    }

    // 选择最高分的行为（带随机性）
    return _selectBehaviorWithRandomness(behaviorScores);
  }

  /// 评估行为适合度
  double _evaluateBehavior(
    PetEntity pet,
    PetBehavior behavior,
    Map<String, dynamic> context,
  ) {
    double score = 0.0;

    // 基础优先级分数
    score += behavior.priority * 10.0;

    // 根据桌宠状态调整分数
    score += _evaluateByPetStatus(pet, behavior);

    // 根据桌宠需求调整分数
    score += _evaluateByPetNeeds(pet, behavior);

    // 根据心情调整分数
    score += _evaluateByMood(pet, behavior);

    // 根据历史经验调整分数
    score += _evaluateByExperience(pet, behavior);

    // 根据环境上下文调整分数
    score += _evaluateByContext(pet, behavior, context);

    return score.clamp(0.0, 100.0);
  }

  /// 根据桌宠状态评估
  double _evaluateByPetStatus(PetEntity pet, PetBehavior behavior) {
    double score = 0;

    // 根据健康状态调整
    if (pet.health < 30 && behavior.hasTag('health')) {
      score += 20;
    }

    // 根据能量状态调整
    if (pet.energy < 20 && behavior.hasTag('rest')) {
      score += 25;
    }

    // 根据饥饿状态调整
    if (pet.hunger > 80 && behavior.hasTag('food')) {
      score += 30;
    }

    return score;
  }

  /// 根据桌宠需求评估
  double _evaluateByPetNeeds(PetEntity pet, PetBehavior behavior) {
    double score = 0;

    // 快乐需求
    if (pet.happiness < 50 && behavior.hasTag('entertainment')) {
      score += 15;
    }

    // 清洁需求
    if (pet.cleanliness < 40 && behavior.hasTag('hygiene')) {
      score += 10;
    }

    // 社交需求
    if (pet.social < 60 && behavior.hasTag('social')) {
      score += 12;
    }

    return score;
  }

  /// 根据心情评估
  double _evaluateByMood(PetEntity pet, PetBehavior behavior) {
    double score = 0;

    // 积极心情偏好娱乐活动
    if (pet.mood.isPositive && behavior.hasTag('entertainment')) {
      score += 10;
    }

    // 消极心情偏好恢复活动
    if (pet.mood.isNegative && behavior.hasTag('recovery')) {
      score += 15;
    }

    return score;
  }

  /// 根据历史经验评估
  double _evaluateByExperience(PetEntity pet, PetBehavior behavior) {
    final memory = _memories[pet.id];
    if (memory == null) return 0;

    final behaviorHistory = memory.getBehaviorHistory(behavior.id);
    if (behaviorHistory.isEmpty) return 0;

    // 计算平均满意度
    final avgSatisfaction = behaviorHistory
            .map((BehaviorRecord h) => h.satisfaction)
            .reduce((double a, double b) => a + b) /
        behaviorHistory.length;

    return avgSatisfaction * 10;
  }

  /// 根据环境上下文评估
  double _evaluateByContext(
    PetEntity pet,
    PetBehavior behavior,
    Map<String, dynamic> context,
  ) {
    double score = 0;

    // 时间相关调整
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 6) {
      if (behavior.hasTag('sleep')) score += 20;
      if (behavior.hasTag('quiet')) score += 10;
    } else if (hour >= 9 && hour <= 18) {
      if (behavior.hasTag('active')) score += 10;
      if (behavior.hasTag('work')) score += 5;
    }

    return score;
  }

  /// 带随机性选择行为
  PetBehavior? _selectBehaviorWithRandomness(
    Map<PetBehavior, double> behaviorScores,
  ) {
    if (behaviorScores.isEmpty) return null;

    // 按分数排序
    final sortedBehaviors = behaviorScores.entries.toList()
      ..sort(
          (MapEntry<PetBehavior, double> a, MapEntry<PetBehavior, double> b) =>
              b.value.compareTo(a.value));

    // 前30%的行为有机会被选中
    final topCount = (sortedBehaviors.length * 0.3).ceil().clamp(1, 3);
    final topBehaviors = sortedBehaviors.take(topCount).toList();

    // 加权随机选择
    final totalWeight = topBehaviors.fold<double>(
      0,
      (double sum, MapEntry<PetBehavior, double> entry) => sum + entry.value,
    );

    if (totalWeight <= 0) return topBehaviors.first.key;

    final randomValue = _random.nextDouble() * totalWeight;
    double currentWeight = 0;

    for (final entry in topBehaviors) {
      currentWeight += entry.value;
      if (randomValue <= currentWeight) {
        return entry.key;
      }
    }

    return topBehaviors.first.key;
  }

  /// 学习行为结果
  void learnFromBehavior(
    String petId,
    PetBehavior behavior,
    bool success,
    double satisfaction,
  ) {
    final memory = _memories[petId] ?? AIMemory.create(petId);

    final updatedMemory =
        memory.recordBehaviorResult(behavior.id, success, satisfaction);
    _memories[petId] = updatedMemory;

    // 调整行为权重
    _adjustBehaviorWeights(behavior, success, satisfaction);
  }

  /// 调整行为权重
  void _adjustBehaviorWeights(
    PetBehavior behavior,
    bool success,
    double satisfaction,
  ) {
    for (final tag in behavior.tags) {
      final currentWeight = _behaviorWeights[tag] ?? 0.5;

      if (success && satisfaction > 0.7) {
        _behaviorWeights[tag] = (currentWeight + 0.1).clamp(0.0, 2.0);
      } else if (!success || satisfaction < 0.3) {
        _behaviorWeights[tag] = (currentWeight - 0.05).clamp(0.0, 2.0);
      }
    }
  }

  /// 获取桌宠AI状态
  AIStatus getAIStatus(String petId) {
    final memory = _memories[petId];

    return AIStatus(
      learningProgress: memory?.learningProgress ?? 0.0,
      behaviorCount: memory?.behaviorHistory.length ?? 0,
      adaptationLevel: _calculateAdaptationLevel(memory),
      preferences: memory?.getTopPreferences(5) ?? <String>[],
    );
  }

  /// 计算适应水平
  double _calculateAdaptationLevel(AIMemory? memory) {
    if (memory == null) return 0;

    final totalBehaviors = memory.behaviorHistory.length;
    if (totalBehaviors < 10) return totalBehaviors / 10.0;

    final recentSuccess = memory.getRecentSuccessRate(10);
    return recentSuccess;
  }

  /// 重置AI学习数据
  void resetLearning(String petId) {
    _memories.remove(petId);
  }
}
