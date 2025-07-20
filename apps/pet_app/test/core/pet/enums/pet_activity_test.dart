/*
---------------------------------------------------------------
File name:          pet_activity_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠活动枚举测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/enums/pet_activity.dart';

void main() {
  group('PetActivity Tests', () {
    group('基础功能测试', () {
      test('应该包含所有预期的活动类型', () {
        expect(PetActivity.values.length, equals(15));
        
        // 验证基础活动
        expect(PetActivity.values, contains(PetActivity.idle));
        expect(PetActivity.values, contains(PetActivity.sleeping));
        expect(PetActivity.values, contains(PetActivity.eating));
        
        // 验证娱乐活动
        expect(PetActivity.values, contains(PetActivity.playing));
        expect(PetActivity.values, contains(PetActivity.exploring));
        
        // 验证学习活动
        expect(PetActivity.values, contains(PetActivity.learning));
        expect(PetActivity.values, contains(PetActivity.working));
        expect(PetActivity.values, contains(PetActivity.creating));
      });

      test('应该能够通过ID获取活动', () {
        expect(PetActivity.fromId('idle'), equals(PetActivity.idle));
        expect(PetActivity.fromId('playing'), equals(PetActivity.playing));
        expect(PetActivity.fromId('learning'), equals(PetActivity.learning));
        
        // 测试无效ID返回默认值
        expect(PetActivity.fromId('invalid'), equals(PetActivity.idle));
      });

      test('应该有正确的显示名称和表情符号', () {
        expect(PetActivity.idle.displayName, equals('空闲'));
        expect(PetActivity.idle.emoji, equals('🧘'));
        
        expect(PetActivity.playing.displayName, equals('玩耍'));
        expect(PetActivity.playing.emoji, equals('🎮'));
        
        expect(PetActivity.learning.displayName, equals('学习'));
        expect(PetActivity.learning.emoji, equals('📚'));
      });
    });

    group('活动分类测试', () {
      test('应该正确分类基础活动', () {
        final basicActivities = PetActivity.basicActivities;
        expect(basicActivities, contains(PetActivity.idle));
        expect(basicActivities, contains(PetActivity.sleeping));
        expect(basicActivities, contains(PetActivity.eating));
        expect(basicActivities.length, equals(3));
      });

      test('应该正确分类娱乐活动', () {
        final entertainmentActivities = PetActivity.entertainmentActivities;
        expect(entertainmentActivities, contains(PetActivity.playing));
        expect(entertainmentActivities, contains(PetActivity.exploring));
        expect(entertainmentActivities, contains(PetActivity.listening));
        expect(entertainmentActivities, contains(PetActivity.watching));
        expect(entertainmentActivities.length, equals(4));
      });

      test('应该正确分类学习活动', () {
        final learningActivities = PetActivity.learningActivities;
        expect(learningActivities, contains(PetActivity.learning));
        expect(learningActivities, contains(PetActivity.thinking));
        expect(learningActivities, contains(PetActivity.working));
        expect(learningActivities, contains(PetActivity.creating));
        expect(learningActivities.length, equals(4));
      });

      test('应该正确分类健康活动', () {
        final healthActivities = PetActivity.healthActivities;
        expect(healthActivities, contains(PetActivity.exercising));
        expect(healthActivities, contains(PetActivity.cleaning));
        expect(healthActivities, contains(PetActivity.meditating));
        expect(healthActivities.length, equals(3));
      });

      test('应该正确判断活动类型', () {
        expect(PetActivity.idle.isBasic, isTrue);
        expect(PetActivity.playing.isEntertainment, isTrue);
        expect(PetActivity.learning.isLearning, isTrue);
        expect(PetActivity.socializing.isSocial, isTrue);
        expect(PetActivity.exercising.isHealth, isTrue);
      });
    });

    group('活动属性测试', () {
      test('应该有合理的持续时间', () {
        expect(PetActivity.idle.durationMinutes, equals(0)); // 无限制
        expect(PetActivity.sleeping.durationMinutes, equals(480)); // 8小时
        expect(PetActivity.eating.durationMinutes, equals(15));
        expect(PetActivity.playing.durationMinutes, equals(30));
        expect(PetActivity.learning.durationMinutes, equals(45));
        
        // 所有活动的持续时间应该是非负数
        for (final activity in PetActivity.values) {
          expect(activity.durationMinutes, greaterThanOrEqualTo(0));
        }
      });

      test('应该有合理的能量消耗', () {
        expect(PetActivity.idle.energyCost, equals(0));
        expect(PetActivity.sleeping.energyCost, equals(-20)); // 恢复能量
        expect(PetActivity.eating.energyCost, equals(-10)); // 恢复能量
        expect(PetActivity.exercising.energyCost, equals(25)); // 高消耗
        expect(PetActivity.working.energyCost, equals(30)); // 高消耗
        
        // 验证恢复性活动有负值
        expect(PetActivity.sleeping.energyCost, lessThan(0));
        expect(PetActivity.eating.energyCost, lessThan(0));
        expect(PetActivity.meditating.energyCost, lessThan(0));
        
        // 验证高强度活动有高消耗
        expect(PetActivity.exercising.energyCost, greaterThan(20));
        expect(PetActivity.working.energyCost, greaterThan(20));
      });

      test('能量消耗应该在合理范围内', () {
        for (final activity in PetActivity.values) {
          expect(activity.energyCost, greaterThanOrEqualTo(-30));
          expect(activity.energyCost, lessThanOrEqualTo(50));
        }
      });
    });

    group('字符串转换测试', () {
      test('toString应该返回显示名称', () {
        expect(PetActivity.idle.toString(), equals('空闲'));
        expect(PetActivity.playing.toString(), equals('玩耍'));
        expect(PetActivity.learning.toString(), equals('学习'));
      });
    });
  });
}
