/*
---------------------------------------------------------------
File name:          dependency_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        插件依赖管理器
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - 插件依赖管理器;
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';

/// 依赖解析结果
class DependencyResolutionResult {
  const DependencyResolutionResult({
    required this.success,
    required this.loadOrder,
    this.conflicts = const <DependencyConflict>[],
    this.missing = const <String>[],
  });

  /// 是否成功
  final bool success;

  /// 加载顺序
  final List<String> loadOrder;

  /// 依赖冲突
  final List<DependencyConflict> conflicts;

  /// 缺失的依赖
  final List<String> missing;
}

/// 依赖冲突
class DependencyConflict {
  const DependencyConflict({
    required this.pluginId,
    required this.dependencyId,
    required this.requiredVersion,
    required this.availableVersion,
    required this.conflictType,
  });

  /// 插件ID
  final String pluginId;

  /// 依赖插件ID
  final String dependencyId;

  /// 需要的版本
  final String requiredVersion;

  /// 可用的版本
  final String availableVersion;

  /// 冲突类型
  final DependencyConflictType conflictType;
}

/// 依赖冲突类型
enum DependencyConflictType {
  /// 版本不兼容
  versionIncompatible,

  /// 循环依赖
  circularDependency,

  /// 依赖缺失
  missingDependency,

  /// 多版本冲突
  multipleVersions,
}

/// 插件依赖管理器
///
/// 负责插件依赖的解析、验证和管理
class DependencyManager {
  DependencyManager._();

  /// 单例实例
  static final DependencyManager _instance = DependencyManager._();
  static DependencyManager get instance => _instance;

  /// 插件注册中心
  final PluginRegistry _registry = PluginRegistry.instance;

  /// 依赖图缓存
  final Map<String, Set<String>> _dependencyGraph = <String, Set<String>>{};

  /// 反向依赖图缓存
  final Map<String, Set<String>> _reverseDependencyGraph =
      <String, Set<String>>{};

  /// 解析插件依赖
  ///
  /// [plugins] 要解析的插件列表
  Future<DependencyResolutionResult> resolveDependencies(
    List<Plugin> plugins,
  ) async {
    // TODO(Critical): [Phase 2.9.1] 实现完整的依赖解析算法
    // 需要实现：
    // 1. 拓扑排序算法
    // 2. 版本兼容性检查
    // 3. 循环依赖检测
    // 4. 依赖冲突解决
    // 5. 可选依赖处理

    try {
      // 1. 构建依赖图
      _buildDependencyGraph(plugins);

      // 2. 检测循环依赖
      final List<String> circularDeps = _detectCircularDependencies(plugins);
      if (circularDeps.isNotEmpty) {
        return DependencyResolutionResult(
          success: false,
          loadOrder: const <String>[],
          conflicts: circularDeps
              .map((pluginId) => DependencyConflict(
                    pluginId: pluginId,
                    dependencyId: 'circular',
                    requiredVersion: '',
                    availableVersion: '',
                    conflictType: DependencyConflictType.circularDependency,
                  ))
              .toList(),
        );
      }

      // 3. 检查版本冲突
      final List<DependencyConflict> conflicts =
          await _checkVersionConflicts(plugins);

      // 4. 生成加载顺序
      final List<String> loadOrder = _generateLoadOrder(plugins);

      return DependencyResolutionResult(
        success: conflicts.isEmpty,
        loadOrder: loadOrder,
        conflicts: conflicts,
      );
    } catch (e) {
      return const DependencyResolutionResult(
        success: false,
        loadOrder: <String>[],
      );
    }
  }

  /// 检查插件依赖是否满足
  ///
  /// [plugin] 要检查的插件
  Future<bool> checkDependencies(Plugin plugin) async {
    // TODO(High): [Phase 2.9.1] 实现依赖检查逻辑
    // 需要实现：
    // 1. 必需依赖检查
    // 2. 可选依赖检查
    // 3. 版本兼容性验证
    // 4. 平台兼容性检查

    for (final PluginDependency dependency in plugin.dependencies) {
      final Plugin? depPlugin = _registry.get(dependency.pluginId);

      if (depPlugin == null) {
        if (!dependency.optional) {
          return false;
        }
        continue;
      }

      // 检查版本兼容性
      if (!_isVersionCompatible(
          depPlugin.version, dependency.versionConstraint)) {
        return false;
      }
    }

    return true;
  }

  /// 获取插件的所有依赖
  ///
  /// [pluginId] 插件ID
  /// [recursive] 是否递归获取
  List<String> getPluginDependencies(String pluginId,
      {bool recursive = false}) {
    // TODO(Medium): [Phase 2.9.1] 实现依赖获取逻辑
    // 需要实现：
    // 1. 直接依赖获取
    // 2. 递归依赖遍历
    // 3. 依赖去重
    // 4. 依赖排序

    final Set<String> dependencies = _dependencyGraph[pluginId] ?? <String>{};

    if (!recursive) {
      return dependencies.toList();
    }

    final Set<String> allDependencies = <String>{};
    final Set<String> visited = <String>{};

    void collectDependencies(String currentPluginId) {
      if (visited.contains(currentPluginId)) {
        return;
      }

      visited.add(currentPluginId);
      final Set<String> deps = _dependencyGraph[currentPluginId] ?? <String>{};

      for (final String dep in deps) {
        allDependencies.add(dep);
        collectDependencies(dep);
      }
    }

    collectDependencies(pluginId);
    return allDependencies.toList();
  }

  /// 获取依赖于指定插件的插件列表
  ///
  /// [pluginId] 插件ID
  List<String> getPluginDependents(String pluginId) {
    // TODO(Medium): [Phase 2.9.1] 实现依赖者获取逻辑
    return (_reverseDependencyGraph[pluginId] ?? <String>{}).toList();
  }

  /// 检查是否可以安全卸载插件
  ///
  /// [pluginId] 插件ID
  bool canUnloadPlugin(String pluginId) {
    // TODO(High): [Phase 2.9.1] 实现安全卸载检查
    // 需要实现：
    // 1. 检查是否有其他插件依赖
    // 2. 检查运行时依赖
    // 3. 检查用户数据依赖

    final List<String> dependents = getPluginDependents(pluginId);

    // 检查是否有活跃的依赖者
    for (final String dependent in dependents) {
      final PluginState? state = _registry.getState(dependent);
      if (state == PluginState.started || state == PluginState.initialized) {
        return false;
      }
    }

    return true;
  }

  /// 自动安装缺失的依赖
  ///
  /// [plugin] 插件
  Future<List<String>> autoInstallDependencies(Plugin plugin) async {
    // TODO(Medium): [Phase 2.9.1] 实现自动依赖安装
    // 需要实现：
    // 1. 依赖源配置
    // 2. 依赖下载和安装
    // 3. 版本选择策略
    // 4. 安装进度报告
    // 5. 安装失败回滚

    final List<String> installed = <String>[];

    for (final PluginDependency dependency in plugin.dependencies) {
      if (!_registry.contains(dependency.pluginId)) {
        // 这里应该实现实际的依赖安装逻辑
        // 目前只是模拟
        print('Would install dependency: ${dependency.pluginId}');
        installed.add(dependency.pluginId);
      }
    }

    return installed;
  }

  /// 更新依赖图
  ///
  /// [plugin] 插件
  void updateDependencyGraph(Plugin plugin) {
    // TODO(High): [Phase 2.9.1] 实现依赖图更新
    // 需要实现：
    // 1. 依赖关系更新
    // 2. 反向依赖更新
    // 3. 图结构优化
    // 4. 缓存失效处理

    final Set<String> dependencies =
        plugin.dependencies.map((dep) => dep.pluginId).toSet();

    _dependencyGraph[plugin.id] = dependencies;

    // 更新反向依赖图
    for (final String depId in dependencies) {
      _reverseDependencyGraph.putIfAbsent(depId, () => <String>{});
      _reverseDependencyGraph[depId]!.add(plugin.id);
    }
  }

  /// 清理插件依赖信息
  ///
  /// [pluginId] 插件ID
  void cleanupPlugin(String pluginId) {
    // TODO(Medium): [Phase 2.9.1] 实现依赖信息清理
    // 需要实现：
    // 1. 移除依赖关系
    // 2. 清理反向依赖
    // 3. 更新依赖图

    // 移除插件的依赖关系
    final Set<String>? dependencies = _dependencyGraph.remove(pluginId);

    // 从反向依赖图中移除
    if (dependencies != null) {
      for (final String depId in dependencies) {
        _reverseDependencyGraph[depId]?.remove(pluginId);
      }
    }

    // 移除其他插件对此插件的反向依赖
    _reverseDependencyGraph.remove(pluginId);
  }

  /// 构建依赖图
  void _buildDependencyGraph(List<Plugin> plugins) {
    // TODO(High): [Phase 2.9.1] 优化依赖图构建算法
    for (final Plugin plugin in plugins) {
      updateDependencyGraph(plugin);
    }
  }

  /// 检测循环依赖
  List<String> _detectCircularDependencies(List<Plugin> plugins) {
    // TODO(Critical): [Phase 2.9.1] 实现循环依赖检测算法
    // 需要实现：
    // 1. 深度优先搜索
    // 2. 访问状态跟踪
    // 3. 循环路径记录

    final Set<String> visited = <String>{};
    final Set<String> recursionStack = <String>{};
    final List<String> circularDeps = <String>[];

    bool hasCycle(String pluginId) {
      if (recursionStack.contains(pluginId)) {
        circularDeps.add(pluginId);
        return true;
      }

      if (visited.contains(pluginId)) {
        return false;
      }

      visited.add(pluginId);
      recursionStack.add(pluginId);

      final Set<String> dependencies = _dependencyGraph[pluginId] ?? <String>{};
      for (final String dep in dependencies) {
        if (hasCycle(dep)) {
          return true;
        }
      }

      recursionStack.remove(pluginId);
      return false;
    }

    for (final Plugin plugin in plugins) {
      if (!visited.contains(plugin.id)) {
        hasCycle(plugin.id);
      }
    }

    return circularDeps;
  }

  /// 检查版本冲突
  Future<List<DependencyConflict>> _checkVersionConflicts(
      List<Plugin> plugins) async {
    // TODO(High): [Phase 2.9.1] 实现版本冲突检测
    // 需要实现：
    // 1. 语义化版本解析
    // 2. 版本约束检查
    // 3. 多版本冲突检测

    final List<DependencyConflict> conflicts = <DependencyConflict>[];

    for (final Plugin plugin in plugins) {
      for (final PluginDependency dependency in plugin.dependencies) {
        final Plugin? depPlugin = _registry.get(dependency.pluginId);

        if (depPlugin != null) {
          if (!_isVersionCompatible(
              depPlugin.version, dependency.versionConstraint)) {
            conflicts.add(DependencyConflict(
              pluginId: plugin.id,
              dependencyId: dependency.pluginId,
              requiredVersion: dependency.versionConstraint,
              availableVersion: depPlugin.version,
              conflictType: DependencyConflictType.versionIncompatible,
            ));
          }
        }
      }
    }

    return conflicts;
  }

  /// 生成加载顺序
  List<String> _generateLoadOrder(List<Plugin> plugins) {
    // TODO(Critical): [Phase 2.9.1] 实现拓扑排序算法
    // 需要实现：
    // 1. 拓扑排序
    // 2. 优先级考虑
    // 3. 并行加载优化

    final List<String> loadOrder = <String>[];
    final Set<String> visited = <String>{};

    void visit(String pluginId) {
      if (visited.contains(pluginId)) {
        return;
      }

      visited.add(pluginId);

      final Set<String> dependencies = _dependencyGraph[pluginId] ?? <String>{};
      for (final String dep in dependencies) {
        visit(dep);
      }

      loadOrder.add(pluginId);
    }

    for (final Plugin plugin in plugins) {
      visit(plugin.id);
    }

    return loadOrder;
  }

  /// 检查版本兼容性
  bool _isVersionCompatible(String version, String constraint) {
    // TODO(High): [Phase 2.9.1] 实现语义化版本兼容性检查
    // 需要实现：
    // 1. 语义化版本解析
    // 2. 版本约束解析
    // 3. 兼容性规则检查

    // 简化实现：只检查精确匹配
    return version == constraint || constraint.isEmpty;
  }
}
