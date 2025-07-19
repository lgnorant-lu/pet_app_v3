/*
---------------------------------------------------------------
File name:          tool_toolbar_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        工具栏UI组件单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - 工具栏测试覆盖;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/ui/toolbar/tool_toolbar.dart';

void main() {
  group('Tool Toolbar Tests', () {
    // ToolToolbar不需要外部依赖，使用内部单例
    // 所有测试都使用const ToolToolbar()构造函数

    testWidgets('应该显示工具栏组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byType(ToolToolbar), findsOneWidget);
    });

    testWidgets('应该显示画笔工具按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.brush), findsOneWidget);
    });

    testWidgets('应该显示铅笔工具按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('应该显示形状工具按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.crop_square), findsWidgets);
    });

    testWidgets('应该显示清空画布按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsWidgets);
    });

    testWidgets('应该显示撤销按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    testWidgets('应该显示重做按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.redo), findsOneWidget);
    });

    testWidgets('点击画笔工具应该显示反馈', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      // 点击画笔工具按钮
      await tester.tap(find.byIcon(Icons.brush));
      await tester.pump();

      // 验证没有异常抛出
      expect(tester.takeException(), isNull);
    });

    testWidgets('点击铅笔工具应该显示反馈', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(),
          ),
        ),
      );

      // 点击铅笔工具按钮
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // 验证没有异常抛出
      expect(tester.takeException(), isNull);
    });

    testWidgets('点击形状工具应该显示对话框', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(
              orientation: ToolbarOrientation.vertical,
            ),
          ),
        ),
      );

      // 点击形状工具按钮（垂直布局中的矩形按钮会显示对话框）
      await tester.tap(find.byIcon(Icons.crop_square).first);
      await tester.pumpAndSettle();

      // 验证对话框出现
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('选择形状工具'), findsOneWidget);
    });

    testWidgets('形状工具对话框应该显示工具选项', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(
              orientation: ToolbarOrientation.vertical,
            ),
          ),
        ),
      );

      // 打开形状工具对话框
      await tester.tap(find.byIcon(Icons.crop_square).first);
      await tester.pumpAndSettle();

      // 验证工具选项
      expect(find.text('矩形工具'), findsOneWidget);
      expect(find.text('圆形工具'), findsOneWidget);
      expect(find.text('直线工具'), findsOneWidget);
    });

    testWidgets('基本功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolToolbar(
              orientation: ToolbarOrientation.vertical,
            ),
          ),
        ),
      );

      // 验证基本按钮存在且可点击
      expect(find.byIcon(Icons.brush), findsWidgets);
      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.crop_square), findsWidgets);
      expect(find.byIcon(Icons.clear), findsWidgets);
      expect(find.byIcon(Icons.undo), findsWidgets);
      expect(find.byIcon(Icons.redo), findsWidgets);
    });
  });
}
