/*
---------------------------------------------------------------
File name:          pet_service.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠服务 - 管理桌宠数据和业务逻辑
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../pet/models/pet_entity.dart';
import '../pet/models/pet_profile.dart';
import '../pet/enums/pet_mood.dart';
import '../pet/enums/pet_activity.dart';
import '../pet/enums/pet_status.dart';

/// 桌宠服务提供者
final petServiceProvider = Provider<PetService>((ref) {
  return PetService();
});

/// 桌宠服务
///
/// 负责桌宠的数据管理、状态更新和业务逻辑
class PetService {
  static const String _petsKey = 'pets_data';
  static const String _profilesKey = 'pet_profiles_data';

  SharedPreferences? _prefs;
  Timer? _updateTimer;
  bool _isSystemRunning = false;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 启动桌宠系统
  Future<void> startSystem() async {
    await initialize();

    if (_isSystemRunning) return;

    _isSystemRunning = true;

    // 启动定时更新
    _updateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateAllPets(),
    );
  }

  /// 停止桌宠系统
  Future<void> stopSystem() async {
    _isSystemRunning = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// 获取所有桌宠
  Future<List<PetEntity>> getAllPets() async {
    await initialize();

    final petsJson = _prefs!.getString(_petsKey);
    if (petsJson == null) return [];

    try {
      final List<dynamic> petsList = jsonDecode(petsJson);
      return petsList.map((json) => PetEntity.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取单个桌宠
  Future<PetEntity?> getPet(String petId) async {
    final pets = await getAllPets();
    try {
      return pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
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
    await initialize();

    final newPet = PetEntity.createDefault(
      name: name,
      type: type,
      breed: breed,
      color: color,
      gender: gender,
    );

    // 保存桌宠
    await _savePet(newPet);

    // 创建桌宠档案
    final profile = PetProfile.createDefault(
      petId: newPet.id,
      name: name,
      nickname: name,
    );
    await _saveProfile(profile);

    return newPet;
  }

  /// 删除桌宠
  Future<void> deletePet(String petId) async {
    await initialize();

    final pets = await getAllPets();
    final updatedPets = pets.where((pet) => pet.id != petId).toList();

    await _saveAllPets(updatedPets);
    await _deleteProfile(petId);
  }

  /// 更新桌宠心情
  Future<void> updatePetMood(String petId, PetMood mood) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final updatedPet = pet.copyWith(mood: mood);
    await _savePet(updatedPet);
  }

  /// 更新桌宠活动
  Future<void> updatePetActivity(String petId, PetActivity activity) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final updatedPet = pet.copyWith(currentActivity: activity);
    await _savePet(updatedPet);
  }

  /// 更新桌宠状态
  Future<void> updatePetStatus(String petId, PetStatus status) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final updatedPet = pet.copyWith(status: status);
    await _savePet(updatedPet);
  }

  /// 喂食桌宠
  Future<void> feedPet(String petId) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final now = DateTime.now();
    final updatedPet = pet.copyWith(
      hunger: (pet.hunger - 30).clamp(0, 100),
      happiness: (pet.happiness + 10).clamp(0, 100),
      lastFed: now,
      lastInteraction: now,
    );

    await _savePet(updatedPet);
  }

  /// 清洁桌宠
  Future<void> cleanPet(String petId) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final now = DateTime.now();
    final updatedPet = pet.copyWith(
      cleanliness: (pet.cleanliness + 40).clamp(0, 100),
      happiness: (pet.happiness + 5).clamp(0, 100),
      lastCleaned: now,
      lastInteraction: now,
    );

    await _savePet(updatedPet);
  }

  /// 与桌宠玩耍
  Future<void> playWithPet(String petId) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final now = DateTime.now();
    final updatedPet = pet.copyWith(
      happiness: (pet.happiness + 20).clamp(0, 100),
      energy: (pet.energy - 10).clamp(0, 100),
      social: (pet.social + 15).clamp(0, 100),
      currentActivity: PetActivity.playing,
      lastInteraction: now,
    );

    await _savePet(updatedPet);
  }

  /// 移动桌宠位置
  Future<void> movePet(String petId, double x, double y) async {
    final pet = await getPet(petId);
    if (pet == null) throw Exception('桌宠不存在');

    final updatedPet = pet.copyWith(positionX: x, positionY: y);

    await _savePet(updatedPet);
  }

  /// 获取桌宠档案
  Future<PetProfile?> getPetProfile(String petId) async {
    await initialize();

    final profilesJson = _prefs!.getString(_profilesKey);
    if (profilesJson == null) return null;

    try {
      final Map<String, dynamic> profilesMap = jsonDecode(profilesJson);
      final profileJson = profilesMap[petId];
      if (profileJson == null) return null;

      return PetProfile.fromJson(profileJson);
    } catch (e) {
      return null;
    }
  }

  /// 保存桌宠（公共方法）
  Future<void> savePet(PetEntity pet) async {
    await _savePet(pet);
  }

  /// 保存单个桌宠
  Future<void> _savePet(PetEntity pet) async {
    final pets = await getAllPets();
    final index = pets.indexWhere((p) => p.id == pet.id);

    if (index >= 0) {
      pets[index] = pet;
    } else {
      pets.add(pet);
    }

    await _saveAllPets(pets);
  }

  /// 保存所有桌宠
  Future<void> _saveAllPets(List<PetEntity> pets) async {
    await initialize();

    final petsJson = jsonEncode(pets.map((pet) => pet.toJson()).toList());
    await _prefs!.setString(_petsKey, petsJson);
  }

  /// 保存桌宠档案
  Future<void> _saveProfile(PetProfile profile) async {
    await initialize();

    final profilesJson = _prefs!.getString(_profilesKey) ?? '{}';
    final Map<String, dynamic> profilesMap = jsonDecode(profilesJson);

    profilesMap[profile.petId] = profile.toJson();

    await _prefs!.setString(_profilesKey, jsonEncode(profilesMap));
  }

  /// 删除桌宠档案
  Future<void> _deleteProfile(String petId) async {
    await initialize();

    final profilesJson = _prefs!.getString(_profilesKey) ?? '{}';
    final Map<String, dynamic> profilesMap = jsonDecode(profilesJson);

    profilesMap.remove(petId);

    await _prefs!.setString(_profilesKey, jsonEncode(profilesMap));
  }

  /// 定时更新所有桌宠
  Future<void> _updateAllPets() async {
    if (!_isSystemRunning) return;

    try {
      final pets = await getAllPets();
      final now = DateTime.now();
      bool hasChanges = false;

      final updatedPets = pets.map((pet) {
        if (!pet.status.isActive) return pet;

        // 计算时间差
        final timeSinceLastUpdate = now.difference(pet.updatedAt).inMinutes;
        if (timeSinceLastUpdate < 1) return pet;

        // 更新桌宠状态
        var updatedPet = pet;

        // 饥饿值增加
        if (timeSinceLastUpdate > 0) {
          final hungerIncrease = (timeSinceLastUpdate * 0.5).round();
          updatedPet = updatedPet.copyWith(
            hunger: (pet.hunger + hungerIncrease).clamp(0, 100),
          );
        }

        // 清洁度下降
        if (timeSinceLastUpdate > 30) {
          final cleanlinessDecrease = ((timeSinceLastUpdate - 30) * 0.2)
              .round();
          updatedPet = updatedPet.copyWith(
            cleanliness: (pet.cleanliness - cleanlinessDecrease).clamp(0, 100),
          );
        }

        // 能量恢复（如果在睡觉）
        if (pet.currentActivity == PetActivity.sleeping) {
          final energyRestore = (timeSinceLastUpdate * 2).round();
          updatedPet = updatedPet.copyWith(
            energy: (pet.energy + energyRestore).clamp(0, 100),
          );
        } else {
          // 能量消耗
          final energyDecrease = (timeSinceLastUpdate * 0.3).round();
          updatedPet = updatedPet.copyWith(
            energy: (pet.energy - energyDecrease).clamp(0, 100),
          );
        }

        // 根据状态调整心情
        updatedPet = _adjustMoodBasedOnStats(updatedPet);

        // 根据状态调整活动
        updatedPet = _adjustActivityBasedOnStats(updatedPet);

        if (updatedPet != pet) {
          hasChanges = true;
          return updatedPet.copyWith(updatedAt: now);
        }

        return pet;
      }).toList();

      if (hasChanges) {
        await _saveAllPets(updatedPets);
      }
    } catch (e) {
      // 静默处理更新错误
    }
  }

  /// 根据属性调整心情
  PetEntity _adjustMoodBasedOnStats(PetEntity pet) {
    PetMood newMood = pet.mood;

    if (pet.health < 30 || pet.hunger > 80) {
      newMood = PetMood.sick;
    } else if (pet.energy < 20) {
      newMood = PetMood.sleepy;
    } else if (pet.hunger > 60) {
      newMood = PetMood.hungry;
    } else if (pet.happiness > 80 && pet.energy > 60) {
      newMood = PetMood.happy;
    } else if (pet.happiness < 30) {
      newMood = PetMood.sad;
    } else if (pet.cleanliness < 30) {
      newMood = PetMood.bored;
    } else {
      newMood = PetMood.calm;
    }

    return pet.copyWith(mood: newMood);
  }

  /// 根据属性调整活动
  PetEntity _adjustActivityBasedOnStats(PetEntity pet) {
    PetActivity newActivity = pet.currentActivity;

    if (pet.energy < 20) {
      newActivity = PetActivity.sleeping;
    } else if (pet.hunger > 70) {
      newActivity = PetActivity.eating;
    } else if (pet.happiness < 40) {
      newActivity = PetActivity.idle;
    } else if (pet.energy > 80 && pet.happiness > 60) {
      newActivity = PetActivity.playing;
    } else {
      newActivity = PetActivity.idle;
    }

    return pet.copyWith(currentActivity: newActivity);
  }

  /// 清除所有桌宠数据
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('pet_'))
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// 获取桌宠统计信息
  Future<PetStatistics> getPetStatistics() async {
    final pets = await getAllPets();

    if (pets.isEmpty) {
      return PetStatistics(
        totalPets: 0,
        activePets: 0,
        averageHealth: 0,
        averageHappiness: 0,
      );
    }

    final activePets = pets.where((pet) => pet.status != PetStatus.sick).length;
    final totalHealth = pets.fold<int>(0, (sum, pet) => sum + pet.health);
    final totalHappiness = pets.fold<int>(0, (sum, pet) => sum + pet.happiness);

    return PetStatistics(
      totalPets: pets.length,
      activePets: activePets,
      averageHealth: totalHealth ~/ pets.length,
      averageHappiness: totalHappiness ~/ pets.length,
    );
  }

  /// 释放资源
  void dispose() {
    stopSystem();
  }
}

/// 桌宠统计信息
class PetStatistics {
  final int totalPets;
  final int activePets;
  final int averageHealth;
  final int averageHappiness;

  const PetStatistics({
    required this.totalPets,
    required this.activePets,
    required this.averageHealth,
    required this.averageHappiness,
  });
}
