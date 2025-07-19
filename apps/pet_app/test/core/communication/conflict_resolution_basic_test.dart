/*
---------------------------------------------------------------
File name:          conflict_resolution_basic_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.4 冲突解决基础测试（不依赖Flutter）
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.4 - 实现冲突解决基础测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';
import 'dart:math';

/// 简化的冲突类型（用于测试）
enum TestConflictType {
  resourceAccess,
  dataState,
  priority,
  dependency,
  configuration,
  lifecycle,
}

/// 简化的冲突严重程度（用于测试）
enum TestConflictSeverity {
  low(1),
  medium(2),
  high(3),
  critical(4);
  
  const TestConflictSeverity(this.level);
  final int level;
}

/// 简化的冲突解决状态（用于测试）
enum TestConflictResolutionStatus {
  detected,
  resolving,
  resolved,
  failed,
  manualIntervention,
  ignored,
}

/// 简化的冲突记录（用于测试）
class TestConflictRecord {
  const TestConflictRecord({
    required this.id,
    required this.type,
    required this.severity,
    required this.involvedModules,
    required this.resourceId,
    required this.detectedAt,
    required this.description,
    this.metadata = const {},
    this.status = TestConflictResolutionStatus.detected,
    this.resolvedAt,
    this.resolutionStrategy,
    this.resolutionDetails,
  });

  final String id;
  final TestConflictType type;
  final TestConflictSeverity severity;
  final List<String> involvedModules;
  final String resourceId;
  final DateTime detectedAt;
  final String description;
  final Map<String, dynamic> metadata;
  final TestConflictResolutionStatus status;
  final DateTime? resolvedAt;
  final String? resolutionStrategy;
  final Map<String, dynamic>? resolutionDetails;

  TestConflictRecord resolve({
    required String strategy,
    required Map<String, dynamic> details,
  }) {
    return TestConflictRecord(
      id: id,
      type: type,
      severity: severity,
      involvedModules: involvedModules,
      resourceId: resourceId,
      detectedAt: detectedAt,
      description: description,
      metadata: metadata,
      status: TestConflictResolutionStatus.resolved,
      resolvedAt: DateTime.now(),
      resolutionStrategy: strategy,
      resolutionDetails: details,
    );
  }

  TestConflictRecord fail({required String reason}) {
    return TestConflictRecord(
      id: id,
      type: type,
      severity: severity,
      involvedModules: involvedModules,
      resourceId: resourceId,
      detectedAt: detectedAt,
      description: description,
      metadata: metadata,
      status: TestConflictResolutionStatus.failed,
      resolutionDetails: {'failureReason': reason},
    );
  }

  bool get isResolved => status == TestConflictResolutionStatus.resolved;
  bool get needsManualIntervention => status == TestConflictResolutionStatus.manualIntervention;

  int? get resolutionTimeMs {
    if (resolvedAt != null) {
      return resolvedAt!.difference(detectedAt).inMilliseconds;
    }
    return null;
  }
}

/// 简化的冲突解决策略接口（用于测试）
abstract class TestConflictResolutionStrategy {
  String get name;
  String get description;
  Set<TestConflictType> get supportedTypes;
  int get priority;
  
  bool canHandle(TestConflictRecord conflict);
  Future<TestConflictRecord> resolve(TestConflictRecord conflict);
}

/// 测试用优先级策略
class TestPriorityBasedStrategy extends TestConflictResolutionStrategy {
  final Map<String, int> modulePriorities;
  
  TestPriorityBasedStrategy(this.modulePriorities);

  @override
  String get name => 'TestPriorityBased';

  @override
  String get description => '测试用基于优先级的冲突解决策略';

  @override
  Set<TestConflictType> get supportedTypes => {
    TestConflictType.resourceAccess,
    TestConflictType.priority,
    TestConflictType.configuration,
  };

  @override
  int get priority => 80;

  @override
  bool canHandle(TestConflictRecord conflict) {
    return supportedTypes.contains(conflict.type);
  }

  @override
  Future<TestConflictRecord> resolve(TestConflictRecord conflict) async {
    try {
      // 按优先级排序
      final sortedModules = conflict.involvedModules.toList()
        ..sort((a, b) {
          final priorityA = modulePriorities[a] ?? 0;
          final priorityB = modulePriorities[b] ?? 0;
          return priorityB.compareTo(priorityA);
        });

      final winnerModule = sortedModules.first;
      
      return conflict.resolve(
        strategy: name,
        details: {
          'winnerModule': winnerModule,
          'modulePriorities': modulePriorities,
          'resolutionMethod': 'highest_priority_wins',
        },
      );
      
    } catch (e) {
      return conflict.fail(reason: 'Priority resolution failed: $e');
    }
  }
}

/// 测试用时间戳策略
class TestTimestampBasedStrategy extends TestConflictResolutionStrategy {
  @override
  String get name => 'TestTimestampBased';

  @override
  String get description => '测试用基于时间戳的冲突解决策略';

  @override
  Set<TestConflictType> get supportedTypes => {
    TestConflictType.dataState,
    TestConflictType.configuration,
  };

  @override
  int get priority => 70;

  @override
  bool canHandle(TestConflictRecord conflict) {
    return supportedTypes.contains(conflict.type) &&
           conflict.metadata.containsKey('timestamps');
  }

  @override
  Future<TestConflictRecord> resolve(TestConflictRecord conflict) async {
    try {
      final timestamps = conflict.metadata['timestamps'] as Map<String, dynamic>;
      
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

/// 测试用随机策略
class TestRandomStrategy extends TestConflictResolutionStrategy {
  final Random _random = Random(42); // 固定种子以便测试

  @override
  String get name => 'TestRandom';

  @override
  String get description => '测试用随机选择策略';

  @override
  Set<TestConflictType> get supportedTypes => TestConflictType.values.toSet();

  @override
  int get priority => 10;

  @override
  bool canHandle(TestConflictRecord conflict) => true;

  @override
  Future<TestConflictRecord> resolve(TestConflictRecord conflict) async {
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

/// 简化的冲突解决引擎（用于测试）
class TestConflictResolutionEngine {
  TestConflictResolutionEngine._();

  final List<TestConflictResolutionStrategy> _strategies = [];
  final Map<String, TestConflictRecord> _conflicts = {};
  final Map<String, int> _resolutionStats = {};
  final Map<String, List<int>> _performanceStats = {};
  
  int _conflictIdCounter = 0;

  void initialize() {
    // 可以在这里添加默认策略
  }

  void addStrategy(TestConflictResolutionStrategy strategy) {
    _strategies.add(strategy);
    _strategies.sort((a, b) => b.priority.compareTo(a.priority));
  }

  void removeStrategy(String strategyName) {
    _strategies.removeWhere((strategy) => strategy.name == strategyName);
  }

  String _generateConflictId() {
    return 'conflict_${DateTime.now().millisecondsSinceEpoch}_${++_conflictIdCounter}';
  }

  Future<TestConflictRecord> detectConflict({
    required TestConflictType type,
    required TestConflictSeverity severity,
    required List<String> involvedModules,
    required String resourceId,
    required String description,
    Map<String, dynamic> metadata = const {},
  }) async {
    final conflict = TestConflictRecord(
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

    // 根据严重程度决定是否立即解决
    if (severity.level >= TestConflictSeverity.high.level) {
      await resolveConflict(conflict.id);
    }

    return conflict;
  }

  Future<TestConflictRecord?> resolveConflict(String conflictId) async {
    final conflict = _conflicts[conflictId];
    if (conflict == null || conflict.isResolved) {
      return conflict;
    }

    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    try {
      // 查找合适的策略
      TestConflictResolutionStrategy? selectedStrategy;
      for (final strategy in _strategies) {
        if (strategy.canHandle(conflict)) {
          selectedStrategy = strategy;
          break;
        }
      }

      if (selectedStrategy == null) {
        final failedConflict = conflict.fail(reason: 'No suitable strategy found');
        _conflicts[conflictId] = failedConflict;
        _updateResolutionStats('no_strategy');
        return failedConflict;
      }

      // 执行解决策略
      final resolvedConflict = await selectedStrategy.resolve(conflict);
      _conflicts[conflictId] = resolvedConflict;

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

      return resolvedConflict;
      
    } catch (e) {
      final failedConflict = conflict.fail(reason: 'Resolution error: $e');
      _conflicts[conflictId] = failedConflict;
      _updateResolutionStats('error');
      
      return failedConflict;
    }
  }

  void _updateResolutionStats(String action) {
    _resolutionStats[action] = (_resolutionStats[action] ?? 0) + 1;
  }

  void _updatePerformanceStats(String strategy, int processingTime) {
    _performanceStats.putIfAbsent(strategy, () => []);
    _performanceStats[strategy]!.add(processingTime);
    
    if (_performanceStats[strategy]!.length > 100) {
      _performanceStats[strategy]!.removeAt(0);
    }
  }

  TestConflictRecord? getConflict(String conflictId) => _conflicts[conflictId];
  List<TestConflictRecord> getAllConflicts() => List.unmodifiable(_conflicts.values);
  
  List<TestConflictRecord> getUnresolvedConflicts() {
    return _conflicts.values
        .where((conflict) => !conflict.isResolved)
        .toList();
  }

  List<TestConflictResolutionStrategy> get strategies => List.unmodifiable(_strategies);
  Map<String, int> get resolutionStats => Map.unmodifiable(_resolutionStats);

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

  void dispose() {
    _strategies.clear();
    _conflicts.clear();
    _resolutionStats.clear();
    _performanceStats.clear();
  }
}

void main() {
  group('Conflict Resolution Basic Tests', () {
    late TestConflictResolutionEngine engine;

    setUp(() {
      engine = TestConflictResolutionEngine._();
      engine.initialize();
    });

    tearDown(() {
      engine.dispose();
    });

    group('策略管理', () {
      test('应该能够添加和移除策略', () {
        // 准备
        final strategy = TestRandomStrategy();

        // 执行
        engine.addStrategy(strategy);

        // 验证
        expect(engine.strategies.length, equals(1));
        expect(engine.strategies.first.name, equals('TestRandom'));

        // 移除
        engine.removeStrategy('TestRandom');
        expect(engine.strategies.length, equals(0));
      });

      test('策略应该按优先级排序', () {
        // 准备
        final lowPriorityStrategy = TestRandomStrategy(); // priority: 10
        final highPriorityStrategy = TestPriorityBasedStrategy({}); // priority: 80

        // 执行
        engine.addStrategy(lowPriorityStrategy);
        engine.addStrategy(highPriorityStrategy);

        // 验证
        expect(engine.strategies.length, equals(2));
        expect(engine.strategies.first.name, equals('TestPriorityBased'));
        expect(engine.strategies.last.name, equals('TestRandom'));
      });
    });

    group('冲突检测', () {
      test('应该能够检测冲突', () async {
        // 执行
        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.medium,
          involvedModules: ['module1', 'module2'],
          resourceId: 'test_resource',
          description: 'Test conflict',
        );

        // 验证
        expect(conflict.type, equals(TestConflictType.resourceAccess));
        expect(conflict.severity, equals(TestConflictSeverity.medium));
        expect(conflict.involvedModules, equals(['module1', 'module2']));
        expect(conflict.resourceId, equals('test_resource'));
        expect(conflict.description, equals('Test conflict'));
        expect(engine.getAllConflicts().length, equals(1));
      });

      test('高严重程度冲突应该自动解决', () async {
        // 准备
        engine.addStrategy(TestRandomStrategy());

        // 执行
        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.critical,
          involvedModules: ['module1', 'module2'],
          resourceId: 'critical_resource',
          description: 'Critical conflict',
        );

        // 等待异步处理
        await Future.delayed(const Duration(milliseconds: 10));

        // 验证
        final resolvedConflict = engine.getConflict(conflict.id);
        expect(resolvedConflict?.isResolved, isTrue);
      });
    });

    group('优先级策略', () {
      test('应该根据模块优先级解决冲突', () async {
        // 准备
        final modulePriorities = {
          'module1': 10,
          'module2': 20,
          'module3': 15,
        };
        engine.addStrategy(TestPriorityBasedStrategy(modulePriorities));

        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.medium,
          involvedModules: ['module1', 'module2', 'module3'],
          resourceId: 'test_resource',
          description: 'Priority test conflict',
        );

        // 执行
        final resolvedConflict = await engine.resolveConflict(conflict.id);

        // 验证
        expect(resolvedConflict?.isResolved, isTrue);
        expect(resolvedConflict?.resolutionStrategy, equals('TestPriorityBased'));
        expect(resolvedConflict?.resolutionDetails?['winnerModule'], equals('module2')); // 最高优先级
      });
    });

    group('时间戳策略', () {
      test('应该根据时间戳解决冲突', () async {
        // 准备
        final now = DateTime.now();
        final timestamps = {
          'module1': now.subtract(const Duration(minutes: 2)).toIso8601String(),
          'module2': now.subtract(const Duration(minutes: 1)).toIso8601String(),
          'module3': now.toIso8601String(), // 最新
        };

        engine.addStrategy(TestTimestampBasedStrategy());

        final conflict = await engine.detectConflict(
          type: TestConflictType.dataState,
          severity: TestConflictSeverity.medium,
          involvedModules: ['module1', 'module2', 'module3'],
          resourceId: 'test_data',
          description: 'Timestamp test conflict',
          metadata: {'timestamps': timestamps},
        );

        // 执行
        final resolvedConflict = await engine.resolveConflict(conflict.id);

        // 验证
        expect(resolvedConflict?.isResolved, isTrue);
        expect(resolvedConflict?.resolutionStrategy, equals('TestTimestampBased'));
        expect(resolvedConflict?.resolutionDetails?['winnerModule'], equals('module3')); // 最新时间戳
      });
    });

    group('随机策略', () {
      test('应该随机选择获胜者', () async {
        // 准备
        engine.addStrategy(TestRandomStrategy());

        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.low,
          involvedModules: ['module1', 'module2'],
          resourceId: 'test_resource',
          description: 'Random test conflict',
        );

        // 执行
        final resolvedConflict = await engine.resolveConflict(conflict.id);

        // 验证
        expect(resolvedConflict?.isResolved, isTrue);
        expect(resolvedConflict?.resolutionStrategy, equals('TestRandom'));
        expect(resolvedConflict?.resolutionDetails?['winnerModule'], isIn(['module1', 'module2']));
      });
    });

    group('统计和监控', () {
      test('应该收集解决统计', () async {
        // 准备
        engine.addStrategy(TestRandomStrategy());

        // 执行多次冲突解决
        for (int i = 0; i < 3; i++) {
          final conflict = await engine.detectConflict(
            type: TestConflictType.resourceAccess,
            severity: TestConflictSeverity.medium,
            involvedModules: ['module1', 'module2'],
            resourceId: 'resource_$i',
            description: 'Test conflict $i',
          );
          await engine.resolveConflict(conflict.id);
        }

        // 验证
        final stats = engine.resolutionStats;
        expect(stats['resolved'], equals(3));
        expect(stats['strategy_TestRandom'], equals(3));
      });

      test('应该收集性能统计', () async {
        // 准备
        engine.addStrategy(TestRandomStrategy());

        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.medium,
          involvedModules: ['module1', 'module2'],
          resourceId: 'perf_test_resource',
          description: 'Performance test conflict',
        );

        // 执行
        await engine.resolveConflict(conflict.id);

        // 验证
        final perfStats = engine.getPerformanceStats();
        expect(perfStats.containsKey('TestRandom'), isTrue);
        expect(perfStats['TestRandom']! >= 0, isTrue);
      });
    });

    group('错误处理', () {
      test('应该处理没有合适策略的情况', () async {
        // 不添加任何策略

        final conflict = await engine.detectConflict(
          type: TestConflictType.resourceAccess,
          severity: TestConflictSeverity.medium,
          involvedModules: ['module1', 'module2'],
          resourceId: 'no_strategy_resource',
          description: 'No strategy test conflict',
        );

        // 执行
        final resolvedConflict = await engine.resolveConflict(conflict.id);

        // 验证
        expect(resolvedConflict?.status, equals(TestConflictResolutionStatus.failed));
        expect(resolvedConflict?.resolutionDetails?['failureReason'], contains('No suitable strategy'));
      });
    });
  });
}
