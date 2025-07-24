/*
---------------------------------------------------------------
File name:          quick_action_test.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        快速操作模型测试 - Phase 5.0.7.1
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_dashboard/src/models/quick_action.dart';

void main() {
  group('QuickAction', () {
    late QuickAction testAction;
    late DateTime testTime;

    setUp(() {
      testTime = DateTime.now();
      testAction = QuickAction(
        id: 'test_action',
        title: '测试操作',
        description: '这是一个测试操作',
        icon: Icons.science,
        color: Colors.blue,
        createdAt: testTime,
      );
    });

    test('should create QuickAction with required fields', () {
      expect(testAction.id, equals('test_action'));
      expect(testAction.title, equals('测试操作'));
      expect(testAction.description, equals('这是一个测试操作'));
      expect(testAction.icon, equals(Icons.science));
      expect(testAction.color, equals(Colors.blue));
      expect(testAction.createdAt, equals(testTime));
    });

    test('should have default values for optional fields', () {
      expect(testAction.type, equals(QuickActionType.module));
      expect(testAction.priority, equals(QuickActionPriority.normal));
      expect(testAction.permission, equals(QuickActionPermission.public));
      expect(testAction.isEnabled, isTrue);
      expect(testAction.isVisible, isTrue);
      expect(testAction.usageCount, equals(0));
      expect(testAction.lastUsed, isNull);
      expect(testAction.tags, isEmpty);
      expect(testAction.metadata, isEmpty);
    });

    test('should copy with new values', () {
      final copiedAction = testAction.copyWith(
        title: '新标题',
        usageCount: 5,
      );

      expect(copiedAction.id, equals(testAction.id));
      expect(copiedAction.title, equals('新标题'));
      expect(copiedAction.usageCount, equals(5));
      expect(copiedAction.description, equals(testAction.description));
    });

    test('should increment usage count', () {
      final incrementedAction = testAction.incrementUsage();

      expect(incrementedAction.usageCount, equals(1));
      expect(incrementedAction.lastUsed, isNotNull);
      expect(
          incrementedAction.lastUsed!.isAfter(testTime) ||
              incrementedAction.lastUsed!.isAtSameMomentAs(testTime),
          isTrue);
    });

    test('should check availability correctly', () {
      expect(testAction.isAvailable, isTrue);

      final disabledAction = testAction.copyWith(isEnabled: false);
      expect(disabledAction.isAvailable, isFalse);

      final hiddenAction = testAction.copyWith(isVisible: false);
      expect(hiddenAction.isAvailable, isFalse);
    });

    test('should calculate priority weight correctly', () {
      expect(testAction.priorityWeight, equals(2)); // normal priority

      final lowPriorityAction =
          testAction.copyWith(priority: QuickActionPriority.low);
      expect(lowPriorityAction.priorityWeight, equals(1));

      final highPriorityAction =
          testAction.copyWith(priority: QuickActionPriority.high);
      expect(highPriorityAction.priorityWeight, equals(3));

      final pinnedAction =
          testAction.copyWith(priority: QuickActionPriority.pinned);
      expect(pinnedAction.priorityWeight, equals(4));
    });

    test('should calculate recommendation score correctly', () {
      // 基础分数：优先级(2) * 10 = 20
      expect(testAction.calculateRecommendationScore(), equals(20.0));

      // 增加使用次数：20 + (5 * 2) = 30
      final usedAction = testAction.copyWith(usageCount: 5);
      expect(usedAction.calculateRecommendationScore(), equals(30.0));

      // 最近使用：30 + 20 = 50
      final recentlyUsedAction = usedAction.copyWith(
        lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(recentlyUsedAction.calculateRecommendationScore(), equals(50.0));
    });

    test('should handle equality correctly', () {
      final sameAction = QuickAction(
        id: 'test_action',
        title: '不同标题',
        description: '不同描述',
        icon: Icons.star,
        color: Colors.red,
        createdAt: DateTime.now(),
      );

      expect(testAction, equals(sameAction)); // 只比较ID
      expect(testAction.hashCode, equals(sameAction.hashCode));

      final differentAction = testAction.copyWith(id: 'different_id');
      expect(testAction, isNot(equals(differentAction)));
    });

    test('should convert to string correctly', () {
      final stringRepresentation = testAction.toString();
      expect(stringRepresentation, contains('test_action'));
      expect(stringRepresentation, contains('测试操作'));
      expect(stringRepresentation, contains('QuickActionType.module'));
      expect(stringRepresentation, contains('QuickActionPriority.normal'));
    });
  });

  group('Workflow', () {
    late Workflow testWorkflow;
    late DateTime testTime;

    setUp(() {
      testTime = DateTime.now();
      testWorkflow = Workflow(
        id: 'test_workflow',
        name: '测试工作流',
        description: '这是一个测试工作流',
        icon: Icons.alt_route,
        color: Colors.green,
        steps: [
          const WorkflowStep(
            id: 'step1',
            name: '步骤1',
            action: 'navigate',
            parameters: {'route': '/test'},
          ),
        ],
        createdAt: testTime,
      );
    });

    test('should create Workflow with required fields', () {
      expect(testWorkflow.id, equals('test_workflow'));
      expect(testWorkflow.name, equals('测试工作流'));
      expect(testWorkflow.description, equals('这是一个测试工作流'));
      expect(testWorkflow.icon, equals(Icons.alt_route));
      expect(testWorkflow.color, equals(Colors.green));
      expect(testWorkflow.steps, hasLength(1));
      expect(testWorkflow.createdAt, equals(testTime));
    });

    test('should have default values for optional fields', () {
      expect(testWorkflow.isEnabled, isTrue);
      expect(testWorkflow.usageCount, equals(0));
    });

    test('should copy with new values', () {
      final copiedWorkflow = testWorkflow.copyWith(
        name: '新工作流',
        usageCount: 3,
      );

      expect(copiedWorkflow.id, equals(testWorkflow.id));
      expect(copiedWorkflow.name, equals('新工作流'));
      expect(copiedWorkflow.usageCount, equals(3));
      expect(copiedWorkflow.description, equals(testWorkflow.description));
    });
  });

  group('WorkflowStep', () {
    test('should create WorkflowStep with required fields', () {
      const step = WorkflowStep(
        id: 'test_step',
        name: '测试步骤',
        action: 'test_action',
      );

      expect(step.id, equals('test_step'));
      expect(step.name, equals('测试步骤'));
      expect(step.action, equals('test_action'));
      expect(step.parameters, isEmpty);
      expect(step.isRequired, isTrue);
    });

    test('should create WorkflowStep with optional fields', () {
      const step = WorkflowStep(
        id: 'test_step',
        name: '测试步骤',
        action: 'test_action',
        parameters: {'key': 'value'},
        isRequired: false,
      );

      expect(step.parameters, equals({'key': 'value'}));
      expect(step.isRequired, isFalse);
    });
  });

  group('Enums', () {
    test('QuickActionType should have correct values', () {
      expect(QuickActionType.values, hasLength(4));
      expect(QuickActionType.values, contains(QuickActionType.module));
      expect(QuickActionType.values, contains(QuickActionType.workflow));
      expect(QuickActionType.values, contains(QuickActionType.system));
      expect(QuickActionType.values, contains(QuickActionType.custom));
    });

    test('QuickActionPriority should have correct values', () {
      expect(QuickActionPriority.values, hasLength(4));
      expect(QuickActionPriority.values, contains(QuickActionPriority.low));
      expect(QuickActionPriority.values, contains(QuickActionPriority.normal));
      expect(QuickActionPriority.values, contains(QuickActionPriority.high));
      expect(QuickActionPriority.values, contains(QuickActionPriority.pinned));
    });

    test('QuickActionPermission should have correct values', () {
      expect(QuickActionPermission.values, hasLength(4));
      expect(
          QuickActionPermission.values, contains(QuickActionPermission.public));
      expect(QuickActionPermission.values,
          contains(QuickActionPermission.authenticated));
      expect(QuickActionPermission.values,
          contains(QuickActionPermission.restricted));
      expect(
          QuickActionPermission.values, contains(QuickActionPermission.admin));
    });
  });
}
