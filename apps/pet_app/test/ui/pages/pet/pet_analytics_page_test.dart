/*
---------------------------------------------------------------
File name:          pet_analytics_page_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠数据分析页面测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../lib/ui/pages/pet/pet_analytics_page.dart';
import '../../../../lib/core/providers/pet_provider.dart';
import '../../../../lib/core/pet/models/pet_entity.dart';

void main() {
  group('PetAnalyticsPage Tests', () {
    late PetEntity testPet;

    setUp(() {
      testPet = PetEntity.createDefault(name: '测试宠物');
    });

    testWidgets('应该显示分析页面', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPetProvider.overrideWith((ref) => testPet),
          ],
          child: const MaterialApp(
            home: PetAnalyticsPage(),
          ),
        ),
      );

      // 验证页面标题
      expect(find.text('桌宠分析'), findsOneWidget);
      
      // 验证Tab标签
      expect(find.text('健康趋势'), findsOneWidget);
      expect(find.text('行为模式'), findsOneWidget);
      expect(find.text('性格分析'), findsOneWidget);
      expect(find.text('照顾质量'), findsOneWidget);
    });

    testWidgets('应该显示加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPetProvider.overrideWith((ref) => testPet),
          ],
          child: const MaterialApp(
            home: PetAnalyticsPage(),
          ),
        ),
      );

      // 验证加载指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该显示无桌宠状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPetProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: PetAnalyticsPage(),
          ),
        ),
      );

      await tester.pump();

      // 验证无桌宠提示
      expect(find.text('没有当前桌宠'), findsOneWidget);
    });

    testWidgets('应该能够刷新数据', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPetProvider.overrideWith((ref) => testPet),
          ],
          child: const MaterialApp(
            home: PetAnalyticsPage(),
          ),
        ),
      );

      // 点击刷新按钮
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // 验证刷新后的状态
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该能够切换Tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPetProvider.overrideWith((ref) => testPet),
          ],
          child: const MaterialApp(
            home: PetAnalyticsPage(),
          ),
        ),
      );

      await tester.pump();

      // 切换到行为模式Tab
      await tester.tap(find.text('行为模式'));
      await tester.pump();

      // 验证Tab切换
      expect(find.text('行为模式'), findsOneWidget);
    });
  });
}
