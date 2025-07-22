/*
---------------------------------------------------------------
File name:          creative_workshop_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        Creative Workshop 主测试入口
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6 - 重构为插件管理系统测试;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_registry.dart';

void main() {
  group('Creative Workshop Core Tests', () {
    test('should export main classes', () {
      // 验证主要类是否正确导出
      expect(PluginManager.instance, isNotNull);
      expect(PluginRegistry.instance, isNotNull);
    });

    test('should have correct enum values', () {
      // 验证枚举值
      expect(PluginState.values.length, 12);
      expect(PluginPermission.values.length, 8);

      // 验证特定枚举值
      expect(PluginState.values.contains(PluginState.enabled), isTrue);
      expect(PluginState.values.contains(PluginState.disabled), isTrue);
      expect(PluginState.values.contains(PluginState.installed), isTrue);

      expect(PluginPermission.values.contains(PluginPermission.fileSystem),
          isTrue);
      expect(
          PluginPermission.values.contains(PluginPermission.network), isTrue);
      expect(PluginPermission.values.contains(PluginPermission.camera), isTrue);
    });
  });

  group('Creative Workshop Singleton Tests', () {
    test('PluginManager should be singleton', () {
      final instance1 = PluginManager.instance;
      final instance2 = PluginManager.instance;
      expect(instance1, same(instance2));
    });

    test('PluginRegistry should be singleton', () {
      final instance1 = PluginRegistry.instance;
      final instance2 = PluginRegistry.instance;
      expect(instance1, same(instance2));
    });
  });

  group('Creative Workshop Permission Tests', () {
    test('should have correct permission display names', () {
      expect(PluginPermission.fileSystem.displayName, '文件系统访问');
      expect(PluginPermission.network.displayName, '网络访问');
      expect(PluginPermission.notifications.displayName, '系统通知');
      expect(PluginPermission.clipboard.displayName, '剪贴板访问');
      expect(PluginPermission.camera.displayName, '相机访问');
      expect(PluginPermission.microphone.displayName, '麦克风访问');
      expect(PluginPermission.location.displayName, '位置信息');
      expect(PluginPermission.deviceInfo.displayName, '设备信息');
    });
  });
}
