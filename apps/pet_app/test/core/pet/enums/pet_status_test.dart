/*
---------------------------------------------------------------
File name:          pet_status_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠状态枚举测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetStatus Tests', () {
    group('基础功能测试', () {
      test('应该包含所有预期的状态类型', () {
        expect(PetStatus.values.length, equals(15));
        
        // 验证生命周期状态
        expect(PetStatus.values, contains(PetStatus.unborn));
        expect(PetStatus.values, contains(PetStatus.hatching));
        expect(PetStatus.values, contains(PetStatus.baby));
        expect(PetStatus.values, contains(PetStatus.growing));
        expect(PetStatus.values, contains(PetStatus.adult));
        
        // 验证健康状态
        expect(PetStatus.values, contains(PetStatus.healthy));
        expect(PetStatus.values, contains(PetStatus.active));
        expect(PetStatus.values, contains(PetStatus.sick));
        expect(PetStatus.values, contains(PetStatus.injured));
        
        // 验证系统状态
        expect(PetStatus.values, contains(PetStatus.offline));
        expect(PetStatus.values, contains(PetStatus.maintenance));
        expect(PetStatus.values, contains(PetStatus.deleted));
      });

      test('应该能够通过ID获取状态', () {
        expect(PetStatus.fromId('active'), equals(PetStatus.active));
        expect(PetStatus.fromId('healthy'), equals(PetStatus.healthy));
        expect(PetStatus.fromId('sick'), equals(PetStatus.sick));
        
        // 测试无效ID返回默认值
        expect(PetStatus.fromId('invalid'), equals(PetStatus.unborn));
      });

      test('应该有正确的显示名称和表情符号', () {
        expect(PetStatus.active.displayName, equals('活跃'));
        expect(PetStatus.active.emoji, equals('✨'));
        
        expect(PetStatus.healthy.displayName, equals('健康'));
        expect(PetStatus.healthy.emoji, equals('💚'));
        
        expect(PetStatus.sick.displayName, equals('生病'));
        expect(PetStatus.sick.emoji, equals('🤒'));
      });
    });

    group('状态分类测试', () {
      test('应该正确分类生命周期状态', () {
        final lifecycleStatuses = PetStatus.lifecycleStatuses;
        expect(lifecycleStatuses, contains(PetStatus.unborn));
        expect(lifecycleStatuses, contains(PetStatus.hatching));
        expect(lifecycleStatuses, contains(PetStatus.baby));
        expect(lifecycleStatuses, contains(PetStatus.growing));
        expect(lifecycleStatuses, contains(PetStatus.adult));
        expect(lifecycleStatuses.length, equals(5));
      });

      test('应该正确分类健康状态', () {
        final healthStatuses = PetStatus.healthStatuses;
        expect(healthStatuses, contains(PetStatus.healthy));
        expect(healthStatuses, contains(PetStatus.active));
        expect(healthStatuses, contains(PetStatus.tired));
        expect(healthStatuses, contains(PetStatus.weak));
        expect(healthStatuses, contains(PetStatus.sick));
        expect(healthStatuses, contains(PetStatus.injured));
        expect(healthStatuses, contains(PetStatus.recovering));
        expect(healthStatuses.length, equals(7));
      });

      test('应该正确分类系统状态', () {
        final systemStatuses = PetStatus.systemStatuses;
        expect(systemStatuses, contains(PetStatus.offline));
        expect(systemStatuses, contains(PetStatus.maintenance));
        expect(systemStatuses, contains(PetStatus.deleted));
        expect(systemStatuses.length, equals(3));
      });

      test('应该正确判断状态类型', () {
        expect(PetStatus.baby.isLifecycle, isTrue);
        expect(PetStatus.healthy.isHealth, isTrue);
        expect(PetStatus.offline.isSystem, isTrue);
        
        expect(PetStatus.baby.isHealth, isFalse);
        expect(PetStatus.healthy.isSystem, isFalse);
        expect(PetStatus.offline.isLifecycle, isFalse);
      });
    });

    group('状态属性测试', () {
      test('应该正确判断活跃状态', () {
        expect(PetStatus.active.isActive, isTrue);
        expect(PetStatus.healthy.isActive, isTrue);
        expect(PetStatus.baby.isActive, isTrue);
        
        expect(PetStatus.unborn.isActive, isFalse);
        expect(PetStatus.offline.isActive, isFalse);
        expect(PetStatus.maintenance.isActive, isFalse);
        expect(PetStatus.deleted.isActive, isFalse);
      });

      test('应该正确判断健康状态', () {
        expect(PetStatus.healthy.isHealthy, isTrue);
        expect(PetStatus.active.isHealthy, isTrue);
        expect(PetStatus.baby.isHealthy, isTrue);
        expect(PetStatus.growing.isHealthy, isTrue);
        expect(PetStatus.adult.isHealthy, isTrue);
        
        expect(PetStatus.sick.isHealthy, isFalse);
        expect(PetStatus.injured.isHealthy, isFalse);
        expect(PetStatus.weak.isHealthy, isFalse);
      });

      test('应该正确判断需要关注的状态', () {
        expect(PetStatus.tired.needsAttention, isTrue);
        expect(PetStatus.weak.needsAttention, isTrue);
        expect(PetStatus.sick.needsAttention, isTrue);
        expect(PetStatus.injured.needsAttention, isTrue);
        
        expect(PetStatus.healthy.needsAttention, isFalse);
        expect(PetStatus.active.needsAttention, isFalse);
      });

      test('应该正确判断可交互状态', () {
        expect(PetStatus.active.canInteract, isTrue);
        expect(PetStatus.healthy.canInteract, isTrue);
        expect(PetStatus.baby.canInteract, isTrue);
        expect(PetStatus.sick.canInteract, isTrue);
        
        expect(PetStatus.unborn.canInteract, isFalse);
        expect(PetStatus.hatching.canInteract, isFalse);
        expect(PetStatus.offline.canInteract, isFalse);
        expect(PetStatus.maintenance.canInteract, isFalse);
        expect(PetStatus.deleted.canInteract, isFalse);
      });

      test('应该有正确的优先级排序', () {
        expect(PetStatus.active.priority, equals(14));
        expect(PetStatus.adult.priority, equals(13));
        expect(PetStatus.healthy.priority, equals(12));
        expect(PetStatus.deleted.priority, equals(0));
        expect(PetStatus.maintenance.priority, equals(1));
        
        // 验证优先级范围
        for (final status in PetStatus.values) {
          expect(status.priority, greaterThanOrEqualTo(0));
          expect(status.priority, lessThanOrEqualTo(14));
        }
      });

      test('应该有有效的颜色代码', () {
        for (final status in PetStatus.values) {
          expect(status.colorHex, matches(r'^#[0-9A-F]{6}$'));
        }
        
        expect(PetStatus.active.colorHex, equals('#4CAF50')); // 绿色
        expect(PetStatus.sick.colorHex, equals('#F44336')); // 红色
        expect(PetStatus.offline.colorHex, equals('#9E9E9E')); // 灰色
      });
    });

    group('字符串转换测试', () {
      test('toString应该返回显示名称', () {
        expect(PetStatus.active.toString(), equals('活跃'));
        expect(PetStatus.healthy.toString(), equals('健康'));
        expect(PetStatus.sick.toString(), equals('生病'));
      });
    });
  });
}
