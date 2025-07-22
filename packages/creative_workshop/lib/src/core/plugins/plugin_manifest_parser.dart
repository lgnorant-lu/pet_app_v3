/*
---------------------------------------------------------------
File name:          plugin_manifest_parser.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件清单解析器 - 解析 plugin.yaml 文件
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.2 - 插件清单解析器实现;
---------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

import 'plugin_manifest.dart';
import 'plugin_file_manager.dart';

/// 插件清单解析结果
class PluginManifestParseResult {
  const PluginManifestParseResult({
    required this.success,
    this.manifest,
    this.error,
    this.warnings = const [],
  });

  /// 是否解析成功
  final bool success;

  /// 解析得到的清单对象
  final PluginManifest? manifest;

  /// 错误信息
  final String? error;

  /// 警告信息列表
  final List<String> warnings;

  /// 创建成功结果
  factory PluginManifestParseResult.success(
    PluginManifest manifest, {
    List<String> warnings = const [],
  }) {
    return PluginManifestParseResult(
      success: true,
      manifest: manifest,
      warnings: warnings,
    );
  }

  /// 创建失败结果
  factory PluginManifestParseResult.failure(String error) {
    return PluginManifestParseResult(
      success: false,
      error: error,
    );
  }
}

/// 插件清单解析器
///
/// 负责解析 plugin.yaml 文件并验证其内容
class PluginManifestParser {
  PluginManifestParser._();
  static final PluginManifestParser _instance = PluginManifestParser._();
  static PluginManifestParser get instance => _instance;

  /// 从字符串解析插件清单
  PluginManifestParseResult parseFromString(String yamlContent) {
    try {
      // 解析 YAML
      final dynamic yamlData = loadYaml(yamlContent);

      if (yamlData is! Map) {
        return PluginManifestParseResult.failure('YAML 根节点必须是对象');
      }

      // 转换为 Map<String, dynamic>
      final Map<String, dynamic> data = _convertYamlMap(yamlData);

      // 创建清单对象
      final manifest = PluginManifest.fromMap(data);

      // 验证清单
      final validationErrors = manifest.validate();
      if (validationErrors.isNotEmpty) {
        return PluginManifestParseResult.failure(
          '清单验证失败:\n${validationErrors.join('\n')}',
        );
      }

      // 检查警告
      final warnings = _checkWarnings(manifest);

      return PluginManifestParseResult.success(manifest, warnings: warnings);
    } catch (e) {
      return PluginManifestParseResult.failure('解析 YAML 失败: $e');
    }
  }

  /// 从字节数组解析插件清单
  PluginManifestParseResult parseFromBytes(Uint8List bytes) {
    try {
      // 使用 UTF-8 解码
      final yamlContent = utf8.decode(bytes);
      if (yamlContent.trim().isEmpty) {
        return PluginManifestParseResult.failure('文件内容为空');
      }
      return parseFromString(yamlContent);
    } catch (e) {
      return PluginManifestParseResult.failure('读取文件内容失败: $e');
    }
  }

  /// 从插件目录解析清单文件
  Future<PluginManifestParseResult> parseFromPlugin(String pluginId) async {
    try {
      final fileManager = PluginFileManager.instance;

      // 读取 plugin.yaml 文件
      final manifestBytes =
          await fileManager.readPluginFile(pluginId, 'plugin.yaml');
      if (manifestBytes == null) {
        return PluginManifestParseResult.failure('找不到 plugin.yaml 文件');
      }

      return parseFromBytes(manifestBytes);
    } catch (e) {
      return PluginManifestParseResult.failure('读取插件清单失败: $e');
    }
  }

  /// 验证清单文件格式
  bool validateYamlFormat(String yamlContent) {
    try {
      final dynamic yamlData = loadYaml(yamlContent);
      return yamlData is Map;
    } catch (e) {
      return false;
    }
  }

  /// 生成默认清单内容
  String generateDefaultManifest({
    required String pluginId,
    required String pluginName,
    String version = '1.0.0',
    String description = '插件描述',
    String author = '插件作者',
    String category = 'tool',
  }) {
    return '''
# ============================================================================
# 插件清单文件 (plugin.yaml)
# 自动生成于: ${DateTime.now().toIso8601String()}
# ============================================================================

# 基础信息 (必需)
id: "$pluginId"
name: "$pluginName"
version: "$version"
description: "$description"
author: "$author"
category: "$category"

# 主入口文件
main: "lib/main.dart"

# 扩展信息 (可选)
# homepage: "https://example.com/my-plugin"
# repository: "https://github.com/user/my-plugin"
# license: "MIT"

# 搜索关键词
keywords:
  - "工具"
  - "创作"

# 兼容性信息
min_app_version: "5.0.0"
platforms:
  - "android"
  - "ios"
  - "windows"
  - "macos"
  - "linux"
  - "web"

# 权限声明 (根据需要取消注释)
permissions: []
  # - "fileSystem"      # 文件系统访问
  # - "network"         # 网络访问
  # - "notifications"   # 系统通知
  # - "clipboard"       # 剪贴板访问

# 插件依赖 (根据需要添加)
dependencies: []
  # - id: "base_utils"
  #   version: "^1.0.0"
  #   required: true
  #   description: "基础工具库"

# 资源文件目录
assets:
  - "assets/"

# 插件配置
config:
  hot_reload: true
  auto_update: true
  background: false
  max_memory: 128
  network_timeout: 30

# 本地化支持
locales:
  - "zh_CN"
  - "en_US"
default_locale: "zh_CN"

# 开发者信息
developer:
  name: "$author"
  # email: "developer@example.com"
  # website: "https://developer.example.com"

# 支持信息
# support:
#   email: "support@example.com"
#   website: "https://support.example.com"
#   documentation: "https://docs.example.com"
''';
  }

  /// 转换 YAML Map 为 Dart Map
  Map<String, dynamic> _convertYamlMap(dynamic yamlData) {
    if (yamlData is YamlMap) {
      final Map<String, dynamic> result = {};
      for (final entry in yamlData.entries) {
        final key = entry.key.toString();
        final value = _convertYamlValue(entry.value);
        result[key] = value;
      }
      return result;
    } else if (yamlData is Map) {
      final Map<String, dynamic> result = {};
      for (final entry in yamlData.entries) {
        final key = entry.key.toString();
        final value = _convertYamlValue(entry.value);
        result[key] = value;
      }
      return result;
    }
    return {};
  }

  /// 转换 YAML 值为 Dart 值
  dynamic _convertYamlValue(dynamic value) {
    if (value is YamlMap) {
      return _convertYamlMap(value);
    } else if (value is YamlList) {
      return value.map(_convertYamlValue).toList();
    } else if (value is List) {
      return value.map(_convertYamlValue).toList();
    } else {
      return value;
    }
  }

  /// 检查清单警告
  List<String> _checkWarnings(PluginManifest manifest) {
    final warnings = <String>[];

    // 检查可选但推荐的字段
    if (manifest.homepage == null) {
      warnings.add('建议添加插件主页 (homepage)');
    }

    if (manifest.license == null) {
      warnings.add('建议添加许可证信息 (license)');
    }

    if (manifest.keywords.isEmpty) {
      warnings.add('建议添加搜索关键词 (keywords)');
    }

    if (manifest.icon == null) {
      warnings.add('建议添加插件图标 (icon)');
    }

    if (manifest.platforms.isEmpty) {
      warnings.add('建议指定支持的平台 (platforms)');
    }

    if (manifest.minAppVersion == null) {
      warnings.add('建议指定最低应用版本要求 (min_app_version)');
    }

    // 检查权限使用
    if (manifest.permissions.contains('network') &&
        !manifest.permissions.contains('fileSystem')) {
      warnings.add('使用网络权限时建议同时申请文件系统权限用于缓存');
    }

    // 检查配置合理性
    if (manifest.config != null) {
      final config = manifest.config!;
      if (config.maxMemory > 512) {
        warnings.add('最大内存使用超过 512MB，可能影响性能');
      }
      if (config.networkTimeout > 60) {
        warnings.add('网络超时时间过长，可能影响用户体验');
      }
    }

    return warnings;
  }
}
