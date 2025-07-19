/*
---------------------------------------------------------------
File name:          app_lifecycle_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        应用生命周期管理器 - Phase 3.1 核心组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现应用生命周期管理、状态监控、资源管理;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 应用生命周期状态
enum AppLifecyclePhase {
  /// 启动中
  starting,
  /// 运行中
  running,
  /// 暂停中
  paused,
  /// 后台运行
  background,
  /// 恢复中
  resuming,
  /// 停止中
  stopping,
  /// 已停止
  stopped,
}

/// 应用生命周期事件
class AppLifecycleEvent {
  final AppLifecyclePhase phase;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  AppLifecycleEvent({
    required this.phase,
    required this.timestamp,
    this.data = const {},
  });
}

/// 应用生命周期监听器
abstract class AppLifecycleListener {
  /// 生命周期状态变更
  void onLifecycleChanged(AppLifecycleEvent event);
  
  /// 应用启动完成
  void onAppStarted() {}
  
  /// 应用进入后台
  void onAppPaused() {}
  
  /// 应用恢复前台
  void onAppResumed() {}
  
  /// 应用即将停止
  void onAppStopping() {}
}

/// 应用生命周期管理器
/// 
/// Phase 3.1 核心功能：
/// - 应用启动流程优化
/// - 生命周期状态监控
/// - 资源管理和清理
/// - 性能监控
class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._();
  static AppLifecycleManager get instance => _instance;
  
  AppLifecycleManager._();

  /// 当前生命周期阶段
  AppLifecyclePhase _currentPhase = AppLifecyclePhase.starting;
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 生命周期监听器列表
  final List<AppLifecycleListener> _listeners = [];
  
  /// 生命周期事件流控制器
  final StreamController<AppLifecycleEvent> _eventController = 
      StreamController<AppLifecycleEvent>.broadcast();
  
  /// 启动时间
  DateTime? _startTime;
  
  /// 性能指标
  final Map<String, dynamic> _performanceMetrics = {};

  /// 获取当前生命周期阶段
  AppLifecyclePhase get currentPhase => _currentPhase;
  
  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 获取生命周期事件流
  Stream<AppLifecycleEvent> get eventStream => _eventController.stream;
  
  /// 获取启动时间
  DateTime? get startTime => _startTime;
  
  /// 获取运行时长（毫秒）
  int? get uptime => _startTime?.let((start) => 
      DateTime.now().difference(start).inMilliseconds);

  /// 初始化生命周期管理器
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('warning', '应用生命周期管理器已经初始化');
      return;
    }

    try {
      _log('info', '初始化应用生命周期管理器');
      
      _startTime = DateTime.now();
      
      // 设置初始状态
      _setPhase(AppLifecyclePhase.starting);
      
      // 初始化性能监控
      _initializePerformanceMonitoring();
      
      _isInitialized = true;
      _log('info', '应用生命周期管理器初始化完成');
      
    } catch (e, stackTrace) {
      _log('severe', '应用生命周期管理器初始化失败', e, stackTrace);
      rethrow;
    }
  }

  /// 添加生命周期监听器
  void addListener(AppLifecycleListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      _log('info', '添加生命周期监听器: ${listener.runtimeType}');
    }
  }

  /// 移除生命周期监听器
  void removeListener(AppLifecycleListener listener) {
    if (_listeners.remove(listener)) {
      _log('info', '移除生命周期监听器: ${listener.runtimeType}');
    }
  }

  /// 处理Flutter应用生命周期变更
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// 标记应用启动完成
  void markAppStarted() {
    _setPhase(AppLifecyclePhase.running);
    
    // 计算启动时间
    if (_startTime != null) {
      final startupTime = DateTime.now().difference(_startTime!).inMilliseconds;
      _performanceMetrics['startup_time_ms'] = startupTime;
      _log('info', '应用启动完成，耗时: ${startupTime}ms');
    }
    
    // 通知监听器
    for (final listener in _listeners) {
      try {
        listener.onAppStarted();
      } catch (e) {
        _log('warning', '生命周期监听器处理启动事件失败: ${listener.runtimeType}', e);
      }
    }
  }

  /// 开始应用停止流程
  Future<void> stopApp() async {
    _log('info', '开始应用停止流程');
    
    _setPhase(AppLifecyclePhase.stopping);
    
    // 通知监听器
    for (final listener in _listeners) {
      try {
        listener.onAppStopping();
      } catch (e) {
        _log('warning', '生命周期监听器处理停止事件失败: ${listener.runtimeType}', e);
      }
    }
    
    // 清理资源
    await _cleanup();
    
    _setPhase(AppLifecyclePhase.stopped);
    _log('info', '应用停止流程完成');
  }

  /// 获取性能指标
  Map<String, dynamic> getPerformanceMetrics() {
    final metrics = Map<String, dynamic>.from(_performanceMetrics);
    
    // 添加实时指标
    if (_startTime != null) {
      metrics['uptime_ms'] = uptime;
    }
    metrics['current_phase'] = _currentPhase.name;
    metrics['listeners_count'] = _listeners.length;
    
    return metrics;
  }

  /// 设置生命周期阶段
  void _setPhase(AppLifecyclePhase phase) {
    if (_currentPhase == phase) return;
    
    final oldPhase = _currentPhase;
    _currentPhase = phase;
    
    _log('info', '生命周期阶段变更: $oldPhase -> $phase');
    
    // 发送事件
    final event = AppLifecycleEvent(
      phase: phase,
      timestamp: DateTime.now(),
      data: {
        'previous_phase': oldPhase.name,
        'uptime_ms': uptime,
      },
    );
    
    _eventController.add(event);
    
    // 通知监听器
    for (final listener in _listeners) {
      try {
        listener.onLifecycleChanged(event);
      } catch (e) {
        _log('warning', '生命周期监听器处理事件失败: ${listener.runtimeType}', e);
      }
    }
  }

  /// 处理应用恢复
  void _handleAppResumed() {
    _log('info', '应用恢复前台');
    _setPhase(AppLifecyclePhase.running);
    
    for (final listener in _listeners) {
      try {
        listener.onAppResumed();
      } catch (e) {
        _log('warning', '生命周期监听器处理恢复事件失败: ${listener.runtimeType}', e);
      }
    }
  }

  /// 处理应用暂停
  void _handleAppPaused() {
    _log('info', '应用进入后台');
    _setPhase(AppLifecyclePhase.background);
    
    for (final listener in _listeners) {
      try {
        listener.onAppPaused();
      } catch (e) {
        _log('warning', '生命周期监听器处理暂停事件失败: ${listener.runtimeType}', e);
      }
    }
  }

  /// 处理应用分离
  void _handleAppDetached() {
    _log('info', '应用分离');
    _setPhase(AppLifecyclePhase.stopped);
  }

  /// 处理应用非活跃
  void _handleAppInactive() {
    _log('info', '应用非活跃');
    _setPhase(AppLifecyclePhase.paused);
  }

  /// 处理应用隐藏
  void _handleAppHidden() {
    _log('info', '应用隐藏');
    _setPhase(AppLifecyclePhase.background);
  }

  /// 初始化性能监控
  void _initializePerformanceMonitoring() {
    _performanceMetrics['initialized_at'] = DateTime.now().toIso8601String();
    _performanceMetrics['dart_version'] = '3.2+';
    _performanceMetrics['debug_mode'] = kDebugMode;
  }

  /// 清理资源
  Future<void> _cleanup() async {
    try {
      _log('info', '清理应用生命周期管理器资源');
      
      // 清理监听器
      _listeners.clear();
      
      // 关闭事件流
      await _eventController.close();
      
      _log('info', '应用生命周期管理器资源清理完成');
    } catch (e) {
      _log('warning', '清理应用生命周期管理器资源时发生错误', e);
    }
  }

  /// 日志记录
  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [AppLifecycleManager] [$level] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}

/// 扩展方法
extension on DateTime? {
  T? let<T>(T Function(DateTime) block) {
    final self = this;
    return self != null ? block(self) : null;
  }
}
