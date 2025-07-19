/*
---------------------------------------------------------------
File name:          drawing_tools_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        绘画工具单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - 绘画工具测试覆盖;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';
import 'package:creative_workshop/src/core/tools/drawing_tools.dart';

void main() {
  group('Drawing Tools Tests', () {
    group('SimpleBrushTool Tests', () {
      late SimpleBrushTool brushTool;

      setUp(() {
        brushTool = SimpleBrushTool();
      });

      tearDown(() {
        brushTool.dispose();
      });

      test('应该有正确的插件信息', () {
        expect(brushTool.id, equals('simple_brush_tool'));
        expect(brushTool.name, equals('画笔工具'));
        expect(brushTool.version, equals('1.0.0'));
        expect(brushTool.author, equals('Creative Workshop'));
        expect(brushTool.description, equals('用于自由绘画的画笔工具'));
      });

      test('应该支持所有平台', () {
        expect(
            brushTool.supportedPlatforms, contains(SupportedPlatform.android));
        expect(brushTool.supportedPlatforms, contains(SupportedPlatform.ios));
        expect(brushTool.supportedPlatforms, contains(SupportedPlatform.web));
        expect(
            brushTool.supportedPlatforms, contains(SupportedPlatform.windows));
        expect(brushTool.supportedPlatforms, contains(SupportedPlatform.macos));
        expect(brushTool.supportedPlatforms, contains(SupportedPlatform.linux));
      });

      test('应该有正确的权限要求', () {
        expect(brushTool.requiredPermissions, contains(Permission.storage));
      });

      test('应该没有依赖', () {
        expect(brushTool.dependencies, isEmpty);
      });

      group('生命周期测试', () {
        test('应该能够正常初始化', () async {
          expect(() => brushTool.initialize(), returnsNormally);
        });

        test('应该能够启动和停止', () async {
          await brushTool.initialize();
          expect(() => brushTool.start(), returnsNormally);
          expect(() => brushTool.stop(), returnsNormally);
        });

        test('应该能够暂停和恢复', () async {
          await brushTool.initialize();
          await brushTool.start();
          expect(() => brushTool.pause(), returnsNormally);
          expect(() => brushTool.resume(), returnsNormally);
        });
      });

      group('工具功能测试', () {
        test('应该能够激活和停用', () async {
          final result = await brushTool.activate();
          expect(result.success, isTrue);

          final deactivateResult = await brushTool.deactivate();
          expect(deactivateResult.success, isTrue);
        });

        test('应该能够执行操作', () async {
          final result = await brushTool.execute({});
          expect(result.success, isTrue);
        });

        test('应该有正确的鼠标光标', () {
          expect(brushTool.getCursor(), equals(SystemMouseCursors.precise));
        });
      });

      group('绘画功能测试', () {
        test('应该能够开始绘画', () async {
          const position = Offset(10, 10);
          final result = await brushTool.startDrawing(position);
          expect(result.success, isTrue);
        });

        test('应该能够更新绘画', () async {
          const startPosition = Offset(10, 10);
          const updatePosition = Offset(20, 20);

          await brushTool.startDrawing(startPosition);
          final result = await brushTool.updateDrawing(updatePosition);
          expect(result.success, isTrue);
        });

        test('应该能够结束绘画', () async {
          const startPosition = Offset(10, 10);
          const endPosition = Offset(30, 30);

          await brushTool.startDrawing(startPosition);
          await brushTool.updateDrawing(const Offset(20, 20));
          final result = await brushTool.endDrawing(endPosition);
          expect(result.success, isTrue);
        });
      });

      group('画笔设置测试', () {
        test('应该能够设置画笔大小', () {
          brushTool.brushSize = 10.0;
          expect(brushTool.brushSize, equals(10.0));
        });

        test('应该能够设置画笔颜色', () {
          brushTool.brushColor = Colors.red;
          expect(brushTool.brushColor, equals(Colors.red));
        });

        test('应该能够设置画笔透明度', () {
          brushTool.brushOpacity = 0.5;
          expect(brushTool.brushOpacity, equals(0.5));
        });

        test('透明度应该被限制在0-1之间', () {
          brushTool.brushOpacity = -0.5;
          expect(brushTool.brushOpacity, equals(0.0));

          brushTool.brushOpacity = 1.5;
          expect(brushTool.brushOpacity, equals(1.0));
        });

        test('应该能够获取和设置画笔设置', () {
          final settings = {
            'size': 15.0,
            'color': Colors.blue.toARGB32(),
            'opacity': 0.8,
          };

          brushTool.setBrushSettings(settings);

          expect(brushTool.brushSize, equals(15.0));
          expect(
              brushTool.brushColor.toARGB32(), equals(Colors.blue.toARGB32()));
          expect(brushTool.brushOpacity, equals(0.8));

          final retrievedSettings = brushTool.getBrushSettings();
          expect(retrievedSettings['size'], equals(15.0));
          expect(retrievedSettings['color'], equals(Colors.blue.toARGB32()));
          expect(retrievedSettings['opacity'], equals(0.8));
        });
      });

      group('状态管理测试', () {
        test('应该能够保存和恢复工具状态', () async {
          brushTool.brushSize = 12.0;
          brushTool.brushColor = Colors.green;
          brushTool.brushOpacity = 0.7;

          final state = brushTool.getToolState();

          // 修改状态
          brushTool.brushSize = 5.0;
          brushTool.brushColor = Colors.yellow;
          brushTool.brushOpacity = 0.3;

          // 恢复状态
          await brushTool.restoreToolState(state);

          expect(brushTool.brushSize, equals(12.0));
          expect(
              brushTool.brushColor.toARGB32(), equals(Colors.green.toARGB32()));
          expect(brushTool.brushOpacity, equals(0.7));
        });
      });
    });

    group('SimplePencilTool Tests', () {
      late SimplePencilTool pencilTool;

      setUp(() {
        pencilTool = SimplePencilTool();
      });

      tearDown(() {
        pencilTool.dispose();
      });

      test('应该有正确的插件信息', () {
        expect(pencilTool.id, equals('simple_pencil_tool'));
        expect(pencilTool.name, equals('铅笔工具'));
        expect(pencilTool.version, equals('1.0.0'));
        expect(pencilTool.author, equals('Creative Workshop'));
        expect(pencilTool.description, equals('用于精细绘画的铅笔工具'));
      });

      test('应该能够设置铅笔属性', () {
        pencilTool.pencilSize = 3.0;
        expect(pencilTool.pencilSize, equals(3.0));

        pencilTool.pencilColor = Colors.black;
        expect(pencilTool.pencilColor, equals(Colors.black));
      });

      test('应该能够获取和设置铅笔设置', () {
        final settings = {
          'size': 2.5,
          'color': Colors.grey.toARGB32(),
        };

        pencilTool.setBrushSettings(settings);

        expect(pencilTool.pencilSize, equals(2.5));
        expect(
            pencilTool.pencilColor.toARGB32(), equals(Colors.grey.toARGB32()));

        final retrievedSettings = pencilTool.getBrushSettings();
        expect(retrievedSettings['size'], equals(2.5));
        expect(retrievedSettings['color'], equals(Colors.grey.toARGB32()));
      });
    });
  });
}
