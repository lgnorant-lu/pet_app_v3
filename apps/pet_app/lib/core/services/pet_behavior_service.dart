/*
---------------------------------------------------------------
File name:          pet_behavior_service.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠行为服务 - 管理桌宠行为数据和逻辑
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../pet/models/pet_behavior.dart';

/// 桌宠行为服务提供者
final petBehaviorServiceProvider = Provider<PetBehaviorService>((ref) {
  return PetBehaviorService();
});

/// 桌宠行为服务
///
/// 负责桌宠行为的数据管理和业务逻辑
class PetBehaviorService {
  static const String _behaviorsKey = 'pet_behaviors_data';
  static const String _behaviorStatsKey = 'pet_behavior_stats_data';

  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取所有行为
  Future<List<PetBehavior>> getAllBehaviors() async {
    await initialize();

    final behaviorsJson = _prefs!.getString(_behaviorsKey);
    if (behaviorsJson == null) return [];

    try {
      final List<dynamic> behaviorsList = jsonDecode(behaviorsJson);
      return behaviorsList.map((json) => PetBehavior.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取单个行为
  Future<PetBehavior?> getBehavior(String behaviorId) async {
    final behaviors = await getAllBehaviors();
    try {
      return behaviors.firstWhere((behavior) => behavior.id == behaviorId);
    } catch (e) {
      return null;
    }
  }

  /// 保存行为
  Future<void> saveBehavior(PetBehavior behavior) async {
    await initialize();

    final behaviors = await getAllBehaviors();
    final index = behaviors.indexWhere((b) => b.id == behavior.id);

    if (index >= 0) {
      behaviors[index] = behavior;
    } else {
      behaviors.add(behavior);
    }

    await _saveAllBehaviors(behaviors);
  }

  /// 删除行为
  Future<void> deleteBehavior(String behaviorId) async {
    await initialize();

    final behaviors = await getAllBehaviors();
    final updatedBehaviors = behaviors
        .where((b) => b.id != behaviorId)
        .toList();

    await _saveAllBehaviors(updatedBehaviors);
  }

  /// 获取行为统计
  Future<BehaviorStatistics> getBehaviorStatistics() async {
    await initialize();

    final statsJson = _prefs!.getString(_behaviorStatsKey);
    if (statsJson == null) {
      return BehaviorStatistics.initial();
    }

    try {
      final Map<String, dynamic> statsMap = jsonDecode(statsJson);
      return BehaviorStatistics.fromJson(statsMap);
    } catch (e) {
      return BehaviorStatistics.initial();
    }
  }

  /// 更新行为统计
  Future<void> updateBehaviorStatistics(BehaviorStatistics stats) async {
    await initialize();

    final statsJson = jsonEncode(stats.toJson());
    await _prefs!.setString(_behaviorStatsKey, statsJson);
  }

  /// 记录行为执行
  Future<void> recordBehaviorExecution(
    String behaviorId,
    Duration duration,
    bool success,
  ) async {
    final stats = await getBehaviorStatistics();
    final updatedStats = stats.recordExecution(behaviorId, duration, success);
    await updateBehaviorStatistics(updatedStats);
  }

  /// 获取行为执行频率
  Future<Map<String, int>> getBehaviorFrequency() async {
    final stats = await getBehaviorStatistics();
    return stats.executionCounts;
  }

  /// 获取最常执行的行为
  Future<List<String>> getMostExecutedBehaviors({int limit = 5}) async {
    final frequency = await getBehaviorFrequency();
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).map((e) => e.key).toList();
  }

  /// 保存所有行为
  Future<void> _saveAllBehaviors(List<PetBehavior> behaviors) async {
    await initialize();

    final behaviorsJson = jsonEncode(behaviors.map((b) => b.toJson()).toList());
    await _prefs!.setString(_behaviorsKey, behaviorsJson);
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    await initialize();

    await _prefs!.remove(_behaviorsKey);
    await _prefs!.remove(_behaviorStatsKey);
  }
}
