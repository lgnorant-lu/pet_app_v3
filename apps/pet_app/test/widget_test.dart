/*
---------------------------------------------------------------
File name:          widget_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Pet App V3 Widget测试 - Phase 3.1
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app_v3/app.dart';

void main() {
  group('Pet App V3 Widget Tests', () {
    testWidgets('App should start and show splash screen', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const PetAppV3());

      // Wait for splash screen to appear
      await tester.pump();

      // Verify that splash screen elements are present
      expect(find.text('Pet App V3'), findsOneWidget);
      expect(find.text('万物皆插件的跨平台应用框架'), findsOneWidget);
      expect(find.text('正在启动 Pet App V3...'), findsOneWidget);

      // 清理所有pending timers
      await tester.pumpAndSettle();
    });

    testWidgets('App should show version information', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const PetAppV3());

      // Wait for splash screen to appear
      await tester.pump();

      // Verify version information
      expect(find.text('Version 3.1.0 - Phase 3.1'), findsOneWidget);

      // 清理所有pending timers
      await tester.pumpAndSettle();
    });
  });
}
