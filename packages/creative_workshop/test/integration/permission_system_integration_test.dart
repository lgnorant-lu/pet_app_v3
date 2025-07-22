/*
---------------------------------------------------------------
File name:          permission_system_integration_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        权限系统集成测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 权限系统集成测试实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/permission_service.dart';
import 'package:creative_workshop/src/core/plugins/permission_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('Permission System Integration Tests', () {
    late PermissionService permissionService;
    late PermissionManager permissionManager;
    late PluginManager pluginManager;
    var testCounter = 0;

    setUpAll(() async {
      permissionService = PermissionService.instance;
      permissionManager = PermissionManager.instance;
      pluginManager = PluginManager.instance;
      
      await permissionManager.initialize();
      await pluginManager.initialize();
    });

    setUp(() {
      testCounter++;
    });

    tearDown(() async {
      // 清理测试插件
      try {
        final testPluginIds = [
          'integration_test_plugin_$testCounter',
          'permission_test_plugin_$testCounter',
          'dangerous_plugin_$testCounter',
        ];
        
        for (final pluginId in testPluginIds) {
          try {
            await pluginManager.uninstallPlugin(pluginId);
          } catch (e) {
            // 忽略卸载错误
          }
          permissionService.cleanupPluginPermissions(pluginId);
        }
      } catch (e) {
        // 忽略清理错误
      }
    });

    group('插件安装权限检查集成', () {
      testWidgets('插件安装时应该检查权限', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'integration_test_plugin_$testCounter';
        
        // 设置权限策略为自动允许
        permissionService.setPermissionPolicy(PluginPermission.fileSystem, PermissionPolicy.allow);
        permissionService.setPermissionPolicy(PluginPermission.notifications, PermissionPolicy.allow);
        
        // 安装插件
        final installResult = await pluginManager.installPlugin(pluginId);
        expect(installResult.success, isTrue);
        
        // 验证插件已安装
        expect(pluginManager.isPluginInstalled(pluginId), isTrue);
        
        // 请求权限
        await permissionService.requestPermission(
          pluginId,
          'Integration Test Plugin',
          PluginPermission.fileSystem,
        );
        
        // 验证权限已授权
        expect(permissionService.hasPermission(pluginId, PluginPermission.fileSystem), isTrue);
      });

      testWidgets('插件卸载时应该清理权限', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'permission_test_plugin_$testCounter';
        
        // 安装插件并授权权限
        await pluginManager.installPlugin(pluginId);
        
        permissionService.setPermissionPolicy(PluginPermission.notifications, PermissionPolicy.allow);
        await permissionService.requestPermission(
          pluginId,
          'Permission Test Plugin',
          PluginPermission.notifications,
        );
        
        expect(permissionService.hasPermission(pluginId, PluginPermission.notifications), isTrue);
        
        // 卸载插件
        final uninstallResult = await pluginManager.uninstallPlugin(pluginId);
        expect(uninstallResult.success, isTrue);
        
        // 验证权限已清理
        expect(permissionService.hasPermission(pluginId, PluginPermission.notifications), isFalse);
        expect(permissionService.getPluginPermissions(pluginId).isEmpty, isTrue);
      });
    });

    group('危险权限组合检查', () {
      testWidgets('应该阻止危险权限组合', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'dangerous_plugin_$testCounter';
        
        // 尝试请求危险权限组合
        final dangerousPermissions = [
          PluginPermission.fileSystem,
          PluginPermission.network,
        ];
        
        final result = await permissionService.requestPermissions(
          pluginId,
          'Dangerous Plugin',
          dangerousPermissions,
        );
        
        // 应该被拒绝
        expect(result.success, isFalse);
        expect(result.error, contains('权限组合存在安全风险'));
      });

      testWidgets('应该识别危险权限', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // 验证危险权限识别
        expect(permissionService.isDangerousPermission(PluginPermission.fileSystem), isTrue);
        expect(permissionService.isDangerousPermission(PluginPermission.network), isTrue);
        expect(permissionService.isDangerousPermission(PluginPermission.camera), isTrue);
        expect(permissionService.isDangerousPermission(PluginPermission.microphone), isTrue);
        expect(permissionService.isDangerousPermission(PluginPermission.location), isTrue);
        
        expect(permissionService.isDangerousPermission(PluginPermission.notifications), isFalse);
        expect(permissionService.isDangerousPermission(PluginPermission.clipboard), isFalse);
        expect(permissionService.isDangerousPermission(PluginPermission.deviceInfo), isFalse);
      });
    });

    group('权限策略管理', () {
      testWidgets('应该能够设置和应用权限策略', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'policy_test_plugin_$testCounter';
        
        // 设置不同的权限策略
        permissionService.setPermissionPolicy(PluginPermission.notifications, PermissionPolicy.allow);
        permissionService.setPermissionPolicy(PluginPermission.camera, PermissionPolicy.deny);
        
        // 测试自动允许策略
        final allowResult = await permissionService.requestPermission(
          pluginId,
          'Policy Test Plugin',
          PluginPermission.notifications,
        );
        expect(allowResult.granted, isTrue);
        
        // 测试自动拒绝策略
        final denyResult = await permissionService.requestPermission(
          pluginId,
          'Policy Test Plugin',
          PluginPermission.camera,
        );
        expect(denyResult.granted, isFalse);
        
        // 验证策略获取
        expect(permissionService.getPermissionPolicy(PluginPermission.notifications), PermissionPolicy.allow);
        expect(permissionService.getPermissionPolicy(PluginPermission.camera), PermissionPolicy.deny);
      });
    });

    group('权限统计和监控', () {
      testWidgets('应该能够获取权限使用统计', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId1 = 'stats_plugin_1_$testCounter';
        final pluginId2 = 'stats_plugin_2_$testCounter';
        
        // 为不同插件授权不同权限
        permissionService.setPermissionPolicy(PluginPermission.notifications, PermissionPolicy.allow);
        permissionService.setPermissionPolicy(PluginPermission.clipboard, PermissionPolicy.allow);
        
        await permissionService.requestPermission(
          pluginId1,
          'Stats Plugin 1',
          PluginPermission.notifications,
        );
        await permissionService.requestPermission(
          pluginId1,
          'Stats Plugin 1',
          PluginPermission.clipboard,
        );
        await permissionService.requestPermission(
          pluginId2,
          'Stats Plugin 2',
          PluginPermission.notifications,
        );
        
        final stats = permissionService.getPermissionStatistics();
        
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalPlugins'], greaterThanOrEqualTo(2));
        expect(stats['totalPermissions'], greaterThanOrEqualTo(3));
        expect(stats['permissionCounts'], isA<Map>());
        
        // 清理
        permissionService.cleanupPluginPermissions(pluginId1);
        permissionService.cleanupPluginPermissions(pluginId2);
      });
    });

    group('权限生命周期管理', () {
      testWidgets('应该能够管理权限的完整生命周期', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'lifecycle_plugin_$testCounter';
        
        // 1. 初始状态：无权限
        expect(permissionService.hasPermission(pluginId, PluginPermission.notifications), isFalse);
        
        // 2. 请求权限
        permissionService.setPermissionPolicy(PluginPermission.notifications, PermissionPolicy.allow);
        await permissionService.requestPermission(
          pluginId,
          'Lifecycle Plugin',
          PluginPermission.notifications,
        );
        
        // 3. 验证权限已授权
        expect(permissionService.hasPermission(pluginId, PluginPermission.notifications), isTrue);
        
        // 4. 获取权限列表
        final permissions = permissionService.getPluginPermissions(pluginId);
        expect(permissions, contains(PluginPermission.notifications));
        
        // 5. 撤销权限
        await permissionService.revokePermission(pluginId, PluginPermission.notifications);
        expect(permissionService.hasPermission(pluginId, PluginPermission.notifications), isFalse);
        
        // 6. 清理所有权限
        permissionService.cleanupPluginPermissions(pluginId);
        expect(permissionService.getPluginPermissions(pluginId).isEmpty, isTrue);
      });
    });

    group('权限工具方法', () {
      testWidgets('应该提供有用的权限工具方法', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await permissionService.initialize(context);
                  },
                  child: const Text('Initialize'),
                ),
              );
            },
          ),
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final pluginId = 'utils_plugin_$testCounter';
        
        // 测试权限格式化
        final permissions = [
          PluginPermission.fileSystem,
          PluginPermission.network,
        ];
        final formatted = permissionService.formatPermissionList(permissions);
        expect(formatted, contains('文件系统访问'));
        expect(formatted, contains('网络访问'));
        
        // 测试插件名称格式化
        final displayName = permissionService.getPluginDisplayName('test_plugin_name');
        expect(displayName, 'Test Plugin Name');
        
        // 测试权限风险等级
        expect(permissionService.getPermissionRiskLevel(PluginPermission.fileSystem), '高风险');
        expect(permissionService.getPermissionRiskLevel(PluginPermission.notifications), '低风险');
        
        // 测试权限组合风险等级
        expect(
          permissionService.getPermissionCombinationRiskLevel([
            PluginPermission.fileSystem,
            PluginPermission.network,
          ]),
          '高风险',
        );
        
        // 测试缺失权限检查
        final requiredPermissions = [
          PluginPermission.notifications,
          PluginPermission.clipboard,
        ];
        final missingPermissions = permissionService.getMissingPermissions(
          pluginId,
          requiredPermissions,
        );
        expect(missingPermissions.length, 2);
        
        // 测试权限充足性检查
        expect(permissionService.hasAllPermissions(pluginId, requiredPermissions), isFalse);
      });
    });
  });
}
