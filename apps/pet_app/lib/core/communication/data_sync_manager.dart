/*
---------------------------------------------------------------
File name:          data_sync_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.3 数据同步管理器 - 模块间数据同步
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.3 - 实现数据同步机制，支持实时和批量同步;
---------------------------------------------------------------
*/

import 'dart:async';
// import 'dart:convert'; // 暂时未使用
import 'package:flutter/foundation.dart';
import 'unified_message_bus.dart';
// import 'module_communication_coordinator.dart' as comm; // 暂时未使用

/// 同步策略
enum SyncStrategy {
  /// 实时同步 - 立即同步数据变更
  realtime,

  /// 批量同步 - 定期批量同步
  batch,

  /// 按需同步 - 仅在请求时同步
  onDemand,

  /// 冲突解决同步 - 检测并解决冲突后同步
  conflictResolution,
}

/// 同步状态
enum SyncStatus {
  /// 同步中
  syncing,

  /// 同步成功
  success,

  /// 同步失败
  failed,

  /// 有冲突
  conflict,

  /// 已取消
  cancelled,
}

/// 数据变更类型
enum DataChangeType {
  /// 创建
  create,

  /// 更新
  update,

  /// 删除
  delete,

  /// 批量操作
  batch,
}

/// 数据变更记录
class DataChange {
  const DataChange({
    required this.id,
    required this.moduleId,
    required this.dataKey,
    required this.changeType,
    required this.timestamp,
    this.oldValue,
    this.newValue,
    this.metadata = const {},
  });

  /// 变更ID
  final String id;

  /// 模块ID
  final String moduleId;

  /// 数据键
  final String dataKey;

  /// 变更类型
  final DataChangeType changeType;

  /// 时间戳
  final DateTime timestamp;

  /// 旧值
  final dynamic oldValue;

  /// 新值
  final dynamic newValue;

  /// 元数据
  final Map<String, dynamic> metadata;

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'dataKey': dataKey,
      'changeType': changeType.name,
      'timestamp': timestamp.toIso8601String(),
      'oldValue': oldValue,
      'newValue': newValue,
      'metadata': metadata,
    };
  }

  /// 从JSON创建
  factory DataChange.fromJson(Map<String, dynamic> json) {
    return DataChange(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      dataKey: json['dataKey'] as String,
      changeType: DataChangeType.values.firstWhere(
        (e) => e.name == json['changeType'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  @override
  String toString() {
    return 'DataChange(id: $id, module: $moduleId, key: $dataKey, '
        'type: $changeType, timestamp: $timestamp)';
  }
}

/// 同步配置
class SyncConfig {
  const SyncConfig({
    required this.moduleId,
    required this.dataKeys,
    this.strategy = SyncStrategy.realtime,
    this.batchInterval = const Duration(seconds: 30),
    this.conflictResolution = ConflictResolutionStrategy.lastWriteWins,
    this.retryCount = 3,
    this.retryDelay = const Duration(seconds: 5),
  });

  /// 模块ID
  final String moduleId;

  /// 要同步的数据键列表
  final Set<String> dataKeys;

  /// 同步策略
  final SyncStrategy strategy;

  /// 批量同步间隔
  final Duration batchInterval;

  /// 冲突解决策略
  final ConflictResolutionStrategy conflictResolution;

  /// 重试次数
  final int retryCount;

  /// 重试延迟
  final Duration retryDelay;
}

/// 冲突解决策略
enum ConflictResolutionStrategy {
  /// 最后写入获胜
  lastWriteWins,

  /// 第一次写入获胜
  firstWriteWins,

  /// 手动解决
  manual,

  /// 合并策略
  merge,
}

/// 同步结果
class SyncResult {
  const SyncResult({
    required this.syncId,
    required this.status,
    required this.timestamp,
    this.syncedChanges = const [],
    this.conflicts = const [],
    this.error,
  });

  /// 同步ID
  final String syncId;

  /// 同步状态
  final SyncStatus status;

  /// 时间戳
  final DateTime timestamp;

  /// 已同步的变更
  final List<DataChange> syncedChanges;

  /// 冲突列表
  final List<DataChange> conflicts;

  /// 错误信息
  final String? error;

  /// 是否成功
  bool get isSuccess => status == SyncStatus.success;

  /// 是否有冲突
  bool get hasConflicts => conflicts.isNotEmpty;
}

/// 数据同步管理器
///
/// Phase 3.2.3 核心功能：
/// - 实时数据同步
/// - 批量数据同步
/// - 冲突检测和解决
/// - 同步状态管理
/// - 性能优化
class DataSyncManager {
  DataSyncManager._();

  static final DataSyncManager _instance = DataSyncManager._();
  static DataSyncManager get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 通信协调器 (暂时未使用)
  // final comm.ModuleCommunicationCoordinator _coordinator =
  //     comm.ModuleCommunicationCoordinator.instance;

  /// 同步配置
  final Map<String, SyncConfig> _syncConfigs = {};

  /// 待同步的变更
  final Map<String, List<DataChange>> _pendingChanges = {};

  /// 同步历史
  final Map<String, SyncResult> _syncHistory = {};

  /// 批量同步定时器
  final Map<String, Timer> _batchTimers = {};

  /// 同步统计
  final Map<String, int> _syncStats = {};

  /// 同步ID计数器
  int _syncIdCounter = 0;

  /// 变更ID计数器
  int _changeIdCounter = 0;

  /// 生成同步ID
  String _generateSyncId() {
    return 'sync_${DateTime.now().millisecondsSinceEpoch}_${++_syncIdCounter}';
  }

  /// 生成变更ID
  String _generateChangeId() {
    return 'change_${DateTime.now().millisecondsSinceEpoch}_${++_changeIdCounter}';
  }

  /// 注册同步配置
  void registerSyncConfig(SyncConfig config) {
    _syncConfigs[config.moduleId] = config;
    _pendingChanges[config.moduleId] = [];

    // 设置批量同步定时器
    if (config.strategy == SyncStrategy.batch) {
      _setupBatchTimer(config);
    }

    debugPrint('Registered sync config for module: ${config.moduleId}');
  }

  /// 注销同步配置
  void unregisterSyncConfig(String moduleId) {
    _syncConfigs.remove(moduleId);
    _pendingChanges.remove(moduleId);

    // 取消批量同步定时器
    _batchTimers[moduleId]?.cancel();
    _batchTimers.remove(moduleId);

    debugPrint('Unregistered sync config for module: $moduleId');
  }

  /// 记录数据变更
  Future<void> recordDataChange({
    required String moduleId,
    required String dataKey,
    required DataChangeType changeType,
    dynamic oldValue,
    dynamic newValue,
    Map<String, dynamic> metadata = const {},
  }) async {
    final config = _syncConfigs[moduleId];
    if (config == null) {
      debugPrint('No sync config found for module: $moduleId');
      return;
    }

    // 检查是否需要同步此数据键
    if (!config.dataKeys.contains(dataKey)) {
      return;
    }

    final change = DataChange(
      id: _generateChangeId(),
      moduleId: moduleId,
      dataKey: dataKey,
      changeType: changeType,
      timestamp: DateTime.now(),
      oldValue: oldValue,
      newValue: newValue,
      metadata: metadata,
    );

    // 添加到待同步列表
    _pendingChanges[moduleId]!.add(change);

    // 根据同步策略处理
    switch (config.strategy) {
      case SyncStrategy.realtime:
        await _performRealtimeSync(moduleId, [change]);
        break;
      case SyncStrategy.batch:
        // 批量同步由定时器处理
        break;
      case SyncStrategy.onDemand:
        // 按需同步不自动触发
        break;
      case SyncStrategy.conflictResolution:
        await _performConflictResolutionSync(moduleId, [change]);
        break;
    }

    debugPrint('Recorded data change: $change');
  }

  /// 执行实时同步
  Future<SyncResult> _performRealtimeSync(
    String moduleId,
    List<DataChange> changes,
  ) async {
    final syncId = _generateSyncId();

    try {
      // 发送同步消息
      await _sendSyncMessage(moduleId, changes, syncId);

      // 创建同步结果
      final result = SyncResult(
        syncId: syncId,
        status: SyncStatus.success,
        timestamp: DateTime.now(),
        syncedChanges: changes,
      );

      // 记录同步历史
      _syncHistory[syncId] = result;
      _updateSyncStats('realtime_success');

      // 清理已同步的变更
      _pendingChanges[moduleId]!.removeWhere(
        (change) => changes.contains(change),
      );

      return result;
    } catch (e, stackTrace) {
      debugPrint('Realtime sync failed: $e');
      debugPrint('Stack trace: $stackTrace');

      final result = SyncResult(
        syncId: syncId,
        status: SyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      _syncHistory[syncId] = result;
      _updateSyncStats('realtime_failed');

      return result;
    }
  }

  /// 执行批量同步
  Future<SyncResult> _performBatchSync(String moduleId) async {
    final changes = List<DataChange>.from(_pendingChanges[moduleId] ?? []);
    if (changes.isEmpty) {
      return SyncResult(
        syncId: _generateSyncId(),
        status: SyncStatus.success,
        timestamp: DateTime.now(),
      );
    }

    final syncId = _generateSyncId();

    try {
      // 发送批量同步消息
      await _sendSyncMessage(moduleId, changes, syncId);

      // 创建同步结果
      final result = SyncResult(
        syncId: syncId,
        status: SyncStatus.success,
        timestamp: DateTime.now(),
        syncedChanges: changes,
      );

      // 记录同步历史
      _syncHistory[syncId] = result;
      _updateSyncStats('batch_success');

      // 清理已同步的变更
      _pendingChanges[moduleId]!.clear();

      return result;
    } catch (e, stackTrace) {
      debugPrint('Batch sync failed: $e');
      debugPrint('Stack trace: $stackTrace');

      final result = SyncResult(
        syncId: syncId,
        status: SyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      _syncHistory[syncId] = result;
      _updateSyncStats('batch_failed');

      return result;
    }
  }

  /// 执行冲突解决同步
  Future<SyncResult> _performConflictResolutionSync(
    String moduleId,
    List<DataChange> changes,
  ) async {
    final syncId = _generateSyncId();

    try {
      // 检测冲突
      final conflicts = await _detectConflicts(moduleId, changes);

      if (conflicts.isNotEmpty) {
        // 根据策略解决冲突
        final resolvedChanges = await _resolveConflicts(moduleId, conflicts);

        // 发送解决后的同步消息
        await _sendSyncMessage(moduleId, resolvedChanges, syncId);

        final result = SyncResult(
          syncId: syncId,
          status: SyncStatus.success,
          timestamp: DateTime.now(),
          syncedChanges: resolvedChanges,
          conflicts: conflicts,
        );

        _syncHistory[syncId] = result;
        _updateSyncStats('conflict_resolved');

        return result;
      } else {
        // 没有冲突，直接同步
        return await _performRealtimeSync(moduleId, changes);
      }
    } catch (e, stackTrace) {
      debugPrint('Conflict resolution sync failed: $e');
      debugPrint('Stack trace: $stackTrace');

      final result = SyncResult(
        syncId: syncId,
        status: SyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      _syncHistory[syncId] = result;
      _updateSyncStats('conflict_failed');

      return result;
    }
  }

  /// 发送同步消息
  Future<void> _sendSyncMessage(
    String moduleId,
    List<DataChange> changes,
    String syncId,
  ) async {
    final message = {
      'syncId': syncId,
      'changes': changes.map((c) => c.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 广播同步消息给其他模块
    _messageBus.broadcastMessage(
      moduleId,
      'data_sync',
      message,
      excludeIds: [moduleId], // 排除发送者自己
      priority: MessagePriority.high,
    );
  }

  /// 检测冲突
  Future<List<DataChange>> _detectConflicts(
    String moduleId,
    List<DataChange> changes,
  ) async {
    // 简化的冲突检测逻辑
    // 实际实现中可能需要更复杂的冲突检测算法
    return [];
  }

  /// 解决冲突
  Future<List<DataChange>> _resolveConflicts(
    String moduleId,
    List<DataChange> conflicts,
  ) async {
    final config = _syncConfigs[moduleId];
    if (config == null) return conflicts;

    switch (config.conflictResolution) {
      case ConflictResolutionStrategy.lastWriteWins:
        // 保留最新的变更
        return conflicts;
      case ConflictResolutionStrategy.firstWriteWins:
        // 保留最早的变更
        return conflicts;
      case ConflictResolutionStrategy.manual:
        // 需要手动解决
        return [];
      case ConflictResolutionStrategy.merge:
        // 尝试合并变更
        return conflicts;
    }
  }

  /// 设置批量同步定时器
  void _setupBatchTimer(SyncConfig config) {
    _batchTimers[config.moduleId]?.cancel();

    _batchTimers[config.moduleId] = Timer.periodic(config.batchInterval, (
      timer,
    ) async {
      await _performBatchSync(config.moduleId);
    });
  }

  /// 更新同步统计
  void _updateSyncStats(String action) {
    _syncStats[action] = (_syncStats[action] ?? 0) + 1;
  }

  /// 手动触发同步
  Future<SyncResult> triggerSync(String moduleId) async {
    final config = _syncConfigs[moduleId];
    if (config == null) {
      throw ArgumentError('No sync config found for module: $moduleId');
    }

    final changes = List<DataChange>.from(_pendingChanges[moduleId] ?? []);
    if (changes.isEmpty) {
      return SyncResult(
        syncId: _generateSyncId(),
        status: SyncStatus.success,
        timestamp: DateTime.now(),
      );
    }

    switch (config.strategy) {
      case SyncStrategy.realtime:
      case SyncStrategy.onDemand:
        return await _performRealtimeSync(moduleId, changes);
      case SyncStrategy.batch:
        return await _performBatchSync(moduleId);
      case SyncStrategy.conflictResolution:
        return await _performConflictResolutionSync(moduleId, changes);
    }
  }

  /// 获取同步配置
  SyncConfig? getSyncConfig(String moduleId) => _syncConfigs[moduleId];

  /// 获取待同步变更
  List<DataChange> getPendingChanges(String moduleId) =>
      List.unmodifiable(_pendingChanges[moduleId] ?? []);

  /// 获取同步历史
  List<SyncResult> getSyncHistory([String? moduleId]) {
    if (moduleId != null) {
      return _syncHistory.values
          .where(
            (result) => result.syncedChanges.any((c) => c.moduleId == moduleId),
          )
          .toList();
    }
    return List.unmodifiable(_syncHistory.values);
  }

  /// 获取同步统计
  Map<String, int> get syncStats => Map.unmodifiable(_syncStats);

  /// 清理资源
  void dispose() {
    // 取消所有定时器
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }

    // 清理数据
    _syncConfigs.clear();
    _pendingChanges.clear();
    _syncHistory.clear();
    _batchTimers.clear();
    _syncStats.clear();

    debugPrint('DataSyncManager disposed');
  }
}
