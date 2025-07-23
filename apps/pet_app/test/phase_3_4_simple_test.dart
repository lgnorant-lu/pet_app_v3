/*
---------------------------------------------------------------
File name:          phase_3_4_simple_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        Phase 3.4 简单测试 - 验证开发者工具基础功能
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

void main() {
  group('Phase 3.4 开发者工具简单测试', () {
    testWidgets('DeveloperPlatformPage能正常创建', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeveloperPlatformPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeveloperPlatformPage), findsOneWidget);
    });

    testWidgets('PublishManagerTab能正常创建', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PublishManagerTab(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PublishManagerTab), findsOneWidget);
    });

    testWidgets('PluginDevelopmentTab能正常创建', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PluginDevelopmentTab(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PluginDevelopmentTab), findsOneWidget);
    });

    testWidgets('MingCliIntegrationTab能正常创建', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MingCliIntegrationTab(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MingCliIntegrationTab), findsOneWidget);
    });

    testWidgets('ProjectManagerTab能正常创建', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProjectManagerTab(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProjectManagerTab), findsOneWidget);
    });
  });
}
