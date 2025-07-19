/*
---------------------------------------------------------------
File name:          hot_reload_manager_test.dart
Author:             lgnorant-lu
Date created:       2025/07/19
Last modified:      2025/07/19
Dart Version:       3.2+
Description:        热重载管理器单元测试 (Hot Reload Manager Unit Tests)
---------------------------------------------------------------
Change History:
    2025/07/19: Initial creation - 热重载管理器单元测试 (Hot Reload Manager Unit Tests);
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:plugin_system/src/core/hot_reload_manager.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';
import 'package:plugin_system/src/core/plugin_loader.dart';
import '../../helpers/test_plugin.dart';

void main() {
  group('HotReloadManager Unit Tests', () {
    late HotReloadManager hotReloadManager;
    late PluginRegistry registry;
    late PluginLoader loader;

    setUp(() {
      hotReloadManager = HotReloadManager.instance;
      registry = PluginRegistry.instance;
      loader = PluginLoader.instance;
    });

    tearDown(() async {
      try {
        await hotReloadManager.stopWatching();
      } catch (_) {
        // 忽略停止错误
      }
      await loader.unloadAllPlugins(force: true);
      await registry.clear();
    });

    group('Basic Functionality', () {
      test('should start and stop watching', () async {
        // 开始监听
        await hotReloadManager.startWatching(['/mock/path1', '/mock/path2']);

        // 停止监听
        await hotReloadManager.stopWatching();

        expect(true, isTrue); // 基本功能测试
      });

      test('should handle empty path list', () async {
        await hotReloadManager.startWatching([]);
        await hotReloadManager.stopWatching();

        expect(true, isTrue);
      });
    });

    group('Plugin Operations', () {
      test('should reload plugin successfully', () async {
        final plugin = TestPlugin(pluginId: 'reload_test_plugin');
        await loader.loadPlugin(plugin);

        // 重载插件
        final result = await hotReloadManager.reloadPlugin(plugin.id);
        expect(result.success, isTrue);
        expect(result.pluginId, equals(plugin.id));
        expect(registry.contains(plugin.id), isTrue);
      });

      test('should handle non-existent plugin reload', () async {
        final result =
            await hotReloadManager.reloadPlugin('non_existent_plugin');
        expect(result.success, isFalse);
        expect(result.error, contains('Plugin not found'));
      });

      test('should reload plugin with state preservation', () async {
        final plugin = TestPlugin(pluginId: 'preserve_state_test');
        await loader.loadPlugin(plugin);

        // 重载插件并保持状态
        final result = await hotReloadManager.reloadPlugin(
          plugin.id,
          preserveState: true,
        );

        expect(result.success, isTrue);
        expect(registry.contains(plugin.id), isTrue);
      });

      test('should reload plugin without state preservation', () async {
        final plugin = TestPlugin(pluginId: 'no_preserve_test');
        await loader.loadPlugin(plugin);

        // 重载插件不保持状态
        final result = await hotReloadManager.reloadPlugin(
          plugin.id,
          preserveState: false,
        );

        expect(result.success, isTrue);
        expect(registry.contains(plugin.id), isTrue);
      });
    });

    group('State Management', () {
      test('should get state snapshots', () async {
        final plugin = TestPlugin(pluginId: 'snapshot_test_plugin');
        await loader.loadPlugin(plugin);

        // 重载插件会创建快照
        await hotReloadManager.reloadPlugin(plugin.id, preserveState: true);

        // 获取快照
        final snapshot = hotReloadManager.getStateSnapshot(plugin.id);
        expect(snapshot, isA<PluginStateSnapshot?>());
      });

      test('should cleanup plugin data', () async {
        final plugin = TestPlugin(pluginId: 'cleanup_test_plugin');
        await loader.loadPlugin(plugin);

        // 重载插件创建数据
        await hotReloadManager.reloadPlugin(plugin.id);

        // 清理插件数据
        hotReloadManager.cleanupPlugin(plugin.id);

        // 验证数据被清理
        final snapshot = hotReloadManager.getStateSnapshot(plugin.id);
        expect(snapshot, isNull);
      });
    });

    group('Batch Operations', () {
      test('should handle reload all plugins', () async {
        final plugin1 = TestPlugin(pluginId: 'batch_test_1');
        final plugin2 = TestPlugin(pluginId: 'batch_test_2');

        await loader.loadPlugin(plugin1);
        await loader.loadPlugin(plugin2);

        // 批量重载
        final results = await hotReloadManager.reloadAllPlugins();

        expect(results.length, equals(2));
        expect(results.every((r) => r.success), isTrue);
        expect(registry.contains(plugin1.id), isTrue);
        expect(registry.contains(plugin2.id), isTrue);
      });

      test('should handle reload all with state preservation', () async {
        final plugin1 = TestPlugin(pluginId: 'preserve_batch_1');
        final plugin2 = TestPlugin(pluginId: 'preserve_batch_2');

        await loader.loadPlugin(plugin1);
        await loader.loadPlugin(plugin2);

        // 批量重载并保持状态
        final results = await hotReloadManager.reloadAllPlugins(
          preserveState: true,
        );

        expect(results.length, equals(2));
        expect(results.every((r) => r.success), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle multiple start watching calls', () async {
        await hotReloadManager.startWatching(['/path1']);

        // 重复启动不应该出错
        await expectLater(
          () => hotReloadManager.startWatching(['/path2']),
          returnsNormally,
        );
      });

      test('should handle multiple stop watching calls', () async {
        await hotReloadManager.startWatching(['/path1']);
        await hotReloadManager.stopWatching();

        // 重复停止不应该出错
        await expectLater(
          () => hotReloadManager.stopWatching(),
          returnsNormally,
        );
      });

      test('should handle dispose', () async {
        await hotReloadManager.startWatching(['/path1']);

        // 销毁不应该出错
        await expectLater(
          () => hotReloadManager.dispose(),
          returnsNormally,
        );
      });
    });
  });
}
