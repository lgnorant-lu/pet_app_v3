/*
---------------------------------------------------------------
File name:          pet_state.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠状态模型 - 管理桌宠的实时状态和状态变化
---------------------------------------------------------------
*/

import 'package:desktop_pet/src/models/enums/index.dart';
import 'package:desktop_pet/src/models/pet_entity.dart';

/// 桌宠状态模型
///
/// 管理桌宠的实时状态和状态变化
class PetState {

  const PetState({
    required this.lastUpdate, this.currentPet,
    this.pets = const <PetEntity>[],
    this.isLoading = false,
    this.error,
    this.isEnabled = true,
    this.isVisible = true,
    this.interactionMode = PetInteractionMode.normal,
  });

  /// 创建初始状态
  factory PetState.initial() => PetState(lastUpdate: DateTime.now());

  /// 创建加载状态
  factory PetState.loading() => PetState(
      isLoading: true,
      lastUpdate: DateTime.now(),
    );

  /// 创建错误状态
  factory PetState.error(String error) => PetState(
      error: error,
      lastUpdate: DateTime.now(),
    );
  /// 当前桌宠实体
  final PetEntity? currentPet;

  /// 所有桌宠列表
  final List<PetEntity> pets;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 桌宠系统是否启用
  final bool isEnabled;

  /// 桌宠是否可见
  final bool isVisible;

  /// 桌宠交互模式
  final PetInteractionMode interactionMode;

  /// 最后更新时间
  final DateTime lastUpdate;

  /// 复制并更新状态
  PetState copyWith({
    PetEntity? currentPet,
    List<PetEntity>? pets,
    bool? isLoading,
    String? error,
    bool? isEnabled,
    bool? isVisible,
    PetInteractionMode? interactionMode,
    DateTime? lastUpdate,
  }) => PetState(
      currentPet: currentPet ?? this.currentPet,
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEnabled: isEnabled ?? this.isEnabled,
      isVisible: isVisible ?? this.isVisible,
      interactionMode: interactionMode ?? this.interactionMode,
      lastUpdate: lastUpdate ?? DateTime.now(),
    );

  /// 判断是否有活跃的桌宠
  bool get hasActivePet => currentPet != null && currentPet!.status.isActive;

  /// 判断是否有桌宠
  bool get hasPets => pets.isNotEmpty;

  /// 获取活跃桌宠数量
  int get activePetCount => pets.where((PetEntity pet) => pet.status.isActive).length;

  /// 获取需要关注的桌宠数量
  int get petsNeedingAttention => pets.where((PetEntity pet) => pet.needsAttention).length;

  /// 判断桌宠系统是否可用
  bool get isAvailable => isEnabled && !isLoading && error == null;

  /// 获取桌宠系统状态描述
  String get statusDescription {
    if (!isEnabled) return '桌宠系统已禁用';
    if (isLoading) return '正在加载桌宠...';
    if (error != null) return '桌宠系统错误: $error';
    if (!hasPets) return '暂无桌宠';
    if (!hasActivePet) return '桌宠未激活';
    return '桌宠系统正常';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetState &&
        other.currentPet == currentPet &&
        other.pets.length == pets.length &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isEnabled == isEnabled &&
        other.isVisible == isVisible &&
        other.interactionMode == interactionMode;
  }

  @override
  int get hashCode => Object.hash(
      currentPet,
      pets.length,
      isLoading,
      error,
      isEnabled,
      isVisible,
      interactionMode,
    );

  @override
  String toString() => 'PetState('
        'currentPet: ${currentPet?.name}, '
        'pets: ${pets.length}, '
        'isLoading: $isLoading, '
        'error: $error, '
        'isEnabled: $isEnabled'
        ')';
}
