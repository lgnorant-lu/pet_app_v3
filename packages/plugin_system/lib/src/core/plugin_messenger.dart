/*
---------------------------------------------------------------
File name:          plugin_messenger.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件消息传递 (Plugin messaging)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件消息传递 (Plugin messaging);
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_exceptions.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';

/// 插件消息类型
enum MessageType {
  /// 请求消息
  request,

  /// 响应消息
  response,

  /// 通知消息
  notification,

  /// 广播消息
  broadcast,
}

/// 插件消息
class PluginMessage {
  const PluginMessage({
    required this.id,
    required this.type,
    required this.action,
    required this.senderId,
    required this.targetId,
    required this.data,
    this.timestamp,
    this.timeout,
  });

  /// 消息ID
  final String id;

  /// 消息类型
  final MessageType type;

  /// 动作名称
  final String action;

  /// 发送者ID
  final String senderId;

  /// 目标ID（广播消息时为空）
  final String? targetId;

  /// 消息数据
  final Map<String, dynamic> data;

  /// 时间戳
  final DateTime? timestamp;

  /// 超时时间（毫秒）
  final int? timeout;

  @override
  String toString() {
    return 'PluginMessage(id: $id, type: $type, action: $action, '
        'senderId: $senderId, targetId: $targetId)';
  }
}

/// 插件消息响应
class PluginMessageResponse {
  const PluginMessageResponse({
    required this.messageId,
    required this.success,
    this.data,
    this.error,
  });

  /// 原始消息ID
  final String messageId;

  /// 是否成功
  final bool success;

  /// 响应数据
  final dynamic data;

  /// 错误信息
  final String? error;

  @override
  String toString() {
    return 'PluginMessageResponse(messageId: $messageId, success: $success)';
  }
}

/// 插件消息处理器
typedef PluginMessageHandler = Future<PluginMessageResponse> Function(
    PluginMessage message);

/// 插件消息传递器
///
/// 负责插件间的消息传递和通信
class PluginMessenger {
  PluginMessenger._();

  /// 单例实例
  static final PluginMessenger _instance = PluginMessenger._();
  static PluginMessenger get instance => _instance;

  /// 插件注册中心
  final PluginRegistry _registry = PluginRegistry.instance;

  /// 消息处理器
  final Map<String, Map<String, PluginMessageHandler>> _handlers =
      <String, Map<String, PluginMessageHandler>>{};

  /// 待处理的消息
  final Map<String, Completer<PluginMessageResponse>> _pendingMessages =
      <String, Completer<PluginMessageResponse>>{};

  /// 消息ID计数器
  int _messageIdCounter = 0;

  /// 默认超时时间（毫秒）
  static const int _defaultTimeoutMs = 5000;

  // TODO(High): [Phase 2.9.1] 添加消息路由和过滤机制
  // 需要实现：
  // 1. 消息路由规则配置
  // 2. 消息内容过滤器
  // 3. 消息优先级队列
  // 4. 消息历史记录和审计
  // 5. 消息加密和签名验证

  /// 发送消息
  ///
  /// [senderId] 发送者插件ID
  /// [targetId] 目标插件ID
  /// [action] 动作名称
  /// [data] 消息数据
  /// [timeoutMs] 超时时间（毫秒）
  Future<PluginMessageResponse> sendMessage(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data, {
    int timeoutMs = _defaultTimeoutMs,
  }) async {
    // 验证发送者和目标插件
    if (!_registry.contains(senderId)) {
      throw PluginNotFoundException(senderId);
    }

    if (!_registry.contains(targetId)) {
      throw PluginNotFoundException(targetId);
    }

    // 创建消息
    final String messageId = _generateMessageId();
    final PluginMessage message = PluginMessage(
      id: messageId,
      type: MessageType.request,
      action: action,
      senderId: senderId,
      targetId: targetId,
      data: data,
      timestamp: DateTime.now(),
      timeout: timeoutMs,
    );

    // 发送消息并等待响应
    return _sendMessageWithResponse(message, timeoutMs);
  }

  /// 发送通知消息（不等待响应）
  ///
  /// [senderId] 发送者插件ID
  /// [targetId] 目标插件ID
  /// [action] 动作名称
  /// [data] 消息数据
  Future<void> sendNotification(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data,
  ) async {
    // 验证发送者和目标插件
    if (!_registry.contains(senderId)) {
      throw PluginNotFoundException(senderId);
    }

    if (!_registry.contains(targetId)) {
      throw PluginNotFoundException(targetId);
    }

    // 创建通知消息
    final String messageId = _generateMessageId();
    final PluginMessage message = PluginMessage(
      id: messageId,
      type: MessageType.notification,
      action: action,
      senderId: senderId,
      targetId: targetId,
      data: data,
      timestamp: DateTime.now(),
    );

    // 发送通知
    await _deliverMessage(message);
  }

  /// 广播消息
  ///
  /// [senderId] 发送者插件ID
  /// [action] 动作名称
  /// [data] 消息数据
  /// [excludeIds] 排除的插件ID列表
  Future<void> broadcastMessage(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    List<String> excludeIds = const <String>[],
  }) async {
    // 验证发送者插件
    if (!_registry.contains(senderId)) {
      throw PluginNotFoundException(senderId);
    }

    // 创建广播消息
    final String messageId = _generateMessageId();
    final PluginMessage message = PluginMessage(
      id: messageId,
      type: MessageType.broadcast,
      action: action,
      senderId: senderId,
      targetId: null,
      data: data,
      timestamp: DateTime.now(),
    );

    // 获取所有活跃插件
    final List<Plugin> activePlugins = _registry.getAllActive();

    // 广播给所有插件（除了发送者和排除列表）
    for (final Plugin plugin in activePlugins) {
      if (plugin.id != senderId && !excludeIds.contains(plugin.id)) {
        try {
          await _deliverMessage(message.copyWith(targetId: plugin.id));
        } catch (e) {
          // 广播时忽略单个插件的错误
        }
      }
    }
  }

  /// 注册消息处理器
  ///
  /// [pluginId] 插件ID
  /// [action] 动作名称
  /// [handler] 消息处理器
  void registerHandler(
    String pluginId,
    String action,
    PluginMessageHandler handler,
  ) {
    _handlers.putIfAbsent(pluginId, () => <String, PluginMessageHandler>{});
    _handlers[pluginId]![action] = handler;
  }

  /// 注销消息处理器
  ///
  /// [pluginId] 插件ID
  /// [action] 动作名称，如果为null则注销所有处理器
  void unregisterHandler(String pluginId, [String? action]) {
    if (action == null) {
      _handlers.remove(pluginId);
    } else {
      _handlers[pluginId]?.remove(action);
    }
  }

  /// 发送带响应的消息
  Future<PluginMessageResponse> _sendMessageWithResponse(
    PluginMessage message,
    int timeoutMs,
  ) async {
    final Completer<PluginMessageResponse> completer =
        Completer<PluginMessageResponse>();

    _pendingMessages[message.id] = completer;

    try {
      // 发送消息
      await _deliverMessage(message);

      // 等待响应或超时
      return await Future.any([
        completer.future,
        Future<PluginMessageResponse>.delayed(
          Duration(milliseconds: timeoutMs),
          () => PluginMessageResponse(
            messageId: message.id,
            success: false,
            error: 'Message timeout',
          ),
        ),
      ]);
    } finally {
      _pendingMessages.remove(message.id);
    }
  }

  /// 投递消息
  Future<void> _deliverMessage(PluginMessage message) async {
    final String? targetId = message.targetId;
    if (targetId == null) {
      throw PluginCommunicationException(
        message.senderId,
        'null',
        'Target ID is null',
      );
    }

    // 获取目标插件
    final Plugin? targetPlugin = _registry.get(targetId);
    if (targetPlugin == null) {
      throw PluginNotFoundException(targetId);
    }

    // 检查插件状态
    final PluginState? state = _registry.getState(targetId);
    if (state != PluginState.started) {
      throw PluginCommunicationException(
        message.senderId,
        targetId,
        'Target plugin is not active',
      );
    }

    try {
      // 使用插件的消息处理方法
      final dynamic result = await targetPlugin.handleMessage(
        message.action,
        message.data,
      );

      // 如果是请求消息，发送响应
      if (message.type == MessageType.request) {
        final PluginMessageResponse response = PluginMessageResponse(
          messageId: message.id,
          success: true,
          data: result,
        );
        _completeMessage(message.id, response);
      }
    } catch (e) {
      // 如果是请求消息，发送错误响应
      if (message.type == MessageType.request) {
        final PluginMessageResponse response = PluginMessageResponse(
          messageId: message.id,
          success: false,
          error: e.toString(),
        );
        _completeMessage(message.id, response);
      }
    }
  }

  /// 完成消息处理
  void _completeMessage(String messageId, PluginMessageResponse response) {
    final Completer<PluginMessageResponse>? completer =
        _pendingMessages[messageId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
  }

  /// 生成消息ID
  String _generateMessageId() {
    return 'msg_${++_messageIdCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取通信状态
  Map<String, dynamic> getStatus() {
    return <String, dynamic>{
      'registeredHandlers': _handlers.length,
      'pendingMessages': _pendingMessages.length,
      'messageCounter': _messageIdCounter,
    };
  }

  /// 清理插件的所有消息处理器
  void cleanupPlugin(String pluginId) {
    unregisterHandler(pluginId);

    // 取消该插件的所有待处理消息
    final List<String> toRemove = <String>[];
    for (final MapEntry<String, Completer<PluginMessageResponse>> entry
        in _pendingMessages.entries) {
      // 这里需要更复杂的逻辑来识别插件相关的消息
      // 简化处理：如果消息ID包含插件ID则取消
      if (entry.key.contains(pluginId)) {
        entry.value.complete(PluginMessageResponse(
          messageId: entry.key,
          success: false,
          error: 'Plugin unloaded',
        ));
        toRemove.add(entry.key);
      }
    }

    for (final String messageId in toRemove) {
      _pendingMessages.remove(messageId);
    }
  }
}

/// PluginMessage的扩展方法
extension PluginMessageExtension on PluginMessage {
  /// 复制消息并修改目标ID
  PluginMessage copyWith({String? targetId}) {
    return PluginMessage(
      id: id,
      type: type,
      action: action,
      senderId: senderId,
      targetId: targetId ?? this.targetId,
      data: data,
      timestamp: timestamp,
      timeout: timeout,
    );
  }
}
