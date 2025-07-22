/*
---------------------------------------------------------------
File name:          plugin_manager_test.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件管理器测试
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件管理器测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('PluginManager Tests', () {
    late PluginManager pluginManager;
    var testCounter = 0;

    setUp(() {
      pluginManager = PluginManager.instance;
      testCounter++;
    });

    tearDown(() async {
      // 清理测试插件
      final testPluginIds = [
        'test_plugin_$testCounter',
        'test_plugin_enable_$testCounter',
        'test_plugin_disable_$testCounter',
        'test_plugin_update_$testCounter',
        'test_plugin',
        'test_plugin_enable_1',
        'test_plugin_for_uninstall',
      ];

      for (final pluginId in testPluginIds) {
        try {
          await pluginManager.uninstallPlugin(pluginId);
        } on Exception {
          // 忽略未安装的插件错误
        }
      }
    });

    group('初始化测试', () {
      test('应该能够获取单例实例', () {
        final instance1 = PluginManager.instance;
        final instance2 = PluginManager.instance;
        expect(instance1, same(instance2));
      });

      test('应该能够初始化插件管理器', () async {
        await pluginManager.initialize();
        expect(pluginManager.installedPlugins, isNotEmpty);
      });
    });

    group('插件状态管理测试', () {
      test('应该能够获取已安装插件列表', () async {
        await pluginManager.initialize();
        final plugins = pluginManager.installedPlugins;
        expect(plugins, isA<List<PluginInstallInfo>>());
        expect(plugins.length, greaterThan(0));
      });

      test('应该能够获取已启用插件列表', () async {
        await pluginManager.initialize();
        final enabledPlugins = pluginManager.enabledPlugins;
        expect(enabledPlugins, isA<List<PluginInstallInfo>>());
        expect(enabledPlugins.every((p) => p.state == PluginState.enabled),
            isTrue);
      });

      test('应该能够获取需要更新的插件列表', () async {
        await pluginManager.initialize();
        final updatablePlugins = pluginManager.updatablePlugins;
        expect(updatablePlugins, isA<List<PluginInstallInfo>>());
        expect(
            updatablePlugins
                .every((p) => p.state == PluginState.updateAvailable),
            isTrue);
      });
    });

    group('插件操作测试', () {
      test('应该能够启用已安装的插件', () async {
        await pluginManager.initialize();

        // 先安装一个插件
        final pluginId =
            'test_plugin_enable_${DateTime.now().millisecondsSinceEpoch}';
        await pluginManager.installPlugin(pluginId);

        // 新安装的插件状态应该是 installed
        final installedPlugin = pluginManager.getPluginInfo(pluginId);
        expect(installedPlugin?.state, PluginState.installed);

        // 启用插件
        final result = await pluginManager.enablePlugin(pluginId);
        expect(result.success, isTrue);

        // 验证插件已启用
        final updatedPlugin = pluginManager.getPluginInfo(pluginId);
        expect(updatedPlugin?.state, PluginState.enabled);
      });

      test('应该能够禁用已启用的插件', () async {
        await pluginManager.initialize();

        // 查找已启用的插件
        final enabledPlugin = pluginManager.installedPlugins
            .firstWhere((p) => p.state == PluginState.enabled);

        final result = await pluginManager.disablePlugin(enabledPlugin.id);
        expect(result.success, isTrue);

        final updatedPlugin = pluginManager.getPluginInfo(enabledPlugin.id);
        expect(updatedPlugin?.state, PluginState.installed);
      });

      test('应该能够更新有更新的插件', () async {
        await pluginManager.initialize();

        // 查找需要更新的插件
        final updatablePlugin = pluginManager.installedPlugins
            .firstWhere((p) => p.state == PluginState.updateAvailable);

        final result = await pluginManager.updatePlugin(updatablePlugin.id);
        expect(result.success, isTrue);

        final updatedPlugin = pluginManager.getPluginInfo(updatablePlugin.id);
        expect(updatedPlugin?.state, PluginState.enabled);
      });

      test('应该能够安装新插件', () async {
        await pluginManager.initialize();

        final newPluginId =
            'test_plugin_${DateTime.now().millisecondsSinceEpoch}';
        final result = await pluginManager.installPlugin(newPluginId);
        expect(result.success, isTrue);

        final installedPlugin = pluginManager.getPluginInfo(newPluginId);
        expect(installedPlugin, isNotNull);
        expect(installedPlugin?.state, PluginState.installed);
      });

      test('应该能够卸载已安装的插件', () async {
        await pluginManager.initialize();

        // 先安装一个测试插件
        final testPluginId =
            'test_plugin_for_uninstall_${DateTime.now().millisecondsSinceEpoch}';
        await pluginManager.installPlugin(testPluginId);

        // 然后卸载它
        final result = await pluginManager.uninstallPlugin(testPluginId);
        expect(result.success, isTrue);

        final uninstalledPlugin = pluginManager.getPluginInfo(testPluginId);
        expect(uninstalledPlugin, isNull);
      });
    });

    group('错误处理测试', () {
      test('启用不存在的插件应该返回错误', () async {
        await pluginManager.initialize();

        final result = await pluginManager.enablePlugin('non_existent_plugin');
        expect(result.success, isFalse);
        expect(result.error, contains('插件未安装'));
      });

      test('禁用不存在的插件应该返回错误', () async {
        await pluginManager.initialize();

        final result = await pluginManager.disablePlugin('non_existent_plugin');
        expect(result.success, isFalse);
        expect(result.error, contains('插件未安装'));
      });

      test('更新不存在的插件应该返回错误', () async {
        await pluginManager.initialize();

        final result = await pluginManager.updatePlugin('non_existent_plugin');
        expect(result.success, isFalse);
        expect(result.error, contains('插件未安装'));
      });

      test('重复安装插件应该返回错误', () async {
        await pluginManager.initialize();

        // 尝试安装已存在的插件
        final existingPlugin = pluginManager.installedPlugins.first;
        final result = await pluginManager.installPlugin(existingPlugin.id);
        expect(result.success, isFalse);
        expect(result.error, contains('插件已安装'));
      });
    });

    group('插件信息查询测试', () {
      test('应该能够检查插件是否已安装', () async {
        await pluginManager.initialize();

        final existingPlugin = pluginManager.installedPlugins.first;
        expect(pluginManager.isPluginInstalled(existingPlugin.id), isTrue);
        expect(pluginManager.isPluginInstalled('non_existent_plugin'), isFalse);
      });

      test('应该能够检查插件是否已启用', () async {
        await pluginManager.initialize();

        final enabledPlugin = pluginManager.enabledPlugins.first;
        expect(pluginManager.isPluginEnabled(enabledPlugin.id), isTrue);

        final disabledPlugin = pluginManager.installedPlugins
            .firstWhere((p) => p.state != PluginState.enabled);
        expect(pluginManager.isPluginEnabled(disabledPlugin.id), isFalse);
      });

      test('应该能够获取插件统计信息', () async {
        await pluginManager.initialize();

        final stats = pluginManager.getPluginStats();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalInstalled'], isA<int>());
        expect(stats['totalEnabled'], isA<int>());
        expect(stats['totalSize'], isA<int>());
        expect(stats['needsUpdate'], isA<int>());
      });
    });

    group('插件权限测试', () {
      test('插件应该有正确的权限信息', () async {
        await pluginManager.initialize();

        final pluginWithPermissions = pluginManager.installedPlugins
            .firstWhere((p) => p.permissions.isNotEmpty);

        expect(
            pluginWithPermissions.permissions, isA<List<PluginPermission>>());
        expect(pluginWithPermissions.permissions.length, greaterThan(0));
      });
    });

    group('插件依赖测试', () {
      test('插件应该有正确的依赖信息', () async {
        await pluginManager.initialize();

        final pluginWithDeps = pluginManager.installedPlugins
            .firstWhere((p) => p.dependencies.isNotEmpty);

        expect(pluginWithDeps.dependencies, isA<List<PluginDependency>>());
        expect(pluginWithDeps.dependencies.length, greaterThan(0));

        final dependency = pluginWithDeps.dependencies.first;
        expect(dependency.pluginId, isA<String>());
        expect(dependency.version, isA<String>());
        expect(dependency.isRequired, isA<bool>());
      });
    });
  });
}
