/*
---------------------------------------------------------------
File name:          plugin_manifest.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件清单数据模型 - 集成Creative Workshop的清单功能
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.1.3 - 统一插件清单解析，集成Creative Workshop实现;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

/// 插件依赖信息
@immutable
class PluginManifestDependency {
  const PluginManifestDependency({
    required this.id,
    required this.version,
    this.required = true,
    this.description,
  });

  /// 从Map创建
  factory PluginManifestDependency.fromMap(Map<String, dynamic> map) =>
      PluginManifestDependency(
        id: map['id'] as String,
        version: map['version'] as String,
        required: map['required'] as bool? ?? true,
        description: map['description'] as String?,
      );

  /// 依赖插件ID
  final String id;

  /// 版本约束
  final String version;

  /// 是否必需
  final bool required;

  /// 依赖描述
  final String? description;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'version': version,
        'required': required,
        if (description != null) 'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifestDependency &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;
}

/// 插件配置信息
@immutable
class PluginManifestConfig {
  const PluginManifestConfig({
    this.hotReload = true,
    this.autoUpdate = true,
    this.background = false,
    this.maxMemory = 128,
    this.networkTimeout = 30,
  });

  /// 从Map创建
  factory PluginManifestConfig.fromMap(Map<String, dynamic> map) =>
      PluginManifestConfig(
        hotReload: map['hot_reload'] as bool? ?? true,
        autoUpdate: map['auto_update'] as bool? ?? true,
        background: map['background'] as bool? ?? false,
        maxMemory: map['max_memory'] as int? ?? 128,
        networkTimeout: map['network_timeout'] as int? ?? 30,
      );

  /// 是否支持热重载
  final bool hotReload;

  /// 是否自动更新
  final bool autoUpdate;

  /// 是否后台运行
  final bool background;

  /// 最大内存使用(MB)
  final int maxMemory;

  /// 网络超时时间(秒)
  final int networkTimeout;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        'hot_reload': hotReload,
        'auto_update': autoUpdate,
        'background': background,
        'max_memory': maxMemory,
        'network_timeout': networkTimeout,
      };
}

/// 开发者信息
@immutable
class PluginManifestDeveloper {
  const PluginManifestDeveloper({
    required this.name,
    this.email,
    this.website,
  });

  /// 从Map创建
  factory PluginManifestDeveloper.fromMap(Map<String, dynamic> map) =>
      PluginManifestDeveloper(
        name: map['name'] as String,
        email: map['email'] as String?,
        website: map['website'] as String?,
      );

  /// 开发者姓名
  final String name;

  /// 邮箱
  final String? email;

  /// 网站
  final String? website;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        if (email != null) 'email': email,
        if (website != null) 'website': website,
      };
}

/// 支持信息
@immutable
class PluginManifestSupport {
  const PluginManifestSupport({
    this.email,
    this.website,
    this.documentation,
    this.issues,
  });

  /// 从Map创建
  factory PluginManifestSupport.fromMap(Map<String, dynamic> map) =>
      PluginManifestSupport(
        email: map['email'] as String?,
        website: map['website'] as String?,
        documentation: map['documentation'] as String?,
        issues: map['issues'] as String?,
      );

  /// 支持邮箱
  final String? email;

  /// 支持网站
  final String? website;

  /// 文档地址
  final String? documentation;

  /// 问题反馈地址
  final String? issues;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        if (email != null) 'email': email,
        if (website != null) 'website': website,
        if (documentation != null) 'documentation': documentation,
        if (issues != null) 'issues': issues,
      };
}

/// 统一插件清单数据模型
///
/// 集成了Creative Workshop的完整清单功能，
/// 对应 plugin.yaml 文件的完整结构。
///
/// 版本: v1.4.0 - 统一插件清单解析
/// 集成来源: Creative Workshop PluginManifest
@immutable
class PluginManifest {
  const PluginManifest({
    // 基础信息 (必需)
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    required this.main,

    // 扩展信息 (可选)
    this.homepage,
    this.repository,
    this.license,
    this.keywords = const <String>[],
    this.icon,
    this.screenshots = const <String>[],

    // 兼容性信息 (可选)
    this.minAppVersion,
    this.maxAppVersion,
    this.platforms = const <String>[],

    // 权限和依赖 (可选)
    this.permissions = const <String>[],
    this.dependencies = const <PluginManifestDependency>[],

    // 资源文件 (可选)
    this.assets = const <String>[],

    // 配置选项 (可选)
    this.config,

    // 本地化支持 (可选)
    this.locales = const <String>[],
    this.defaultLocale,

    // 开发信息 (可选)
    this.developer,
    this.support,
    this.changelog,

    // 元数据 (自动生成)
    this.createdAt,
    this.updatedAt,
    this.size,
    this.hash,
  });

  /// 从Map创建插件清单 (集成Creative Workshop功能)
  factory PluginManifest.fromMap(Map<String, dynamic> map) => PluginManifest(
        // 基础信息 - 使用安全的类型转换，缺失字段使用空字符串
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        version: map['version'] as String? ?? '',
        description: map['description'] as String? ?? '',
        author: map['author'] as String? ?? '',
        category: map['category'] as String? ?? '',
        main: map['main'] as String? ?? '',

        // 扩展信息
        homepage: map['homepage'] as String?,
        repository: map['repository'] as String?,
        license: map['license'] as String?,
        keywords: (map['keywords'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        icon: map['icon'] as String?,
        screenshots: (map['screenshots'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],

        // 兼容性信息
        minAppVersion: map['min_app_version'] as String?,
        maxAppVersion: map['max_app_version'] as String?,
        platforms: (map['platforms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],

        // 权限和依赖
        permissions: (map['permissions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        dependencies: (map['dependencies'] as List<dynamic>?)
                ?.map(
                  (e) => PluginManifestDependency.fromMap(
                      e as Map<String, dynamic>),
                )
                .toList() ??
            const <PluginManifestDependency>[],

        // 资源文件
        assets: (map['assets'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],

        // 配置选项
        config: map['config'] != null
            ? PluginManifestConfig.fromMap(
                map['config'] as Map<String, dynamic>)
            : null,

        // 本地化支持
        locales: (map['locales'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        defaultLocale: map['default_locale'] as String?,

        // 开发信息
        developer: map['developer'] != null
            ? PluginManifestDeveloper.fromMap(
                map['developer'] as Map<String, dynamic>,
              )
            : null,
        support: map['support'] != null
            ? PluginManifestSupport.fromMap(
                map['support'] as Map<String, dynamic>,
              )
            : null,
        changelog: map['changelog'] as String?,

        // 元数据
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'] as String)
            : null,
        size: map['size'] as int?,
        hash: map['hash'] as String?,
      );

  // ============================================================================
  // 基础信息 (必需)
  // ============================================================================

  /// 插件唯一标识符
  final String id;

  /// 插件显示名称
  final String name;

  /// 插件版本
  final String version;

  /// 插件描述
  final String description;

  /// 插件作者
  final String author;

  /// 插件类别
  final String category;

  /// 主入口文件
  final String main;

  // ============================================================================
  // 扩展信息 (可选)
  // ============================================================================

  /// 插件主页
  final String? homepage;

  /// 源码仓库
  final String? repository;

  /// 许可证
  final String? license;

  /// 搜索关键词
  final List<String> keywords;

  /// 插件图标路径
  final String? icon;

  /// 截图列表
  final List<String> screenshots;

  // ============================================================================
  // 兼容性信息 (可选)
  // ============================================================================

  /// 最低应用版本要求
  final String? minAppVersion;

  /// 最高应用版本要求
  final String? maxAppVersion;

  /// 支持的平台
  final List<String> platforms;

  // ============================================================================
  // 权限和依赖 (可选)
  // ============================================================================

  /// 所需权限列表
  final List<String> permissions;

  /// 插件依赖
  final List<PluginManifestDependency> dependencies;

  // ============================================================================
  // 资源文件 (可选)
  // ============================================================================

  /// 资源文件目录
  final List<String> assets;

  // ============================================================================
  // 配置选项 (可选)
  // ============================================================================

  /// 插件配置
  final PluginManifestConfig? config;

  // ============================================================================
  // 本地化支持 (可选)
  // ============================================================================

  /// 支持的语言
  final List<String> locales;

  /// 默认语言
  final String? defaultLocale;

  // ============================================================================
  // 开发信息 (可选)
  // ============================================================================

  /// 开发者信息
  final PluginManifestDeveloper? developer;

  /// 支持信息
  final PluginManifestSupport? support;

  /// 更新日志文件
  final String? changelog;

  // ============================================================================
  // 元数据 (自动生成)
  // ============================================================================

  /// 创建时间
  final DateTime? createdAt;

  /// 最后修改时间
  final DateTime? updatedAt;

  /// 文件大小 (字节)
  final int? size;

  /// 文件哈希
  final String? hash;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        // 基础信息
        'id': id,
        'name': name,
        'version': version,
        'description': description,
        'author': author,
        'category': category,
        'main': main,

        // 扩展信息
        if (homepage != null) 'homepage': homepage,
        if (repository != null) 'repository': repository,
        if (license != null) 'license': license,
        if (keywords.isNotEmpty) 'keywords': keywords,
        if (icon != null) 'icon': icon,
        if (screenshots.isNotEmpty) 'screenshots': screenshots,

        // 兼容性信息
        if (minAppVersion != null) 'min_app_version': minAppVersion,
        if (maxAppVersion != null) 'max_app_version': maxAppVersion,
        if (platforms.isNotEmpty) 'platforms': platforms,

        // 权限和依赖
        if (permissions.isNotEmpty) 'permissions': permissions,
        if (dependencies.isNotEmpty)
          'dependencies': dependencies
              .map((PluginManifestDependency e) => e.toMap())
              .toList(),

        // 资源文件
        if (assets.isNotEmpty) 'assets': assets,

        // 配置选项
        if (config != null) 'config': config!.toMap(),

        // 本地化支持
        if (locales.isNotEmpty) 'locales': locales,
        if (defaultLocale != null) 'default_locale': defaultLocale,

        // 开发信息
        if (developer != null) 'developer': developer!.toMap(),
        if (support != null) 'support': support!.toMap(),
        if (changelog != null) 'changelog': changelog,

        // 元数据
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (size != null) 'size': size,
        if (hash != null) 'hash': hash,
      };

  /// 验证清单完整性 (集成Creative Workshop功能)
  List<String> validate() {
    final errors = <String>[];

    // 验证必需字段
    if (id.trim().isEmpty) {
      errors.add('插件ID不能为空');
    } else if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      errors.add('插件ID格式无效，只能包含小写字母、数字和下划线');
    }

    if (name.trim().isEmpty) {
      errors.add('插件名称不能为空');
    }

    if (version.trim().isEmpty) {
      errors.add('插件版本不能为空');
    } else if (!RegExp(r'^\d+\.\d+\.\d+').hasMatch(version)) {
      errors.add('插件版本格式无效，应使用语义化版本 (如: 1.0.0)');
    }

    if (description.trim().isEmpty) {
      errors.add('插件描述不能为空');
    }

    if (author.trim().isEmpty) {
      errors.add('插件作者不能为空');
    }

    if (category.trim().isEmpty) {
      errors.add('插件类别不能为空');
    }

    if (main.trim().isEmpty) {
      errors.add('主入口文件不能为空');
    }

    // 验证版本约束
    if (minAppVersion != null && maxAppVersion != null) {
      // 这里可以添加版本比较逻辑
    }

    // 验证依赖
    for (final dependency in dependencies) {
      if (dependency.id.trim().isEmpty) {
        errors.add('依赖插件ID不能为空');
      }
      if (dependency.version.trim().isEmpty) {
        errors.add('依赖版本约束不能为空');
      }
    }

    return errors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;

  @override
  String toString() =>
      'PluginManifest(id: $id, name: $name, version: $version)';
}
