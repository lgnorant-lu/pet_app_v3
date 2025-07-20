/*
---------------------------------------------------------------
File name:          pet_behavior_service_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠行为服务测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:pet_app_v3/core/services/pet_behavior_service.dart';
import 'package:pet_app_v3/core/pet/models/pet_behavior.dart';

void main() {
  group('PetBehaviorService Tests', () {
    late PetBehaviorService behaviorService;

    setUp(() {
      behaviorService = PetBehaviorService();
    });

    tearDown(() async {
      // 清理测试数据
      await behaviorService.clearAllData();
    });

    group('基础CRUD操作测试', () {
      test('应该能够保存和获取行为', () async {
        final testBehavior = PetBehavior.createDefault(
          id: 'test_behavior',
          name: '测试行为',
          description: '这是一个测试行为',
        );

        await behaviorService.saveBehavior(testBehavior);
        final retrievedBehavior = await behaviorService.getBehavior(
          testBehavior.id,
        );

        expect(retrievedBehavior, isNotNull);
        expect(retrievedBehavior!.id, equals(testBehavior.id));
        expect(retrievedBehavior.name, equals(testBehavior.name));
        expect(retrievedBehavior.description, equals(testBehavior.description));
      });

      test('应该能够获取所有行为', () async {
        final behavior1 = PetBehavior.createDefault(
          id: 'behavior1',
          name: '行为1',
        );
        final behavior2 = PetBehavior.createDefault(
          id: 'behavior2',
          name: '行为2',
        );

        await behaviorService.saveBehavior(behavior1);
        await behaviorService.saveBehavior(behavior2);

        final allBehaviors = await behaviorService.getAllBehaviors();

        expect(allBehaviors.length, equals(2));
        expect(allBehaviors.any((b) => b.id == behavior1.id), isTrue);
        expect(allBehaviors.any((b) => b.id == behavior2.id), isTrue);
      });

      test('应该能够删除行为', () async {
        final testBehavior = PetBehavior.createDefault(
          id: 'delete_test',
          name: '待删除行为',
        );

        await behaviorService.saveBehavior(testBehavior);
        expect(await behaviorService.getBehavior(testBehavior.id), isNotNull);

        await behaviorService.deleteBehavior(testBehavior.id);
        expect(await behaviorService.getBehavior(testBehavior.id), isNull);
      });

      test('应该能够更新行为', () async {
        final originalBehavior = PetBehavior.createDefault(
          id: 'update_test',
          name: '原始名称',
          priority: 5,
        );
        await behaviorService.saveBehavior(originalBehavior);

        final updatedBehavior = originalBehavior.copyWith(
          name: '更新名称',
          priority: 8,
        );
        await behaviorService.saveBehavior(updatedBehavior);

        final retrievedBehavior = await behaviorService.getBehavior(
          originalBehavior.id,
        );
        expect(retrievedBehavior!.name, equals('更新名称'));
        expect(retrievedBehavior.priority, equals(8));
      });
    });

    group('行为统计测试', () {
      test('应该能够获取和更新行为统计', () async {
        final initialStats = await behaviorService.getBehaviorStatistics();

        expect(initialStats, isA<BehaviorStatistics>());
        expect(initialStats.executionCounts, isEmpty);
        expect(initialStats.totalDurations, isEmpty);
        expect(initialStats.successCounts, isEmpty);
        expect(initialStats.failureCounts, isEmpty);
      });

      test('应该能够记录行为执行', () async {
        const behaviorId = 'test_behavior';
        const duration = Duration(seconds: 30);

        await behaviorService.recordBehaviorExecution(
          behaviorId,
          duration,
          true,
        );

        final stats = await behaviorService.getBehaviorStatistics();
        expect(stats.executionCounts[behaviorId], equals(1));
        expect(stats.totalDurations[behaviorId], equals(30));
        expect(stats.successCounts[behaviorId], equals(1));
        expect(stats.failureCounts[behaviorId], isNull);
      });

      test('应该能够记录失败的行为执行', () async {
        const behaviorId = 'failed_behavior';
        const duration = Duration(seconds: 15);

        await behaviorService.recordBehaviorExecution(
          behaviorId,
          duration,
          false,
        );

        final stats = await behaviorService.getBehaviorStatistics();
        expect(stats.executionCounts[behaviorId], equals(1));
        expect(stats.totalDurations[behaviorId], equals(15));
        expect(stats.successCounts[behaviorId], isNull);
        expect(stats.failureCounts[behaviorId], equals(1));
      });

      test('应该能够累积行为统计', () async {
        const behaviorId = 'accumulate_test';

        // 记录多次执行
        await behaviorService.recordBehaviorExecution(
          behaviorId,
          const Duration(seconds: 10),
          true,
        );
        await behaviorService.recordBehaviorExecution(
          behaviorId,
          const Duration(seconds: 20),
          true,
        );
        await behaviorService.recordBehaviorExecution(
          behaviorId,
          const Duration(seconds: 15),
          false,
        );

        final stats = await behaviorService.getBehaviorStatistics();
        expect(stats.executionCounts[behaviorId], equals(3));
        expect(stats.totalDurations[behaviorId], equals(45));
        expect(stats.successCounts[behaviorId], equals(2));
        expect(stats.failureCounts[behaviorId], equals(1));
      });

      test('应该能够获取行为频率', () async {
        const behavior1 = 'frequent_behavior';
        const behavior2 = 'rare_behavior';

        // behavior1执行3次，behavior2执行1次
        for (int i = 0; i < 3; i++) {
          await behaviorService.recordBehaviorExecution(
            behavior1,
            const Duration(seconds: 10),
            true,
          );
        }
        await behaviorService.recordBehaviorExecution(
          behavior2,
          const Duration(seconds: 10),
          true,
        );

        final frequency = await behaviorService.getBehaviorFrequency();
        expect(frequency[behavior1], equals(3));
        expect(frequency[behavior2], equals(1));
      });

      test('应该能够获取最常执行的行为', () async {
        const behavior1 = 'most_frequent';
        const behavior2 = 'second_frequent';
        const behavior3 = 'least_frequent';

        // 设置不同的执行频率
        for (int i = 0; i < 5; i++) {
          await behaviorService.recordBehaviorExecution(
            behavior1,
            const Duration(seconds: 10),
            true,
          );
        }
        for (int i = 0; i < 3; i++) {
          await behaviorService.recordBehaviorExecution(
            behavior2,
            const Duration(seconds: 10),
            true,
          );
        }
        await behaviorService.recordBehaviorExecution(
          behavior3,
          const Duration(seconds: 10),
          true,
        );

        final mostExecuted = await behaviorService.getMostExecutedBehaviors(
          limit: 2,
        );
        expect(mostExecuted.length, equals(2));
        expect(mostExecuted[0], equals(behavior1));
        expect(mostExecuted[1], equals(behavior2));
      });
    });

    group('BehaviorStatistics模型测试', () {
      test('应该能够记录行为执行结果', () {
        final stats = BehaviorStatistics.initial();

        final updatedStats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 30),
          true,
        );

        expect(updatedStats.executionCounts['test_behavior'], equals(1));
        expect(updatedStats.totalDurations['test_behavior'], equals(30));
        expect(updatedStats.successCounts['test_behavior'], equals(1));
        expect(updatedStats.failureCounts['test_behavior'], isNull);
      });

      test('应该能够计算成功率', () {
        var stats = BehaviorStatistics.initial();

        // 记录2次成功，1次失败
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 10),
          false,
        );

        final successRate = stats.getSuccessRate('test_behavior');
        expect(successRate, closeTo(2.0 / 3.0, 0.01));
      });

      test('应该能够计算平均执行时间', () {
        var stats = BehaviorStatistics.initial();

        // 记录不同时长的执行
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 20),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 30),
          true,
        );

        final avgDuration = stats.getAverageDuration('test_behavior');
        expect(avgDuration.inSeconds, equals(20));
      });

      test('应该能够计算总执行次数', () {
        var stats = BehaviorStatistics.initial();

        stats = stats.recordExecution(
          'behavior1',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'behavior2',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'behavior1',
          const Duration(seconds: 10),
          false,
        );

        expect(stats.totalExecutions, equals(3));
      });

      test('应该能够计算总执行时间', () {
        var stats = BehaviorStatistics.initial();

        stats = stats.recordExecution(
          'behavior1',
          const Duration(seconds: 10),
          true,
        );
        stats = stats.recordExecution(
          'behavior2',
          const Duration(seconds: 20),
          true,
        );
        stats = stats.recordExecution(
          'behavior1',
          const Duration(seconds: 15),
          false,
        );

        expect(stats.totalDuration.inSeconds, equals(45));
      });

      test('应该能够序列化和反序列化', () {
        var stats = BehaviorStatistics.initial();
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 30),
          true,
        );

        final json = stats.toJson();
        final recreated = BehaviorStatistics.fromJson(json);

        expect(recreated.executionCounts['test_behavior'], equals(1));
        expect(recreated.totalDurations['test_behavior'], equals(30));
        expect(recreated.successCounts['test_behavior'], equals(1));
      });

      test('未执行的行为应该返回默认值', () {
        final stats = BehaviorStatistics.initial();

        expect(stats.getSuccessRate('nonexistent'), equals(0.0));
        expect(stats.getAverageDuration('nonexistent'), equals(Duration.zero));
      });
    });

    group('数据持久化测试', () {
      test('数据应该在服务重启后保持', () async {
        final testBehavior = PetBehavior.createDefault(
          id: 'persistence_test',
          name: '持久化测试',
        );
        await behaviorService.saveBehavior(testBehavior);

        // 记录一些统计数据
        await behaviorService.recordBehaviorExecution(
          'persistence_test',
          const Duration(seconds: 25),
          true,
        );

        // 创建新的服务实例模拟重启
        final newService = PetBehaviorService();
        final retrievedBehavior = await newService.getBehavior(testBehavior.id);
        final stats = await newService.getBehaviorStatistics();

        expect(retrievedBehavior, isNotNull);
        expect(retrievedBehavior!.id, equals(testBehavior.id));
        expect(stats.executionCounts['persistence_test'], equals(1));
      });

      test('应该能够清除所有数据', () async {
        final behavior1 = PetBehavior.createDefault(
          id: 'behavior1',
          name: '行为1',
        );
        final behavior2 = PetBehavior.createDefault(
          id: 'behavior2',
          name: '行为2',
        );

        await behaviorService.saveBehavior(behavior1);
        await behaviorService.saveBehavior(behavior2);
        await behaviorService.recordBehaviorExecution(
          'behavior1',
          const Duration(seconds: 10),
          true,
        );

        expect((await behaviorService.getAllBehaviors()).length, equals(2));

        await behaviorService.clearAllData();

        expect((await behaviorService.getAllBehaviors()).length, equals(0));
        final stats = await behaviorService.getBehaviorStatistics();
        expect(stats.executionCounts, isEmpty);
      });
    });

    group('错误处理测试', () {
      test('获取不存在的行为应该返回null', () async {
        final behavior = await behaviorService.getBehavior('nonexistent');
        expect(behavior, isNull);
      });

      test('删除不存在的行为应该正常处理', () async {
        // 不应该抛出异常
        await behaviorService.deleteBehavior('nonexistent');
      });
    });

    group('JSON序列化测试', () {
      test('行为数据应该能够正确序列化和反序列化', () async {
        final originalBehavior = PetBehavior.createDefault(
          id: 'serialization_test',
          name: '序列化测试',
          description: '测试JSON序列化',
          priority: 7,
          duration: 120,
          tags: ['test', 'serialization'],
        );

        await behaviorService.saveBehavior(originalBehavior);
        final retrievedBehavior = await behaviorService.getBehavior(
          originalBehavior.id,
        );

        expect(retrievedBehavior!.name, equals('序列化测试'));
        expect(retrievedBehavior.description, equals('测试JSON序列化'));
        expect(retrievedBehavior.priority, equals(7));
        expect(retrievedBehavior.duration, equals(120));
        expect(retrievedBehavior.tags, containsAll(['test', 'serialization']));
      });
    });
  });
}
