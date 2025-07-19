/*
---------------------------------------------------------------
File name:          permission_manager_test.dart
Author:             lgnorant-lu
Date created:       2025/07/19
Last modified:      2025/07/19
Dart Version:       3.2+
Description:        权限管理器单元测试 (Permission Manager Unit Tests)

Change History:
    2025/07/19: Initial creation - 权限管理器单元测试 (Permission Manager Unit Tests);
---------------------------------------------------------------
*/

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_loader.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';
import 'package:plugin_system/src/security/permission_manager.dart';
import 'package:test/test.dart';

import '../../helpers/test_plugin.dart';

void main() {
  group('PermissionManager Unit Tests', () {
    late PermissionManager permissionManager;
    late PluginRegistry registry;
    late PluginLoader loader;

    setUp(() {
      permissionManager = PermissionManager.instance;
      registry = PluginRegistry.instance;
      loader = PluginLoader.instance;
    });

    tearDown(() async {
      await loader.unloadAllPlugins(force: true);
      await registry.clear();
    });

    group('Basic Functionality', () {
      test('should initialize', () async {
        await expectLater(
          () => permissionManager.initialize(),
          returnsNormally,
        );
      });

      test('should cleanup plugin permissions', () {
        expect(
          () => permissionManager.cleanupPluginPermissions('test_plugin'),
          returnsNormally,
        );
      });

      test('should set permission policy', () {
        expect(
          () => permissionManager.setPermissionPolicy(
            Permission.network,
            PermissionPolicy.allow,
          ),
          returnsNormally,
        );
      });
    });

    group('Permission Operations', () {
      test('should request permission', () async {
        final plugin = TestPlugin(pluginId: 'request_test_plugin');

        final result = await permissionManager.requestPermission(
          plugin.id,
          Permission.camera,
          reason: 'Test reason',
        );

        expect(result, isA<PermissionAuthorizationResult>());
        expect(result.permission, equals(Permission.camera));
      });

      test('should validate permissions', () async {
        final plugin = TestPlugin(pluginId: 'validate_test_plugin');

        // 使用安全的权限组合
        final results = await permissionManager.validatePermissions(
          plugin.id,
          <Permission>[Permission.camera, Permission.microphone],
        );

        expect(results, isA<List<PermissionAuthorizationResult>>());
        expect(results.length, equals(2));
      });

      test('should revoke permission', () async {
        final plugin = TestPlugin(pluginId: 'revoke_test_plugin');

        await expectLater(
          () =>
              permissionManager.revokePermission(plugin.id, Permission.camera),
          returnsNormally,
        );
      });

      test('should check permission', () {
        final plugin = TestPlugin(pluginId: 'check_test_plugin');

        final hasPermission =
            permissionManager.hasPermission(plugin.id, Permission.network);
        expect(hasPermission, isA<bool>());
      });

      test('should get plugin permissions', () {
        final plugin = TestPlugin(pluginId: 'get_perms_test_plugin');

        final permissions = permissionManager.getPluginPermissions(plugin.id);
        expect(permissions, isA<List<Permission>>());
      });
    });

    group('Error Handling', () {
      test('should handle non-existent plugin permission check', () {
        final bool hasPermission = permissionManager.hasPermission(
          'non_existent_plugin',
          Permission.network,
        );
        expect(hasPermission, isFalse);
      });

      test('should handle permission request for non-existent plugin',
          () async {
        final PermissionAuthorizationResult result =
            await permissionManager.requestPermission(
          'non_existent_plugin',
          Permission.camera,
          reason: 'Test reason',
        );
        expect(result, isA<PermissionAuthorizationResult>());
        expect(result.granted, isFalse);
      });

      test('should handle cleanup of non-existent plugin', () {
        expect(
          () => permissionManager.cleanupPluginPermissions('non_existent'),
          returnsNormally,
        );
      });
    });

    group('Performance Tests', () {
      test('should handle multiple permission requests efficiently', () async {
        final TestPlugin plugin = TestPlugin(pluginId: 'perf_test_plugin');

        final Stopwatch stopwatch = Stopwatch()..start();

        // 执行多个权限请求
        for (int i = 0; i < 10; i++) {
          await permissionManager.requestPermission(
            plugin.id,
            Permission.network,
            reason: 'Performance test $i',
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 应该在1秒内完成
      });
    });

    group('Integration Tests', () {
      test('should work with plugin lifecycle', () async {
        final TestPlugin plugin = TestPlugin(pluginId: 'integration_test');
        await loader.loadPlugin(plugin);

        // 请求权限
        final PermissionAuthorizationResult result =
            await permissionManager.requestPermission(
          plugin.id,
          Permission.fileSystem,
          reason: 'Integration test',
        );

        expect(result, isA<PermissionAuthorizationResult>());

        // 检查权限
        final bool hasPermission =
            permissionManager.hasPermission(plugin.id, Permission.fileSystem);
        expect(hasPermission, isA<bool>());

        // 清理
        permissionManager.cleanupPluginPermissions(plugin.id);
      });
    });
  });
}
