/*
---------------------------------------------------------------
File name:          plugin_file_manager_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件文件管理器测试 - 集成Creative Workshop测试
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.1.2 - 统一文件系统操作测试;
---------------------------------------------------------------
*/

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:plugin_system/src/core/plugin_file_manager.dart';

void main() {
  group('PluginFileManager Tests', () {
    late PluginFileManager fileManager;
    late String testPluginsDir;
    var testCounter = 0;

    setUpAll(() async {
      // 创建测试目录
      final tempDir = Directory.systemTemp;
      testPluginsDir = path.join(tempDir.path,
          'test_plugins_${DateTime.now().millisecondsSinceEpoch}',);
      await Directory(testPluginsDir).create(recursive: true);
    });

    setUp(() async {
      fileManager = PluginFileManager.instance;
      fileManager.reset(); // 重置状态
      testCounter++;
      await fileManager.initialize(customPluginsDir: testPluginsDir);
    });

    tearDown(() async {
      // 清理测试插件
      try {
        final testPluginId = 'test_plugin_$testCounter';
        await fileManager.deletePluginDirectory(testPluginId);
      } catch (e) {
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
      } catch (e) {
        // 忽略清理错误
      }
    });

    group('初始化测试', () {
      test('应该能够正确初始化文件管理器', () async {
        expect(fileManager, isNotNull);
        
        // 验证目录是否创建
        final pluginsDir = Directory(testPluginsDir);
        expect(await pluginsDir.exists(), isTrue);
      });

      test('应该能够重复初始化而不出错', () async {
        // 重复初始化应该不会出错
        await fileManager.initialize(customPluginsDir: testPluginsDir);
        await fileManager.initialize(customPluginsDir: testPluginsDir);
        
        expect(fileManager, isNotNull);
      });

      test('未初始化时应该抛出异常', () {
        fileManager.reset();
        
        expect(
          () => fileManager.getPluginDirectory('test'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('插件目录管理测试', () {
      test('应该能够创建插件目录', () async {
        const pluginId = 'test_plugin_create';
        
        final result = await fileManager.createPluginDirectory(pluginId);
        
        expect(result.success, isTrue);
        expect(result.path, isNotNull);
        expect(await fileManager.isPluginInstalled(pluginId), isTrue);
        
        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('应该能够删除插件目录', () async {
        const pluginId = 'test_plugin_delete';
        
        // 先创建目录
        await fileManager.createPluginDirectory(pluginId);
        expect(await fileManager.isPluginInstalled(pluginId), isTrue);
        
        // 删除目录
        final result = await fileManager.deletePluginDirectory(pluginId);
        
        expect(result.success, isTrue);
        expect(await fileManager.isPluginInstalled(pluginId), isFalse);
      });

      test('创建已存在的插件目录应该失败', () async {
        const pluginId = 'test_plugin_duplicate';
        
        // 先创建目录
        await fileManager.createPluginDirectory(pluginId);
        
        // 再次创建应该失败
        final result = await fileManager.createPluginDirectory(pluginId);
        
        expect(result.success, isFalse);
        expect(result.error, contains('插件目录已存在'));
        
        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('应该能够检查插件是否已安装', () async {
        const pluginId = 'test_plugin_check';
        
        // 未安装时应该返回false
        expect(await fileManager.isPluginInstalled(pluginId), isFalse);
        
        // 安装后应该返回true
        await fileManager.createPluginDirectory(pluginId);
        expect(await fileManager.isPluginInstalled(pluginId), isTrue);
        
        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });
    });

    group('文件操作测试', () {
      test('应该能够写入插件文件', () async {
        const pluginId = 'test_plugin_write';
        const relativePath = 'test_file.txt';
        final testData = Uint8List.fromList('Hello, Plugin!'.codeUnits);

        // 先创建插件目录
        await fileManager.createPluginDirectory(pluginId);

        // 写入文件
        final result = await fileManager.writePluginFile(
          pluginId,
          relativePath,
          testData,
        );

        expect(result.success, isTrue);
        expect(result.path, isNotNull);

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('应该能够读取插件文件', () async {
        const pluginId = 'test_plugin_read';
        const relativePath = 'test_file.txt';
        const testContent = 'Hello, Plugin!';
        final testData = Uint8List.fromList(testContent.codeUnits);

        // 先创建插件目录并写入文件
        await fileManager.createPluginDirectory(pluginId);
        await fileManager.writePluginFile(pluginId, relativePath, testData);

        // 读取文件
        final readData =
            await fileManager.readPluginFile(pluginId, relativePath);
        expect(readData, isNotNull);
        expect(String.fromCharCodes(readData!), testContent);

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('读取不存在的文件应该返回null', () async {
        const pluginId = 'test_plugin_read_null';
        const relativePath = 'nonexistent_file.txt';

        // 创建插件目录但不创建文件
        await fileManager.createPluginDirectory(pluginId);

        // 读取不存在的文件
        final readData =
            await fileManager.readPluginFile(pluginId, relativePath);
        expect(readData, isNull);

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('应该能够复制文件到插件目录', () async {
        const pluginId = 'test_plugin_copy';
        const relativePath = 'copied_file.txt';
        const testContent = 'Test file content';

        // 创建源文件
        final tempFile =
            File(path.join(Directory.systemTemp.path, 'source_file.txt'));
        await tempFile.writeAsString(testContent);

        // 创建插件目录
        await fileManager.createPluginDirectory(pluginId);

        // 复制文件
        final result = await fileManager.copyFileToPlugin(
          pluginId,
          tempFile.path,
          relativePath,
        );

        expect(result.success, isTrue);

        // 验证文件是否复制成功
        final readData =
            await fileManager.readPluginFile(pluginId, relativePath);
        expect(readData, isNotNull);
        expect(String.fromCharCodes(readData!), testContent);

        // 清理
        await tempFile.delete();
        await fileManager.deletePluginDirectory(pluginId);
      });
    });

    group('插件目录信息测试', () {
      test('应该能够获取插件目录大小', () async {
        const pluginId = 'test_plugin_size';
        const testContent = 'Test content for size calculation';
        final testData = Uint8List.fromList(testContent.codeUnits);

        // 创建插件目录并写入文件
        await fileManager.createPluginDirectory(pluginId);
        await fileManager.writePluginFile(pluginId, 'file1.txt', testData);
        await fileManager.writePluginFile(pluginId, 'file2.txt', testData);

        // 获取目录大小
        final size = await fileManager.getPluginDirectorySize(pluginId);
        expect(size, greaterThan(0));
        expect(size, testContent.length * 2); // 两个文件的大小

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });

      test('不存在的插件目录大小应该为0', () async {
        const pluginId = 'nonexistent_plugin';

        final size = await fileManager.getPluginDirectorySize(pluginId);
        expect(size, 0);
      });

      test('应该能够获取已安装插件列表', () async {
        const pluginId1 = 'test_plugin_list_1';
        const pluginId2 = 'test_plugin_list_2';

        // 创建两个插件目录
        await fileManager.createPluginDirectory(pluginId1);
        await fileManager.createPluginDirectory(pluginId2);

        // 获取插件列表
        final pluginIds = await fileManager.getInstalledPluginIds();
        expect(pluginIds, contains(pluginId1));
        expect(pluginIds, contains(pluginId2));

        // 清理
        await fileManager.deletePluginDirectory(pluginId1);
        await fileManager.deletePluginDirectory(pluginId2);
      });

      test('应该能够验证插件目录完整性', () async {
        const pluginId = 'test_plugin_validate';

        // 创建插件目录
        await fileManager.createPluginDirectory(pluginId);

        // 没有 plugin.yaml 文件时应该验证失败
        final isValid1 = await fileManager.validatePluginDirectory(pluginId);
        expect(isValid1, isFalse);

        // 创建 plugin.yaml 文件
        final manifestData = Uint8List.fromList('name: Test Plugin'.codeUnits);
        await fileManager.writePluginFile(
            pluginId, 'plugin.yaml', manifestData,);

        // 有 plugin.yaml 文件时应该验证成功
        final isValid2 = await fileManager.validatePluginDirectory(pluginId);
        expect(isValid2, isTrue);

        // 清理
        await fileManager.deletePluginDirectory(pluginId);
      });
    });

    group('清理操作测试', () {
      test('应该能够清理临时文件', () async {
        // 这个测试主要验证方法不会抛出异常
        expect(() => fileManager.cleanupTempFiles(), returnsNormally);
      });
    });
  });
}
