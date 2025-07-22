/*
---------------------------------------------------------------
File name:          simple_plugin_test.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        简单插件测试
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 简单插件测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('Simple Plugin Tests', () {
    test('PluginManager singleton should work', () {
      final PluginManager instance1 = PluginManager.instance;
      final PluginManager instance2 = PluginManager.instance;
      expect(instance1, same(instance2));
    });

    test('PluginState enum should have all values', () {
      expect(PluginState.values.length, 12);
      expect(PluginState.values.contains(PluginState.enabled), isTrue);
      expect(PluginState.values.contains(PluginState.disabled), isTrue);
      expect(PluginState.values.contains(PluginState.installed), isTrue);
    });

    test('PluginPermission enum should have all values', () {
      expect(PluginPermission.values.length, 8);
      expect(PluginPermission.values.contains(PluginPermission.fileSystem), isTrue);
      expect(PluginPermission.values.contains(PluginPermission.network), isTrue);
      expect(PluginPermission.values.contains(PluginPermission.camera), isTrue);
    });

    test('PluginOperationResult should work correctly', () {
      final PluginOperationResult success = PluginOperationResult.success('Success message');
      expect(success.success, isTrue);
      expect(success.message, 'Success message');
      expect(success.error, isNull);

      final PluginOperationResult failure = PluginOperationResult.failure('Error message');
      expect(failure.success, isFalse);
      expect(failure.error, 'Error message');
      expect(failure.message, isNull);
    });

    test('PluginDependency should work correctly', () {
      const PluginDependency dependency = PluginDependency(
        pluginId: 'test_plugin',
        version: '1.0.0',
        isRequired: true,
      );

      expect(dependency.pluginId, 'test_plugin');
      expect(dependency.version, '1.0.0');
      expect(dependency.isRequired, isTrue);
    });

    test('PluginInstallInfo copyWith should work correctly', () {
      final DateTime now = DateTime.now();
      final PluginInstallInfo original = PluginInstallInfo(
        id: 'test',
        name: 'Test Plugin',
        version: '1.0.0',
        state: PluginState.installed,
        installedAt: now,
      );

      final PluginInstallInfo updated = original.copyWith(
        state: PluginState.enabled,
        version: '1.1.0',
      );

      expect(updated.id, 'test');
      expect(updated.name, 'Test Plugin');
      expect(updated.version, '1.1.0');
      expect(updated.state, PluginState.enabled);
      expect(updated.installedAt, now);
    });
  });
}
