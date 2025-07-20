/*
---------------------------------------------------------------
File name:          pet_creation_wizard_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠创建向导测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../lib/ui/pages/pet/pet_creation_wizard.dart';

void main() {
  group('PetCreationWizard Tests', () {
    testWidgets('应该显示创建向导', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 验证页面标题
      expect(find.text('创建桌宠'), findsOneWidget);
      
      // 验证进度指示器
      expect(find.text('1'), findsOneWidget);
      
      // 验证第一步内容
      expect(find.text('给你的桌宠起个名字'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('应该能够输入桌宠名字', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 输入桌宠名字
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.pump();

      // 验证输入内容
      expect(find.text('小橘'), findsOneWidget);
    });

    testWidgets('应该能够进行下一步', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 输入桌宠名字
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.pump();

      // 点击下一步
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 验证进入第二步
      expect(find.text('选择桌宠类型'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('应该能够选择桌宠类型', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 进入第二步
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 选择猫咪类型
      await tester.tap(find.text('猫咪'));
      await tester.pump();

      // 验证选择状态
      expect(find.text('猫咪'), findsOneWidget);
    });

    testWidgets('应该能够返回上一步', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 进入第二步
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 点击上一步
      await tester.tap(find.text('上一步'));
      await tester.pumpAndSettle();

      // 验证返回第一步
      expect(find.text('给你的桌宠起个名字'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('应该能够完成创建流程', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 第一步：输入名字
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 第二步：选择类型
      await tester.tap(find.text('猫咪'));
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 第三步：自定义外观
      expect(find.text('自定义外观'), findsOneWidget);
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 第四步：确认创建
      expect(find.text('确认创建'), findsOneWidget);
      expect(find.text('小橘'), findsOneWidget);
    });

    testWidgets('下一步按钮应该根据输入状态启用/禁用', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 初始状态下一步按钮应该禁用
      final nextButton = find.text('下一步');
      expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNull);

      // 输入名字后下一步按钮应该启用
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNotNull);
    });

    testWidgets('应该显示进度指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PetCreationWizard(),
          ),
        ),
      );

      // 验证第一步进度
      expect(find.text('1'), findsOneWidget);

      // 进入第二步
      await tester.enterText(find.byType(TextField), '小橘');
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 验证第二步进度
      expect(find.text('2'), findsOneWidget);
    });
  });
}
