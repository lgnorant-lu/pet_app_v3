/*
---------------------------------------------------------------
File name:          pet_repository.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠数据仓库 - 负责桌宠数据的持久化和检索
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_pet/src/models/index.dart';

/// 桌宠数据仓库
///
/// 负责桌宠数据的持久化和检索
class PetRepository {
  static const String _petsKey = 'desktop_pets';
  static const String _interactionsKey = 'pet_interactions';
  static const String _statsKey = 'pet_stats';

  SharedPreferences? _prefs;

  /// 初始化仓库
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取所有桌宠
  Future<List<PetEntity>> getAllPets() async {
    await _ensureInitialized();

    final petsJson = _prefs!.getString(_petsKey);
    if (petsJson == null) return [];

    try {
      final List<dynamic> petsList = jsonDecode(petsJson) as List<dynamic>;
      return petsList
          .map((petJson) => PetEntity.fromJson(petJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException('解析桌宠数据失败: $e');
    }
  }

  /// 根据ID获取桌宠
  Future<PetEntity?> getPetById(String id) async {
    final pets = await getAllPets();
    try {
      return pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 创建桌宠
  Future<PetEntity> createPet(PetEntity pet) async {
    final pets = await getAllPets();

    // 检查ID是否已存在
    if (pets.any((p) => p.id == pet.id)) {
      throw const RepositoryException('桌宠ID已存在');
    }

    pets.add(pet);
    await _savePets(pets);

    // 初始化统计数据
    await _initializePetStats(pet.id);

    return pet;
  }

  /// 更新桌宠
  Future<PetEntity> updatePet(PetEntity pet) async {
    final pets = await getAllPets();
    final index = pets.indexWhere((p) => p.id == pet.id);

    if (index == -1) {
      throw const RepositoryException('桌宠不存在');
    }

    pets[index] = pet;
    await _savePets(pets);

    // 更新统计数据
    await _updatePetStats(pet);

    return pet;
  }

  /// 删除桌宠
  Future<void> deletePet(String id) async {
    final pets = await getAllPets();
    final initialLength = pets.length;

    pets.removeWhere((pet) => pet.id == id);

    if (pets.length == initialLength) {
      throw const RepositoryException('桌宠不存在');
    }

    await _savePets(pets);

    // 清理相关数据
    await _cleanupPetData(id);
  }

  /// 记录互动
  Future<void> recordInteraction(String petId, String interactionType) async {
    await _ensureInitialized();

    final interactionsJson = _prefs!.getString(_interactionsKey) ?? '{}';
    final Map<String, dynamic> interactions =
        jsonDecode(interactionsJson) as Map<String, dynamic>;

    final petInteractions = List<Map<String, dynamic>>.from(
      (interactions[petId] as List<dynamic>?) ?? <dynamic>[],
    );

    petInteractions.add({
      'type': interactionType,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 只保留最近100次互动
    if (petInteractions.length > 100) {
      petInteractions.removeRange(0, petInteractions.length - 100);
    }

    interactions[petId] = petInteractions;
    await _prefs!.setString(_interactionsKey, jsonEncode(interactions));
  }

  /// 获取互动次数
  Future<int> getInteractionCount(String petId) async {
    await _ensureInitialized();

    final interactionsJson = _prefs!.getString(_interactionsKey) ?? '{}';
    final Map<String, dynamic> interactions =
        jsonDecode(interactionsJson) as Map<String, dynamic>;

    final petInteractions = List<dynamic>.from(
      (interactions[petId] as List<dynamic>?) ?? <dynamic>[],
    );
    return petInteractions.length;
  }

  /// 获取平均快乐值
  Future<double> getAverageHappiness(String petId) async {
    await _ensureInitialized();

    final statsJson = _prefs!.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats =
        jsonDecode(statsJson) as Map<String, dynamic>;

    final petStats = stats[petId] as Map<String, dynamic>?;
    if (petStats == null) return 0.0;

    final happinessHistory = List<num>.from(
      (petStats['happinessHistory'] as List<dynamic>?) ?? <dynamic>[],
    );
    if (happinessHistory.isEmpty) return 0.0;

    final total = happinessHistory.fold<double>(
      0.0,
      (double sum, num value) => sum + value.toDouble(),
    );
    return total / happinessHistory.length;
  }

  /// 获取桌宠历史数据
  Future<PetHistoryData> getPetHistory(String petId, {int days = 7}) async {
    await _ensureInitialized();

    final statsJson = _prefs!.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats =
        jsonDecode(statsJson) as Map<String, dynamic>;

    final petStats = stats[petId] as Map<String, dynamic>?;
    if (petStats == null) {
      return PetHistoryData.empty();
    }

    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return PetHistoryData(
      healthHistory: _filterHistoryByDate(
        petStats['healthHistory'],
        cutoffDate,
      ),
      happinessHistory: _filterHistoryByDate(
        petStats['happinessHistory'],
        cutoffDate,
      ),
      energyHistory: _filterHistoryByDate(
        petStats['energyHistory'],
        cutoffDate,
      ),
      interactionHistory: await _filterInteractionsByDate(petId, cutoffDate),
    );
  }

  /// 获取桌宠数量统计
  Future<PetCountStats> getPetCountStats() async {
    final pets = await getAllPets();

    final statusCounts = <PetStatus, int>{};
    final moodCounts = <PetMood, int>{};
    final typeCounts = <String, int>{};

    for (final pet in pets) {
      statusCounts[pet.status] = (statusCounts[pet.status] ?? 0) + 1;
      moodCounts[pet.mood] = (moodCounts[pet.mood] ?? 0) + 1;
      typeCounts[pet.type] = (typeCounts[pet.type] ?? 0) + 1;
    }

    return PetCountStats(
      total: pets.length,
      statusCounts: statusCounts,
      moodCounts: moodCounts,
      typeCounts: typeCounts,
      activePets: pets.where((p) => p.status.isActive).length,
      healthyPets: pets.where((p) => p.isHealthy).length,
      needsAttentionPets: pets.where((p) => p.needsAttention).length,
    );
  }

  /// 批量操作：保存多个桌宠
  Future<void> savePetsBatch(List<PetEntity> pets) async {
    await _savePets(pets);

    // 批量更新统计数据
    for (final pet in pets) {
      await _updatePetStats(pet);
    }
  }

  /// 批量操作：删除多个桌宠
  Future<void> deletePetsBatch(List<String> petIds) async {
    for (final petId in petIds) {
      await deletePet(petId);
    }
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// 保存桌宠列表
  Future<void> _savePets(List<PetEntity> pets) async {
    await _ensureInitialized();

    try {
      final petsJson = jsonEncode(pets.map((pet) => pet.toJson()).toList());
      await _prefs!.setString(_petsKey, petsJson);
    } catch (e) {
      throw RepositoryException('保存桌宠数据失败: $e');
    }
  }

  /// 初始化桌宠统计数据
  Future<void> _initializePetStats(String petId) async {
    await _ensureInitialized();

    final statsJson = _prefs!.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats =
        jsonDecode(statsJson) as Map<String, dynamic>;

    stats[petId] = {
      'healthHistory': <int>[],
      'happinessHistory': <int>[],
      'energyHistory': <int>[],
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _prefs!.setString(_statsKey, jsonEncode(stats));
  }

  /// 更新桌宠统计数据
  Future<void> _updatePetStats(PetEntity pet) async {
    await _ensureInitialized();

    final statsJson = _prefs!.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats =
        jsonDecode(statsJson) as Map<String, dynamic>;

    final petStats =
        stats[pet.id] as Map<String, dynamic>? ?? <String, dynamic>{};

    // 添加当前数值到历史记录
    final healthHistory = List<int>.from(
      (petStats['healthHistory'] as List<dynamic>?) ?? <dynamic>[],
    );
    final happinessHistory = List<int>.from(
      (petStats['happinessHistory'] as List<dynamic>?) ?? <dynamic>[],
    );
    final energyHistory = List<int>.from(
      (petStats['energyHistory'] as List<dynamic>?) ?? <dynamic>[],
    );

    healthHistory.add(pet.health);
    happinessHistory.add(pet.happiness);
    energyHistory.add(pet.energy);

    // 只保留最近100个数据点
    if (healthHistory.length > 100) healthHistory.removeAt(0);
    if (happinessHistory.length > 100) happinessHistory.removeAt(0);
    if (energyHistory.length > 100) energyHistory.removeAt(0);

    petStats['healthHistory'] = healthHistory;
    petStats['happinessHistory'] = happinessHistory;
    petStats['energyHistory'] = energyHistory;
    petStats['lastUpdated'] = DateTime.now().toIso8601String();

    stats[pet.id] = petStats;
    await _prefs!.setString(_statsKey, jsonEncode(stats));
  }

  /// 清理桌宠数据
  Future<void> _cleanupPetData(String petId) async {
    await _ensureInitialized();

    // 清理统计数据
    final statsJson = _prefs!.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats =
        jsonDecode(statsJson) as Map<String, dynamic>;
    stats.remove(petId);
    await _prefs!.setString(_statsKey, jsonEncode(stats));

    // 清理互动数据
    final interactionsJson = _prefs!.getString(_interactionsKey) ?? '{}';
    final Map<String, dynamic> interactions =
        jsonDecode(interactionsJson) as Map<String, dynamic>;
    interactions.remove(petId);
    await _prefs!.setString(_interactionsKey, jsonEncode(interactions));
  }

  /// 按日期过滤历史数据
  List<HistoryPoint> _filterHistoryByDate(
    dynamic history,
    DateTime cutoffDate,
  ) {
    if (history == null) return [];

    final List<dynamic> historyList = List<dynamic>.from(
      history as List<dynamic>,
    );
    // 简化处理：返回最近的数据点
    return historyList
        .asMap()
        .entries
        .map((entry) {
          return HistoryPoint(
            timestamp: DateTime.now().subtract(
              Duration(hours: historyList.length - entry.key),
            ),
            value: (entry.value as num).toDouble(),
          );
        })
        .where((point) => point.timestamp.isAfter(cutoffDate))
        .toList();
  }

  /// 按日期过滤互动数据
  Future<List<InteractionPoint>> _filterInteractionsByDate(
    String petId,
    DateTime cutoffDate,
  ) async {
    await _ensureInitialized();

    final interactionsJson = _prefs!.getString(_interactionsKey) ?? '{}';
    final Map<String, dynamic> interactions =
        jsonDecode(interactionsJson) as Map<String, dynamic>;

    final petInteractions = List<Map<String, dynamic>>.from(
      (interactions[petId] as List<dynamic>?) ?? <dynamic>[],
    );

    return petInteractions
        .map(
          (interaction) => InteractionPoint(
            timestamp: DateTime.parse(interaction['timestamp'] as String),
            type: interaction['type'] as String,
          ),
        )
        .where((point) => point.timestamp.isAfter(cutoffDate))
        .toList();
  }
}

/// 仓库异常
class RepositoryException implements Exception {
  const RepositoryException(this.message);
  final String message;

  @override
  String toString() => 'RepositoryException: $message';
}

/// 桌宠历史数据
class PetHistoryData {
  const PetHistoryData({
    required this.healthHistory,
    required this.happinessHistory,
    required this.energyHistory,
    required this.interactionHistory,
  });

  final List<HistoryPoint> healthHistory;
  final List<HistoryPoint> happinessHistory;
  final List<HistoryPoint> energyHistory;
  final List<InteractionPoint> interactionHistory;

  factory PetHistoryData.empty() => const PetHistoryData(
    healthHistory: [],
    happinessHistory: [],
    energyHistory: [],
    interactionHistory: [],
  );
}

/// 历史数据点
class HistoryPoint {
  const HistoryPoint({required this.timestamp, required this.value});

  final DateTime timestamp;
  final double value;
}

/// 互动数据点
class InteractionPoint {
  const InteractionPoint({required this.timestamp, required this.type});

  final DateTime timestamp;
  final String type;
}

/// 桌宠数量统计
class PetCountStats {
  const PetCountStats({
    required this.total,
    required this.statusCounts,
    required this.moodCounts,
    required this.typeCounts,
    required this.activePets,
    required this.healthyPets,
    required this.needsAttentionPets,
  });

  final int total;
  final Map<PetStatus, int> statusCounts;
  final Map<PetMood, int> moodCounts;
  final Map<String, int> typeCounts;
  final int activePets;
  final int healthyPets;
  final int needsAttentionPets;
}
