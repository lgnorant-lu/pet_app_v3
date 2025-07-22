/*
---------------------------------------------------------------
File name:          plugin_registry_test.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件注册表测试
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件注册表测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_registry.dart';

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
    _isInitialized = true;
  }

  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('Plugin not initialized');
    }
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
  }

  @override
  Future<void> dispose() async {
    _isRunning = false;
    _isInitialized = false;
  }
}

void main() {
  group('PluginRegistry Tests', () {
    late PluginRegistry registry;
    late PluginMetadata testMetadata;
    var testCounter = 0;

    setUp(() {
      registry = PluginRegistry.instance;
      testCounter++;
      testMetadata = PluginMetadata(
        id: 'test_plugin_$testCounter',
        name: 'Test Plugin $testCounter',
        version: '1.0.0',
        description: 'A test plugin $testCounter',
        author: 'Test Author',
        category: 'test',
      );
    });

    tearDown(() {
      // 清理所有已注册的插件
      final List<PluginRegistration> registrations =
          registry.registrations.toList();
      for (final PluginRegistration registration in registrations) {
        try {
          registry.unregisterPlugin(registration.metadata.id);
        } on Exception {
          // 忽略未注册的插件错误
        }
      }
    });

    group('插件注册测试', () {
      test('应该能够注册插件', () {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        expect(registry.isPluginRegistered(testMetadata.id), isTrue);
        expect(registry.registrations.length, greaterThan(0));
      });

      test('应该能够获取插件元数据', () {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        final metadata = registry.getPluginMetadata(testMetadata.id);
        expect(metadata, isNotNull);
        expect(metadata?.id, testMetadata.id);
        expect(metadata?.name, testMetadata.name);
      });

      test('重复注册相同ID的插件应该抛出异常', () {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        expect(
          () => registry.registerPlugin(
            testMetadata,
            () => TestPlugin(testMetadata),
          ),
          throwsArgumentError,
        );
      });
    });

    group('插件生命周期测试', () {
      test('应该能够启动插件', () async {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        await registry.startPlugin(testMetadata.id);

        expect(registry.isPluginRunning(testMetadata.id), isTrue);
        expect(registry.activePlugins.length, 1);
      });

      test('应该能够停止插件', () async {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        await registry.startPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isTrue);

        await registry.stopPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isFalse);
      });

      test('应该能够重启插件', () async {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        await registry.startPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isTrue);

        await registry.restartPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isTrue);
      });

      test('启动未注册的插件应该抛出异常', () async {
        expect(
          () => registry.startPlugin('non_existent_plugin'),
          throwsArgumentError,
        );
      });

      test('重复启动已运行的插件应该正常处理', () async {
        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        await registry.startPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isTrue);

        // 重复启动应该不抛出异常
        await registry.startPlugin(testMetadata.id);
        expect(registry.isPluginRunning(testMetadata.id), isTrue);
      });
    });

    group('插件查询测试', () {
      test('应该能够按类别查询插件', () {
        final metadata1 = testMetadata;
        const metadata2 = PluginMetadata(
          id: 'test_plugin_2',
          name: 'Test Plugin 2',
          version: '1.0.0',
          description: 'Another test plugin',
          author: 'Test Author',
          category: 'test',
        );
        const metadata3 = PluginMetadata(
          id: 'game_plugin',
          name: 'Game Plugin',
          version: '1.0.0',
          description: 'A game plugin',
          author: 'Game Author',
          category: 'game',
        );

        registry
          ..registerPlugin(metadata1, () => TestPlugin(metadata1))
          ..registerPlugin(metadata2, () => TestPlugin(metadata2))
          ..registerPlugin(metadata3, () => TestPlugin(metadata3));

        final testPlugins = registry.getPluginsByCategory('test');
        expect(testPlugins.length, 2);
        expect(testPlugins.every((p) => p.metadata.category == 'test'), isTrue);

        final gamePlugins = registry.getPluginsByCategory('game');
        expect(gamePlugins.length, 1);
        expect(gamePlugins.first.metadata.category, 'game');
      });

      test('应该能够搜索插件', () {
        final metadata1 = testMetadata;
        const metadata2 = PluginMetadata(
          id: 'drawing_tool',
          name: 'Drawing Tool',
          version: '1.0.0',
          description: 'A tool for drawing',
          author: 'Artist',
          category: 'tool',
          keywords: ['drawing', 'art', 'creative'],
        );

        registry.registerPlugin(metadata1, () => TestPlugin(metadata1));
        registry.registerPlugin(metadata2, () => TestPlugin(metadata2));

        // 按名称搜索
        final nameResults = registry.searchPlugins('Drawing');
        expect(nameResults.length, 1);
        expect(nameResults.first.metadata.name, 'Drawing Tool');

        // 按描述搜索
        final descResults = registry.searchPlugins('drawing');
        expect(descResults.length, 1);
        expect(descResults.first.metadata.description, contains('drawing'));

        // 按关键词搜索
        final keywordResults = registry.searchPlugins('art');
        expect(keywordResults.length, 1);
        expect(keywordResults.first.metadata.keywords, contains('art'));
      });
    });

    group('插件统计测试', () {
      test('应该能够获取插件统计信息', () async {
        final metadata1 = testMetadata;
        final metadata2 = PluginMetadata(
          id: 'stats_plugin_$testCounter',
          name: 'Stats Plugin $testCounter',
          version: '1.0.0',
          description: 'Another test plugin',
          author: 'Test Author',
          category: 'game',
        );

        registry.registerPlugin(metadata1, () => TestPlugin(metadata1));
        registry.registerPlugin(metadata2, () => TestPlugin(metadata2));

        await registry.startPlugin(metadata1.id);

        final stats = registry.getStatistics();
        expect(stats['totalRegistered'], 2);
        expect(stats['totalActive'], 1);
        expect(stats['categoryCounts'], isA<Map<String, int>>());
        expect(stats['categoryCounts']['test'], 1);
        expect(stats['categoryCounts']['game'], 1);
      });
    });

    group('批量操作测试', () {
      test('应该能够启动所有插件', () async {
        final metadata1 = testMetadata;
        final metadata2 = PluginMetadata(
          id: 'batch_start_plugin_$testCounter',
          name: 'Batch Start Plugin $testCounter',
          version: '1.0.0',
          description: 'Another test plugin',
          author: 'Test Author',
          category: 'test',
        );

        registry.registerPlugin(metadata1, () => TestPlugin(metadata1));
        registry.registerPlugin(metadata2, () => TestPlugin(metadata2));

        await registry.startAllPlugins();

        expect(registry.activePlugins.length, 2);
        expect(registry.isPluginRunning(metadata1.id), isTrue);
        expect(registry.isPluginRunning(metadata2.id), isTrue);
      });

      test('应该能够停止所有插件', () async {
        final metadata1 = testMetadata;
        final metadata2 = PluginMetadata(
          id: 'batch_stop_plugin_$testCounter',
          name: 'Batch Stop Plugin $testCounter',
          version: '1.0.0',
          description: 'Another test plugin',
          author: 'Test Author',
          category: 'test',
        );

        registry.registerPlugin(metadata1, () => TestPlugin(metadata1));
        registry.registerPlugin(metadata2, () => TestPlugin(metadata2));

        await registry.startAllPlugins();
        expect(registry.activePlugins.length, 2);

        await registry.stopAllPlugins();
        expect(registry.activePlugins.length, 0);
      });
    });

    group('事件系统测试', () {
      test('应该能够监听插件注册事件', () async {
        final events = <PluginRegistryEvent>[];
        final subscription = registry.events.listen(events.add);

        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events.length, 1);
        expect(events.first.pluginId, testMetadata.id);

        await subscription.cancel();
      });

      test('应该能够监听插件启动和停止事件', () async {
        final events = <PluginRegistryEvent>[];
        final subscription = registry.events.listen(events.add);

        registry.registerPlugin(testMetadata, () => TestPlugin(testMetadata));
        await registry.startPlugin(testMetadata.id);
        await registry.stopPlugin(testMetadata.id);

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events.length, 3); // 注册、启动、停止

        await subscription.cancel();
      });
    });
  });
}
