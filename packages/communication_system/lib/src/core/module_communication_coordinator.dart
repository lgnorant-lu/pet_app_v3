/*
---------------------------------------------------------------
File name:          module_communication_coordinator.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2 模块通信协调器 - 管理模块间通信
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.1 - 实现模块通信协调器，整合统一消息总线;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'unified_message_bus.dart';

/// 模块信息
class ModuleInfo {
  const ModuleInfo({
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    this.capabilities = const {},
    this.dependencies = const [],
    this.priority = 0,
  });

  /// 模块ID
  final String id;
  
  /// 模块名称
  final String name;
  
  /// 模块版本
  final String version;
  
  /// 模块类型
  final String type;
  
  /// 模块能力
  final Map<String, dynamic> capabilities;
  
  /// 模块依赖
  final List<String> dependencies;
  
  /// 模块优先级
  final int priority;

  @override
  String toString() {
    return 'ModuleInfo(id: $id, name: $name, version: $version, type: $type)';
  }
}

/// 模块状态
enum ModuleStatus {
  /// 未注册
  unregistered,
  
  /// 已注册
  registered,
  
  /// 初始化中
  initializing,
  
  /// 运行中
  running,
  
  /// 暂停
  paused,
  
  /// 停止
  stopped,
  
  /// 错误
  error,
}

/// 模块通信协调器
/// 
/// Phase 3.2.1 核心功能：
/// - 管理模块注册和生命周期
/// - 协调模块间通信
/// - 提供统一的通信接口
/// - 监控通信性能和状态
class ModuleCommunicationCoordinator {
  ModuleCommunicationCoordinator._();
  
  static final ModuleCommunicationCoordinator _instance = 
      ModuleCommunicationCoordinator._();
  static ModuleCommunicationCoordinator get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;
  
  /// 已注册的模块
  final Map<String, ModuleInfo> _registeredModules = {};
  
  /// 模块状态
  final Map<String, ModuleStatus> _moduleStatus = {};
  
  /// 模块订阅
  final Map<String, List<MessageSubscription>> _moduleSubscriptions = {};
  
  /// 模块通信统计
  final Map<String, Map<String, int>> _communicationStats = {};

  /// 注册模块
  /// 
  /// [moduleInfo] 模块信息
  void registerModule(ModuleInfo moduleInfo) {
    if (_registeredModules.containsKey(moduleInfo.id)) {
      throw ArgumentError('Module ${moduleInfo.id} is already registered');
    }

    _registeredModules[moduleInfo.id] = moduleInfo;
    _moduleStatus[moduleInfo.id] = ModuleStatus.registered;
    _moduleSubscriptions[moduleInfo.id] = [];
    _communicationStats[moduleInfo.id] = {};

    // 发布模块注册事件
    _messageBus.publishEvent(
      'system',
      'module_registered',
      {
        'moduleId': moduleInfo.id,
        'moduleName': moduleInfo.name,
        'moduleType': moduleInfo.type,
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: MessagePriority.high,
    );

    debugPrint('Module registered: ${moduleInfo.id}');
  }

  /// 注销模块
  /// 
  /// [moduleId] 模块ID
  void unregisterModule(String moduleId) {
    if (!_registeredModules.containsKey(moduleId)) {
      throw ArgumentError('Module $moduleId is not registered');
    }

    // 取消所有订阅
    final subscriptions = _moduleSubscriptions[moduleId] ?? [];
    for (final subscription in subscriptions) {
      subscription.cancel();
    }

    // 清理数据
    _registeredModules.remove(moduleId);
    _moduleStatus.remove(moduleId);
    _moduleSubscriptions.remove(moduleId);
    _communicationStats.remove(moduleId);

    // 发布模块注销事件
    _messageBus.publishEvent(
      'system',
      'module_unregistered',
      {
        'moduleId': moduleId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: MessagePriority.high,
    );

    debugPrint('Module unregistered: $moduleId');
  }

  /// 更新模块状态
  /// 
  /// [moduleId] 模块ID
  /// [status] 新状态
  void updateModuleStatus(String moduleId, ModuleStatus status) {
    if (!_registeredModules.containsKey(moduleId)) {
      throw ArgumentError('Module $moduleId is not registered');
    }

    final oldStatus = _moduleStatus[moduleId];
    _moduleStatus[moduleId] = status;

    // 发布状态变更事件
    _messageBus.publishEvent(
      'system',
      'module_status_changed',
      {
        'moduleId': moduleId,
        'oldStatus': oldStatus?.name,
        'newStatus': status.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: MessagePriority.normal,
    );

    debugPrint('Module $moduleId status changed: ${oldStatus?.name} -> ${status.name}');
  }

  /// 模块发布事件
  /// 
  /// [moduleId] 发送模块ID
  /// [action] 事件动作
  /// [data] 事件数据
  /// [priority] 消息优先级
  void publishEvent(
    String moduleId,
    String action,
    Map<String, dynamic> data, {
    MessagePriority priority = MessagePriority.normal,
  }) {
    _validateModule(moduleId);
    
    _messageBus.publishEvent(moduleId, action, data, priority: priority);
    _updateCommunicationStats(moduleId, 'event_published');
  }

  /// 模块发送请求
  /// 
  /// [senderId] 发送模块ID
  /// [targetId] 目标模块ID
  /// [action] 请求动作
  /// [data] 请求数据
  /// [timeoutMs] 超时时间
  /// [priority] 消息优先级
  Future<Map<String, dynamic>?> sendRequest(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data, {
    int timeoutMs = 5000,
    MessagePriority priority = MessagePriority.normal,
  }) async {
    _validateModule(senderId);
    _validateModule(targetId);

    try {
      final response = await _messageBus.sendRequest(
        senderId,
        targetId,
        action,
        data,
        timeoutMs: timeoutMs,
        priority: priority,
      );
      
      _updateCommunicationStats(senderId, 'request_sent');
      _updateCommunicationStats(targetId, 'request_received');
      
      return response;
    } catch (e) {
      _updateCommunicationStats(senderId, 'request_failed');
      rethrow;
    }
  }

  /// 模块发送通知
  /// 
  /// [senderId] 发送模块ID
  /// [targetId] 目标模块ID
  /// [action] 通知动作
  /// [data] 通知数据
  /// [priority] 消息优先级
  void sendNotification(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data, {
    MessagePriority priority = MessagePriority.normal,
  }) {
    _validateModule(senderId);
    _validateModule(targetId);

    _messageBus.sendNotification(senderId, targetId, action, data, priority: priority);
    _updateCommunicationStats(senderId, 'notification_sent');
    _updateCommunicationStats(targetId, 'notification_received');
  }

  /// 模块广播消息
  /// 
  /// [senderId] 发送模块ID
  /// [action] 广播动作
  /// [data] 广播数据
  /// [excludeIds] 排除的模块ID列表
  /// [priority] 消息优先级
  void broadcastMessage(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    List<String> excludeIds = const [],
    MessagePriority priority = MessagePriority.normal,
  }) {
    _validateModule(senderId);

    _messageBus.broadcastMessage(
      senderId,
      action,
      data,
      excludeIds: excludeIds,
      priority: priority,
    );
    
    _updateCommunicationStats(senderId, 'broadcast_sent');
    
    // 更新接收者统计
    for (final moduleId in _registeredModules.keys) {
      if (moduleId != senderId && !excludeIds.contains(moduleId)) {
        _updateCommunicationStats(moduleId, 'broadcast_received');
      }
    }
  }

  /// 模块订阅消息
  /// 
  /// [moduleId] 订阅模块ID
  /// [handler] 消息处理器
  /// [action] 订阅的动作
  /// [filter] 消息过滤器
  /// [senderId] 指定发送者ID
  /// [targetId] 指定目标ID
  MessageSubscription subscribeMessage(
    String moduleId,
    MessageHandler handler, {
    String? action,
    MessageFilter? filter,
    String? senderId,
    String? targetId,
  }) {
    _validateModule(moduleId);

    final subscription = _messageBus.subscribe(
      handler,
      action: action,
      filter: filter,
      senderId: senderId,
      targetId: targetId,
    );

    _moduleSubscriptions[moduleId]!.add(subscription);
    _updateCommunicationStats(moduleId, 'subscription_created');

    return subscription;
  }

  /// 验证模块是否已注册
  void _validateModule(String moduleId) {
    if (!_registeredModules.containsKey(moduleId)) {
      throw ArgumentError('Module $moduleId is not registered');
    }
  }

  /// 更新通信统计
  void _updateCommunicationStats(String moduleId, String action) {
    _communicationStats[moduleId]!.putIfAbsent(action, () => 0);
    _communicationStats[moduleId]![action] = 
        _communicationStats[moduleId]![action]! + 1;
  }

  /// 获取已注册的模块列表
  List<ModuleInfo> get registeredModules => 
      List.unmodifiable(_registeredModules.values);

  /// 获取模块信息
  ModuleInfo? getModuleInfo(String moduleId) => _registeredModules[moduleId];

  /// 获取模块状态
  ModuleStatus? getModuleStatus(String moduleId) => _moduleStatus[moduleId];

  /// 获取模块通信统计
  Map<String, int>? getModuleCommunicationStats(String moduleId) {
    final stats = _communicationStats[moduleId];
    return stats != null ? Map.unmodifiable(stats) : null;
  }

  /// 获取所有模块通信统计
  Map<String, Map<String, int>> get allCommunicationStats => 
      Map.unmodifiable(_communicationStats);

  /// 获取消息总线统计
  Map<String, int> get messageBusStats => _messageBus.messageStats;

  /// 获取性能统计
  Map<String, double> get performanceStats => _messageBus.getPerformanceStats();

  /// 清理资源
  void dispose() {
    // 取消所有订阅
    for (final subscriptions in _moduleSubscriptions.values) {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    }

    // 清理数据
    _registeredModules.clear();
    _moduleStatus.clear();
    _moduleSubscriptions.clear();
    _communicationStats.clear();

    debugPrint('ModuleCommunicationCoordinator disposed');
  }
}
