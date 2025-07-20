/*
---------------------------------------------------------------
File name:          pet_state_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠状态模型测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/models/pet_state.dart';
import '../../../../lib/core/pet/models/pet_entity.dart';
import '../../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetState Tests', () {
    group('初始状态测试', () {
      test('应该能够创建初始状态', () {
        final state = PetState.initial();
        
        expect(state.currentPet, isNull);
        expect(state.pets, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.isEnabled, isTrue);
        expect(state.isVisible, isTrue);
        expect(state.interactionMode, equals(PetInteractionMode.normal));
        expect(state.lastUpdate, isA<DateTime>());
      });
    });

    group('状态复制测试', () {
      late PetState initialState;
      late PetEntity testPet;

      setUp(() {
        initialState = PetState.initial();
        testPet = PetEntity.createDefault(name: '测试宠物');
      });

      test('应该能够复制并更新状态', () {
        final updatedState = initialState.copyWith(
          currentPet: testPet,
          isLoading: true,
          isEnabled: false,
        );
        
        expect(updatedState.currentPet, equals(testPet));
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.isEnabled, isFalse);
        
        // 其他属性应该保持不变
        expect(updatedState.pets, equals(initialState.pets));
        expect(updatedState.isVisible, equals(initialState.isVisible));
        expect(updatedState.interactionMode, equals(initialState.interactionMode));
      });

      test('应该能够创建加载状态', () {
        final loadingState = initialState.copyWithLoading(true);
        
        expect(loadingState.isLoading, isTrue);
        expect(loadingState.error, isNull);
        
        final notLoadingState = loadingState.copyWithLoading(false);
        expect(notLoadingState.isLoading, isFalse);
      });

      test('应该能够创建错误状态', () {
        const errorMessage = '测试错误';
        final errorState = initialState.copyWithError(errorMessage);
        
        expect(errorState.isLoading, isFalse);
        expect(errorState.error, equals(errorMessage));
      });
    });

    group('状态属性测试', () {
      late PetEntity activePet;
      late PetEntity inactivePet;
      late PetEntity needsAttentionPet;

      setUp(() {
        activePet = PetEntity.createDefault(name: '活跃宠物')
            .copyWith(status: PetStatus.active);
        inactivePet = PetEntity.createDefault(name: '非活跃宠物')
            .copyWith(status: PetStatus.offline);
        needsAttentionPet = PetEntity.createDefault(name: '需要关注的宠物')
            .copyWith(
              status: PetStatus.sick,
              health: 20,
            );
      });

      test('应该正确判断是否有活跃桌宠', () {
        final stateWithActivePet = PetState.initial().copyWith(
          currentPet: activePet,
        );
        
        final stateWithInactivePet = PetState.initial().copyWith(
          currentPet: inactivePet,
        );
        
        final stateWithoutPet = PetState.initial();
        
        expect(stateWithActivePet.hasActivePet, isTrue);
        expect(stateWithInactivePet.hasActivePet, isFalse);
        expect(stateWithoutPet.hasActivePet, isFalse);
      });

      test('应该正确判断是否有桌宠', () {
        final stateWithPets = PetState.initial().copyWith(
          pets: [activePet, inactivePet],
        );
        
        final stateWithoutPets = PetState.initial();
        
        expect(stateWithPets.hasPets, isTrue);
        expect(stateWithoutPets.hasPets, isFalse);
      });

      test('应该正确计算活跃桌宠数量', () {
        final state = PetState.initial().copyWith(
          pets: [activePet, inactivePet, activePet.copyWith(id: 'pet2')],
        );
        
        expect(state.activePetCount, equals(2));
      });

      test('应该正确计算需要关注的桌宠数量', () {
        final state = PetState.initial().copyWith(
          pets: [activePet, needsAttentionPet, needsAttentionPet.copyWith(id: 'pet2')],
        );
        
        expect(state.petsNeedingAttention, equals(2));
      });

      test('应该正确判断桌宠系统是否可用', () {
        final availableState = PetState.initial().copyWith(
          isEnabled: true,
          isLoading: false,
          error: null,
        );
        
        final disabledState = PetState.initial().copyWith(
          isEnabled: false,
        );
        
        final loadingState = PetState.initial().copyWith(
          isLoading: true,
        );
        
        final errorState = PetState.initial().copyWith(
          error: '错误',
        );
        
        expect(availableState.isAvailable, isTrue);
        expect(disabledState.isAvailable, isFalse);
        expect(loadingState.isAvailable, isFalse);
        expect(errorState.isAvailable, isFalse);
      });

      test('应该提供正确的状态描述', () {
        final disabledState = PetState.initial().copyWith(isEnabled: false);
        expect(disabledState.statusDescription, equals('桌宠系统已禁用'));
        
        final loadingState = PetState.initial().copyWith(isLoading: true);
        expect(loadingState.statusDescription, equals('正在加载桌宠...'));
        
        final errorState = PetState.initial().copyWith(error: '测试错误');
        expect(errorState.statusDescription, equals('桌宠系统错误: 测试错误'));
        
        final noPetsState = PetState.initial();
        expect(noPetsState.statusDescription, equals('暂无桌宠'));
        
        final noActivePetState = PetState.initial().copyWith(
          pets: [inactivePet],
        );
        expect(noActivePetState.statusDescription, equals('桌宠未激活'));
        
        final normalState = PetState.initial().copyWith(
          pets: [activePet],
          currentPet: activePet,
        );
        expect(normalState.statusDescription, equals('桌宠系统正常'));
      });
    });

    group('相等性测试', () {
      test('相同属性的状态应该相等', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        
        final state1 = PetState.initial().copyWith(
          currentPet: pet,
          isLoading: true,
          isEnabled: false,
        );
        
        final state2 = PetState.initial().copyWith(
          currentPet: pet,
          isLoading: true,
          isEnabled: false,
        );
        
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同属性的状态应该不相等', () {
        final state1 = PetState.initial().copyWith(isLoading: true);
        final state2 = PetState.initial().copyWith(isLoading: false);
        
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });

    group('字符串转换测试', () {
      test('toString应该包含关键信息', () {
        final pet = PetEntity.createDefault(name: '测试宠物');
        final state = PetState.initial().copyWith(
          currentPet: pet,
          pets: [pet],
          isLoading: true,
          error: '测试错误',
          isEnabled: false,
        );
        
        final str = state.toString();
        
        expect(str, contains(pet.name));
        expect(str, contains('1')); // pets count
        expect(str, contains('true')); // isLoading
        expect(str, contains('测试错误'));
        expect(str, contains('false')); // isEnabled
      });
    });
  });

  group('PetInteractionMode Tests', () {
    test('应该包含所有预期的交互模式', () {
      expect(PetInteractionMode.values.length, equals(5));
      expect(PetInteractionMode.values, contains(PetInteractionMode.normal));
      expect(PetInteractionMode.values, contains(PetInteractionMode.quiet));
      expect(PetInteractionMode.values, contains(PetInteractionMode.focus));
      expect(PetInteractionMode.values, contains(PetInteractionMode.sleep));
      expect(PetInteractionMode.values, contains(PetInteractionMode.play));
    });

    test('应该能够通过ID获取交互模式', () {
      expect(PetInteractionMode.fromId('normal'), equals(PetInteractionMode.normal));
      expect(PetInteractionMode.fromId('quiet'), equals(PetInteractionMode.quiet));
      expect(PetInteractionMode.fromId('invalid'), equals(PetInteractionMode.normal));
    });

    test('应该有正确的显示名称', () {
      expect(PetInteractionMode.normal.displayName, equals('正常模式'));
      expect(PetInteractionMode.quiet.displayName, equals('安静模式'));
      expect(PetInteractionMode.focus.displayName, equals('专注模式'));
      expect(PetInteractionMode.sleep.displayName, equals('睡眠模式'));
      expect(PetInteractionMode.play.displayName, equals('游戏模式'));
    });

    test('toString应该返回显示名称', () {
      expect(PetInteractionMode.normal.toString(), equals('正常模式'));
      expect(PetInteractionMode.quiet.toString(), equals('安静模式'));
    });
  });
}
