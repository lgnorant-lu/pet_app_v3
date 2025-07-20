/*
---------------------------------------------------------------
File name:          settings_tile_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        SettingsTile组件测试 - UI组件功能验证
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app_v3/ui/pages/settings/widgets/settings_tile.dart';
import 'package:pet_app_v3/core/models/settings_models.dart';

void main() {
  group('SettingsTile Tests', () {
    group('基础组件测试', () {
      testWidgets('应该显示基本设置项', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile(
                title: '测试标题',
                subtitle: '测试副标题',
                leading: Icons.settings,
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('测试标题'), findsOneWidget);
        expect(find.text('测试副标题'), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('应该响应点击事件', (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile(
                title: '可点击项',
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SettingsTile));
        expect(tapped, isTrue);
      });
    });

    group('开关设置项测试', () {
      testWidgets('应该显示开关设置项', (WidgetTester tester) async {
        bool switchValue = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile.switchTile(
                title: '开关设置',
                subtitle: '开关描述',
                value: switchValue,
                onChanged: (value) {
                  switchValue = value;
                },
              ),
            ),
          ),
        );

        expect(find.text('开关设置'), findsOneWidget);
        expect(find.text('开关描述'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isFalse);
      });

      testWidgets('应该能够切换开关状态', (WidgetTester tester) async {
        bool switchValue = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: SettingsTile.switchTile(
                    title: '开关设置',
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );

        await tester.tap(find.byType(Switch));
        await tester.pump();

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      });
    });

    group('选择设置项测试', () {
      testWidgets('应该显示选择设置项', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile.selection<AppThemeMode>(
                title: '主题选择',
                subtitle: '当前主题',
                value: AppThemeMode.auto,
                options: const [
                  SelectionOption(value: AppThemeMode.light, title: '浅色主题'),
                  SelectionOption(value: AppThemeMode.dark, title: '深色主题'),
                  SelectionOption(value: AppThemeMode.auto, title: '自动主题'),
                ],
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.text('主题选择'), findsOneWidget);
        expect(find.text('当前主题'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });
    });

    group('滑块设置项测试', () {
      testWidgets('应该显示滑块设置项', (WidgetTester tester) async {
        double sliderValue = 50.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile.slider(
                title: '音量设置',
                subtitle: '当前音量: ${sliderValue.round()}',
                value: sliderValue,
                min: 0.0,
                max: 100.0,
                onChanged: (value) {
                  sliderValue = value;
                },
              ),
            ),
          ),
        );

        expect(find.text('音量设置'), findsOneWidget);
        expect(find.text('当前音量: 50'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);

        final sliderWidget = tester.widget<Slider>(find.byType(Slider));
        expect(sliderWidget.value, equals(50.0));
        expect(sliderWidget.min, equals(0.0));
        expect(sliderWidget.max, equals(100.0));
      });
    });

    group('文本输入设置项测试', () {
      testWidgets('应该显示文本输入设置项', (WidgetTester tester) async {
        String textValue = '初始值';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile.textField(
                title: '用户名设置',
                subtitle: '输入用户名',
                value: textValue,
                onChanged: (value) {
                  textValue = value;
                },
              ),
            ),
          ),
        );

        expect(find.text('用户名设置'), findsOneWidget);
        expect(find.text('输入用户名'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });
  });

  group('SelectionOption Tests', () {
    test('应该正确创建选择选项', () {
      const option = SelectionOption<String>(
        value: 'test_value',
        title: '测试选项',
        subtitle: '测试描述',
      );

      expect(option.value, equals('test_value'));
      expect(option.title, equals('测试选项'));
      expect(option.subtitle, equals('测试描述'));
    });

    test('应该支持无副标题的选项', () {
      const option = SelectionOption<int>(value: 42, title: '数字选项');

      expect(option.value, equals(42));
      expect(option.title, equals('数字选项'));
      expect(option.subtitle, isNull);
    });
  });
}
