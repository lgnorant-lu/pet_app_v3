/*
---------------------------------------------------------------
File name:          pet_ai_engine.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠AI引擎 - 智能行为决策和学习系统
---------------------------------------------------------------
*/

import 'dart:math';
import '../models/pet_entity.dart';
import '../models/pet_behavior.dart';
import '../enums/pet_mood.dart';

import '../enums/pet_status.dart';

/// 桌宠AI引擎
///
/// 负责桌宠的智能行为决策、学习和适应
class PetAIEngine {
  final Random _random = Random();
  final Map<String, AIMemory> _memories = {};
  final Map<String, double> _behaviorWeights = {};

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
    score += behavior.priority * 10;

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
    double score = 0.0;

    switch (pet.status) {
      case PetStatus.sick:
        if (behavior.hasTag('healing') || behavior.hasTag('rest')) {
          score += 30;
        }
        break;
      case PetStatus.tired:
        if (behavior.hasTag('rest') || behavior.hasTag('sleep')) {
          score += 25;
        }
        break;
      case PetStatus.active:
        if (behavior.hasTag('entertainment') || behavior.hasTag('social')) {
          score += 20;
        }
        break;
      default:
        break;
    }

    return score;
  }

  /// 根据桌宠需求评估
  double _evaluateByPetNeeds(PetEntity pet, PetBehavior behavior) {
    double score = 0.0;

    // 饥饿需求
    if (pet.hunger > 70 && behavior.hasTag('food')) {
      score += (pet.hunger - 50) * 0.5;
    }

    // 能量需求
    if (pet.energy < 30 && behavior.hasTag('rest')) {
      score += (50 - pet.energy) * 0.4;
    }

    // 清洁需求
    if (pet.cleanliness < 40 && behavior.hasTag('clean')) {
      score += (60 - pet.cleanliness) * 0.3;
    }

    // 社交需求
    final timeSinceLastInteraction = DateTime.now().difference(
      pet.lastInteraction,
    );
    if (timeSinceLastInteraction.inHours > 2 && behavior.hasTag('social')) {
      score += timeSinceLastInteraction.inHours * 2;
    }

    return score;
  }

  /// 根据心情评估
  double _evaluateByMood(PetEntity pet, PetBehavior behavior) {
    double score = 0.0;

    switch (pet.mood) {
      case PetMood.happy:
        if (behavior.hasTag('entertainment') || behavior.hasTag('social')) {
          score += 15;
        }
        break;
      case PetMood.excited:
        if (behavior.hasTag('play') || behavior.hasTag('exploration')) {
          score += 20;
        }
        break;
      case PetMood.bored:
        if (behavior.hasTag('entertainment') || behavior.hasTag('new')) {
          score += 25;
        }
        break;
      case PetMood.curious:
        if (behavior.hasTag('exploration') || behavior.hasTag('learning')) {
          score += 20;
        }
        break;
      case PetMood.sad:
        if (behavior.hasTag('comfort') || behavior.hasTag('social')) {
          score += 15;
        }
        break;
      default:
        break;
    }

    return score;
  }

  /// 根据历史经验评估
  double _evaluateByExperience(PetEntity pet, PetBehavior behavior) {
    final memory = _memories[pet.id];
    if (memory == null) return 0.0;

    double score = 0.0;

    // 检查行为成功率
    final successRate = memory.getBehaviorSuccessRate(behavior.id);
    score += successRate * 10;

    // 检查行为偏好
    final preference = memory.getBehaviorPreference(behavior.id);
    score += preference * 5;

    // 检查最近执行情况
    final recentExecution = memory.getRecentExecution(behavior.id);
    if (recentExecution != null) {
      final timeSince = DateTime.now().difference(recentExecution);
      if (timeSince.inMinutes < behavior.cooldown) {
        score -= 20; // 冷却期内降低分数
      }
    }

    return score;
  }

  /// 根据环境上下文评估
  double _evaluateByContext(
    PetEntity pet,
    PetBehavior behavior,
    Map<String, dynamic> context,
  ) {
    double score = 0.0;

    // 时间因素
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 6) {
      // 夜间时间
      if (behavior.hasTag('sleep') || behavior.hasTag('quiet')) {
        score += 15;
      } else if (behavior.hasTag('loud') || behavior.hasTag('active')) {
        score -= 10;
      }
    } else if (hour >= 9 && hour <= 17) {
      // 工作时间
      if (behavior.hasTag('quiet') || behavior.hasTag('background')) {
        score += 10;
      }
    }

    // 用户活动状态
    final userActive = context['userActive'] as bool? ?? true;
    if (!userActive) {
      if (behavior.hasTag('independent') || behavior.hasTag('auto')) {
        score += 10;
      } else if (behavior.hasTag('interactive')) {
        score -= 15;
      }
    }

    return score;
  }

  /// 带随机性的行为选择
  PetBehavior? _selectBehaviorWithRandomness(Map<PetBehavior, double> scores) {
    if (scores.isEmpty) return null;

    // 按分数排序
    final sortedBehaviors = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 使用加权随机选择
    final totalWeight = sortedBehaviors.fold(
      0.0,
      (sum, entry) => sum + entry.value,
    );
    if (totalWeight <= 0) return sortedBehaviors.first.key;

    final randomValue = _random.nextDouble() * totalWeight;
    double currentWeight = 0.0;

    for (final entry in sortedBehaviors) {
      currentWeight += entry.value;
      if (randomValue <= currentWeight) {
        return entry.key;
      }
    }

    return sortedBehaviors.first.key;
  }

  /// 学习行为结果
  void learnFromBehavior(
    String petId,
    PetBehavior behavior,
    bool success,
    double satisfaction,
  ) {
    final memory = _memories[petId] ?? AIMemory(petId);

    memory.recordBehaviorResult(behavior.id, success, satisfaction);
    _memories[petId] = memory;

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
      preferences: memory?.getTopPreferences(5) ?? [],
    );
  }

  /// 计算适应水平
  double _calculateAdaptationLevel(AIMemory? memory) {
    if (memory == null) return 0.0;

    final totalBehaviors = memory.behaviorHistory.length;
    if (totalBehaviors < 10) return totalBehaviors / 10.0;

    final recentSuccess = memory.getRecentSuccessRate(10);
    return recentSuccess;
  }

  /// 重置AI学习数据
  void resetLearning(String petId) {
    _memories.remove(petId);
  }

  /// 清理过期数据
  void cleanupOldData() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

    for (final memory in _memories.values) {
      memory.cleanupOldData(cutoffDate);
    }
  }
}

/// AI记忆系统
class AIMemory {
  final String petId;
  final List<BehaviorRecord> behaviorHistory = [];
  final Map<String, double> behaviorPreferences = {};
  final Map<String, int> behaviorSuccessCount = {};
  final Map<String, int> behaviorTotalCount = {};

  AIMemory(this.petId);

  /// 记录行为结果
  void recordBehaviorResult(
    String behaviorId,
    bool success,
    double satisfaction,
  ) {
    behaviorHistory.add(
      BehaviorRecord(
        behaviorId: behaviorId,
        timestamp: DateTime.now(),
        success: success,
        satisfaction: satisfaction,
      ),
    );

    // 更新统计
    behaviorTotalCount[behaviorId] = (behaviorTotalCount[behaviorId] ?? 0) + 1;
    if (success) {
      behaviorSuccessCount[behaviorId] =
          (behaviorSuccessCount[behaviorId] ?? 0) + 1;
    }

    // 更新偏好
    final currentPreference = behaviorPreferences[behaviorId] ?? 0.5;
    final adjustment = success ? satisfaction * 0.1 : -0.1;
    behaviorPreferences[behaviorId] = (currentPreference + adjustment).clamp(
      0.0,
      1.0,
    );
  }

  /// 获取行为成功率
  double getBehaviorSuccessRate(String behaviorId) {
    final total = behaviorTotalCount[behaviorId] ?? 0;
    if (total == 0) return 0.5; // 默认成功率

    final success = behaviorSuccessCount[behaviorId] ?? 0;
    return success / total;
  }

  /// 获取行为偏好
  double getBehaviorPreference(String behaviorId) {
    return behaviorPreferences[behaviorId] ?? 0.5;
  }

  /// 获取最近执行时间
  DateTime? getRecentExecution(String behaviorId) {
    final recentRecord = behaviorHistory
        .where((record) => record.behaviorId == behaviorId)
        .lastOrNull;

    return recentRecord?.timestamp;
  }

  /// 获取学习进度
  double get learningProgress {
    if (behaviorHistory.length < 50) {
      return behaviorHistory.length / 50.0;
    }
    return 1.0;
  }

  /// 获取最近成功率
  double getRecentSuccessRate(int count) {
    final recentRecords = behaviorHistory.takeLast(count);
    if (recentRecords.isEmpty) return 0.5;

    final successCount = recentRecords.where((r) => r.success).length;
    return successCount / recentRecords.length;
  }

  /// 获取热门偏好
  List<String> getTopPreferences(int limit) {
    final sorted = behaviorPreferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// 清理过期数据
  void cleanupOldData(DateTime cutoffDate) {
    behaviorHistory.removeWhere(
      (record) => record.timestamp.isBefore(cutoffDate),
    );
  }
}

/// 行为记录
class BehaviorRecord {
  final String behaviorId;
  final DateTime timestamp;
  final bool success;
  final double satisfaction;

  const BehaviorRecord({
    required this.behaviorId,
    required this.timestamp,
    required this.success,
    required this.satisfaction,
  });
}

/// AI状态
class AIStatus {
  final double learningProgress;
  final int behaviorCount;
  final double adaptationLevel;
  final List<String> preferences;

  const AIStatus({
    required this.learningProgress,
    required this.behaviorCount,
    required this.adaptationLevel,
    required this.preferences,
  });
}

extension on List<BehaviorRecord> {
  List<BehaviorRecord> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}

extension on Iterable<BehaviorRecord> {
  BehaviorRecord? get lastOrNull {
    return isEmpty ? null : last;
  }
}
