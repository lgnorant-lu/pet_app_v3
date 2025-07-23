/*
---------------------------------------------------------------
File name:          plugin_registry_test.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件注册中心单元测试
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:test/test.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';
import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_exceptions.dart';
import '../helpers/test_plugin.dart';

void main() {
  group('PluginRegistry Unit Tests', () {
    late PluginRegistry registry;

    setUp(() {
      registry = PluginRegistry.instance;
    });

    tearDown(() async {
      try {
        // 强制清理所有插件
        final allPlugins = registry.getAll();
        for (final plugin in allPlugins) {
          try {
            if (plugin.currentState != PluginState.stopped) {
              await plugin.stop();
            }
            await plugin.dispose();
          } catch (e) {
            // 忽略单个插件清理错误
          }
        }
        await registry.clear(force: true);
      } on Exception {
        // 忽略清理错误
      }
    });

    group('Plugin Registration', () {
      test('should register plugin with valid metadata', () async {
        final plugin = TestPlugin(pluginId: 'valid_plugin');

        await registry.register(plugin);

        expect(registry.contains(plugin.id), isTrue);
        expect(registry.get(plugin.id), equals(plugin));

        final metadata = registry.getMetadata(plugin.id);
        expect(metadata, isNotNull);
        expect(metadata!.id, equals(plugin.id));
        expect(metadata.name, equals(plugin.name));
        expect(metadata.version, equals(plugin.version));
      });

      test('should throw exception for duplicate plugin registration',
          () async {
        final plugin = TestPlugin(pluginId: 'duplicate_plugin');

        await registry.register(plugin);

        expect(
          () => registry.register(plugin),
          throwsA(isA<PluginAlreadyExistsException>()),
        );
      });

      test('should validate plugin before registration', () async {
        final invalidPlugin = TestPlugin(
          pluginId: '', // 无效的空ID
        );

        expect(
          () => registry.register(invalidPlugin),
          throwsA(isA<PluginConfigurationException>()),
        );
      });
    });

    group('Plugin Unregistration', () {
      test('should unregister existing plugin', () async {
        final plugin = TestPlugin(pluginId: 'unregister_test');

        await registry.register(plugin);
        expect(registry.contains(plugin.id), isTrue);

        await registry.unregister(plugin.id);
        expect(registry.contains(plugin.id), isFalse);
        expect(registry.get(plugin.id), isNull);
      });

      test('should throw exception for non-existent plugin', () async {
        expect(
          () => registry.unregister('non_existent'),
          throwsA(isA<PluginNotFoundException>()),
        );
      });

      test('should prevent unregistration of plugin with dependents', () async {
        final basePlugin = TestPlugin(pluginId: 'base_plugin');
        final dependentPlugin = TestPluginWithDependency(
          pluginId: 'dependent_plugin',
          dependsOn: 'base_plugin',
        );

        await registry.register(basePlugin);
        await registry.register(dependentPlugin);

        expect(
          () => registry.unregister(basePlugin.id),
          throwsA(isA<PluginDependencyException>()),
        );
      });
    });

    group('Plugin Queries', () {
      test('should get plugins by category', () async {
        // 先清理注册中心
        await registry.clear(force: true);

        final toolPlugin1 = TestPlugin(pluginId: 'query_tool1');
        final toolPlugin2 = TestPlugin(pluginId: 'query_tool2');
        final gamePlugin = TestPlugin(pluginId: 'query_game1');

        await registry.register(toolPlugin1);
        await registry.register(toolPlugin2);
        await registry.register(gamePlugin);

        final toolPlugins = registry.getByCategory(PluginType.tool);
        expect(toolPlugins.length, equals(3)); // 所有测试插件都是tool类型

        final gamePlugins = registry.getByCategory(PluginType.game);
        expect(gamePlugins.length, equals(0)); // 没有game类型的插件
      });

      test('should get plugins by state', () async {
        // 先清理注册中心
        await registry.clear(force: true);

        final plugin1 = TestPlugin(pluginId: 'state_query_test1');
        final plugin2 = TestPlugin(pluginId: 'state_query_test2');

        await registry.register(plugin1);
        await registry.register(plugin2);

        // 默认状态应该是loaded
        final loadedPlugins = registry.getByState(PluginState.loaded);
        expect(loadedPlugins.length, equals(2));

        // 更新一个插件的状态
        registry.updateState(plugin1.id, PluginState.started);

        final startedPlugins = registry.getByState(PluginState.started);
        expect(startedPlugins.length, equals(1));
        expect(startedPlugins.first.id, equals(plugin1.id));
      });

      test('should get all plugins', () async {
        // 先清理注册中心
        await registry.clear(force: true);

        final plugin1 = TestPlugin(pluginId: 'all_query_test1');
        final plugin2 = TestPlugin(pluginId: 'all_query_test2');
        final plugin3 = TestPlugin(pluginId: 'all_query_test3');

        await registry.register(plugin1);
        await registry.register(plugin2);
        await registry.register(plugin3);

        final allPlugins = registry.getAll();
        expect(allPlugins.length, equals(3));

        final pluginIds = allPlugins.map((Plugin p) => p.id).toSet();
        expect(pluginIds, contains(plugin1.id));
        expect(pluginIds, contains(plugin2.id));
        expect(pluginIds, contains(plugin3.id));
      });
    });

    group('State Management', () {
      test('should update plugin state', () async {
        final plugin = TestPlugin(pluginId: 'state_update_test');

        await registry.register(plugin);
        expect(registry.getState(plugin.id), equals(PluginState.loaded));

        registry.updateState(plugin.id, PluginState.started);
        expect(registry.getState(plugin.id), equals(PluginState.started));

        registry.updateState(plugin.id, PluginState.paused);
        expect(registry.getState(plugin.id), equals(PluginState.paused));
      });

      test('should provide state change stream', () async {
        final plugin = TestPlugin(pluginId: 'state_stream_test');

        await registry.register(plugin);

        final stateStream = registry.getStateStream(plugin.id);
        expect(stateStream, isNotNull);

        final states = <PluginState>[];
        final subscription = stateStream!.listen(states.add);

        registry.updateState(plugin.id, PluginState.started);
        registry.updateState(plugin.id, PluginState.paused);
        registry.updateState(plugin.id, PluginState.stopped);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(states, contains(PluginState.started));
        expect(states, contains(PluginState.paused));
        expect(states, contains(PluginState.stopped));

        await subscription.cancel();
      });

      test('should throw exception for invalid plugin state update', () async {
        expect(
          () => registry.updateState('non_existent', PluginState.started),
          throwsA(isA<PluginNotFoundException>()),
        );
      });
    });

    group('Registry Statistics', () {
      test('should track plugin count', () async {
        // 先清理注册中心
        await registry.clear(force: true);
        expect(registry.count, equals(0));

        final plugin1 = TestPlugin(pluginId: 'count_test1');
        await registry.register(plugin1);
        expect(registry.count, equals(1));

        final plugin2 = TestPlugin(pluginId: 'count_test2');
        await registry.register(plugin2);
        expect(registry.count, equals(2));

        await registry.unregister(plugin1.id);
        expect(registry.count, equals(1));

        await registry.clear(force: true);
        expect(registry.count, equals(0));
      });

      test('should clear all plugins', () async {
        // 先清理注册中心
        await registry.clear(force: true);

        final plugin1 = TestPlugin(pluginId: 'clear_test1');
        final plugin2 = TestPlugin(pluginId: 'clear_test2');

        await registry.register(plugin1);
        await registry.register(plugin2);
        expect(registry.count, equals(2));

        await registry.clear(force: true);
        expect(registry.count, equals(0));
        expect(registry.getAll(), isEmpty);
      });
    });
  });
}

/// 带依赖的测试插件
class TestPluginWithDependency extends TestPlugin {
  TestPluginWithDependency({
    required super.pluginId,
    required String dependsOn,
  }) : _dependsOn = dependsOn;

  final String _dependsOn;

  @override
  List<PluginDependency> get dependencies => <PluginDependency>[
        PluginDependency(
          pluginId: _dependsOn,
          versionConstraint: '^1.0.0',
        ),
      ];
}
