/*
---------------------------------------------------------------
File name:          module_loader_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        模块加载器测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 模块状态
enum TestModuleState {
  unloaded,
  loading,
  loaded,
  initializing,
  initialized,
  starting,
  started,
  stopping,
  stopped,
  error,
}

/// 模块依赖
class TestModuleDependency {
  final String moduleId;
  final String version;
  final bool optional;
  
  const TestModuleDependency({
    required this.moduleId,
    required this.version,
    this.optional = false,
  });
}

/// 模块信息
class TestModuleInfo {
  final String id;
  final String name;
  final String version;
  final List<TestModuleDependency> dependencies;
  final Map<String, dynamic> config;
  TestModuleState state;
  
  TestModuleInfo({
    required this.id,
    required this.name,
    required this.version,
    List<TestModuleDependency>? dependencies,
    Map<String, dynamic>? config,
    this.state = TestModuleState.unloaded,
  }) : dependencies = dependencies ?? [],
       config = config ?? {};
}

/// 模块加载事件
class TestModuleLoadEvent {
  final String moduleId;
  final TestModuleState fromState;
  final TestModuleState toState;
  final DateTime timestamp;
  final String? error;
  
  TestModuleLoadEvent({
    required this.moduleId,
    required this.fromState,
    required this.toState,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 简化的模块加载器（测试版本）
class TestModuleLoader {
  final Map<String, TestModuleInfo> _modules = {};
  final List<TestModuleLoadEvent> _loadHistory = [];
  final StreamController<TestModuleLoadEvent> _eventController = StreamController<TestModuleLoadEvent>.broadcast();
  
  Stream<TestModuleLoadEvent> get eventStream => _eventController.stream;
  List<TestModuleLoadEvent> get loadHistory => List.unmodifiable(_loadHistory);
  
  /// 注册模块
  void registerModule(TestModuleInfo module) {
    _modules[module.id] = module;
  }
  
  /// 加载模块
  Future<bool> loadModule(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null) {
      _addEvent(moduleId, TestModuleState.unloaded, TestModuleState.error, 'Module not found');
      return false;
    }
    
    if (module.state != TestModuleState.unloaded) {
      return module.state == TestModuleState.loaded || module.state == TestModuleState.started;
    }
    
    try {
      // 检查依赖
      if (!await _checkDependencies(module)) {
        _addEvent(moduleId, module.state, TestModuleState.error, 'Dependency check failed');
        module.state = TestModuleState.error;
        return false;
      }
      
      // 加载模块
      _addEvent(moduleId, module.state, TestModuleState.loading);
      module.state = TestModuleState.loading;
      
      await Future.delayed(const Duration(milliseconds: 100)); // 模拟加载时间
      
      _addEvent(moduleId, module.state, TestModuleState.loaded);
      module.state = TestModuleState.loaded;
      
      return true;
    } catch (e) {
      _addEvent(moduleId, module.state, TestModuleState.error, e.toString());
      module.state = TestModuleState.error;
      return false;
    }
  }
  
  /// 卸载模块
  Future<bool> unloadModule(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null || module.state == TestModuleState.unloaded) {
      return true;
    }
    
    try {
      // 检查是否有其他模块依赖此模块
      if (_hasDependents(moduleId)) {
        _addEvent(moduleId, module.state, TestModuleState.error, 'Module has dependents');
        return false;
      }
      
      // 停止模块（如果正在运行）
      if (module.state == TestModuleState.started) {
        await stopModule(moduleId);
      }
      
      _addEvent(moduleId, module.state, TestModuleState.unloaded);
      module.state = TestModuleState.unloaded;
      
      return true;
    } catch (e) {
      _addEvent(moduleId, module.state, TestModuleState.error, e.toString());
      module.state = TestModuleState.error;
      return false;
    }
  }
  
  /// 初始化模块
  Future<bool> initializeModule(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null || module.state != TestModuleState.loaded) {
      return false;
    }
    
    try {
      _addEvent(moduleId, module.state, TestModuleState.initializing);
      module.state = TestModuleState.initializing;
      
      await Future.delayed(const Duration(milliseconds: 50)); // 模拟初始化时间
      
      _addEvent(moduleId, module.state, TestModuleState.initialized);
      module.state = TestModuleState.initialized;
      
      return true;
    } catch (e) {
      _addEvent(moduleId, module.state, TestModuleState.error, e.toString());
      module.state = TestModuleState.error;
      return false;
    }
  }
  
  /// 启动模块
  Future<bool> startModule(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null || module.state != TestModuleState.initialized) {
      return false;
    }
    
    try {
      _addEvent(moduleId, module.state, TestModuleState.starting);
      module.state = TestModuleState.starting;
      
      await Future.delayed(const Duration(milliseconds: 75)); // 模拟启动时间
      
      _addEvent(moduleId, module.state, TestModuleState.started);
      module.state = TestModuleState.started;
      
      return true;
    } catch (e) {
      _addEvent(moduleId, module.state, TestModuleState.error, e.toString());
      module.state = TestModuleState.error;
      return false;
    }
  }
  
  /// 停止模块
  Future<bool> stopModule(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null || module.state != TestModuleState.started) {
      return true;
    }
    
    try {
      _addEvent(moduleId, module.state, TestModuleState.stopping);
      module.state = TestModuleState.stopping;
      
      await Future.delayed(const Duration(milliseconds: 50)); // 模拟停止时间
      
      _addEvent(moduleId, module.state, TestModuleState.stopped);
      module.state = TestModuleState.stopped;
      
      return true;
    } catch (e) {
      _addEvent(moduleId, module.state, TestModuleState.error, e.toString());
      module.state = TestModuleState.error;
      return false;
    }
  }
  
  /// 批量加载模块
  Future<Map<String, bool>> loadModules(List<String> moduleIds) async {
    final results = <String, bool>{};
    
    // 按依赖顺序排序
    final sortedIds = _sortByDependencies(moduleIds);
    
    for (final moduleId in sortedIds) {
      results[moduleId] = await loadModule(moduleId);
    }
    
    return results;
  }
  
  /// 检查模块依赖
  Future<bool> _checkDependencies(TestModuleInfo module) async {
    for (final dependency in module.dependencies) {
      final depModule = _modules[dependency.moduleId];
      
      if (depModule == null) {
        if (!dependency.optional) {
          return false;
        }
        continue;
      }
      
      // 如果依赖模块未加载，尝试加载
      if (depModule.state == TestModuleState.unloaded) {
        if (!await loadModule(dependency.moduleId)) {
          return !dependency.optional;
        }
      }
      
      // 检查版本兼容性
      if (!_isVersionCompatible(depModule.version, dependency.version)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 检查是否有其他模块依赖指定模块
  bool _hasDependents(String moduleId) {
    return _modules.values.any((module) =>
      module.state != TestModuleState.unloaded &&
      module.dependencies.any((dep) => dep.moduleId == moduleId)
    );
  }
  
  /// 按依赖关系排序模块
  List<String> _sortByDependencies(List<String> moduleIds) {
    final sorted = <String>[];
    final visited = <String>{};
    final visiting = <String>{};
    
    void visit(String moduleId) {
      if (visited.contains(moduleId)) return;
      if (visiting.contains(moduleId)) {
        throw StateError('Circular dependency detected: $moduleId');
      }
      
      visiting.add(moduleId);
      
      final module = _modules[moduleId];
      if (module != null) {
        for (final dep in module.dependencies) {
          if (moduleIds.contains(dep.moduleId)) {
            visit(dep.moduleId);
          }
        }
      }
      
      visiting.remove(moduleId);
      visited.add(moduleId);
      sorted.add(moduleId);
    }
    
    for (final moduleId in moduleIds) {
      visit(moduleId);
    }
    
    return sorted;
  }
  
  /// 检查版本兼容性
  bool _isVersionCompatible(String moduleVersion, String requiredVersion) {
    // 简化的版本检查：只检查主版本号
    final moduleMajor = int.tryParse(moduleVersion.split('.').first) ?? 0;
    final requiredMajor = int.tryParse(requiredVersion.split('.').first) ?? 0;
    return moduleMajor >= requiredMajor;
  }
  
  /// 添加事件
  void _addEvent(String moduleId, TestModuleState fromState, TestModuleState toState, [String? error]) {
    final event = TestModuleLoadEvent(
      moduleId: moduleId,
      fromState: fromState,
      toState: toState,
      error: error,
    );
    
    _loadHistory.add(event);
    _eventController.add(event);
  }
  
  /// 获取模块状态
  TestModuleState? getModuleState(String moduleId) {
    return _modules[moduleId]?.state;
  }
  
  /// 获取已加载的模块列表
  List<String> get loadedModules {
    return _modules.entries
        .where((entry) => entry.value.state == TestModuleState.loaded || 
                         entry.value.state == TestModuleState.started)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 获取模块信息
  TestModuleInfo? getModuleInfo(String moduleId) {
    return _modules[moduleId];
  }
  
  /// 检查模块是否已加载
  bool isModuleLoaded(String moduleId) {
    final state = getModuleState(moduleId);
    return state == TestModuleState.loaded || 
           state == TestModuleState.initialized ||
           state == TestModuleState.started;
  }
  
  /// 获取加载统计
  Map<TestModuleState, int> getLoadStatistics() {
    final stats = <TestModuleState, int>{};
    for (final module in _modules.values) {
      stats[module.state] = (stats[module.state] ?? 0) + 1;
    }
    return stats;
  }
  
  /// 清理资源
  void dispose() {
    _modules.clear();
    _loadHistory.clear();
    _eventController.close();
  }
}

void main() {
  group('ModuleLoader Tests', () {
    late TestModuleLoader loader;
    
    setUp(() {
      loader = TestModuleLoader();
      
      // 注册测试模块
      loader.registerModule(TestModuleInfo(
        id: 'core',
        name: 'Core Module',
        version: '1.0.0',
      ));
      
      loader.registerModule(TestModuleInfo(
        id: 'ui',
        name: 'UI Module',
        version: '1.0.0',
        dependencies: [
          const TestModuleDependency(moduleId: 'core', version: '1.0.0'),
        ],
      ));
      
      loader.registerModule(TestModuleInfo(
        id: 'plugin',
        name: 'Plugin Module',
        version: '1.0.0',
        dependencies: [
          const TestModuleDependency(moduleId: 'core', version: '1.0.0'),
          const TestModuleDependency(moduleId: 'ui', version: '1.0.0'),
        ],
      ));
      
      loader.registerModule(TestModuleInfo(
        id: 'optional',
        name: 'Optional Module',
        version: '1.0.0',
        dependencies: [
          const TestModuleDependency(moduleId: 'nonexistent', version: '1.0.0', optional: true),
        ],
      ));
    });
    
    tearDown(() {
      loader.dispose();
    });
    
    group('基础模块操作', () {
      test('应该能够加载单个模块', () async {
        final result = await loader.loadModule('core');
        
        expect(result, isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.loaded));
        expect(loader.isModuleLoaded('core'), isTrue);
      });
      
      test('应该能够卸载模块', () async {
        await loader.loadModule('core');
        
        final result = await loader.unloadModule('core');
        
        expect(result, isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.unloaded));
      });
      
      test('应该拒绝加载不存在的模块', () async {
        final result = await loader.loadModule('nonexistent');
        
        expect(result, isFalse);
      });
    });
    
    group('模块生命周期', () {
      test('应该支持完整的模块生命周期', () async {
        // 加载 -> 初始化 -> 启动 -> 停止 -> 卸载
        expect(await loader.loadModule('core'), isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.loaded));
        
        expect(await loader.initializeModule('core'), isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.initialized));
        
        expect(await loader.startModule('core'), isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.started));
        
        expect(await loader.stopModule('core'), isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.stopped));
        
        expect(await loader.unloadModule('core'), isTrue);
        expect(loader.getModuleState('core'), equals(TestModuleState.unloaded));
      });
    });
    
    group('依赖管理', () {
      test('应该自动加载依赖模块', () async {
        final result = await loader.loadModule('ui');
        
        expect(result, isTrue);
        expect(loader.isModuleLoaded('core'), isTrue); // 依赖应该被自动加载
        expect(loader.isModuleLoaded('ui'), isTrue);
      });
      
      test('应该按依赖顺序批量加载模块', () async {
        final results = await loader.loadModules(['plugin', 'ui', 'core']);
        
        expect(results['core'], isTrue);
        expect(results['ui'], isTrue);
        expect(results['plugin'], isTrue);
        
        // 验证加载顺序（通过事件历史）
        final coreLoadEvent = loader.loadHistory.firstWhere(
          (event) => event.moduleId == 'core' && event.toState == TestModuleState.loaded
        );
        final uiLoadEvent = loader.loadHistory.firstWhere(
          (event) => event.moduleId == 'ui' && event.toState == TestModuleState.loaded
        );
        
        expect(coreLoadEvent.timestamp.isBefore(uiLoadEvent.timestamp), isTrue);
      });
      
      test('应该处理可选依赖', () async {
        final result = await loader.loadModule('optional');
        
        expect(result, isTrue); // 即使可选依赖不存在也应该成功
        expect(loader.isModuleLoaded('optional'), isTrue);
      });
      
      test('应该防止卸载有依赖的模块', () async {
        await loader.loadModule('ui'); // 这会自动加载core
        
        final result = await loader.unloadModule('core');
        
        expect(result, isFalse); // 不能卸载，因为ui依赖core
      });
    });
    
    group('错误处理', () {
      test('应该处理循环依赖', () {
        // 创建循环依赖
        loader.registerModule(TestModuleInfo(
          id: 'circular_a',
          name: 'Circular A',
          version: '1.0.0',
          dependencies: [
            const TestModuleDependency(moduleId: 'circular_b', version: '1.0.0'),
          ],
        ));
        
        loader.registerModule(TestModuleInfo(
          id: 'circular_b',
          name: 'Circular B',
          version: '1.0.0',
          dependencies: [
            const TestModuleDependency(moduleId: 'circular_a', version: '1.0.0'),
          ],
        ));
        
        expect(
          () => loader.loadModules(['circular_a', 'circular_b']),
          throwsA(isA<StateError>()),
        );
      });
    });
    
    group('监控和统计', () {
      test('应该记录加载事件历史', () async {
        await loader.loadModule('core');
        
        final history = loader.loadHistory;
        expect(history.length, equals(2)); // loading -> loaded
        expect(history[0].toState, equals(TestModuleState.loading));
        expect(history[1].toState, equals(TestModuleState.loaded));
      });
      
      test('应该提供加载统计', () async {
        await loader.loadModule('core');
        await loader.loadModule('ui');
        
        final stats = loader.getLoadStatistics();
        expect(stats[TestModuleState.loaded], equals(2));
        expect(stats[TestModuleState.unloaded], equals(2)); // plugin和optional
      });
      
      test('应该能够监听加载事件', () async {
        final receivedEvents = <TestModuleLoadEvent>[];
        final subscription = loader.eventStream.listen((event) {
          receivedEvents.add(event);
        });
        
        await loader.loadModule('core');
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedEvents.length, equals(2));
        expect(receivedEvents[0].toState, equals(TestModuleState.loading));
        expect(receivedEvents[1].toState, equals(TestModuleState.loaded));
        
        await subscription.cancel();
      });
    });
    
    group('模块信息查询', () {
      test('应该能够获取模块信息', () {
        final info = loader.getModuleInfo('core');
        
        expect(info, isNotNull);
        expect(info!.name, equals('Core Module'));
        expect(info.version, equals('1.0.0'));
      });
      
      test('应该能够获取已加载模块列表', () async {
        await loader.loadModule('core');
        await loader.loadModule('ui');
        
        final loadedModules = loader.loadedModules;
        expect(loadedModules.length, equals(2));
        expect(loadedModules, contains('core'));
        expect(loadedModules, contains('ui'));
      });
    });
  });
}
