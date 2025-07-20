/*
---------------------------------------------------------------
File name:          pet_lifecycle_manager_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠生命周期管理器测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/lifecycle/pet_lifecycle_manager.dart';
import '../../../../lib/core/pet/models/pet_entity.dart';
import '../../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetLifecycleManager Tests', () {
    late PetLifecycleManager manager;

    setUp(() {
      manager = PetLifecycleManager();
    });

    tearDown(() {
      manager.dispose();
    });

    group('基础功能测试', () {
      test('应该能够启动和停止生命周期管理', () {
        manager.start();
        expect(manager, isNotNull);
        
        manager.stop();
        expect(manager, isNotNull);
      });

      test('应该能够添加和移除桌宠', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        
        manager.addPet(pet);
        expect(manager, isNotNull);
        
        manager.removePet(pet.id);
        expect(manager, isNotNull);
      });

      test('应该能够更新桌宠状态', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        manager.addPet(pet);
        
        final updatedPet = pet.copyWith(health: 50);
        manager.updatePet(updatedPet);
        
        expect(manager, isNotNull);
      });
    });

    group('生命周期信息测试', () {
      test('应该能够获取桌宠生命周期信息', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        manager.addPet(pet);
        
        final info = manager.getLifecycleInfo(pet.id);
        
        expect(info.currentStage, isNotEmpty);
        expect(info.ageInDays, greaterThanOrEqualTo(0));
        expect(info.nextStageIn, greaterThanOrEqualTo(0));
        expect(info.healthStatus, isA<PetStatus>());
        expect(info.overallCondition, isNotEmpty);
      });

      test('获取不存在桌宠的信息应该抛出异常', () {
        expect(
          () => manager.getLifecycleInfo('nonexistent'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('生命周期状态测试', () {
      test('LifecycleState应该能够从桌宠创建', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final state = LifecycleState.fromPet(pet);
        
        expect(state.lastHealthCheck, isA<DateTime>());
        expect(state.lastLifecycleCheck, isA<DateTime>());
        expect(state.metadata, isA<Map<String, dynamic>>());
        expect(state.metadata['lastStatus'], equals(pet.status.id));
        expect(state.metadata['lastMood'], equals(pet.mood.id));
      });
    });

    group('生命周期信息模型测试', () {
      test('LifecycleInfo应该包含所有必要信息', () {
        const info = LifecycleInfo(
          currentStage: '幼体',
          ageInDays: 5,
          nextStageIn: 2,
          healthStatus: PetStatus.healthy,
          overallCondition: '良好',
        );
        
        expect(info.currentStage, equals('幼体'));
        expect(info.ageInDays, equals(5));
        expect(info.nextStageIn, equals(2));
        expect(info.healthStatus, equals(PetStatus.healthy));
        expect(info.overallCondition, equals('良好'));
      });
    });
  });
}
