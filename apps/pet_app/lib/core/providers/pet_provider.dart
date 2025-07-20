/*
---------------------------------------------------------------
File name:          pet_provider.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠状态管理Provider - 使用Riverpod管理桌宠状态
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pet/models/pet_entity.dart';
import '../pet/models/pet_state.dart';
import '../pet/enums/pet_mood.dart';
import '../pet/enums/pet_activity.dart';
import '../pet/enums/pet_status.dart';
import '../services/pet_service.dart';

/// 桌宠状态提供者
final petProvider = StateNotifierProvider<PetNotifier, PetState>((ref) {
  return PetNotifier(ref.read(petServiceProvider));
});

/// 当前桌宠提供者
final currentPetProvider = Provider<PetEntity?>((ref) {
  return ref.watch(petProvider).currentPet;
});

/// 桌宠列表提供者
final petListProvider = Provider<List<PetEntity>>((ref) {
  return ref.watch(petProvider).pets;
});

/// 活跃桌宠数量提供者
final activePetCountProvider = Provider<int>((ref) {
  return ref.watch(petProvider).activePetCount;
});

/// 需要关注的桌宠数量提供者
final petsNeedingAttentionProvider = Provider<int>((ref) {
  return ref.watch(petProvider).petsNeedingAttention;
});

/// 桌宠系统状态提供者
final petSystemStatusProvider = Provider<String>((ref) {
  return ref.watch(petProvider).statusDescription;
});

/// 桌宠状态通知器
class PetNotifier extends StateNotifier<PetState> {
  final PetService _petService;

  PetNotifier(this._petService) : super(PetState.initial()) {
    _initialize();
  }

  /// 初始化桌宠系统
  Future<void> _initialize() async {
    if (!mounted) return;

    state = state.copyWithLoading(true);

    try {
      // 加载桌宠数据
      await _loadPets();

      // 启动桌宠系统
      await _startPetSystem();

      if (!mounted) return;
      state = state.copyWithLoading(false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('桌宠系统初始化失败: $e');
    }
  }

  /// 加载桌宠列表
  Future<void> _loadPets() async {
    try {
      final pets = await _petService.getAllPets();
      if (!mounted) return;

      state = state.copyWith(pets: pets);

      // 设置当前桌宠
      if (pets.isNotEmpty && state.currentPet == null) {
        final activePet = pets.firstWhere(
          (pet) => pet.status.isActive,
          orElse: () => pets.first,
        );
        state = state.copyWith(currentPet: activePet);
      }
    } catch (e) {
      throw Exception('加载桌宠列表失败: $e');
    }
  }

  /// 启动桌宠系统
  Future<void> _startPetSystem() async {
    try {
      await _petService.startSystem();
    } catch (e) {
      throw Exception('启动桌宠系统失败: $e');
    }
  }

  /// 刷新桌宠数据
  Future<void> refresh() async {
    if (!mounted) return;

    state = state.copyWithLoading(true);

    try {
      await _loadPets();
      if (!mounted) return;
      state = state.copyWithLoading(false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('刷新桌宠数据失败: $e');
    }
  }

  /// 创建新桌宠
  Future<void> createPet({
    required String name,
    String type = 'cat',
    String breed = 'domestic',
    String color = 'orange',
    String gender = 'unknown',
  }) async {
    if (!mounted) return;

    state = state.copyWithLoading(true);

    try {
      final newPet = await _petService.createPet(
        name: name,
        type: type,
        breed: breed,
        color: color,
        gender: gender,
      );

      if (!mounted) return;

      final updatedPets = List<PetEntity>.from(state.pets)..add(newPet);
      state = state.copyWith(
        pets: updatedPets,
        currentPet: newPet,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('创建桌宠失败: $e');
    }
  }

  /// 删除桌宠
  Future<void> deletePet(String petId) async {
    if (!mounted) return;

    state = state.copyWithLoading(true);

    try {
      await _petService.deletePet(petId);

      if (!mounted) return;

      final updatedPets = state.pets.where((pet) => pet.id != petId).toList();
      PetEntity? newCurrentPet = state.currentPet;

      if (state.currentPet?.id == petId) {
        newCurrentPet = updatedPets.isNotEmpty ? updatedPets.first : null;
      }

      state = state.copyWith(
        pets: updatedPets,
        currentPet: newCurrentPet,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('删除桌宠失败: $e');
    }
  }

  /// 切换当前桌宠
  void switchCurrentPet(String petId) {
    final pet = state.pets.firstWhere(
      (p) => p.id == petId,
      orElse: () => throw Exception('桌宠不存在'),
    );

    state = state.copyWith(currentPet: pet);
  }

  /// 更新桌宠心情
  Future<void> updatePetMood(String petId, PetMood mood) async {
    try {
      await _petService.updatePetMood(petId, mood);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('更新桌宠心情失败: $e');
    }
  }

  /// 更新桌宠活动
  Future<void> updatePetActivity(String petId, PetActivity activity) async {
    try {
      await _petService.updatePetActivity(petId, activity);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('更新桌宠活动失败: $e');
    }
  }

  /// 更新桌宠状态
  Future<void> updatePetStatus(String petId, PetStatus status) async {
    try {
      await _petService.updatePetStatus(petId, status);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('更新桌宠状态失败: $e');
    }
  }

  /// 喂食桌宠
  Future<void> feedPet(String petId) async {
    try {
      await _petService.feedPet(petId);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('喂食桌宠失败: $e');
    }
  }

  /// 清洁桌宠
  Future<void> cleanPet(String petId) async {
    try {
      await _petService.cleanPet(petId);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('清洁桌宠失败: $e');
    }
  }

  /// 与桌宠玩耍
  Future<void> playWithPet(String petId) async {
    try {
      await _petService.playWithPet(petId);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('与桌宠玩耍失败: $e');
    }
  }

  /// 移动桌宠位置
  Future<void> movePet(String petId, double x, double y) async {
    try {
      await _petService.movePet(petId, x, y);
      await _updatePetInState(petId);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWithError('移动桌宠失败: $e');
    }
  }

  /// 设置桌宠可见性
  void setPetVisibility(bool visible) {
    state = state.copyWith(isVisible: visible);
  }

  /// 设置桌宠交互模式
  void setInteractionMode(PetInteractionMode mode) {
    state = state.copyWith(interactionMode: mode);
  }

  /// 启用/禁用桌宠系统
  void setPetSystemEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }

  /// 更新状态中的桌宠
  Future<void> _updatePetInState(String petId) async {
    try {
      final updatedPet = await _petService.getPet(petId);
      if (updatedPet == null || !mounted) return;

      final updatedPets = state.pets.map((pet) {
        return pet.id == petId ? updatedPet : pet;
      }).toList();

      PetEntity? updatedCurrentPet = state.currentPet;
      if (state.currentPet?.id == petId) {
        updatedCurrentPet = updatedPet;
      }

      state = state.copyWith(pets: updatedPets, currentPet: updatedCurrentPet);
    } catch (e) {
      // 静默处理更新错误
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}
