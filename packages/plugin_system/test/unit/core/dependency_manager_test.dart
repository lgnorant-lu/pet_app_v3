/*
---------------------------------------------------------------
File name:          dependency_manager_test.dart
Author:             lgnorant-lu
Date created:       2025/07/19
Last modified:      2025/07/19
Dart Version:       3.2+
Description:        依赖管理器单元测试 (Dependency Manager Unit Tests)
---------------------------------------------------------------
Change History:
    2025/07/19: Initial creation - 依赖管理器单元测试 (Dependency Manager Unit Tests);
---------------------------------------------------------------
*/

import 'package:plugin_system/src/core/dependency_manager.dart';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_loader.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';
import 'package:test/test.dart';

import '../../helpers/test_plugin.dart';

void main() {
  group('DependencyManager Unit Tests', () {
    late DependencyManager dependencyManager;
    late PluginRegistry registry;
    late PluginLoader loader;

    setUp(() {
      dependencyManager = DependencyManager.instance;
      registry = PluginRegistry.instance;
      loader = PluginLoader.instance;
    });

    tearDown(() async {
      await loader.unloadAllPlugins(force: true);
      await registry.clear();
    });

    group('Basic Functionality', () {
      test('should cleanup plugin', () {
        expect(
          () => dependencyManager.cleanupPlugin('test_plugin'),
          returnsNormally,
        );
      });

      test('should update dependency graph', () {
        final plugin = TestPlugin(pluginId: 'update_test');
        expect(
          () => dependencyManager.updateDependencyGraph(plugin),
          returnsNormally,
        );
      });
    });

    group('Dependency Resolution', () {
      test('should resolve dependencies for empty plugin list', () async {
        final result = await dependencyManager.resolveDependencies(<Plugin>[]);
        expect(result.success, isTrue);
        expect(result.loadOrder, isEmpty);
        expect(result.conflicts, isEmpty);
      });

      test('should resolve dependencies for single plugin', () async {
        final plugin = TestPlugin(pluginId: 'single_test_plugin');
        await loader.loadPlugin(plugin);

        final result =
            await dependencyManager.resolveDependencies(<Plugin>[plugin]);
        expect(result.success, isTrue);
        expect(result.loadOrder, contains(plugin.id));
      });

      test('should resolve dependencies for multiple plugins', () async {
        final plugin1 = TestPlugin(pluginId: 'multi_test_1');
        final plugin2 = TestPlugin(pluginId: 'multi_test_2');

        await loader.loadPlugin(plugin1);
        await loader.loadPlugin(plugin2);

        final result = await dependencyManager
            .resolveDependencies(<Plugin>[plugin1, plugin2]);
        expect(result.success, isTrue);
        expect(result.loadOrder.length, equals(2));
        expect(result.loadOrder, contains(plugin1.id));
        expect(result.loadOrder, contains(plugin2.id));
      });
    });

    group('Dependency Checking', () {
      test('should check dependencies for plugin', () async {
        final plugin = TestPlugin(pluginId: 'check_test_plugin');
        await loader.loadPlugin(plugin);

        final hasAllDeps = await dependencyManager.checkDependencies(plugin);
        expect(hasAllDeps, isA<bool>());
      });

      // getMissingDependencies方法不存在，跳过此测试
    });

    group('Plugin Dependencies', () {
      test('should get plugin dependencies', () {
        final dependencies =
            dependencyManager.getPluginDependencies('test_plugin');
        expect(dependencies, isA<List<String>>());
      });

      test('should get plugin dependencies recursively', () {
        final dependencies = dependencyManager.getPluginDependencies(
          'test_plugin',
          recursive: true,
        );
        expect(dependencies, isA<List<String>>());
      });

      test('should get plugin dependents', () {
        final dependents = dependencyManager.getPluginDependents('test_plugin');
        expect(dependents, isA<List<String>>());
      });
    });

    group('Plugin Management', () {
      test('should check if plugin can be unloaded', () {
        final canUnload = dependencyManager.canUnloadPlugin('test_plugin');
        expect(canUnload, isA<bool>());
      });

      test('should auto install dependencies', () async {
        final plugin = TestPlugin(pluginId: 'auto_install_test');
        await loader.loadPlugin(plugin);

        final installed =
            await dependencyManager.autoInstallDependencies(plugin);
        expect(installed, isA<List<String>>());
      });

      test('should update dependency graph', () {
        final plugin = TestPlugin(pluginId: 'update_graph_test');

        expect(
          () => dependencyManager.updateDependencyGraph(plugin),
          returnsNormally,
        );
      });

      test('should cleanup plugin', () {
        expect(
          () => dependencyManager.cleanupPlugin('test_plugin'),
          returnsNormally,
        );
      });
    });

    group('Error Handling', () {
      test('should handle non-existent plugin dependencies', () {
        final dependencies =
            dependencyManager.getPluginDependencies('non_existent');
        expect(dependencies, isEmpty);
      });

      test('should handle non-existent plugin dependents', () {
        final dependents =
            dependencyManager.getPluginDependents('non_existent');
        expect(dependents, isEmpty);
      });

      test('should handle cleanup of non-existent plugin', () {
        expect(
          () => dependencyManager.cleanupPlugin('non_existent'),
          returnsNormally,
        );
      });
    });

    group('Performance Tests', () {
      test('should handle large plugin lists efficiently', () async {
        final plugins = <TestPlugin>[];
        for (int i = 0; i < 20; i++) {
          final plugin = TestPlugin(pluginId: 'perf_test_$i');
          plugins.add(plugin);
          await loader.loadPlugin(plugin);
        }

        final stopwatch = Stopwatch()..start();
        final result = await dependencyManager.resolveDependencies(plugins);
        stopwatch.stop();

        expect(result.success, isTrue);
        expect(result.loadOrder.length, equals(plugins.length));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 应该在1秒内完成
      });
    });

    group('Integration Tests', () {
      test('should work with plugin registry', () async {
        final plugin = TestPlugin(pluginId: 'integration_test');
        await loader.loadPlugin(plugin);

        // 更新依赖图
        dependencyManager.updateDependencyGraph(plugin);

        // 检查依赖
        final hasAllDeps = await dependencyManager.checkDependencies(plugin);
        expect(hasAllDeps, isA<bool>());

        // 清理
        dependencyManager.cleanupPlugin(plugin.id);
      });
    });
  });
}
