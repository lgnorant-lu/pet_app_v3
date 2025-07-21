/*
---------------------------------------------------------------
File name:          pet_provider.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠状态管理 - 使用Riverpod管理桌宠的状态
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_pet/src/models/index.dart';
import 'package:desktop_pet/src/services/pet_service.dart';
import 'package:desktop_pet/src/repositories/index.dart';
import 'package:desktop_pet/src/core/ai_engine.dart';
import 'package:desktop_pet/src/core/lifecycle_manager.dart';

/// 桌宠仓库提供者
final Provider<PetRepository> petRepositoryProvider =
    Provider<PetRepository>((ProviderRef<PetRepository> ref) {
  final repository = PetRepository();
  repository.initialize();
  return repository;
});

/// AI引擎提供者
final Provider<PetAIEngine> aiEngineProvider =
    Provider<PetAIEngine>((ProviderRef<PetAIEngine> ref) {
  final engine = PetAIEngine();
  engine.initialize();
  return engine;
});

/// 生命周期管理器提供者
final Provider<PetLifecycleManager> lifecycleManagerProvider =
    Provider<PetLifecycleManager>((ProviderRef<PetLifecycleManager> ref) {
  final manager = PetLifecycleManager();
  manager.start();
  return manager;
});

/// 桌宠服务提供者
final Provider<PetService> petServiceProvider = Provider<PetService>(
  (ProviderRef<PetService> ref) => PetService(
    repository: ref.watch(petRepositoryProvider),
    aiEngine: ref.watch(aiEngineProvider),
    lifecycleManager: ref.watch(lifecycleManagerProvider),
  ),
);

/// 桌宠状态提供者
final StateNotifierProvider<PetStateNotifier, PetState> petStateProvider =
    StateNotifierProvider<PetStateNotifier, PetState>(
        (StateNotifierProviderRef<PetStateNotifier, PetState> ref) =>
            PetStateNotifier(ref.watch(petServiceProvider)));

/// 当前选中桌宠提供者
final StateProvider<PetEntity?> currentPetProvider =
    StateProvider<PetEntity?>((StateProviderRef<PetEntity?> ref) => null);

/// 桌宠列表提供者
final FutureProvider<List<PetEntity>> petListProvider =
    FutureProvider<List<PetEntity>>(
        (FutureProviderRef<List<PetEntity>> ref) async {
  final service = ref.watch(petServiceProvider);
  return service.getAllPets();
});

/// 特定桌宠提供者
final FutureProviderFamily<PetEntity?, String> petByIdProvider =
    FutureProvider.family<PetEntity?, String>(
        (FutureProviderRef<PetEntity?> ref, String id) async {
  final service = ref.watch(petServiceProvider);
  return service.getPetById(id);
});

/// 桌宠统计提供者
final FutureProviderFamily<PetStats, String> petStatsProvider =
    FutureProvider.family<PetStats, String>(
        (FutureProviderRef<PetStats> ref, String petId) async {
  final service = ref.watch(petServiceProvider);
  return service.getPetStats(petId);
});

/// 桌宠数量统计提供者
final FutureProvider<PetCountStats> petCountStatsProvider =
    FutureProvider<PetCountStats>((FutureProviderRef<PetCountStats> ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getPetCountStats();
});

/// 桌宠历史数据提供者
final FutureProviderFamily<PetHistoryData, String> petHistoryProvider =
    FutureProvider.family<PetHistoryData, String>(
        (FutureProviderRef<PetHistoryData> ref, String petId) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getPetHistory(petId);
});

/// 桌宠状态通知器
class PetStateNotifier extends StateNotifier<PetState> {
  PetStateNotifier(this._petService) : super(PetState.initial()) {
    _loadInitialData();
  }
  final PetService _petService;

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    try {
      state = PetState.loading();
      final pets = await _petService.getAllPets();

      state = state.copyWith(
        pets: pets,
        currentPet: pets.isNotEmpty ? pets.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = PetState.error(e.toString());
    }
  }

  /// 刷新桌宠列表
  Future<void> refreshPets() async {
    try {
      state = state.copyWith(isLoading: true);
      final pets = await _petService.getAllPets();

      state = state.copyWith(
        pets: pets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
    try {
      state = state.copyWith(isLoading: true);

      final newPet = await _petService.createPet(
        name: name,
        type: type,
        breed: breed,
        color: color,
        gender: gender,
      );

      final updatedPets = <PetEntity>[...state.pets, newPet];

      state = state.copyWith(
        pets: updatedPets,
        currentPet: newPet,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 更新桌宠
  Future<void> updatePet(PetEntity pet) async {
    try {
      final updatedPet = await _petService.updatePet(pet);

      final updatedPets = state.pets
          .map((PetEntity p) => p.id == updatedPet.id ? updatedPet : p)
          .toList();

      state = state.copyWith(
        pets: updatedPets,
        currentPet: state.currentPet?.id == updatedPet.id
            ? updatedPet
            : state.currentPet,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 删除桌宠
  Future<void> deletePet(String petId) async {
    try {
      state = state.copyWith(isLoading: true);

      await _petService.deletePet(petId);

      final updatedPets =
          state.pets.where((PetEntity p) => p.id != petId).toList();
      final newCurrentPet = state.currentPet?.id == petId
          ? (updatedPets.isNotEmpty ? updatedPets.first : null)
          : state.currentPet;

      state = state.copyWith(
        pets: updatedPets,
        currentPet: newCurrentPet,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 选择当前桌宠
  void selectPet(PetEntity? pet) {
    state = state.copyWith(currentPet: pet);
  }

  /// 喂食桌宠
  Future<void> feedPet(String petId) async {
    try {
      final updatedPet = await _petService.feedPet(petId);
      await _updatePetInState(updatedPet);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清洁桌宠
  Future<void> cleanPet(String petId) async {
    try {
      final updatedPet = await _petService.cleanPet(petId);
      await _updatePetInState(updatedPet);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 与桌宠互动
  Future<void> interactWithPet(String petId, String interactionType) async {
    try {
      final updatedPet =
          await _petService.interactWithPet(petId, interactionType);
      await _updatePetInState(updatedPet);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 执行桌宠行为
  Future<void> executeBehavior(String petId, PetBehavior behavior) async {
    try {
      final updatedPet = await _petService.executeBehavior(petId, behavior);
      await _updatePetInState(updatedPet);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 切换桌宠系统启用状态
  void togglePetSystem() {
    state = state.copyWith(isEnabled: !state.isEnabled);
  }

  /// 切换桌宠可见性
  void togglePetVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// 设置交互模式
  void setInteractionMode(PetInteractionMode mode) {
    state = state.copyWith(interactionMode: mode);
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith();
  }

  /// 在状态中更新桌宠
  Future<void> _updatePetInState(PetEntity updatedPet) async {
    final updatedPets = state.pets
        .map((PetEntity p) => p.id == updatedPet.id ? updatedPet : p)
        .toList();

    state = state.copyWith(
      pets: updatedPets,
      currentPet:
          state.currentPet?.id == updatedPet.id ? updatedPet : state.currentPet,
    );
  }
}

/// 桌宠行为提供者
final StateNotifierProvider<PetBehaviorNotifier, PetBehaviorState>
    petBehaviorProvider =
    StateNotifierProvider<PetBehaviorNotifier, PetBehaviorState>(
        (StateNotifierProviderRef<PetBehaviorNotifier, PetBehaviorState> ref) =>
            PetBehaviorNotifier());

/// 桌宠行为状态
class PetBehaviorState {
  const PetBehaviorState({
    this.availableBehaviors = const <PetBehavior>[],
    this.currentBehavior,
    this.isExecuting = false,
    this.error,
  });
  final List<PetBehavior> availableBehaviors;
  final PetBehavior? currentBehavior;
  final bool isExecuting;
  final String? error;

  PetBehaviorState copyWith({
    List<PetBehavior>? availableBehaviors,
    PetBehavior? currentBehavior,
    bool? isExecuting,
    String? error,
  }) =>
      PetBehaviorState(
        availableBehaviors: availableBehaviors ?? this.availableBehaviors,
        currentBehavior: currentBehavior ?? this.currentBehavior,
        isExecuting: isExecuting ?? this.isExecuting,
        error: error,
      );
}

/// 桌宠行为通知器
class PetBehaviorNotifier extends StateNotifier<PetBehaviorState> {
  PetBehaviorNotifier() : super(const PetBehaviorState()) {
    _loadDefaultBehaviors();
  }

  /// 加载默认行为
  void _loadDefaultBehaviors() {
    final defaultBehaviors = <PetBehavior>[
      PetBehavior.createDefault(
        id: 'idle',
        name: '空闲',
        description: '桌宠处于空闲状态',
        tags: <String>['basic', 'idle'],
      ),
      PetBehavior.createDefault(
        id: 'play',
        name: '玩耍',
        description: '桌宠开始玩耍',
        tags: <String>['entertainment', 'active'],
      ),
      PetBehavior.createDefault(
        id: 'sleep',
        name: '睡觉',
        description: '桌宠开始休息',
        tags: <String>['rest', 'recovery'],
      ),
      PetBehavior.createDefault(
        id: 'eat',
        name: '吃东西',
        description: '桌宠开始进食',
        tags: <String>['food', 'survival'],
      ),
    ];

    state = state.copyWith(availableBehaviors: defaultBehaviors);
  }

  /// 添加行为
  void addBehavior(PetBehavior behavior) {
    final updatedBehaviors = <PetBehavior>[
      ...state.availableBehaviors,
      behavior
    ];
    state = state.copyWith(availableBehaviors: updatedBehaviors);
  }

  /// 移除行为
  void removeBehavior(String behaviorId) {
    final updatedBehaviors = state.availableBehaviors
        .where((PetBehavior b) => b.id != behaviorId)
        .toList();
    state = state.copyWith(availableBehaviors: updatedBehaviors);
  }

  /// 设置当前行为
  void setCurrentBehavior(PetBehavior? behavior) {
    state = state.copyWith(currentBehavior: behavior);
  }

  /// 开始执行行为
  void startExecuting() {
    state = state.copyWith(isExecuting: true);
  }

  /// 完成执行行为
  void finishExecuting() {
    state = state.copyWith(isExecuting: false);
  }

  /// 设置错误
  void setError(String error) {
    state = state.copyWith(error: error, isExecuting: false);
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith();
  }
}
