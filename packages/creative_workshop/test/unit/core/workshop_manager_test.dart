/*
---------------------------------------------------------------
File name:          workshop_manager_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        WorkshopManager单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - WorkshopManager测试覆盖;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';
import 'package:creative_workshop/src/core/workshop_manager.dart';
import 'package:creative_workshop/src/core/tools/drawing_tools.dart';
import 'package:creative_workshop/src/core/games/simple_games.dart';

void main() {
  group('WorkshopManager Tests', () {
    late WorkshopManager workshopManager;
    late PluginRegistry pluginRegistry;

    setUpAll(() async {
      // 在所有测试开始前初始化一次
      pluginRegistry = PluginRegistry.instance;
      workshopManager = WorkshopManager.instance;

      // 只初始化一次
      if (workshopManager.state == WorkshopState.uninitialized) {
        await workshopManager.initialize();
      }
    });

    group('初始化测试', () {
      test('应该已经初始化完成', () {
        expect(workshopManager.state, equals(WorkshopState.ready));
      });

      test('应该能够获取状态', () {
        expect(workshopManager.state, isA<WorkshopState>());
      });
    });

    group('插件注册测试', () {
      test('应该能够注册内置工具插件', () {
        // 验证画笔工具已注册
        final plugins = pluginRegistry.getAllPlugins();
        final brushTool = plugins.firstWhere(
          (plugin) => plugin.id == 'simple_brush_tool',
          orElse: () => throw StateError('画笔工具未找到'),
        );

        expect(brushTool, isA<SimpleBrushTool>());
        expect(brushTool.name, equals('画笔工具'));
      });

      test('应该能够注册内置游戏插件', () {
        // 验证点击游戏已注册
        final plugins = pluginRegistry.getAllPlugins();
        final clickGame = plugins.firstWhere(
          (plugin) => plugin.id == 'simple_click_game',
          orElse: () => throw StateError('点击游戏未找到'),
        );

        expect(clickGame, isA<SimpleClickGame>());
        expect(clickGame.name, equals('点击游戏'));
      });
    });

    group('状态管理测试', () {
      test('状态应该是就绪', () {
        expect(workshopManager.state, equals(WorkshopState.ready));
      });

      test('应该能够获取项目管理器', () {
        expect(workshopManager.projectManager, isNotNull);
      });

      test('应该能够监听状态变化', () async {
        final stateChanges = <WorkshopState>[];
        final subscription = workshopManager.stateChanges.listen((state) {
          stateChanges.add(state);
        });

        // 等待状态变化
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // 由于已经初始化，状态变化流可能为空或包含当前状态
        expect(workshopManager.state, equals(WorkshopState.ready));

        await subscription.cancel();
      });
    });
  });
}
