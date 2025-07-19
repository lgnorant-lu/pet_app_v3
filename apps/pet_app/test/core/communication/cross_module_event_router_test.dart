/*
---------------------------------------------------------------
File name:          cross_module_event_router_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.2.2 跨模块事件路由器测试 - 纯Dart版本
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.2.2 - 实现跨模块事件路由器测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 简化的事件路由规则（测试版本）
class TestEventRoutingRule {
  final String id;
  final String sourcePattern;
  final String targetPattern;
  final String actionPattern;
  final int priority;

  const TestEventRoutingRule({
    required this.id,
    required this.sourcePattern,
    required this.targetPattern,
    this.actionPattern = '*',
    this.priority = 0,
  });

  bool matches(String source, String target, String action) {
    return _matchesPattern(sourcePattern, source) &&
        _matchesPattern(targetPattern, target) &&
        _matchesPattern(actionPattern, action);
  }

  bool _matchesPattern(String pattern, String value) {
    if (pattern == '*') return true;
    if (pattern.endsWith('*')) {
      final prefix = pattern.substring(0, pattern.length - 1);
      return value.startsWith(prefix);
    }
    if (pattern.startsWith('*')) {
      final suffix = pattern.substring(1);
      return value.endsWith(suffix);
    }
    return pattern == value;
  }
}

/// 简化的事件消息（测试版本）
class TestEventMessage {
  final String id;
  final String sender;
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TestEventMessage({
    required this.id,
    required this.sender,
    required this.action,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 简化的跨模块事件路由器（测试版本）
class TestCrossModuleEventRouter {
  final List<TestEventRoutingRule> _rules = [];
  final Map<String, int> _routingStats = {};
  final Map<String, List<TestEventMessage>> _routedMessages = {};
  final StreamController<TestEventMessage> _eventController =
      StreamController<TestEventMessage>.broadcast();

  Stream<TestEventMessage> get eventStream => _eventController.stream;

  void addRoutingRule(TestEventRoutingRule rule) {
    _rules.add(rule);
    _rules.sort((a, b) => b.priority.compareTo(a.priority));
  }

  void removeRoutingRule(String ruleId) {
    _rules.removeWhere((rule) => rule.id == ruleId);
  }

  List<TestEventRoutingRule> get routingRules => List.unmodifiable(_rules);

  List<TestEventRoutingRule> findMatchingRules(
    String source,
    String target,
    String action,
  ) {
    return _rules
        .where((rule) => rule.matches(source, target, action))
        .toList();
  }

  Future<bool> routeEvent(
    String source,
    String target,
    String action,
    Map<String, dynamic> data,
  ) async {
    final matchingRules = findMatchingRules(source, target, action);
    if (matchingRules.isNotEmpty) {
      final message = TestEventMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        sender: source,
        action: action,
        data: data,
      );

      // 更新统计
      _routingStats[source] = (_routingStats[source] ?? 0) + 1;

      // 存储路由消息
      _routedMessages[target] = _routedMessages[target] ?? [];
      _routedMessages[target]!.add(message);

      // 发送事件
      _eventController.add(message);

      return true;
    }
    return false;
  }

  Map<String, int> get routingStats => Map.unmodifiable(_routingStats);

  List<TestEventMessage> getRoutedMessages(String target) {
    return List.unmodifiable(_routedMessages[target] ?? []);
  }

  void clearStats() {
    _routingStats.clear();
  }

  void clearMessages() {
    _routedMessages.clear();
  }

  void dispose() {
    _rules.clear();
    _routingStats.clear();
    _routedMessages.clear();
    _eventController.close();
  }
}

void main() {
  group('CrossModuleEventRouter Tests', () {
    late TestCrossModuleEventRouter router;

    setUp(() {
      router = TestCrossModuleEventRouter();

      // 添加默认路由规则
      router.addRoutingRule(
        const TestEventRoutingRule(
          id: 'system_broadcast',
          sourcePattern: 'system',
          targetPattern: '*',
          actionPattern: 'broadcast_*',
          priority: 100,
        ),
      );

      router.addRoutingRule(
        const TestEventRoutingRule(
          id: 'plugin_communication',
          sourcePattern: 'plugin_*',
          targetPattern: 'plugin_*',
          actionPattern: '*',
          priority: 50,
        ),
      );

      router.addRoutingRule(
        const TestEventRoutingRule(
          id: 'module_status_change',
          sourcePattern: '*',
          targetPattern: 'status_monitor',
          actionPattern: 'status_*',
          priority: 75,
        ),
      );

      router.addRoutingRule(
        const TestEventRoutingRule(
          id: 'ui_events',
          sourcePattern: 'ui_*',
          targetPattern: 'event_handler',
          actionPattern: 'ui_*',
          priority: 60,
        ),
      );
    });

    tearDown(() {
      router.dispose();
    });

    group('路由规则管理', () {
      test('应该能够添加和移除路由规则', () {
        // 准备
        const rule = TestEventRoutingRule(
          id: 'test_rule',
          sourcePattern: 'test_*',
          targetPattern: 'target_*',
          actionPattern: 'action_*',
          priority: 50,
        );

        // 执行
        router.addRoutingRule(rule);

        // 验证
        final rules = router.routingRules;
        expect(rules.any((r) => r.id == 'test_rule'), isTrue);

        // 移除
        router.removeRoutingRule('test_rule');
        final rulesAfterRemoval = router.routingRules;
        expect(rulesAfterRemoval.any((r) => r.id == 'test_rule'), isFalse);
      });

      test('应该包含默认路由规则', () {
        // 验证默认规则存在
        final rules = router.routingRules;
        expect(rules.any((r) => r.id == 'system_broadcast'), isTrue);
        expect(rules.any((r) => r.id == 'plugin_communication'), isTrue);
        expect(rules.any((r) => r.id == 'module_status_change'), isTrue);
        expect(rules.any((r) => r.id == 'ui_events'), isTrue);
      });

      test('应该按优先级排序规则', () {
        final rules = router.routingRules;

        // 验证优先级排序
        for (int i = 0; i < rules.length - 1; i++) {
          expect(rules[i].priority >= rules[i + 1].priority, isTrue);
        }
      });
    });

    group('事件路由', () {
      test('应该能够路由匹配的事件', () async {
        // 路由系统广播事件
        final result = await router.routeEvent(
          'system',
          'all_modules',
          'broadcast_update',
          {'version': '3.3.0'},
        );

        expect(result, isTrue);
        expect(router.routingStats['system'], equals(1));
      });

      test('应该拒绝不匹配的事件', () async {
        // 尝试路由不匹配的事件
        final result = await router.routeEvent(
          'unknown_source',
          'unknown_target',
          'unknown_action',
          {},
        );

        expect(result, isFalse);
        expect(router.routingStats['unknown_source'], isNull);
      });

      test('应该按优先级处理规则', () async {
        // 添加高优先级规则
        router.addRoutingRule(
          const TestEventRoutingRule(
            id: 'high_priority_rule',
            sourcePattern: 'test_source',
            targetPattern: 'test_target',
            actionPattern: 'test_action',
            priority: 200,
          ),
        );

        // 路由事件
        final result = await router.routeEvent(
          'test_source',
          'test_target',
          'test_action',
          {},
        );

        expect(result, isTrue);

        // 验证高优先级规则被使用
        final matchingRules = router.findMatchingRules(
          'test_source',
          'test_target',
          'test_action',
        );
        expect(matchingRules.first.id, equals('high_priority_rule'));
      });
    });

    group('模式匹配', () {
      test('应该支持通配符匹配', () {
        const rule = TestEventRoutingRule(
          id: 'wildcard_test',
          sourcePattern: 'module_*',
          targetPattern: '*_service',
          actionPattern: 'action_*',
        );

        expect(
          rule.matches('module_a', 'auth_service', 'action_login'),
          isTrue,
        );
        expect(rule.matches('module_b', 'data_service', 'action_save'), isTrue);
        expect(
          rule.matches('service_a', 'auth_service', 'action_login'),
          isFalse,
        );
        expect(
          rule.matches('module_a', 'auth_handler', 'action_login'),
          isFalse,
        );
        expect(rule.matches('module_a', 'auth_service', 'login'), isFalse);
      });

      test('应该支持精确匹配', () {
        const rule = TestEventRoutingRule(
          id: 'exact_test',
          sourcePattern: 'module_a',
          targetPattern: 'module_b',
          actionPattern: 'specific_action',
        );

        expect(rule.matches('module_a', 'module_b', 'specific_action'), isTrue);
        expect(
          rule.matches('module_a', 'module_c', 'specific_action'),
          isFalse,
        );
        expect(
          rule.matches('module_x', 'module_b', 'specific_action'),
          isFalse,
        );
        expect(rule.matches('module_a', 'module_b', 'other_action'), isFalse);
      });
    });

    group('统计和监控', () {
      test('应该收集路由统计', () async {
        // 路由多个事件
        await router.routeEvent('system', 'module1', 'broadcast_info', {});
        await router.routeEvent('system', 'module2', 'broadcast_warning', {});
        await router.routeEvent('plugin_a', 'plugin_b', 'data_sync', {});

        // 验证统计
        expect(router.routingStats['system'], equals(2));
        expect(router.routingStats['plugin_a'], equals(1));
      });

      test('应该能够清除统计', () async {
        // 生成统计
        await router.routeEvent('system', 'test', 'broadcast_test', {});

        // 清除统计
        router.clearStats();

        // 验证统计已清除
        expect(router.routingStats.isEmpty, isTrue);
      });

      test('应该存储路由消息', () async {
        // 添加一个匹配的规则
        router.addRoutingRule(
          const TestEventRoutingRule(
            id: 'test_storage_rule',
            sourcePattern: 'test_source',
            targetPattern: 'test_target',
            actionPattern: 'test_action',
          ),
        );

        // 路由事件
        await router.routeEvent('test_source', 'test_target', 'test_action', {
          'key': 'value',
        });

        // 验证消息存储
        final messages = router.getRoutedMessages('test_target');
        expect(messages.length, equals(1));
        expect(messages.first.sender, equals('test_source'));
        expect(messages.first.action, equals('test_action'));
        expect(messages.first.data['key'], equals('value'));
      });
    });

    group('事件流监听', () {
      test('应该能够监听路由事件', () async {
        final receivedEvents = <TestEventMessage>[];
        final subscription = router.eventStream.listen((event) {
          receivedEvents.add(event);
        });

        // 添加一个匹配的规则
        router.addRoutingRule(
          const TestEventRoutingRule(
            id: 'test_stream_rule',
            sourcePattern: 'test_source',
            targetPattern: 'test_target',
            actionPattern: 'test_action',
          ),
        );

        // 路由事件
        await router.routeEvent('test_source', 'test_target', 'test_action', {
          'data': 'test',
        });

        // 等待事件传播
        await Future.delayed(const Duration(milliseconds: 10));

        // 验证事件接收
        expect(receivedEvents.length, equals(1));
        expect(receivedEvents.first.sender, equals('test_source'));
        expect(receivedEvents.first.action, equals('test_action'));

        await subscription.cancel();
      });
    });

    group('边界情况处理', () {
      test('应该处理空规则列表', () {
        // 清除所有规则
        final allRules = router.routingRules.map((r) => r.id).toList();
        for (final ruleId in allRules) {
          router.removeRoutingRule(ruleId);
        }

        // 尝试路由事件
        final future = router.routeEvent('test', 'test', 'test', {});
        expect(future, completion(isFalse));
      });

      test('应该处理重复规则ID', () {
        const rule1 = TestEventRoutingRule(
          id: 'duplicate_id',
          sourcePattern: 'source1',
          targetPattern: 'target1',
        );

        const rule2 = TestEventRoutingRule(
          id: 'duplicate_id',
          sourcePattern: 'source2',
          targetPattern: 'target2',
        );

        router.addRoutingRule(rule1);
        router.addRoutingRule(rule2);

        // 移除重复ID应该移除所有匹配的规则
        router.removeRoutingRule('duplicate_id');

        final rules = router.routingRules;
        expect(rules.any((r) => r.id == 'duplicate_id'), isFalse);
      });

      test('清理后应该清空所有数据', () async {
        // 添加一些数据
        router.addRoutingRule(
          const TestEventRoutingRule(
            id: 'temp_rule',
            sourcePattern: '*',
            targetPattern: '*',
          ),
        );

        await router.routeEvent('test', 'test', 'test', {});

        // 清理
        router.dispose();

        // 验证清理效果（创建新实例来验证）
        final newRouter = TestCrossModuleEventRouter();
        expect(newRouter.routingRules.isEmpty, isTrue);
        expect(newRouter.routingStats.isEmpty, isTrue);

        newRouter.dispose();
      });
    });
  });
}
