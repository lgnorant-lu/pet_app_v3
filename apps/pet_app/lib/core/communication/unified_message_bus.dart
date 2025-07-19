/*
---------------------------------------------------------------
File name:          unified_message_bus.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2 统一消息总线 - 模块间通信协调核心
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.1 - 实现统一消息总线，整合EventBus和PluginMessenger;
---------------------------------------------------------------
*/

import 'dart:async';
// import 'dart:collection'; // 暂时未使用
import 'package:flutter/foundation.dart';

/// 消息类型枚举
enum MessageType {
  /// 事件消息 - 发布订阅模式
  event,

  /// 请求消息 - 请求响应模式
  request,

  /// 响应消息 - 响应请求
  response,

  /// 通知消息 - 单向通知
  notification,

  /// 广播消息 - 多播消息
  broadcast,

  /// 同步消息 - 数据同步
  sync,
}

/// 消息优先级
enum MessagePriority {
  /// 低优先级
  low(0),

  /// 普通优先级
  normal(1),

  /// 高优先级
  high(2),

  /// 紧急优先级
  urgent(3),

  /// 系统级优先级
  system(4);

  const MessagePriority(this.level);
  final int level;
}

/// 统一消息
class UnifiedMessage {
  const UnifiedMessage({
    required this.id,
    required this.type,
    required this.action,
    required this.senderId,
    this.targetId,
    this.data = const {},
    this.priority = MessagePriority.normal,
    this.timestamp,
    this.timeout,
    this.correlationId,
  });

  /// 消息唯一标识
  final String id;

  /// 消息类型
  final MessageType type;

  /// 动作名称
  final String action;

  /// 发送者ID
  final String senderId;

  /// 目标ID（可选，广播时为null）
  final String? targetId;

  /// 消息数据
  final Map<String, dynamic> data;

  /// 消息优先级
  final MessagePriority priority;

  /// 时间戳
  final DateTime? timestamp;

  /// 超时时间（毫秒）
  final int? timeout;

  /// 关联ID（用于请求响应配对）
  final String? correlationId;

  /// 创建响应消息
  UnifiedMessage createResponse({
    required String responseId,
    required Map<String, dynamic> responseData,
    bool success = true,
  }) {
    return UnifiedMessage(
      id: responseId,
      type: MessageType.response,
      action: '${action}_response',
      senderId: targetId ?? 'system',
      targetId: senderId,
      data: {
        'success': success,
        'response': responseData,
        'originalAction': action,
      },
      priority: priority,
      timestamp: DateTime.now(),
      correlationId: id,
    );
  }

  @override
  String toString() {
    return 'UnifiedMessage(id: $id, type: $type, action: $action, '
        'senderId: $senderId, targetId: $targetId, priority: $priority)';
  }
}

/// 消息处理器类型定义
typedef MessageHandler =
    Future<Map<String, dynamic>?> Function(UnifiedMessage message);

/// 消息过滤器类型定义
typedef MessageFilter = bool Function(UnifiedMessage message);

/// 消息订阅
class MessageSubscription {
  MessageSubscription._(this._bus, this.handler, this.filter, this.id);

  final UnifiedMessageBus _bus;
  final MessageHandler handler;
  final MessageFilter? filter;
  final String id;

  bool _isActive = true;

  /// 是否活跃
  bool get isActive => _isActive;

  /// 取消订阅
  void cancel() {
    if (_isActive) {
      _bus._removeSubscription(this);
      _isActive = false;
    }
  }
}

/// 统一消息总线
///
/// Phase 3.2.1 核心功能：
/// - 整合EventBus和PluginMessenger功能
/// - 提供统一的消息传递接口
/// - 支持多种消息模式（事件、请求响应、通知、广播）
/// - 消息优先级和路由管理
/// - 性能监控和统计
class UnifiedMessageBus {
  UnifiedMessageBus._();

  static final UnifiedMessageBus _instance = UnifiedMessageBus._();
  static UnifiedMessageBus get instance => _instance;

  /// 消息流控制器
  final StreamController<UnifiedMessage> _messageController =
      StreamController<UnifiedMessage>.broadcast();

  /// 订阅管理
  final Map<String, List<MessageSubscription>> _subscriptions = {};

  /// 待处理的请求
  final Map<String, Completer<Map<String, dynamic>?>> _pendingRequests = {};

  /// 消息统计
  final Map<String, int> _messageStats = {};

  /// 性能监控
  final Map<String, List<int>> _performanceStats = {};

  /// 消息ID计数器
  int _messageIdCounter = 0;

  /// 订阅ID计数器
  int _subscriptionIdCounter = 0;

  /// 生成消息ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${++_messageIdCounter}';
  }

  /// 生成订阅ID
  String _generateSubscriptionId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}_${++_subscriptionIdCounter}';
  }

  /// 发布事件
  ///
  /// [senderId] 发送者ID
  /// [action] 事件动作
  /// [data] 事件数据
  /// [priority] 消息优先级
  void publishEvent(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    MessagePriority priority = MessagePriority.normal,
  }) {
    final message = UnifiedMessage(
      id: _generateMessageId(),
      type: MessageType.event,
      action: action,
      senderId: senderId,
      data: data,
      priority: priority,
      timestamp: DateTime.now(),
    );

    _deliverMessage(message);
  }

  /// 发送请求消息
  ///
  /// [senderId] 发送者ID
  /// [targetId] 目标ID
  /// [action] 请求动作
  /// [data] 请求数据
  /// [timeoutMs] 超时时间（毫秒）
  /// [priority] 消息优先级
  Future<Map<String, dynamic>?> sendRequest(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data, {
    int timeoutMs = 5000,
    MessagePriority priority = MessagePriority.normal,
  }) async {
    final messageId = _generateMessageId();
    final message = UnifiedMessage(
      id: messageId,
      type: MessageType.request,
      action: action,
      senderId: senderId,
      targetId: targetId,
      data: data,
      priority: priority,
      timestamp: DateTime.now(),
      timeout: timeoutMs,
    );

    // 创建响应等待器
    final completer = Completer<Map<String, dynamic>?>();
    _pendingRequests[messageId] = completer;

    // 设置超时
    Timer(Duration(milliseconds: timeoutMs), () {
      if (_pendingRequests.containsKey(messageId)) {
        _pendingRequests.remove(messageId);
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException(
              'Request timeout for action: $action',
              Duration(milliseconds: timeoutMs),
            ),
          );
        }
      }
    });

    // 发送消息
    _deliverMessage(message);

    return completer.future;
  }

  /// 发送通知
  ///
  /// [senderId] 发送者ID
  /// [targetId] 目标ID
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
    final message = UnifiedMessage(
      id: _generateMessageId(),
      type: MessageType.notification,
      action: action,
      senderId: senderId,
      targetId: targetId,
      data: data,
      priority: priority,
      timestamp: DateTime.now(),
    );

    _deliverMessage(message);
  }

  /// 广播消息
  ///
  /// [senderId] 发送者ID
  /// [action] 广播动作
  /// [data] 广播数据
  /// [excludeIds] 排除的目标ID列表
  /// [priority] 消息优先级
  void broadcastMessage(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    List<String> excludeIds = const [],
    MessagePriority priority = MessagePriority.normal,
  }) {
    final message = UnifiedMessage(
      id: _generateMessageId(),
      type: MessageType.broadcast,
      action: action,
      senderId: senderId,
      data: {...data, '_excludeIds': excludeIds},
      priority: priority,
      timestamp: DateTime.now(),
    );

    _deliverMessage(message);
  }

  /// 订阅消息
  ///
  /// [action] 订阅的动作（null表示订阅所有）
  /// [handler] 消息处理器
  /// [filter] 消息过滤器
  /// [senderId] 指定发送者ID（null表示不限制）
  /// [targetId] 指定目标ID（null表示不限制）
  MessageSubscription subscribe(
    MessageHandler handler, {
    String? action,
    MessageFilter? filter,
    String? senderId,
    String? targetId,
  }) {
    // 创建组合过滤器
    MessageFilter? combinedFilter;

    if (action != null ||
        senderId != null ||
        targetId != null ||
        filter != null) {
      combinedFilter = (UnifiedMessage message) {
        // 检查动作
        if (action != null && message.action != action) {
          return false;
        }

        // 检查发送者
        if (senderId != null && message.senderId != senderId) {
          return false;
        }

        // 检查目标
        if (targetId != null && message.targetId != targetId) {
          return false;
        }

        // 应用自定义过滤器
        if (filter != null && !filter(message)) {
          return false;
        }

        return true;
      };
    }

    final subscription = MessageSubscription._(
      this,
      handler,
      combinedFilter,
      _generateSubscriptionId(),
    );

    // 添加到订阅列表
    final key = action ?? '*';
    _subscriptions.putIfAbsent(key, () => []);
    _subscriptions[key]!.add(subscription);

    return subscription;
  }

  /// 订阅特定动作的消息
  MessageSubscription on(String action, MessageHandler handler) {
    return subscribe(handler, action: action);
  }

  /// 订阅来自特定发送者的消息
  MessageSubscription from(String senderId, MessageHandler handler) {
    return subscribe(handler, senderId: senderId);
  }

  /// 订阅发送给特定目标的消息
  MessageSubscription to(String targetId, MessageHandler handler) {
    return subscribe(handler, targetId: targetId);
  }

  /// 移除订阅
  void _removeSubscription(MessageSubscription subscription) {
    for (final subscriptionList in _subscriptions.values) {
      subscriptionList.removeWhere((sub) => sub.id == subscription.id);
    }
  }

  /// 投递消息
  void _deliverMessage(UnifiedMessage message) {
    // 更新统计
    _updateStats(message);

    // 添加到消息流
    _messageController.add(message);

    // 处理响应消息
    if (message.type == MessageType.response && message.correlationId != null) {
      _handleResponse(message);
      return;
    }

    // 获取相关订阅
    final subscriptions = _getRelevantSubscriptions(message);

    // 按优先级排序
    subscriptions.sort(
      (a, b) => message.priority.level.compareTo(message.priority.level),
    );

    // 异步处理订阅
    _processSubscriptions(message, subscriptions);
  }

  /// 获取相关订阅
  List<MessageSubscription> _getRelevantSubscriptions(UnifiedMessage message) {
    final List<MessageSubscription> relevantSubs = [];

    // 获取特定动作的订阅
    final actionSubs = _subscriptions[message.action] ?? [];
    relevantSubs.addAll(actionSubs);

    // 获取通用订阅
    final generalSubs = _subscriptions['*'] ?? [];
    relevantSubs.addAll(generalSubs);

    // 应用过滤器
    return relevantSubs.where((sub) {
      if (!sub.isActive) return false;
      if (sub.filter != null && !sub.filter!(message)) return false;

      // 广播消息排除逻辑
      if (message.type == MessageType.broadcast) {
        // final excludeIds = message.data['_excludeIds'] as List<String>? ?? [];
        // 这里需要根据实际的模块ID匹配逻辑来判断是否排除
        // 暂时简化处理
      }

      return true;
    }).toList();
  }

  /// 处理订阅
  Future<void> _processSubscriptions(
    UnifiedMessage message,
    List<MessageSubscription> subscriptions,
  ) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    for (final subscription in subscriptions) {
      try {
        final response = await subscription.handler(message);

        // 如果是请求消息且有响应，发送响应
        if (message.type == MessageType.request && response != null) {
          final responseMessage = message.createResponse(
            responseId: _generateMessageId(),
            responseData: response,
          );
          _deliverMessage(responseMessage);
        }
      } catch (e, stackTrace) {
        debugPrint('Error processing message ${message.id}: $e');
        debugPrint('Stack trace: $stackTrace');

        // 如果是请求消息，发送错误响应
        if (message.type == MessageType.request) {
          final errorResponse = message.createResponse(
            responseId: _generateMessageId(),
            responseData: {'error': e.toString()},
            success: false,
          );
          _deliverMessage(errorResponse);
        }
      }
    }

    // 更新性能统计
    final processingTime = DateTime.now().millisecondsSinceEpoch - startTime;
    _updatePerformanceStats(message.action, processingTime);
  }

  /// 处理响应消息
  void _handleResponse(UnifiedMessage message) {
    final correlationId = message.correlationId!;
    final completer = _pendingRequests.remove(correlationId);

    if (completer != null && !completer.isCompleted) {
      final responseData = message.data['response'] as Map<String, dynamic>?;
      final success = message.data['success'] as bool? ?? true;

      if (success) {
        completer.complete(responseData);
      } else {
        final error = responseData?['error'] ?? 'Unknown error';
        completer.completeError(Exception(error));
      }
    }
  }

  /// 更新统计信息
  void _updateStats(UnifiedMessage message) {
    final key = '${message.type.name}_${message.action}';
    _messageStats[key] = (_messageStats[key] ?? 0) + 1;
  }

  /// 更新性能统计
  void _updatePerformanceStats(String action, int processingTime) {
    _performanceStats.putIfAbsent(action, () => []);
    _performanceStats[action]!.add(processingTime);

    // 保持最近100条记录
    if (_performanceStats[action]!.length > 100) {
      _performanceStats[action]!.removeAt(0);
    }
  }

  /// 获取消息统计
  Map<String, int> get messageStats => Map.unmodifiable(_messageStats);

  /// 获取性能统计
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

  /// 获取消息流
  Stream<UnifiedMessage> get messageStream => _messageController.stream;

  /// 获取特定类型的消息流
  Stream<UnifiedMessage> streamOfType(MessageType type) {
    return messageStream.where((message) => message.type == type);
  }

  /// 获取特定动作的消息流
  Stream<UnifiedMessage> streamOfAction(String action) {
    return messageStream.where((message) => message.action == action);
  }

  /// 清理资源
  void dispose() {
    _messageController.close();
    _subscriptions.clear();
    _pendingRequests.clear();
    _messageStats.clear();
    _performanceStats.clear();
  }
}
