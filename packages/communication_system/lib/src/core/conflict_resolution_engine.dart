/*
---------------------------------------------------------------
File name:          conflict_resolution_engine.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.4 冲突解决引擎 - 模块间资源和状态冲突处理
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.4 - 实现冲突检测、解决策略、仲裁机制;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'unified_message_bus.dart';
import 'module_communication_coordinator.dart' as comm;
// import 'data_sync_manager.dart'; // 暂时未使用

/// 冲突类型
enum ConflictType {
  /// 资源访问冲突
  resourceAccess,

  /// 数据状态冲突
  dataState,

  /// 优先级冲突
  priority,

  /// 依赖冲突
  dependency,

  /// 配置冲突
  configuration,

  /// 生命周期冲突
  lifecycle,
}

/// 冲突严重程度
enum ConflictSeverity {
  /// 低 - 可以忽略或自动解决
  low(1),

  /// 中等 - 需要策略解决
  medium(2),

  /// 高 - 需要立即处理
  high(3),

  /// 严重 - 可能导致系统不稳定
  critical(4);

  const ConflictSeverity(this.level);
  final int level;
}

/// 冲突解决状态
enum ConflictResolutionStatus {
  /// 检测到冲突
  detected,

  /// 解决中
  resolving,

  /// 已解决
  resolved,

  /// 解决失败
  failed,

  /// 需要手动干预
  manualIntervention,

  /// 已忽略
  ignored,
}

/// 冲突记录
class ConflictRecord {
  const ConflictRecord({
    required this.id,
    required this.type,
    required this.severity,
    required this.involvedModules,
    required this.resourceId,
    required this.detectedAt,
    required this.description,
    this.metadata = const {},
    this.status = ConflictResolutionStatus.detected,
    this.resolvedAt,
    this.resolutionStrategy,
    this.resolutionDetails,
  });

  /// 冲突ID
  final String id;

  /// 冲突类型
  final ConflictType type;

  /// 严重程度
  final ConflictSeverity severity;

  /// 涉及的模块
  final List<String> involvedModules;

  /// 资源ID
  final String resourceId;

  /// 检测时间
  final DateTime detectedAt;

  /// 冲突描述
  final String description;

  /// 元数据
  final Map<String, dynamic> metadata;

  /// 解决状态
  final ConflictResolutionStatus status;

  /// 解决时间
  final DateTime? resolvedAt;

  /// 解决策略
  final String? resolutionStrategy;

  /// 解决详情
  final Map<String, dynamic>? resolutionDetails;

  /// 创建已解决的冲突记录
  ConflictRecord resolve({
    required String strategy,
    required Map<String, dynamic> details,
  }) {
    return ConflictRecord(
      id: id,
      type: type,
      severity: severity,
      involvedModules: involvedModules,
      resourceId: resourceId,
      detectedAt: detectedAt,
      description: description,
      metadata: metadata,
      status: ConflictResolutionStatus.resolved,
      resolvedAt: DateTime.now(),
      resolutionStrategy: strategy,
      resolutionDetails: details,
    );
  }

  /// 创建失败的冲突记录
  ConflictRecord fail({required String reason}) {
    return ConflictRecord(
      id: id,
      type: type,
      severity: severity,
      involvedModules: involvedModules,
      resourceId: resourceId,
      detectedAt: detectedAt,
      description: description,
      metadata: metadata,
      status: ConflictResolutionStatus.failed,
      resolutionDetails: {'failureReason': reason},
    );
  }

  /// 是否已解决
  bool get isResolved => status == ConflictResolutionStatus.resolved;

  /// 是否需要手动干预
  bool get needsManualIntervention =>
      status == ConflictResolutionStatus.manualIntervention;

  /// 解决耗时（毫秒）
  int? get resolutionTimeMs {
    if (resolvedAt != null) {
      return resolvedAt!.difference(detectedAt).inMilliseconds;
    }
    return null;
  }

  @override
  String toString() {
    return 'ConflictRecord(id: $id, type: $type, severity: $severity, '
        'modules: $involvedModules, resource: $resourceId, status: $status)';
  }
}

/// 冲突解决策略接口
abstract class ConflictResolutionStrategy {
  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 支持的冲突类型
  Set<ConflictType> get supportedTypes;

  /// 策略优先级（数值越高优先级越高）
  int get priority;

  /// 是否可以处理此冲突
  bool canHandle(ConflictRecord conflict);

  /// 解决冲突
  Future<ConflictRecord> resolve(ConflictRecord conflict);
}

/// 优先级策略 - 根据模块优先级解决冲突
class PriorityBasedStrategy extends ConflictResolutionStrategy {
  @override
  String get name => 'PriorityBased';

  @override
  String get description => '基于模块优先级的冲突解决策略';

  @override
  Set<ConflictType> get supportedTypes => {
    ConflictType.resourceAccess,
    ConflictType.priority,
    ConflictType.configuration,
  };

  @override
  int get priority => 80;

  @override
  bool canHandle(ConflictRecord conflict) {
    return supportedTypes.contains(conflict.type);
  }

  @override
  Future<ConflictRecord> resolve(ConflictRecord conflict) async {
    try {
      // 获取模块优先级信息
      final coordinator = comm.ModuleCommunicationCoordinator.instance;
      final moduleInfos = <String, comm.ModuleInfo>{};

      for (final moduleId in conflict.involvedModules) {
        final info = coordinator.getModuleInfo(moduleId);
        if (info != null) {
          moduleInfos[moduleId] = info;
        }
      }

      // 按优先级排序
      final sortedModules = conflict.involvedModules.toList()
        ..sort((a, b) {
          final priorityA = moduleInfos[a]?.priority ?? 0;
          final priorityB = moduleInfos[b]?.priority ?? 0;
          return priorityB.compareTo(priorityA); // 降序排列
        });

      final winnerModule = sortedModules.first;

      return conflict.resolve(
        strategy: name,
        details: {
          'winnerModule': winnerModule,
          'modulePriorities': moduleInfos.map(
            (id, info) => MapEntry(id, info.priority),
          ),
          'resolutionMethod': 'highest_priority_wins',
        },
      );
    } catch (e) {
      return conflict.fail(reason: 'Priority resolution failed: $e');
    }
  }
}

/// 时间戳策略 - 最后写入获胜
class TimestampBasedStrategy extends ConflictResolutionStrategy {
  @override
  String get name => 'TimestampBased';

  @override
  String get description => '基于时间戳的冲突解决策略（最后写入获胜）';

  @override
  Set<ConflictType> get supportedTypes => {
    ConflictType.dataState,
    ConflictType.configuration,
  };

  @override
  int get priority => 70;

  @override
  bool canHandle(ConflictRecord conflict) {
    return supportedTypes.contains(conflict.type) &&
        conflict.metadata.containsKey('timestamps');
  }

  @override
  Future<ConflictRecord> resolve(ConflictRecord conflict) async {
    try {
      final timestamps =
          conflict.metadata['timestamps'] as Map<String, dynamic>;

      // 找到最新的时间戳
      String? latestModule;
      DateTime? latestTime;

      for (final entry in timestamps.entries) {
        final timestamp = DateTime.parse(entry.value as String);
        if (latestTime == null || timestamp.isAfter(latestTime)) {
          latestTime = timestamp;
          latestModule = entry.key;
        }
      }

      return conflict.resolve(
        strategy: name,
        details: {
          'winnerModule': latestModule,
          'winnerTimestamp': latestTime?.toIso8601String(),
          'allTimestamps': timestamps,
          'resolutionMethod': 'last_write_wins',
        },
      );
    } catch (e) {
      return conflict.fail(reason: 'Timestamp resolution failed: $e');
    }
  }
}

/// 轮询策略 - 公平轮询访问资源
class RoundRobinStrategy extends ConflictResolutionStrategy {
  static final Map<String, int> _resourceCounters = {};

  @override
  String get name => 'RoundRobin';

  @override
  String get description => '轮询策略，公平分配资源访问权';

  @override
  Set<ConflictType> get supportedTypes => {ConflictType.resourceAccess};

  @override
  int get priority => 60;

  @override
  bool canHandle(ConflictRecord conflict) {
    return supportedTypes.contains(conflict.type);
  }

  @override
  Future<ConflictRecord> resolve(ConflictRecord conflict) async {
    try {
      final resourceId = conflict.resourceId;
      final currentCounter = _resourceCounters[resourceId] ?? 0;
      final moduleIndex = currentCounter % conflict.involvedModules.length;
      final winnerModule = conflict.involvedModules[moduleIndex];

      // 更新计数器
      _resourceCounters[resourceId] = currentCounter + 1;

      return conflict.resolve(
        strategy: name,
        details: {
          'winnerModule': winnerModule,
          'roundRobinIndex': moduleIndex,
          'totalModules': conflict.involvedModules.length,
          'resolutionMethod': 'round_robin',
        },
      );
    } catch (e) {
      return conflict.fail(reason: 'Round robin resolution failed: $e');
    }
  }
}

/// 随机策略 - 随机选择获胜者
class RandomStrategy extends ConflictResolutionStrategy {
  final Random _random = Random();

  @override
  String get name => 'Random';

  @override
  String get description => '随机选择策略，随机选择一个模块作为获胜者';

  @override
  Set<ConflictType> get supportedTypes => ConflictType.values.toSet();

  @override
  int get priority => 10; // 最低优先级，作为兜底策略

  @override
  bool canHandle(ConflictRecord conflict) => true;

  @override
  Future<ConflictRecord> resolve(ConflictRecord conflict) async {
    try {
      final randomIndex = _random.nextInt(conflict.involvedModules.length);
      final winnerModule = conflict.involvedModules[randomIndex];

      return conflict.resolve(
        strategy: name,
        details: {
          'winnerModule': winnerModule,
          'randomIndex': randomIndex,
          'totalModules': conflict.involvedModules.length,
          'resolutionMethod': 'random_selection',
        },
      );
    } catch (e) {
      return conflict.fail(reason: 'Random resolution failed: $e');
    }
  }
}

/// 冲突解决引擎
///
/// Phase 3.2.4 核心功能：
/// - 冲突检测和分类
/// - 多种解决策略
/// - 策略优先级管理
/// - 解决过程监控
/// - 性能统计和分析
class ConflictResolutionEngine {
  ConflictResolutionEngine._();

  static final ConflictResolutionEngine _instance =
      ConflictResolutionEngine._();
  static ConflictResolutionEngine get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 通信协调器 (暂时未使用)
  // final comm.ModuleCommunicationCoordinator _coordinator =
  //     comm.ModuleCommunicationCoordinator.instance;

  /// 解决策略
  final List<ConflictResolutionStrategy> _strategies = [];

  /// 冲突记录
  final Map<String, ConflictRecord> _conflicts = {};

  /// 解决统计
  final Map<String, int> _resolutionStats = {};

  /// 性能统计
  final Map<String, List<int>> _performanceStats = {};

  /// 冲突ID计数器
  int _conflictIdCounter = 0;

  /// 初始化冲突解决引擎
  void initialize() {
    // 注册默认策略
    _registerDefaultStrategies();

    // 订阅冲突相关消息
    _messageBus.subscribe(_handleConflictMessage);

    debugPrint('ConflictResolutionEngine initialized');
  }

  /// 注册默认策略
  void _registerDefaultStrategies() {
    addStrategy(PriorityBasedStrategy());
    addStrategy(TimestampBasedStrategy());
    addStrategy(RoundRobinStrategy());
    addStrategy(RandomStrategy()); // 兜底策略
  }

  /// 添加解决策略
  void addStrategy(ConflictResolutionStrategy strategy) {
    _strategies.add(strategy);
    // 按优先级排序
    _strategies.sort((a, b) => b.priority.compareTo(a.priority));
    debugPrint('Added conflict resolution strategy: ${strategy.name}');
  }

  /// 移除解决策略
  void removeStrategy(String strategyName) {
    _strategies.removeWhere((strategy) => strategy.name == strategyName);
    debugPrint('Removed conflict resolution strategy: $strategyName');
  }

  /// 生成冲突ID
  String _generateConflictId() {
    return 'conflict_${DateTime.now().millisecondsSinceEpoch}_${++_conflictIdCounter}';
  }

  /// 检测并报告冲突
  Future<ConflictRecord> detectConflict({
    required ConflictType type,
    required ConflictSeverity severity,
    required List<String> involvedModules,
    required String resourceId,
    required String description,
    Map<String, dynamic> metadata = const {},
  }) async {
    final conflict = ConflictRecord(
      id: _generateConflictId(),
      type: type,
      severity: severity,
      involvedModules: involvedModules,
      resourceId: resourceId,
      detectedAt: DateTime.now(),
      description: description,
      metadata: metadata,
    );

    _conflicts[conflict.id] = conflict;

    // 发布冲突检测事件
    _messageBus.publishEvent(
      'conflict_engine',
      'conflict_detected',
      {
        'conflictId': conflict.id,
        'type': conflict.type.name,
        'severity': conflict.severity.name,
        'involvedModules': conflict.involvedModules,
        'resourceId': conflict.resourceId,
        'description': conflict.description,
      },
      priority: _getMessagePriority(conflict.severity),
    );

    // 根据严重程度决定是否立即解决
    if (conflict.severity.level >= ConflictSeverity.high.level) {
      await resolveConflict(conflict.id);
    }

    debugPrint('Conflict detected: $conflict');
    return conflict;
  }

  /// 解决冲突
  Future<ConflictRecord?> resolveConflict(String conflictId) async {
    final conflict = _conflicts[conflictId];
    if (conflict == null) {
      debugPrint('Conflict not found: $conflictId');
      return null;
    }

    if (conflict.isResolved) {
      debugPrint('Conflict already resolved: $conflictId');
      return conflict;
    }

    final startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      // 更新冲突状态为解决中
      _conflicts[conflictId] = ConflictRecord(
        id: conflict.id,
        type: conflict.type,
        severity: conflict.severity,
        involvedModules: conflict.involvedModules,
        resourceId: conflict.resourceId,
        detectedAt: conflict.detectedAt,
        description: conflict.description,
        metadata: conflict.metadata,
        status: ConflictResolutionStatus.resolving,
      );

      // 查找合适的策略
      ConflictResolutionStrategy? selectedStrategy;
      for (final strategy in _strategies) {
        if (strategy.canHandle(conflict)) {
          selectedStrategy = strategy;
          break;
        }
      }

      if (selectedStrategy == null) {
        final failedConflict = conflict.fail(
          reason: 'No suitable strategy found',
        );
        _conflicts[conflictId] = failedConflict;
        _updateResolutionStats('no_strategy');
        return failedConflict;
      }

      // 执行解决策略
      final resolvedConflict = await selectedStrategy.resolve(conflict);
      _conflicts[conflictId] = resolvedConflict;

      // 发布解决结果事件
      _messageBus.publishEvent(
        'conflict_engine',
        'conflict_resolved',
        {
          'conflictId': resolvedConflict.id,
          'status': resolvedConflict.status.name,
          'strategy': resolvedConflict.resolutionStrategy,
          'details': resolvedConflict.resolutionDetails,
          'resolutionTimeMs': resolvedConflict.resolutionTimeMs,
        },
        priority: _getMessagePriority(conflict.severity),
      );

      // 更新统计
      if (resolvedConflict.isResolved) {
        _updateResolutionStats('resolved');
        _updateResolutionStats('strategy_${selectedStrategy.name}');
      } else {
        _updateResolutionStats('failed');
      }

      // 更新性能统计
      final processingTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _updatePerformanceStats(selectedStrategy.name, processingTime);

      debugPrint('Conflict resolution completed: $resolvedConflict');
      return resolvedConflict;
    } catch (e, stackTrace) {
      debugPrint('Error resolving conflict $conflictId: $e');
      debugPrint('Stack trace: $stackTrace');

      final failedConflict = conflict.fail(reason: 'Resolution error: $e');
      _conflicts[conflictId] = failedConflict;
      _updateResolutionStats('error');

      return failedConflict;
    }
  }

  /// 处理冲突相关消息
  Future<Map<String, dynamic>?> _handleConflictMessage(
    UnifiedMessage message,
  ) async {
    if (message.action.startsWith('conflict_')) {
      // 处理冲突相关的消息
      debugPrint('Handling conflict message: ${message.action}');
    }
    return null;
  }

  /// 获取消息优先级
  MessagePriority _getMessagePriority(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return MessagePriority.low;
      case ConflictSeverity.medium:
        return MessagePriority.normal;
      case ConflictSeverity.high:
        return MessagePriority.high;
      case ConflictSeverity.critical:
        return MessagePriority.urgent;
    }
  }

  /// 更新解决统计
  void _updateResolutionStats(String action) {
    _resolutionStats[action] = (_resolutionStats[action] ?? 0) + 1;
  }

  /// 更新性能统计
  void _updatePerformanceStats(String strategy, int processingTime) {
    _performanceStats.putIfAbsent(strategy, () => []);
    _performanceStats[strategy]!.add(processingTime);

    // 保持最近100条记录
    if (_performanceStats[strategy]!.length > 100) {
      _performanceStats[strategy]!.removeAt(0);
    }
  }

  /// 获取冲突记录
  ConflictRecord? getConflict(String conflictId) => _conflicts[conflictId];

  /// 获取所有冲突记录
  List<ConflictRecord> getAllConflicts() =>
      List.unmodifiable(_conflicts.values);

  /// 获取未解决的冲突
  List<ConflictRecord> getUnresolvedConflicts() {
    return _conflicts.values.where((conflict) => !conflict.isResolved).toList();
  }

  /// 获取解决策略列表
  List<ConflictResolutionStrategy> get strategies =>
      List.unmodifiable(_strategies);

  /// 获取解决统计
  Map<String, int> get resolutionStats => Map.unmodifiable(_resolutionStats);

  /// 获取性能统计
  Map<String, double> getPerformanceStats() {
    final Map<String, double> avgStats = {};

    for (final entry in _performanceStats.entries) {
      if (entry.value.isNotEmpty) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        avgStats[entry.key] = avg;
      }
    }

    return avgStats;
  }

  /// 清理资源
  void dispose() {
    _strategies.clear();
    _conflicts.clear();
    _resolutionStats.clear();
    _performanceStats.clear();

    debugPrint('ConflictResolutionEngine disposed');
  }
}
