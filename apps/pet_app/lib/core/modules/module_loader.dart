/*
---------------------------------------------------------------
File name:          module_loader.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        模块加载器 - Phase 3.1 核心组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现模块加载顺序管理、依赖解析、生命周期管理;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 模块状态
enum ModuleState {
  /// 未加载
  unloaded,
  /// 加载中
  loading,
  /// 已加载
  loaded,
  /// 初始化中
  initializing,
  /// 已初始化
  initialized,
  /// 启动中
  starting,
  /// 运行中
  running,
  /// 暂停中
  pausing,
  /// 已暂停
  paused,
  /// 停止中
  stopping,
  /// 已停止
  stopped,
  /// 错误状态
  error,
}

/// 模块信息
class ModuleInfo {
  final String id;
  final String name;
  final String version;
  final List<String> dependencies;
  final int priority;
  final bool required;
  
  ModuleInfo({
    required this.id,
    required this.name,
    required this.version,
    this.dependencies = const [],
    this.priority = 0,
    this.required = false,
  });
}

/// 模块实例
class ModuleInstance {
  final ModuleInfo info;
  final dynamic module;
  ModuleState state;
  DateTime? loadedAt;
  DateTime? initializedAt;
  DateTime? startedAt;
  String? errorMessage;
  
  ModuleInstance({
    required this.info,
    required this.module,
    this.state = ModuleState.unloaded,
  });
}

/// 模块加载事件
class ModuleLoadEvent {
  final String moduleId;
  final ModuleState state;
  final DateTime timestamp;
  final String? error;
  
  ModuleLoadEvent({
    required this.moduleId,
    required this.state,
    required this.timestamp,
    this.error,
  });
}

/// 模块加载器
/// 
/// Phase 3.1 核心功能：
/// - 模块加载顺序管理
/// - 依赖关系解析
/// - 模块生命周期管理
/// - 错误处理和恢复
class ModuleLoader {
  static final ModuleLoader _instance = ModuleLoader._();
  static ModuleLoader get instance => _instance;
  
  ModuleLoader._();

  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 已加载的模块
  final Map<String, ModuleInstance> _modules = {};
  
  /// 模块加载事件流控制器
  final StreamController<ModuleLoadEvent> _eventController = 
      StreamController<ModuleLoadEvent>.broadcast();
  
  /// 模块定义
  final Map<String, ModuleInfo> _moduleDefinitions = {};

  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 获取已加载的模块
  Map<String, ModuleInstance> get modules => Map.unmodifiable(_modules);
  
  /// 获取模块加载事件流
  Stream<ModuleLoadEvent> get eventStream => _eventController.stream;

  /// 初始化模块加载器
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('warning', '模块加载器已经初始化');
      return;
    }

    try {
      _log('info', '初始化模块加载器');
      
      // 注册内置模块定义
      _registerBuiltinModules();
      
      _isInitialized = true;
      _log('info', '模块加载器初始化完成');
      
    } catch (e, stackTrace) {
      _log('severe', '模块加载器初始化失败', e, stackTrace);
      rethrow;
    }
  }

  /// 加载模块
  Future<void> loadModule(String moduleId) async {
    await _ensureInitialized();
    
    if (_modules.containsKey(moduleId)) {
      _log('warning', '模块已加载: $moduleId');
      return;
    }

    final moduleInfo = _moduleDefinitions[moduleId];
    if (moduleInfo == null) {
      throw Exception('未找到模块定义: $moduleId');
    }

    try {
      _log('info', '开始加载模块: $moduleId');
      
      // 检查并加载依赖
      await _loadDependencies(moduleInfo);
      
      // 创建模块实例
      final module = await _createModuleInstance(moduleInfo);
      
      final instance = ModuleInstance(
        info: moduleInfo,
        module: module,
        state: ModuleState.loaded,
      );
      instance.loadedAt = DateTime.now();
      
      _modules[moduleId] = instance;
      
      // 发送加载事件
      _emitEvent(moduleId, ModuleState.loaded);
      
      _log('info', '模块加载完成: $moduleId');
      
    } catch (e, stackTrace) {
      _log('severe', '模块加载失败: $moduleId', e, stackTrace);
      
      // 记录错误状态
      final errorInstance = ModuleInstance(
        info: moduleInfo,
        module: null,
        state: ModuleState.error,
      );
      errorInstance.errorMessage = e.toString();
      _modules[moduleId] = errorInstance;
      
      // 发送错误事件
      _emitEvent(moduleId, ModuleState.error, e.toString());
      
      rethrow;
    }
  }

  /// 初始化模块
  Future<void> initializeModule(String moduleId) async {
    final instance = _modules[moduleId];
    if (instance == null) {
      throw Exception('模块未加载: $moduleId');
    }

    if (instance.state == ModuleState.initialized) {
      _log('warning', '模块已初始化: $moduleId');
      return;
    }

    try {
      _log('info', '开始初始化模块: $moduleId');
      
      instance.state = ModuleState.initializing;
      _emitEvent(moduleId, ModuleState.initializing);
      
      // 调用模块初始化方法
      if (instance.module != null && instance.module.initialize != null) {
        await instance.module.initialize();
      }
      
      instance.state = ModuleState.initialized;
      instance.initializedAt = DateTime.now();
      
      _emitEvent(moduleId, ModuleState.initialized);
      _log('info', '模块初始化完成: $moduleId');
      
    } catch (e, stackTrace) {
      _log('severe', '模块初始化失败: $moduleId', e, stackTrace);
      
      instance.state = ModuleState.error;
      instance.errorMessage = e.toString();
      
      _emitEvent(moduleId, ModuleState.error, e.toString());
      rethrow;
    }
  }

  /// 启动模块
  Future<void> startModule(String moduleId) async {
    final instance = _modules[moduleId];
    if (instance == null) {
      throw Exception('模块未加载: $moduleId');
    }

    if (instance.state == ModuleState.running) {
      _log('warning', '模块已运行: $moduleId');
      return;
    }

    try {
      _log('info', '开始启动模块: $moduleId');
      
      // 确保模块已初始化
      if (instance.state != ModuleState.initialized) {
        await initializeModule(moduleId);
      }
      
      instance.state = ModuleState.starting;
      _emitEvent(moduleId, ModuleState.starting);
      
      // 调用模块启动方法
      if (instance.module != null && instance.module.start != null) {
        await instance.module.start();
      }
      
      instance.state = ModuleState.running;
      instance.startedAt = DateTime.now();
      
      _emitEvent(moduleId, ModuleState.running);
      _log('info', '模块启动完成: $moduleId');
      
    } catch (e, stackTrace) {
      _log('severe', '模块启动失败: $moduleId', e, stackTrace);
      
      instance.state = ModuleState.error;
      instance.errorMessage = e.toString();
      
      _emitEvent(moduleId, ModuleState.error, e.toString());
      rethrow;
    }
  }

  /// 停止模块
  Future<void> stopModule(String moduleId) async {
    final instance = _modules[moduleId];
    if (instance == null) {
      _log('warning', '模块未加载: $moduleId');
      return;
    }

    try {
      _log('info', '开始停止模块: $moduleId');
      
      instance.state = ModuleState.stopping;
      _emitEvent(moduleId, ModuleState.stopping);
      
      // 调用模块停止方法
      if (instance.module != null && instance.module.stop != null) {
        await instance.module.stop();
      }
      
      instance.state = ModuleState.stopped;
      _emitEvent(moduleId, ModuleState.stopped);
      
      _log('info', '模块停止完成: $moduleId');
      
    } catch (e, stackTrace) {
      _log('severe', '模块停止失败: $moduleId', e, stackTrace);
      
      instance.state = ModuleState.error;
      instance.errorMessage = e.toString();
      
      _emitEvent(moduleId, ModuleState.error, e.toString());
    }
  }

  /// 获取模块状态
  ModuleState? getModuleState(String moduleId) {
    return _modules[moduleId]?.state;
  }

  /// 获取运行中的模块列表
  List<String> getRunningModules() {
    return _modules.entries
        .where((entry) => entry.value.state == ModuleState.running)
        .map((entry) => entry.key)
        .toList();
  }

  /// 注册内置模块定义
  void _registerBuiltinModules() {
    // Plugin System
    _moduleDefinitions['plugin_system'] = ModuleInfo(
      id: 'plugin_system',
      name: 'Plugin System',
      version: '1.3.0',
      dependencies: [],
      priority: 100,
      required: true,
    );
    
    // Creative Workshop
    _moduleDefinitions['creative_workshop'] = ModuleInfo(
      id: 'creative_workshop',
      name: 'Creative Workshop',
      version: '1.4.0',
      dependencies: ['plugin_system'],
      priority: 90,
      required: true,
    );
    
    // Home Dashboard
    _moduleDefinitions['home_dashboard'] = ModuleInfo(
      id: 'home_dashboard',
      name: 'Home Dashboard',
      version: '1.0.0',
      dependencies: ['plugin_system'],
      priority: 80,
      required: true,
    );
    
    // App Manager
    _moduleDefinitions['app_manager'] = ModuleInfo(
      id: 'app_manager',
      name: 'App Manager',
      version: '1.0.0',
      dependencies: ['plugin_system'],
      priority: 70,
      required: true,
    );
    
    // Settings System
    _moduleDefinitions['settings_system'] = ModuleInfo(
      id: 'settings_system',
      name: 'Settings System',
      version: '1.0.0',
      dependencies: [],
      priority: 60,
      required: true,
    );
  }

  /// 加载依赖模块
  Future<void> _loadDependencies(ModuleInfo moduleInfo) async {
    for (final dependency in moduleInfo.dependencies) {
      if (!_modules.containsKey(dependency)) {
        await loadModule(dependency);
      }
    }
  }

  /// 创建模块实例
  Future<dynamic> _createModuleInstance(ModuleInfo moduleInfo) async {
    // TODO: 实际实现中，这里会动态加载模块
    // 目前返回模拟实例
    return _MockModule(moduleInfo.id);
  }

  /// 发送模块事件
  void _emitEvent(String moduleId, ModuleState state, [String? error]) {
    final event = ModuleLoadEvent(
      moduleId: moduleId,
      state: state,
      timestamp: DateTime.now(),
      error: error,
    );
    
    _eventController.add(event);
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 日志记录
  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [ModuleLoader] [$level] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}

/// 模拟模块类
class _MockModule {
  final String id;
  
  _MockModule(this.id);
  
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> start() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
  
  Future<void> stop() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
