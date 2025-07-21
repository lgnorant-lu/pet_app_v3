/*
---------------------------------------------------------------
File name:          lifecycle_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠生命周期管理器 - 负责管理桌宠的生命周期状态转换和自动化处理
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:desktop_pet/src/models/index.dart';

/// 桌宠生命周期管理器
///
/// 负责管理桌宠的生命周期状态转换和自动化处理
class PetLifecycleManager {
  Timer? _lifecycleTimer;
  final List<PetEntity> _managedPets = <PetEntity>[];
  final Map<String, LifecycleState> _petStates = <String, LifecycleState>{};

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
    if (!_managedPets.any((PetEntity p) => p.id == pet.id)) {
      _managedPets.add(pet);
      _petStates[pet.id] = LifecycleState.fromPet(pet);
    }
  }

  /// 从管理列表移除桌宠
  void removePet(String petId) {
    _managedPets.removeWhere((PetEntity p) => p.id == petId);
    _petStates.remove(petId);
  }

  /// 更新桌宠状态
  void updatePet(PetEntity pet) {
    final index = _managedPets.indexWhere((PetEntity p) => p.id == pet.id);
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

  /// 检查生命周期进展
  PetStatus? _checkLifecycleProgression(PetEntity pet) {
    final ageInDays = pet.ageInDays;

    // 根据年龄确定生命周期阶段
    if (ageInDays >= 365 && pet.status != PetStatus.adult) {
      return PetStatus.adult;
    } else if (ageInDays >= 90 && pet.status == PetStatus.growing) {
      return PetStatus.adult;
    } else if (ageInDays >= 30 && pet.status == PetStatus.baby) {
      return PetStatus.growing;
    } else if (ageInDays >= 7 && pet.status == PetStatus.baby) {
      return PetStatus.growing;
    }

    return null;
  }

  /// 检查健康状态
  PetStatus? _checkHealthStatus(PetEntity pet) {
    // 严重健康问题
    if (pet.health <= 10) {
      return PetStatus.injured;
    }

    // 生病状态
    if (pet.health <= 30 || 
        (pet.hunger > 90 && pet.energy < 10)) {
      return PetStatus.sick;
    }

    // 虚弱状态
    if (pet.health <= 50 && pet.energy <= 20) {
      return PetStatus.weak;
    }

    // 疲倦状态
    if (pet.energy <= 15) {
      return PetStatus.tired;
    }

    // 恢复中状态
    if (pet.status == PetStatus.sick && pet.health > 50) {
      return PetStatus.recovering;
    }

    // 健康状态
    if (pet.health >= 80 && 
        pet.energy >= 60 && 
        pet.hunger <= 30 && 
        pet.happiness >= 70) {
      return PetStatus.healthy;
    }

    // 活跃状态
    if (pet.health >= 90 && 
        pet.energy >= 80 && 
        pet.happiness >= 80) {
      return PetStatus.active;
    }

    return null;
  }

  /// 转换到生命周期阶段
  Future<void> _transitionToLifecycleStage(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 更新桌宠状态
    final updatedPet = pet.copyWith(status: newStatus);
    updatePet(updatedPet);

    // 触发生命周期事件
    await _triggerLifecycleEvent(pet, newStatus);
  }

  /// 转换到健康状态
  Future<void> _transitionToHealthStatus(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 更新桌宠状态
    final updatedPet = pet.copyWith(status: newStatus);
    updatePet(updatedPet);

    // 触发健康状态事件
    await _triggerHealthEvent(pet, newStatus);
  }

  /// 触发生命周期事件
  Future<void> _triggerLifecycleEvent(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 这里可以触发UI通知、音效等
    // 例如：成长庆祝动画、状态变化提示等
  }

  /// 触发健康事件
  Future<void> _triggerHealthEvent(
    PetEntity pet,
    PetStatus newStatus,
  ) async {
    // 这里可以触发健康相关的UI反馈
    // 例如：生病提醒、恢复庆祝等
  }

  /// 检查自动恢复
  Future<void> _checkAutoRecovery(PetEntity pet) async {
    final now = DateTime.now();

    // 自然恢复
    final timeSinceLastUpdate = now.difference(pet.updatedAt);
    if (timeSinceLastUpdate.inMinutes >= 60) {
      var updatedPet = pet;

      // 缓慢恢复健康
      if (pet.health < 100 && pet.status != PetStatus.sick) {
        const healthRestore = 1;
        updatedPet = updatedPet.copyWith(
          health: (pet.health + healthRestore).clamp(0, 100),
        );
      }

      // 缓慢恢复清洁度（如果不是很脏）
      if (pet.cleanliness < 80 && pet.cleanliness > 20) {
        const cleanRestore = 1;
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
      (PetEntity p) => p.id == petId,
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

  /// 计算整体状况
  String _calculateOverallCondition(PetEntity pet) {
    final score = pet.overallScore;

    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '一般';
    if (score >= 60) return '需要关注';
    return '状况不佳';
  }
}

/// 生命周期状态
class LifecycleState {

  const LifecycleState({
    required this.lastHealthCheck,
    required this.lastLifecycleCheck,
    this.metadata = const <String, dynamic>{},
  });

  factory LifecycleState.fromPet(PetEntity pet) => LifecycleState(
      lastHealthCheck: DateTime.now(),
      lastLifecycleCheck: DateTime.now(),
      metadata: <String, dynamic>{'lastStatus': pet.status.id, 'lastMood': pet.mood.id},
    );
  final DateTime lastHealthCheck;
  final DateTime lastLifecycleCheck;
  final Map<String, dynamic> metadata;
}

/// 生命周期信息
class LifecycleInfo {

  const LifecycleInfo({
    required this.currentStage,
    required this.ageInDays,
    required this.nextStageIn,
    required this.healthStatus,
    required this.overallCondition,
  });
  final String currentStage;
  final int ageInDays;
  final int nextStageIn;
  final PetStatus healthStatus;
  final String overallCondition;
}
