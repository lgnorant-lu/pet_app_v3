/*
---------------------------------------------------------------
File name:          plugin_manifest.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件清单数据模型
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.2 - 插件清单数据模型实现;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

/// 插件清单数据模型
///
/// 对应 plugin.yaml 文件的完整结构
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
    this.keywords = const [],
    this.icon,
    this.screenshots = const [],

    // 兼容性信息 (可选)
    this.minAppVersion,
    this.maxAppVersion,
    this.platforms = const [],

    // 权限和依赖 (可选)
    this.permissions = const [],
    this.dependencies = const [],

    // 资源文件 (可选)
    this.assets = const [],

    // 配置选项 (可选)
    this.config,

    // 本地化支持 (可选)
    this.locales = const [],
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

  /// 最高应用版本支持
  final String? maxAppVersion;

  /// 支持的平台
  final List<String> platforms;

  // ============================================================================
  // 权限和依赖 (可选)
  // ============================================================================

  /// 插件所需权限
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

  /// 从 Map 创建 PluginManifest
  factory PluginManifest.fromMap(Map<String, dynamic> map) {
    return PluginManifest(
      // 基础信息
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
      keywords: (map['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      icon: map['icon'] as String?,
      screenshots: (map['screenshots'] as List<dynamic>?)?.cast<String>() ?? [],

      // 兼容性信息
      minAppVersion: map['min_app_version'] as String?,
      maxAppVersion: map['max_app_version'] as String?,
      platforms: (map['platforms'] as List<dynamic>?)?.cast<String>() ?? [],

      // 权限和依赖
      permissions: (map['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      dependencies: (map['dependencies'] as List<dynamic>?)
              ?.map((e) =>
                  PluginManifestDependency.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],

      // 资源文件
      assets: (map['assets'] as List<dynamic>?)?.cast<String>() ?? [],

      // 配置选项
      config: map['config'] != null
          ? PluginManifestConfig.fromMap(map['config'] as Map<String, dynamic>)
          : null,

      // 本地化支持
      locales: (map['locales'] as List<dynamic>?)?.cast<String>() ?? [],
      defaultLocale: map['default_locale'] as String?,

      // 开发信息
      developer: map['developer'] != null
          ? PluginManifestDeveloper.fromMap(
              map['developer'] as Map<String, dynamic>)
          : null,
      support: map['support'] != null
          ? PluginManifestSupport.fromMap(
              map['support'] as Map<String, dynamic>)
          : null,
      changelog: map['changelog'] as String?,

      // 元数据
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      size: map['size'] as int?,
      hash: map['hash'] as String?,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
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
        'dependencies': dependencies.map((e) => e.toMap()).toList(),

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
  }

  /// 验证清单数据的有效性
  List<String> validate() {
    final errors = <String>[];

    // 验证必需字段
    if (id.isEmpty) errors.add('插件ID不能为空');
    if (name.isEmpty) errors.add('插件名称不能为空');
    if (version.isEmpty) errors.add('插件版本不能为空');
    if (description.isEmpty) errors.add('插件描述不能为空');
    if (author.isEmpty) errors.add('插件作者不能为空');
    if (category.isEmpty) errors.add('插件类别不能为空');
    if (main.isEmpty) errors.add('主入口文件不能为空');

    // 验证ID格式
    if (!RegExp(r'^[a-zA-Z0-9_]{3,50}$').hasMatch(id)) {
      errors.add('插件ID格式无效，只能包含字母、数字、下划线，长度3-50字符');
    }

    // 验证版本格式 (简单的语义化版本检查)
    if (!RegExp(r'^\d+\.\d+\.\d+').hasMatch(version)) {
      errors.add('版本号格式无效，必须符合语义化版本规范 (如: 1.0.0)');
    }

    // 验证类别
    const validCategories = [
      'system',
      'ui',
      'tool',
      'game',
      'theme',
      'widget',
      'service'
    ];
    if (!validCategories.contains(category)) {
      errors.add('插件类别无效，必须是: ${validCategories.join(', ')}');
    }

    // 验证权限
    const validPermissions = [
      'fileSystem',
      'network',
      'notifications',
      'clipboard',
      'camera',
      'microphone',
      'location',
      'deviceInfo'
    ];
    for (final permission in permissions) {
      if (!validPermissions.contains(permission)) {
        errors.add('权限 "$permission" 无效，有效权限: ${validPermissions.join(', ')}');
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

/// 插件依赖信息
@immutable
class PluginManifestDependency {
  const PluginManifestDependency({
    required this.id,
    required this.version,
    this.required = true,
    this.description,
  });

  /// 依赖的插件ID
  final String id;

  /// 版本约束
  final String version;

  /// 是否为必需依赖
  final bool required;

  /// 依赖描述
  final String? description;

  factory PluginManifestDependency.fromMap(Map<String, dynamic> map) {
    return PluginManifestDependency(
      id: map['id'] as String,
      version: map['version'] as String,
      required: map['required'] as bool? ?? true,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version': version,
      'required': required,
      if (description != null) 'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifestDependency &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;

  @override
  String toString() =>
      'PluginManifestDependency(id: $id, version: $version, required: $required)';
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

  /// 是否支持热重载
  final bool hotReload;

  /// 是否自动更新
  final bool autoUpdate;

  /// 是否在后台运行
  final bool background;

  /// 最大内存使用 (MB)
  final int maxMemory;

  /// 网络超时 (秒)
  final int networkTimeout;

  factory PluginManifestConfig.fromMap(Map<String, dynamic> map) {
    return PluginManifestConfig(
      hotReload: map['hot_reload'] as bool? ?? true,
      autoUpdate: map['auto_update'] as bool? ?? true,
      background: map['background'] as bool? ?? false,
      maxMemory: map['max_memory'] as int? ?? 128,
      networkTimeout: map['network_timeout'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hot_reload': hotReload,
      'auto_update': autoUpdate,
      'background': background,
      'max_memory': maxMemory,
      'network_timeout': networkTimeout,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifestConfig &&
          runtimeType == other.runtimeType &&
          hotReload == other.hotReload &&
          autoUpdate == other.autoUpdate &&
          background == other.background &&
          maxMemory == other.maxMemory &&
          networkTimeout == other.networkTimeout;

  @override
  int get hashCode =>
      hotReload.hashCode ^
      autoUpdate.hashCode ^
      background.hashCode ^
      maxMemory.hashCode ^
      networkTimeout.hashCode;

  @override
  String toString() =>
      'PluginManifestConfig(hotReload: $hotReload, autoUpdate: $autoUpdate)';
}

/// 开发者信息
@immutable
class PluginManifestDeveloper {
  const PluginManifestDeveloper({
    required this.name,
    this.email,
    this.website,
  });

  /// 开发者名称
  final String name;

  /// 开发者邮箱
  final String? email;

  /// 开发者网站
  final String? website;

  factory PluginManifestDeveloper.fromMap(Map<String, dynamic> map) {
    return PluginManifestDeveloper(
      name: map['name'] as String,
      email: map['email'] as String?,
      website: map['website'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifestDeveloper &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          website == other.website;

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ website.hashCode;

  @override
  String toString() => 'PluginManifestDeveloper(name: $name)';
}

/// 支持信息
@immutable
class PluginManifestSupport {
  const PluginManifestSupport({
    this.email,
    this.website,
    this.documentation,
  });

  /// 支持邮箱
  final String? email;

  /// 支持网站
  final String? website;

  /// 文档链接
  final String? documentation;

  factory PluginManifestSupport.fromMap(Map<String, dynamic> map) {
    return PluginManifestSupport(
      email: map['email'] as String?,
      website: map['website'] as String?,
      documentation: map['documentation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (documentation != null) 'documentation': documentation,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginManifestSupport &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          website == other.website &&
          documentation == other.documentation;

  @override
  int get hashCode =>
      email.hashCode ^ website.hashCode ^ documentation.hashCode;

  @override
  String toString() =>
      'PluginManifestSupport(email: $email, website: $website)';
}
