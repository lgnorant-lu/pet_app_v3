/*
---------------------------------------------------------------
File name:          plugin_loader.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件加载器 (Plugin loader)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件加载器 (Plugin loader);
---------------------------------------------------------------
*/
import 'dart:async';
import 'dart:isolate';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_exceptions.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';

/// 插件加载器
/// 
/// 负责插件的动态加载、卸载和生命周期管理
class PluginLoader {
  PluginLoader._();
  
  /// 单例实例
  static final PluginLoader _instance = PluginLoader._();
  static PluginLoader get instance => _instance;

  /// 插件注册中心
  final PluginRegistry _registry = PluginRegistry.instance;
  
  /// 加载中的插件
  final Map<String, Completer<void>> _loadingPlugins = <String, Completer<void>>{};
  
  /// 插件隔离环境
  final Map<String, Isolate?> _pluginIsolates = <String, Isolate?>{};
  
  /// 插件超时时间（秒）
  static const int _defaultTimeoutSeconds = 30;

  /// 加载插件
  /// 
  /// [plugin] 要加载的插件实例
  /// [timeoutSeconds] 加载超时时间，默认30秒
  Future<void> loadPlugin(
    Plugin plugin, {
    int timeoutSeconds = _defaultTimeoutSeconds,
  }) async {
    final String pluginId = plugin.id;
    
    // 检查插件是否已经在加载中
    if (_loadingPlugins.containsKey(pluginId)) {
      await _loadingPlugins[pluginId]!.future;
      return;
    }

    // 检查插件是否已经加载
    if (_registry.contains(pluginId)) {
      final PluginState? currentState = _registry.getState(pluginId);
      if (currentState != null && currentState != PluginState.unloaded) {
        throw PluginStateException(
          pluginId,
          currentState.toString(),
          PluginState.unloaded.toString(),
        );
      }
    }

    final Completer<void> completer = Completer<void>();
    _loadingPlugins[pluginId] = completer;

    try {
      // 设置超时
      await _loadPluginWithTimeout(plugin, timeoutSeconds);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingPlugins.remove(pluginId);
    }
  }

  /// 带超时的插件加载
  Future<void> _loadPluginWithTimeout(
    Plugin plugin,
    int timeoutSeconds,
  ) async {
    await Future.any([
      _doLoadPlugin(plugin),
      Future<void>.delayed(
        Duration(seconds: timeoutSeconds),
        () => throw PluginTimeoutException(plugin.id),
      ),
    ]);
  }

  /// 执行插件加载
  Future<void> _doLoadPlugin(Plugin plugin) async {
    final String pluginId = plugin.id;
    
    try {
      // 1. 验证插件
      await _validatePlugin(plugin);
      
      // 2. 注册插件到注册中心
      await _registry.register(plugin);
      
      // 3. 初始化插件
      _registry.updateState(pluginId, PluginState.loaded);
      await plugin.initialize();
      _registry.updateState(pluginId, PluginState.initialized);
      
      // 4. 启动插件
      await plugin.start();
      _registry.updateState(pluginId, PluginState.started);
      
    } catch (e) {
      // 加载失败，清理状态
      _registry.updateState(pluginId, PluginState.error);
      
      if (e is PluginException) {
        rethrow;
      } else {
        throw PluginLoadException(pluginId, e.toString());
      }
    }
  }

  /// 卸载插件
  /// 
  /// [pluginId] 要卸载的插件ID
  /// [force] 是否强制卸载，默认false
  Future<void> unloadPlugin(
    String pluginId, {
    bool force = false,
  }) async {
    final Plugin? plugin = _registry.get(pluginId);
    if (plugin == null) {
      throw PluginNotFoundException(pluginId);
    }

    final PluginState? currentState = _registry.getState(pluginId);
    if (currentState == null || currentState == PluginState.unloaded) {
      return; // 已经卸载
    }

    try {
      // 1. 停止插件
      if (currentState == PluginState.started) {
        await plugin.stop();
        _registry.updateState(pluginId, PluginState.stopped);
      }
      
      // 2. 销毁插件
      await plugin.dispose();
      
      // 3. 清理隔离环境
      await _cleanupIsolate(pluginId);
      
      // 4. 从注册中心注销
      await _registry.unregister(pluginId);
      
    } catch (e) {
      if (force) {
        // 强制卸载，忽略错误
        await _forceUnload(pluginId);
      } else {
        _registry.updateState(pluginId, PluginState.error);
        throw PluginLoadException(pluginId, 'Failed to unload: ${e.toString()}');
      }
    }
  }

  /// 重新加载插件
  /// 
  /// [pluginId] 要重新加载的插件ID
  /// [newPlugin] 新的插件实例，如果为null则使用原插件
  Future<void> reloadPlugin(
    String pluginId, {
    Plugin? newPlugin,
  }) async {
    final Plugin? currentPlugin = _registry.get(pluginId);
    if (currentPlugin == null) {
      throw PluginNotFoundException(pluginId);
    }

    // 1. 卸载当前插件
    await unloadPlugin(pluginId);
    
    // 2. 加载新插件
    final Plugin pluginToLoad = newPlugin ?? currentPlugin;
    await loadPlugin(pluginToLoad);
  }

  /// 暂停插件
  Future<void> pausePlugin(String pluginId) async {
    final Plugin? plugin = _registry.get(pluginId);
    if (plugin == null) {
      throw PluginNotFoundException(pluginId);
    }

    final PluginState? currentState = _registry.getState(pluginId);
    if (currentState != PluginState.started) {
      throw PluginStateException(
        pluginId,
        currentState.toString(),
        PluginState.started.toString(),
      );
    }

    try {
      await plugin.pause();
      _registry.updateState(pluginId, PluginState.paused);
    } catch (e) {
      _registry.updateState(pluginId, PluginState.error);
      throw PluginLoadException(pluginId, 'Failed to pause: ${e.toString()}');
    }
  }

  /// 恢复插件
  Future<void> resumePlugin(String pluginId) async {
    final Plugin? plugin = _registry.get(pluginId);
    if (plugin == null) {
      throw PluginNotFoundException(pluginId);
    }

    final PluginState? currentState = _registry.getState(pluginId);
    if (currentState != PluginState.paused) {
      throw PluginStateException(
        pluginId,
        currentState.toString(),
        PluginState.paused.toString(),
      );
    }

    try {
      await plugin.resume();
      _registry.updateState(pluginId, PluginState.started);
    } catch (e) {
      _registry.updateState(pluginId, PluginState.error);
      throw PluginLoadException(pluginId, 'Failed to resume: ${e.toString()}');
    }
  }

  /// 获取所有加载中的插件
  List<String> getLoadingPlugins() {
    return _loadingPlugins.keys.toList();
  }

  /// 检查插件是否正在加载
  bool isLoading(String pluginId) {
    return _loadingPlugins.containsKey(pluginId);
  }

  /// 等待插件加载完成
  Future<void> waitForPlugin(String pluginId) async {
    final Completer<void>? completer = _loadingPlugins[pluginId];
    if (completer != null) {
      await completer.future;
    }
  }

  /// 验证插件
  Future<void> _validatePlugin(Plugin plugin) async {
    // 检查插件平台支持
    if (plugin.supportedPlatforms.isEmpty) {
      throw PluginConfigurationException(
        plugin.id,
        'No supported platforms specified',
      );
    }

    // 检查权限声明
    for (final Permission permission in plugin.requiredPermissions) {
      if (!_isPermissionValid(permission)) {
        throw PermissionNotDeclaredException(plugin.id, permission.toString());
      }
    }
  }

  /// 检查权限是否有效
  bool _isPermissionValid(Permission permission) {
    // 简化的权限检查，实际项目中应该更完善
    return Permission.values.contains(permission);
  }

  /// 清理插件隔离环境
  Future<void> _cleanupIsolate(String pluginId) async {
    final Isolate? isolate = _pluginIsolates[pluginId];
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      _pluginIsolates.remove(pluginId);
    }
  }

  /// 强制卸载插件
  Future<void> _forceUnload(String pluginId) async {
    try {
      // 清理隔离环境
      await _cleanupIsolate(pluginId);
      
      // 强制从注册中心移除
      _registry.updateState(pluginId, PluginState.unloaded);
      
    } catch (e) {
      // 忽略强制卸载时的错误
    }
  }

  /// 卸载所有插件
  Future<void> unloadAllPlugins({bool force = false}) async {
    final List<Plugin> allPlugins = _registry.getAll();
    
    for (final Plugin plugin in allPlugins) {
      try {
        await unloadPlugin(plugin.id, force: force);
      } catch (e) {
        if (!force) {
          rethrow;
        }
        // 强制模式下忽略错误
      }
    }
  }

  /// 获取加载器状态信息
  Map<String, dynamic> getStatus() {
    return <String, dynamic>{
      'totalPlugins': _registry.count,
      'loadingPlugins': _loadingPlugins.length,
      'activeIsolates': _pluginIsolates.length,
      'loadingPluginIds': _loadingPlugins.keys.toList(),
    };
  }
}
