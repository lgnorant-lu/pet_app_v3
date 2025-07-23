/*
---------------------------------------------------------------
File name:          dependency_resolver_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        依赖解析器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.4 - 依赖解析算法测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/dependency_resolver.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('DependencyResolver Tests', () {
    late DependencyResolver resolver;

    setUp(() {
      resolver = DependencyResolver.instance;
    });

    group('单例模式测试', () {
      test('应该返回相同的实例', () {
        final instance1 = DependencyResolver.instance;
        final instance2 = DependencyResolver.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('版本兼容性测试', () {
      test('应该正确检查版本兼容性', () {
        // 精确版本匹配
        expect(resolver.isVersionCompatible('1.0.0', '1.0.0'), isTrue);
        expect(resolver.isVersionCompatible('1.0.0', '1.0.1'), isFalse);

        // 范围版本匹配
        expect(resolver.isVersionCompatible('^1.0.0', '1.0.0'), isTrue);
        expect(resolver.isVersionCompatible('^1.0.0', '1.5.0'), isTrue);
        expect(resolver.isVersionCompatible('^1.0.0', '2.0.0'), isFalse);

        // 大于等于版本匹配
        expect(resolver.isVersionCompatible('>=1.0.0', '1.0.0'), isTrue);
        expect(resolver.isVersionCompatible('>=1.0.0', '1.5.0'), isTrue);
        expect(resolver.isVersionCompatible('>=1.0.0', '0.9.0'), isFalse);

        // 范围版本匹配
        expect(resolver.isVersionCompatible('>=1.0.0 <2.0.0', '1.5.0'), isTrue);
        expect(resolver.isVersionCompatible('>=1.0.0 <2.0.0', '2.0.0'), isFalse);
      });

      test('应该处理无效版本格式', () {
        expect(resolver.isVersionCompatible('invalid', '1.0.0'), isFalse);
        expect(resolver.isVersionCompatible('1.0.0', 'invalid'), isFalse);
        expect(resolver.isVersionCompatible('invalid', 'invalid'), isFalse);
      });
    });

    group('简单依赖解析测试', () {
      test('应该解析无依赖的插件', () {
        final targetPlugin = PluginInstallInfo(
          id: 'simple_plugin',
          name: '简单插件',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [],
          permissions: [],
          size: 1024,
        );

        final result = resolver.resolveDependencies(
          targetPlugin: targetPlugin,
          installedPlugins: {},
        );

        expect(result.success, isTrue);
        expect(result.installOrder, contains('simple_plugin'));
        expect(result.missingDependencies, isEmpty);
        expect(result.conflictingDependencies, isEmpty);
        expect(result.circularDependencies, isEmpty);
      });

      test('应该检测缺失的依赖', () {
        final targetPlugin = PluginInstallInfo(
          id: 'dependent_plugin',
          name: '依赖插件',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'missing_plugin',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final result = resolver.resolveDependencies(
          targetPlugin: targetPlugin,
          installedPlugins: {},
        );

        expect(result.success, isFalse);
        expect(result.error, contains('缺失的依赖'));
        expect(result.missingDependencies, hasLength(1));
        expect(result.missingDependencies.first.pluginId, 'missing_plugin');
      });

      test('应该解析满足的依赖', () {
        final dependencyPlugin = PluginInstallInfo(
          id: 'base_plugin',
          name: '基础插件',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [],
          permissions: [],
          size: 1024,
        );

        final targetPlugin = PluginInstallInfo(
          id: 'dependent_plugin',
          name: '依赖插件',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'base_plugin',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final installedPlugins = {
          'base_plugin': dependencyPlugin,
        };

        final result = resolver.resolveDependencies(
          targetPlugin: targetPlugin,
          installedPlugins: installedPlugins,
        );

        expect(result.success, isTrue);
        expect(result.installOrder, contains('base_plugin'));
        expect(result.installOrder, contains('dependent_plugin'));
        // 依赖应该在被依赖者之前
        expect(
          result.installOrder.indexOf('base_plugin'),
          lessThan(result.installOrder.indexOf('dependent_plugin')),
        );
      });
    });

    group('版本冲突检测测试', () {
      test('应该检测版本冲突', () {
        final basePlugin = PluginInstallInfo(
          id: 'base_plugin',
          name: '基础插件',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [],
          permissions: [],
          size: 1024,
        );

        final plugin1 = PluginInstallInfo(
          id: 'plugin1',
          name: '插件1',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'base_plugin',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final plugin2 = PluginInstallInfo(
          id: 'plugin2',
          name: '插件2',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'base_plugin',
              version: '^2.0.0', // 与已安装版本冲突
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final installedPlugins = {
          'base_plugin': basePlugin,
          'plugin1': plugin1,
        };

        final result = resolver.resolveDependencies(
          targetPlugin: plugin2,
          installedPlugins: installedPlugins,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('版本冲突'));
        expect(result.conflictingDependencies, isNotEmpty);
      });
    });

    group('循环依赖检测测试', () {
      test('应该检测简单循环依赖', () {
        final plugin1 = PluginInstallInfo(
          id: 'plugin1',
          name: '插件1',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'plugin2',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final plugin2 = PluginInstallInfo(
          id: 'plugin2',
          name: '插件2',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'plugin1',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final installedPlugins = {
          'plugin2': plugin2,
        };

        final availablePlugins = {
          'plugin1': plugin1,
        };

        final result = resolver.resolveDependencies(
          targetPlugin: plugin1,
          installedPlugins: installedPlugins,
          availablePlugins: availablePlugins,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('循环依赖'));
        expect(result.circularDependencies, isNotEmpty);
      });
    });

    group('拓扑排序测试', () {
      test('应该生成正确的安装顺序', () {
        // 创建依赖链: A -> B -> C
        final pluginC = PluginInstallInfo(
          id: 'plugin_c',
          name: '插件C',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [],
          permissions: [],
          size: 1024,
        );

        final pluginB = PluginInstallInfo(
          id: 'plugin_b',
          name: '插件B',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'plugin_c',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final pluginA = PluginInstallInfo(
          id: 'plugin_a',
          name: '插件A',
          version: '1.0.0',
          state: PluginState.installed,
          installedAt: DateTime.now(),
          dependencies: [
            const PluginDependency(
              pluginId: 'plugin_b',
              version: '^1.0.0',
              isRequired: true,
            ),
          ],
          permissions: [],
          size: 1024,
        );

        final installedPlugins = {
          'plugin_b': pluginB,
          'plugin_c': pluginC,
        };

        final result = resolver.resolveDependencies(
          targetPlugin: pluginA,
          installedPlugins: installedPlugins,
        );

        expect(result.success, isTrue);
        expect(result.installOrder, hasLength(3));

        // 验证安装顺序：C -> B -> A
        final cIndex = result.installOrder.indexOf('plugin_c');
        final bIndex = result.installOrder.indexOf('plugin_b');
        final aIndex = result.installOrder.indexOf('plugin_a');

        expect(cIndex, lessThan(bIndex));
        expect(bIndex, lessThan(aIndex));
      });
    });
  });
}
