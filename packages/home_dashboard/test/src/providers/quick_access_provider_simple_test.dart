/*
---------------------------------------------------------------
File name:          quick_access_provider_simple_test.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        简化的快速访问提供者测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_dashboard/src/models/quick_action.dart';
import 'package:home_dashboard/src/providers/quick_access_provider.dart';

void main() {
  setUpAll(() {
    // 初始化测试绑定
    TestWidgetsFlutterBinding.ensureInitialized();

    // 模拟 SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('QuickAccessProvider Simple Tests', () {
    test('should create provider state without errors', () {
      // 只测试状态创建，不触发异步初始化
      expect(() => const QuickAccessState(), returnsNormally);
    });

    test('should have valid initial state structure', () {
      const state = QuickAccessState();

      expect(state, isA<QuickAccessState>());
      expect(state.allActions, isA<List<QuickAction>>());
      expect(state.workflows, isA<List<Workflow>>());
      expect(state.isLoading, isFalse); // 默认状态不是加载中
      expect(state.error, isNull);
    });

    test('should handle state updates correctly', () {
      const initialState = QuickAccessState();
      final actions = <QuickAction>[
        QuickAction(
          id: 'test_action',
          title: '测试操作',
          description: '测试描述',
          icon: Icons.flash_on,
          color: Colors.blue,
          type: QuickActionType.workflow,
          priority: QuickActionPriority.normal,
          isEnabled: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          tags: const ['测试'],
          onTap: () {},
        ),
      ];

      final updatedState = initialState.copyWith(
        allActions: actions,
        isLoading: false,
      );

      expect(updatedState.allActions.length, equals(1));
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.allActions.first.title, equals('测试操作'));
    });

    test('should handle error state correctly', () {
      const initialState = QuickAccessState();
      const errorMessage = '测试错误';

      final errorState = initialState.copyWith(
        isLoading: false,
        error: errorMessage,
      );

      expect(errorState.isLoading, isFalse);
      expect(errorState.error, equals(errorMessage));
    });
  });
}
