/*
---------------------------------------------------------------
File name:          navigation_state_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.2 导航状态保持管理器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.2 - 实现页面状态保持、恢复、缓存管理;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:communication_system/communication_system.dart' as comm;

/// 页面状态条目
class PageStateEntry {
  final String routeId;
  final String route;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> state;
  final DateTime timestamp;
  final Duration? ttl;
  final bool persistent;

  const PageStateEntry({
    required this.routeId,
    required this.route,
    required this.parameters,
    required this.state,
    required this.timestamp,
    this.ttl,
    this.persistent = false,
  });

  /// 是否已过期
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'route': route,
      'parameters': parameters,
      'state': state,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl?.inMilliseconds,
      'persistent': persistent,
    };
  }

  /// 从JSON创建
  factory PageStateEntry.fromJson(Map<String, dynamic> json) {
    return PageStateEntry(
      routeId: json['routeId'],
      route: json['route'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      state: Map<String, dynamic>.from(json['state'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      ttl: json['ttl'] != null ? Duration(milliseconds: json['ttl']) : null,
      persistent: json['persistent'] ?? false,
    );
  }

  @override
  String toString() {
    return 'PageStateEntry(routeId: $routeId, route: $route, expired: $isExpired)';
  }
}

/// 状态保持策略
enum StateRetentionPolicy {
  /// 不保持状态
  none,
  
  /// 保持到页面销毁
  untilDestroy,
  
  /// 保持指定时间
  timed,
  
  /// 永久保持
  persistent,
  
  /// 基于内存压力自动管理
  automatic,
}

/// 导航状态管理器
/// 
/// Phase 3.3.2.2 核心功能：
/// - 页面状态保持和恢复
/// - 状态缓存管理
/// - 内存优化
/// - 状态持久化
/// - 自动清理机制
class NavigationStateManager {
  NavigationStateManager._();
  
  static final NavigationStateManager _instance = NavigationStateManager._();
  static NavigationStateManager get instance => _instance;

  /// 统一消息总线
  final comm.UnifiedMessageBus _messageBus = comm.UnifiedMessageBus.instance;

  /// 状态缓存
  final Map<String, PageStateEntry> _stateCache = {};
  
  /// 路由状态映射
  final Map<String, String> _routeStateMapping = {};
  
  /// 清理定时器
  Timer? _cleanupTimer;
  
  /// 最大缓存大小
  final int _maxCacheSize = 50;
  
  /// 默认TTL
  final Duration _defaultTtl = const Duration(hours: 1);
  
  /// 状态变更流
  final StreamController<Map<String, PageStateEntry>> _stateController = 
      StreamController<Map<String, PageStateEntry>>.broadcast();

  /// 初始化状态管理器
  Future<void> initialize() async {
    try {
      await _loadPersistedStates();
      _startCleanupTimer();
      debugPrint('NavigationStateManager initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize NavigationStateManager: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 保存页面状态
  Future<void> savePageState({
    required String route,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> state,
    StateRetentionPolicy policy = StateRetentionPolicy.untilDestroy,
    Duration? customTtl,
  }) async {
    final routeId = _generateRouteId(route, parameters ?? {});
    
    Duration? ttl;
    bool persistent = false;
    
    switch (policy) {
      case StateRetentionPolicy.none:
        return; // 不保存状态
      case StateRetentionPolicy.untilDestroy:
        ttl = null; // 无过期时间，手动清理
        break;
      case StateRetentionPolicy.timed:
        ttl = customTtl ?? _defaultTtl;
        break;
      case StateRetentionPolicy.persistent:
        persistent = true;
        ttl = null;
        break;
      case StateRetentionPolicy.automatic:
        ttl = _calculateAutomaticTtl(state);
        break;
    }

    final entry = PageStateEntry(
      routeId: routeId,
      route: route,
      parameters: parameters ?? {},
      state: state,
      timestamp: DateTime.now(),
      ttl: ttl,
      persistent: persistent,
    );

    _stateCache[routeId] = entry;
    _routeStateMapping[route] = routeId;

    // 限制缓存大小
    await _enforceMaxCacheSize();

    // 持久化状态（如果需要）
    if (persistent) {
      await _persistState(entry);
    }

    _notifyStateChanged();
    
    _messageBus.publishEvent(
      'navigation_state',
      'state_saved',
      {
        'routeId': routeId,
        'route': route,
        'policy': policy.name,
        'stateSize': _calculateStateSize(state),
      },
    );

    debugPrint('Saved state for: $route (policy: ${policy.name})');
  }

  /// 恢复页面状态
  Map<String, dynamic>? restorePageState({
    required String route,
    Map<String, dynamic>? parameters,
  }) {
    final routeId = _generateRouteId(route, parameters ?? {});
    final entry = _stateCache[routeId];
    
    if (entry == null) {
      debugPrint('No state found for: $route');
      return null;
    }

    if (entry.isExpired) {
      _removeState(routeId);
      debugPrint('State expired for: $route');
      return null;
    }

    _messageBus.publishEvent(
      'navigation_state',
      'state_restored',
      {
        'routeId': routeId,
        'route': route,
        'stateAge': DateTime.now().difference(entry.timestamp).inSeconds,
      },
    );

    debugPrint('Restored state for: $route');
    return Map<String, dynamic>.from(entry.state);
  }

  /// 清除页面状态
  void clearPageState({
    required String route,
    Map<String, dynamic>? parameters,
  }) {
    final routeId = _generateRouteId(route, parameters ?? {});
    _removeState(routeId);
    
    _messageBus.publishEvent(
      'navigation_state',
      'state_cleared',
      {'routeId': routeId, 'route': route},
    );

    debugPrint('Cleared state for: $route');
  }

  /// 清除所有状态
  Future<void> clearAllStates() async {
    final count = _stateCache.length;
    _stateCache.clear();
    _routeStateMapping.clear();
    
    await _clearPersistedStates();
    _notifyStateChanged();
    
    _messageBus.publishEvent(
      'navigation_state',
      'all_states_cleared',
      {'clearedCount': count},
    );

    debugPrint('Cleared all states ($count entries)');
  }

  /// 获取状态信息
  Map<String, dynamic> getStateInfo({
    required String route,
    Map<String, dynamic>? parameters,
  }) {
    final routeId = _generateRouteId(route, parameters ?? {});
    final entry = _stateCache[routeId];
    
    if (entry == null) {
      return {'exists': false};
    }

    return {
      'exists': true,
      'route': entry.route,
      'timestamp': entry.timestamp.toIso8601String(),
      'isExpired': entry.isExpired,
      'persistent': entry.persistent,
      'stateSize': _calculateStateSize(entry.state),
      'ttl': entry.ttl?.inMilliseconds,
    };
  }

  /// 预加载状态
  Future<void> preloadState({
    required String route,
    Map<String, dynamic>? parameters,
    required Map<String, dynamic> state,
  }) async {
    await savePageState(
      route: route,
      parameters: parameters,
      state: state,
      policy: StateRetentionPolicy.timed,
      customTtl: const Duration(minutes: 30),
    );
  }

  /// 生成路由ID
  String _generateRouteId(String route, Map<String, dynamic> parameters) {
    final paramString = parameters.isEmpty 
        ? '' 
        : '_${parameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    return '$route$paramString';
  }

  /// 移除状态
  void _removeState(String routeId) {
    final entry = _stateCache.remove(routeId);
    if (entry != null) {
      _routeStateMapping.remove(entry.route);
      _notifyStateChanged();
    }
  }

  /// 计算自动TTL
  Duration _calculateAutomaticTtl(Map<String, dynamic> state) {
    final stateSize = _calculateStateSize(state);
    
    // 根据状态大小调整TTL
    if (stateSize < 1024) { // < 1KB
      return const Duration(hours: 2);
    } else if (stateSize < 10240) { // < 10KB
      return const Duration(hours: 1);
    } else {
      return const Duration(minutes: 30);
    }
  }

  /// 计算状态大小
  int _calculateStateSize(Map<String, dynamic> state) {
    try {
      return utf8.encode(jsonEncode(state)).length;
    } catch (e) {
      return 0;
    }
  }

  /// 强制执行最大缓存大小
  Future<void> _enforceMaxCacheSize() async {
    if (_stateCache.length <= _maxCacheSize) return;

    // 按时间戳排序，移除最旧的非持久化状态
    final entries = _stateCache.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final toRemove = <String>[];
    for (final entry in entries) {
      if (!entry.persistent && toRemove.length < _stateCache.length - _maxCacheSize) {
        toRemove.add(entry.routeId);
      }
    }

    for (final routeId in toRemove) {
      _removeState(routeId);
    }

    debugPrint('Enforced cache size limit, removed ${toRemove.length} entries');
  }

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpiredStates();
    });
  }

  /// 清理过期状态
  void _cleanupExpiredStates() {
    final expiredIds = <String>[];
    
    for (final entry in _stateCache.values) {
      if (entry.isExpired) {
        expiredIds.add(entry.routeId);
      }
    }

    for (final routeId in expiredIds) {
      _removeState(routeId);
    }

    if (expiredIds.isNotEmpty) {
      debugPrint('Cleaned up ${expiredIds.length} expired states');
    }
  }

  /// 通知状态变更
  void _notifyStateChanged() {
    _stateController.add(Map.unmodifiable(_stateCache));
  }

  /// 加载持久化状态
  Future<void> _loadPersistedStates() async {
    // 这里可以从本地存储加载持久化状态
    // 暂时使用空实现
  }

  /// 持久化状态
  Future<void> _persistState(PageStateEntry entry) async {
    // 这里可以将状态保存到本地存储
    // 暂时使用空实现
  }

  /// 清除持久化状态
  Future<void> _clearPersistedStates() async {
    // 这里可以清除本地存储的状态
    // 暂时使用空实现
  }

  /// 获取所有状态
  Map<String, PageStateEntry> get allStates => Map.unmodifiable(_stateCache);

  /// 获取缓存统计
  Map<String, dynamic> get cacheStats {
    final totalSize = _stateCache.values
        .map((entry) => _calculateStateSize(entry.state))
        .fold(0, (sum, size) => sum + size);
    
    final expiredCount = _stateCache.values
        .where((entry) => entry.isExpired)
        .length;
    
    final persistentCount = _stateCache.values
        .where((entry) => entry.persistent)
        .length;

    return {
      'totalEntries': _stateCache.length,
      'totalSize': totalSize,
      'expiredCount': expiredCount,
      'persistentCount': persistentCount,
      'maxCacheSize': _maxCacheSize,
    };
  }

  /// 状态流
  Stream<Map<String, PageStateEntry>> get stateStream => _stateController.stream;

  /// 清理资源
  void dispose() {
    _cleanupTimer?.cancel();
    _stateController.close();
    
    debugPrint('NavigationStateManager disposed');
  }
}
