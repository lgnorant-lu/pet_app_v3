/*
---------------------------------------------------------------
File name:          pet_service_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠服务测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../lib/core/services/pet_service.dart';
import '../../../lib/core/pet/models/pet_entity.dart';
import '../../../lib/core/pet/enums/pet_mood.dart';
import '../../../lib/core/pet/enums/pet_activity.dart';

void main() {
  group('PetService Tests', () {
    late PetService petService;

    setUp(() {
      petService = PetService();
    });

    tearDown(() async {
      // 清理测试数据
      await petService.clearAllData();
    });

    group('基础CRUD操作测试', () {
      test('应该能够保存和获取桌宠', () async {
        final testPet = PetEntity.createDefault(name: '测试宠物');
        
        await petService.savePet(testPet);
        final retrievedPet = await petService.getPet(testPet.id);
        
        expect(retrievedPet, isNotNull);
        expect(retrievedPet!.id, equals(testPet.id));
        expect(retrievedPet.name, equals(testPet.name));
      });

      test('应该能够获取所有桌宠', () async {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        final pet2 = PetEntity.createDefault(name: '宠物2');
        
        await petService.savePet(pet1);
        await petService.savePet(pet2);
        
        final allPets = await petService.getAllPets();
        
        expect(allPets.length, equals(2));
        expect(allPets.any((p) => p.id == pet1.id), isTrue);
        expect(allPets.any((p) => p.id == pet2.id), isTrue);
      });

      test('应该能够删除桌宠', () async {
        final testPet = PetEntity.createDefault(name: '待删除宠物');
        
        await petService.savePet(testPet);
        expect(await petService.getPet(testPet.id), isNotNull);
        
        await petService.deletePet(testPet.id);
        expect(await petService.getPet(testPet.id), isNull);
      });

      test('应该能够更新桌宠', () async {
        final testPet = PetEntity.createDefault(name: '原始名字');
        await petService.savePet(testPet);
        
        final updatedPet = testPet.copyWith(name: '更新名字', health: 50);
        await petService.savePet(updatedPet);
        
        final retrievedPet = await petService.getPet(testPet.id);
        expect(retrievedPet!.name, equals('更新名字'));
        expect(retrievedPet.health, equals(50));
      });
    });

    group('桌宠状态更新测试', () {
      late PetEntity testPet;

      setUp(() async {
        testPet = PetEntity.createDefault(name: '状态测试宠物');
        await petService.savePet(testPet);
      });

      test('应该能够更新桌宠心情', () async {
        await petService.updatePetMood(testPet.id, PetMood.excited);
        
        final updatedPet = await petService.getPet(testPet.id);
        expect(updatedPet!.mood, equals(PetMood.excited));
      });

      test('应该能够更新桌宠活动', () async {
        await petService.updatePetActivity(testPet.id, PetActivity.playing);
        
        final updatedPet = await petService.getPet(testPet.id);
        expect(updatedPet!.currentActivity, equals(PetActivity.playing));
      });

      test('应该能够喂食桌宠', () async {
        // 先设置桌宠为饥饿状态
        final hungryPet = testPet.copyWith(hunger: 80);
        await petService.savePet(hungryPet);
        
        await petService.feedPet(testPet.id);
        
        final fedPet = await petService.getPet(testPet.id);
        expect(fedPet!.hunger, lessThan(80));
        expect(fedPet.lastFed, isA<DateTime>());
      });

      test('应该能够清洁桌宠', () async {
        // 先设置桌宠为脏污状态
        final dirtyPet = testPet.copyWith(cleanliness: 30);
        await petService.savePet(dirtyPet);
        
        await petService.cleanPet(testPet.id);
        
        final cleanPet = await petService.getPet(testPet.id);
        expect(cleanPet!.cleanliness, greaterThan(30));
        expect(cleanPet.lastCleaned, isA<DateTime>());
      });

      test('应该能够与桌宠玩耍', () async {
        await petService.playWithPet(testPet.id);
        
        final playedPet = await petService.getPet(testPet.id);
        expect(playedPet!.happiness, greaterThan(testPet.happiness));
        expect(playedPet.lastInteraction, isA<DateTime>());
      });

      test('更新不存在的桌宠应该抛出异常', () async {
        expect(
          () => petService.updatePetMood('nonexistent', PetMood.happy),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('桌宠统计测试', () {
      test('应该能够获取桌宠统计信息', () async {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        final pet2 = PetEntity.createDefault(name: '宠物2');
        
        await petService.savePet(pet1);
        await petService.savePet(pet2);
        
        final stats = await petService.getPetStatistics();
        
        expect(stats.totalPets, equals(2));
        expect(stats.activePets, greaterThanOrEqualTo(0));
        expect(stats.averageHealth, greaterThanOrEqualTo(0));
        expect(stats.averageHappiness, greaterThanOrEqualTo(0));
      });

      test('空数据库应该返回零统计', () async {
        final stats = await petService.getPetStatistics();
        
        expect(stats.totalPets, equals(0));
        expect(stats.activePets, equals(0));
        expect(stats.averageHealth, equals(0));
        expect(stats.averageHappiness, equals(0));
      });
    });

    group('数据持久化测试', () {
      test('数据应该在服务重启后保持', () async {
        final testPet = PetEntity.createDefault(name: '持久化测试');
        await petService.savePet(testPet);
        
        // 创建新的服务实例模拟重启
        final newService = PetService();
        final retrievedPet = await newService.getPet(testPet.id);
        
        expect(retrievedPet, isNotNull);
        expect(retrievedPet!.id, equals(testPet.id));
        expect(retrievedPet.name, equals(testPet.name));
      });

      test('应该能够清除所有数据', () async {
        final pet1 = PetEntity.createDefault(name: '宠物1');
        final pet2 = PetEntity.createDefault(name: '宠物2');
        
        await petService.savePet(pet1);
        await petService.savePet(pet2);
        
        expect((await petService.getAllPets()).length, equals(2));
        
        await petService.clearAllData();
        
        expect((await petService.getAllPets()).length, equals(0));
      });
    });

    group('错误处理测试', () {
      test('获取不存在的桌宠应该返回null', () async {
        final pet = await petService.getPet('nonexistent');
        expect(pet, isNull);
      });

      test('删除不存在的桌宠应该正常处理', () async {
        // 不应该抛出异常
        await petService.deletePet('nonexistent');
      });
    });

    group('JSON序列化测试', () {
      test('桌宠数据应该能够正确序列化和反序列化', () async {
        final originalPet = PetEntity.createDefault(name: '序列化测试')
            .copyWith(
              health: 75,
              energy: 60,
              happiness: 85,
              mood: PetMood.excited,
              currentActivity: PetActivity.playing,
            );
        
        await petService.savePet(originalPet);
        final retrievedPet = await petService.getPet(originalPet.id);
        
        expect(retrievedPet!.health, equals(75));
        expect(retrievedPet.energy, equals(60));
        expect(retrievedPet.happiness, equals(85));
        expect(retrievedPet.mood, equals(PetMood.excited));
        expect(retrievedPet.currentActivity, equals(PetActivity.playing));
      });
    });

    group('并发操作测试', () {
      test('应该能够处理并发保存操作', () async {
        final pets = List.generate(10, (i) => 
            PetEntity.createDefault(name: '并发宠物$i'));
        
        // 并发保存所有桌宠
        await Future.wait(pets.map((pet) => petService.savePet(pet)));
        
        final allPets = await petService.getAllPets();
        expect(allPets.length, equals(10));
        
        // 验证所有桌宠都被正确保存
        for (final pet in pets) {
          expect(allPets.any((p) => p.id == pet.id), isTrue);
        }
      });

      test('应该能够处理并发更新操作', () async {
        final testPet = PetEntity.createDefault(name: '并发更新测试');
        await petService.savePet(testPet);
        
        // 并发更新不同属性
        await Future.wait([
          petService.updatePetMood(testPet.id, PetMood.happy),
          petService.updatePetActivity(testPet.id, PetActivity.learning),
          petService.feedPet(testPet.id),
          petService.cleanPet(testPet.id),
        ]);
        
        final updatedPet = await petService.getPet(testPet.id);
        expect(updatedPet!.mood, equals(PetMood.happy));
        expect(updatedPet.currentActivity, equals(PetActivity.learning));
      });
    });
  });
}
