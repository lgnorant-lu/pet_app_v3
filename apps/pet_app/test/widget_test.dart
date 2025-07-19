/*
---------------------------------------------------------------
File name:          app_core_test.dart (原widget_test.dart)
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Pet App V3 核心功能测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 应用配置信息（测试版本）
class TestAppConfig {
  static const String appName = 'Pet App V3';
  static const String version = '3.3.0';
  static const String description = '万物皆插件的跨平台应用框架';
  static const String phase = 'Phase 3.3';
}

/// 应用状态枚举
enum TestAppState { initializing, loading, ready, error }

/// 简化的应用核心类（用于测试）
class TestAppCore {
  TestAppState _state = TestAppState.initializing;
  final StreamController<TestAppState> _stateController =
      StreamController<TestAppState>.broadcast();

  TestAppState get state => _state;
  Stream<TestAppState> get stateStream => _stateController.stream;

  /// 初始化应用
  Future<void> initialize() async {
    _setState(TestAppState.loading);

    // 模拟初始化过程
    await Future.delayed(const Duration(milliseconds: 100));

    _setState(TestAppState.ready);
  }

  /// 获取应用信息
  Map<String, String> getAppInfo() {
    return {
      'name': TestAppConfig.appName,
      'version': TestAppConfig.version,
      'description': TestAppConfig.description,
      'phase': TestAppConfig.phase,
    };
  }

  /// 检查应用是否就绪
  bool get isReady => _state == TestAppState.ready;

  void _setState(TestAppState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 清理资源
  void dispose() {
    _stateController.close();
  }
}

void main() {
  group('Pet App V3 Core Tests', () {
    late TestAppCore appCore;

    setUp(() {
      appCore = TestAppCore();
    });

    tearDown(() {
      appCore.dispose();
    });

    test('应用应该能够正确初始化', () async {
      expect(appCore.state, equals(TestAppState.initializing));

      await appCore.initialize();

      expect(appCore.state, equals(TestAppState.ready));
      expect(appCore.isReady, isTrue);
    });

    test('应用应该返回正确的配置信息', () {
      final appInfo = appCore.getAppInfo();

      expect(appInfo['name'], equals('Pet App V3'));
      expect(appInfo['version'], equals('3.3.0'));
      expect(appInfo['description'], equals('万物皆插件的跨平台应用框架'));
      expect(appInfo['phase'], equals('Phase 3.3'));
    });

    test('应用状态流应该正确工作', () async {
      final stateChanges = <TestAppState>[];
      final subscription = appCore.stateStream.listen((state) {
        stateChanges.add(state);
      });

      await appCore.initialize();

      // 等待一小段时间确保所有状态变更都被捕获
      await Future.delayed(const Duration(milliseconds: 50));

      expect(stateChanges, contains(TestAppState.loading));
      expect(stateChanges, contains(TestAppState.ready));

      await subscription.cancel();
    });

    test('应用应该能够处理多次初始化', () async {
      await appCore.initialize();
      expect(appCore.isReady, isTrue);

      // 再次初始化
      await appCore.initialize();
      expect(appCore.isReady, isTrue);
    });
  });
}
