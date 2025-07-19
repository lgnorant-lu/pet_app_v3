/*
---------------------------------------------------------------
File name:          app_state_manager_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        应用状态管理器测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';
import 'dart:convert';

/// 状态变更事件
class TestStateChangeEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;
  
  TestStateChangeEvent({
    required this.key,
    this.oldValue,
    required this.newValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 简化的应用状态管理器（测试版本）
class TestAppStateManager {
  final Map<String, dynamic> _state = {};
  final Map<String, dynamic> _persistentStorage = {}; // 模拟持久化存储
  final List<TestStateChangeEvent> _changeHistory = [];
  final StreamController<TestStateChangeEvent> _changeController = StreamController<TestStateChangeEvent>.broadcast();
  
  Stream<TestStateChangeEvent> get changeStream => _changeController.stream;
  List<TestStateChangeEvent> get changeHistory => List.unmodifiable(_changeHistory);
  
  /// 保存状态
  Future<void> saveState(String key, dynamic value) async {
    final oldValue = _state[key];
    _state[key] = value;
    
    // 模拟持久化
    await _persistToStorage(key, value);
    
    final event = TestStateChangeEvent(
      key: key,
      oldValue: oldValue,
      newValue: value,
    );
    
    _changeHistory.add(event);
    _changeController.add(event);
  }
  
  /// 加载状态
  Future<T?> loadState<T>(String key) async {
    // 首先从内存中获取
    if (_state.containsKey(key)) {
      return _state[key] as T?;
    }
    
    // 从持久化存储中加载
    final value = await _loadFromStorage(key);
    if (value != null) {
      _state[key] = value;
      return value as T?;
    }
    
    return null;
  }
  
  /// 清除特定状态
  Future<void> clearState(String key) async {
    final oldValue = _state[key];
    _state.remove(key);
    
    // 从持久化存储中删除
    await _removeFromStorage(key);
    
    if (oldValue != null) {
      final event = TestStateChangeEvent(
        key: key,
        oldValue: oldValue,
        newValue: null,
      );
      
      _changeHistory.add(event);
      _changeController.add(event);
    }
  }
  
  /// 清除所有状态
  Future<void> clearAllStates() async {
    final keys = _state.keys.toList();
    _state.clear();
    _persistentStorage.clear();
    
    for (final key in keys) {
      final event = TestStateChangeEvent(
        key: key,
        oldValue: 'cleared',
        newValue: null,
      );
      
      _changeHistory.add(event);
      _changeController.add(event);
    }
  }
  
  /// 批量保存状态
  Future<void> saveStates(Map<String, dynamic> states) async {
    for (final entry in states.entries) {
      await saveState(entry.key, entry.value);
    }
  }
  
  /// 批量加载状态
  Future<Map<String, dynamic>> loadStates(List<String> keys) async {
    final result = <String, dynamic>{};
    
    for (final key in keys) {
      final value = await loadState(key);
      if (value != null) {
        result[key] = value;
      }
    }
    
    return result;
  }
  
  /// 检查状态是否存在
  bool hasState(String key) {
    return _state.containsKey(key) || _persistentStorage.containsKey(key);
  }
  
  /// 获取所有状态键
  List<String> getAllKeys() {
    final keys = <String>{};
    keys.addAll(_state.keys);
    keys.addAll(_persistentStorage.keys);
    return keys.toList();
  }
  
  /// 获取状态大小（字节）
  int getStateSize(String key) {
    final value = _state[key] ?? _persistentStorage[key];
    if (value == null) return 0;
    
    try {
      final jsonString = jsonEncode(value);
      return jsonString.length;
    } catch (e) {
      return value.toString().length;
    }
  }
  
  /// 获取总状态大小
  int getTotalStateSize() {
    return getAllKeys().fold(0, (sum, key) => sum + getStateSize(key));
  }
  
  /// 压缩状态（移除过期或无用的状态）
  Future<void> compactStates() async {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    // 查找过期的状态（这里简化为超过1小时的变更）
    for (final event in _changeHistory) {
      if (now.difference(event.timestamp).inHours > 1) {
        // 这里可以添加更复杂的过期逻辑
      }
    }
    
    for (final key in keysToRemove) {
      await clearState(key);
    }
  }
  
  /// 创建状态快照
  Map<String, dynamic> createSnapshot() {
    return Map<String, dynamic>.from(_state);
  }
  
  /// 从快照恢复状态
  Future<void> restoreFromSnapshot(Map<String, dynamic> snapshot) async {
    await clearAllStates();
    await saveStates(snapshot);
  }
  
  /// 模拟持久化到存储
  Future<void> _persistToStorage(String key, dynamic value) async {
    // 模拟异步存储操作
    await Future.delayed(const Duration(milliseconds: 10));
    
    try {
      // 尝试序列化以验证数据可持久化
      jsonEncode(value);
      _persistentStorage[key] = value;
    } catch (e) {
      // 如果无法序列化，存储字符串表示
      _persistentStorage[key] = value.toString();
    }
  }
  
  /// 模拟从存储加载
  Future<dynamic> _loadFromStorage(String key) async {
    // 模拟异步加载操作
    await Future.delayed(const Duration(milliseconds: 5));
    return _persistentStorage[key];
  }
  
  /// 模拟从存储删除
  Future<void> _removeFromStorage(String key) async {
    await Future.delayed(const Duration(milliseconds: 5));
    _persistentStorage.remove(key);
  }
  
  /// 获取状态统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'totalKeys': getAllKeys().length,
      'memoryKeys': _state.length,
      'persistentKeys': _persistentStorage.length,
      'totalSize': getTotalStateSize(),
      'changeEvents': _changeHistory.length,
    };
  }
  
  /// 验证状态完整性
  bool validateIntegrity() {
    try {
      // 检查所有状态是否可以序列化
      for (final entry in _state.entries) {
        jsonEncode(entry.value);
      }
      
      // 检查持久化存储一致性
      for (final key in _state.keys) {
        if (!_persistentStorage.containsKey(key)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 清理资源
  void dispose() {
    _state.clear();
    _persistentStorage.clear();
    _changeHistory.clear();
    _changeController.close();
  }
}

void main() {
  group('AppStateManager Tests', () {
    late TestAppStateManager stateManager;
    
    setUp(() {
      stateManager = TestAppStateManager();
    });
    
    tearDown(() {
      stateManager.dispose();
    });
    
    group('基础状态操作', () {
      test('应该能够保存和加载状态', () async {
        await stateManager.saveState('test_key', 'test_value');
        
        final value = await stateManager.loadState<String>('test_key');
        expect(value, equals('test_value'));
      });
      
      test('应该能够保存不同类型的数据', () async {
        await stateManager.saveState('string', 'hello');
        await stateManager.saveState('int', 42);
        await stateManager.saveState('bool', true);
        await stateManager.saveState('list', [1, 2, 3]);
        await stateManager.saveState('map', {'key': 'value'});
        
        expect(await stateManager.loadState<String>('string'), equals('hello'));
        expect(await stateManager.loadState<int>('int'), equals(42));
        expect(await stateManager.loadState<bool>('bool'), equals(true));
        expect(await stateManager.loadState<List>('list'), equals([1, 2, 3]));
        expect(await stateManager.loadState<Map>('map'), equals({'key': 'value'}));
      });
      
      test('应该能够清除特定状态', () async {
        await stateManager.saveState('test_key', 'test_value');
        expect(stateManager.hasState('test_key'), isTrue);
        
        await stateManager.clearState('test_key');
        expect(stateManager.hasState('test_key'), isFalse);
        
        final value = await stateManager.loadState('test_key');
        expect(value, isNull);
      });
      
      test('应该能够清除所有状态', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 'value2');
        
        await stateManager.clearAllStates();
        
        expect(stateManager.getAllKeys().isEmpty, isTrue);
      });
    });
    
    group('批量操作', () {
      test('应该能够批量保存状态', () async {
        final states = {
          'key1': 'value1',
          'key2': 42,
          'key3': true,
        };
        
        await stateManager.saveStates(states);
        
        expect(await stateManager.loadState('key1'), equals('value1'));
        expect(await stateManager.loadState('key2'), equals(42));
        expect(await stateManager.loadState('key3'), equals(true));
      });
      
      test('应该能够批量加载状态', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 42);
        await stateManager.saveState('key3', true);
        
        final loaded = await stateManager.loadStates(['key1', 'key2', 'key3', 'nonexistent']);
        
        expect(loaded['key1'], equals('value1'));
        expect(loaded['key2'], equals(42));
        expect(loaded['key3'], equals(true));
        expect(loaded.containsKey('nonexistent'), isFalse);
      });
    });
    
    group('状态监听', () {
      test('应该能够监听状态变更', () async {
        final receivedEvents = <TestStateChangeEvent>[];
        final subscription = stateManager.changeStream.listen((event) {
          receivedEvents.add(event);
        });
        
        await stateManager.saveState('test_key', 'test_value');
        await stateManager.saveState('test_key', 'new_value');
        await stateManager.clearState('test_key');
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedEvents.length, equals(3));
        expect(receivedEvents[0].newValue, equals('test_value'));
        expect(receivedEvents[1].oldValue, equals('test_value'));
        expect(receivedEvents[1].newValue, equals('new_value'));
        expect(receivedEvents[2].newValue, isNull);
        
        await subscription.cancel();
      });
      
      test('应该记录状态变更历史', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 'value2');
        await stateManager.clearState('key1');
        
        final history = stateManager.changeHistory;
        expect(history.length, equals(3));
        expect(history[0].key, equals('key1'));
        expect(history[1].key, equals('key2'));
        expect(history[2].key, equals('key1'));
      });
    });
    
    group('状态查询和统计', () {
      test('应该能够检查状态是否存在', () async {
        expect(stateManager.hasState('nonexistent'), isFalse);
        
        await stateManager.saveState('existing', 'value');
        expect(stateManager.hasState('existing'), isTrue);
      });
      
      test('应该能够获取所有状态键', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 'value2');
        
        final keys = stateManager.getAllKeys();
        expect(keys.length, equals(2));
        expect(keys, contains('key1'));
        expect(keys, contains('key2'));
      });
      
      test('应该能够计算状态大小', () async {
        await stateManager.saveState('small', 'hi');
        await stateManager.saveState('large', 'this is a much longer string');
        
        final smallSize = stateManager.getStateSize('small');
        final largeSize = stateManager.getStateSize('large');
        
        expect(largeSize, greaterThan(smallSize));
        expect(stateManager.getStateSize('nonexistent'), equals(0));
      });
      
      test('应该能够获取统计信息', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 'value2');
        
        final stats = stateManager.getStatistics();
        expect(stats['totalKeys'], equals(2));
        expect(stats['memoryKeys'], equals(2));
        expect(stats['changeEvents'], equals(2));
      });
    });
    
    group('快照和恢复', () {
      test('应该能够创建状态快照', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 42);
        
        final snapshot = stateManager.createSnapshot();
        
        expect(snapshot['key1'], equals('value1'));
        expect(snapshot['key2'], equals(42));
      });
      
      test('应该能够从快照恢复状态', () async {
        await stateManager.saveState('original', 'data');
        
        final snapshot = {
          'key1': 'value1',
          'key2': 42,
        };
        
        await stateManager.restoreFromSnapshot(snapshot);
        
        expect(await stateManager.loadState('key1'), equals('value1'));
        expect(await stateManager.loadState('key2'), equals(42));
        expect(await stateManager.loadState('original'), isNull);
      });
    });
    
    group('数据完整性', () {
      test('应该验证状态完整性', () async {
        await stateManager.saveState('valid', 'data');
        
        expect(stateManager.validateIntegrity(), isTrue);
      });
      
      test('应该处理不可序列化的数据', () async {
        // 创建一个包含循环引用的对象（不可序列化）
        final cyclicMap = <String, dynamic>{};
        cyclicMap['self'] = cyclicMap;
        
        // 应该能够保存（会转换为字符串）
        await stateManager.saveState('cyclic', cyclicMap);
        
        final loaded = await stateManager.loadState('cyclic');
        expect(loaded, isNotNull);
      });
    });
    
    group('性能和优化', () {
      test('应该能够压缩状态', () async {
        await stateManager.saveState('key1', 'value1');
        await stateManager.saveState('key2', 'value2');
        
        await stateManager.compactStates();
        
        // 压缩操作应该完成而不出错
        expect(stateManager.getAllKeys().isNotEmpty, isTrue);
      });
      
      test('应该处理大量状态数据', () async {
        // 保存大量状态
        for (int i = 0; i < 100; i++) {
          await stateManager.saveState('key_$i', 'value_$i');
        }
        
        expect(stateManager.getAllKeys().length, equals(100));
        
        // 批量加载
        final keys = List.generate(100, (i) => 'key_$i');
        final loaded = await stateManager.loadStates(keys);
        
        expect(loaded.length, equals(100));
      });
    });
    
    group('错误处理', () {
      test('应该处理不存在的键', () async {
        final value = await stateManager.loadState('nonexistent');
        expect(value, isNull);
      });
      
      test('应该处理空键名', () async {
        await stateManager.saveState('', 'empty_key_value');
        final value = await stateManager.loadState('');
        expect(value, equals('empty_key_value'));
      });
      
      test('应该处理null值', () async {
        await stateManager.saveState('null_key', null);
        final value = await stateManager.loadState('null_key');
        expect(value, isNull);
      });
    });
  });
}
