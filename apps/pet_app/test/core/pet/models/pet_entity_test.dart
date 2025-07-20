/*
---------------------------------------------------------------
File name:          pet_entity_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠实体模型测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/models/pet_entity.dart';
import '../../../../lib/core/pet/enums/pet_mood.dart';
import '../../../../lib/core/pet/enums/pet_activity.dart';
import '../../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetEntity Tests', () {
    group('创建默认桌宠测试', () {
      test('应该能够创建默认桌宠', () {
        final pet = PetEntity.createDefault(name: '小橘');

        expect(pet.name, equals('小橘'));
        expect(pet.type, equals('cat'));
        expect(pet.breed, equals('domestic'));
        expect(pet.color, equals('orange'));
        expect(pet.gender, equals('unknown'));
        expect(pet.size, equals(1.0));
        expect(pet.status, equals(PetStatus.baby));
        expect(pet.mood, equals(PetMood.happy));
        expect(pet.currentActivity, equals(PetActivity.idle));
        expect(pet.level, equals(1));
        expect(pet.experience, equals(0));
        expect(pet.health, equals(100));
        expect(pet.energy, equals(80));
        expect(pet.hunger, equals(20));
        expect(pet.happiness, equals(80));
        expect(pet.cleanliness, equals(90));
        expect(pet.isVisible, isTrue);
        expect(pet.isInteractable, isTrue);
      });

      test('应该能够创建自定义桌宠', () {
        final pet = PetEntity.createDefault(
          name: '小黑',
          type: 'dog',
          breed: 'labrador',
          color: 'black',
          gender: 'male',
        );

        expect(pet.name, equals('小黑'));
        expect(pet.type, equals('dog'));
        expect(pet.breed, equals('labrador'));
        expect(pet.color, equals('black'));
        expect(pet.gender, equals('male'));
      });

      test('创建的桌宠应该有唯一ID', () async {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        // 等待1毫秒确保时间戳不同
        await Future.delayed(const Duration(milliseconds: 1));
        final pet2 = PetEntity.createDefault(name: '宠物2');

        expect(pet1.id, isNot(equals(pet2.id)));
        expect(pet1.id, isNotEmpty);
        expect(pet2.id, isNotEmpty);
      });
    });

    group('桌宠属性测试', () {
      late PetEntity pet;

      setUp(() {
        pet = PetEntity.createDefault(name: '测试宠物');
      });

      test('应该能够复制并更新桌宠', () {
        final updatedPet = pet.copyWith(
          name: '新名字',
          mood: PetMood.excited,
          health: 90,
          energy: 70,
        );

        expect(updatedPet.name, equals('新名字'));
        expect(updatedPet.mood, equals(PetMood.excited));
        expect(updatedPet.health, equals(90));
        expect(updatedPet.energy, equals(70));

        // 其他属性应该保持不变
        expect(updatedPet.id, equals(pet.id));
        expect(updatedPet.type, equals(pet.type));
        expect(updatedPet.hunger, equals(pet.hunger));
      });

      test('应该正确计算桌宠年龄', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final weekAgo = now.subtract(const Duration(days: 7));

        final youngPet = pet.copyWith(birthday: yesterday);
        final olderPet = pet.copyWith(birthday: weekAgo);

        expect(youngPet.ageInDays, equals(1));
        expect(olderPet.ageInDays, equals(7));
      });

      test('应该正确判断年龄阶段', () {
        final now = DateTime.now();

        final babyPet = pet.copyWith(
          birthday: now.subtract(const Duration(days: 3)),
        );
        final teenPet = pet.copyWith(
          birthday: now.subtract(const Duration(days: 15)),
        );
        final youngPet = pet.copyWith(
          birthday: now.subtract(const Duration(days: 45)),
        );
        final adultPet = pet.copyWith(
          birthday: now.subtract(const Duration(days: 180)),
        );
        final elderPet = pet.copyWith(
          birthday: now.subtract(const Duration(days: 400)),
        );

        expect(babyPet.ageStage, equals('幼体'));
        expect(teenPet.ageStage, equals('少年'));
        expect(youngPet.ageStage, equals('青年'));
        expect(adultPet.ageStage, equals('成年'));
        expect(elderPet.ageStage, equals('长者'));
      });

      test('应该正确计算总体状态评分', () {
        final healthyPet = pet.copyWith(
          health: 100,
          energy: 100,
          hunger: 0,
          happiness: 100,
          cleanliness: 100,
        );

        final sickPet = pet.copyWith(
          health: 20,
          energy: 10,
          hunger: 90,
          happiness: 20,
          cleanliness: 30,
        );

        expect(healthyPet.overallScore, equals(100));
        expect(sickPet.overallScore, equals(18));
      });

      test('应该正确判断是否需要关注', () {
        final healthyPet = pet.copyWith(
          health: 80,
          energy: 60,
          hunger: 30,
          happiness: 70,
          cleanliness: 80,
        );

        final needsAttentionPet = pet.copyWith(
          health: 20, // 低于30
          energy: 60,
          hunger: 30,
          happiness: 70,
          cleanliness: 80,
        );

        expect(healthyPet.needsAttention, isFalse);
        expect(needsAttentionPet.needsAttention, isTrue);
      });

      test('应该正确判断是否健康', () {
        final healthyPet = pet.copyWith(
          health: 80,
          energy: 50,
          hunger: 40,
          happiness: 60,
          cleanliness: 50,
        );

        final unhealthyPet = pet.copyWith(
          health: 60, // 低于70
          energy: 50,
          hunger: 40,
          happiness: 60,
          cleanliness: 50,
        );

        expect(healthyPet.isHealthy, isTrue);
        expect(unhealthyPet.isHealthy, isFalse);
      });
    });

    group('JSON序列化测试', () {
      late PetEntity pet;

      setUp(() {
        pet = PetEntity.createDefault(name: '序列化测试');
      });

      test('应该能够转换为JSON', () {
        final json = pet.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals(pet.id));
        expect(json['name'], equals(pet.name));
        expect(json['type'], equals(pet.type));
        expect(json['status'], equals(pet.status.id));
        expect(json['mood'], equals(pet.mood.id));
        expect(json['currentActivity'], equals(pet.currentActivity.id));
        expect(json['health'], equals(pet.health));
        expect(json['energy'], equals(pet.energy));
      });

      test('应该能够从JSON创建', () {
        final json = pet.toJson();
        final recreatedPet = PetEntity.fromJson(json);

        expect(recreatedPet.id, equals(pet.id));
        expect(recreatedPet.name, equals(pet.name));
        expect(recreatedPet.type, equals(pet.type));
        expect(recreatedPet.status, equals(pet.status));
        expect(recreatedPet.mood, equals(pet.mood));
        expect(recreatedPet.currentActivity, equals(pet.currentActivity));
        expect(recreatedPet.health, equals(pet.health));
        expect(recreatedPet.energy, equals(pet.energy));
        expect(recreatedPet.birthday, equals(pet.birthday));
      });

      test('JSON序列化应该是可逆的', () {
        final json = pet.toJson();
        final recreatedPet = PetEntity.fromJson(json);
        final secondJson = recreatedPet.toJson();

        expect(secondJson, equals(json));
      });
    });

    group('相等性测试', () {
      test('相同ID的桌宠应该相等', () {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        final pet2 = pet1.copyWith(name: '宠物2');

        expect(pet1, equals(pet2));
        expect(pet1.hashCode, equals(pet2.hashCode));
      });

      test('不同ID的桌宠应该不相等', () async {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        // 等待1毫秒确保时间戳不同
        await Future.delayed(const Duration(milliseconds: 1));
        final pet2 = PetEntity.createDefault(name: '宠物2');

        expect(pet1, isNot(equals(pet2)));
        expect(pet1.hashCode, isNot(equals(pet2.hashCode)));
      });
    });

    group('字符串转换测试', () {
      test('toString应该包含关键信息', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final str = pet.toString();

        expect(str, contains(pet.id));
        expect(str, contains(pet.name));
        expect(str, contains(pet.status.toString()));
        expect(str, contains(pet.mood.toString()));
      });
    });
  });
}
