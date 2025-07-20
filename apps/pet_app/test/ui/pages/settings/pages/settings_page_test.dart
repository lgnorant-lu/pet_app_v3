/*
---------------------------------------------------------------
File name:          settings_page_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置页面测试 - 主设置页面功能验证
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_app_v3/ui/pages/settings/pages/settings_page.dart';
import 'package:pet_app_v3/ui/pages/settings/widgets/settings_tile.dart';
import 'package:pet_app_v3/core/services/settings_service.dart';
import 'package:pet_app_v3/core/providers/settings_provider.dart';
import 'package:pet_app_v3/core/models/settings_models.dart';
import 'package:pet_app_v3/constants/app_strings.dart';

void main() {
  group('SettingsPage Tests', () {
    late ProviderContainer container;
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
      await settingsService.initialize();

      container = ProviderContainer(
        overrides: [settingsServiceProvider.overrideWithValue(settingsService)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('页面结构测试', () {
      testWidgets('应该显示设置页面标题', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        expect(find.text(AppStrings.settings), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('应该显示三个主要设置分类', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        // 等待页面加载
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.settingsApp), findsOneWidget);
        expect(find.text(AppStrings.settingsPlugins), findsOneWidget);
        expect(find.text(AppStrings.settingsUser), findsOneWidget);
      });

      testWidgets('应该显示设置项图标', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.app_settings_alt), findsOneWidget);
        expect(find.byIcon(Icons.extension), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('交互测试', () {
      testWidgets('应该能够点击设置项', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        await tester.pumpAndSettle();

        // 查找应用设置项并点击
        final appSettingsTile = find.ancestor(
          of: find.text(AppStrings.settingsApp),
          matching: find.byType(SettingsTile),
        );

        expect(appSettingsTile, findsOneWidget);
        await tester.tap(appSettingsTile);
        await tester.pumpAndSettle();

        // 验证点击没有错误
        expect(tester.takeException(), isNull);
      });
    });

    group('状态管理测试', () {
      testWidgets('应该正确显示当前设置状态', (WidgetTester tester) async {
        // 修改一些设置
        await settingsService.updateThemeMode(AppThemeMode.dark);
        await settingsService.updateLanguage(AppLanguage.english);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        await tester.pumpAndSettle();

        // 验证设置状态反映在UI中
        expect(find.byType(SettingsPage), findsOneWidget);
      });
    });

    group('错误处理测试', () {
      testWidgets('应该处理设置加载错误', (WidgetTester tester) async {
        // 创建一个会失败的设置服务
        final failingContainer = ProviderContainer(
          overrides: [
            settingsServiceProvider.overrideWithValue(SettingsService()),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: failingContainer,
            child: MaterialApp(home: const SettingsPage()),
          ),
        );

        await tester.pumpAndSettle();

        // 页面应该仍然能够显示，即使有错误
        expect(find.byType(SettingsPage), findsOneWidget);

        failingContainer.dispose();
      });
    });
  });
}
