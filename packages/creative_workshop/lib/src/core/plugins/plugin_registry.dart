/*
---------------------------------------------------------------
File name:          plugin_registry.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件注册表服务
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件注册表功能实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 插件元数据
class PluginMetadata {
  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    this.homepage,
    this.repository,
    this.license = 'MIT',
    this.keywords = const [],
    this.screenshots = const [],
    this.minAppVersion,
    this.maxAppVersion,
  });

  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final String category;
  final String? homepage;
  final String? repository;
  final String license;
  final List<String> keywords;
  final List<String> screenshots;
  final String? minAppVersion;
  final String? maxAppVersion;

  factory PluginMetadata.fromJson(Map<String, dynamic> json) {
    return PluginMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      homepage: json['homepage'] as String?,
      repository: json['repository'] as String?,
      license: json['license'] as String? ?? 'MIT',
      keywords: List<String>.from((json['keywords'] as List<dynamic>?) ?? []),
      screenshots:
          List<String>.from((json['screenshots'] as List<dynamic>?) ?? []),
      minAppVersion: json['minAppVersion'] as String?,
      maxAppVersion: json['maxAppVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'category': category,
      'homepage': homepage,
      'repository': repository,
      'license': license,
      'keywords': keywords,
      'screenshots': screenshots,
      'minAppVersion': minAppVersion,
      'maxAppVersion': maxAppVersion,
    };
  }
}

/// 插件接口定义
abstract class Plugin {
  /// 插件唯一标识
  String get id;

  /// 插件名称
  String get name;

  /// 插件版本
  String get version;

  /// 插件描述
  String get description;

  /// 插件元数据
  PluginMetadata get metadata;

  /// 初始化插件
  Future<void> initialize();

  /// 启动插件
  Future<void> start();

  /// 停止插件
  Future<void> stop();

  /// 销毁插件
  Future<void> dispose();

  /// 插件是否已初始化
  bool get isInitialized;

  /// 插件是否正在运行
  bool get isRunning;
}

/// 插件注册信息
class PluginRegistration {
  const PluginRegistration({
    required this.metadata,
    required this.pluginFactory,
    required this.registeredAt,
  });

  final PluginMetadata metadata;
  final Plugin Function() pluginFactory;
  final DateTime registeredAt;
}

/// 插件注册表
class PluginRegistry extends ChangeNotifier {
  PluginRegistry._();
  static final PluginRegistry _instance = PluginRegistry._();
  static PluginRegistry get instance => _instance;

  final Map<String, PluginRegistration> _registrations = {};
  final Map<String, Plugin> _activePlugins = {};
  final StreamController<PluginRegistryEvent> _eventController =
      StreamController<PluginRegistryEvent>.broadcast();

  /// 事件流
  Stream<PluginRegistryEvent> get events => _eventController.stream;

  /// 获取所有注册的插件
  List<PluginRegistration> get registrations => _registrations.values.toList();

  /// 获取所有活跃的插件
  List<Plugin> get activePlugins => _activePlugins.values.toList();

  /// 注册插件
  void registerPlugin(
      PluginMetadata metadata, Plugin Function() pluginFactory) {
    if (_registrations.containsKey(metadata.id)) {
      throw ArgumentError(
          'Plugin with id "${metadata.id}" is already registered');
    }

    final registration = PluginRegistration(
      metadata: metadata,
      pluginFactory: pluginFactory,
      registeredAt: DateTime.now(),
    );

    _registrations[metadata.id] = registration;
    _eventController.add(PluginRegistryEvent.registered(metadata.id));
    notifyListeners();

    debugPrint('Plugin registered: ${metadata.id} (${metadata.name})');
  }

  /// 注销插件
  Future<void> unregisterPlugin(String pluginId) async {
    if (!_registrations.containsKey(pluginId)) {
      throw ArgumentError('Plugin with id "$pluginId" is not registered');
    }

    // 如果插件正在运行，先停止它
    if (_activePlugins.containsKey(pluginId)) {
      await stopPlugin(pluginId);
    }

    _registrations.remove(pluginId);
    _eventController.add(PluginRegistryEvent.unregistered(pluginId));
    notifyListeners();

    debugPrint('Plugin unregistered: $pluginId');
  }

  /// 启动插件
  Future<void> startPlugin(String pluginId) async {
    final registration = _registrations[pluginId];
    if (registration == null) {
      throw ArgumentError('Plugin with id "$pluginId" is not registered');
    }

    if (_activePlugins.containsKey(pluginId)) {
      debugPrint('Plugin $pluginId is already running');
      return;
    }

    try {
      final plugin = registration.pluginFactory();

      if (!plugin.isInitialized) {
        await plugin.initialize();
      }

      await plugin.start();
      _activePlugins[pluginId] = plugin;

      _eventController.add(PluginRegistryEvent.started(pluginId));
      notifyListeners();

      debugPrint('Plugin started: $pluginId');
    } catch (e) {
      _eventController.add(PluginRegistryEvent.error(pluginId, e.toString()));
      rethrow;
    }
  }

  /// 停止插件
  Future<void> stopPlugin(String pluginId) async {
    final plugin = _activePlugins[pluginId];
    if (plugin == null) {
      debugPrint('Plugin $pluginId is not running');
      return;
    }

    try {
      await plugin.stop();
      _activePlugins.remove(pluginId);

      _eventController.add(PluginRegistryEvent.stopped(pluginId));
      notifyListeners();

      debugPrint('Plugin stopped: $pluginId');
    } catch (e) {
      _eventController.add(PluginRegistryEvent.error(pluginId, e.toString()));
      rethrow;
    }
  }

  /// 重启插件
  Future<void> restartPlugin(String pluginId) async {
    if (_activePlugins.containsKey(pluginId)) {
      await stopPlugin(pluginId);
    }
    await startPlugin(pluginId);
  }

  /// 获取插件元数据
  PluginMetadata? getPluginMetadata(String pluginId) {
    return _registrations[pluginId]?.metadata;
  }

  /// 获取活跃插件实例
  Plugin? getActivePlugin(String pluginId) {
    return _activePlugins[pluginId];
  }

  /// 检查插件是否已注册
  bool isPluginRegistered(String pluginId) {
    return _registrations.containsKey(pluginId);
  }

  /// 检查插件是否正在运行
  bool isPluginRunning(String pluginId) {
    return _activePlugins.containsKey(pluginId);
  }

  /// 按类别获取插件
  List<PluginRegistration> getPluginsByCategory(String category) {
    return _registrations.values
        .where((reg) => reg.metadata.category == category)
        .toList();
  }

  /// 搜索插件
  List<PluginRegistration> searchPlugins(String query) {
    final lowerQuery = query.toLowerCase();
    return _registrations.values.where((reg) {
      final metadata = reg.metadata;
      return metadata.name.toLowerCase().contains(lowerQuery) ||
          metadata.description.toLowerCase().contains(lowerQuery) ||
          metadata.keywords
              .any((keyword) => keyword.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// 验证插件兼容性
  bool isPluginCompatible(PluginMetadata metadata, String appVersion) {
    // TODO: Phase 5.0.6.4 - 实现版本兼容性检查
    return true;
  }

  /// 获取插件统计信息
  Map<String, dynamic> getStatistics() {
    final totalRegistered = _registrations.length;
    final totalActive = _activePlugins.length;
    final categoryCounts = <String, int>{};

    for (final registration in _registrations.values) {
      final category = registration.metadata.category;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return {
      'totalRegistered': totalRegistered,
      'totalActive': totalActive,
      'categoryCounts': categoryCounts,
    };
  }

  /// 启动所有插件
  Future<void> startAllPlugins() async {
    final pluginIds = _registrations.keys.toList();
    for (final pluginId in pluginIds) {
      try {
        await startPlugin(pluginId);
      } catch (e) {
        debugPrint('Failed to start plugin $pluginId: $e');
      }
    }
  }

  /// 停止所有插件
  Future<void> stopAllPlugins() async {
    final pluginIds = _activePlugins.keys.toList();
    for (final pluginId in pluginIds) {
      try {
        await stopPlugin(pluginId);
      } catch (e) {
        debugPrint('Failed to stop plugin $pluginId: $e');
      }
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}

/// 插件注册表事件
abstract class PluginRegistryEvent {
  const PluginRegistryEvent(this.pluginId, this.timestamp);

  final String pluginId;
  final DateTime timestamp;

  factory PluginRegistryEvent.registered(String pluginId) =>
      _PluginRegisteredEvent(pluginId, DateTime.now());

  factory PluginRegistryEvent.unregistered(String pluginId) =>
      _PluginUnregisteredEvent(pluginId, DateTime.now());

  factory PluginRegistryEvent.started(String pluginId) =>
      _PluginStartedEvent(pluginId, DateTime.now());

  factory PluginRegistryEvent.stopped(String pluginId) =>
      _PluginStoppedEvent(pluginId, DateTime.now());

  factory PluginRegistryEvent.error(String pluginId, String error) =>
      _PluginErrorEvent(pluginId, DateTime.now(), error);
}

class _PluginRegisteredEvent extends PluginRegistryEvent {
  const _PluginRegisteredEvent(super.pluginId, super.timestamp);
}

class _PluginUnregisteredEvent extends PluginRegistryEvent {
  const _PluginUnregisteredEvent(super.pluginId, super.timestamp);
}

class _PluginStartedEvent extends PluginRegistryEvent {
  const _PluginStartedEvent(super.pluginId, super.timestamp);
}

class _PluginStoppedEvent extends PluginRegistryEvent {
  const _PluginStoppedEvent(super.pluginId, super.timestamp);
}

class _PluginErrorEvent extends PluginRegistryEvent {
  const _PluginErrorEvent(super.pluginId, super.timestamp, this.error);

  final String error;
}
