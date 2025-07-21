/*
---------------------------------------------------------------
File name:          pet_service.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠服务 - 提供桌宠的CRUD操作和业务逻辑
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:desktop_pet/src/core/ai_engine.dart';
import 'package:desktop_pet/src/core/lifecycle_manager.dart';
import 'package:desktop_pet/src/models/index.dart';
import 'package:desktop_pet/src/repositories/index.dart';

/// 桌宠服务
///
/// 提供桌宠的CRUD操作和业务逻辑
class PetService {
  PetService({
    required PetRepository repository,
    required PetAIEngine aiEngine,
    required PetLifecycleManager lifecycleManager,
  })  : _repository = repository,
        _aiEngine = aiEngine,
        _lifecycleManager = lifecycleManager;
  final PetRepository _repository;
  final PetAIEngine _aiEngine;
  final PetLifecycleManager _lifecycleManager;

  /// 获取所有桌宠
  Future<List<PetEntity>> getAllPets() async {
    try {
      return await _repository.getAllPets();
    } catch (e) {
      throw PetServiceException('获取桌宠列表失败: $e');
    }
  }

  /// 根据ID获取桌宠
  Future<PetEntity?> getPetById(String id) async {
    try {
      return await _repository.getPetById(id);
    } catch (e) {
      throw PetServiceException('获取桌宠失败: $e');
    }
  }

  /// 创建新桌宠
  Future<PetEntity> createPet({
    required String name,
    String type = 'cat',
    String breed = 'domestic',
    String color = 'orange',
    String gender = 'unknown',
  }) async {
    try {
      // 验证输入
      _validatePetInput(name, type, breed, color, gender);

      // 创建桌宠实体
      final pet = PetEntity.createDefault(
        name: name,
        type: type,
        breed: breed,
        color: color,
        gender: gender,
      );

      // 保存到数据库
      final savedPet = await _repository.createPet(pet);

      // 添加到生命周期管理
      _lifecycleManager.addPet(savedPet);

      return savedPet;
    } catch (e) {
      throw PetServiceException('创建桌宠失败: $e');
    }
  }

  /// 更新桌宠
  Future<PetEntity> updatePet(PetEntity pet) async {
    try {
      // 验证桌宠存在
      final existingPet = await _repository.getPetById(pet.id);
      if (existingPet == null) {
        throw const PetServiceException('桌宠不存在');
      }

      // 更新时间戳
      final updatedPet = pet.copyWith(updatedAt: DateTime.now());

      // 保存更新
      final savedPet = await _repository.updatePet(updatedPet);

      // 更新生命周期管理
      _lifecycleManager.updatePet(savedPet);

      return savedPet;
    } catch (e) {
      throw PetServiceException('更新桌宠失败: $e');
    }
  }

  /// 删除桌宠
  Future<void> deletePet(String id) async {
    try {
      // 验证桌宠存在
      final pet = await _repository.getPetById(id);
      if (pet == null) {
        throw const PetServiceException('桌宠不存在');
      }

      // 从生命周期管理中移除
      _lifecycleManager.removePet(id);

      // 清理AI学习数据
      _aiEngine.resetLearning(id);

      // 删除桌宠
      await _repository.deletePet(id);
    } catch (e) {
      throw PetServiceException('删除桌宠失败: $e');
    }
  }

  /// 喂食桌宠
  Future<PetEntity> feedPet(String petId) async {
    try {
      final pet = await _getPetOrThrow(petId);

      // 计算喂食效果
      final newHunger = (pet.hunger - 30).clamp(0, 100);
      final newHappiness = (pet.happiness + 10).clamp(0, 100);
      final newEnergy = (pet.energy + 5).clamp(0, 100);

      // 更新桌宠状态
      final updatedPet = pet.copyWith(
        hunger: newHunger,
        happiness: newHappiness,
        energy: newEnergy,
        lastFed: DateTime.now(),
        mood: newHunger < 30 ? PetMood.happy : pet.mood,
      );

      return await updatePet(updatedPet);
    } catch (e) {
      throw PetServiceException('喂食失败: $e');
    }
  }

  /// 清洁桌宠
  Future<PetEntity> cleanPet(String petId) async {
    try {
      final pet = await _getPetOrThrow(petId);

      // 计算清洁效果
      const newCleanliness = 100;
      final newHappiness = (pet.happiness + 15).clamp(0, 100);
      final newHealth = (pet.health + 5).clamp(0, 100);

      // 更新桌宠状态
      final updatedPet = pet.copyWith(
        cleanliness: newCleanliness,
        happiness: newHappiness,
        health: newHealth,
        lastCleaned: DateTime.now(),
        mood: PetMood.happy,
      );

      return await updatePet(updatedPet);
    } catch (e) {
      throw PetServiceException('清洁失败: $e');
    }
  }

  /// 与桌宠互动
  Future<PetEntity> interactWithPet(
    String petId,
    String interactionType,
  ) async {
    try {
      final pet = await _getPetOrThrow(petId);

      // 根据互动类型计算效果
      final effects = _calculateInteractionEffects(pet, interactionType);

      // 更新桌宠状态
      final updatedPet = pet.copyWith(
        happiness:
            (pet.happiness + (effects['happiness'] as int)).clamp(0, 100),
        energy: (pet.energy + (effects['energy'] as int)).clamp(0, 100),
        social: (pet.social + (effects['social'] as int)).clamp(0, 100),
        lastInteraction: DateTime.now(),
        mood: effects['mood'] as PetMood? ?? pet.mood,
      );

      // 记录AI学习
      _recordInteractionForAI(pet, interactionType, effects);

      return await updatePet(updatedPet);
    } catch (e) {
      throw PetServiceException('互动失败: $e');
    }
  }

  /// 获取桌宠统计信息
  Future<PetStats> getPetStats(String petId) async {
    try {
      final pet = await _getPetOrThrow(petId);
      final aiStatus = _aiEngine.getAIStatus(petId);
      final lifecycleInfo = _lifecycleManager.getLifecycleInfo(petId);

      return PetStats(
        pet: pet,
        aiStatus: aiStatus,
        lifecycleInfo: lifecycleInfo,
        totalInteractions: await _repository.getInteractionCount(petId),
        averageHappiness: await _repository.getAverageHappiness(petId),
        daysAlive: pet.ageInDays,
      );
    } catch (e) {
      throw PetServiceException('获取统计信息失败: $e');
    }
  }

  /// 执行桌宠行为
  Future<PetEntity> executeBehavior(String petId, PetBehavior behavior) async {
    try {
      final pet = await _getPetOrThrow(petId);

      // 检查行为是否可以执行
      final context = _buildBehaviorContext(pet);
      if (!behavior.canTrigger(context)) {
        throw const PetServiceException('当前无法执行该行为');
      }

      // 执行行为动作
      var updatedPet = pet;
      for (final action in behavior.actions) {
        updatedPet = await _executeAction(updatedPet, action);
      }

      // 记录行为执行结果
      const success = true; // 简化处理，实际应根据执行结果判断
      final satisfaction = _calculateSatisfaction(pet, updatedPet);

      _aiEngine.learnFromBehavior(petId, behavior, success, satisfaction);

      return await updatePet(updatedPet);
    } catch (e) {
      throw PetServiceException('执行行为失败: $e');
    }
  }

  /// 验证桌宠输入
  void _validatePetInput(
    String name,
    String type,
    String breed,
    String color,
    String gender,
  ) {
    if (name.trim().isEmpty) {
      throw const PetServiceException('桌宠名称不能为空');
    }
    if (name.length > 20) {
      throw const PetServiceException('桌宠名称不能超过20个字符');
    }
    if (type.trim().isEmpty) {
      throw const PetServiceException('桌宠类型不能为空');
    }
  }

  /// 获取桌宠或抛出异常
  Future<PetEntity> _getPetOrThrow(String petId) async {
    final pet = await _repository.getPetById(petId);
    if (pet == null) {
      throw const PetServiceException('桌宠不存在');
    }
    return pet;
  }

  /// 计算互动效果
  Map<String, dynamic> _calculateInteractionEffects(
    PetEntity pet,
    String interactionType,
  ) {
    switch (interactionType) {
      case 'play':
        return <String, dynamic>{
          'happiness': 20,
          'energy': -10,
          'social': 15,
          'mood': PetMood.happy,
        };
      case 'pet':
        return <String, dynamic>{
          'happiness': 15,
          'energy': 0,
          'social': 10,
          'mood': PetMood.loving,
        };
      case 'talk':
        return <String, dynamic>{
          'happiness': 10,
          'energy': 0,
          'social': 20,
          'mood': PetMood.curious,
        };
      default:
        return <String, dynamic>{
          'happiness': 5,
          'energy': 0,
          'social': 5,
        };
    }
  }

  /// 记录互动用于AI学习
  void _recordInteractionForAI(
    PetEntity pet,
    String interactionType,
    Map<String, dynamic> effects,
  ) {
    // 创建虚拟行为用于学习
    final behavior = PetBehavior.createDefault(
      id: 'interaction_$interactionType',
      name: '互动: $interactionType',
      tags: <String>['interaction', interactionType],
    );

    final satisfaction = (effects['happiness'] as int) / 20.0;
    _aiEngine.learnFromBehavior(
      pet.id,
      behavior,
      true,
      satisfaction.clamp(0.0, 1.0),
    );
  }

  /// 构建行为上下文
  Map<String, dynamic> _buildBehaviorContext(PetEntity pet) =>
      <String, dynamic>{
        'mood': pet.mood.id,
        'activity': pet.currentActivity.id,
        'status': pet.status.id,
        'health': pet.health,
        'energy': pet.energy,
        'hunger': pet.hunger,
        'happiness': pet.happiness,
        'lastInteraction': pet.lastInteraction.toIso8601String(),
      };

  /// 执行单个动作
  Future<PetEntity> _executeAction(PetEntity pet, BehaviorAction action) async {
    switch (action.type) {
      case ActionType.changeMood:
        final newMoodId = action.parameters['mood'] as String;
        final newMood = PetMood.fromId(newMoodId);
        return pet.copyWith(mood: newMood);

      case ActionType.changeActivity:
        final newActivityId = action.parameters['activity'] as String;
        final newActivity = PetActivity.fromId(newActivityId);
        return pet.copyWith(currentActivity: newActivity);

      case ActionType.modifyStat:
        final statName = action.parameters['stat'] as String;
        final change = action.parameters['change'] as int;

        switch (statName) {
          case 'health':
            return pet.copyWith(health: (pet.health + change).clamp(0, 100));
          case 'energy':
            return pet.copyWith(energy: (pet.energy + change).clamp(0, 100));
          case 'happiness':
            return pet.copyWith(
              happiness: (pet.happiness + change).clamp(0, 100),
            );
          default:
            return pet;
        }

      case ActionType.playAnimation:
      case ActionType.showMessage:
      case ActionType.move:
        return pet; // 其他动作类型暂不处理
    }
  }

  /// 计算满意度
  double _calculateSatisfaction(PetEntity before, PetEntity after) {
    final healthImprovement = (after.health - before.health) / 100.0;
    final happinessImprovement = (after.happiness - before.happiness) / 100.0;
    final energyImprovement = (after.energy - before.energy) / 100.0;

    final totalImprovement =
        healthImprovement + happinessImprovement + energyImprovement;
    return (totalImprovement / 3.0 + 0.5).clamp(0.0, 1.0);
  }
}

/// 桌宠服务异常
class PetServiceException implements Exception {
  const PetServiceException(this.message);
  final String message;

  @override
  String toString() => 'PetServiceException: $message';
}

/// 桌宠统计信息
class PetStats {
  const PetStats({
    required this.pet,
    required this.aiStatus,
    required this.lifecycleInfo,
    required this.totalInteractions,
    required this.averageHappiness,
    required this.daysAlive,
  });
  final PetEntity pet;
  final AIStatus aiStatus;
  final LifecycleInfo lifecycleInfo;
  final int totalInteractions;
  final double averageHappiness;
  final int daysAlive;
}
