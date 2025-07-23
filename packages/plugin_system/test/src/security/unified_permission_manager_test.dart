/*
---------------------------------------------------------------
File name:          unified_permission_manager_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        统一权限管理器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 1.1.1 - 统一权限管理系统测试;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/security/unified_permission_manager.dart';

void main() {
  group('UnifiedPermissionManager', () {
    late UnifiedPermissionManager manager;

    setUp(() {
      manager = UnifiedPermissionManager.instance;
    });

    tearDown(() async {
      // 清理所有权限
      // 这里需要一个方法来获取所有插件ID，暂时跳过清理
    });

    group('初始化', () {
      test('应该能够初始化权限管理器', () async {
        await manager.initialize();
        expect(manager, isNotNull);
      });

      test('应该能够设置用户授权回调', () {
        manager
            .setUserAuthorizationCallback((pluginId, permission, reason) async {
          return true;
        });
        // 无异常抛出即为成功
      });
    });

    group('权限验证', () {
      test('应该能够验证单个权限', () async {
        await manager.initialize();

        final result = await manager.validatePermissions(
          'test_plugin',
          [PluginPermission.deviceInfo],
        );

        expect(result.pluginId, equals('test_plugin'));
        expect(result.permissions, hasLength(1));
        expect(result.permissions.first.permission,
            equals(PluginPermission.deviceInfo));
      });

      test('应该能够验证多个权限', () async {
        await manager.initialize();

        final result = await manager.validatePermissions(
          'test_plugin',
          [
            PluginPermission.deviceInfo,
            PluginPermission.notifications,
          ],
        );

        expect(result.pluginId, equals('test_plugin'));
        expect(result.permissions, hasLength(2));
      });

      test('应该能够检测危险权限组合', () async {
        await manager.initialize();

        final result = await manager.validatePermissions(
          'test_plugin',
          [
            PluginPermission.fileSystem,
            PluginPermission.network,
          ],
        );

        expect(result.dangerousPermissions, isNotEmpty);
        expect(
            result.dangerousPermissions, contains(PluginPermission.fileSystem));
        expect(result.dangerousPermissions, contains(PluginPermission.network));
      });
    });

    group('权限请求', () {
      test('应该能够请求权限', () async {
        await manager.initialize();

        final result = await manager.requestPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
          reason: '测试权限请求',
        );

        expect(result.permission, equals(PluginPermission.deviceInfo));
        expect(result.granted, isTrue);
        // deviceInfo权限默认允许，所以reason会是'自动授权'而不是传入的reason
        expect(result.reason, isNotNull);
      });

      test('应该能够处理用户授权回调', () async {
        await manager.initialize();

        // 先清理可能存在的权限
        await manager.revokePermission('test_plugin_callback');

        var callbackCalled = false;
        manager
            .setUserAuthorizationCallback((pluginId, permission, reason) async {
          callbackCalled = true;
          expect(pluginId, equals('test_plugin_callback'));
          expect(permission, equals(PluginPermission.fileSystem));
          return true;
        });

        final result = await manager.requestPermission(
          'test_plugin_callback',
          PluginPermission.fileSystem,
          reason: '测试用户授权',
        );

        expect(callbackCalled, isTrue);
        expect(result.granted, isTrue);
        expect(result.reason, equals('用户授权'));
      });

      test('应该能够处理用户拒绝授权', () async {
        await manager.initialize();

        // 先清理可能存在的权限
        await manager.revokePermission('test_plugin_deny');

        manager
            .setUserAuthorizationCallback((pluginId, permission, reason) async {
          return false;
        });

        final result = await manager.requestPermission(
          'test_plugin_deny',
          PluginPermission.fileSystem,
          reason: '测试用户拒绝',
        );

        expect(result.granted, isFalse);
        expect(result.reason, equals('用户拒绝'));
      });
    });

    group('权限检查', () {
      test('应该能够检查权限状态', () async {
        await manager.initialize();

        // 先请求权限
        await manager.requestPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        // 检查权限
        final hasPermission = manager.hasPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        expect(hasPermission, isTrue);
      });

      test('应该能够获取权限授权信息', () async {
        await manager.initialize();

        // 先请求权限
        await manager.requestPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        // 获取授权信息
        final auth = manager.getPermissionAuthorization(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        expect(auth, isNotNull);
        expect(auth!.permission, equals(PluginPermission.deviceInfo));
        expect(auth.granted, isTrue);
      });
    });

    group('权限管理', () {
      test('应该能够撤销单个权限', () async {
        await manager.initialize();

        // 先请求权限
        await manager.requestPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        // 撤销权限
        await manager.revokePermission(
            'test_plugin', PluginPermission.deviceInfo);

        // 检查权限已被撤销
        final hasPermission = manager.hasPermission(
          'test_plugin',
          PluginPermission.deviceInfo,
        );

        expect(hasPermission, isFalse);
      });

      test('应该能够撤销所有权限', () async {
        await manager.initialize();

        // 先请求多个权限
        await manager.requestPermission(
            'test_plugin', PluginPermission.deviceInfo);
        await manager.requestPermission(
            'test_plugin', PluginPermission.notifications);

        // 撤销所有权限
        await manager.revokePermission('test_plugin');

        // 检查所有权限已被撤销
        expect(
            manager.hasPermission('test_plugin', PluginPermission.deviceInfo),
            isFalse);
        expect(
            manager.hasPermission(
                'test_plugin', PluginPermission.notifications),
            isFalse);
      });

      test('应该能够清理插件权限', () {
        manager.cleanupPluginPermissions('test_plugin');
        // 无异常抛出即为成功
      });

      test('应该能够清理过期权限', () {
        manager.cleanupExpiredPermissions();
        // 无异常抛出即为成功
      });
    });

    group('权限统计', () {
      test('应该能够获取权限统计信息', () async {
        await manager.initialize();

        final stats = manager.getPermissionStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('totalPlugins'), isTrue);
        expect(stats.containsKey('totalPermissions'), isTrue);
        expect(stats.containsKey('expiredPermissions'), isTrue);
        expect(stats.containsKey('expiringSoonPermissions'), isTrue);
        expect(stats.containsKey('permissionCounts'), isTrue);
      });
    });

    group('权限授权结果', () {
      test('应该能够正确判断权限有效性', () {
        final validResult = PermissionAuthorizationResult(
          permission: PluginPermission.deviceInfo,
          granted: true,
          timestamp: DateTime.now(),
        );

        expect(validResult.isValid, isTrue);

        final invalidResult = PermissionAuthorizationResult(
          permission: PluginPermission.deviceInfo,
          granted: false,
          timestamp: DateTime.now(),
        );

        expect(invalidResult.isValid, isFalse);
      });

      test('应该能够正确判断权限过期状态', () {
        final expiredResult = PermissionAuthorizationResult(
          permission: PluginPermission.deviceInfo,
          granted: true,
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(expiredResult.isValid, isFalse);

        final expiringSoonResult = PermissionAuthorizationResult(
          permission: PluginPermission.deviceInfo,
          granted: true,
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 3)),
        );

        expect(expiringSoonResult.isExpiringSoon, isTrue);
      });
    });

    group('权限请求结果', () {
      test('应该能够正确创建权限请求结果', () {
        const result = PermissionRequestResult(
          pluginId: 'test_plugin',
          permissions: [
            PermissionAuthorizationResult(
              permission: PluginPermission.deviceInfo,
              granted: true,
            ),
          ],
          allGranted: true,
        );

        expect(result.pluginId, equals('test_plugin'));
        expect(result.permissions, hasLength(1));
        expect(result.allGranted, isTrue);
        expect(result.deniedPermissions, isEmpty);
        expect(result.dangerousPermissions, isEmpty);
      });
    });
  });
}
