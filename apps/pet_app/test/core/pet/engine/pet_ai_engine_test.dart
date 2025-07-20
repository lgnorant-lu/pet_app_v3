/*
---------------------------------------------------------------
File name:          pet_ai_engine_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠AI引擎测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/engine/pet_ai_engine.dart';
import '../../../../lib/core/pet/models/pet_entity.dart';
import '../../../../lib/core/pet/models/pet_behavior.dart';

void main() {
  group('PetAIEngine Tests', () {
    late PetAIEngine aiEngine;

    setUp(() {
      aiEngine = PetAIEngine();
      aiEngine.initialize();
    });

    group('基础功能测试', () {
      test('应该能够初始化AI引擎', () {
        expect(aiEngine, isNotNull);
      });

      test('应该能够决策下一个行为', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final behaviors = [
          PetBehavior.createDefault(
            id: 'test_behavior',
            name: '测试行为',
            priority: 5,
            tags: ['test'],
          ),
        ];
        final context = <String, dynamic>{};

        final selectedBehavior = aiEngine.decideNextBehavior(
          pet,
          behaviors,
          context,
        );

        expect(selectedBehavior, isNotNull);
        expect(selectedBehavior!.id, equals('test_behavior'));
      });

      test('空行为列表应该返回null', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final behaviors = <PetBehavior>[];
        final context = <String, dynamic>{};

        final selectedBehavior = aiEngine.decideNextBehavior(
          pet,
          behaviors,
          context,
        );

        expect(selectedBehavior, isNull);
      });
    });

    group('学习功能测试', () {
      test('应该能够从行为结果学习', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final behavior = PetBehavior.createDefault(
          id: 'learning_behavior',
          name: '学习行为',
        );

        // 记录成功的行为
        aiEngine.learnFromBehavior(pet.id, behavior, true, 0.8);

        final aiStatus = aiEngine.getAIStatus(pet.id);
        expect(aiStatus.behaviorCount, equals(1));
        expect(aiStatus.learningProgress, greaterThan(0.0));
      });

      test('应该能够获取AI状态', () {
        final pet = PetEntity.createDefault(name: '测试宠物');

        final aiStatus = aiEngine.getAIStatus(pet.id);

        expect(aiStatus.learningProgress, greaterThanOrEqualTo(0.0));
        expect(aiStatus.learningProgress, lessThanOrEqualTo(1.0));
        expect(aiStatus.behaviorCount, greaterThanOrEqualTo(0));
        expect(aiStatus.adaptationLevel, greaterThanOrEqualTo(0.0));
        expect(aiStatus.adaptationLevel, lessThanOrEqualTo(1.0));
        expect(aiStatus.preferences, isA<List<String>>());
      });

      test('应该能够重置学习数据', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final behavior = PetBehavior.createDefault(id: 'test', name: 'test');

        // 先学习一些数据
        aiEngine.learnFromBehavior(pet.id, behavior, true, 0.8);
        expect(aiEngine.getAIStatus(pet.id).behaviorCount, equals(1));

        // 重置学习数据
        aiEngine.resetLearning(pet.id);
        expect(aiEngine.getAIStatus(pet.id).behaviorCount, equals(0));
      });
    });

    group('AI记忆系统测试', () {
      test('AIMemory应该能够记录行为结果', () {
        final memory = AIMemory('test_pet');

        memory.recordBehaviorResult('test_behavior', true, 0.8);

        expect(memory.behaviorHistory.length, equals(1));
        expect(memory.getBehaviorSuccessRate('test_behavior'), equals(1.0));
        expect(memory.getBehaviorPreference('test_behavior'), greaterThan(0.5));
      });

      test('AIMemory应该能够计算成功率', () {
        final memory = AIMemory('test_pet');

        // 记录多次行为结果
        memory.recordBehaviorResult('test_behavior', true, 0.8);
        memory.recordBehaviorResult('test_behavior', false, 0.2);
        memory.recordBehaviorResult('test_behavior', true, 0.9);

        expect(
          memory.getBehaviorSuccessRate('test_behavior'),
          equals(2.0 / 3.0),
        );
      });

      test('AIMemory应该能够获取最近执行时间', () {
        final memory = AIMemory('test_pet');

        memory.recordBehaviorResult('test_behavior', true, 0.8);

        final recentExecution = memory.getRecentExecution('test_behavior');
        expect(recentExecution, isNotNull);
        expect(recentExecution, isA<DateTime>());
      });

      test('AIMemory应该能够计算学习进度', () {
        final memory = AIMemory('test_pet');

        // 初始进度应该是0
        expect(memory.learningProgress, equals(0.0));

        // 添加一些行为记录
        for (int i = 0; i < 25; i++) {
          memory.recordBehaviorResult('behavior_$i', true, 0.8);
        }

        expect(memory.learningProgress, equals(0.5)); // 25/50
      });

      test('AIMemory应该能够获取热门偏好', () {
        final memory = AIMemory('test_pet');

        memory.recordBehaviorResult('behavior_1', true, 0.9);
        memory.recordBehaviorResult('behavior_2', true, 0.7);
        memory.recordBehaviorResult('behavior_3', true, 0.5);

        final topPreferences = memory.getTopPreferences(2);
        expect(topPreferences.length, equals(2));
        expect(topPreferences.first, equals('behavior_1'));
      });
    });

    group('行为记录测试', () {
      test('BehaviorRecord应该包含所有必要信息', () {
        final record = BehaviorRecord(
          behaviorId: 'test_behavior',
          timestamp: DateTime.now(),
          success: true,
          satisfaction: 0.8,
        );

        expect(record.behaviorId, equals('test_behavior'));
        expect(record.timestamp, isA<DateTime>());
        expect(record.success, isTrue);
        expect(record.satisfaction, equals(0.8));
      });
    });

    group('AI状态测试', () {
      test('AIStatus应该包含所有必要信息', () {
        const status = AIStatus(
          learningProgress: 0.5,
          behaviorCount: 10,
          adaptationLevel: 0.8,
          preferences: ['behavior_1', 'behavior_2'],
        );

        expect(status.learningProgress, equals(0.5));
        expect(status.behaviorCount, equals(10));
        expect(status.adaptationLevel, equals(0.8));
        expect(status.preferences.length, equals(2));
      });
    });
  });
}
