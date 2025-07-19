/*
---------------------------------------------------------------
File name:          plugin_registry.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/19
Dart Version:       3.2+
Description:        插件注册中心 (Plugin registry)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件注册中心 (Plugin registry);
    2025/07/19: 优化注册逻辑，支持重复注册;
---------------------------------------------------------------
*/
import 'dart:async';
import 'dart:collection';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_exceptions.dart';

/// 插件注册中心
///
/// 负责管理所有插件的注册、查找、依赖解析和版本管理
class PluginRegistry {
  PluginRegistry._();

  /// 单例实例
  static final PluginRegistry _instance = PluginRegistry._();
  static PluginRegistry get instance => _instance;

  /// 已注册的插件
  final Map<String, Plugin> _plugins = <String, Plugin>{};

  /// 插件元数据
  final Map<String, PluginMetadata> _metadata = <String, PluginMetadata>{};

  /// 插件状态
  final Map<String, PluginState> _states = <String, PluginState>{};

  /// 插件状态变化控制器
  final Map<String, StreamController<PluginState>> _stateControllers =
      <String, StreamController<PluginState>>{};

  /// 注册插件
  Future<void> register(Plugin plugin) async {
    if (_plugins.containsKey(plugin.id)) {
      throw PluginAlreadyExistsException(plugin.id);
    }

    // 验证插件
    await _validatePlugin(plugin);

    // 解析依赖
    await _resolveDependencies(plugin);

    // 注册插件
    _plugins[plugin.id] = plugin;
    _metadata[plugin.id] = PluginMetadata.from(plugin);
    _states[plugin.id] = PluginState.loaded;

    // 创建状态控制器
    _stateControllers[plugin.id] = StreamController<PluginState>.broadcast();

    // 通知插件已注册
    _notifyPluginRegistered(plugin);
  }

  /// 安全注册插件（如果不存在则注册）
  Future<bool> registerIfNotExists(Plugin plugin) async {
    if (_plugins.containsKey(plugin.id)) {
      // 插件已存在，跳过注册
      return false;
    }

    try {
      await register(plugin);
      return true;
    } catch (e) {
      // 注册失败，重新抛出异常
      rethrow;
    }
  }

  /// 注销插件
  Future<void> unregister(String pluginId) async {
    if (!_plugins.containsKey(pluginId)) {
      throw PluginNotFoundException(pluginId);
    }

    // 检查是否有其他插件依赖此插件
    final dependents = _findDependents(pluginId);
    if (dependents.isNotEmpty) {
      throw PluginDependencyException(
          pluginId, 'Plugin is required by: ${dependents.join(', ')}');
    }

    // 停止插件
    final plugin = _plugins[pluginId]!;
    if (plugin.currentState != PluginState.stopped) {
      await plugin.stop();
    }

    // 注销插件
    _plugins.remove(pluginId);
    _metadata.remove(pluginId);
    _states.remove(pluginId);

    // 关闭状态控制器
    await _stateControllers[pluginId]?.close();
    _stateControllers.remove(pluginId);

    // 通知插件已注销
    _notifyPluginUnregistered(pluginId);
  }

  /// 获取插件
  Plugin? get(String pluginId) {
    return _plugins[pluginId];
  }

  /// 获取插件元数据
  PluginMetadata? getMetadata(String pluginId) {
    return _metadata[pluginId];
  }

  /// 获取插件状态
  PluginState? getState(String pluginId) {
    return _states[pluginId];
  }

  /// 获取插件状态流
  Stream<PluginState>? getStateStream(String pluginId) {
    return _stateControllers[pluginId]?.stream;
  }

  /// 更新插件状态
  void updateState(String pluginId, PluginState newState) {
    if (!_plugins.containsKey(pluginId)) {
      throw PluginNotFoundException(pluginId);
    }

    final oldState = _states[pluginId];
    _states[pluginId] = newState;

    // 通知状态变化
    _stateControllers[pluginId]?.add(newState);
    _notifyStateChanged(pluginId, oldState, newState);
  }

  /// 按类别查找插件
  List<Plugin> getByCategory(PluginCategory category) {
    return _plugins.values
        .where((plugin) => plugin.category == category)
        .toList();
  }

  /// 按状态查找插件
  List<Plugin> getByState(PluginState state) {
    return _plugins.entries
        .where((entry) => _states[entry.key] == state)
        .map((entry) => entry.value)
        .toList();
  }

  /// 获取所有已注册的插件
  List<Plugin> getAll() {
    return UnmodifiableListView(_plugins.values);
  }

  /// 获取所有已注册的插件（别名方法）
  List<Plugin> getAllPlugins() {
    return getAll();
  }

  /// 获取所有活跃的插件
  List<Plugin> getAllActive() {
    return getByState(PluginState.started);
  }

  /// 检查插件是否存在
  bool contains(String pluginId) {
    return _plugins.containsKey(pluginId);
  }

  /// 获取插件数量
  int get count => _plugins.length;

  /// 清空所有插件
  Future<void> clear({bool force = false}) async {
    if (force) {
      // 强制清理，忽略依赖关系
      final pluginIds = _plugins.keys.toList();
      for (final pluginId in pluginIds) {
        try {
          _plugins.remove(pluginId);
          _metadata.remove(pluginId);
          _states.remove(pluginId);

          // 关闭状态控制器
          final controller = _stateControllers.remove(pluginId);
          if (controller != null && !controller.isClosed) {
            await controller.close();
          }
        } catch (e) {
          // 忽略清理错误
        }
      }
    } else {
      // 正常清理，遵循依赖关系
      final pluginIds = _plugins.keys.toList();
      for (final pluginId in pluginIds) {
        await unregister(pluginId);
      }
    }
  }

  /// 验证插件
  Future<void> _validatePlugin(Plugin plugin) async {
    // 验证插件ID
    if (plugin.id.isEmpty) {
      throw PluginConfigurationException(
          plugin.id, 'Plugin ID cannot be empty');
    }

    // 验证版本格式
    if (!_isValidVersion(plugin.version)) {
      throw PluginConfigurationException(
          plugin.id, 'Invalid version format: ${plugin.version}');
    }

    // 验证支持的平台
    if (plugin.supportedPlatforms.isEmpty) {
      throw PluginConfigurationException(
          plugin.id, 'At least one platform must be supported');
    }
  }

  /// 解析插件依赖
  Future<void> _resolveDependencies(Plugin plugin) async {
    for (final dependency in plugin.dependencies) {
      final dependencyPlugin = _plugins[dependency.pluginId];

      if (dependencyPlugin == null) {
        if (!dependency.optional) {
          throw PluginDependencyException(plugin.id, dependency.pluginId);
        }
        continue;
      }

      // 检查版本兼容性
      if (!_isVersionCompatible(
          dependencyPlugin.version, dependency.versionConstraint)) {
        throw PluginVersionIncompatibleException(
          plugin.id,
          dependency.versionConstraint,
          dependencyPlugin.version,
        );
      }
    }

    // 检查循环依赖
    _checkCircularDependencies(plugin);
  }

  /// 检查循环依赖
  void _checkCircularDependencies(Plugin plugin) {
    final visited = <String>{};
    final visiting = <String>{};

    void dfs(String pluginId) {
      if (visiting.contains(pluginId)) {
        throw CircularDependencyException(pluginId);
      }

      if (visited.contains(pluginId)) {
        return;
      }

      visiting.add(pluginId);

      final currentPlugin = _plugins[pluginId];
      if (currentPlugin != null) {
        for (final dependency in currentPlugin.dependencies) {
          dfs(dependency.pluginId);
        }
      }

      visiting.remove(pluginId);
      visited.add(pluginId);
    }

    dfs(plugin.id);
  }

  /// 查找依赖此插件的其他插件
  List<String> _findDependents(String pluginId) {
    final dependents = <String>[];

    for (final entry in _plugins.entries) {
      final plugin = entry.value;
      for (final dependency in plugin.dependencies) {
        if (dependency.pluginId == pluginId) {
          dependents.add(plugin.id);
          break;
        }
      }
    }

    return dependents;
  }

  /// 验证版本格式
  bool _isValidVersion(String version) {
    final versionRegex =
        RegExp(r'^\d+\.\d+\.\d+(?:-[a-zA-Z0-9]+)?(?:\+[a-zA-Z0-9]+)?$');
    return versionRegex.hasMatch(version);
  }

  /// 检查版本兼容性
  bool _isVersionCompatible(String actualVersion, String constraint) {
    // 简化的版本兼容性检查
    // 实际项目中应该使用更完善的版本解析库
    if (constraint.startsWith('^')) {
      final constraintVersion = constraint.substring(1);
      return _compareVersions(actualVersion, constraintVersion) >= 0;
    }

    if (constraint.startsWith('>=')) {
      final constraintVersion = constraint.substring(2);
      return _compareVersions(actualVersion, constraintVersion) >= 0;
    }

    return actualVersion == constraint;
  }

  /// 比较版本号
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part != v2Part) {
        return v1Part.compareTo(v2Part);
      }
    }

    return 0;
  }

  /// 通知插件已注册
  void _notifyPluginRegistered(Plugin plugin) {
    // 可以在这里添加事件通知逻辑
  }

  /// 通知插件已注销
  void _notifyPluginUnregistered(String pluginId) {
    // 可以在这里添加事件通知逻辑
  }

  /// 通知状态变化
  void _notifyStateChanged(
      String pluginId, PluginState? oldState, PluginState newState) {
    // 可以在这里添加事件通知逻辑
  }
}
