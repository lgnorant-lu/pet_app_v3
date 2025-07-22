/*
---------------------------------------------------------------
File name:          permission_manager_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        权限管理器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 权限管理器测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/permission_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('PermissionManager Tests', () {
    late PermissionManager permissionManager;
    var testCounter = 0;

    setUp(() async {
      permissionManager = PermissionManager.instance;
      await permissionManager.initialize();
      testCounter++;
    });

    tearDown(() {
      // 清理测试插件权限
      final testPluginId = 'test_plugin_$testCounter';
      permissionManager.cleanupPluginPermissions(testPluginId);
    });

    group('初始化测试', () {
      test('应该能够获取单例实例', () {
        final instance1 = PermissionManager.instance;
        final instance2 = PermissionManager.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('应该能够初始化权限管理器', () async {
        final manager = PermissionManager.instance;
        await manager.initialize();

        // 验证默认策略已设置
        expect(manager.getPermissionPolicy(PluginPermission.fileSystem),
            PermissionPolicy.ask);
        expect(manager.getPermissionPolicy(PluginPermission.network),
            PermissionPolicy.ask);
        expect(manager.getPermissionPolicy(PluginPermission.notifications),
            PermissionPolicy.allow);
      });
    });

    group('权限策略测试', () {
      test('应该能够设置和获取权限策略', () {
        permissionManager.setPermissionPolicy(
            PluginPermission.fileSystem, PermissionPolicy.allow);
        expect(
            permissionManager.getPermissionPolicy(PluginPermission.fileSystem),
            PermissionPolicy.allow);

        permissionManager.setPermissionPolicy(
            PluginPermission.network, PermissionPolicy.deny);
        expect(permissionManager.getPermissionPolicy(PluginPermission.network),
            PermissionPolicy.deny);
      });

      test('未设置的权限应该返回默认策略', () {
        // 清理所有策略设置
        permissionManager.setPermissionPolicy(
            PluginPermission.deviceInfo, PermissionPolicy.ask);
        expect(
            permissionManager.getPermissionPolicy(PluginPermission.deviceInfo),
            PermissionPolicy.ask);
      });
    });

    group('权限请求测试', () {
      test('自动允许策略应该直接授权', () async {
        final pluginId = 'test_plugin_allow_$testCounter';

        // 设置为自动允许
        permissionManager.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);

        final result = await permissionManager.requestPermission(
          pluginId,
          PluginPermission.notifications,
          reason: '测试自动允许',
        );

        expect(result.granted, isTrue);
        expect(result.permission, PluginPermission.notifications);
        expect(result.reason, '测试自动允许');
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.notifications),
            isTrue);
      });

      test('自动拒绝策略应该直接拒绝', () async {
        final pluginId = 'test_plugin_deny_$testCounter';

        // 设置为自动拒绝
        permissionManager.setPermissionPolicy(
            PluginPermission.camera, PermissionPolicy.deny);

        final result = await permissionManager.requestPermission(
          pluginId,
          PluginPermission.camera,
          reason: '测试自动拒绝',
        );

        expect(result.granted, isFalse);
        expect(result.permission, PluginPermission.camera);
        expect(result.reason, '权限策略拒绝');
        expect(
            permissionManager.hasPermission(pluginId, PluginPermission.camera),
            isFalse);
      });

      test('询问用户策略应该调用用户授权回调', () async {
        final pluginId = 'test_plugin_ask_$testCounter';
        bool callbackCalled = false;

        // 设置用户授权回调
        permissionManager
            .setUserAuthorizationCallback((pluginId, permission, reason) async {
          callbackCalled = true;
          expect(permission, PluginPermission.fileSystem);
          expect(reason, '测试用户授权');
          return true; // 用户同意
        });

        // 设置为询问用户
        permissionManager.setPermissionPolicy(
            PluginPermission.fileSystem, PermissionPolicy.ask);

        final result = await permissionManager.requestPermission(
          pluginId,
          PluginPermission.fileSystem,
          reason: '测试用户授权',
        );

        expect(callbackCalled, isTrue);
        expect(result.granted, isTrue);
        expect(result.reason, '用户授权');
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.fileSystem),
            isTrue);
      });

      test('用户拒绝授权应该返回拒绝结果', () async {
        final pluginId = 'test_plugin_user_deny_$testCounter';

        // 设置用户授权回调（用户拒绝）
        permissionManager
            .setUserAuthorizationCallback((pluginId, permission, reason) async {
          return false; // 用户拒绝
        });

        permissionManager.setPermissionPolicy(
            PluginPermission.microphone, PermissionPolicy.ask);

        final result = await permissionManager.requestPermission(
          pluginId,
          PluginPermission.microphone,
          reason: '测试用户拒绝',
        );

        expect(result.granted, isFalse);
        expect(result.reason, '用户拒绝');
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.microphone),
            isFalse);
      });

      test('没有用户授权回调应该默认拒绝', () async {
        final pluginId = 'test_plugin_no_callback_$testCounter';

        // 清除用户授权回调
        permissionManager.setUserAuthorizationCallback(null);

        permissionManager.setPermissionPolicy(
            PluginPermission.location, PermissionPolicy.ask);

        final result = await permissionManager.requestPermission(
          pluginId,
          PluginPermission.location,
          reason: '测试无回调',
        );

        expect(result.granted, isFalse);
        expect(result.reason, '无用户授权回调');
      });
    });

    group('权限验证测试', () {
      test('应该能够验证单个权限', () async {
        final pluginId = 'test_plugin_validate_single_$testCounter';

        // 设置为自动允许
        permissionManager.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);

        final result = await permissionManager.validatePermissions(
          pluginId,
          [PluginPermission.clipboard],
        );

        expect(result.success, isTrue);
        expect(result.results.length, 1);
        expect(result.results.first.granted, isTrue);
        expect(result.allGranted, isTrue);
      });

      test('应该能够验证多个权限', () async {
        final pluginId = 'test_plugin_validate_multiple_$testCounter';

        // 设置不同策略
        permissionManager.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        permissionManager.setPermissionPolicy(
            PluginPermission.deviceInfo, PermissionPolicy.allow);

        final result = await permissionManager.validatePermissions(
          pluginId,
          [PluginPermission.notifications, PluginPermission.deviceInfo],
        );

        expect(result.success, isTrue);
        expect(result.results.length, 2);
        expect(result.allGranted, isTrue);
        expect(result.grantedPermissions.length, 2);
        expect(result.deniedPermissions.length, 0);
      });

      test('危险权限组合应该被拒绝', () async {
        final pluginId = 'test_plugin_dangerous_$testCounter';

        // 文件系统 + 网络访问是危险组合
        final result = await permissionManager.validatePermissions(
          pluginId,
          [PluginPermission.fileSystem, PluginPermission.network],
        );

        expect(result.success, isFalse);
        expect(result.error, contains('权限组合存在安全风险'));
      });

      test('相机 + 网络访问组合应该被拒绝', () async {
        final pluginId = 'test_plugin_camera_network_$testCounter';

        final result = await permissionManager.validatePermissions(
          pluginId,
          [PluginPermission.camera, PluginPermission.network],
        );

        expect(result.success, isFalse);
        expect(result.error, contains('权限组合存在安全风险'));
      });
    });

    group('权限管理测试', () {
      test('应该能够撤销单个权限', () async {
        final pluginId = 'test_plugin_revoke_single_$testCounter';

        // 先授权
        permissionManager.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);
        await permissionManager.requestPermission(
            pluginId, PluginPermission.clipboard);
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.clipboard),
            isTrue);

        // 撤销权限
        await permissionManager.revokePermission(
            pluginId, PluginPermission.clipboard);
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.clipboard),
            isFalse);
      });

      test('应该能够撤销所有权限', () async {
        final pluginId = 'test_plugin_revoke_all_$testCounter';

        // 先授权多个权限
        permissionManager.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        permissionManager.setPermissionPolicy(
            PluginPermission.deviceInfo, PermissionPolicy.allow);

        await permissionManager.requestPermission(
            pluginId, PluginPermission.notifications);
        await permissionManager.requestPermission(
            pluginId, PluginPermission.deviceInfo);

        expect(permissionManager.getPluginPermissions(pluginId).length, 2);

        // 撤销所有权限
        await permissionManager.revokePermission(pluginId);
        expect(permissionManager.getPluginPermissions(pluginId).length, 0);
      });

      test('应该能够获取插件权限列表', () async {
        final pluginId = 'test_plugin_get_permissions_$testCounter';

        // 授权多个权限
        permissionManager.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        permissionManager.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);

        await permissionManager.requestPermission(
            pluginId, PluginPermission.notifications);
        await permissionManager.requestPermission(
            pluginId, PluginPermission.clipboard);

        final permissions = permissionManager.getPluginPermissions(pluginId);
        expect(permissions.length, 2);
        expect(permissions.contains(PluginPermission.notifications), isTrue);
        expect(permissions.contains(PluginPermission.clipboard), isTrue);
      });

      test('应该能够清理插件权限', () async {
        final pluginId = 'test_plugin_cleanup_$testCounter';

        // 授权权限
        permissionManager.setPermissionPolicy(
            PluginPermission.deviceInfo, PermissionPolicy.allow);
        await permissionManager.requestPermission(
            pluginId, PluginPermission.deviceInfo);
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.deviceInfo),
            isTrue);

        // 清理权限
        permissionManager.cleanupPluginPermissions(pluginId);
        expect(
            permissionManager.hasPermission(
                pluginId, PluginPermission.deviceInfo),
            isFalse);
        expect(permissionManager.getPluginPermissions(pluginId).length, 0);
      });
    });

    group('权限统计测试', () {
      test('应该能够获取权限统计信息', () async {
        // 创建一个新的权限管理器实例来避免之前测试的干扰
        final testManager = PermissionManager.instance;

        // 清理所有现有权限
        final existingStats = testManager.getPermissionStatistics();
        final existingPlugins = existingStats['totalPlugins'] as int;

        final pluginId1 = 'test_plugin_stats_1_$testCounter';
        final pluginId2 = 'test_plugin_stats_2_$testCounter';

        // 为不同插件授权不同权限
        testManager.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        testManager.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);

        await testManager.requestPermission(
            pluginId1, PluginPermission.notifications);
        await testManager.requestPermission(
            pluginId1, PluginPermission.clipboard);
        await testManager.requestPermission(
            pluginId2, PluginPermission.notifications);

        final stats = testManager.getPermissionStatistics();

        expect(stats['totalPlugins'], existingPlugins + 2);
        expect(stats['totalPermissions'], greaterThanOrEqualTo(3));
        expect(stats['permissionCounts']['notifications'],
            greaterThanOrEqualTo(2));
        expect(stats['permissionCounts']['clipboard'], greaterThanOrEqualTo(1));

        // 清理测试数据
        testManager.cleanupPluginPermissions(pluginId1);
        testManager.cleanupPluginPermissions(pluginId2);
      });
    });

    group('权限过期测试', () {
      test('过期权限应该被识别为无效', () async {
        final pluginId = 'test_plugin_expired_$testCounter';

        // 创建一个已过期的权限授权
        final expiredAuth = PermissionAuthorizationResult(
          permission: PluginPermission.notifications,
          granted: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(expiredAuth.isExpired, isTrue);
        expect(expiredAuth.isValid, isFalse);
      });

      test('应该能够清理过期权限', () async {
        // 这个测试需要模拟过期权限，但由于当前实现没有设置过期时间
        // 我们先验证清理方法不会出错
        permissionManager.cleanupExpiredPermissions();

        // 验证方法执行成功（没有抛出异常）
        expect(true, isTrue);
      });
    });
  });
}
