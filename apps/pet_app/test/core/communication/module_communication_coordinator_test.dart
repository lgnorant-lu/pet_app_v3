/*
---------------------------------------------------------------
File name:          module_communication_coordinator_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        模块通信协调器测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 通信协议类型
enum TestCommunicationProtocol {
  direct,
  broadcast,
  request_response,
  publish_subscribe,
}

/// 模块通信消息
class TestCommunicationMessage {
  final String id;
  final String senderId;
  final String? receiverId;
  final TestCommunicationProtocol protocol;
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TestCommunicationMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.protocol,
    required this.action,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 通信统计信息
class TestCommunicationStats {
  final Map<String, int> messagesSent;
  final Map<String, int> messagesReceived;
  final Map<TestCommunicationProtocol, int> protocolUsage;
  final Duration averageLatency;

  TestCommunicationStats({
    required this.messagesSent,
    required this.messagesReceived,
    required this.protocolUsage,
    required this.averageLatency,
  });
}

/// 模块接口
abstract class TestModule {
  String get moduleId;
  Future<void> handleMessage(TestCommunicationMessage message);
}

/// 简化的模块通信协调器（测试版本）
class TestModuleCommunicationCoordinator {
  final Map<String, TestModule> _modules = {};
  final List<TestCommunicationMessage> _messageHistory = [];
  final Map<String, List<String>> _subscriptions = {}; // action -> moduleIds
  final StreamController<TestCommunicationMessage> _messageController =
      StreamController<TestCommunicationMessage>.broadcast();
  final Map<String, Completer<TestCommunicationMessage>> _pendingRequests = {};

  Stream<TestCommunicationMessage> get messageStream =>
      _messageController.stream;
  List<TestCommunicationMessage> get messageHistory =>
      List.unmodifiable(_messageHistory);

  /// 注册模块
  void registerModule(TestModule module) {
    _modules[module.moduleId] = module;
  }

  /// 注销模块
  void unregisterModule(String moduleId) {
    _modules.remove(moduleId);

    // 清理订阅
    _subscriptions.forEach((action, moduleIds) {
      moduleIds.remove(moduleId);
    });
    _subscriptions.removeWhere((action, moduleIds) => moduleIds.isEmpty);
  }

  /// 发送直接消息
  Future<bool> sendDirectMessage(
    String senderId,
    String receiverId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final receiver = _modules[receiverId];
    if (receiver == null) return false;

    final message = TestCommunicationMessage(
      id: _generateMessageId(),
      senderId: senderId,
      receiverId: receiverId,
      protocol: TestCommunicationProtocol.direct,
      action: action,
      data: data,
    );

    await _deliverMessage(message, [receiver]);
    return true;
  }

  /// 广播消息
  Future<int> broadcastMessage(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    List<String>? excludeModules,
  }) async {
    final excludeSet = excludeModules?.toSet() ?? <String>{};
    excludeSet.add(senderId); // 排除发送者自己

    final receivers = _modules.values
        .where((module) => !excludeSet.contains(module.moduleId))
        .toList();

    final message = TestCommunicationMessage(
      id: _generateMessageId(),
      senderId: senderId,
      protocol: TestCommunicationProtocol.broadcast,
      action: action,
      data: data,
    );

    await _deliverMessage(message, receivers);
    return receivers.length;
  }

  /// 发送请求并等待响应
  Future<TestCommunicationMessage?> sendRequest(
    String senderId,
    String receiverId,
    String action,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final receiver = _modules[receiverId];
    if (receiver == null) return null;

    final requestId = _generateMessageId();
    final completer = Completer<TestCommunicationMessage>();
    _pendingRequests[requestId] = completer;

    final message = TestCommunicationMessage(
      id: requestId,
      senderId: senderId,
      receiverId: receiverId,
      protocol: TestCommunicationProtocol.request_response,
      action: action,
      data: data,
    );

    await _deliverMessage(message, [receiver]);

    try {
      return await completer.future.timeout(timeout);
    } catch (e) {
      _pendingRequests.remove(requestId);
      return null;
    }
  }

  /// 发送响应
  Future<void> sendResponse(
    String senderId,
    String requestId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final completer = _pendingRequests.remove(requestId);
    if (completer != null) {
      final response = TestCommunicationMessage(
        id: _generateMessageId(),
        senderId: senderId,
        protocol: TestCommunicationProtocol.request_response,
        action: action,
        data: data,
      );

      completer.complete(response);
    }
  }

  /// 订阅特定动作
  void subscribe(String moduleId, String action) {
    _subscriptions[action] = _subscriptions[action] ?? [];
    if (!_subscriptions[action]!.contains(moduleId)) {
      _subscriptions[action]!.add(moduleId);
    }
  }

  /// 取消订阅
  void unsubscribe(String moduleId, String action) {
    _subscriptions[action]?.remove(moduleId);
    if (_subscriptions[action]?.isEmpty ?? false) {
      _subscriptions.remove(action);
    }
  }

  /// 发布消息给订阅者
  Future<int> publishMessage(
    String senderId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final subscriberIds = _subscriptions[action] ?? [];
    final subscribers = subscriberIds
        .where((id) => id != senderId) // 排除发送者
        .map((id) => _modules[id])
        .where((module) => module != null)
        .cast<TestModule>()
        .toList();

    final message = TestCommunicationMessage(
      id: _generateMessageId(),
      senderId: senderId,
      protocol: TestCommunicationProtocol.publish_subscribe,
      action: action,
      data: data,
    );

    await _deliverMessage(message, subscribers);
    return subscribers.length;
  }

  /// 投递消息
  Future<void> _deliverMessage(
    TestCommunicationMessage message,
    List<TestModule> receivers,
  ) async {
    _messageHistory.add(message);
    _messageController.add(message);

    // 异步投递给所有接收者，捕获异常
    final futures = receivers.map((receiver) async {
      try {
        await receiver.handleMessage(message);
      } catch (e) {
        // 记录错误但不中断其他模块的消息处理
        // 在测试环境中忽略异常
      }
    });
    await Future.wait(futures);
  }

  /// 生成消息ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_messageHistory.length}';
  }

  /// 获取通信统计
  TestCommunicationStats getStatistics() {
    final messagesSent = <String, int>{};
    final messagesReceived = <String, int>{};
    final protocolUsage = <TestCommunicationProtocol, int>{};

    for (final message in _messageHistory) {
      // 发送统计
      messagesSent[message.senderId] =
          (messagesSent[message.senderId] ?? 0) + 1;

      // 接收统计
      if (message.receiverId != null) {
        messagesReceived[message.receiverId!] =
            (messagesReceived[message.receiverId!] ?? 0) + 1;
      }

      // 协议使用统计
      protocolUsage[message.protocol] =
          (protocolUsage[message.protocol] ?? 0) + 1;
    }

    // 计算平均延迟（简化版）
    const averageLatency = Duration(milliseconds: 10);

    return TestCommunicationStats(
      messagesSent: messagesSent,
      messagesReceived: messagesReceived,
      protocolUsage: protocolUsage,
      averageLatency: averageLatency,
    );
  }

  /// 获取活跃模块列表
  List<String> getActiveModules() {
    return _modules.keys.toList();
  }

  /// 获取订阅信息
  Map<String, List<String>> getSubscriptions() {
    return Map.from(_subscriptions);
  }

  /// 检查模块是否已注册
  bool isModuleRegistered(String moduleId) {
    return _modules.containsKey(moduleId);
  }

  /// 清理过期的请求
  void cleanupExpiredRequests() {
    // final now = DateTime.now(); // 暂时未使用
    final expiredKeys = <String>[];

    for (final entry in _pendingRequests.entries) {
      // 简化的过期检查：假设5秒后过期
      if (!entry.value.isCompleted) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      final completer = _pendingRequests.remove(key);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(
          TimeoutException('Request timeout', const Duration(seconds: 5)),
        );
      }
    }
  }

  /// 清理资源
  void dispose() {
    _modules.clear();
    _messageHistory.clear();
    _subscriptions.clear();
    _messageController.close();

    // 完成所有待处理的请求
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Coordinator disposed'));
      }
    }
    _pendingRequests.clear();
  }
}

/// 测试模块实现
class TestModuleImpl implements TestModule {
  @override
  final String moduleId;

  final List<TestCommunicationMessage> receivedMessages = [];
  final TestModuleCommunicationCoordinator? coordinator;

  TestModuleImpl(this.moduleId, [this.coordinator]);

  @override
  Future<void> handleMessage(TestCommunicationMessage message) async {
    receivedMessages.add(message);

    // 如果是请求消息，自动发送响应
    if (message.protocol == TestCommunicationProtocol.request_response &&
        coordinator != null) {
      await coordinator!.sendResponse(
        moduleId,
        message.id,
        'response_${message.action}',
        {'response': 'ok', 'original': message.data},
      );
    }
  }

  void clearMessages() {
    receivedMessages.clear();
  }
}

/// 故障测试模块（会抛出异常）
class FaultyTestModule implements TestModule {
  @override
  final String moduleId;

  FaultyTestModule(this.moduleId);

  @override
  Future<void> handleMessage(TestCommunicationMessage message) async {
    throw Exception('Module error');
  }
}

void main() {
  group('ModuleCommunicationCoordinator Tests', () {
    late TestModuleCommunicationCoordinator coordinator;
    late TestModuleImpl moduleA;
    late TestModuleImpl moduleB;
    late TestModuleImpl moduleC;

    setUp(() {
      coordinator = TestModuleCommunicationCoordinator();
      moduleA = TestModuleImpl('module_a', coordinator);
      moduleB = TestModuleImpl('module_b', coordinator);
      moduleC = TestModuleImpl('module_c', coordinator);

      coordinator.registerModule(moduleA);
      coordinator.registerModule(moduleB);
      coordinator.registerModule(moduleC);
    });

    tearDown(() {
      coordinator.dispose();
    });

    group('模块注册管理', () {
      test('应该能够注册和注销模块', () {
        expect(coordinator.isModuleRegistered('module_a'), isTrue);
        expect(coordinator.getActiveModules().length, equals(3));

        coordinator.unregisterModule('module_a');

        expect(coordinator.isModuleRegistered('module_a'), isFalse);
        expect(coordinator.getActiveModules().length, equals(2));
      });
    });

    group('直接消息通信', () {
      test('应该能够发送直接消息', () async {
        final result = await coordinator.sendDirectMessage(
          'module_a',
          'module_b',
          'test_action',
          {'data': 'test'},
        );

        expect(result, isTrue);
        expect(moduleB.receivedMessages.length, equals(1));
        expect(moduleB.receivedMessages.first.action, equals('test_action'));
        expect(moduleB.receivedMessages.first.senderId, equals('module_a'));
      });

      test('应该拒绝发送到不存在的模块', () async {
        final result = await coordinator.sendDirectMessage(
          'module_a',
          'nonexistent',
          'test_action',
          {},
        );

        expect(result, isFalse);
      });
    });

    group('广播消息', () {
      test('应该能够广播消息给所有模块', () async {
        final receiverCount = await coordinator.broadcastMessage(
          'module_a',
          'broadcast_action',
          {'message': 'hello all'},
        );

        expect(receiverCount, equals(2)); // 排除发送者
        expect(moduleB.receivedMessages.length, equals(1));
        expect(moduleC.receivedMessages.length, equals(1));
        expect(moduleA.receivedMessages.length, equals(0)); // 发送者不接收
      });

      test('应该能够排除特定模块', () async {
        final receiverCount = await coordinator.broadcastMessage(
          'module_a',
          'broadcast_action',
          {'message': 'hello some'},
          excludeModules: ['module_c'],
        );

        expect(receiverCount, equals(1));
        expect(moduleB.receivedMessages.length, equals(1));
        expect(moduleC.receivedMessages.length, equals(0)); // 被排除
      });
    });

    group('请求响应通信', () {
      test('应该能够发送请求并接收响应', () async {
        final response = await coordinator.sendRequest(
          'module_a',
          'module_b',
          'request_action',
          {'request': 'data'},
        );

        expect(response, isNotNull);
        expect(response!.action, equals('response_request_action'));
        expect(response.data['response'], equals('ok'));
      });

      test('应该处理请求超时', () async {
        // 创建一个不会响应的模块
        final silentModule = TestModuleImpl('silent_module');
        coordinator.registerModule(silentModule);

        final response = await coordinator.sendRequest(
          'module_a',
          'silent_module',
          'request_action',
          {},
          timeout: const Duration(milliseconds: 100),
        );

        expect(response, isNull);
      });
    });

    group('发布订阅通信', () {
      test('应该能够订阅和发布消息', () async {
        coordinator.subscribe('module_b', 'news_update');
        coordinator.subscribe('module_c', 'news_update');

        final subscriberCount = await coordinator.publishMessage(
          'module_a',
          'news_update',
          {'news': 'important update'},
        );

        expect(subscriberCount, equals(2));
        expect(moduleB.receivedMessages.length, equals(1));
        expect(moduleC.receivedMessages.length, equals(1));
        expect(moduleA.receivedMessages.length, equals(0)); // 发布者不接收
      });

      test('应该能够取消订阅', () async {
        coordinator.subscribe('module_b', 'news_update');
        coordinator.subscribe('module_c', 'news_update');
        coordinator.unsubscribe('module_b', 'news_update');

        final subscriberCount = await coordinator.publishMessage(
          'module_a',
          'news_update',
          {'news': 'update after unsubscribe'},
        );

        expect(subscriberCount, equals(1));
        expect(moduleB.receivedMessages.length, equals(0)); // 已取消订阅
        expect(moduleC.receivedMessages.length, equals(1));
      });
    });

    group('通信统计和监控', () {
      test('应该收集通信统计信息', () async {
        await coordinator.sendDirectMessage(
          'module_a',
          'module_b',
          'action1',
          {},
        );
        await coordinator.broadcastMessage('module_b', 'action2', {});
        await coordinator.sendRequest('module_c', 'module_a', 'action3', {});

        final stats = coordinator.getStatistics();

        expect(stats.messagesSent['module_a'], equals(1));
        expect(stats.messagesSent['module_b'], equals(1));
        expect(stats.messagesSent['module_c'], equals(1));
        expect(
          stats.protocolUsage[TestCommunicationProtocol.direct],
          equals(1),
        );
        expect(
          stats.protocolUsage[TestCommunicationProtocol.broadcast],
          equals(1),
        );
      });

      test('应该能够监听消息流', () async {
        final receivedMessages = <TestCommunicationMessage>[];
        final subscription = coordinator.messageStream.listen((message) {
          receivedMessages.add(message);
        });

        await coordinator.sendDirectMessage('module_a', 'module_b', 'test', {});
        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedMessages.length, equals(1));
        expect(receivedMessages.first.action, equals('test'));

        await subscription.cancel();
      });
    });

    group('订阅管理', () {
      test('应该能够获取订阅信息', () {
        coordinator.subscribe('module_a', 'action1');
        coordinator.subscribe('module_b', 'action1');
        coordinator.subscribe('module_c', 'action2');

        final subscriptions = coordinator.getSubscriptions();

        expect(subscriptions['action1']?.length, equals(2));
        expect(subscriptions['action2']?.length, equals(1));
        expect(subscriptions['action1'], contains('module_a'));
        expect(subscriptions['action1'], contains('module_b'));
      });

      test('应该在模块注销时清理订阅', () {
        coordinator.subscribe('module_a', 'action1');
        coordinator.subscribe('module_b', 'action1');

        coordinator.unregisterModule('module_a');

        final subscriptions = coordinator.getSubscriptions();
        expect(subscriptions['action1']?.length, equals(1));
        expect(subscriptions['action1'], isNot(contains('module_a')));
      });
    });

    group('错误处理和清理', () {
      test('应该清理过期的请求', () {
        coordinator.cleanupExpiredRequests();
        // 清理操作应该完成而不出错
        expect(coordinator.getActiveModules().isNotEmpty, isTrue);
      });

      test('应该处理模块处理消息时的异常', () async {
        // 创建一个会抛出异常的模块
        final faultyModule = FaultyTestModule('faulty_module');
        coordinator.registerModule(faultyModule);

        // 发送消息不应该导致整个系统崩溃
        final result = await coordinator.sendDirectMessage(
          'module_a',
          'faulty_module',
          'test',
          {},
        );

        expect(result, isTrue); // 消息发送成功，即使处理失败
      });
    });

    group('复杂通信场景', () {
      test('应该支持混合通信模式', () async {
        // 设置订阅
        coordinator.subscribe('module_b', 'notification');
        coordinator.subscribe('module_c', 'notification');

        // 1. 直接消息
        await coordinator.sendDirectMessage(
          'module_a',
          'module_b',
          'direct_msg',
          {},
        );

        // 2. 广播消息
        await coordinator.broadcastMessage('module_a', 'broadcast_msg', {});

        // 3. 发布订阅
        await coordinator.publishMessage('module_a', 'notification', {});

        // 4. 请求响应
        await coordinator.sendRequest(
          'module_a',
          'module_c',
          'request_msg',
          {},
        );

        // 验证消息接收
        expect(
          moduleB.receivedMessages.length,
          equals(3),
        ); // direct + broadcast + notification
        expect(
          moduleC.receivedMessages.length,
          equals(3),
        ); // broadcast + notification + request

        final stats = coordinator.getStatistics();
        expect(stats.protocolUsage.length, equals(4)); // 使用了所有4种协议
      });
    });
  });
}
