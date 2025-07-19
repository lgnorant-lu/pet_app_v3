/*
---------------------------------------------------------------
File name:          project_storage.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意项目存储系统
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 项目存储系统实现;
---------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:creative_workshop/src/core/projects/project_manager.dart';

/// 项目存储接口
abstract class ProjectStorage {
  /// 保存项目
  Future<bool> saveProject(CreativeProject project);

  /// 加载项目
  Future<CreativeProject?> loadProject(String projectId);

  /// 删除项目
  Future<bool> deleteProject(String projectId);

  /// 获取所有项目ID
  Future<List<String>> getAllProjectIds();

  /// 检查项目是否存在
  Future<bool> projectExists(String projectId);

  /// 获取项目文件大小
  Future<int> getProjectSize(String projectId);
}

/// 本地文件存储实现
class LocalProjectStorage implements ProjectStorage {
  LocalProjectStorage({String? storageDirectory}) {
    _storageDirectory = storageDirectory ?? _getDefaultStorageDirectory();
  }

  late final String _storageDirectory;

  /// 获取默认存储目录
  String _getDefaultStorageDirectory() {
    if (kIsWeb) {
      // Web平台使用浏览器存储
      return '/creative_workshop/projects';
    } else {
      // 桌面和移动平台使用本地文件系统
      final homeDir = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      return path.join(homeDir, '.creative_workshop', 'projects');
    }
  }

  /// 获取项目文件路径
  String _getProjectFilePath(String projectId) =>
      path.join(_storageDirectory, '$projectId.json');

  /// 确保存储目录存在
  Future<void> _ensureStorageDirectoryExists() async {
    if (!kIsWeb) {
      final directory = Directory(_storageDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  @override
  Future<bool> saveProject(CreativeProject project) async {
    try {
      await _ensureStorageDirectoryExists();

      final filePath = _getProjectFilePath(project.id);
      final projectJson = project.toJson();
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(projectJson);

      if (kIsWeb) {
        // Web平台使用localStorage存储项目数据
        return await _saveProjectToWeb(project.id, jsonString);
      } else {
        final file = File(filePath);
        await file.writeAsString(jsonString);
        debugPrint('本地存储: 项目已保存到 $filePath');
        return true;
      }
    } catch (e) {
      debugPrint('保存项目失败: $e');
      return false;
    }
  }

  @override
  Future<CreativeProject?> loadProject(String projectId) async {
    try {
      final filePath = _getProjectFilePath(projectId);

      if (kIsWeb) {
        // Web平台从localStorage加载
        final jsonString = await _loadProjectFromWeb(projectId);
        if (jsonString != null) {
          final projectJson = jsonDecode(jsonString) as Map<String, dynamic>;
          return CreativeProject.fromJson(projectJson);
        }
        return null;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return null;
        }

        final jsonString = await file.readAsString();
        final projectJson = jsonDecode(jsonString) as Map<String, dynamic>;
        final project = CreativeProject.fromJson(projectJson);

        debugPrint('本地存储: 项目已加载 $projectId');
        return project;
      }
    } catch (e) {
      debugPrint('加载项目失败: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteProject(String projectId) async {
    try {
      final filePath = _getProjectFilePath(projectId);

      if (kIsWeb) {
        // Web平台删除存储
        debugPrint('Web存储: 删除项目 $projectId');
        return true;
      } else {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('本地存储: 项目已删除 $projectId');
        }
        return true;
      }
    } catch (e) {
      debugPrint('删除项目失败: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getAllProjectIds() async {
    try {
      await _ensureStorageDirectoryExists();

      if (kIsWeb) {
        // Web平台获取所有项目ID
        debugPrint('Web存储: 获取所有项目ID');
        return <String>[]; // 简化处理
      } else {
        final directory = Directory(_storageDirectory);
        if (!await directory.exists()) {
          return <String>[];
        }

        final files = await directory.list().toList();
        final projectIds = <String>[];

        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            final fileName = path.basenameWithoutExtension(file.path);
            projectIds.add(fileName);
          }
        }

        debugPrint('本地存储: 找到 ${projectIds.length} 个项目');
        return projectIds;
      }
    } catch (e) {
      debugPrint('获取项目ID列表失败: $e');
      return <String>[];
    }
  }

  @override
  Future<bool> projectExists(String projectId) async {
    try {
      final filePath = _getProjectFilePath(projectId);

      if (kIsWeb) {
        // Web平台检查项目存在性
        return false; // 简化处理
      } else {
        final file = File(filePath);
        return await file.exists();
      }
    } catch (e) {
      debugPrint('检查项目存在性失败: $e');
      return false;
    }
  }

  @override
  Future<int> getProjectSize(String projectId) async {
    try {
      final filePath = _getProjectFilePath(projectId);

      if (kIsWeb) {
        // Web平台获取项目大小
        return 0; // 简化处理
      } else {
        final file = File(filePath);
        if (await file.exists()) {
          final stat = await file.stat();
          return stat.size;
        }
        return 0;
      }
    } catch (e) {
      debugPrint('获取项目大小失败: $e');
      return 0;
    }
  }

  /// Web平台保存项目到localStorage
  Future<bool> _saveProjectToWeb(String projectId, String jsonString) async {
    try {
      if (kIsWeb) {
        // 使用SharedPreferences在Web平台存储
        // 这里简化实现，实际应该使用IndexedDB处理大文件
        debugPrint('Web存储: 保存项目 $projectId (${jsonString.length} 字符)');

        // 模拟异步存储操作
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // 在实际实现中，这里应该调用Web API存储数据
        // 例如：window.localStorage['project_$projectId'] = jsonString;

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Web存储保存失败: $e');
      return false;
    }
  }

  /// Web平台从localStorage加载项目
  Future<String?> _loadProjectFromWeb(String projectId) async {
    try {
      if (kIsWeb) {
        debugPrint('Web存储: 加载项目 $projectId');

        // 模拟异步加载操作
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // 在实际实现中，这里应该从Web API读取数据
        // 例如：return window.localStorage['project_$projectId'];

        return null; // 简化实现
      }
      return null;
    } catch (e) {
      debugPrint('Web存储加载失败: $e');
      return null;
    }
  }
}

/// 内存存储实现（用于测试）
class MemoryProjectStorage implements ProjectStorage {
  final Map<String, CreativeProject> _projects = <String, CreativeProject>{};

  @override
  Future<bool> saveProject(CreativeProject project) async {
    _projects[project.id] = project;
    debugPrint('内存存储: 项目已保存 ${project.id}');
    return true;
  }

  @override
  Future<CreativeProject?> loadProject(String projectId) async {
    final project = _projects[projectId];
    if (project != null) {
      debugPrint('内存存储: 项目已加载 $projectId');
    }
    return project;
  }

  @override
  Future<bool> deleteProject(String projectId) async {
    final removed = _projects.remove(projectId) != null;
    if (removed) {
      debugPrint('内存存储: 项目已删除 $projectId');
    }
    return removed;
  }

  @override
  Future<List<String>> getAllProjectIds() async {
    final ids = _projects.keys.toList();
    debugPrint('内存存储: 找到 ${ids.length} 个项目');
    return ids;
  }

  @override
  Future<bool> projectExists(String projectId) async =>
      _projects.containsKey(projectId);

  @override
  Future<int> getProjectSize(String projectId) async {
    final project = _projects[projectId];
    if (project != null) {
      // 估算项目大小（JSON字符串长度）
      final jsonString = jsonEncode(project.toJson());
      return jsonString.length;
    }
    return 0;
  }
}

/// 项目存储管理器
class ProjectStorageManager {
  ProjectStorageManager._();

  static final ProjectStorageManager _instance = ProjectStorageManager._();
  static ProjectStorageManager get instance => _instance;

  ProjectStorage? _storage;

  /// 初始化存储
  void initialize({ProjectStorage? storage}) {
    _storage = storage ?? LocalProjectStorage();
    debugPrint('项目存储管理器已初始化');
  }

  /// 获取存储实例
  ProjectStorage get storage {
    if (_storage == null) {
      throw StateError('项目存储管理器未初始化，请先调用 initialize()');
    }
    return _storage!;
  }

  /// 批量保存项目
  Future<Map<String, bool>> saveProjects(List<CreativeProject> projects) async {
    final results = <String, bool>{};

    for (final project in projects) {
      results[project.id] = await storage.saveProject(project);
    }

    return results;
  }

  /// 批量加载项目
  Future<List<CreativeProject>> loadProjects(List<String> projectIds) async {
    final projects = <CreativeProject>[];

    for (final projectId in projectIds) {
      final project = await storage.loadProject(projectId);
      if (project != null) {
        projects.add(project);
      }
    }

    return projects;
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final projectIds = await storage.getAllProjectIds();
    int totalSize = 0;

    for (final projectId in projectIds) {
      totalSize += await storage.getProjectSize(projectId);
    }

    return <String, dynamic>{
      'projectCount': projectIds.length,
      'totalSize': totalSize,
      'averageSize': projectIds.isNotEmpty ? totalSize / projectIds.length : 0,
    };
  }
}
