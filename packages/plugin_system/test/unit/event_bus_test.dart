/*
---------------------------------------------------------------
File name:          event_bus_test.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        事件总线单元测试
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:test/test.dart';
import 'package:plugin_system/src/core/event_bus.dart';

void main() {
  group('EventBus Unit Tests', () {
    late EventBus eventBus;

    setUp(() {
      eventBus = EventBus.instance;
    });

    tearDown(() {
      eventBus.clearSubscriptions();
      eventBus.clearStats();
    });

    group('Event Publishing', () {
      test('should publish events successfully', () async {
        bool eventReceived = false;
        String? receivedType;
        String? receivedSource;
        Map<String, dynamic>? receivedData;

        final subscription = eventBus.subscribe((event) {
          eventReceived = true;
          receivedType = event.type;
          receivedSource = event.source;
          receivedData = event.data;
        });

        eventBus.publish(
          'test_event',
          'test_source',
          data: {'message': 'Hello World'},
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(eventReceived, isTrue);
        expect(receivedType, equals('test_event'));
        expect(receivedSource, equals('test_source'));
        expect(receivedData?['message'], equals('Hello World'));

        subscription.cancel();
      });

      test('should publish events with timestamp', () async {
        PluginEvent? receivedEvent;

        final subscription = eventBus.subscribe((event) {
          receivedEvent = event;
        });

        final beforePublish = DateTime.now();
        eventBus.publish('timestamped_event', 'source');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final afterPublish = DateTime.now();

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.timestamp, isNotNull);
        expect(
          receivedEvent!.timestamp!.isAfter(beforePublish) ||
              receivedEvent!.timestamp!.isAtSameMomentAs(beforePublish),
          isTrue,
        );
        expect(
          receivedEvent!.timestamp!.isBefore(afterPublish) ||
              receivedEvent!.timestamp!.isAtSameMomentAs(afterPublish),
          isTrue,
        );

        subscription.cancel();
      });
    });

    group('Event Subscription', () {
      test('should subscribe to all events', () async {
        final receivedEvents = <PluginEvent>[];

        final subscription = eventBus.subscribe((event) {
          receivedEvents.add(event);
        });

        eventBus.publish('event1', 'source1');
        eventBus.publish('event2', 'source2');
        eventBus.publish('event3', 'source1');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(receivedEvents.length, equals(3));
        expect(receivedEvents.map((e) => e.type), contains('event1'));
        expect(receivedEvents.map((e) => e.type), contains('event2'));
        expect(receivedEvents.map((e) => e.type), contains('event3'));

        subscription.cancel();
      });

      test('should subscribe to specific event type', () async {
        final receivedEvents = <PluginEvent>[];

        final subscription = eventBus.on('specific_event', (event) {
          receivedEvents.add(event);
        });

        eventBus.publish('specific_event', 'source1');
        eventBus.publish('other_event', 'source1');
        eventBus.publish('specific_event', 'source2');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(receivedEvents.length, equals(2));
        expect(receivedEvents.every((e) => e.type == 'specific_event'), isTrue);

        subscription.cancel();
      });

      test('should subscribe to events from specific source', () async {
        final receivedEvents = <PluginEvent>[];

        final subscription = eventBus.from('specific_source', (event) {
          receivedEvents.add(event);
        });

        eventBus.publish('event1', 'specific_source');
        eventBus.publish('event2', 'other_source');
        eventBus.publish('event3', 'specific_source');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(receivedEvents.length, equals(2));
        expect(
            receivedEvents.every((e) => e.source == 'specific_source'), isTrue);

        subscription.cancel();
      });

      test('should apply custom filters', () async {
        final receivedEvents = <PluginEvent>[];

        final subscription = eventBus.subscribe(
          (event) => receivedEvents.add(event),
          filter: (event) => event.data?['priority'] == 'high',
        );

        eventBus.publish('event1', 'source', data: {'priority': 'high'});
        eventBus.publish('event2', 'source', data: {'priority': 'low'});
        eventBus.publish('event3', 'source', data: {'priority': 'high'});

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(receivedEvents.length, equals(2));
        expect(
          receivedEvents.every((e) => e.data?['priority'] == 'high'),
          isTrue,
        );

        subscription.cancel();
      });
    });

    group('Event Streams', () {
      test('should provide event stream', () async {
        final receivedEvents = <PluginEvent>[];

        final streamSubscription = eventBus.stream.listen((event) {
          receivedEvents.add(event);
        });

        eventBus.publish('stream_event1', 'source');
        eventBus.publish('stream_event2', 'source');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(receivedEvents.length, equals(2));

        await streamSubscription.cancel();
      });

      test('should provide filtered event streams', () async {
        final specificEvents = <PluginEvent>[];
        final sourceEvents = <PluginEvent>[];

        final typeStreamSub =
            eventBus.streamOf('specific_type').listen((event) {
          specificEvents.add(event);
        });

        final sourceStreamSub =
            eventBus.streamFrom('specific_source').listen((event) {
          sourceEvents.add(event);
        });

        eventBus.publish('specific_type', 'source1');
        eventBus.publish('other_type', 'specific_source');
        eventBus.publish('specific_type', 'specific_source');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(specificEvents.length, equals(2));
        expect(sourceEvents.length, equals(2));

        await typeStreamSub.cancel();
        await sourceStreamSub.cancel();
      });
    });

    group('Event Waiting', () {
      test('should wait for specific event', () async {
        // 启动等待
        final waitFuture = eventBus.waitFor('awaited_event');

        // 延迟发布事件
        Timer(const Duration(milliseconds: 100), () {
          eventBus
              .publish('awaited_event', 'source', data: {'result': 'success'});
        });

        final receivedEvent = await waitFuture;

        expect(receivedEvent.type, equals('awaited_event'));
        expect(receivedEvent.source, equals('source'));
        expect(receivedEvent.data?['result'], equals('success'));
      });

      test('should timeout when waiting for event', () async {
        expect(
          () => eventBus.waitFor(
            'never_published_event',
            timeout: const Duration(milliseconds: 100),
          ),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should wait for event with filter', () async {
        // 启动等待（只等待priority为high的事件）
        final waitFuture = eventBus.waitFor(
          'filtered_event',
          filter: (event) => event.data?['priority'] == 'high',
        );

        // 发布不符合条件的事件
        Timer(const Duration(milliseconds: 50), () {
          eventBus
              .publish('filtered_event', 'source', data: {'priority': 'low'});
        });

        // 发布符合条件的事件
        Timer(const Duration(milliseconds: 100), () {
          eventBus
              .publish('filtered_event', 'source', data: {'priority': 'high'});
        });

        final receivedEvent = await waitFuture;

        expect(receivedEvent.data?['priority'], equals('high'));
      });
    });

    group('Subscription Management', () {
      test('should cancel subscriptions', () async {
        final receivedEvents = <PluginEvent>[];

        final subscription = eventBus.subscribe((event) {
          receivedEvents.add(event);
        });

        eventBus.publish('before_cancel', 'source');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        subscription.cancel();

        eventBus.publish('after_cancel', 'source');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(receivedEvents.length, equals(1));
        expect(receivedEvents.first.type, equals('before_cancel'));
      });

      test('should track subscription status', () {
        final subscription = eventBus.subscribe((event) {});

        expect(subscription.isActive, isTrue);

        subscription.cancel();

        expect(subscription.isActive, isFalse);
      });

      test('should clear all subscriptions', () async {
        final receivedEvents = <PluginEvent>[];

        eventBus.subscribe((event) => receivedEvents.add(event));
        eventBus.subscribe((event) => receivedEvents.add(event));

        eventBus.publish('before_clear', 'source');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        eventBus.clearSubscriptions();

        eventBus.publish('after_clear', 'source');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // 应该收到2个事件（每个订阅者一个）
        expect(receivedEvents.length, equals(2));
        expect(receivedEvents.every((e) => e.type == 'before_clear'), isTrue);
      });
    });

    group('Statistics', () {
      test('should track event statistics', () {
        expect(eventBus.getEventStats(), isEmpty);

        eventBus.publish('event_type1', 'source');
        eventBus.publish('event_type1', 'source');
        eventBus.publish('event_type2', 'source');

        final stats = eventBus.getEventStats();
        expect(stats['event_type1'], equals(2));
        expect(stats['event_type2'], equals(1));
      });

      test('should track subscription statistics', () {
        // 先清理所有订阅
        eventBus.clearSubscriptions();

        final stats1 = eventBus.getSubscriptionStats();
        expect(stats1['activeSubscriptions'], equals(0));

        final sub1 = eventBus.subscribe((event) {});
        final sub2 = eventBus.subscribe((event) {});

        final stats2 = eventBus.getSubscriptionStats();
        expect(stats2['activeSubscriptions'], equals(2));

        sub1.cancel();

        final stats3 = eventBus.getSubscriptionStats();
        expect(stats3['activeSubscriptions'], equals(1));
        expect(stats3['totalSubscriptions'], equals(1)); // 取消的订阅被移除了

        sub2.cancel();

        final stats4 = eventBus.getSubscriptionStats();
        expect(stats4['activeSubscriptions'], equals(0));
        expect(stats4['totalSubscriptions'], equals(0)); // 所有订阅都被移除了
      });

      test('should clear statistics', () {
        eventBus.publish('test_event', 'source');
        expect(eventBus.getEventStats(), isNotEmpty);

        eventBus.clearStats();
        expect(eventBus.getEventStats(), isEmpty);
      });
    });
  });
}
