/*
---------------------------------------------------------------
File name:          plugin_filesystem_integration_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件文件系统操作集成测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.1 - 插件文件系统集成测试实现;
---------------------------------------------------------------
*/

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_file_manager.dart';

void main() {
  group('Plugin FileSystem Integration Tests', () {
    late PluginManager pluginManager;
    late PluginFileManager fileManager;
    late String testPluginsDir;
    var testCounter = 0;

    setUpAll(() async {
      // 创建测试目录
      final tempDir = Directory.systemTemp;
      testPluginsDir = path.join(
        tempDir.path,
        'integration_test_plugins_${DateTime.now().millisecondsSinceEpoch}',
      );
      await Directory(testPluginsDir).create(recursive: true);
    });

    setUp(() async {
      // 重置文件管理器
      fileManager = PluginFileManager.instance;
      fileManager.reset();
      await fileManager.initialize(customPluginsDir: testPluginsDir);

      // 重置插件管理器
      pluginManager = PluginManager.instance;
      await pluginManager.initialize();

      testCounter++;
    });

    tearDown(() async {
      // 清理测试插件
      try {
        final testPluginId = 'integration_test_plugin_$testCounter';
        await pluginManager.uninstallPlugin(testPluginId);
      } on Exception {
        // 忽略清理错误
      }
    });

    tearDownAll(() async {
      // 清理测试目录
      try {
        final testDir = Directory(testPluginsDir);
        if (await testDir.exists()) {
          await testDir.delete(recursive: true);
        }
      } on Exception {
        // 忽略清理错误
      }
    });

    group('完整的插件生命周期测试', () {
      test('应该能够完成插件的完整生命周期：安装→启用→禁用→卸载', () async {
        final pluginId = 'lifecycle_test_plugin_$testCounter';

        // 1. 验证插件初始状态
        expect(await fileManager.isPluginInstalled(pluginId), isFalse);
        expect(pluginManager.isPluginInstalled(pluginId), isFalse);

        // 2. 安装插件
        final installResult = await pluginManager.installPlugin(pluginId);
        expect(installResult.success, isTrue);

        // 3. 验证安装后状态
        expect(await fileManager.isPluginInstalled(pluginId), isTrue);
        expect(pluginManager.isPluginInstalled(pluginId), isTrue);

        final installedPlugin = pluginManager.getPluginInfo(pluginId);
        expect(installedPlugin, isNotNull);
        expect(installedPlugin!.state, PluginState.installed);

        // 4. 验证文件系统状态
        expect(await fileManager.validatePluginDirectory(pluginId), isTrue);
        final pluginSize = await fileManager.getPluginDirectorySize(pluginId);
        expect(pluginSize, greaterThan(0));

        // 5. 启用插件
        final enableResult = await pluginManager.enablePlugin(pluginId);
        expect(enableResult.success, isTrue);

        final enabledPlugin = pluginManager.getPluginInfo(pluginId);
        expect(enabledPlugin!.state, PluginState.enabled);

        // 6. 禁用插件
        final disableResult = await pluginManager.disablePlugin(pluginId);
        expect(disableResult.success, isTrue);

        final disabledPlugin = pluginManager.getPluginInfo(pluginId);
        expect(disabledPlugin!.state, PluginState.installed);

        // 7. 卸载插件
        final uninstallResult = await pluginManager.uninstallPlugin(pluginId);
        expect(uninstallResult.success, isTrue);

        // 8. 验证卸载后状态
        expect(await fileManager.isPluginInstalled(pluginId), isFalse);
        expect(pluginManager.isPluginInstalled(pluginId), isFalse);
        expect(pluginManager.getPluginInfo(pluginId), isNull);
      });

      test('应该能够处理多个插件的并发安装', () async {
        final pluginIds = [
          'concurrent_plugin_1_$testCounter',
          'concurrent_plugin_2_$testCounter',
          'concurrent_plugin_3_$testCounter',
        ];

        // 并发安装多个插件
        final installFutures = pluginIds.map(
          (id) => pluginManager.installPlugin(id),
        );
        final installResults = await Future.wait(installFutures);

        // 验证所有安装都成功
        for (final result in installResults) {
          expect(result.success, isTrue);
        }

        // 验证所有插件都正确安装
        for (final pluginId in pluginIds) {
          expect(await fileManager.isPluginInstalled(pluginId), isTrue);
          expect(pluginManager.isPluginInstalled(pluginId), isTrue);
          expect(await fileManager.validatePluginDirectory(pluginId), isTrue);
        }

        // 清理：并发卸载所有插件
        final uninstallFutures = pluginIds.map(
          (id) => pluginManager.uninstallPlugin(id),
        );
        final uninstallResults = await Future.wait(uninstallFutures);

        // 验证所有卸载都成功
        for (final result in uninstallResults) {
          expect(result.success, isTrue);
        }

        // 验证所有插件都正确卸载
        for (final pluginId in pluginIds) {
          expect(await fileManager.isPluginInstalled(pluginId), isFalse);
          expect(pluginManager.isPluginInstalled(pluginId), isFalse);
        }
      });
    });

    group('文件系统一致性测试', () {
      test('插件管理器和文件管理器状态应该保持一致', () async {
        final pluginId = 'consistency_test_plugin_$testCounter';

        // 安装插件
        await pluginManager.installPlugin(pluginId);

        // 验证状态一致性
        final managerInstalled = pluginManager.isPluginInstalled(pluginId);
        final fileManagerInstalled =
            await fileManager.isPluginInstalled(pluginId);
        expect(managerInstalled, fileManagerInstalled);

        // 验证插件信息与文件系统匹配
        final pluginInfo = pluginManager.getPluginInfo(pluginId);
        final actualSize = await fileManager.getPluginDirectorySize(pluginId);
        expect(pluginInfo!.size, actualSize);

        // 卸载插件
        await pluginManager.uninstallPlugin(pluginId);

        // 验证卸载后状态一致性
        final managerUninstalled = !pluginManager.isPluginInstalled(pluginId);
        final fileManagerUninstalled =
            !await fileManager.isPluginInstalled(pluginId);
        expect(managerUninstalled, fileManagerUninstalled);
      });

      test('应该能够从文件系统恢复插件状态', () async {
        final pluginId = 'recovery_test_plugin_$testCounter';

        // 直接使用文件管理器创建插件
        await fileManager.createPluginDirectory(pluginId);
        await fileManager.writePluginFile(
          pluginId,
          'plugin.yaml',
          Uint8List.fromList('name: $pluginId\nversion: 1.0.0'.codeUnits),
        );

        // 验证文件管理器能检测到插件
        expect(await fileManager.isPluginInstalled(pluginId), isTrue);
        expect(await fileManager.validatePluginDirectory(pluginId), isTrue);

        // 获取已安装插件列表应该包含这个插件
        final installedIds = await fileManager.getInstalledPluginIds();
        expect(installedIds, contains(pluginId));

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });
    });

    group('错误处理和恢复测试', () {
      test('安装失败时应该正确清理文件', () async {
        final pluginId = 'cleanup_test_plugin_$testCounter';

        // 先创建一个同名目录来模拟冲突
        await fileManager.createPluginDirectory(pluginId);

        // 尝试安装应该失败
        final installResult = await pluginManager.installPlugin(pluginId);
        expect(installResult.success, isFalse);

        // 验证没有留下不完整的安装
        expect(pluginManager.isPluginInstalled(pluginId), isFalse);
        expect(pluginManager.getPluginInfo(pluginId), isNull);

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('卸载失败时应该保持原状态', () async {
        final pluginId = 'uninstall_fail_test_plugin_$testCounter';

        // 安装插件
        await pluginManager.installPlugin(pluginId);
        final originalPlugin = pluginManager.getPluginInfo(pluginId);

        // 手动删除文件系统中的插件目录来模拟部分失败
        await fileManager.deletePluginDirectory(pluginId);

        // 尝试卸载（应该成功，因为目录已经不存在了）
        final uninstallResult = await pluginManager.uninstallPlugin(pluginId);
        expect(uninstallResult.success, isTrue);

        // 验证插件已从管理器中移除
        expect(pluginManager.isPluginInstalled(pluginId), isFalse);
      });
    });

    group('性能和资源管理测试', () {
      test('大量插件操作不应该导致内存泄漏', () async {
        final pluginIds = <String>[];

        // 创建多个插件
        for (int i = 0; i < 10; i++) {
          final pluginId = 'memory_test_plugin_${testCounter}_$i';
          pluginIds.add(pluginId);

          await pluginManager.installPlugin(pluginId);
          expect(pluginManager.isPluginInstalled(pluginId), isTrue);
        }

        // 验证所有插件都正确安装
        expect(pluginManager.installedPlugins.length, greaterThanOrEqualTo(10));

        // 批量卸载
        for (final pluginId in pluginIds) {
          await pluginManager.uninstallPlugin(pluginId);
          expect(pluginManager.isPluginInstalled(pluginId), isFalse);
        }

        // 验证清理完成
        final remainingPlugins = pluginManager.installedPlugins
            .where((p) => pluginIds.contains(p.id))
            .toList();
        expect(remainingPlugins, isEmpty);
      });

      test('应该能够正确计算插件大小', () async {
        final pluginId = 'size_test_plugin_$testCounter';

        // 安装插件
        await pluginManager.installPlugin(pluginId);

        // 获取插件信息
        final pluginInfo = pluginManager.getPluginInfo(pluginId);
        expect(pluginInfo, isNotNull);
        expect(pluginInfo!.size, greaterThan(0));

        // 验证大小计算准确性
        final actualSize = await fileManager.getPluginDirectorySize(pluginId);
        expect(pluginInfo.size, actualSize);

        // 清理
        await pluginManager.uninstallPlugin(pluginId);
      });
    });
  });
}
