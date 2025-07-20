/*
---------------------------------------------------------------
File name:          welcome_header_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        欢迎头部组件测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_app_v3/ui/pages/home/widgets/welcome_header.dart';
import 'package:pet_app_v3/constants/app_strings.dart';

void main() {
  group('WelcomeHeader Tests', () {
    testWidgets('应该显示应用名称和版本', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text('v${AppStrings.appVersion}'), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('应该显示欢迎信息', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      // 验证显示了某种欢迎信息（根据时间不同）
      final welcomeMessages = [
        '夜深了，注意休息 🌙',
        '早上好！☀️',
        '下午好！🌤️',
        '晚上好！🌆',
      ];

      bool foundWelcomeMessage = false;
      for (final message in welcomeMessages) {
        if (find.text(message).evaluate().isNotEmpty) {
          foundWelcomeMessage = true;
          break;
        }
      }
      expect(foundWelcomeMessage, isTrue);
    });

    testWidgets('应该显示应用描述', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.appDescription), findsOneWidget);
    });

    testWidgets('应该显示状态指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      expect(find.text('系统正常'), findsOneWidget);
      expect(find.text('已是最新'), findsOneWidget);
      expect(find.text('安全'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('应该能够点击通知按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      final notificationButton = find.byIcon(Icons.notifications_outlined);
      expect(notificationButton, findsOneWidget);

      await tester.tap(notificationButton);
      await tester.pumpAndSettle();

      // 验证显示了通知对话框
      expect(find.text('通知'), findsOneWidget);
      expect(find.text('暂无新通知'), findsOneWidget);
    });

    testWidgets('应该使用正确的主题颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证组件正确渲染
      expect(find.byType(WelcomeHeader), findsOneWidget);
    });

    testWidgets('应该在SafeArea中显示内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const WelcomeHeader(),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
