/*
---------------------------------------------------------------
File name:          pet_mood_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠心情枚举测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/enums/pet_mood.dart';

void main() {
  group('PetMood Tests', () {
    group('基础功能测试', () {
      test('应该包含所有预期的心情类型', () {
        expect(PetMood.values.length, equals(12));
        
        // 验证所有心情都存在
        expect(PetMood.values, contains(PetMood.happy));
        expect(PetMood.values, contains(PetMood.excited));
        expect(PetMood.values, contains(PetMood.calm));
        expect(PetMood.values, contains(PetMood.sleepy));
        expect(PetMood.values, contains(PetMood.hungry));
        expect(PetMood.values, contains(PetMood.bored));
        expect(PetMood.values, contains(PetMood.curious));
        expect(PetMood.values, contains(PetMood.angry));
        expect(PetMood.values, contains(PetMood.sad));
        expect(PetMood.values, contains(PetMood.scared));
        expect(PetMood.values, contains(PetMood.sick));
        expect(PetMood.values, contains(PetMood.loving));
      });

      test('应该能够通过ID获取心情', () {
        expect(PetMood.fromId('happy'), equals(PetMood.happy));
        expect(PetMood.fromId('sad'), equals(PetMood.sad));
        expect(PetMood.fromId('excited'), equals(PetMood.excited));
        
        // 测试无效ID返回默认值
        expect(PetMood.fromId('invalid'), equals(PetMood.calm));
      });

      test('应该有正确的显示名称和表情符号', () {
        expect(PetMood.happy.displayName, equals('开心'));
        expect(PetMood.happy.emoji, equals('😊'));
        
        expect(PetMood.sad.displayName, equals('悲伤'));
        expect(PetMood.sad.emoji, equals('😢'));
        
        expect(PetMood.excited.displayName, equals('兴奋'));
        expect(PetMood.excited.emoji, equals('🤩'));
      });
    });

    group('心情分类测试', () {
      test('应该正确分类积极心情', () {
        final positiveMoods = PetMood.positiveMoods;
        expect(positiveMoods, contains(PetMood.happy));
        expect(positiveMoods, contains(PetMood.excited));
        expect(positiveMoods, contains(PetMood.calm));
        expect(positiveMoods, contains(PetMood.curious));
        expect(positiveMoods, contains(PetMood.loving));
        expect(positiveMoods.length, equals(5));
      });

      test('应该正确分类消极心情', () {
        final negativeMoods = PetMood.negativeMoods;
        expect(negativeMoods, contains(PetMood.angry));
        expect(negativeMoods, contains(PetMood.sad));
        expect(negativeMoods, contains(PetMood.scared));
        expect(negativeMoods, contains(PetMood.sick));
        expect(negativeMoods, contains(PetMood.bored));
        expect(negativeMoods.length, equals(5));
      });

      test('应该正确分类中性心情', () {
        final neutralMoods = PetMood.neutralMoods;
        expect(neutralMoods, contains(PetMood.sleepy));
        expect(neutralMoods, contains(PetMood.hungry));
        expect(neutralMoods.length, equals(2));
      });

      test('应该正确判断心情类型', () {
        expect(PetMood.happy.isPositive, isTrue);
        expect(PetMood.happy.isNegative, isFalse);
        expect(PetMood.happy.isNeutral, isFalse);
        
        expect(PetMood.sad.isPositive, isFalse);
        expect(PetMood.sad.isNegative, isTrue);
        expect(PetMood.sad.isNeutral, isFalse);
        
        expect(PetMood.sleepy.isPositive, isFalse);
        expect(PetMood.sleepy.isNegative, isFalse);
        expect(PetMood.sleepy.isNeutral, isTrue);
      });
    });

    group('心情值测试', () {
      test('应该有正确的心情值范围', () {
        for (final mood in PetMood.values) {
          expect(mood.moodValue, greaterThanOrEqualTo(-1.0));
          expect(mood.moodValue, lessThanOrEqualTo(1.0));
        }
      });

      test('应该有正确的心情值排序', () {
        expect(PetMood.excited.moodValue, equals(1.0));
        expect(PetMood.loving.moodValue, equals(1.0));
        expect(PetMood.happy.moodValue, equals(0.8));
        expect(PetMood.sleepy.moodValue, equals(0.0));
        expect(PetMood.hungry.moodValue, equals(0.0));
        expect(PetMood.sick.moodValue, equals(-1.0));
        expect(PetMood.scared.moodValue, equals(-1.0));
      });

      test('积极心情应该有正值', () {
        for (final mood in PetMood.positiveMoods) {
          expect(mood.moodValue, greaterThan(0.0));
        }
      });

      test('消极心情应该有负值', () {
        for (final mood in PetMood.negativeMoods) {
          expect(mood.moodValue, lessThan(0.0));
        }
      });

      test('中性心情应该有零值', () {
        for (final mood in PetMood.neutralMoods) {
          expect(mood.moodValue, equals(0.0));
        }
      });
    });

    group('字符串转换测试', () {
      test('toString应该返回显示名称', () {
        expect(PetMood.happy.toString(), equals('开心'));
        expect(PetMood.sad.toString(), equals('悲伤'));
        expect(PetMood.excited.toString(), equals('兴奋'));
      });
    });
  });
}
