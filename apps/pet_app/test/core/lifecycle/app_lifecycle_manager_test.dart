/*
---------------------------------------------------------------
File name:          app_lifecycle_manager_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        应用生命周期管理器测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 应用生命周期状态
enum TestAppLifecycleState {
  uninitialized,
  initializing,
  initialized,
  starting,
  started,
  pausing,
  paused,
  resuming,
  stopping,
  stopped,
  error,
}

/// 生命周期事件
class TestLifecycleEvent {
  final String id;
  final TestAppLifecycleState fromState;
  final TestAppLifecycleState toState;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  TestLifecycleEvent({
    required this.id,
    required this.fromState,
    required this.toState,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) : timestamp = timestamp ?? DateTime.now(),
       data = data ?? {};
}

/// 简化的应用生命周期管理器（测试版本）
class TestAppLifecycleManager {
  TestAppLifecycleState _currentState = TestAppLifecycleState.uninitialized;
  final List<TestLifecycleEvent> _eventHistory = [];
  final StreamController<TestLifecycleEvent> _eventController = StreamController<TestLifecycleEvent>.broadcast();
  final StreamController<TestAppLifecycleState> _stateController = StreamController<TestAppLifecycleState>.broadcast();
  
  TestAppLifecycleState get currentState => _currentState;
  Stream<TestLifecycleEvent> get eventStream => _eventController.stream;
  Stream<TestAppLifecycleState> get stateStream => _stateController.stream;
  List<TestLifecycleEvent> get eventHistory => List.unmodifiable(_eventHistory);
  
  /// 初始化应用
  Future<void> initialize() async {
    if (_currentState != TestAppLifecycleState.uninitialized) {
      throw StateError('App already initialized');
    }
    
    await _transitionTo(TestAppLifecycleState.initializing);
    
    // 模拟初始化过程
    await Future.delayed(const Duration(milliseconds: 100));
    
    await _transitionTo(TestAppLifecycleState.initialized);
  }
  
  /// 启动应用
  Future<void> startApplication() async {
    if (_currentState != TestAppLifecycleState.initialized) {
      throw StateError('App must be initialized before starting');
    }
    
    await _transitionTo(TestAppLifecycleState.starting);
    
    // 模拟启动过程
    await Future.delayed(const Duration(milliseconds: 150));
    
    await _transitionTo(TestAppLifecycleState.started);
  }
  
  /// 暂停应用
  Future<void> pauseApplication() async {
    if (_currentState != TestAppLifecycleState.started) {
      throw StateError('App must be started before pausing');
    }
    
    await _transitionTo(TestAppLifecycleState.pausing);
    
    // 模拟暂停过程
    await Future.delayed(const Duration(milliseconds: 50));
    
    await _transitionTo(TestAppLifecycleState.paused);
  }
  
  /// 恢复应用
  Future<void> resumeApplication() async {
    if (_currentState != TestAppLifecycleState.paused) {
      throw StateError('App must be paused before resuming');
    }
    
    await _transitionTo(TestAppLifecycleState.resuming);
    
    // 模拟恢复过程
    await Future.delayed(const Duration(milliseconds: 75));
    
    await _transitionTo(TestAppLifecycleState.started);
  }
  
  /// 停止应用
  Future<void> stopApplication() async {
    if (_currentState == TestAppLifecycleState.stopped || 
        _currentState == TestAppLifecycleState.uninitialized) {
      return; // 已经停止或未初始化
    }
    
    await _transitionTo(TestAppLifecycleState.stopping);
    
    // 模拟停止过程
    await Future.delayed(const Duration(milliseconds: 100));
    
    await _transitionTo(TestAppLifecycleState.stopped);
  }
  
  /// 状态转换
  Future<void> _transitionTo(TestAppLifecycleState newState) async {
    final fromState = _currentState;
    
    // 验证状态转换的有效性
    if (!_isValidTransition(fromState, newState)) {
      throw StateError('Invalid transition from $fromState to $newState');
    }
    
    _currentState = newState;
    
    final event = TestLifecycleEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      fromState: fromState,
      toState: newState,
    );
    
    _eventHistory.add(event);
    _eventController.add(event);
    _stateController.add(newState);
  }
  
  /// 验证状态转换是否有效
  bool _isValidTransition(TestAppLifecycleState from, TestAppLifecycleState to) {
    const validTransitions = {
      TestAppLifecycleState.uninitialized: [TestAppLifecycleState.initializing],
      TestAppLifecycleState.initializing: [TestAppLifecycleState.initialized, TestAppLifecycleState.error],
      TestAppLifecycleState.initialized: [TestAppLifecycleState.starting],
      TestAppLifecycleState.starting: [TestAppLifecycleState.started, TestAppLifecycleState.error],
      TestAppLifecycleState.started: [TestAppLifecycleState.pausing, TestAppLifecycleState.stopping],
      TestAppLifecycleState.pausing: [TestAppLifecycleState.paused, TestAppLifecycleState.error],
      TestAppLifecycleState.paused: [TestAppLifecycleState.resuming, TestAppLifecycleState.stopping],
      TestAppLifecycleState.resuming: [TestAppLifecycleState.started, TestAppLifecycleState.error],
      TestAppLifecycleState.stopping: [TestAppLifecycleState.stopped, TestAppLifecycleState.error],
      TestAppLifecycleState.stopped: [TestAppLifecycleState.initializing],
      TestAppLifecycleState.error: [TestAppLifecycleState.initializing, TestAppLifecycleState.stopping],
    };
    
    return validTransitions[from]?.contains(to) ?? false;
  }
  
  /// 检查应用是否正在运行
  bool get isRunning => _currentState == TestAppLifecycleState.started;
  
  /// 检查应用是否已初始化
  bool get isInitialized => _currentState != TestAppLifecycleState.uninitialized;
  
  /// 获取状态持续时间
  Duration getStateDuration() {
    if (_eventHistory.isEmpty) return Duration.zero;
    
    final lastEvent = _eventHistory.last;
    return DateTime.now().difference(lastEvent.timestamp);
  }
  
  /// 获取状态统计
  Map<TestAppLifecycleState, int> getStateStatistics() {
    final stats = <TestAppLifecycleState, int>{};
    for (final event in _eventHistory) {
      stats[event.toState] = (stats[event.toState] ?? 0) + 1;
    }
    return stats;
  }
  
  /// 重置管理器
  Future<void> reset() async {
    if (_currentState != TestAppLifecycleState.stopped && 
        _currentState != TestAppLifecycleState.uninitialized) {
      await stopApplication();
    }
    
    _currentState = TestAppLifecycleState.uninitialized;
    _eventHistory.clear();
  }
  
  /// 清理资源
  void dispose() {
    _eventHistory.clear();
    _eventController.close();
    _stateController.close();
  }
}

void main() {
  group('AppLifecycleManager Tests', () {
    late TestAppLifecycleManager manager;
    
    setUp(() {
      manager = TestAppLifecycleManager();
    });
    
    tearDown(() {
      manager.dispose();
    });
    
    group('基础生命周期操作', () {
      test('应该能够初始化应用', () async {
        expect(manager.currentState, equals(TestAppLifecycleState.uninitialized));
        
        await manager.initialize();
        
        expect(manager.currentState, equals(TestAppLifecycleState.initialized));
        expect(manager.isInitialized, isTrue);
      });
      
      test('应该能够启动应用', () async {
        await manager.initialize();
        
        await manager.startApplication();
        
        expect(manager.currentState, equals(TestAppLifecycleState.started));
        expect(manager.isRunning, isTrue);
      });
      
      test('应该能够暂停和恢复应用', () async {
        await manager.initialize();
        await manager.startApplication();
        
        await manager.pauseApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.paused));
        expect(manager.isRunning, isFalse);
        
        await manager.resumeApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.started));
        expect(manager.isRunning, isTrue);
      });
      
      test('应该能够停止应用', () async {
        await manager.initialize();
        await manager.startApplication();
        
        await manager.stopApplication();
        
        expect(manager.currentState, equals(TestAppLifecycleState.stopped));
        expect(manager.isRunning, isFalse);
      });
    });
    
    group('状态转换验证', () {
      test('应该拒绝无效的状态转换', () async {
        // 尝试在未初始化时启动应用
        expect(
          () => manager.startApplication(),
          throwsA(isA<StateError>()),
        );
      });
      
      test('应该拒绝重复初始化', () async {
        await manager.initialize();
        
        expect(
          () => manager.initialize(),
          throwsA(isA<StateError>()),
        );
      });
      
      test('应该拒绝在错误状态下暂停', () async {
        // 在未启动状态下暂停
        await manager.initialize();
        
        expect(
          () => manager.pauseApplication(),
          throwsA(isA<StateError>()),
        );
      });
    });
    
    group('事件历史和监控', () {
      test('应该记录所有状态转换事件', () async {
        await manager.initialize();
        await manager.startApplication();
        await manager.pauseApplication();
        await manager.resumeApplication();
        
        final history = manager.eventHistory;
        expect(history.length, equals(8)); // 每个操作包含2个状态转换
        
        // 验证事件顺序
        expect(history[0].toState, equals(TestAppLifecycleState.initializing));
        expect(history[1].toState, equals(TestAppLifecycleState.initialized));
        expect(history[2].toState, equals(TestAppLifecycleState.starting));
        expect(history[3].toState, equals(TestAppLifecycleState.started));
      });
      
      test('应该提供状态统计信息', () async {
        await manager.initialize();
        await manager.startApplication();
        await manager.pauseApplication();
        await manager.resumeApplication();
        
        final stats = manager.getStateStatistics();
        expect(stats[TestAppLifecycleState.started], equals(2)); // 启动和恢复后
        expect(stats[TestAppLifecycleState.paused], equals(1));
      });
      
      test('应该计算状态持续时间', () async {
        await manager.initialize();
        
        await Future.delayed(const Duration(milliseconds: 50));
        
        final duration = manager.getStateDuration();
        expect(duration.inMilliseconds, greaterThan(40));
      });
    });
    
    group('事件流监听', () {
      test('应该能够监听生命周期事件', () async {
        final receivedEvents = <TestLifecycleEvent>[];
        final subscription = manager.eventStream.listen((event) {
          receivedEvents.add(event);
        });
        
        await manager.initialize();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedEvents.length, equals(2));
        expect(receivedEvents[0].toState, equals(TestAppLifecycleState.initializing));
        expect(receivedEvents[1].toState, equals(TestAppLifecycleState.initialized));
        
        await subscription.cancel();
      });
      
      test('应该能够监听状态变更', () async {
        final receivedStates = <TestAppLifecycleState>[];
        final subscription = manager.stateStream.listen((state) {
          receivedStates.add(state);
        });
        
        await manager.initialize();
        await manager.startApplication();
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedStates.length, equals(4));
        expect(receivedStates.last, equals(TestAppLifecycleState.started));
        
        await subscription.cancel();
      });
    });
    
    group('完整生命周期测试', () {
      test('应该支持完整的生命周期流程', () async {
        // 完整流程：初始化 -> 启动 -> 暂停 -> 恢复 -> 停止
        await manager.initialize();
        expect(manager.currentState, equals(TestAppLifecycleState.initialized));
        
        await manager.startApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.started));
        
        await manager.pauseApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.paused));
        
        await manager.resumeApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.started));
        
        await manager.stopApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.stopped));
        
        // 验证事件历史完整性
        final history = manager.eventHistory;
        expect(history.length, equals(10)); // 5个操作 × 2个状态转换
      });
      
      test('应该支持重置和重新启动', () async {
        await manager.initialize();
        await manager.startApplication();
        
        await manager.reset();
        expect(manager.currentState, equals(TestAppLifecycleState.uninitialized));
        expect(manager.eventHistory.isEmpty, isTrue);
        
        // 重新启动
        await manager.initialize();
        await manager.startApplication();
        expect(manager.isRunning, isTrue);
      });
    });
    
    group('错误处理', () {
      test('应该处理停止已停止的应用', () async {
        await manager.initialize();
        await manager.startApplication();
        await manager.stopApplication();
        
        // 再次停止不应该抛出错误
        await manager.stopApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.stopped));
      });
      
      test('应该处理从不同状态停止应用', () async {
        await manager.initialize();
        await manager.startApplication();
        await manager.pauseApplication();
        
        // 从暂停状态停止
        await manager.stopApplication();
        expect(manager.currentState, equals(TestAppLifecycleState.stopped));
      });
    });
  });
}
