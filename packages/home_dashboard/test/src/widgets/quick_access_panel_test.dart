/*
---------------------------------------------------------------
File name:          quick_access_panel_test.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        快速访问面板组件测试 - Phase 5.0.7.1
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_dashboard/src/models/quick_action.dart';
import 'package:home_dashboard/src/providers/quick_access_provider.dart';
import 'package:home_dashboard/src/widgets/quick_access_panel.dart';

void main() {
  group('QuickAccessPanel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget() {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: QuickAccessPanel(),
          ),
        ),
      );
    }

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      // 创建一个始终加载中的状态
      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) => QuickAccessNotifier()),
        ],
      );

      await tester.pumpWidget(createTestWidget());

      // 在初始化期间应该显示加载指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state when error occurs',
        (WidgetTester tester) async {
      // 创建错误状态
      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              const QuickAccessState(error: '测试错误'),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('加载失败'), findsOneWidget);
      expect(find.text('测试错误'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('should display quick access panel with actions',
        (WidgetTester tester) async {
      // 创建测试数据
      final testActions = [
        QuickAction(
          id: 'test1',
          title: '测试操作1',
          description: '测试描述1',
          icon: Icons.science,
          color: Colors.blue,
          createdAt: DateTime.now(),
        ),
        QuickAction(
          id: 'test2',
          title: '测试操作2',
          description: '测试描述2',
          icon: Icons.settings,
          color: Colors.green,
          priority: QuickActionPriority.pinned,
          createdAt: DateTime.now(),
        ),
      ];

      final testWorkflows = [
        Workflow(
          id: 'workflow1',
          name: '测试工作流',
          description: '测试工作流描述',
          icon: Icons.alt_route,
          color: Colors.orange,
          steps: [],
          createdAt: DateTime.now(),
        ),
      ];

      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              QuickAccessState(
                allActions: testActions,
                recommendedActions: [testActions[0]],
                pinnedActions: [testActions[1]],
                recentActions: testActions,
                workflows: testWorkflows,
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 验证标题
      expect(find.text('智能快捷入口'), findsOneWidget);

      // 验证置顶操作部分
      expect(find.text('置顶操作'), findsOneWidget);
      expect(find.text('测试操作2'), findsOneWidget);

      // 验证推荐操作部分
      expect(find.text('推荐操作'), findsOneWidget);
      expect(find.text('测试操作1'), findsOneWidget);

      // 验证工作流部分
      expect(find.text('快速工作流'), findsOneWidget);
      expect(find.text('测试工作流'), findsOneWidget);

      // 验证最近活动部分
      expect(find.text('最近活动'), findsOneWidget);
    });

    testWidgets('should handle action tap', (WidgetTester tester) async {
      final testAction = QuickAction(
        id: 'test_tap',
        title: '可点击操作',
        description: '测试点击',
        icon: Icons.touch_app,
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              QuickAccessState(
                allActions: [testAction],
                recommendedActions: [testAction],
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 点击操作
      await tester.tap(find.text('可点击操作'));
      await tester.pumpAndSettle();

      // 验证是否显示了开发中的消息
      expect(find.text('可点击操作 功能开发中...'), findsOneWidget);
    });

    testWidgets('should handle long press on action',
        (WidgetTester tester) async {
      final testAction = QuickAction(
        id: 'test_long_press',
        title: '长按操作',
        description: '测试长按',
        icon: Icons.touch_app,
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              QuickAccessState(
                allActions: [testAction],
                recommendedActions: [testAction],
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 长按操作
      await tester.longPress(find.text('长按操作'));
      await tester.pumpAndSettle();

      // 验证是否显示了底部菜单
      expect(find.text('执行'), findsOneWidget);
      expect(find.text('置顶'), findsOneWidget);
    });

    testWidgets('should handle workflow tap', (WidgetTester tester) async {
      final testWorkflow = Workflow(
        id: 'test_workflow_tap',
        name: '可点击工作流',
        description: '测试工作流点击',
        icon: Icons.alt_route,
        color: Colors.orange,
        steps: [],
        createdAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              QuickAccessState(
                workflows: [testWorkflow],
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 点击工作流
      await tester.tap(find.text('可点击工作流'));
      await tester.pumpAndSettle();

      // 验证是否显示了工作流执行消息
      expect(find.text('正在执行工作流: 可点击工作流'), findsOneWidget);
    });

    testWidgets('should handle menu actions', (WidgetTester tester) async {
      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              const QuickAccessState(),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 点击菜单按钮
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 验证菜单项
      expect(find.text('自定义'), findsOneWidget);
      expect(find.text('刷新'), findsOneWidget);
      expect(find.text('查看全部'), findsOneWidget);

      // 点击自定义
      await tester.tap(find.text('自定义'));
      await tester.pumpAndSettle();

      expect(find.text('自定义功能开发中...'), findsOneWidget);
    });

    testWidgets('should display empty state when no recent actions',
        (WidgetTester tester) async {
      container = ProviderContainer(
        overrides: [
          quickAccessProvider.overrideWith((ref) {
            return TestQuickAccessNotifier(
              const QuickAccessState(
                allActions: [],
                recommendedActions: [],
                recentActions: [],
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('暂无最近活动'), findsOneWidget);
    });
  });
}

/// 测试用的 QuickAccessNotifier
class TestQuickAccessNotifier extends QuickAccessNotifier {
  final QuickAccessState _testState;

  TestQuickAccessNotifier(this._testState) : super() {
    state = _testState;
  }

  @override
  Future<void> executeAction(QuickAction action) async {
    // 测试实现：不做实际操作
  }

  @override
  Future<void> executeWorkflow(Workflow workflow) async {
    // 测试实现：不做实际操作
  }

  @override
  void toggleActionPin(String actionId) {
    // 测试实现：不做实际操作
  }

  @override
  Future<void> refresh() async {
    // 测试实现：不做实际操作
  }
}
