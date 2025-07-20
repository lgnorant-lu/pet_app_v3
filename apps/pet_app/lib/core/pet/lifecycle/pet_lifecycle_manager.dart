/*
---------------------------------------------------------------
File name:          pet_lifecycle_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠生命周期管理器 - 管理桌宠的生命周期状态
---------------------------------------------------------------
*/

import 'dart:async';
import '../models/pet_entity.dart';
import '../enums/pet_status.dart';

import '../enums/pet_activity.dart';

/// 桌宠生命周期管理器
///
/// 负责管理桌宠的生命周期状态转换和自动化处理
class PetLifecycleManager {
  Timer? _lifecycleTimer;
  final List<PetEntity> _managedPets = [];
  final Map<String, LifecycleState> _petStates = {};

  /// 启动生命周期管理
  void start() {
    _lifecycleTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _processLifecycleUpdates(),
    );
  }

  /// 停止生命周期管理
  void stop() {
    _lifecycleTimer?.cancel();
    _lifecycleTimer = null;
  }

  /// 添加桌宠到管理列表
  void addPet(PetEntity pet) {
    if (!_managedPets.any((p) => p.id == pet.id)) {
      _managedPets.add(pet);
      _petStates[pet.id] = LifecycleState.fromPet(pet);
    }
  }

  /// 从管理列表移除桌宠
  void removePet(String petId) {
    _managedPets.removeWhere((p) => p.id == petId);
    _petStates.remove(petId);
  }

  /// 更新桌宠状态
  void updatePet(PetEntity pet) {
    final index = _managedPets.indexWhere((p) => p.id == pet.id);
    if (index >= 0) {
      _managedPets[index] = pet;
      _petStates[pet.id] = LifecycleState.fromPet(pet);
    }
  }

  /// 处理生命周期更新
  Future<void> _processLifecycleUpdates() async {
    for (final pet in _managedPets) {
      await _processPetLifecycle(pet);
    }
  }

  /// 处理单个桌宠的生命周期
  Future<void> _processPetLifecycle(PetEntity pet) async {
    final currentState = _petStates[pet.id];
    if (currentState == null) return;

    // 检查生命周期阶段转换
    final newLifecycleStatus = _checkLifecycleProgression(pet);
    if (newLifecycleStatus != null && newLifecycleStatus != pet.status) {
      await _transitionToLifecycleStage(pet, newLifecycleStatus);
    }

    // 检查健康状态变化
    final newHealthStatus = _checkHealthStatus(pet);
    if (newHealthStatus != null && newHealthStatus != pet.status) {
      await _transitionToHealthStatus(pet, newHealthStatus);
    }

    // 检查自动恢复
    await _checkAutoRecovery(pet);
  }

  /// 检查生命周期阶段进展
  PetStatus? _checkLifecycleProgression(PetEntity pet) {
    final ageInDays = pet.ageInDays;

    switch (pet.status) {
      case PetStatus.unborn:
        return PetStatus.hatching;

      case PetStatus.hatching:
        // 孵化需要一定时间
        if (ageInDays >= 1) {
          return PetStatus.baby;
        }
        break;

      case PetStatus.baby:
        // 幼体阶段持续7天
        if (ageInDays >= 7) {
          return PetStatus.growing;
        }
        break;

      case PetStatus.growing:
        // 成长阶段持续30天
        if (ageInDays >= 30) {
          return PetStatus.adult;
        }
        break;

      case PetStatus.adult:
        // 成年后保持活跃状态
        if (pet.isHealthy) {
          return PetStatus.active;
        }
        break;

      default:
        break;
    }

    return null;
  }

  /// 检查健康状态
  PetStatus? _checkHealthStatus(PetEntity pet) {
    // 如果是系统状态，不改变
    if (pet.status.isSystem) return null;

    // 检查严重健康问题
    if (pet.health <= 10) {
      return PetStatus.injured;
    }

    if (pet.health <= 30 || pet.hunger >= 90) {
      return PetStatus.sick;
    }

    if (pet.health <= 50 || pet.energy <= 20) {
      return PetStatus.weak;
    }

    if (pet.energy <= 30) {
      return PetStatus.tired;
    }

    // 检查恢复状态
    if (pet.status.needsAttention && pet.health > 60 && pet.energy > 40) {
      return PetStatus.recovering;
    }

    // 检查健康状态
    if (pet.isHealthy && pet.status != PetStatus.healthy) {
      return PetStatus.healthy;
    }

    return null;
  }

  /// 转换到生命周期阶段
  Future<void> _transitionToLifecycleStage(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 触发生命周期事件
    await _triggerLifecycleEvent(pet, newStatus);

    // 更新桌宠状态
    final updatedPet = pet.copyWith(status: newStatus);
    updatePet(updatedPet);
  }

  /// 转换到健康状态
  Future<void> _transitionToHealthStatus(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 触发健康状态事件
    await _triggerHealthEvent(pet, newStatus);

    // 更新桌宠状态
    final updatedPet = pet.copyWith(status: newStatus);
    updatePet(updatedPet);
  }

  /// 触发生命周期事件
  Future<void> _triggerLifecycleEvent(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    switch (newStatus) {
      case PetStatus.hatching:
        // 孵化事件
        break;
      case PetStatus.baby:
        // 出生事件
        break;
      case PetStatus.growing:
        // 成长事件
        break;
      case PetStatus.adult:
        // 成年事件
        break;
      case PetStatus.active:
        // 激活事件
        break;
      default:
        break;
    }
  }

  /// 触发健康状态事件
  Future<void> _triggerHealthEvent(PetEntity pet, PetStatus newStatus) async {
    switch (newStatus) {
      case PetStatus.sick:
        // 生病事件
        break;
      case PetStatus.injured:
        // 受伤事件
        break;
      case PetStatus.weak:
        // 虚弱事件
        break;
      case PetStatus.tired:
        // 疲倦事件
        break;
      case PetStatus.recovering:
        // 恢复事件
        break;
      case PetStatus.healthy:
        // 健康事件
        break;
      default:
        break;
    }
  }

  /// 检查自动恢复
  Future<void> _checkAutoRecovery(PetEntity pet) async {
    final now = DateTime.now();

    // 睡眠恢复能量
    if (pet.currentActivity == PetActivity.sleeping) {
      final sleepDuration = now.difference(pet.lastInteraction);
      if (sleepDuration.inMinutes >= 30) {
        final energyRestore = (sleepDuration.inMinutes / 10).round();
        final newEnergy = (pet.energy + energyRestore).clamp(0, 100);

        if (newEnergy != pet.energy) {
          final updatedPet = pet.copyWith(energy: newEnergy);
          updatePet(updatedPet);
        }
      }
    }

    // 自然恢复
    final timeSinceLastUpdate = now.difference(pet.updatedAt);
    if (timeSinceLastUpdate.inMinutes >= 60) {
      var updatedPet = pet;

      // 缓慢恢复健康
      if (pet.health < 100 && pet.status != PetStatus.sick) {
        final healthRestore = 1;
        updatedPet = updatedPet.copyWith(
          health: (pet.health + healthRestore).clamp(0, 100),
        );
      }

      // 缓慢恢复清洁度（如果不是很脏）
      if (pet.cleanliness < 80 && pet.cleanliness > 20) {
        final cleanRestore = 1;
        updatedPet = updatedPet.copyWith(
          cleanliness: (pet.cleanliness + cleanRestore).clamp(0, 100),
        );
      }

      if (updatedPet != pet) {
        updatePet(updatedPet);
      }
    }
  }

  /// 获取桌宠生命周期信息
  LifecycleInfo getLifecycleInfo(String petId) {
    final pet = _managedPets.firstWhere(
      (p) => p.id == petId,
      orElse: () => throw Exception('桌宠不存在'),
    );

    return LifecycleInfo(
      currentStage: pet.ageStage,
      ageInDays: pet.ageInDays,
      nextStageIn: _calculateNextStageTime(pet),
      healthStatus: pet.status,
      overallCondition: _calculateOverallCondition(pet),
    );
  }

  /// 计算下一阶段时间
  int _calculateNextStageTime(PetEntity pet) {
    final ageInDays = pet.ageInDays;

    if (ageInDays < 7) {
      return 7 - ageInDays; // 到少年期
    } else if (ageInDays < 30) {
      return 30 - ageInDays; // 到青年期
    } else if (ageInDays < 90) {
      return 90 - ageInDays; // 到成年期
    } else if (ageInDays < 365) {
      return 365 - ageInDays; // 到长者期
    }

    return 0; // 已经是最高阶段
  }

  /// 计算总体状况
  String _calculateOverallCondition(PetEntity pet) {
    final score = pet.overallScore;

    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    if (score >= 40) return '一般';
    if (score >= 20) return '较差';
    return '危险';
  }

  /// 释放资源
  void dispose() {
    stop();
    _managedPets.clear();
    _petStates.clear();
  }
}

/// 生命周期状态
class LifecycleState {
  final DateTime lastHealthCheck;
  final DateTime lastLifecycleCheck;
  final Map<String, dynamic> metadata;

  const LifecycleState({
    required this.lastHealthCheck,
    required this.lastLifecycleCheck,
    this.metadata = const {},
  });

  factory LifecycleState.fromPet(PetEntity pet) {
    return LifecycleState(
      lastHealthCheck: DateTime.now(),
      lastLifecycleCheck: DateTime.now(),
      metadata: {'lastStatus': pet.status.id, 'lastMood': pet.mood.id},
    );
  }
}

/// 生命周期信息
class LifecycleInfo {
  final String currentStage;
  final int ageInDays;
  final int nextStageIn;
  final PetStatus healthStatus;
  final String overallCondition;

  const LifecycleInfo({
    required this.currentStage,
    required this.ageInDays,
    required this.nextStageIn,
    required this.healthStatus,
    required this.overallCondition,
  });
}
