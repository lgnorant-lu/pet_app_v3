/*
---------------------------------------------------------------
File name:          phase_3_1_ui_integration_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        Phase 3.1 UI集成测试 - 插件管理界面集成验证
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 3.1 - 创建UI集成测试，验证插件管理界面集成;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

import 'package:pet_app_v3/app.dart';

void main() {
  group('Phase 3.1 UI集成测试', () {
    group('插件管理界面集成', () {
      testWidgets('应用启动后能正常显示主导航', (WidgetTester tester) async {
        // 启动应用
        await tester.pumpWidget(const PetAppV3());
        await tester.pumpAndSettle();

        // 验证主导航界面存在
        expect(find.text('Pet App V3'), findsOneWidget);
        
        // 验证底部导航栏存在
        expect(find.byType(NavigationBar), findsOneWidget);
        
        print('✅ 主导航界面显示正常');
      });

      testWidgets('能够切换到创意工坊页面', (WidgetTester tester) async {
        // 启动应用
        await tester.pumpWidget(const PetAppV3());
        await tester.pumpAndSettle();

        // 查找创意工坊导航按钮
        final workshopTab = find.text('创意工坊');
        expect(workshopTab, findsOneWidget);

        // 点击创意工坊标签
        await tester.tap(workshopTab);
        await tester.pumpAndSettle();

        // 验证创意工坊页面已显示
        expect(find.text('创意工坊'), findsWidgets);
        
        print('✅ 创意工坊页面切换成功');
      });

      testWidgets('创意工坊主页面包含所有必要的标签页', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 验证标签页存在
        expect(find.text('工作区'), findsOneWidget);
        expect(find.text('应用商店'), findsOneWidget);
        expect(find.text('插件管理'), findsOneWidget);
        expect(find.text('开发者'), findsOneWidget);

        print('✅ 创意工坊主页面标签页显示正常');
      });

      testWidgets('能够切换到插件管理标签页', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 点击插件管理标签
        await tester.tap(find.text('插件管理'));
        await tester.pumpAndSettle();

        // 验证插件管理页面内容
        expect(find.byType(PluginManagementPage), findsOneWidget);
        
        print('✅ 插件管理标签页切换成功');
      });

      testWidgets('插件管理页面包含所有必要的子标签', (WidgetTester tester) async {
        // 直接测试PluginManagementPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: PluginManagementPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 验证插件管理子标签存在
        expect(find.text('已安装'), findsOneWidget);
        expect(find.text('权限'), findsOneWidget);
        expect(find.text('更新'), findsOneWidget);
        expect(find.text('依赖'), findsOneWidget);

        print('✅ 插件管理页面子标签显示正常');
      });

      testWidgets('能够切换到应用商店标签页', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 点击应用商店标签
        await tester.tap(find.text('应用商店'));
        await tester.pumpAndSettle();

        // 验证应用商店页面内容
        expect(find.byType(AppStorePage), findsOneWidget);
        
        print('✅ 应用商店标签页切换成功');
      });

      testWidgets('能够切换到开发者标签页', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 点击开发者标签
        await tester.tap(find.text('开发者'));
        await tester.pumpAndSettle();

        // 验证开发者平台页面内容
        expect(find.byType(DeveloperPlatformPage), findsOneWidget);
        
        print('✅ 开发者标签页切换成功');
      });
    });

    group('UI组件功能验证', () {
      testWidgets('快速操作菜单功能正常', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 查找并点击更多操作按钮
        final moreButton = find.byIcon(Icons.more_vert);
        expect(moreButton, findsOneWidget);
        
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        // 验证快速操作菜单项
        expect(find.text('刷新'), findsOneWidget);
        expect(find.text('设置'), findsOneWidget);
        expect(find.text('帮助'), findsOneWidget);

        print('✅ 快速操作菜单显示正常');
      });

      testWidgets('帮助对话框功能正常', (WidgetTester tester) async {
        // 直接测试CreativeWorkshopMainPage组件
        await tester.pumpWidget(
          const MaterialApp(
            home: CreativeWorkshopMainPage(),
          ),
        );
        await tester.pumpAndSettle();

        // 打开更多操作菜单
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // 点击帮助
        await tester.tap(find.text('帮助'));
        await tester.pumpAndSettle();

        // 验证帮助对话框
        expect(find.text('Creative Workshop 帮助'), findsOneWidget);
        expect(find.text('🎨 创意工作区'), findsOneWidget);
        expect(find.text('🏪 应用商店'), findsOneWidget);
        expect(find.text('🔧 插件管理'), findsOneWidget);
        expect(find.text('👨‍💻 开发者平台'), findsOneWidget);

        // 关闭对话框
        await tester.tap(find.text('关闭'));
        await tester.pumpAndSettle();

        print('✅ 帮助对话框功能正常');
      });
    });

    group('集成完整性验证', () {
      testWidgets('Creative Workshop组件能正确导出和使用', (WidgetTester tester) async {
        // 验证所有主要组件都能正确实例化
        expect(() => const CreativeWorkshopMainPage(), returnsNormally);
        expect(() => const PluginManagementPage(), returnsNormally);
        expect(() => const AppStorePage(), returnsNormally);
        expect(() => const DeveloperPlatformPage(), returnsNormally);

        print('✅ Creative Workshop组件导出正常');
      });

      testWidgets('插件系统与UI组件集成正常', (WidgetTester tester) async {
        // 启动完整应用
        await tester.pumpWidget(const PetAppV3());
        await tester.pumpAndSettle();

        // 验证插件系统初始化
        final workshopManager = WorkshopManager.instance;
        expect(workshopManager, isNotNull);

        // 切换到创意工坊
        await tester.tap(find.text('创意工坊'));
        await tester.pumpAndSettle();

        // 切换到插件管理
        await tester.tap(find.text('插件管理'));
        await tester.pumpAndSettle();

        // 验证插件管理页面正常显示
        expect(find.byType(PluginManagementPage), findsOneWidget);

        print('✅ 插件系统与UI组件集成正常');
      });
    });
  });
}
