/*
---------------------------------------------------------------
File name:          cross_module_event_router.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.2 跨模块事件路由器 - 标准化事件传递
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.2 - 实现跨模块事件路由、过滤、优先级管理;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'unified_message_bus.dart';
// import 'module_communication_coordinator.dart' as comm; // 暂时未使用

/// 事件路由规则
class EventRoutingRule {
  const EventRoutingRule({
    required this.id,
    required this.sourcePattern,
    required this.targetPattern,
    required this.actionPattern,
    this.priority = 0,
    this.enabled = true,
    this.description,
  });

  /// 规则ID
  final String id;

  /// 源模块匹配模式（支持通配符）
  final String sourcePattern;

  /// 目标模块匹配模式（支持通配符）
  final String targetPattern;

  /// 动作匹配模式（支持通配符）
  final String actionPattern;

  /// 规则优先级
  final int priority;

  /// 是否启用
  final bool enabled;

  /// 规则描述
  final String? description;

  /// 检查是否匹配
  bool matches(String sourceId, String targetId, String action) {
    if (!enabled) return false;

    return _matchesPattern(sourceId, sourcePattern) &&
        _matchesPattern(targetId, targetPattern) &&
        _matchesPattern(action, actionPattern);
  }

  /// 模式匹配（支持通配符 * 和 ?）
  bool _matchesPattern(String value, String pattern) {
    if (pattern == '*') return true;
    if (pattern == value) return true;

    // 简单的通配符匹配
    final regexPattern = pattern.replaceAll('*', '.*').replaceAll('?', '.');

    return RegExp('^$regexPattern\$').hasMatch(value);
  }

  @override
  String toString() {
    return 'EventRoutingRule(id: $id, source: $sourcePattern, '
        'target: $targetPattern, action: $actionPattern, priority: $priority)';
  }
}

/// 事件过滤器
abstract class EventFilter {
  /// 过滤器名称
  String get name;

  /// 过滤器描述
  String get description;

  /// 是否允许事件通过
  bool shouldAllow(UnifiedMessage message);
}

/// 基于发送者的过滤器
class SenderBasedFilter extends EventFilter {
  SenderBasedFilter({required this.allowedSenders, this.isWhitelist = true});

  final Set<String> allowedSenders;
  final bool isWhitelist;

  @override
  String get name => 'SenderBasedFilter';

  @override
  String get description => isWhitelist
      ? 'Whitelist filter for senders: ${allowedSenders.join(", ")}'
      : 'Blacklist filter for senders: ${allowedSenders.join(", ")}';

  @override
  bool shouldAllow(UnifiedMessage message) {
    final contains = allowedSenders.contains(message.senderId);
    return isWhitelist ? contains : !contains;
  }
}

/// 基于动作的过滤器
class ActionBasedFilter extends EventFilter {
  ActionBasedFilter({required this.allowedActions, this.isWhitelist = true});

  final Set<String> allowedActions;
  final bool isWhitelist;

  @override
  String get name => 'ActionBasedFilter';

  @override
  String get description => isWhitelist
      ? 'Whitelist filter for actions: ${allowedActions.join(", ")}'
      : 'Blacklist filter for actions: ${allowedActions.join(", ")}';

  @override
  bool shouldAllow(UnifiedMessage message) {
    final contains = allowedActions.contains(message.action);
    return isWhitelist ? contains : !contains;
  }
}

/// 基于时间的过滤器
class TimeBasedFilter extends EventFilter {
  TimeBasedFilter({this.startTime, this.endTime, this.allowedDays = const {}});

  final DateTime? startTime;
  final DateTime? endTime;
  final Set<int> allowedDays; // 1-7 (Monday-Sunday)

  @override
  String get name => 'TimeBasedFilter';

  @override
  String get description => 'Time-based filter';

  @override
  bool shouldAllow(UnifiedMessage message) {
    final now = DateTime.now();

    // 检查时间范围
    if (startTime != null && now.isBefore(startTime!)) return false;
    if (endTime != null && now.isAfter(endTime!)) return false;

    // 检查允许的星期几
    if (allowedDays.isNotEmpty && !allowedDays.contains(now.weekday)) {
      return false;
    }

    return true;
  }
}

/// 跨模块事件路由器
///
/// Phase 3.2.2 核心功能：
/// - 标准化事件路由规则
/// - 事件过滤和转换
/// - 优先级管理
/// - 路由性能监控
/// - 动态路由配置
class CrossModuleEventRouter {
  CrossModuleEventRouter._();

  static final CrossModuleEventRouter _instance = CrossModuleEventRouter._();
  static CrossModuleEventRouter get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 通信协调器 (暂时未使用)
  // final comm.ModuleCommunicationCoordinator _coordinator =
  //     comm.ModuleCommunicationCoordinator.instance;

  /// 路由规则
  final Map<String, EventRoutingRule> _routingRules = {};

  /// 事件过滤器
  final Map<String, EventFilter> _eventFilters = {};

  /// 路由统计
  final Map<String, int> _routingStats = {};

  /// 路由性能统计
  final Map<String, List<int>> _routingPerformance = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化事件路由器
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 注册默认路由规则
      _registerDefaultRoutingRules();

      // 注册默认过滤器
      _registerDefaultFilters();

      // 订阅所有消息进行路由处理
      _messageBus.subscribe(_handleMessage);

      _isInitialized = true;
      debugPrint('CrossModuleEventRouter initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize CrossModuleEventRouter: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 注册默认路由规则
  void _registerDefaultRoutingRules() {
    // 系统级事件路由
    addRoutingRule(
      const EventRoutingRule(
        id: 'system_broadcast',
        sourcePattern: 'system',
        targetPattern: '*',
        actionPattern: 'system_*',
        priority: 100,
        description: '系统广播事件路由',
      ),
    );

    // 插件间通信路由
    addRoutingRule(
      const EventRoutingRule(
        id: 'plugin_communication',
        sourcePattern: '*_plugin',
        targetPattern: '*_plugin',
        actionPattern: 'plugin_*',
        priority: 80,
        description: '插件间通信路由',
      ),
    );

    // 模块状态变更路由
    addRoutingRule(
      const EventRoutingRule(
        id: 'module_status_change',
        sourcePattern: '*',
        targetPattern: 'pet_app_main',
        actionPattern: 'module_status_changed',
        priority: 90,
        description: '模块状态变更通知路由',
      ),
    );

    // 用户界面事件路由
    addRoutingRule(
      const EventRoutingRule(
        id: 'ui_events',
        sourcePattern: 'ui_*',
        targetPattern: '*',
        actionPattern: 'ui_*',
        priority: 70,
        description: '用户界面事件路由',
      ),
    );
  }

  /// 注册默认过滤器
  void _registerDefaultFilters() {
    // 系统事件过滤器
    addEventFilter(
      'system_events',
      SenderBasedFilter(
        allowedSenders: {'system', 'pet_app_main'},
        isWhitelist: true,
      ),
    );

    // 调试事件过滤器（在生产环境中可以禁用）
    if (kDebugMode) {
      addEventFilter(
        'debug_events',
        ActionBasedFilter(
          allowedActions: {'debug_*', 'test_*'},
          isWhitelist: true,
        ),
      );
    }

    // 工作时间过滤器（示例）
    addEventFilter(
      'business_hours',
      TimeBasedFilter(
        allowedDays: {1, 2, 3, 4, 5}, // Monday to Friday
      ),
    );
  }

  /// 添加路由规则
  void addRoutingRule(EventRoutingRule rule) {
    _routingRules[rule.id] = rule;
    debugPrint('Added routing rule: ${rule.id}');
  }

  /// 移除路由规则
  void removeRoutingRule(String ruleId) {
    _routingRules.remove(ruleId);
    debugPrint('Removed routing rule: $ruleId');
  }

  /// 添加事件过滤器
  void addEventFilter(String filterId, EventFilter filter) {
    _eventFilters[filterId] = filter;
    debugPrint('Added event filter: $filterId (${filter.name})');
  }

  /// 移除事件过滤器
  void removeEventFilter(String filterId) {
    _eventFilters.remove(filterId);
    debugPrint('Removed event filter: $filterId');
  }

  /// 处理消息路由
  Future<Map<String, dynamic>?> _handleMessage(UnifiedMessage message) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      // 应用事件过滤器
      if (!_shouldAllowMessage(message)) {
        _updateRoutingStats('filtered');
        return null;
      }

      // 查找匹配的路由规则
      final matchingRules = _findMatchingRules(message);

      if (matchingRules.isEmpty) {
        _updateRoutingStats('no_route');
        return null;
      }

      // 按优先级排序
      matchingRules.sort((a, b) => b.priority.compareTo(a.priority));

      // 执行路由
      for (final rule in matchingRules) {
        await _executeRouting(message, rule);
      }

      _updateRoutingStats('routed');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error in message routing: $e');
      debugPrint('Stack trace: $stackTrace');
      _updateRoutingStats('error');
      return null;
    } finally {
      // 更新性能统计
      final processingTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _updateRoutingPerformance(message.action, processingTime);
    }
  }

  /// 检查消息是否应该被允许
  bool _shouldAllowMessage(UnifiedMessage message) {
    for (final filter in _eventFilters.values) {
      if (!filter.shouldAllow(message)) {
        return false;
      }
    }
    return true;
  }

  /// 查找匹配的路由规则
  List<EventRoutingRule> _findMatchingRules(UnifiedMessage message) {
    final matchingRules = <EventRoutingRule>[];

    for (final rule in _routingRules.values) {
      final targetId = message.targetId ?? '*';
      if (rule.matches(message.senderId, targetId, message.action)) {
        matchingRules.add(rule);
      }
    }

    return matchingRules;
  }

  /// 执行路由
  Future<void> _executeRouting(
    UnifiedMessage message,
    EventRoutingRule rule,
  ) async {
    try {
      // 这里可以添加路由转换逻辑
      // 例如：修改消息格式、添加路由信息等

      // 记录路由执行
      debugPrint('Routing message ${message.id} via rule ${rule.id}');

      // 可以在这里添加路由后的处理逻辑
      // 例如：日志记录、监控、转换等
    } catch (e, stackTrace) {
      debugPrint('Error executing routing rule ${rule.id}: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 更新路由统计
  void _updateRoutingStats(String action) {
    _routingStats[action] = (_routingStats[action] ?? 0) + 1;
  }

  /// 更新路由性能统计
  void _updateRoutingPerformance(String action, int processingTime) {
    _routingPerformance.putIfAbsent(action, () => []);
    _routingPerformance[action]!.add(processingTime);

    // 保持最近100条记录
    if (_routingPerformance[action]!.length > 100) {
      _routingPerformance[action]!.removeAt(0);
    }
  }

  /// 获取路由规则列表
  List<EventRoutingRule> get routingRules =>
      List.unmodifiable(_routingRules.values);

  /// 获取事件过滤器列表
  Map<String, EventFilter> get eventFilters => Map.unmodifiable(_eventFilters);

  /// 获取路由统计
  Map<String, int> get routingStats => Map.unmodifiable(_routingStats);

  /// 获取路由性能统计
  Map<String, double> getRoutingPerformanceStats() {
    final Map<String, double> avgStats = {};

    for (final entry in _routingPerformance.entries) {
      if (entry.value.isNotEmpty) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        avgStats[entry.key] = avg;
      }
    }

    return avgStats;
  }

  /// 清理资源
  void dispose() {
    _routingRules.clear();
    _eventFilters.clear();
    _routingStats.clear();
    _routingPerformance.clear();
    _isInitialized = false;

    debugPrint('CrossModuleEventRouter disposed');
  }
}
