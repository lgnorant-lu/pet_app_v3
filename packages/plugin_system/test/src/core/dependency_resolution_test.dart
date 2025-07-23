/*
---------------------------------------------------------------
File name:          dependency_resolution_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        依赖解析测试 - 简化版本
---------------------------------------------------------------
Change History:
    2025-07-23: 简化依赖解析测试，修复Plugin实例化问题;
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:test/test.dart';
import 'package:plugin_system/src/core/dependency_manager.dart';
import 'package:plugin_system/src/core/dependency_node.dart';
import 'package:plugin_system/src/core/plugin.dart';

/// 支持自定义依赖的测试插件
class DependencyTestPlugin extends Plugin {
  /// 构造函数
  DependencyTestPlugin({
    required this.pluginId,
    this.pluginName,
    this.pluginDependencies = const <PluginDependency>[],
  });

  /// 插件ID
  final String pluginId;

  /// 插件名称
  final String? pluginName;

  /// 插件依赖列表
  final List<PluginDependency> pluginDependencies;

  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;

  @override
  String get name => pluginName ?? pluginId;

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Test plugin for dependency resolution';

  @override
  String get author => 'Test Author';

  @override
  PluginType get category => PluginType.tool;

  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];

  @override
  List<PluginDependency> get dependencies => pluginDependencies;

  @override
  List<SupportedPlatform> get supportedPlatforms => <SupportedPlatform>[
        SupportedPlatform.android,
        SupportedPlatform.ios,
        SupportedPlatform.windows,
        SupportedPlatform.macos,
        SupportedPlatform.linux,
        SupportedPlatform.web,
      ];

  @override
  PluginState get currentState => _currentState;

  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'test_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async =>
      <String, dynamic>{'action': action, 'data': data};
}

void main() {
  group('Dependency Resolution Tests', () {
    late DependencyManager dependencyManager;

    setUp(() {
      dependencyManager = DependencyManager.instance;
    });

    group('基本依赖解析', () {
      test('应该能够解析无依赖的插件', () async {
        final DependencyTestPlugin plugin =
            DependencyTestPlugin(pluginId: 'simple_plugin');

        final DependencyResolutionResult result =
            await dependencyManager.resolveDependencies(<Plugin>[plugin]);

        expect(result.success, isTrue);
        expect(result.loadOrder, contains('simple_plugin'));
        expect(result.conflicts, isEmpty);
        expect(result.missingDependencies, isEmpty);
        expect(result.circularDependencies, isEmpty);
      });

      test('应该能够解析简单的线性依赖链', () async {
        final DependencyTestPlugin pluginA = DependencyTestPlugin(
          pluginId: 'plugin_a',
          pluginName: '插件A',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'plugin_b',
              versionConstraint: '^1.0.0',
            ),
          ],
        );

        final DependencyTestPlugin pluginB = DependencyTestPlugin(
          pluginId: 'plugin_b',
          pluginName: '插件B',
        );

        final DependencyResolutionResult result = await dependencyManager
            .resolveDependencies(<Plugin>[pluginA, pluginB]);

        expect(result.success, isTrue);
        expect(result.loadOrder, contains('plugin_b'));
        expect(result.loadOrder, contains('plugin_a'));
        // plugin_b应该在plugin_a之前加载
        expect(
          result.loadOrder.indexOf('plugin_b'),
          lessThan(result.loadOrder.indexOf('plugin_a')),
        );
      });

      test('应该检测缺失的依赖', () async {
        final DependencyTestPlugin pluginA = DependencyTestPlugin(
          pluginId: 'plugin_a',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'missing_plugin',
              versionConstraint: '^1.0.0',
            ),
          ],
        );

        final DependencyResolutionResult result =
            await dependencyManager.resolveDependencies(<Plugin>[pluginA]);

        expect(result.success, isFalse);
        expect(result.missingDependencies, isNotEmpty);
        expect(result.missingDependencies.first.pluginId, 'missing_plugin');
      });

      test('应该检测循环依赖', () async {
        final DependencyTestPlugin pluginA = DependencyTestPlugin(
          pluginId: 'plugin_a',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'plugin_b',
              versionConstraint: '^1.0.0',
            ),
          ],
        );

        final DependencyTestPlugin pluginB = DependencyTestPlugin(
          pluginId: 'plugin_b',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'plugin_a',
              versionConstraint: '^1.0.0',
            ),
          ],
        );

        final DependencyResolutionResult result = await dependencyManager
            .resolveDependencies(<Plugin>[pluginA, pluginB]);

        expect(result.success, isFalse);
        expect(result.circularDependencies, isNotEmpty);
      });
    });

    group('版本兼容性测试', () {
      test('应该验证版本兼容性', () async {
        final DependencyTestPlugin pluginA = DependencyTestPlugin(
          pluginId: 'plugin_a',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'plugin_b',
              versionConstraint: '^2.0.0', // 要求2.x版本
            ),
          ],
        );

        final DependencyTestPlugin pluginB = DependencyTestPlugin(
          pluginId: 'plugin_b',
          pluginName: '插件B',
        ); // 默认版本是1.0.0

        final DependencyResolutionResult result = await dependencyManager
            .resolveDependencies(<Plugin>[pluginA, pluginB]);

        expect(result.success, isFalse);
        expect(result.conflicts, isNotEmpty);
      });
    });

    group('批量验证测试', () {
      test('应该能够批量验证多个插件', () async {
        final List<DependencyTestPlugin> plugins =
            List<DependencyTestPlugin>.generate(
          5,
          (int index) => DependencyTestPlugin(pluginId: 'plugin_$index'),
        );

        // 逐个验证插件（因为validateBatch方法不存在）
        final List<DependencyResolutionResult> results =
            <DependencyResolutionResult>[];
        for (final DependencyTestPlugin plugin in plugins) {
          final DependencyResolutionResult result =
              await dependencyManager.resolveDependencies(<Plugin>[plugin]);
          results.add(result);
        }

        expect(results, hasLength(5));
        expect(
          results.every((DependencyResolutionResult result) => result.success),
          isTrue,
        );
      });
    });

    group('依赖图构建测试', () {
      test('应该构建正确的依赖图', () async {
        final pluginA = DependencyTestPlugin(
          pluginId: 'plugin_a',
          pluginDependencies: const <PluginDependency>[
            PluginDependency(
              pluginId: 'plugin_b',
              versionConstraint: '^1.0.0',
            ),
          ],
        );

        final pluginB = DependencyTestPlugin(pluginId: 'plugin_b');

        final result = await dependencyManager
            .resolveDependencies(<Plugin>[pluginA, pluginB]);

        expect(result.success, isTrue);
        expect(result.loadOrder, isNotEmpty);

        // 验证依赖解析结果（因为getDependencyGraph方法不存在）
        expect(result.loadOrder, contains('plugin_a'));
        expect(result.loadOrder, contains('plugin_b'));
        expect(result.conflicts, isEmpty);
        expect(result.missingDependencies, isEmpty);
        expect(result.circularDependencies, isEmpty);
      });
    });

    group('性能测试', () {
      test('应该能够处理大量插件的依赖解析', () async {
        final List<DependencyTestPlugin> plugins =
            List<DependencyTestPlugin>.generate(
          50,
          (int index) => DependencyTestPlugin(pluginId: 'plugin_$index'),
        );

        final Stopwatch stopwatch = Stopwatch()..start();
        final DependencyResolutionResult result =
            await dependencyManager.resolveDependencies(plugins);
        stopwatch.stop();

        expect(result.success, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 应该在1秒内完成
      });
    });
  });
}
