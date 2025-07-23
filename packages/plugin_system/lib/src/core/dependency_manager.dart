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
import 'dart:collection';

import 'package:pub_semver/pub_semver.dart';

import 'package:plugin_system/src/core/dependency_node.dart';
import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/plugin_registry.dart';

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

  /// 解析插件依赖 (集成Creative Workshop算法)
  ///
  /// [plugins] 要解析的插件列表
  /// [installedPlugins] 已安装的插件映射
  /// [availablePlugins] 可用的插件映射（用于查找缺失依赖）
  Future<DependencyResolutionResult> resolveDependencies(
    List<Plugin> plugins, {
    Map<String, PluginInstallInfo>? installedPlugins,
    Map<String, PluginInstallInfo>? availablePlugins,
  }) async {
    try {
      // 转换插件列表为安装信息映射
      final Map<String, PluginInstallInfo> pluginInfoMap =
          <String, PluginInstallInfo>{};
      for (final Plugin plugin in plugins) {
        pluginInfoMap[plugin.id] = PluginInstallInfo.fromPlugin(plugin);
      }

      // 使用提供的映射或默认映射
      final Map<String, PluginInstallInfo> installed =
          installedPlugins ?? pluginInfoMap;
      final Map<String, PluginInstallInfo> available =
          availablePlugins ?? <String, PluginInstallInfo>{};

      // 1. 构建依赖图
      final Map<String, DependencyNode> dependencyGraph =
          _buildDependencyGraphAdvanced(plugins, installed, available);

      // 2. 检查缺失依赖
      final List<PluginDependency> missingDeps =
          _findMissingDependencies(plugins, installed, available);
      if (missingDeps.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在缺失的依赖',
          missingDependencies: missingDeps,
        );
      }

      // 3. 检查版本冲突
      final List<DependencyConflict> conflicts =
          _findVersionConflicts(dependencyGraph, installed);
      if (conflicts.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在版本冲突',
          conflicts: conflicts,
        );
      }

      // 4. 检查循环依赖
      final List<List<String>> cycles =
          _findCircularDependencies(dependencyGraph);
      if (cycles.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在循环依赖',
          circularDependencies: cycles,
        );
      }

      // 5. 生成安装顺序（拓扑排序）
      final List<String> installOrder = _topologicalSort(dependencyGraph);

      return DependencyResolutionResult.success(
        loadOrder: installOrder,
      );
    } catch (e) {
      return DependencyResolutionResult.failure(
        error: '依赖解析失败: $e',
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
        depPlugin.version,
        dependency.versionConstraint,
      )) {
        return false;
      }
    }

    return true;
  }

  /// 获取插件的所有依赖
  ///
  /// [pluginId] 插件ID
  /// [recursive] 是否递归获取
  List<String> getPluginDependencies(
    String pluginId, {
    bool recursive = false,
  }) {
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
        plugin.dependencies.map((PluginDependency dep) => dep.pluginId).toSet();

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

  /// 构建高级依赖图 (集成Creative Workshop算法)
  Map<String, DependencyNode> _buildDependencyGraphAdvanced(
    List<Plugin> plugins,
    Map<String, PluginInstallInfo> installedPlugins,
    Map<String, PluginInstallInfo> availablePlugins,
  ) {
    final Map<String, DependencyNode> graph = <String, DependencyNode>{};
    final Set<String> visited = <String>{};

    void buildNode(PluginInstallInfo plugin) {
      if (visited.contains(plugin.id)) return;
      visited.add(plugin.id);

      // 创建节点
      final DependencyNode node = DependencyNode(
        pluginId: plugin.id,
        version: plugin.version,
        dependencies: plugin.dependencies,
      );
      graph[plugin.id] = node;

      // 递归处理依赖
      for (final PluginDependency dep in plugin.dependencies) {
        final PluginInstallInfo? depPlugin =
            installedPlugins[dep.pluginId] ?? availablePlugins[dep.pluginId];
        if (depPlugin != null) {
          buildNode(depPlugin);
        }
      }
    }

    // 为所有插件构建节点
    for (final Plugin plugin in plugins) {
      final PluginInstallInfo pluginInfo = PluginInstallInfo.fromPlugin(plugin);
      buildNode(pluginInfo);
    }

    return graph;
  }

  /// 查找缺失依赖 (集成Creative Workshop算法)
  List<PluginDependency> _findMissingDependencies(
    List<Plugin> plugins,
    Map<String, PluginInstallInfo> installedPlugins,
    Map<String, PluginInstallInfo> availablePlugins,
  ) {
    final List<PluginDependency> missing = <PluginDependency>[];
    final Set<String> checked = <String>{};

    void checkDependencies(List<PluginDependency> dependencies) {
      for (final PluginDependency dep in dependencies) {
        if (checked.contains(dep.pluginId)) continue;
        checked.add(dep.pluginId);

        // 检查是否在已安装或可用插件中
        final bool isInstalled = installedPlugins.containsKey(dep.pluginId);
        final bool isAvailable = availablePlugins.containsKey(dep.pluginId);

        if (!isInstalled && !isAvailable && !dep.optional) {
          missing.add(dep);
        } else if (isInstalled || isAvailable) {
          // 递归检查依赖的依赖
          final PluginInstallInfo? plugin =
              installedPlugins[dep.pluginId] ?? availablePlugins[dep.pluginId];
          if (plugin != null) {
            checkDependencies(plugin.dependencies);
          }
        }
      }
    }

    // 检查所有插件的依赖
    for (final Plugin plugin in plugins) {
      checkDependencies(plugin.dependencies);
    }

    return missing;
  }

  /// 查找版本冲突 (集成Creative Workshop算法)
  List<DependencyConflict> _findVersionConflicts(
    Map<String, DependencyNode> dependencyGraph,
    Map<String, PluginInstallInfo> installedPlugins,
  ) {
    final List<DependencyConflict> conflicts = <DependencyConflict>[];
    final Map<String, Set<String>> versionRequirements =
        <String, Set<String>>{};

    // 收集所有版本要求
    for (final DependencyNode node in dependencyGraph.values) {
      for (final PluginDependency dep in node.dependencies) {
        versionRequirements.putIfAbsent(dep.pluginId, () => <String>{});
        versionRequirements[dep.pluginId]!.add(dep.versionConstraint);
      }
    }

    // 检查版本冲突
    for (final MapEntry<String, Set<String>> entry
        in versionRequirements.entries) {
      final String pluginId = entry.key;
      final Set<String> requiredVersions = entry.value;
      final PluginInstallInfo? installedPlugin = installedPlugins[pluginId];

      if (installedPlugin != null) {
        // 检查每个版本要求是否与已安装版本兼容
        for (final String requiredVersion in requiredVersions) {
          if (!_isVersionCompatible(
            installedPlugin.version,
            requiredVersion,
          )) {
            conflicts.add(
              DependencyConflict(
                pluginId: 'unknown',
                dependencyId: pluginId,
                requiredVersion: requiredVersion,
                availableVersion: installedPlugin.version,
                conflictType: DependencyConflictType.versionIncompatible,
              ),
            );
          }
        }
      }
    }

    return conflicts;
  }

  /// 检查版本兼容性 (集成Creative Workshop算法)
  bool _isVersionCompatible(String availableVersion, String requiredVersion) {
    try {
      final Version available = Version.parse(availableVersion);
      final VersionConstraint constraint =
          VersionConstraint.parse(requiredVersion);
      return constraint.allows(available);
    } catch (e) {
      // 如果解析失败，使用简单字符串比较
      return availableVersion == requiredVersion;
    }
  }

  /// 查找循环依赖 (集成Creative Workshop算法)
  List<List<String>> _findCircularDependencies(
    Map<String, DependencyNode> dependencyGraph,
  ) {
    final List<List<String>> cycles = <List<String>>[];
    final Set<String> visited = <String>{};
    final Set<String> recursionStack = <String>{};
    final List<String> currentPath = <String>[];

    bool dfs(String pluginId) {
      if (recursionStack.contains(pluginId)) {
        // 找到循环，提取循环路径
        final int cycleStart = currentPath.indexOf(pluginId);
        if (cycleStart >= 0) {
          final List<String> cycle = currentPath.sublist(cycleStart)
            ..add(pluginId);
          cycles.add(cycle);
        }
        return true;
      }

      if (visited.contains(pluginId)) {
        return false;
      }

      visited.add(pluginId);
      recursionStack.add(pluginId);
      currentPath.add(pluginId);

      final DependencyNode? node = dependencyGraph[pluginId];
      if (node != null) {
        for (final PluginDependency dep in node.dependencies) {
          if (dfs(dep.pluginId)) {
            // 继续搜索其他可能的循环
          }
        }
      }

      recursionStack.remove(pluginId);
      currentPath.removeLast();
      return false;
    }

    // 对所有节点进行DFS
    for (final String pluginId in dependencyGraph.keys) {
      if (!visited.contains(pluginId)) {
        dfs(pluginId);
      }
    }

    return cycles;
  }

  /// 拓扑排序 (集成Creative Workshop算法)
  List<String> _topologicalSort(Map<String, DependencyNode> dependencyGraph) {
    final List<String> result = <String>[];
    final Map<String, int> inDegree = <String, int>{};
    final Queue<String> queue = Queue<String>();

    // 计算入度
    for (final String pluginId in dependencyGraph.keys) {
      inDegree[pluginId] = 0;
    }

    for (final DependencyNode node in dependencyGraph.values) {
      for (final PluginDependency dep in node.dependencies) {
        if (dependencyGraph.containsKey(dep.pluginId)) {
          // 修复：当node依赖dep时，应该是node的入度增加，而不是dep的入度增加
          inDegree[node.pluginId] = (inDegree[node.pluginId] ?? 0) + 1;
        }
      }
    }

    // 将入度为0的节点加入队列
    for (final MapEntry<String, int> entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    // Kahn算法
    while (queue.isNotEmpty) {
      final String current = queue.removeFirst();
      result.add(current);

      // 修复：当处理current节点时，需要减少依赖于current的其他节点的入度
      for (final DependencyNode otherNode in dependencyGraph.values) {
        for (final PluginDependency dep in otherNode.dependencies) {
          if (dep.pluginId == current) {
            // otherNode依赖current，所以current被处理后，otherNode的入度减1
            inDegree[otherNode.pluginId] =
                (inDegree[otherNode.pluginId] ?? 1) - 1;
            if (inDegree[otherNode.pluginId] == 0) {
              queue.add(otherNode.pluginId);
            }
          }
        }
      }
    }

    return result;
  }
}
