/*
---------------------------------------------------------------
File name:          pet_behavior_provider.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠行为管理Provider - 管理桌宠行为触发和执行
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../pet/models/pet_behavior.dart';
import '../pet/models/pet_entity.dart';
import '../pet/enums/pet_mood.dart';
import '../pet/enums/pet_activity.dart';

import 'pet_provider.dart';

/// 桌宠行为状态
class PetBehaviorState {
  /// 当前执行的行为
  final PetBehavior? currentBehavior;

  /// 行为队列
  final List<PetBehavior> behaviorQueue;

  /// 可用行为列表
  final List<PetBehavior> availableBehaviors;

  /// 行为执行历史
  final List<BehaviorExecution> executionHistory;

  /// 是否正在执行行为
  final bool isExecuting;

  /// 行为系统是否启用
  final bool isEnabled;

  /// 最后更新时间
  final DateTime lastUpdate;

  const PetBehaviorState({
    this.currentBehavior,
    this.behaviorQueue = const [],
    this.availableBehaviors = const [],
    this.executionHistory = const [],
    this.isExecuting = false,
    this.isEnabled = true,
    required this.lastUpdate,
  });

  /// 创建初始状态
  factory PetBehaviorState.initial() {
    return PetBehaviorState(lastUpdate: DateTime.now());
  }

  /// 复制并更新状态
  PetBehaviorState copyWith({
    PetBehavior? currentBehavior,
    List<PetBehavior>? behaviorQueue,
    List<PetBehavior>? availableBehaviors,
    List<BehaviorExecution>? executionHistory,
    bool? isExecuting,
    bool? isEnabled,
    DateTime? lastUpdate,
  }) {
    return PetBehaviorState(
      currentBehavior: currentBehavior ?? this.currentBehavior,
      behaviorQueue: behaviorQueue ?? this.behaviorQueue,
      availableBehaviors: availableBehaviors ?? this.availableBehaviors,
      executionHistory: executionHistory ?? this.executionHistory,
      isExecuting: isExecuting ?? this.isExecuting,
      isEnabled: isEnabled ?? this.isEnabled,
      lastUpdate: lastUpdate ?? DateTime.now(),
    );
  }

  /// 判断是否有待执行的行为
  bool get hasPendingBehaviors => behaviorQueue.isNotEmpty;

  /// 获取下一个行为
  PetBehavior? get nextBehavior =>
      behaviorQueue.isNotEmpty ? behaviorQueue.first : null;
}

/// 行为执行记录
class BehaviorExecution {
  final String behaviorId;
  final String petId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? errorMessage;
  final Map<String, dynamic> context;

  const BehaviorExecution({
    required this.behaviorId,
    required this.petId,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.errorMessage,
    this.context = const {},
  });

  /// 完成执行
  BehaviorExecution complete() {
    return BehaviorExecution(
      behaviorId: behaviorId,
      petId: petId,
      startTime: startTime,
      endTime: DateTime.now(),
      isCompleted: true,
      context: context,
    );
  }

  /// 执行失败
  BehaviorExecution fail(String error) {
    return BehaviorExecution(
      behaviorId: behaviorId,
      petId: petId,
      startTime: startTime,
      endTime: DateTime.now(),
      isCompleted: false,
      errorMessage: error,
      context: context,
    );
  }

  /// 获取执行时长
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

/// 桌宠行为提供者
final petBehaviorProvider =
    StateNotifierProvider<PetBehaviorNotifier, PetBehaviorState>((ref) {
      return PetBehaviorNotifier(ref);
    });

/// 当前执行行为提供者
final currentBehaviorProvider = Provider<PetBehavior?>((ref) {
  return ref.watch(petBehaviorProvider).currentBehavior;
});

/// 行为队列提供者
final behaviorQueueProvider = Provider<List<PetBehavior>>((ref) {
  return ref.watch(petBehaviorProvider).behaviorQueue;
});

/// 可用行为提供者
final availableBehaviorsProvider = Provider<List<PetBehavior>>((ref) {
  return ref.watch(petBehaviorProvider).availableBehaviors;
});

/// 桌宠行为通知器
class PetBehaviorNotifier extends StateNotifier<PetBehaviorState> {
  final Ref _ref;
  Timer? _behaviorTimer;

  PetBehaviorNotifier(this._ref) : super(PetBehaviorState.initial()) {
    _initialize();
  }

  /// 初始化行为系统
  Future<void> _initialize() async {
    try {
      // 加载默认行为
      await _loadDefaultBehaviors();

      // 启动行为检查定时器
      _startBehaviorTimer();
    } catch (e) {
      // 处理初始化错误
    }
  }

  /// 加载默认行为
  Future<void> _loadDefaultBehaviors() async {
    final defaultBehaviors = _createDefaultBehaviors();

    if (!mounted) return;
    state = state.copyWith(availableBehaviors: defaultBehaviors);
  }

  /// 创建默认行为
  List<PetBehavior> _createDefaultBehaviors() {
    return [
      // 基础生存行为
      PetBehavior.createDefault(
        id: 'auto_sleep',
        name: '自动睡觉',
        description: '当能量低时自动睡觉',
        priority: 8,
        duration: 300, // 5分钟
        tags: ['survival', 'auto'],
      ),

      PetBehavior.createDefault(
        id: 'auto_eat',
        name: '自动进食',
        description: '当饥饿时自动进食',
        priority: 9,
        duration: 60, // 1分钟
        tags: ['survival', 'auto'],
      ),

      // 社交行为
      PetBehavior.createDefault(
        id: 'greet_user',
        name: '问候用户',
        description: '用户回来时问候',
        priority: 6,
        duration: 30,
        tags: ['social', 'greeting'],
      ),

      PetBehavior.createDefault(
        id: 'request_attention',
        name: '请求关注',
        description: '长时间无互动时请求关注',
        priority: 5,
        duration: 45,
        tags: ['social', 'attention'],
      ),

      // 娱乐行为
      PetBehavior.createDefault(
        id: 'random_play',
        name: '随机玩耍',
        description: '心情好时随机玩耍',
        priority: 3,
        duration: 120,
        tags: ['entertainment', 'random'],
      ),

      PetBehavior.createDefault(
        id: 'explore_environment',
        name: '探索环境',
        description: '好奇时探索周围环境',
        priority: 4,
        duration: 90,
        tags: ['entertainment', 'exploration'],
      ),
    ];
  }

  /// 启动行为检查定时器
  void _startBehaviorTimer() {
    _behaviorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndTriggerBehaviors(),
    );
  }

  /// 检查并触发行为
  Future<void> _checkAndTriggerBehaviors() async {
    if (!state.isEnabled || state.isExecuting) return;

    final currentPet = _ref.read(currentPetProvider);
    if (currentPet == null) return;

    try {
      // 检查是否有可触发的行为
      final triggeredBehavior = await _findTriggeredBehavior(currentPet);
      if (triggeredBehavior != null) {
        await _executeBehavior(triggeredBehavior, currentPet);
      }
    } catch (e) {
      // 处理行为触发错误
    }
  }

  /// 查找可触发的行为
  Future<PetBehavior?> _findTriggeredBehavior(PetEntity pet) async {
    final context = _buildBehaviorContext(pet);

    // 按优先级排序可用行为
    final sortedBehaviors = List<PetBehavior>.from(state.availableBehaviors)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final behavior in sortedBehaviors) {
      if (_canTriggerBehavior(behavior, context)) {
        return behavior;
      }
    }

    return null;
  }

  /// 构建行为上下文
  Map<String, dynamic> _buildBehaviorContext(PetEntity pet) {
    return {
      'mood': pet.mood,
      'activity': pet.currentActivity,
      'status': pet.status,
      'health': pet.health,
      'energy': pet.energy,
      'hunger': pet.hunger,
      'happiness': pet.happiness,
      'cleanliness': pet.cleanliness,
      'lastInteraction': pet.lastInteraction,
      'lastFed': pet.lastFed,
      'lastCleaned': pet.lastCleaned,
    };
  }

  /// 检查行为是否可以触发
  bool _canTriggerBehavior(PetBehavior behavior, Map<String, dynamic> context) {
    // 检查基础条件
    switch (behavior.id) {
      case 'auto_sleep':
        return context['energy'] < 30;
      case 'auto_eat':
        return context['hunger'] > 70;
      case 'greet_user':
        final lastInteraction = context['lastInteraction'] as DateTime;
        return DateTime.now().difference(lastInteraction).inMinutes > 60;
      case 'request_attention':
        final lastInteraction = context['lastInteraction'] as DateTime;
        return DateTime.now().difference(lastInteraction).inMinutes > 120;
      case 'random_play':
        return context['happiness'] > 60 && context['energy'] > 50;
      case 'explore_environment':
        return context['mood'] == PetMood.curious;
      default:
        return false;
    }
  }

  /// 执行行为
  Future<void> _executeBehavior(PetBehavior behavior, PetEntity pet) async {
    if (!mounted) return;

    // 开始执行
    final execution = BehaviorExecution(
      behaviorId: behavior.id,
      petId: pet.id,
      startTime: DateTime.now(),
      context: _buildBehaviorContext(pet),
    );

    state = state.copyWith(
      currentBehavior: behavior,
      isExecuting: true,
      executionHistory: [...state.executionHistory, execution],
    );

    try {
      // 执行行为效果
      await _applyBehaviorEffects(behavior, pet);

      // 等待行为持续时间
      await Future.delayed(Duration(seconds: behavior.duration));

      if (!mounted) return;

      // 完成执行
      final completedExecution = execution.complete();
      final updatedHistory = state.executionHistory
          .map(
            (e) =>
                e.behaviorId == execution.behaviorId &&
                    e.startTime == execution.startTime
                ? completedExecution
                : e,
          )
          .toList();

      state = state.copyWith(
        currentBehavior: null,
        isExecuting: false,
        executionHistory: updatedHistory,
      );
    } catch (e) {
      if (!mounted) return;

      // 执行失败
      final failedExecution = execution.fail(e.toString());
      final updatedHistory = state.executionHistory
          .map(
            (e) =>
                e.behaviorId == execution.behaviorId &&
                    e.startTime == execution.startTime
                ? failedExecution
                : e,
          )
          .toList();

      state = state.copyWith(
        currentBehavior: null,
        isExecuting: false,
        executionHistory: updatedHistory,
      );
    }
  }

  /// 应用行为效果
  Future<void> _applyBehaviorEffects(
    PetBehavior behavior,
    PetEntity pet,
  ) async {
    final petNotifier = _ref.read(petProvider.notifier);

    switch (behavior.id) {
      case 'auto_sleep':
        await petNotifier.updatePetActivity(pet.id, PetActivity.sleeping);
        await petNotifier.updatePetMood(pet.id, PetMood.sleepy);
        break;
      case 'auto_eat':
        await petNotifier.feedPet(pet.id);
        await petNotifier.updatePetActivity(pet.id, PetActivity.eating);
        break;
      case 'greet_user':
        await petNotifier.updatePetMood(pet.id, PetMood.happy);
        await petNotifier.updatePetActivity(pet.id, PetActivity.socializing);
        break;
      case 'request_attention':
        await petNotifier.updatePetMood(pet.id, PetMood.bored);
        await petNotifier.updatePetActivity(pet.id, PetActivity.idle);
        break;
      case 'random_play':
        await petNotifier.playWithPet(pet.id);
        await petNotifier.updatePetMood(pet.id, PetMood.excited);
        break;
      case 'explore_environment':
        await petNotifier.updatePetActivity(pet.id, PetActivity.exploring);
        await petNotifier.updatePetMood(pet.id, PetMood.curious);
        break;
    }
  }

  /// 手动触发行为
  Future<void> triggerBehavior(String behaviorId, String petId) async {
    final behavior = state.availableBehaviors.firstWhere(
      (b) => b.id == behaviorId,
      orElse: () => throw Exception('行为不存在: $behaviorId'),
    );

    final pet = _ref.read(currentPetProvider);
    if (pet == null || pet.id != petId) {
      throw Exception('桌宠不存在或不匹配');
    }

    await _executeBehavior(behavior, pet);
  }

  /// 添加自定义行为
  void addBehavior(PetBehavior behavior) {
    final updatedBehaviors = [...state.availableBehaviors, behavior];
    state = state.copyWith(availableBehaviors: updatedBehaviors);
  }

  /// 移除行为
  void removeBehavior(String behaviorId) {
    final updatedBehaviors = state.availableBehaviors
        .where((b) => b.id != behaviorId)
        .toList();
    state = state.copyWith(availableBehaviors: updatedBehaviors);
  }

  /// 启用/禁用行为系统
  void setBehaviorSystemEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);

    if (!enabled) {
      _behaviorTimer?.cancel();
    } else {
      _startBehaviorTimer();
    }
  }

  /// 清除执行历史
  void clearExecutionHistory() {
    state = state.copyWith(executionHistory: []);
  }

  @override
  void dispose() {
    _behaviorTimer?.cancel();
    super.dispose();
  }
}
