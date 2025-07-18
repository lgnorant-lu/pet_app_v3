/*
---------------------------------------------------------------
File name:          plugin_system_test.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件系统测试 (Plugin System Tests)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件系统测试 (Plugin System Tests);
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';
import 'package:plugin_system/src/core/plugin_loader.dart';
import 'package:plugin_system/src/core/plugin_messenger.dart';
import 'package:plugin_system/src/core/event_bus.dart';
import 'package:plugin_system/src/core/plugin_exceptions.dart';
import 'helpers/test_plugin.dart';

void main() {
  group('PluginRegistry Tests', () {
    late PluginRegistry registry;
    late TestPlugin testPlugin;

    setUp(() {
      registry = PluginRegistry.instance;
      testPlugin = TestPlugin(pluginId: 'test_registry_plugin');
    });

    tearDown(() async {
      // 清理注册中心
      try {
        await registry.clear();
      } catch (e) {
        // 忽略清理错误
      }
    });

    test('should register plugin successfully', () async {
      expect(registry.contains(testPlugin.id), isFalse);

      await registry.register(testPlugin);

      expect(registry.contains(testPlugin.id), isTrue);
      expect(registry.get(testPlugin.id), equals(testPlugin));
      expect(registry.getState(testPlugin.id), equals(PluginState.loaded));
    });

    test('should throw exception when registering duplicate plugin', () async {
      await registry.register(testPlugin);

      expect(
        () => registry.register(testPlugin),
        throwsA(isA<PluginAlreadyExistsException>()),
      );
    });

    test('should unregister plugin successfully', () async {
      await registry.register(testPlugin);
      expect(registry.contains(testPlugin.id), isTrue);

      await registry.unregister(testPlugin.id);

      expect(registry.contains(testPlugin.id), isFalse);
      expect(registry.get(testPlugin.id), isNull);
    });

    test('should throw exception when unregistering non-existent plugin',
        () async {
      expect(
        () => registry.unregister('non_existent'),
        throwsA(isA<PluginNotFoundException>()),
      );
    });

    test('should get plugins by category', () async {
      final TestPlugin toolPlugin = TestPlugin(pluginId: 'tool_plugin');
      final TestPlugin gamePlugin = TestPlugin(pluginId: 'game_plugin');

      await registry.register(toolPlugin);
      await registry.register(gamePlugin);

      final List<Plugin> toolPlugins =
          registry.getByCategory(PluginCategory.tool);
      expect(toolPlugins.length, equals(2));
      expect(toolPlugins.map((Plugin p) => p.id), contains(toolPlugin.id));
      expect(toolPlugins.map((Plugin p) => p.id), contains(gamePlugin.id));
    });

    test('should update plugin state', () async {
      await registry.register(testPlugin);
      expect(registry.getState(testPlugin.id), equals(PluginState.loaded));

      registry.updateState(testPlugin.id, PluginState.started);
      expect(registry.getState(testPlugin.id), equals(PluginState.started));
    });
  });

  group('PluginLoader Tests', () {
    late PluginLoader loader;
    late PluginRegistry registry;

    setUp(() {
      loader = PluginLoader.instance;
      registry = PluginRegistry.instance;
    });

    tearDown(() async {
      try {
        await loader.unloadAllPlugins(force: true);
        await registry.clear();
      } catch (e) {
        // 忽略清理错误
      }
    });

    test('should load plugin successfully', () async {
      final testPlugin = TestPlugin(pluginId: 'test_loader_plugin_1');
      expect(registry.contains(testPlugin.id), isFalse);

      await loader.loadPlugin(testPlugin);

      expect(registry.contains(testPlugin.id), isTrue);
      expect(registry.getState(testPlugin.id), equals(PluginState.started));
    });

    test('should unload plugin successfully', () async {
      final testPlugin = TestPlugin(pluginId: 'test_loader_plugin_2');
      await loader.loadPlugin(testPlugin);
      expect(registry.contains(testPlugin.id), isTrue);

      await loader.unloadPlugin(testPlugin.id);

      expect(registry.contains(testPlugin.id), isFalse);
    });

    test('should pause and resume plugin', () async {
      final testPlugin = TestPlugin(pluginId: 'test_loader_plugin_3');
      await loader.loadPlugin(testPlugin);
      expect(registry.getState(testPlugin.id), equals(PluginState.started));

      await loader.pausePlugin(testPlugin.id);
      expect(registry.getState(testPlugin.id), equals(PluginState.paused));

      await loader.resumePlugin(testPlugin.id);
      expect(registry.getState(testPlugin.id), equals(PluginState.started));
    });
  });

  group('PluginMessenger Tests', () {
    late PluginMessenger messenger;
    late PluginRegistry registry;

    setUp(() {
      messenger = PluginMessenger.instance;
      registry = PluginRegistry.instance;
    });

    tearDown(() async {
      try {
        await registry.clear();
      } catch (e) {
        // 忽略清理错误
      }
    });

    test('should send message successfully', () async {
      final testPlugin = TestPlugin(pluginId: 'test_messenger_plugin_1');
      final echoPlugin = EchoPlugin(pluginId: 'echo_messenger_plugin_1');

      await registry.register(testPlugin);
      await registry.register(echoPlugin);
      registry.updateState(testPlugin.id, PluginState.started);
      registry.updateState(echoPlugin.id, PluginState.started);

      final PluginMessageResponse response = await messenger.sendMessage(
        testPlugin.id,
        echoPlugin.id,
        'test_action',
        <String, dynamic>{'test': 'data'},
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
    });

    test('should send notification successfully', () async {
      final testPlugin = TestPlugin(pluginId: 'test_messenger_plugin_2');
      final echoPlugin = EchoPlugin(pluginId: 'echo_messenger_plugin_2');

      await registry.register(testPlugin);
      await registry.register(echoPlugin);
      registry.updateState(testPlugin.id, PluginState.started);
      registry.updateState(echoPlugin.id, PluginState.started);

      // 通知不应该抛出异常
      await messenger.sendNotification(
        testPlugin.id,
        echoPlugin.id,
        'notification',
        <String, dynamic>{'type': 'test'},
      );
    });
  });

  group('EventBus Tests', () {
    late EventBus eventBus;

    setUp(() {
      eventBus = EventBus.instance;
    });

    tearDown(() {
      eventBus.clearSubscriptions();
      eventBus.clearStats();
    });

    test('should publish and receive events', () async {
      bool eventReceived = false;
      String? receivedData;

      final EventSubscription subscription =
          eventBus.on('test_event', (PluginEvent event) {
        eventReceived = true;
        receivedData = event.data?['message'] as String?;
      });

      eventBus.publish('test_event', 'test_source', data: <String, dynamic>{
        'message': 'Hello World',
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(eventReceived, isTrue);
      expect(receivedData, equals('Hello World'));

      subscription.cancel();
    });

    test('should filter events correctly', () async {
      int eventCount = 0;

      final EventSubscription subscription = eventBus.subscribe(
        (PluginEvent event) => eventCount++,
        eventType: 'filtered_event',
      );

      eventBus.publish('filtered_event', 'source1');
      eventBus.publish('other_event', 'source1');
      eventBus.publish('filtered_event', 'source2');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(eventCount, equals(2));

      subscription.cancel();
    });
  });
}
