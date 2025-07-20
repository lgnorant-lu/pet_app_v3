/*
---------------------------------------------------------------
File name:          pet_data_manager_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠数据管理器测试
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import '../../../lib/core/services/pet_data_manager.dart';
import '../../../lib/core/services/pet_service.dart';
import '../../../lib/core/services/pet_behavior_service.dart';
import '../../../lib/core/pet/models/pet_entity.dart';
import '../../../lib/core/pet/models/pet_behavior.dart';

void main() {
  group('PetDataManager Tests', () {
    late PetDataManager dataManager;
    late PetService petService;
    late PetBehaviorService behaviorService;

    setUp(() {
      petService = PetService();
      behaviorService = PetBehaviorService();
      dataManager = PetDataManager(petService, behaviorService);
    });

    group('数据导出测试', () {
      test('应该能够导出所有数据', () async {
        final exportData = await dataManager.exportAllData();
        
        expect(exportData, isA<PetDataExport>());
        expect(exportData.version, isNotEmpty);
        expect(exportData.exportDate, isA<DateTime>());
        expect(exportData.pets, isA<List<PetEntity>>());
        expect(exportData.behaviors, isA<List<PetBehavior>>());
        expect(exportData.behaviorStatistics, isA<BehaviorStatistics>());
        expect(exportData.systemSettings, isA<Map<String, dynamic>>());
      });

      test('应该能够导出单个桌宠数据', () async {
        // 先创建一个测试桌宠
        final testPet = PetEntity.createDefault(name: '测试宠物');
        await petService.savePet(testPet);

        final exportData = await dataManager.exportPetData(testPet.id);
        
        expect(exportData.pets.length, equals(1));
        expect(exportData.pets.first.id, equals(testPet.id));
        expect(exportData.pets.first.name, equals(testPet.name));
      });

      test('导出不存在的桌宠应该抛出异常', () async {
        expect(
          () => dataManager.exportPetData('nonexistent'),
          throwsA(isA<PetDataException>()),
        );
      });
    });

    group('数据导入测试', () {
      test('应该能够导入桌宠数据', () async {
        final testPet = PetEntity.createDefault(name: '导入测试宠物');
        final exportData = PetDataExport(
          version: '1.0.0',
          exportDate: DateTime.now(),
          pets: [testPet],
          behaviors: [],
          behaviorStatistics: BehaviorStatistics.initial(),
          systemSettings: {},
        );

        final result = await dataManager.importData(exportData);
        
        expect(result.success, isTrue);
        expect(result.importedPets, contains(testPet.id));
        expect(result.errors, isEmpty);
      });

      test('应该能够跳过已存在的桌宠', () async {
        final testPet = PetEntity.createDefault(name: '重复测试宠物');
        
        // 先保存桌宠
        await petService.savePet(testPet);
        
        final exportData = PetDataExport(
          version: '1.0.0',
          exportDate: DateTime.now(),
          pets: [testPet],
          behaviors: [],
          behaviorStatistics: BehaviorStatistics.initial(),
          systemSettings: {},
        );

        final result = await dataManager.importData(
          exportData,
          overwriteExisting: false,
        );
        
        expect(result.skippedPets, contains(testPet.id));
      });

      test('应该能够覆盖已存在的桌宠', () async {
        final testPet = PetEntity.createDefault(name: '覆盖测试宠物');
        
        // 先保存桌宠
        await petService.savePet(testPet);
        
        final exportData = PetDataExport(
          version: '1.0.0',
          exportDate: DateTime.now(),
          pets: [testPet],
          behaviors: [],
          behaviorStatistics: BehaviorStatistics.initial(),
          systemSettings: {},
        );

        final result = await dataManager.importData(
          exportData,
          overwriteExisting: true,
        );
        
        expect(result.importedPets, contains(testPet.id));
      });
    });

    group('备份管理测试', () {
      test('应该能够创建备份', () async {
        final backupId = await dataManager.createBackup();
        
        expect(backupId, isNotEmpty);
        expect(backupId, startsWith('backup_'));
      });

      test('应该能够获取备份列表', () async {
        // 创建一个备份
        await dataManager.createBackup();
        
        final backups = await dataManager.getAllBackups();
        
        expect(backups, isA<List<BackupInfo>>());
        expect(backups.length, greaterThanOrEqualTo(1));
      });

      test('应该能够删除备份', () async {
        // 创建一个备份
        final backupId = await dataManager.createBackup();
        
        // 删除备份
        await dataManager.deleteBackup(backupId);
        
        // 验证备份已删除
        final backups = await dataManager.getAllBackups();
        expect(backups.where((b) => b.id == backupId), isEmpty);
      });

      test('应该能够恢复备份', () async {
        // 创建测试数据
        final testPet = PetEntity.createDefault(name: '备份测试宠物');
        await petService.savePet(testPet);
        
        // 创建备份
        final backupId = await dataManager.createBackup();
        
        // 清除数据
        await petService.deletePet(testPet.id);
        
        // 恢复备份
        final result = await dataManager.restoreBackup(backupId);
        
        expect(result.success, isTrue);
        expect(result.importedPets, contains(testPet.id));
      });
    });

    group('数据验证测试', () {
      test('应该能够验证数据完整性', () async {
        final report = await dataManager.validateDataIntegrity();
        
        expect(report, isA<DataIntegrityReport>());
        expect(report.isValid, isA<bool>());
        expect(report.corruptedPets, isA<List<String>>());
        expect(report.corruptedBehaviors, isA<List<String>>());
        expect(report.orphanedData, isA<List<String>>());
        expect(report.errors, isA<List<String>>());
      });

      test('应该能够修复数据', () async {
        final result = await dataManager.repairData();
        
        expect(result, isA<DataRepairResult>());
        expect(result.success, isA<bool>());
        expect(result.repairedPets, isA<List<String>>());
        expect(result.repairedBehaviors, isA<List<String>>());
        expect(result.removedOrphanedData, isA<List<String>>());
        expect(result.failedRepairs, isA<Map<String, String>>());
        expect(result.errors, isA<List<String>>());
      });
    });

    group('数据清除测试', () {
      test('应该能够清除所有数据', () async {
        // 创建测试数据
        final testPet = PetEntity.createDefault(name: '清除测试宠物');
        await petService.savePet(testPet);
        
        // 清除所有数据
        await dataManager.clearAllData();
        
        // 验证数据已清除
        final pets = await petService.getAllPets();
        expect(pets, isEmpty);
      });
    });

    group('异常处理测试', () {
      test('PetDataException应该包含错误信息', () {
        const exception = PetDataException('测试错误');
        
        expect(exception.message, equals('测试错误'));
        expect(exception.toString(), contains('测试错误'));
      });
    });

    group('数据模型测试', () {
      test('PetDataExport应该能够序列化和反序列化', () {
        final testPet = PetEntity.createDefault(name: '序列化测试宠物');
        final exportData = PetDataExport(
          version: '1.0.0',
          exportDate: DateTime.now(),
          pets: [testPet],
          behaviors: [],
          behaviorStatistics: BehaviorStatistics.initial(),
          systemSettings: {'test': 'value'},
        );

        final json = exportData.toJson();
        final recreated = PetDataExport.fromJson(json);
        
        expect(recreated.version, equals(exportData.version));
        expect(recreated.pets.length, equals(exportData.pets.length));
        expect(recreated.pets.first.id, equals(testPet.id));
        expect(recreated.systemSettings['test'], equals('value'));
      });

      test('BackupData应该能够序列化和反序列化', () {
        final testPet = PetEntity.createDefault(name: '备份序列化测试');
        final exportData = PetDataExport(
          version: '1.0.0',
          exportDate: DateTime.now(),
          pets: [testPet],
          behaviors: [],
          behaviorStatistics: BehaviorStatistics.initial(),
          systemSettings: {},
        );
        
        final backupData = BackupData(
          id: 'test_backup',
          createdAt: DateTime.now(),
          exportData: exportData,
        );

        final json = backupData.toJson();
        final recreated = BackupData.fromJson(json);
        
        expect(recreated.id, equals(backupData.id));
        expect(recreated.exportData.pets.length, equals(1));
        expect(recreated.exportData.pets.first.id, equals(testPet.id));
      });

      test('PetDataImportResult应该正确跟踪导入结果', () {
        final result = PetDataImportResult();
        
        result.success = true;
        result.importedPets.add('pet1');
        result.importedBehaviors.add('behavior1');
        result.skippedPets.add('pet2');
        result.failedPets['pet3'] = '导入失败';
        result.errors.add('测试错误');
        
        expect(result.success, isTrue);
        expect(result.importedPets, contains('pet1'));
        expect(result.importedBehaviors, contains('behavior1'));
        expect(result.skippedPets, contains('pet2'));
        expect(result.failedPets['pet3'], equals('导入失败'));
        expect(result.errors, contains('测试错误'));
      });

      test('BackupInfo应该包含备份基本信息', () {
        final backupInfo = BackupInfo(
          id: 'test_backup',
          createdAt: DateTime.now(),
          petCount: 5,
          behaviorCount: 10,
        );
        
        expect(backupInfo.id, equals('test_backup'));
        expect(backupInfo.petCount, equals(5));
        expect(backupInfo.behaviorCount, equals(10));
        expect(backupInfo.createdAt, isA<DateTime>());
      });

      test('DataIntegrityReport应该正确报告数据状态', () {
        final report = DataIntegrityReport();
        
        report.isValid = false;
        report.corruptedPets.add('corrupt_pet');
        report.corruptedBehaviors.add('corrupt_behavior');
        report.orphanedData.add('orphaned_key');
        report.errors.add('验证错误');
        
        expect(report.isValid, isFalse);
        expect(report.corruptedPets, contains('corrupt_pet'));
        expect(report.corruptedBehaviors, contains('corrupt_behavior'));
        expect(report.orphanedData, contains('orphaned_key'));
        expect(report.errors, contains('验证错误'));
      });

      test('DataRepairResult应该正确跟踪修复结果', () {
        final result = DataRepairResult();
        
        result.success = true;
        result.repairedPets.add('repaired_pet');
        result.repairedBehaviors.add('repaired_behavior');
        result.removedOrphanedData.add('removed_key');
        result.failedRepairs['failed_item'] = '修复失败';
        result.errors.add('修复错误');
        
        expect(result.success, isTrue);
        expect(result.repairedPets, contains('repaired_pet'));
        expect(result.repairedBehaviors, contains('repaired_behavior'));
        expect(result.removedOrphanedData, contains('removed_key'));
        expect(result.failedRepairs['failed_item'], equals('修复失败'));
        expect(result.errors, contains('修复错误'));
      });
    });
  });
}
