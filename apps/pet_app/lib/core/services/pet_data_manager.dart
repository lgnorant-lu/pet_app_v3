/*
---------------------------------------------------------------
File name:          pet_data_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠数据管理器 - 处理桌宠数据的导入导出和备份
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../pet/models/pet_entity.dart';
import '../pet/models/pet_behavior.dart';
import 'pet_service.dart';
import 'pet_behavior_service.dart';

/// 桌宠数据管理器提供者
final petDataManagerProvider = Provider<PetDataManager>((ref) {
  return PetDataManager(
    ref.read(petServiceProvider),
    ref.read(petBehaviorServiceProvider),
  );
});

/// 桌宠数据管理器
///
/// 负责桌宠数据的导入、导出、备份和恢复
class PetDataManager {
  final PetService _petService;
  final PetBehaviorService _behaviorService;

  PetDataManager(this._petService, this._behaviorService);

  /// 导出所有桌宠数据
  Future<PetDataExport> exportAllData() async {
    try {
      // 获取所有桌宠
      final pets = await _petService.getAllPets();

      // 获取所有行为
      final behaviors = await _behaviorService.getAllBehaviors();

      // 获取行为统计
      final behaviorStats = await _behaviorService.getBehaviorStatistics();

      // 获取系统设置
      final settings = await _getSystemSettings();

      return PetDataExport(
        version: '1.0.0',
        exportDate: DateTime.now(),
        pets: pets,
        behaviors: behaviors,
        behaviorStatistics: behaviorStats,
        systemSettings: settings,
      );
    } catch (e) {
      throw PetDataException('导出数据失败: $e');
    }
  }

  /// 导出单个桌宠数据
  Future<PetDataExport> exportPetData(String petId) async {
    try {
      final pet = await _petService.getPet(petId);
      if (pet == null) {
        throw PetDataException('桌宠不存在: $petId');
      }

      return PetDataExport(
        version: '1.0.0',
        exportDate: DateTime.now(),
        pets: [pet],
        behaviors: [],
        behaviorStatistics: BehaviorStatistics.initial(),
        systemSettings: {},
      );
    } catch (e) {
      throw PetDataException('导出桌宠数据失败: $e');
    }
  }

  /// 导入桌宠数据
  Future<PetDataImportResult> importData(
    PetDataExport exportData, {
    bool overwriteExisting = false,
    bool importBehaviors = true,
    bool importSettings = true,
  }) async {
    final result = PetDataImportResult();

    try {
      // 验证数据格式
      _validateExportData(exportData);

      // 导入桌宠
      for (final pet in exportData.pets) {
        try {
          final existingPet = await _petService.getPet(pet.id);

          if (existingPet != null && !overwriteExisting) {
            result.skippedPets.add(pet.id);
            continue;
          }

          await _petService.savePet(pet);
          result.importedPets.add(pet.id);
        } catch (e) {
          result.failedPets[pet.id] = e.toString();
        }
      }

      // 导入行为
      if (importBehaviors) {
        for (final behavior in exportData.behaviors) {
          try {
            await _behaviorService.saveBehavior(behavior);
            result.importedBehaviors.add(behavior.id);
          } catch (e) {
            result.failedBehaviors[behavior.id] = e.toString();
          }
        }

        // 导入行为统计
        try {
          await _behaviorService.updateBehaviorStatistics(
            exportData.behaviorStatistics,
          );
        } catch (e) {
          result.errors.add('导入行为统计失败: $e');
        }
      }

      // 导入系统设置
      if (importSettings) {
        try {
          await _importSystemSettings(exportData.systemSettings);
        } catch (e) {
          result.errors.add('导入系统设置失败: $e');
        }
      }

      result.success = true;
      return result;
    } catch (e) {
      result.success = false;
      result.errors.add('导入数据失败: $e');
      return result;
    }
  }

  /// 创建数据备份
  Future<String> createBackup() async {
    try {
      final exportData = await exportAllData();
      final backupData = BackupData(
        id: _generateBackupId(),
        createdAt: DateTime.now(),
        exportData: exportData,
      );

      await _saveBackup(backupData);
      return backupData.id;
    } catch (e) {
      throw PetDataException('创建备份失败: $e');
    }
  }

  /// 恢复数据备份
  Future<PetDataImportResult> restoreBackup(String backupId) async {
    try {
      final backupData = await _loadBackup(backupId);
      if (backupData == null) {
        throw PetDataException('备份不存在: $backupId');
      }

      return await importData(
        backupData.exportData,
        overwriteExisting: true,
        importBehaviors: true,
        importSettings: true,
      );
    } catch (e) {
      throw PetDataException('恢复备份失败: $e');
    }
  }

  /// 获取所有备份
  Future<List<BackupInfo>> getAllBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupIds = prefs.getStringList('backup_ids') ?? [];

      final backups = <BackupInfo>[];
      for (final id in backupIds) {
        final backupJson = prefs.getString('backup_$id');
        if (backupJson != null) {
          final backupData = BackupData.fromJson(jsonDecode(backupJson));
          backups.add(
            BackupInfo(
              id: backupData.id,
              createdAt: backupData.createdAt,
              petCount: backupData.exportData.pets.length,
              behaviorCount: backupData.exportData.behaviors.length,
            ),
          );
        }
      }

      // 按创建时间倒序排列
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      throw PetDataException('获取备份列表失败: $e');
    }
  }

  /// 删除备份
  Future<void> deleteBackup(String backupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupIds = prefs.getStringList('backup_ids') ?? [];

      backupIds.remove(backupId);
      await prefs.setStringList('backup_ids', backupIds);
      await prefs.remove('backup_$backupId');
    } catch (e) {
      throw PetDataException('删除备份失败: $e');
    }
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    try {
      await _petService.clearAllData();
      await _behaviorService.clearAllData();
      await _clearSystemSettings();
      await _clearAllBackups();
    } catch (e) {
      throw PetDataException('清除数据失败: $e');
    }
  }

  /// 验证数据完整性
  Future<DataIntegrityReport> validateDataIntegrity() async {
    final report = DataIntegrityReport();

    try {
      // 检查桌宠数据
      final pets = await _petService.getAllPets();
      for (final pet in pets) {
        if (!_isValidPet(pet)) {
          report.corruptedPets.add(pet.id);
        }
      }

      // 检查行为数据
      final behaviors = await _behaviorService.getAllBehaviors();
      for (final behavior in behaviors) {
        if (!_isValidBehavior(behavior)) {
          report.corruptedBehaviors.add(behavior.id);
        }
      }

      // 检查数据一致性
      final orphanedData = await _findOrphanedData();
      report.orphanedData.addAll(orphanedData);

      report.isValid =
          report.corruptedPets.isEmpty &&
          report.corruptedBehaviors.isEmpty &&
          report.orphanedData.isEmpty;

      return report;
    } catch (e) {
      report.isValid = false;
      report.errors.add('验证数据完整性失败: $e');
      return report;
    }
  }

  /// 修复数据
  Future<DataRepairResult> repairData() async {
    final result = DataRepairResult();

    try {
      final integrityReport = await validateDataIntegrity();

      // 修复损坏的桌宠数据
      for (final petId in integrityReport.corruptedPets) {
        try {
          await _repairPet(petId);
          result.repairedPets.add(petId);
        } catch (e) {
          result.failedRepairs[petId] = e.toString();
        }
      }

      // 修复损坏的行为数据
      for (final behaviorId in integrityReport.corruptedBehaviors) {
        try {
          await _repairBehavior(behaviorId);
          result.repairedBehaviors.add(behaviorId);
        } catch (e) {
          result.failedRepairs[behaviorId] = e.toString();
        }
      }

      // 清理孤立数据
      for (final orphanedKey in integrityReport.orphanedData) {
        try {
          await _removeOrphanedData(orphanedKey);
          result.removedOrphanedData.add(orphanedKey);
        } catch (e) {
          result.failedRepairs[orphanedKey] = e.toString();
        }
      }

      result.success = result.failedRepairs.isEmpty;
      return result;
    } catch (e) {
      result.success = false;
      result.errors.add('修复数据失败: $e');
      return result;
    }
  }

  /// 获取系统设置
  Future<Map<String, dynamic>> _getSystemSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'petSystemEnabled': prefs.getBool('pet_system_enabled') ?? true,
      'behaviorSystemEnabled': prefs.getBool('behavior_system_enabled') ?? true,
      'petVisibility': prefs.getBool('pet_visibility') ?? true,
      'interactionMode': prefs.getString('interaction_mode') ?? 'normal',
    };
  }

  /// 导入系统设置
  Future<void> _importSystemSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    }
  }

  /// 清除系统设置
  Future<void> _clearSystemSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'pet_system_enabled',
      'behavior_system_enabled',
      'pet_visibility',
      'interaction_mode',
    ];

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// 保存备份
  Future<void> _saveBackup(BackupData backupData) async {
    final prefs = await SharedPreferences.getInstance();

    // 保存备份数据
    final backupJson = jsonEncode(backupData.toJson());
    await prefs.setString('backup_${backupData.id}', backupJson);

    // 更新备份ID列表
    final backupIds = prefs.getStringList('backup_ids') ?? [];
    if (!backupIds.contains(backupData.id)) {
      backupIds.add(backupData.id);
      await prefs.setStringList('backup_ids', backupIds);
    }
  }

  /// 加载备份
  Future<BackupData?> _loadBackup(String backupId) async {
    final prefs = await SharedPreferences.getInstance();
    final backupJson = prefs.getString('backup_$backupId');

    if (backupJson == null) return null;

    return BackupData.fromJson(jsonDecode(backupJson));
  }

  /// 清除所有备份
  Future<void> _clearAllBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final backupIds = prefs.getStringList('backup_ids') ?? [];

    for (final id in backupIds) {
      await prefs.remove('backup_$id');
    }

    await prefs.remove('backup_ids');
  }

  /// 验证导出数据
  void _validateExportData(PetDataExport exportData) {
    if (exportData.version.isEmpty) {
      throw PetDataException('无效的数据版本');
    }

    for (final pet in exportData.pets) {
      if (!_isValidPet(pet)) {
        throw PetDataException('无效的桌宠数据: ${pet.id}');
      }
    }

    for (final behavior in exportData.behaviors) {
      if (!_isValidBehavior(behavior)) {
        throw PetDataException('无效的行为数据: ${behavior.id}');
      }
    }
  }

  /// 验证桌宠数据
  bool _isValidPet(PetEntity pet) {
    return pet.id.isNotEmpty &&
        pet.name.isNotEmpty &&
        pet.type.isNotEmpty &&
        pet.health >= 0 &&
        pet.health <= 100 &&
        pet.energy >= 0 &&
        pet.energy <= 100 &&
        pet.hunger >= 0 &&
        pet.hunger <= 100 &&
        pet.happiness >= 0 &&
        pet.happiness <= 100 &&
        pet.cleanliness >= 0 &&
        pet.cleanliness <= 100;
  }

  /// 验证行为数据
  bool _isValidBehavior(PetBehavior behavior) {
    return behavior.id.isNotEmpty &&
        behavior.name.isNotEmpty &&
        behavior.priority >= 0 &&
        behavior.duration >= 0;
  }

  /// 查找孤立数据
  Future<List<String>> _findOrphanedData() async {
    // TODO: 实现孤立数据检测逻辑
    return [];
  }

  /// 修复桌宠数据
  Future<void> _repairPet(String petId) async {
    // TODO: 实现桌宠数据修复逻辑
  }

  /// 修复行为数据
  Future<void> _repairBehavior(String behaviorId) async {
    // TODO: 实现行为数据修复逻辑
  }

  /// 移除孤立数据
  Future<void> _removeOrphanedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// 生成备份ID
  String _generateBackupId() {
    return 'backup_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// 桌宠数据导出
class PetDataExport {
  final String version;
  final DateTime exportDate;
  final List<PetEntity> pets;
  final List<PetBehavior> behaviors;
  final BehaviorStatistics behaviorStatistics;
  final Map<String, dynamic> systemSettings;

  const PetDataExport({
    required this.version,
    required this.exportDate,
    required this.pets,
    required this.behaviors,
    required this.behaviorStatistics,
    required this.systemSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'pets': pets.map((pet) => pet.toJson()).toList(),
      'behaviors': behaviors.map((behavior) => behavior.toJson()).toList(),
      'behaviorStatistics': behaviorStatistics.toJson(),
      'systemSettings': systemSettings,
    };
  }

  factory PetDataExport.fromJson(Map<String, dynamic> json) {
    return PetDataExport(
      version: json['version'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
      pets: (json['pets'] as List<dynamic>)
          .map((petJson) => PetEntity.fromJson(petJson))
          .toList(),
      behaviors: (json['behaviors'] as List<dynamic>)
          .map((behaviorJson) => PetBehavior.fromJson(behaviorJson))
          .toList(),
      behaviorStatistics: BehaviorStatistics.fromJson(
        json['behaviorStatistics'],
      ),
      systemSettings: Map<String, dynamic>.from(json['systemSettings']),
    );
  }
}

/// 数据导入结果
class PetDataImportResult {
  bool success = false;
  final List<String> importedPets = [];
  final List<String> importedBehaviors = [];
  final List<String> skippedPets = [];
  final Map<String, String> failedPets = {};
  final Map<String, String> failedBehaviors = {};
  final List<String> errors = [];
}

/// 备份数据
class BackupData {
  final String id;
  final DateTime createdAt;
  final PetDataExport exportData;

  const BackupData({
    required this.id,
    required this.createdAt,
    required this.exportData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'exportData': exportData.toJson(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      exportData: PetDataExport.fromJson(json['exportData']),
    );
  }
}

/// 备份信息
class BackupInfo {
  final String id;
  final DateTime createdAt;
  final int petCount;
  final int behaviorCount;

  const BackupInfo({
    required this.id,
    required this.createdAt,
    required this.petCount,
    required this.behaviorCount,
  });
}

/// 数据完整性报告
class DataIntegrityReport {
  bool isValid = true;
  final List<String> corruptedPets = [];
  final List<String> corruptedBehaviors = [];
  final List<String> orphanedData = [];
  final List<String> errors = [];
}

/// 数据修复结果
class DataRepairResult {
  bool success = false;
  final List<String> repairedPets = [];
  final List<String> repairedBehaviors = [];
  final List<String> removedOrphanedData = [];
  final Map<String, String> failedRepairs = {};
  final List<String> errors = [];
}

/// 桌宠数据异常
class PetDataException implements Exception {
  final String message;

  const PetDataException(this.message);

  @override
  String toString() => 'PetDataException: $message';
}
