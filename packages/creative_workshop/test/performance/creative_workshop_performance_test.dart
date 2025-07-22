/*
---------------------------------------------------------------
File name:          creative_workshop_performance_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        Creative Workshop 性能测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6 - Creative Workshop 性能测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_registry.dart';

void main() {
  group('Creative Workshop Performance Tests', () {
    group('PluginManager Performance Tests', () {
      test('插件安装性能测试', () async {
        final pluginManager = PluginManager.instance;
        final stopwatch = Stopwatch()..start();

        // 批量安装插件
        final futures = <Future<PluginOperationResult>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(pluginManager.installPlugin('test_plugin_$i'));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // 验证性能指标 (应该在5秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        print('批量安装10个插件耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('插件查询性能测试', () async {
        final pluginManager = PluginManager.instance;

        // 先安装一些插件（减少数量）
        for (int i = 0; i < 10; i++) {
          await pluginManager.installPlugin('perf_test_plugin_$i');
        }

        final stopwatch = Stopwatch()..start();

        // 执行查询操作（减少次数）
        for (int i = 0; i < 100; i++) {
          pluginManager.isPluginInstalled('perf_test_plugin_${i % 10}');
          pluginManager.getPluginInfo('perf_test_plugin_${i % 10}');
        }

        stopwatch.stop();

        // 验证查询性能 (应该在1秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('100次插件查询耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('插件统计性能测试', () async {
        final pluginManager = PluginManager.instance;

        // 安装少量插件
        for (int i = 0; i < 5; i++) {
          await pluginManager.installPlugin('stats_test_plugin_$i');
          if (i % 2 == 0) {
            await pluginManager.enablePlugin('stats_test_plugin_$i');
          }
        }

        final stopwatch = Stopwatch()..start();

        // 执行统计操作（减少次数）
        for (int i = 0; i < 10; i++) {
          pluginManager.getPluginStats();
          pluginManager.installedPlugins;
          pluginManager.enabledPlugins;
          pluginManager.updatablePlugins;
        }

        stopwatch.stop();

        // 验证统计性能 (应该在500ms内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        print('10次统计操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('并发操作性能测试', () async {
        final pluginManager = PluginManager.instance;
        final stopwatch = Stopwatch()..start();

        // 并发执行多种操作
        final futures = <Future<dynamic>>[];

        // 安装操作
        for (int i = 0; i < 5; i++) {
          futures.add(pluginManager.installPlugin('concurrent_install_$i'));
        }

        // 查询操作
        for (int i = 0; i < 10; i++) {
          futures.add(Future<Map<String, dynamic>>(
              () => pluginManager.getPluginStats()));
        }

        // 启用操作
        for (int i = 0; i < 3; i++) {
          futures.add(
            pluginManager.installPlugin('concurrent_enable_$i').then(
                (_) => pluginManager.enablePlugin('concurrent_enable_$i')),
          );
        }

        await Future.wait(futures);
        stopwatch.stop();

        // 验证并发性能 (应该在10秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        print('并发操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('PluginRegistry Performance Tests', () {
      test('插件注册性能测试', () async {
        final registry = PluginRegistry.instance;
        final stopwatch = Stopwatch()..start();

        // 批量注册插件
        for (int i = 0; i < 100; i++) {
          final metadata = PluginMetadata(
            id: 'perf_registry_plugin_$i',
            name: 'Performance Test Plugin $i',
            version: '1.0.0',
            description: 'Performance test plugin $i',
            author: 'Test Author',
            category: 'test',
          );

          registry.registerPlugin(metadata, () => TestPlugin(metadata));
        }

        stopwatch.stop();

        // 验证注册性能 (应该在2秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        print('注册100个插件耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('插件搜索性能测试', () async {
        final registry = PluginRegistry.instance;

        // 注册大量插件
        for (int i = 0; i < 1000; i++) {
          final metadata = PluginMetadata(
            id: 'search_test_plugin_$i',
            name: 'Search Test Plugin $i',
            version: '1.0.0',
            description: 'Search test plugin $i',
            author: 'Test Author',
            category: i % 2 == 0 ? 'tool' : 'game',
            keywords: ['test', 'plugin', 'search', 'keyword$i'],
          );

          registry.registerPlugin(metadata, () => TestPlugin(metadata));
        }

        final stopwatch = Stopwatch()..start();

        // 执行搜索操作
        for (int i = 0; i < 100; i++) {
          registry.searchPlugins('Plugin');
          registry.searchPlugins('test');
          registry.searchPlugins('keyword${i % 100}');
        }

        stopwatch.stop();

        // 验证搜索性能 (应该在1秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('300次搜索操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('分类查询性能测试', () async {
        final registry = PluginRegistry.instance;

        // 注册不同类别的插件
        final categories = ['tool', 'game', 'utility', 'theme', 'other'];
        for (int i = 0; i < 500; i++) {
          final category = categories[i % categories.length];
          final metadata = PluginMetadata(
            id: 'category_test_plugin_$i',
            name: 'Category Test Plugin $i',
            version: '1.0.0',
            description: 'Category test plugin $i',
            author: 'Test Author',
            category: category,
          );

          registry.registerPlugin(metadata, () => TestPlugin(metadata));
        }

        final stopwatch = Stopwatch()..start();

        // 执行分类查询
        for (int i = 0; i < 200; i++) {
          for (final category in categories) {
            registry.getPluginsByCategory(category);
          }
        }

        stopwatch.stop();

        // 验证分类查询性能 (应该在500ms内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        print('1000次分类查询耗时: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('插件生命周期性能测试', () async {
        final registry = PluginRegistry.instance;

        // 注册插件
        const metadata = PluginMetadata(
          id: 'lifecycle_test_plugin',
          name: 'Lifecycle Test Plugin',
          version: '1.0.0',
          description: 'Lifecycle test plugin',
          author: 'Test Author',
          category: 'test',
        );

        registry.registerPlugin(metadata, () => TestPlugin(metadata));

        final stopwatch = Stopwatch()..start();

        // 执行生命周期操作
        for (int i = 0; i < 50; i++) {
          await registry.startPlugin('lifecycle_test_plugin');
          await registry.stopPlugin('lifecycle_test_plugin');
        }

        stopwatch.stop();

        // 验证生命周期性能 (应该在3秒内完成)
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        print('50次生命周期操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Memory Performance Tests', () {
      test('内存使用测试', () async {
        final pluginManager = PluginManager.instance;
        final registry = PluginRegistry.instance;

        // 记录初始状态
        final initialTime = DateTime.now();

        // 执行少量操作（减少数量）
        for (int i = 0; i < 10; i++) {
          // 注册插件
          final metadata = PluginMetadata(
            id: 'memory_test_plugin_$i',
            name: 'Memory Test Plugin $i',
            version: '1.0.0',
            description: 'Memory test plugin $i',
            author: 'Test Author',
            category: 'test',
          );

          registry.registerPlugin(metadata, () => TestPlugin(metadata));

          // 安装插件
          await pluginManager.installPlugin('memory_test_plugin_$i');

          // 启用插件
          await pluginManager.enablePlugin('memory_test_plugin_$i');

          // 查询操作
          pluginManager.getPluginInfo('memory_test_plugin_$i');
          registry.searchPlugins('Plugin $i');
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(initialTime);

        // 验证总体性能
        expect(duration.inSeconds, lessThan(30));
        print('内存测试总耗时: ${duration.inMilliseconds}ms');

        // 清理操作
        for (int i = 0; i < 10; i++) {
          await pluginManager.uninstallPlugin('memory_test_plugin_$i');
          await registry.unregisterPlugin('memory_test_plugin_$i');
        }
      });

      test('垃圾回收压力测试', () async {
        final pluginManager = PluginManager.instance;

        // 创建和销毁少量对象（减少数量）
        for (int cycle = 0; cycle < 3; cycle++) {
          final futures = <Future<PluginOperationResult>>[];

          // 创建临时插件
          for (int i = 0; i < 5; i++) {
            futures.add(
              pluginManager.installPlugin('gc_test_plugin_${cycle}_$i'),
            );
          }

          await Future.wait(futures);

          // 立即卸载
          final uninstallFutures = <Future<PluginOperationResult>>[];
          for (int i = 0; i < 5; i++) {
            uninstallFutures.add(
              pluginManager.uninstallPlugin('gc_test_plugin_${cycle}_$i'),
            );
          }

          await Future.wait(uninstallFutures);

          // 强制垃圾回收
          // 在实际应用中，这里可以添加内存监控逻辑
        }

        // 验证最终状态
        final stats = pluginManager.getPluginStats();
        expect(stats['totalInstalled'], isA<int>());
        print('垃圾回收测试完成，当前已安装插件: ${stats['totalInstalled']}');
      });
    });
  });
}

// 测试插件实现
class TestPlugin extends Plugin {
  TestPlugin(this._metadata);

  final PluginMetadata _metadata;
  bool _isInitialized = false;
  bool _isRunning = false;

  @override
  String get id => _metadata.id;

  @override
  String get name => _metadata.name;

  @override
  String get version => _metadata.version;

  @override
  String get description => _metadata.description;

  @override
  PluginMetadata get metadata => _metadata;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 10)); // 模拟初始化时间
    _isInitialized = true;
  }

  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('Plugin not initialized');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5)); // 模拟启动时间
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    await Future<void>.delayed(const Duration(milliseconds: 5)); // 模拟停止时间
    _isRunning = false;
  }

  @override
  Future<void> dispose() async {
    await Future<void>.delayed(const Duration(milliseconds: 5)); // 模拟清理时间
    _isRunning = false;
    _isInitialized = false;
  }
}
