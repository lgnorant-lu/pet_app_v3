/*
---------------------------------------------------------------
File name:          event_bus.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        事件总线 (Event bus)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 事件总线 (Event bus);
---------------------------------------------------------------
*/
import 'dart:async';

/// 插件事件
class PluginEvent {
  const PluginEvent({
    required this.type,
    required this.source,
    this.data,
    this.timestamp,
  });

  /// 事件类型
  final String type;

  /// 事件源（插件ID）
  final String source;

  /// 事件数据
  final Map<String, dynamic>? data;

  /// 时间戳
  final DateTime? timestamp;

  @override
  String toString() => 'PluginEvent(type: $type, source: $source, timestamp: $timestamp)';
}

/// 事件监听器
typedef EventListener = void Function(PluginEvent event);

/// 事件过滤器
typedef EventFilter = bool Function(PluginEvent event);

/// 事件订阅
class EventSubscription {
  EventSubscription._(this._eventBus, this._listener, this._filter);

  final EventBus _eventBus;
  final EventListener _listener;
  final EventFilter? _filter;
  bool _isActive = true;

  /// 取消订阅
  void cancel() {
    if (_isActive) {
      _eventBus._removeSubscription(this);
      _isActive = false;
    }
  }

  /// 是否活跃
  bool get isActive => _isActive;
}

/// 插件事件总线
///
/// 负责插件间的事件发布和订阅
class EventBus {
  EventBus._();

  /// 单例实例
  static final EventBus _instance = EventBus._();
  static EventBus get instance => _instance;

  /// 事件监听器
  final List<EventSubscription> _subscriptions = <EventSubscription>[];

  /// 事件流控制器
  final StreamController<PluginEvent> _eventController =
      StreamController<PluginEvent>.broadcast();

  /// 事件统计
  final Map<String, int> _eventStats = <String, int>{};

  /// 发布事件
  ///
  /// [type] 事件类型
  /// [source] 事件源（插件ID）
  /// [data] 事件数据
  void publish(
    String type,
    String source, {
    Map<String, dynamic>? data,
  }) {
    final PluginEvent event = PluginEvent(
      type: type,
      source: source,
      data: data,
      timestamp: DateTime.now(),
    );

    // 更新统计
    _eventStats[type] = (_eventStats[type] ?? 0) + 1;

    // 发布到流
    _eventController.add(event);

    // 通知订阅者
    _notifySubscribers(event);
  }

  /// 订阅事件
  ///
  /// [eventType] 事件类型，null表示订阅所有事件
  /// [listener] 事件监听器
  /// [filter] 事件过滤器
  EventSubscription subscribe(
    EventListener listener, {
    String? eventType,
    String? source,
    EventFilter? filter,
  }) {
    // 创建组合过滤器
    EventFilter? combinedFilter;

    if (eventType != null || source != null || filter != null) {
      combinedFilter = (PluginEvent event) {
        // 检查事件类型
        if (eventType != null && event.type != eventType) {
          return false;
        }

        // 检查事件源
        if (source != null && event.source != source) {
          return false;
        }

        // 应用自定义过滤器
        if (filter != null && !filter(event)) {
          return false;
        }

        return true;
      };
    }

    final EventSubscription subscription = EventSubscription._(
      this,
      listener,
      combinedFilter,
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// 订阅特定类型的事件
  EventSubscription on(String eventType, EventListener listener) => subscribe(listener, eventType: eventType);

  /// 订阅来自特定源的事件
  EventSubscription from(String source, EventListener listener) => subscribe(listener, source: source);

  /// 获取事件流
  Stream<PluginEvent> get stream => _eventController.stream;

  /// 获取特定类型的事件流
  Stream<PluginEvent> streamOf(String eventType) => stream.where((PluginEvent event) => event.type == eventType);

  /// 获取来自特定源的事件流
  Stream<PluginEvent> streamFrom(String source) => stream.where((PluginEvent event) => event.source == source);

  /// 等待特定事件
  ///
  /// [eventType] 事件类型
  /// [timeout] 超时时间
  /// [filter] 事件过滤器
  Future<PluginEvent> waitFor(
    String eventType, {
    Duration? timeout,
    EventFilter? filter,
  }) {
    final Completer<PluginEvent> completer = Completer<PluginEvent>();
    late EventSubscription subscription;

    subscription = subscribe(
      (PluginEvent event) {
        subscription.cancel();
        completer.complete(event);
      },
      eventType: eventType,
      filter: filter,
    );

    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(
            TimeoutException('Event wait timeout', timeout),
          );
        }
      });
    }

    return completer.future;
  }

  /// 通知订阅者
  void _notifySubscribers(PluginEvent event) {
    // 创建副本以避免并发修改
    final List<EventSubscription> activeSubscriptions =
        _subscriptions.where((EventSubscription sub) => sub.isActive).toList();

    for (final EventSubscription subscription in activeSubscriptions) {
      try {
        // 应用过滤器
        final filter = subscription._filter;
        if (filter != null && !filter(event)) {
          continue;
        }

        // 调用监听器
        subscription._listener(event);
      } catch (e) {
        // 忽略监听器中的错误，避免影响其他监听器
      }
    }
  }

  /// 移除订阅
  void _removeSubscription(EventSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  /// 清理插件的所有订阅
  void cleanupPlugin(String pluginId) {
    final List<EventSubscription> toRemove = _subscriptions
        .where((EventSubscription sub) =>
            sub._listener.toString().contains(pluginId),)
        .toList();

    for (final EventSubscription subscription in toRemove) {
      subscription.cancel();
    }
  }

  /// 获取事件统计
  Map<String, int> getEventStats() => Map<String, int>.from(_eventStats);

  /// 获取订阅统计
  Map<String, dynamic> getSubscriptionStats() {
    final int activeSubscriptions =
        _subscriptions.where((EventSubscription sub) => sub.isActive).length;

    return <String, dynamic>{
      'totalSubscriptions': _subscriptions.length,
      'activeSubscriptions': activeSubscriptions,
      'inactiveSubscriptions': _subscriptions.length - activeSubscriptions,
    };
  }

  /// 获取综合统计信息
  Map<String, dynamic> getStats() {
    final eventStats = getEventStats();
    final subscriptionStats = getSubscriptionStats();

    return <String, dynamic>{
      'totalEvents': eventStats.values.fold(0, (int sum, int count) => sum + count),
      'eventTypes': eventStats.keys.toList(),
      'eventStats': eventStats,
      'subscriptionStats': subscriptionStats,
    };
  }

  /// 清空所有统计
  void clearStats() {
    _eventStats.clear();
  }

  /// 清空所有订阅
  void clearSubscriptions() {
    // 创建副本以避免并发修改
    final subscriptionsToCancel = List<EventSubscription>.from(_subscriptions);
    _subscriptions.clear();

    for (final EventSubscription subscription in subscriptionsToCancel) {
      subscription.cancel();
    }
  }

  /// 关闭事件总线
  Future<void> close() async {
    clearSubscriptions();
    await _eventController.close();
  }

  /// 获取状态信息
  Map<String, dynamic> getStatus() => <String, dynamic>{
      'subscriptions': getSubscriptionStats(),
      'eventStats': getEventStats(),
      'isControllerClosed': _eventController.isClosed,
    };
}

/// 常用的系统事件类型
class SystemEvents {
  static const String pluginLoaded = 'plugin.loaded';
  static const String pluginUnloaded = 'plugin.unloaded';
  static const String pluginStarted = 'plugin.started';
  static const String pluginStopped = 'plugin.stopped';
  static const String pluginPaused = 'plugin.paused';
  static const String pluginResumed = 'plugin.resumed';
  static const String pluginError = 'plugin.error';
  static const String systemStartup = 'system.startup';
  static const String systemShutdown = 'system.shutdown';
  static const String configChanged = 'config.changed';
  static const String permissionGranted = 'permission.granted';
  static const String permissionDenied = 'permission.denied';
}

/// 事件总线的便捷扩展
extension EventBusExtensions on EventBus {
  /// 发布插件生命周期事件
  void publishPluginEvent(
    String eventType,
    String pluginId, {
    Map<String, dynamic>? data,
  }) {
    publish(eventType, pluginId, data: data);
  }

  /// 发布系统事件
  void publishSystemEvent(
    String eventType, {
    Map<String, dynamic>? data,
  }) {
    publish(eventType, 'system', data: data);
  }

  /// 订阅插件生命周期事件
  EventSubscription onPluginEvent(String eventType, EventListener listener) => on(eventType, listener);

  /// 订阅系统事件
  EventSubscription onSystemEvent(String eventType, EventListener listener) => subscribe(listener, eventType: eventType, source: 'system');
}
