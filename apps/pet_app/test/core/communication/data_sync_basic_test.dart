/*
---------------------------------------------------------------
File name:          data_sync_basic_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.3 数据同步基础测试（不依赖Flutter）
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.3 - 实现数据同步基础测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 简化的同步策略（用于测试）
enum TestSyncStrategy {
  realtime,
  batch,
  onDemand,
  conflictResolution,
}

/// 简化的同步状态（用于测试）
enum TestSyncStatus {
  syncing,
  success,
  failed,
  conflict,
  cancelled,
}

/// 简化的数据变更类型（用于测试）
enum TestDataChangeType {
  create,
  update,
  delete,
  batch,
}

/// 简化的数据变更记录（用于测试）
class TestDataChange {
  const TestDataChange({
    required this.id,
    required this.moduleId,
    required this.dataKey,
    required this.changeType,
    required this.timestamp,
    this.oldValue,
    this.newValue,
    this.metadata = const {},
  });

  final String id;
  final String moduleId;
  final String dataKey;
  final TestDataChangeType changeType;
  final DateTime timestamp;
  final dynamic oldValue;
  final dynamic newValue;
  final Map<String, dynamic> metadata;

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

  factory TestDataChange.fromJson(Map<String, dynamic> json) {
    return TestDataChange(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      dataKey: json['dataKey'] as String,
      changeType: TestDataChangeType.values.firstWhere(
        (e) => e.name == json['changeType'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
}

/// 简化的同步配置（用于测试）
class TestSyncConfig {
  const TestSyncConfig({
    required this.moduleId,
    required this.dataKeys,
    this.strategy = TestSyncStrategy.realtime,
    this.batchInterval = const Duration(seconds: 30),
  });

  final String moduleId;
  final Set<String> dataKeys;
  final TestSyncStrategy strategy;
  final Duration batchInterval;
}

/// 简化的同步结果（用于测试）
class TestSyncResult {
  const TestSyncResult({
    required this.syncId,
    required this.status,
    required this.timestamp,
    this.syncedChanges = const [],
    this.conflicts = const [],
    this.error,
  });

  final String syncId;
  final TestSyncStatus status;
  final DateTime timestamp;
  final List<TestDataChange> syncedChanges;
  final List<TestDataChange> conflicts;
  final String? error;

  bool get isSuccess => status == TestSyncStatus.success;
  bool get hasConflicts => conflicts.isNotEmpty;
}

/// 简化的数据同步管理器（用于测试）
class TestDataSyncManager {
  TestDataSyncManager._();

  final Map<String, TestSyncConfig> _syncConfigs = {};
  final Map<String, List<TestDataChange>> _pendingChanges = {};
  final Map<String, TestSyncResult> _syncHistory = {};
  final Map<String, Timer> _batchTimers = {};
  final Map<String, int> _syncStats = {};
  
  int _syncIdCounter = 0;
  int _changeIdCounter = 0;

  String _generateSyncId() {
    return 'sync_${DateTime.now().millisecondsSinceEpoch}_${++_syncIdCounter}';
  }
  
  String _generateChangeId() {
    return 'change_${DateTime.now().millisecondsSinceEpoch}_${++_changeIdCounter}';
  }

  void registerSyncConfig(TestSyncConfig config) {
    _syncConfigs[config.moduleId] = config;
    _pendingChanges[config.moduleId] = [];
    
    if (config.strategy == TestSyncStrategy.batch) {
      _setupBatchTimer(config);
    }
  }

  void unregisterSyncConfig(String moduleId) {
    _syncConfigs.remove(moduleId);
    _pendingChanges.remove(moduleId);
    
    _batchTimers[moduleId]?.cancel();
    _batchTimers.remove(moduleId);
  }

  Future<void> recordDataChange({
    required String moduleId,
    required String dataKey,
    required TestDataChangeType changeType,
    dynamic oldValue,
    dynamic newValue,
    Map<String, dynamic> metadata = const {},
  }) async {
    final config = _syncConfigs[moduleId];
    if (config == null || !config.dataKeys.contains(dataKey)) {
      return;
    }

    final change = TestDataChange(
      id: _generateChangeId(),
      moduleId: moduleId,
      dataKey: dataKey,
      changeType: changeType,
      timestamp: DateTime.now(),
      oldValue: oldValue,
      newValue: newValue,
      metadata: metadata,
    );

    _pendingChanges[moduleId]!.add(change);

    switch (config.strategy) {
      case TestSyncStrategy.realtime:
        await _performRealtimeSync(moduleId, [change]);
        break;
      case TestSyncStrategy.batch:
        // 批量同步由定时器处理
        break;
      case TestSyncStrategy.onDemand:
        // 按需同步不自动触发
        break;
      case TestSyncStrategy.conflictResolution:
        await _performConflictResolutionSync(moduleId, [change]);
        break;
    }
  }

  Future<TestSyncResult> _performRealtimeSync(
    String moduleId,
    List<TestDataChange> changes,
  ) async {
    final syncId = _generateSyncId();
    
    try {
      // 模拟同步过程
      await Future.delayed(const Duration(milliseconds: 10));
      
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.success,
        timestamp: DateTime.now(),
        syncedChanges: changes,
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('realtime_success');
      
      _pendingChanges[moduleId]!.removeWhere(
        (change) => changes.contains(change),
      );
      
      return result;
      
    } catch (e) {
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('realtime_failed');
      
      return result;
    }
  }

  Future<TestSyncResult> _performBatchSync(String moduleId) async {
    final changes = List<TestDataChange>.from(_pendingChanges[moduleId] ?? []);
    if (changes.isEmpty) {
      return TestSyncResult(
        syncId: _generateSyncId(),
        status: TestSyncStatus.success,
        timestamp: DateTime.now(),
      );
    }

    final syncId = _generateSyncId();
    
    try {
      // 模拟批量同步过程
      await Future.delayed(const Duration(milliseconds: 20));
      
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.success,
        timestamp: DateTime.now(),
        syncedChanges: changes,
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('batch_success');
      
      _pendingChanges[moduleId]!.clear();
      
      return result;
      
    } catch (e) {
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('batch_failed');
      
      return result;
    }
  }

  Future<TestSyncResult> _performConflictResolutionSync(
    String moduleId,
    List<TestDataChange> changes,
  ) async {
    final syncId = _generateSyncId();
    
    try {
      // 模拟冲突检测和解决
      await Future.delayed(const Duration(milliseconds: 15));
      
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.success,
        timestamp: DateTime.now(),
        syncedChanges: changes,
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('conflict_resolved');
      
      return result;
      
    } catch (e) {
      final result = TestSyncResult(
        syncId: syncId,
        status: TestSyncStatus.failed,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
      
      _syncHistory[syncId] = result;
      _updateSyncStats('conflict_failed');
      
      return result;
    }
  }

  void _setupBatchTimer(TestSyncConfig config) {
    _batchTimers[config.moduleId]?.cancel();
    
    _batchTimers[config.moduleId] = Timer.periodic(
      config.batchInterval,
      (timer) async {
        await _performBatchSync(config.moduleId);
      },
    );
  }

  void _updateSyncStats(String action) {
    _syncStats[action] = (_syncStats[action] ?? 0) + 1;
  }

  Future<TestSyncResult> triggerSync(String moduleId) async {
    final config = _syncConfigs[moduleId];
    if (config == null) {
      throw ArgumentError('No sync config found for module: $moduleId');
    }

    final changes = List<TestDataChange>.from(_pendingChanges[moduleId] ?? []);
    if (changes.isEmpty) {
      return TestSyncResult(
        syncId: _generateSyncId(),
        status: TestSyncStatus.success,
        timestamp: DateTime.now(),
      );
    }

    switch (config.strategy) {
      case TestSyncStrategy.realtime:
      case TestSyncStrategy.onDemand:
        return await _performRealtimeSync(moduleId, changes);
      case TestSyncStrategy.batch:
        return await _performBatchSync(moduleId);
      case TestSyncStrategy.conflictResolution:
        return await _performConflictResolutionSync(moduleId, changes);
    }
  }

  TestSyncConfig? getSyncConfig(String moduleId) => _syncConfigs[moduleId];

  List<TestDataChange> getPendingChanges(String moduleId) =>
      List.unmodifiable(_pendingChanges[moduleId] ?? []);

  List<TestSyncResult> getSyncHistory([String? moduleId]) {
    if (moduleId != null) {
      return _syncHistory.values
          .where((result) => result.syncedChanges.any((c) => c.moduleId == moduleId))
          .toList();
    }
    return List.unmodifiable(_syncHistory.values);
  }

  Map<String, int> get syncStats => Map.unmodifiable(_syncStats);

  void dispose() {
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    
    _syncConfigs.clear();
    _pendingChanges.clear();
    _syncHistory.clear();
    _batchTimers.clear();
    _syncStats.clear();
  }
}

void main() {
  group('Data Sync Basic Tests', () {
    late TestDataSyncManager syncManager;

    setUp(() {
      syncManager = TestDataSyncManager._();
    });

    tearDown(() {
      syncManager.dispose();
    });

    group('同步配置管理', () {
      test('应该能够注册和注销同步配置', () {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'key1', 'key2'},
          strategy: TestSyncStrategy.realtime,
        );

        // 执行
        syncManager.registerSyncConfig(config);

        // 验证
        final retrievedConfig = syncManager.getSyncConfig('test_module');
        expect(retrievedConfig, isNotNull);
        expect(retrievedConfig!.moduleId, equals('test_module'));
        expect(retrievedConfig.dataKeys, equals({'key1', 'key2'}));

        // 注销
        syncManager.unregisterSyncConfig('test_module');
        final configAfterUnregister = syncManager.getSyncConfig('test_module');
        expect(configAfterUnregister, isNull);
      });
    });

    group('数据变更记录', () {
      test('应该能够记录数据变更', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'test_key'},
          strategy: TestSyncStrategy.onDemand, // 使用按需同步避免自动触发
        );
        syncManager.registerSyncConfig(config);

        // 执行
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.update,
          oldValue: 'old_value',
          newValue: 'new_value',
        );

        // 验证
        final pendingChanges = syncManager.getPendingChanges('test_module');
        expect(pendingChanges.length, equals(1));
        expect(pendingChanges.first.dataKey, equals('test_key'));
        expect(pendingChanges.first.changeType, equals(TestDataChangeType.update));
        expect(pendingChanges.first.oldValue, equals('old_value'));
        expect(pendingChanges.first.newValue, equals('new_value'));
      });

      test('应该忽略未配置的数据键', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'allowed_key'},
          strategy: TestSyncStrategy.onDemand,
        );
        syncManager.registerSyncConfig(config);

        // 执行
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'ignored_key', // 未在配置中的键
          changeType: TestDataChangeType.update,
          newValue: 'value',
        );

        // 验证
        final pendingChanges = syncManager.getPendingChanges('test_module');
        expect(pendingChanges.length, equals(0));
      });
    });

    group('实时同步', () {
      test('应该能够执行实时同步', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'test_key'},
          strategy: TestSyncStrategy.realtime,
        );
        syncManager.registerSyncConfig(config);

        // 执行
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.create,
          newValue: 'test_value',
        );

        // 等待异步处理
        await Future.delayed(const Duration(milliseconds: 20));

        // 验证
        final syncHistory = syncManager.getSyncHistory('test_module');
        expect(syncHistory.length, equals(1));
        expect(syncHistory.first.isSuccess, isTrue);
        expect(syncHistory.first.syncedChanges.length, equals(1));

        // 验证待同步变更已清理
        final pendingChanges = syncManager.getPendingChanges('test_module');
        expect(pendingChanges.length, equals(0));
      });
    });

    group('批量同步', () {
      test('应该能够手动触发批量同步', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'key1', 'key2'},
          strategy: TestSyncStrategy.batch,
        );
        syncManager.registerSyncConfig(config);

        // 添加多个变更
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'key1',
          changeType: TestDataChangeType.create,
          newValue: 'value1',
        );

        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'key2',
          changeType: TestDataChangeType.update,
          newValue: 'value2',
        );

        // 执行批量同步
        final result = await syncManager.triggerSync('test_module');

        // 验证
        expect(result.isSuccess, isTrue);
        expect(result.syncedChanges.length, equals(2));

        // 验证待同步变更已清理
        final pendingChanges = syncManager.getPendingChanges('test_module');
        expect(pendingChanges.length, equals(0));
      });
    });

    group('按需同步', () {
      test('应该能够按需触发同步', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'test_key'},
          strategy: TestSyncStrategy.onDemand,
        );
        syncManager.registerSyncConfig(config);

        // 添加变更（不会自动同步）
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.update,
          newValue: 'test_value',
        );

        // 验证变更还在待同步列表中
        expect(syncManager.getPendingChanges('test_module').length, equals(1));

        // 手动触发同步
        final result = await syncManager.triggerSync('test_module');

        // 验证
        expect(result.isSuccess, isTrue);
        expect(result.syncedChanges.length, equals(1));
        expect(syncManager.getPendingChanges('test_module').length, equals(0));
      });
    });

    group('同步统计', () {
      test('应该收集同步统计信息', () async {
        // 准备
        const config = TestSyncConfig(
          moduleId: 'test_module',
          dataKeys: {'test_key'},
          strategy: TestSyncStrategy.realtime,
        );
        syncManager.registerSyncConfig(config);

        // 执行多次同步
        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.create,
          newValue: 'value1',
        );

        await syncManager.recordDataChange(
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.update,
          newValue: 'value2',
        );

        // 等待异步处理
        await Future.delayed(const Duration(milliseconds: 30));

        // 验证统计
        final stats = syncManager.syncStats;
        expect(stats['realtime_success'], equals(2));
      });
    });

    group('JSON序列化', () {
      test('DataChange应该能够正确序列化和反序列化', () {
        // 准备
        final originalChange = TestDataChange(
          id: 'test_id',
          moduleId: 'test_module',
          dataKey: 'test_key',
          changeType: TestDataChangeType.update,
          timestamp: DateTime.now(),
          oldValue: 'old',
          newValue: 'new',
          metadata: {'version': 1},
        );

        // 执行序列化
        final json = originalChange.toJson();
        final deserializedChange = TestDataChange.fromJson(json);

        // 验证
        expect(deserializedChange.id, equals(originalChange.id));
        expect(deserializedChange.moduleId, equals(originalChange.moduleId));
        expect(deserializedChange.dataKey, equals(originalChange.dataKey));
        expect(deserializedChange.changeType, equals(originalChange.changeType));
        expect(deserializedChange.oldValue, equals(originalChange.oldValue));
        expect(deserializedChange.newValue, equals(originalChange.newValue));
        expect(deserializedChange.metadata, equals(originalChange.metadata));
      });
    });
  });
}
