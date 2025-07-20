/*
---------------------------------------------------------------
File name:          pet_provider_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠状态管理Provider测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lib/core/providers/pet_provider.dart';
import '../../../lib/core/pet/models/pet_state.dart';
import '../../../lib/core/pet/models/pet_entity.dart';

import '../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态测试', () {
      test('应该提供初始的桌宠状态', () {
        final petState = container.read(petProvider);

        expect(petState, isA<PetState>());
        expect(petState.currentPet, isNull);
        expect(petState.pets, isEmpty);
        expect(petState.isLoading, isFalse);
        expect(petState.error, isNull);
        expect(petState.isEnabled, isTrue);
        expect(petState.isVisible, isTrue);
        expect(petState.interactionMode, equals(PetInteractionMode.normal));
      });

      test('当前桌宠提供者应该返回null', () {
        final currentPet = container.read(currentPetProvider);
        expect(currentPet, isNull);
      });

      test('桌宠列表提供者应该返回空列表', () {
        final petList = container.read(petListProvider);
        expect(petList, isEmpty);
      });

      test('活跃桌宠数量应该为0', () {
        final activePetCount = container.read(activePetCountProvider);
        expect(activePetCount, equals(0));
      });

      test('需要关注的桌宠数量应该为0', () {
        final petsNeedingAttention = container.read(
          petsNeedingAttentionProvider,
        );
        expect(petsNeedingAttention, equals(0));
      });

      test('桌宠系统状态应该显示暂无桌宠', () {
        final systemStatus = container.read(petSystemStatusProvider);
        expect(systemStatus, equals('暂无桌宠'));
      });
    });

    group('状态更新测试', () {
      test('应该能够设置桌宠可见性', () {
        final notifier = container.read(petProvider.notifier);

        notifier.setPetVisibility(false);

        final state = container.read(petProvider);
        expect(state.isVisible, isFalse);
      });

      test('应该能够设置交互模式', () {
        final notifier = container.read(petProvider.notifier);

        notifier.setInteractionMode(PetInteractionMode.quiet);

        final state = container.read(petProvider);
        expect(state.interactionMode, equals(PetInteractionMode.quiet));
      });

      test('应该能够启用/禁用桌宠系统', () {
        final notifier = container.read(petProvider.notifier);

        notifier.setPetSystemEnabled(false);

        final state = container.read(petProvider);
        expect(state.isEnabled, isFalse);
      });

      test('应该能够清除错误状态', () {
        final notifier = container.read(petProvider.notifier);

        // 先设置错误状态
        final errorState = container.read(petProvider).copyWithError('测试错误');
        container.read(petProvider.notifier).state = errorState;

        expect(container.read(petProvider).error, equals('测试错误'));

        // 清除错误
        notifier.clearError();

        expect(container.read(petProvider).error, isNull);
      });
    });

    group('桌宠管理测试', () {
      test('应该能够切换当前桌宠', () {
        final notifier = container.read(petProvider.notifier);

        // 创建测试桌宠
        final pet1 = PetEntity.createDefault(name: '宠物1');
        final pet2 = PetEntity.createDefault(name: '宠物2');

        // 设置桌宠列表
        final stateWithPets = container
            .read(petProvider)
            .copyWith(pets: [pet1, pet2], currentPet: pet1);
        notifier.state = stateWithPets;

        // 切换到宠物2
        notifier.switchCurrentPet(pet2.id);

        final state = container.read(petProvider);
        expect(state.currentPet, equals(pet2));
      });

      test('切换不存在的桌宠应该抛出异常', () {
        final notifier = container.read(petProvider.notifier);

        expect(
          () => notifier.switchCurrentPet('nonexistent'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('派生提供者测试', () {
      test('当前桌宠提供者应该响应状态变化', () {
        final notifier = container.read(petProvider.notifier);
        final pet = PetEntity.createDefault(name: '测试宠物');

        // 设置当前桌宠
        final stateWithPet = container
            .read(petProvider)
            .copyWith(currentPet: pet);
        notifier.state = stateWithPet;

        final currentPet = container.read(currentPetProvider);
        expect(currentPet, equals(pet));
      });

      test('桌宠列表提供者应该响应状态变化', () {
        final notifier = container.read(petProvider.notifier);
        final pets = [
          PetEntity.createDefault(name: '宠物1'),
          PetEntity.createDefault(name: '宠物2'),
        ];

        // 设置桌宠列表
        final stateWithPets = container.read(petProvider).copyWith(pets: pets);
        notifier.state = stateWithPets;

        final petList = container.read(petListProvider);
        expect(petList, equals(pets));
        expect(petList.length, equals(2));
      });

      test('活跃桌宠数量提供者应该正确计算', () {
        final notifier = container.read(petProvider.notifier);
        final pets = [
          PetEntity.createDefault(
            name: '活跃宠物1',
          ).copyWith(status: PetStatus.active),
          PetEntity.createDefault(
            name: '活跃宠物2',
          ).copyWith(status: PetStatus.healthy),
          PetEntity.createDefault(
            name: '非活跃宠物',
          ).copyWith(status: PetStatus.offline),
        ];

        // 设置桌宠列表
        final stateWithPets = container.read(petProvider).copyWith(pets: pets);
        notifier.state = stateWithPets;

        final activePetCount = container.read(activePetCountProvider);
        expect(activePetCount, equals(2));
      });

      test('需要关注的桌宠数量提供者应该正确计算', () {
        final notifier = container.read(petProvider.notifier);
        final pets = [
          PetEntity.createDefault(name: '健康宠物').copyWith(health: 80),
          PetEntity.createDefault(name: '需要关注宠物1').copyWith(health: 20),
          PetEntity.createDefault(name: '需要关注宠物2').copyWith(hunger: 90),
        ];

        // 设置桌宠列表
        final stateWithPets = container.read(petProvider).copyWith(pets: pets);
        notifier.state = stateWithPets;

        final petsNeedingAttention = container.read(
          petsNeedingAttentionProvider,
        );
        expect(petsNeedingAttention, equals(2));
      });

      test('桌宠系统状态提供者应该反映当前状态', () {
        final notifier = container.read(petProvider.notifier);

        // 测试禁用状态
        notifier.setPetSystemEnabled(false);
        expect(container.read(petSystemStatusProvider), equals('桌宠系统已禁用'));

        // 测试加载状态
        notifier.setPetSystemEnabled(true);
        final loadingState = container.read(petProvider).copyWithLoading(true);
        notifier.state = loadingState;
        expect(container.read(petSystemStatusProvider), equals('正在加载桌宠...'));

        // 测试错误状态
        final errorState = container.read(petProvider).copyWithError('测试错误');
        notifier.state = errorState;
        expect(container.read(petSystemStatusProvider), equals('桌宠系统错误: 测试错误'));

        // 测试正常状态
        final pet = PetEntity.createDefault(name: '测试宠物');
        final normalState = PetState.initial().copyWith(
          pets: [pet],
          currentPet: pet,
        );
        notifier.state = normalState;
        expect(container.read(petSystemStatusProvider), equals('桌宠系统正常'));
      });
    });

    group('状态一致性测试', () {
      test('所有派生提供者应该与主状态保持一致', () {
        final notifier = container.read(petProvider.notifier);
        final pets = [
          PetEntity.createDefault(
            name: '宠物1',
          ).copyWith(status: PetStatus.active),
          PetEntity.createDefault(
            name: '宠物2',
          ).copyWith(status: PetStatus.sick, health: 20),
        ];

        final stateWithPets = container
            .read(petProvider)
            .copyWith(pets: pets, currentPet: pets[0]);
        notifier.state = stateWithPets;

        // 验证所有派生状态都正确
        expect(container.read(currentPetProvider), equals(pets[0]));
        expect(container.read(petListProvider), equals(pets));
        expect(container.read(activePetCountProvider), equals(2));
        expect(container.read(petsNeedingAttentionProvider), equals(1));
        expect(container.read(petSystemStatusProvider), equals('桌宠系统正常'));
      });
    });
  });
}
