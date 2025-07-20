/*
---------------------------------------------------------------
File name:          pet_data_service.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠数据服务 - 高级数据分析和统计
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';
import '../pet/models/pet_entity.dart';

import '../pet/enums/pet_mood.dart';
import '../pet/enums/pet_activity.dart';

/// 桌宠数据服务提供者
final petDataServiceProvider = Provider<PetDataService>((ref) {
  return PetDataService();
});

/// 桌宠数据服务
///
/// 负责桌宠的高级数据分析、统计和洞察
class PetDataService {
  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 分析桌宠健康趋势
  Future<HealthTrend> analyzeHealthTrend(
    String petId,
    List<PetEntity> history,
  ) async {
    if (history.isEmpty) {
      return HealthTrend.empty();
    }

    // 按时间排序
    final sortedHistory = List<PetEntity>.from(history)
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    // 计算健康指标趋势
    final healthValues = sortedHistory.map((pet) => pet.health).toList();
    final energyValues = sortedHistory.map((pet) => pet.energy).toList();
    final happinessValues = sortedHistory.map((pet) => pet.happiness).toList();

    return HealthTrend(
      healthTrend: _calculateTrend(healthValues),
      energyTrend: _calculateTrend(energyValues),
      happinessTrend: _calculateTrend(happinessValues),
      overallTrend: _calculateOverallTrend(sortedHistory),
      riskFactors: _identifyRiskFactors(sortedHistory.last),
      recommendations: _generateRecommendations(sortedHistory.last),
    );
  }

  /// 分析桌宠行为模式
  Future<BehaviorPattern> analyzeBehaviorPattern(
    String petId,
    List<PetEntity> history,
  ) async {
    if (history.isEmpty) {
      return BehaviorPattern.empty();
    }

    // 分析活动模式
    final activityCounts = <PetActivity, int>{};
    final moodCounts = <PetMood, int>{};
    final hourlyActivity = <int, List<PetActivity>>{};

    for (final pet in history) {
      // 统计活动
      activityCounts[pet.currentActivity] =
          (activityCounts[pet.currentActivity] ?? 0) + 1;

      // 统计心情
      moodCounts[pet.mood] = (moodCounts[pet.mood] ?? 0) + 1;

      // 统计时间段活动
      final hour = pet.updatedAt.hour;
      hourlyActivity[hour] = hourlyActivity[hour] ?? [];
      hourlyActivity[hour]!.add(pet.currentActivity);
    }

    return BehaviorPattern(
      favoriteActivities: _getTopActivities(activityCounts, 3),
      commonMoods: _getTopMoods(moodCounts, 3),
      activeHours: _getActiveHours(hourlyActivity),
      activityDiversity: _calculateActivityDiversity(activityCounts),
      moodStability: _calculateMoodStability(moodCounts),
    );
  }

  /// 生成桌宠洞察报告
  Future<PetInsights> generateInsights(
    String petId,
    PetEntity currentPet,
    List<PetEntity> history,
  ) async {
    final healthTrend = await analyzeHealthTrend(petId, history);
    final behaviorPattern = await analyzeBehaviorPattern(petId, history);

    return PetInsights(
      petId: petId,
      generatedAt: DateTime.now(),
      healthTrend: healthTrend,
      behaviorPattern: behaviorPattern,
      personalityTraits: _analyzePersonality(currentPet, history),
      careQuality: _assessCareQuality(currentPet, history),
      predictions: _generatePredictions(currentPet, history),
    );
  }

  /// 计算趋势
  TrendDirection _calculateTrend(List<int> values) {
    if (values.length < 2) return TrendDirection.stable;

    final recent = values.sublist(max(0, values.length - 5));
    final older = values.sublist(0, min(values.length, 5));

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final diff = recentAvg - olderAvg;

    if (diff > 5) return TrendDirection.improving;
    if (diff < -5) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// 计算总体趋势
  TrendDirection _calculateOverallTrend(List<PetEntity> history) {
    if (history.length < 2) return TrendDirection.stable;

    final recent = history.sublist(max(0, history.length - 3));
    final older = history.sublist(0, min(history.length, 3));

    final recentScore =
        recent.map((p) => p.overallScore).reduce((a, b) => a + b) /
        recent.length;
    final olderScore =
        older.map((p) => p.overallScore).reduce((a, b) => a + b) / older.length;

    final diff = recentScore - olderScore;

    if (diff > 10) return TrendDirection.improving;
    if (diff < -10) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// 识别风险因素
  List<String> _identifyRiskFactors(PetEntity pet) {
    final risks = <String>[];

    if (pet.health < 30) risks.add('健康状况危险');
    if (pet.energy < 20) risks.add('能量严重不足');
    if (pet.hunger > 80) risks.add('饥饿程度过高');
    if (pet.happiness < 30) risks.add('情绪低落');
    if (pet.cleanliness < 30) risks.add('清洁度过低');

    final timeSinceLastInteraction = DateTime.now().difference(
      pet.lastInteraction,
    );
    if (timeSinceLastInteraction.inHours > 24) {
      risks.add('长时间缺乏互动');
    }

    return risks;
  }

  /// 生成建议
  List<String> _generateRecommendations(PetEntity pet) {
    final recommendations = <String>[];

    if (pet.health < 50) recommendations.add('建议增加休息时间');
    if (pet.energy < 40) recommendations.add('让桌宠多睡觉恢复体力');
    if (pet.hunger > 60) recommendations.add('及时喂食');
    if (pet.happiness < 50) recommendations.add('多与桌宠互动玩耍');
    if (pet.cleanliness < 50) recommendations.add('保持桌宠清洁');

    if (recommendations.isEmpty) {
      recommendations.add('桌宠状态良好，继续保持');
    }

    return recommendations;
  }

  /// 获取热门活动
  List<PetActivity> _getTopActivities(Map<PetActivity, int> counts, int limit) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// 获取常见心情
  List<PetMood> _getTopMoods(Map<PetMood, int> counts, int limit) {
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// 获取活跃时间段
  List<int> _getActiveHours(Map<int, List<PetActivity>> hourlyActivity) {
    final activityCounts = <int, int>{};

    for (final entry in hourlyActivity.entries) {
      activityCounts[entry.key] = entry.value.length;
    }

    final sorted = activityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// 计算活动多样性
  double _calculateActivityDiversity(Map<PetActivity, int> counts) {
    if (counts.isEmpty) return 0.0;

    final uniqueActivities = counts.keys.length;

    return uniqueActivities / PetActivity.values.length;
  }

  /// 计算心情稳定性
  double _calculateMoodStability(Map<PetMood, int> counts) {
    if (counts.isEmpty) return 0.0;

    final total = counts.values.reduce((a, b) => a + b);
    final variance =
        counts.values
            .map((count) {
              final proportion = count / total;
              final expected = 1.0 / counts.length;
              return pow(proportion - expected, 2);
            })
            .reduce((a, b) => a + b) /
        counts.length;

    return 1.0 - variance; // 方差越小，稳定性越高
  }

  /// 分析性格特征
  List<String> _analyzePersonality(
    PetEntity currentPet,
    List<PetEntity> history,
  ) {
    final traits = <String>[];

    // 基于当前状态分析
    if (currentPet.happiness > 70) traits.add('乐观开朗');
    if (currentPet.social > 70) traits.add('社交活跃');
    if (currentPet.intelligence > 70) traits.add('聪明好学');
    if (currentPet.creativity > 70) traits.add('富有创意');

    // 基于历史行为分析
    if (history.isNotEmpty) {
      final avgEnergy =
          history.map((p) => p.energy).reduce((a, b) => a + b) / history.length;
      if (avgEnergy > 70) traits.add('精力充沛');

      final avgHappiness =
          history.map((p) => p.happiness).reduce((a, b) => a + b) /
          history.length;
      if (avgHappiness > 70) traits.add('性格稳定');
    }

    return traits.isEmpty ? ['性格发展中'] : traits;
  }

  /// 评估照顾质量
  CareQuality _assessCareQuality(
    PetEntity currentPet,
    List<PetEntity> history,
  ) {
    var score = 0;
    final factors = <String>[];

    // 基础照顾
    if (currentPet.health > 70) {
      score += 20;
      factors.add('健康维护良好');
    }
    if (currentPet.hunger < 40) {
      score += 20;
      factors.add('喂食及时');
    }
    if (currentPet.cleanliness > 60) {
      score += 20;
      factors.add('清洁维护良好');
    }

    // 互动质量
    final timeSinceLastInteraction = DateTime.now().difference(
      currentPet.lastInteraction,
    );
    if (timeSinceLastInteraction.inHours < 12) {
      score += 20;
      factors.add('互动频繁');
    }

    // 情感关怀
    if (currentPet.happiness > 60) {
      score += 20;
      factors.add('情感关怀充足');
    }

    String level;
    if (score >= 80) {
      level = '优秀';
    } else if (score >= 60) {
      level = '良好';
    } else if (score >= 40) {
      level = '一般';
    } else {
      level = '需要改善';
    }

    return CareQuality(score: score, level: level, factors: factors);
  }

  /// 生成预测
  List<String> _generatePredictions(
    PetEntity currentPet,
    List<PetEntity> history,
  ) {
    final predictions = <String>[];

    // 基于当前趋势预测
    if (currentPet.energy < 30) {
      predictions.add('桌宠可能在1小时内需要休息');
    }
    if (currentPet.hunger > 70) {
      predictions.add('桌宠可能在30分钟内需要进食');
    }
    if (currentPet.happiness < 40) {
      predictions.add('桌宠可能需要更多关注和互动');
    }

    // 基于历史模式预测
    if (history.length >= 5) {
      final recentMoods = history.takeLast(5).map((p) => p.mood).toList();
      final negativeMoods = recentMoods.where((m) => m.isNegative).length;

      if (negativeMoods >= 3) {
        predictions.add('桌宠情绪可能持续低落，需要特别关注');
      }
    }

    return predictions.isEmpty ? ['桌宠状态稳定'] : predictions;
  }
}

/// 健康趋势
class HealthTrend {
  final TrendDirection healthTrend;
  final TrendDirection energyTrend;
  final TrendDirection happinessTrend;
  final TrendDirection overallTrend;
  final List<String> riskFactors;
  final List<String> recommendations;

  const HealthTrend({
    required this.healthTrend,
    required this.energyTrend,
    required this.happinessTrend,
    required this.overallTrend,
    required this.riskFactors,
    required this.recommendations,
  });

  factory HealthTrend.empty() {
    return const HealthTrend(
      healthTrend: TrendDirection.stable,
      energyTrend: TrendDirection.stable,
      happinessTrend: TrendDirection.stable,
      overallTrend: TrendDirection.stable,
      riskFactors: [],
      recommendations: [],
    );
  }
}

/// 行为模式
class BehaviorPattern {
  final List<PetActivity> favoriteActivities;
  final List<PetMood> commonMoods;
  final List<int> activeHours;
  final double activityDiversity;
  final double moodStability;

  const BehaviorPattern({
    required this.favoriteActivities,
    required this.commonMoods,
    required this.activeHours,
    required this.activityDiversity,
    required this.moodStability,
  });

  factory BehaviorPattern.empty() {
    return const BehaviorPattern(
      favoriteActivities: [],
      commonMoods: [],
      activeHours: [],
      activityDiversity: 0.0,
      moodStability: 0.0,
    );
  }
}

/// 桌宠洞察
class PetInsights {
  final String petId;
  final DateTime generatedAt;
  final HealthTrend healthTrend;
  final BehaviorPattern behaviorPattern;
  final List<String> personalityTraits;
  final CareQuality careQuality;
  final List<String> predictions;

  const PetInsights({
    required this.petId,
    required this.generatedAt,
    required this.healthTrend,
    required this.behaviorPattern,
    required this.personalityTraits,
    required this.careQuality,
    required this.predictions,
  });
}

/// 照顾质量
class CareQuality {
  final int score;
  final String level;
  final List<String> factors;

  const CareQuality({
    required this.score,
    required this.level,
    required this.factors,
  });
}

/// 趋势方向
enum TrendDirection { improving, stable, declining }

extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
