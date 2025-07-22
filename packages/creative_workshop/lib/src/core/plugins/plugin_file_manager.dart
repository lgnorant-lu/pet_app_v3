/*
---------------------------------------------------------------
File name:          plugin_file_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件文件管理器 - 处理插件文件系统操作
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.1 - 插件文件管理器实现;
---------------------------------------------------------------
*/

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// 插件文件操作结果
class PluginFileOperationResult {
  const PluginFileOperationResult({
    required this.success,
    this.message,
    this.error,
    this.path,
  });

  final bool success;
  final String? message;
  final String? error;
  final String? path;

  factory PluginFileOperationResult.success(String message, {String? path}) {
    return PluginFileOperationResult(
      success: true,
      message: message,
      path: path,
    );
  }

  factory PluginFileOperationResult.failure(String error) {
    return PluginFileOperationResult(
      success: false,
      error: error,
    );
  }
}

/// 插件安装进度信息
class PluginInstallProgress {
  const PluginInstallProgress({
    required this.stage,
    required this.progress,
    this.message,
  });

  final PluginInstallStage stage;
  final double progress; // 0.0 - 1.0
  final String? message;
}

/// 插件安装阶段
enum PluginInstallStage {
  downloading('下载中'),
  extracting('解压中'),
  validating('验证中'),
  installing('安装中'),
  configuring('配置中'),
  completed('完成');

  const PluginInstallStage(this.displayName);
  final String displayName;
}

/// 插件文件管理器
///
/// 负责插件的文件系统操作，包括：
/// - 插件目录管理
/// - 文件复制和移动
/// - 插件安装和卸载
/// - 文件验证和清理
class PluginFileManager {
  PluginFileManager._();
  static final PluginFileManager _instance = PluginFileManager._();
  static PluginFileManager get instance => _instance;

  String? _pluginsDirectory;
  String? _tempDirectory;
  String? _cacheDirectory;
  bool _isInitialized = false;

  /// 初始化文件管理器
  Future<void> initialize({String? customPluginsDir}) async {
    if (_isInitialized) {
      return; // 避免重复初始化
    }

    _pluginsDirectory = customPluginsDir ?? await _getDefaultPluginsDirectory();
    _tempDirectory = path.join(_pluginsDirectory!, '.temp');
    _cacheDirectory = path.join(_pluginsDirectory!, '.cache');
    _isInitialized = true;

    // 确保目录存在
    await _ensureDirectoryExists(_pluginsDirectory!);
    await _ensureDirectoryExists(_tempDirectory!);
    await _ensureDirectoryExists(_cacheDirectory!);

    debugPrint('插件文件管理器已初始化: $_pluginsDirectory');
  }

  /// 检查是否已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PluginFileManager 未初始化，请先调用 initialize()');
    }
  }

  /// 重置文件管理器（仅用于测试）
  void reset() {
    _pluginsDirectory = null;
    _tempDirectory = null;
    _cacheDirectory = null;
    _isInitialized = false;
  }

  /// 获取默认插件目录
  Future<String> _getDefaultPluginsDirectory() async {
    if (kIsWeb) {
      return '/creative_workshop/plugins';
    } else {
      final homeDir = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      return path.join(homeDir, '.creative_workshop', 'plugins');
    }
  }

  /// 确保目录存在
  Future<void> _ensureDirectoryExists(String dirPath) async {
    if (!kIsWeb) {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  /// 获取插件安装目录
  String getPluginDirectory(String pluginId) {
    _ensureInitialized();
    return path.join(_pluginsDirectory!, pluginId);
  }

  /// 获取插件临时目录
  String getPluginTempDirectory(String pluginId) {
    _ensureInitialized();
    return path.join(_tempDirectory!, pluginId);
  }

  /// 检查插件是否已安装（目录是否存在）
  Future<bool> isPluginInstalled(String pluginId) async {
    if (kIsWeb) {
      // Web平台简化处理
      return false;
    }

    final pluginDir = Directory(getPluginDirectory(pluginId));
    return await pluginDir.exists();
  }

  /// 创建插件目录
  Future<PluginFileOperationResult> createPluginDirectory(
      String pluginId) async {
    try {
      final pluginPath = getPluginDirectory(pluginId);

      if (await isPluginInstalled(pluginId)) {
        return PluginFileOperationResult.failure('插件目录已存在: $pluginId');
      }

      await _ensureDirectoryExists(pluginPath);

      return PluginFileOperationResult.success(
        '插件目录创建成功',
        path: pluginPath,
      );
    } catch (e) {
      return PluginFileOperationResult.failure('创建插件目录失败: $e');
    }
  }

  /// 删除插件目录
  Future<PluginFileOperationResult> deletePluginDirectory(
      String pluginId) async {
    try {
      final pluginPath = getPluginDirectory(pluginId);

      if (kIsWeb) {
        // Web平台简化处理
        return PluginFileOperationResult.success('插件目录删除成功(Web)');
      }

      final pluginDir = Directory(pluginPath);
      if (await pluginDir.exists()) {
        await pluginDir.delete(recursive: true);
      }

      return PluginFileOperationResult.success('插件目录删除成功');
    } catch (e) {
      return PluginFileOperationResult.failure('删除插件目录失败: $e');
    }
  }

  /// 复制文件到插件目录
  Future<PluginFileOperationResult> copyFileToPlugin(
    String pluginId,
    String sourcePath,
    String relativePath,
  ) async {
    try {
      if (kIsWeb) {
        // Web平台简化处理
        return PluginFileOperationResult.success('文件复制成功(Web)');
      }

      final pluginDir = getPluginDirectory(pluginId);
      final targetPath = path.join(pluginDir, relativePath);
      final targetDir = path.dirname(targetPath);

      // 确保目标目录存在
      await _ensureDirectoryExists(targetDir);

      // 复制文件
      final sourceFile = File(sourcePath);
      final targetFile = File(targetPath);
      await sourceFile.copy(targetPath);

      return PluginFileOperationResult.success(
        '文件复制成功',
        path: targetPath,
      );
    } catch (e) {
      return PluginFileOperationResult.failure('复制文件失败: $e');
    }
  }

  /// 写入数据到插件文件
  Future<PluginFileOperationResult> writePluginFile(
    String pluginId,
    String relativePath,
    Uint8List data,
  ) async {
    try {
      if (kIsWeb) {
        // Web平台简化处理
        return PluginFileOperationResult.success('文件写入成功(Web)');
      }

      final pluginDir = getPluginDirectory(pluginId);
      final filePath = path.join(pluginDir, relativePath);
      final fileDir = path.dirname(filePath);

      // 确保目录存在
      await _ensureDirectoryExists(fileDir);

      // 写入文件
      final file = File(filePath);
      await file.writeAsBytes(data);

      return PluginFileOperationResult.success(
        '文件写入成功',
        path: filePath,
      );
    } catch (e) {
      return PluginFileOperationResult.failure('写入文件失败: $e');
    }
  }

  /// 读取插件文件
  Future<Uint8List?> readPluginFile(
      String pluginId, String relativePath) async {
    try {
      if (kIsWeb) {
        // Web平台简化处理
        return null;
      }

      final pluginDir = getPluginDirectory(pluginId);
      final filePath = path.join(pluginDir, relativePath);
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('读取插件文件失败: $e');
      return null;
    }
  }

  /// 获取插件目录大小
  Future<int> getPluginDirectorySize(String pluginId) async {
    try {
      if (kIsWeb) {
        return 0;
      }

      final pluginDir = Directory(getPluginDirectory(pluginId));
      if (!await pluginDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in pluginDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('获取插件目录大小失败: $e');
      return 0;
    }
  }

  /// 清理临时文件
  Future<void> cleanupTempFiles() async {
    try {
      if (kIsWeb || !_isInitialized) {
        return;
      }

      final tempDir = Directory(_tempDirectory!);
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is Directory) {
            // 删除超过1小时的临时目录
            final stat = await entity.stat();
            final age = DateTime.now().difference(stat.modified);
            if (age.inHours > 1) {
              await entity.delete(recursive: true);
              debugPrint('清理临时目录: ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('清理临时文件失败: $e');
    }
  }

  /// 获取插件目录列表
  Future<List<String>> getInstalledPluginIds() async {
    try {
      if (kIsWeb || !_isInitialized) {
        return [];
      }

      final pluginsDir = Directory(_pluginsDirectory!);
      if (!await pluginsDir.exists()) {
        return [];
      }

      final pluginIds = <String>[];
      await for (final entity in pluginsDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);
          // 排除隐藏目录
          if (!dirName.startsWith('.')) {
            pluginIds.add(dirName);
          }
        }
      }

      return pluginIds;
    } catch (e) {
      debugPrint('获取插件目录列表失败: $e');
      return [];
    }
  }

  /// 验证插件目录完整性
  Future<bool> validatePluginDirectory(String pluginId) async {
    try {
      if (kIsWeb) {
        return true;
      }

      final pluginDir = Directory(getPluginDirectory(pluginId));
      if (!await pluginDir.exists()) {
        return false;
      }

      // 检查必要文件是否存在
      final manifestFile = File(path.join(pluginDir.path, 'plugin.yaml'));
      return await manifestFile.exists();
    } catch (e) {
      debugPrint('验证插件目录失败: $e');
      return false;
    }
  }
}
