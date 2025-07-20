/*
---------------------------------------------------------------
File name:          phase_4_3_integration_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        Phase 4.3 桌宠系统集成测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:pet_app_v3/core/pet/models/pet_entity.dart';
import 'package:pet_app_v3/core/pet/models/pet_behavior.dart';
import 'package:pet_app_v3/core/pet/enums/pet_mood.dart';
import 'package:pet_app_v3/core/pet/enums/pet_activity.dart';
import 'package:pet_app_v3/core/pet/enums/pet_status.dart';

void main() {
  group('Phase 4.3 桌宠系统集成测试', () {
    group('核心模型集成测试', () {
      test('桌宠实体应该能够正确创建和管理', () {
        // 创建默认桌宠
        final pet = PetEntity.createDefault(name: '集成测试宠物');

        expect(pet.name, equals('集成测试宠物'));
        expect(pet.health, equals(100));
        expect(pet.energy, equals(80));
        expect(pet.happiness, equals(80));
        expect(pet.hunger, equals(20));
        expect(pet.cleanliness, equals(90));
        expect(pet.mood, equals(PetMood.happy));
        expect(pet.currentActivity, equals(PetActivity.idle));
        expect(pet.status, equals(PetStatus.baby));
      });

      test('桌宠应该能够更新状态', () {
        final pet = PetEntity.createDefault(name: '状态测试宠物');

        // 更新桌宠状态
        final updatedPet = pet.copyWith(
          health: 80,
          energy: 60,
          happiness: 90,
          mood: PetMood.excited,
          currentActivity: PetActivity.playing,
        );

        expect(updatedPet.health, equals(80));
        expect(updatedPet.energy, equals(60));
        expect(updatedPet.happiness, equals(90));
        expect(updatedPet.mood, equals(PetMood.excited));
        expect(updatedPet.currentActivity, equals(PetActivity.playing));

        // 原始桌宠应该保持不变
        expect(pet.health, equals(100));
        expect(pet.mood, equals(PetMood.happy));
      });

      test('桌宠应该能够计算总体状态评分', () {
        final pet = PetEntity.createDefault(name: '评分测试宠物').copyWith(
          health: 80,
          energy: 70,
          happiness: 90,
          hunger: 20,
          cleanliness: 85,
        );

        final score = pet.overallScore;
        expect(score, greaterThan(0));
        expect(score, lessThanOrEqualTo(100));

        // 验证评分计算逻辑
        final expectedScore = ((80 + 70 + 90 + (100 - 20) + 85) / 5).round();
        expect(score, equals(expectedScore));
      });

      test('桌宠应该能够判断是否需要关注', () {
        // 健康的桌宠不需要关注
        final healthyPet = PetEntity.createDefault(name: '健康宠物');
        expect(healthyPet.needsAttention, isFalse);

        // 低健康值的桌宠需要关注
        final sickPet = healthyPet.copyWith(health: 20);
        expect(sickPet.needsAttention, isTrue);

        // 高饥饿值的桌宠需要关注
        final hungryPet = healthyPet.copyWith(hunger: 90);
        expect(hungryPet.needsAttention, isTrue);

        // 低能量的桌宠需要关注
        final tiredPet = healthyPet.copyWith(energy: 15);
        expect(tiredPet.needsAttention, isTrue);
      });
    });

    group('行为系统集成测试', () {
      test('行为应该能够正确创建和管理', () {
        final behavior = PetBehavior.createDefault(
          id: 'test_behavior',
          name: '测试行为',
          description: '这是一个测试行为',
        );

        expect(behavior.id, equals('test_behavior'));
        expect(behavior.name, equals('测试行为'));
        expect(behavior.description, equals('这是一个测试行为'));
        expect(behavior.priority, equals(5));
        expect(behavior.duration, equals(30));
        expect(behavior.tags, isA<List<String>>());
      });

      test('行为统计应该能够正确记录和计算', () {
        var stats = BehaviorStatistics.initial();

        // 记录行为执行
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 30),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 20),
          true,
        );
        stats = stats.recordExecution(
          'test_behavior',
          const Duration(seconds: 40),
          false,
        );

        // 验证统计数据
        expect(stats.executionCounts['test_behavior'], equals(3));
        expect(stats.totalDurations['test_behavior'], equals(90));
        expect(stats.successCounts['test_behavior'], equals(2));
        expect(stats.failureCounts['test_behavior'], equals(1));

        // 验证计算方法
        expect(stats.getSuccessRate('test_behavior'), closeTo(2.0 / 3.0, 0.01));
        expect(stats.getAverageDuration('test_behavior').inSeconds, equals(30));
        expect(stats.totalExecutions, equals(3));
        expect(stats.totalDuration.inSeconds, equals(90));
      });
    });

    group('枚举系统集成测试', () {
      test('心情枚举应该能够正确分类和转换', () {
        // 测试积极心情
        expect(PetMood.happy.isPositive, isTrue);
        expect(PetMood.excited.isPositive, isTrue);
        expect(PetMood.loving.isPositive, isTrue);

        // 测试消极心情
        expect(PetMood.sad.isNegative, isTrue);
        expect(PetMood.angry.isNegative, isTrue);
        expect(PetMood.sick.isNegative, isTrue);

        // 测试中性心情
        expect(PetMood.sleepy.isNeutral, isTrue);
        expect(PetMood.hungry.isNeutral, isTrue);

        // 测试字符串转换
        expect(PetMood.happy.toString(), equals(PetMood.happy.displayName));
      });

      test('活动枚举应该能够正确分类和管理', () {
        // 测试基础活动
        expect(PetActivity.idle.isBasic, isTrue);
        expect(PetActivity.sleeping.isBasic, isTrue);
        expect(PetActivity.eating.isBasic, isTrue);

        // 测试娱乐活动
        expect(PetActivity.playing.isEntertainment, isTrue);

        // 测试学习活动
        expect(PetActivity.learning.isLearning, isTrue);

        // 测试活动类型
        expect(PetActivity.sleeping.isBasic, isTrue);
        expect(PetActivity.playing.isEntertainment, isTrue);
      });

      test('状态枚举应该能够正确判断和管理', () {
        // 测试生命周期状态
        expect(PetStatus.baby.isLifecycle, isTrue);
        expect(PetStatus.adult.isLifecycle, isTrue);
        expect(PetStatus.growing.isLifecycle, isTrue);

        // 测试健康状态
        expect(PetStatus.healthy.isHealthy, isTrue);
        expect(PetStatus.sick.isHealthy, isFalse);
        expect(PetStatus.injured.isHealthy, isFalse);

        // 测试活跃状态
        expect(PetStatus.healthy.isActive, isTrue);
        expect(PetStatus.offline.isActive, isFalse);
        expect(PetStatus.maintenance.isActive, isFalse);

        // 测试需要关注的状态
        expect(PetStatus.sick.needsAttention, isTrue);
        expect(PetStatus.injured.needsAttention, isTrue);
        expect(PetStatus.weak.needsAttention, isTrue);
        expect(PetStatus.healthy.needsAttention, isFalse);
      });
    });

    group('JSON序列化集成测试', () {
      test('桌宠实体应该能够正确序列化和反序列化', () {
        final originalPet = PetEntity.createDefault(name: '序列化测试宠物').copyWith(
          health: 85,
          energy: 70,
          happiness: 95,
          mood: PetMood.excited,
          currentActivity: PetActivity.playing,
          status: PetStatus.healthy,
        );

        // 序列化
        final json = originalPet.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['name'], equals('序列化测试宠物'));
        expect(json['health'], equals(85));

        // 反序列化
        final recreatedPet = PetEntity.fromJson(json);
        expect(recreatedPet.id, equals(originalPet.id));
        expect(recreatedPet.name, equals(originalPet.name));
        expect(recreatedPet.health, equals(originalPet.health));
        expect(recreatedPet.energy, equals(originalPet.energy));
        expect(recreatedPet.happiness, equals(originalPet.happiness));
        expect(recreatedPet.mood, equals(originalPet.mood));
        expect(
          recreatedPet.currentActivity,
          equals(originalPet.currentActivity),
        );
        expect(recreatedPet.status, equals(originalPet.status));
      });

      test('行为数据应该能够正确序列化和反序列化', () {
        final originalBehavior = PetBehavior.createDefault(
          id: 'serialize_test',
          name: '序列化测试行为',
          description: '测试JSON序列化功能',
          priority: 8,
          duration: 60,
          tags: ['test', 'serialization'],
        );

        // 序列化
        final json = originalBehavior.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['name'], equals('序列化测试行为'));
        expect(json['priority'], equals(8));

        // 反序列化
        final recreatedBehavior = PetBehavior.fromJson(json);
        expect(recreatedBehavior.id, equals(originalBehavior.id));
        expect(recreatedBehavior.name, equals(originalBehavior.name));
        expect(
          recreatedBehavior.description,
          equals(originalBehavior.description),
        );
        expect(recreatedBehavior.priority, equals(originalBehavior.priority));
        expect(recreatedBehavior.duration, equals(originalBehavior.duration));
        expect(recreatedBehavior.tags, equals(originalBehavior.tags));
      });

      test('行为统计应该能够正确序列化和反序列化', () {
        var originalStats = BehaviorStatistics.initial();
        originalStats = originalStats.recordExecution(
          'test1',
          const Duration(seconds: 30),
          true,
        );
        originalStats = originalStats.recordExecution(
          'test2',
          const Duration(seconds: 45),
          false,
        );

        // 序列化
        final json = originalStats.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['executionCounts'], isA<Map<String, dynamic>>());

        // 反序列化
        final recreatedStats = BehaviorStatistics.fromJson(json);
        expect(
          recreatedStats.executionCounts,
          equals(originalStats.executionCounts),
        );
        expect(
          recreatedStats.totalDurations,
          equals(originalStats.totalDurations),
        );
        expect(
          recreatedStats.successCounts,
          equals(originalStats.successCounts),
        );
        expect(
          recreatedStats.failureCounts,
          equals(originalStats.failureCounts),
        );
      });
    });

    group('系统完整性测试', () {
      test('桌宠系统应该能够完整运行生命周期', () {
        // 创建桌宠
        var pet = PetEntity.createDefault(name: '生命周期测试宠物');
        expect(pet.isHealthy, isTrue);

        // 模拟时间流逝和状态变化
        pet = pet.copyWith(hunger: 85, energy: 15, cleanliness: 25);

        // 桌宠应该需要关注
        expect(pet.needsAttention, isTrue);

        // 进行照顾操作
        pet = pet.copyWith(
          hunger: 10, // 喂食
          energy: 90, // 休息
          cleanliness: 95, // 清洁
        );

        // 桌宠应该恢复健康
        expect(pet.needsAttention, isFalse);
        expect(pet.overallScore, greaterThan(80));
      });

      test('行为系统应该能够正确统计和分析', () {
        var stats = BehaviorStatistics.initial();

        // 模拟多种行为执行
        final behaviors = ['eating', 'playing', 'sleeping', 'learning'];
        final durations = [15, 30, 120, 45];
        final successes = [true, true, true, false];

        for (int i = 0; i < behaviors.length; i++) {
          stats = stats.recordExecution(
            behaviors[i],
            Duration(seconds: durations[i]),
            successes[i],
          );
        }

        // 验证统计结果
        expect(stats.totalExecutions, equals(4));
        expect(stats.totalDuration.inSeconds, equals(210));
        expect(stats.getSuccessRate('learning'), equals(0.0));
        expect(stats.getSuccessRate('eating'), equals(1.0));

        // 验证最常执行的行为（这里每个行为只执行一次，所以顺序可能不确定）
        expect(stats.executionCounts.length, equals(4));
      });
    });
  });
}
