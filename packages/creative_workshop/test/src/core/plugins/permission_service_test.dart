/*
---------------------------------------------------------------
File name:          permission_service_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        权限服务测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 权限服务测试实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/permission_service.dart';
import 'package:creative_workshop/src/core/plugins/permission_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('PermissionService Tests', () {
    late PermissionService permissionService;
    var testCounter = 0;

    setUp(() async {
      permissionService = PermissionService.instance;
      testCounter++;
    });

    tearDown(() {
      // 清理测试插件权限（如果已初始化）
      try {
        final testPluginId = 'test_plugin_$testCounter';
        permissionService.cleanupPluginPermissions(testPluginId);
      } catch (e) {
        // 忽略未初始化的错误
      }
    });

    group('初始化测试', () {
      testWidgets('应该能够获取单例实例', (tester) async {
        final instance1 = PermissionService.instance;
        final instance2 = PermissionService.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      testWidgets('应该能够初始化权限服务', (tester) async {
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

        // 验证初始化成功（没有抛出异常）
        expect(true, isTrue);
      });
    });

    group('权限检查测试', () {
      testWidgets('应该能够检查插件权限', (tester) async {
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

        final pluginId = 'test_plugin_check_$testCounter';

        // 初始状态应该没有权限
        expect(
            permissionService.hasPermission(
                pluginId, PluginPermission.notifications),
            isFalse);

        // 设置策略为自动允许并请求权限
        permissionService.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        await permissionService.requestPermission(
          pluginId,
          'Test Plugin',
          PluginPermission.notifications,
        );

        // 现在应该有权限
        expect(
            permissionService.hasPermission(
                pluginId, PluginPermission.notifications),
            isTrue);
      });

      testWidgets('应该能够批量检查权限', (tester) async {
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

        final pluginId = 'test_plugin_batch_check_$testCounter';

        // 设置不同权限策略
        permissionService.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        permissionService.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);

        // 请求部分权限
        await permissionService.requestPermission(
          pluginId,
          'Test Plugin',
          PluginPermission.notifications,
        );

        final permissions = [
          PluginPermission.notifications,
          PluginPermission.clipboard,
          PluginPermission.camera,
        ];

        final result =
            permissionService.checkPermissions(pluginId, permissions);

        expect(result[PluginPermission.notifications], isTrue);
        expect(result[PluginPermission.clipboard], isFalse);
        expect(result[PluginPermission.camera], isFalse);
      });

      testWidgets('应该能够获取缺失的权限', (tester) async {
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

        final pluginId = 'test_plugin_missing_$testCounter';

        final requiredPermissions = [
          PluginPermission.notifications,
          PluginPermission.clipboard,
          PluginPermission.camera,
        ];

        final missingPermissions = permissionService.getMissingPermissions(
          pluginId,
          requiredPermissions,
        );

        expect(missingPermissions.length, 3);
        expect(missingPermissions, containsAll(requiredPermissions));
      });
    });

    group('权限风险评估测试', () {
      test('应该能够识别危险权限', () {
        expect(
            permissionService
                .isDangerousPermission(PluginPermission.fileSystem),
            isTrue);
        expect(
            permissionService.isDangerousPermission(PluginPermission.network),
            isTrue);
        expect(permissionService.isDangerousPermission(PluginPermission.camera),
            isTrue);
        expect(
            permissionService
                .isDangerousPermission(PluginPermission.microphone),
            isTrue);
        expect(
            permissionService.isDangerousPermission(PluginPermission.location),
            isTrue);

        expect(
            permissionService
                .isDangerousPermission(PluginPermission.notifications),
            isFalse);
        expect(
            permissionService.isDangerousPermission(PluginPermission.clipboard),
            isFalse);
        expect(
            permissionService
                .isDangerousPermission(PluginPermission.deviceInfo),
            isFalse);
      });

      test('应该能够识别危险权限组合', () {
        // 文件系统 + 网络访问
        expect(
          permissionService.isDangerousPermissionCombination([
            PluginPermission.fileSystem,
            PluginPermission.network,
          ]),
          isTrue,
        );

        // 相机 + 网络访问
        expect(
          permissionService.isDangerousPermissionCombination([
            PluginPermission.camera,
            PluginPermission.network,
          ]),
          isTrue,
        );

        // 安全组合
        expect(
          permissionService.isDangerousPermissionCombination([
            PluginPermission.notifications,
            PluginPermission.clipboard,
          ]),
          isFalse,
        );
      });

      test('应该能够获取权限风险等级', () {
        expect(
            permissionService
                .getPermissionRiskLevel(PluginPermission.fileSystem),
            '高风险');
        expect(
            permissionService
                .getPermissionRiskLevel(PluginPermission.notifications),
            '低风险');
      });

      test('应该能够获取权限组合风险等级', () {
        // 危险组合
        expect(
          permissionService.getPermissionCombinationRiskLevel([
            PluginPermission.fileSystem,
            PluginPermission.network,
          ]),
          '高风险',
        );

        // 包含危险权限但非危险组合
        expect(
          permissionService.getPermissionCombinationRiskLevel([
            PluginPermission.fileSystem,
            PluginPermission.notifications,
          ]),
          '中风险',
        );

        // 安全组合
        expect(
          permissionService.getPermissionCombinationRiskLevel([
            PluginPermission.notifications,
            PluginPermission.clipboard,
          ]),
          '低风险',
        );
      });
    });

    group('权限管理测试', () {
      testWidgets('应该能够撤销权限', (tester) async {
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

        final pluginId = 'test_plugin_revoke_$testCounter';

        // 先授权
        permissionService.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        await permissionService.requestPermission(
          pluginId,
          'Test Plugin',
          PluginPermission.notifications,
        );
        expect(
            permissionService.hasPermission(
                pluginId, PluginPermission.notifications),
            isTrue);

        // 撤销权限
        await permissionService.revokePermission(
            pluginId, PluginPermission.notifications);
        expect(
            permissionService.hasPermission(
                pluginId, PluginPermission.notifications),
            isFalse);
      });

      testWidgets('应该能够获取插件权限列表', (tester) async {
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

        final pluginId = 'test_plugin_list_$testCounter';

        // 授权多个权限
        permissionService.setPermissionPolicy(
            PluginPermission.notifications, PermissionPolicy.allow);
        permissionService.setPermissionPolicy(
            PluginPermission.clipboard, PermissionPolicy.allow);

        await permissionService.requestPermission(
          pluginId,
          'Test Plugin',
          PluginPermission.notifications,
        );
        await permissionService.requestPermission(
          pluginId,
          'Test Plugin',
          PluginPermission.clipboard,
        );

        final permissions = permissionService.getPluginPermissions(pluginId);
        expect(permissions.length, 2);
        expect(permissions.contains(PluginPermission.notifications), isTrue);
        expect(permissions.contains(PluginPermission.clipboard), isTrue);
      });
    });

    group('工具方法测试', () {
      test('应该能够格式化权限列表', () {
        final permissions = [
          PluginPermission.fileSystem,
          PluginPermission.network,
          PluginPermission.camera,
        ];

        final formatted = permissionService.formatPermissionList(permissions);
        expect(formatted, contains('文件系统访问'));
        expect(formatted, contains('网络访问'));
        expect(formatted, contains('相机访问'));
        expect(formatted, contains('、'));
      });

      test('空权限列表应该返回"无"', () {
        final formatted = permissionService.formatPermissionList([]);
        expect(formatted, '无');
      });

      test('应该能够获取插件显示名称', () {
        final displayName =
            permissionService.getPluginDisplayName('test_plugin_name');
        expect(displayName, 'Test Plugin Name');
      });

      test('应该能够检查是否有足够权限', () {
        final pluginId = 'test_plugin_sufficient_$testCounter';
        final requiredPermissions = [
          PluginPermission.notifications,
          PluginPermission.clipboard,
        ];

        // 初始状态没有足够权限
        expect(
            permissionService.hasAllPermissions(pluginId, requiredPermissions),
            isFalse);
      });
    });

    group('统计信息测试', () {
      testWidgets('应该能够获取权限统计信息', (tester) async {
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

        final stats = permissionService.getPermissionStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('totalPlugins'), isTrue);
        expect(stats.containsKey('totalPermissions'), isTrue);
        expect(stats.containsKey('permissionCounts'), isTrue);
      });
    });
  });
}
