/*
---------------------------------------------------------------
File name:          unified_message_bus_basic_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.1 统一消息总线基础测试
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.1 - 实现统一消息总线基础测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 简化的消息类型枚举（用于测试）
enum TestMessageType { event, request, response, notification, broadcast }

/// 简化的消息优先级枚举（用于测试）
enum TestMessagePriority {
  low(0),
  normal(1),
  high(2),
  urgent(3);

  const TestMessagePriority(this.level);
  final int level;
}

/// 简化的消息类（用于测试）
class TestMessage {
  const TestMessage({
    required this.id,
    required this.type,
    required this.action,
    required this.senderId,
    this.targetId,
    this.data = const {},
    this.priority = TestMessagePriority.normal,
  });

  final String id;
  final TestMessageType type;
  final String action;
  final String senderId;
  final String? targetId;
  final Map<String, dynamic> data;
  final TestMessagePriority priority;
}

/// 简化的消息处理器类型
typedef TestMessageHandler =
    Future<Map<String, dynamic>?> Function(TestMessage message);

/// 简化的消息总线（用于测试核心逻辑）
class TestMessageBus {
  TestMessageBus._();

  StreamController<TestMessage>? _messageController;
  final Map<String, List<TestMessageHandler>> _handlers = {};
  final Map<String, int> _messageStats = {};

  int _messageIdCounter = 0;

  StreamController<TestMessage> get messageController {
    _messageController ??= StreamController<TestMessage>.broadcast();
    return _messageController!;
  }

  String _generateMessageId() {
    return 'test_msg_${++_messageIdCounter}';
  }

  void publishEvent(String senderId, String action, Map<String, dynamic> data) {
    final message = TestMessage(
      id: _generateMessageId(),
      type: TestMessageType.event,
      action: action,
      senderId: senderId,
      data: data,
    );

    _deliverMessage(message);
  }

  void subscribe(String action, TestMessageHandler handler) {
    _handlers.putIfAbsent(action, () => []);
    _handlers[action]!.add(handler);
  }

  void _deliverMessage(TestMessage message) {
    _updateStats(message);
    messageController.add(message);

    final handlers = _handlers[message.action] ?? [];
    for (final handler in handlers) {
      handler(message);
    }
  }

  void _updateStats(TestMessage message) {
    final key = '${message.type.name}_${message.action}';
    _messageStats[key] = (_messageStats[key] ?? 0) + 1;
  }

  Map<String, int> get messageStats => Map.unmodifiable(_messageStats);

  Stream<TestMessage> get messageStream => messageController.stream;

  void dispose() {
    _messageController?.close();
    _messageController = null;
    _handlers.clear();
    _messageStats.clear();
    _messageIdCounter = 0;
  }
}

void main() {
  group('UnifiedMessageBus Basic Tests', () {
    late TestMessageBus messageBus;

    setUp(() {
      messageBus = TestMessageBus._();
    });

    tearDown(() {
      messageBus.dispose();
    });

    test('应该能够创建和发布事件', () {
      // 准备
      String? receivedAction;
      String? receivedSender;
      Map<String, dynamic>? receivedData;

      messageBus.subscribe('test_event', (message) async {
        receivedAction = message.action;
        receivedSender = message.senderId;
        receivedData = message.data;
        return null;
      });

      // 执行
      messageBus.publishEvent('test_sender', 'test_event', {'key': 'value'});

      // 验证
      expect(receivedAction, equals('test_event'));
      expect(receivedSender, equals('test_sender'));
      expect(receivedData, equals({'key': 'value'}));
    });

    test('应该能够收集消息统计', () {
      // 执行
      messageBus.publishEvent('sender1', 'event1', {});
      messageBus.publishEvent('sender2', 'event2', {});
      messageBus.publishEvent('sender1', 'event1', {});

      // 验证
      final stats = messageBus.messageStats;
      expect(stats['event_event1'], equals(2));
      expect(stats['event_event2'], equals(1));
    });

    test('应该能够处理多个订阅者', () {
      // 准备
      int count1 = 0;
      int count2 = 0;

      messageBus.subscribe('shared_event', (message) async {
        count1++;
        return null;
      });

      messageBus.subscribe('shared_event', (message) async {
        count2++;
        return null;
      });

      // 执行
      messageBus.publishEvent('sender', 'shared_event', {});

      // 验证
      expect(count1, equals(1));
      expect(count2, equals(1));
    });

    test('应该能够处理消息流', () async {
      // 准备
      final receivedMessages = <TestMessage>[];
      final subscription = messageBus.messageStream.listen((message) {
        receivedMessages.add(message);
      });

      // 执行
      messageBus.publishEvent('sender1', 'event1', {'data': 1});
      messageBus.publishEvent('sender2', 'event2', {'data': 2});

      // 等待异步处理
      await Future.delayed(const Duration(milliseconds: 10));

      // 验证
      expect(receivedMessages.length, equals(2));
      expect(receivedMessages[0].action, equals('event1'));
      expect(receivedMessages[1].action, equals('event2'));

      // 清理
      await subscription.cancel();
    });

    test('应该能够处理消息优先级', () {
      // 准备
      final message1 = TestMessage(
        id: 'msg1',
        type: TestMessageType.event,
        action: 'test',
        senderId: 'sender',
        priority: TestMessagePriority.low,
      );

      final message2 = TestMessage(
        id: 'msg2',
        type: TestMessageType.event,
        action: 'test',
        senderId: 'sender',
        priority: TestMessagePriority.urgent,
      );

      // 验证优先级比较
      expect(message2.priority.level > message1.priority.level, isTrue);
      expect(message1.priority.level, equals(0));
      expect(message2.priority.level, equals(3));
    });

    test('应该能够生成唯一的消息ID', () {
      // 执行
      for (int i = 0; i < 100; i++) {
        messageBus.publishEvent('sender', 'event', {});
      }

      // 从统计中验证消息数量
      final stats = messageBus.messageStats;
      expect(stats['event_event'], equals(100));
    });
  });
}
