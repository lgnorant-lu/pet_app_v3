/*
---------------------------------------------------------------
File name:          dependency_resolver.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件依赖解析器 - 处理插件依赖关系的分析和解析
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.4 - 依赖解析算法实现;
---------------------------------------------------------------
*/

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'plugin_manager.dart';

/// 依赖解析结果
class DependencyResolutionResult {
  const DependencyResolutionResult({
    required this.success,
    this.installOrder = const [],
    this.missingDependencies = const [],
    this.conflictingDependencies = const [],
    this.circularDependencies = const [],
    this.error,
  });

  /// 是否解析成功
  final bool success;

  /// 安装顺序（拓扑排序结果）
  final List<String> installOrder;

  /// 缺失的依赖
  final List<PluginDependency> missingDependencies;

  /// 冲突的依赖
  final List<DependencyConflict> conflictingDependencies;

  /// 循环依赖
  final List<List<String>> circularDependencies;

  /// 错误信息
  final String? error;

  /// 创建成功结果
  factory DependencyResolutionResult.success({
    List<String> installOrder = const [],
  }) {
    return DependencyResolutionResult(
      success: true,
      installOrder: installOrder,
    );
  }

  /// 创建失败结果
  factory DependencyResolutionResult.failure({
    String? error,
    List<PluginDependency> missingDependencies = const [],
    List<DependencyConflict> conflictingDependencies = const [],
    List<List<String>> circularDependencies = const [],
  }) {
    return DependencyResolutionResult(
      success: false,
      error: error,
      missingDependencies: missingDependencies,
      conflictingDependencies: conflictingDependencies,
      circularDependencies: circularDependencies,
    );
  }
}

/// 依赖冲突信息
class DependencyConflict {
  const DependencyConflict({
    required this.pluginId,
    required this.requiredVersion,
    required this.installedVersion,
    required this.conflictingPlugins,
  });

  /// 冲突的插件ID
  final String pluginId;

  /// 需要的版本约束
  final String requiredVersion;

  /// 已安装的版本
  final String installedVersion;

  /// 产生冲突的插件列表
  final List<String> conflictingPlugins;

  @override
  String toString() {
    return 'DependencyConflict(pluginId: $pluginId, '
        'required: $requiredVersion, installed: $installedVersion, '
        'conflicting: ${conflictingPlugins.join(', ')})';
  }
}

/// 依赖图节点
class DependencyNode {
  DependencyNode({
    required this.pluginId,
    required this.version,
    this.dependencies = const [],
  });

  /// 插件ID
  final String pluginId;

  /// 插件版本
  final String version;

  /// 依赖列表
  final List<PluginDependency> dependencies;

  /// 入度（被依赖的次数）
  int inDegree = 0;

  /// 出度（依赖其他插件的次数）
  int get outDegree => dependencies.length;

  @override
  String toString() {
    return 'DependencyNode(pluginId: $pluginId, version: $version, '
        'inDegree: $inDegree, outDegree: $outDegree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DependencyNode && other.pluginId == pluginId;
  }

  @override
  int get hashCode => pluginId.hashCode;
}

/// 插件依赖解析器
///
/// 负责分析插件依赖关系，检测冲突和循环依赖，生成安装顺序
class DependencyResolver {
  DependencyResolver._();
  static final DependencyResolver _instance = DependencyResolver._();
  static DependencyResolver get instance => _instance;

  /// 解析插件依赖关系
  ///
  /// [targetPlugin] 目标插件信息
  /// [installedPlugins] 已安装的插件映射
  /// [availablePlugins] 可用的插件映射（用于查找缺失依赖）
  DependencyResolutionResult resolveDependencies({
    required PluginInstallInfo targetPlugin,
    required Map<String, PluginInstallInfo> installedPlugins,
    Map<String, PluginInstallInfo>? availablePlugins,
  }) {
    try {
      // 构建依赖图
      final dependencyGraph = _buildDependencyGraph(
        targetPlugin,
        installedPlugins,
        availablePlugins ?? {},
      );

      // 检查缺失依赖
      final missingDeps = _findMissingDependencies(
        targetPlugin,
        installedPlugins,
        availablePlugins ?? {},
      );

      if (missingDeps.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在缺失的依赖',
          missingDependencies: missingDeps,
        );
      }

      // 检查版本冲突
      final conflicts =
          _findVersionConflicts(dependencyGraph, installedPlugins);
      if (conflicts.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在版本冲突',
          conflictingDependencies: conflicts,
        );
      }

      // 检查循环依赖
      final cycles = _findCircularDependencies(dependencyGraph);
      if (cycles.isNotEmpty) {
        return DependencyResolutionResult.failure(
          error: '存在循环依赖',
          circularDependencies: cycles,
        );
      }

      // 生成安装顺序（拓扑排序）
      final installOrder = _topologicalSort(dependencyGraph);

      return DependencyResolutionResult.success(
        installOrder: installOrder,
      );
    } catch (e) {
      return DependencyResolutionResult.failure(
        error: '依赖解析失败: $e',
      );
    }
  }

  /// 检查版本约束兼容性
  ///
  /// [versionConstraint] 版本约束字符串（如 "^1.0.0", ">=1.0.0 <2.0.0"）
  /// [installedVersion] 已安装的版本
  bool isVersionCompatible(String versionConstraint, String installedVersion) {
    try {
      final constraint = VersionConstraint.parse(versionConstraint);
      final version = Version.parse(installedVersion);
      return constraint.allows(version);
    } catch (e) {
      debugPrint('版本兼容性检查失败: $e');
      return false;
    }
  }

  /// 构建依赖图
  Map<String, DependencyNode> _buildDependencyGraph(
    PluginInstallInfo targetPlugin,
    Map<String, PluginInstallInfo> installedPlugins,
    Map<String, PluginInstallInfo> availablePlugins,
  ) {
    final graph = <String, DependencyNode>{};
    final visited = <String>{};

    void buildNode(PluginInstallInfo plugin) {
      if (visited.contains(plugin.id)) return;
      visited.add(plugin.id);

      // 创建节点
      final node = DependencyNode(
        pluginId: plugin.id,
        version: plugin.version,
        dependencies: plugin.dependencies,
      );
      graph[plugin.id] = node;

      // 递归处理依赖
      for (final dep in plugin.dependencies) {
        final depPlugin =
            installedPlugins[dep.pluginId] ?? availablePlugins[dep.pluginId];
        if (depPlugin != null) {
          buildNode(depPlugin);
        }
      }
    }

    // 构建目标插件的依赖图
    buildNode(targetPlugin);

    // 同时包含所有已安装的插件到图中
    for (final plugin in installedPlugins.values) {
      buildNode(plugin);
    }

    // 计算入度：如果A依赖B，那么A的入度+1（A需要等B先安装）
    for (final node in graph.values) {
      node.inDegree = node.dependencies.length;
    }

    return graph;
  }

  /// 查找缺失的依赖
  List<PluginDependency> _findMissingDependencies(
    PluginInstallInfo targetPlugin,
    Map<String, PluginInstallInfo> installedPlugins,
    Map<String, PluginInstallInfo> availablePlugins,
  ) {
    final missingDeps = <PluginDependency>[];
    final visited = <String>{};

    void checkDependencies(PluginInstallInfo plugin) {
      if (visited.contains(plugin.id)) return;
      visited.add(plugin.id);

      for (final dep in plugin.dependencies) {
        final depPlugin =
            installedPlugins[dep.pluginId] ?? availablePlugins[dep.pluginId];

        if (depPlugin == null) {
          if (dep.isRequired) {
            missingDeps.add(dep);
          }
        } else {
          // 递归检查依赖的依赖
          checkDependencies(depPlugin);
        }
      }
    }

    checkDependencies(targetPlugin);
    return missingDeps;
  }

  /// 查找版本冲突
  List<DependencyConflict> _findVersionConflicts(
    Map<String, DependencyNode> graph,
    Map<String, PluginInstallInfo> installedPlugins,
  ) {
    final conflicts = <DependencyConflict>[];
    final versionRequirements = <String, Map<String, List<String>>>{};

    // 收集所有版本要求
    for (final node in graph.values) {
      for (final dep in node.dependencies) {
        versionRequirements
            .putIfAbsent(dep.pluginId, () => {})
            .putIfAbsent(dep.version, () => [])
            .add(node.pluginId);
      }
    }

    // 检查版本冲突
    for (final entry in versionRequirements.entries) {
      final pluginId = entry.key;
      final requirements = entry.value;
      final installedPlugin = installedPlugins[pluginId];

      if (installedPlugin != null) {
        // 检查是否所有要求都与已安装版本兼容
        final incompatibleRequirements = <String, List<String>>{};

        for (final reqEntry in requirements.entries) {
          final versionConstraint = reqEntry.key;
          final requestingPlugins = reqEntry.value;

          if (!isVersionCompatible(
              versionConstraint, installedPlugin.version)) {
            incompatibleRequirements[versionConstraint] = requestingPlugins;
          }
        }

        if (incompatibleRequirements.isNotEmpty) {
          final allConflictingPlugins = incompatibleRequirements.values
              .expand((plugins) => plugins)
              .toList();

          conflicts.add(DependencyConflict(
            pluginId: pluginId,
            requiredVersion: incompatibleRequirements.keys.join(', '),
            installedVersion: installedPlugin.version,
            conflictingPlugins: allConflictingPlugins,
          ));
        }
      }
    }

    return conflicts;
  }

  /// 查找循环依赖
  List<List<String>> _findCircularDependencies(
    Map<String, DependencyNode> graph,
  ) {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final recursionStack = <String>{};
    final currentPath = <String>[];

    void dfs(String pluginId) {
      if (recursionStack.contains(pluginId)) {
        // 找到循环依赖
        final cycleStart = currentPath.indexOf(pluginId);
        if (cycleStart >= 0) {
          final cycle = currentPath.sublist(cycleStart)..add(pluginId);
          cycles.add(cycle);
        }
        return;
      }

      if (visited.contains(pluginId)) return;

      visited.add(pluginId);
      recursionStack.add(pluginId);
      currentPath.add(pluginId);

      final node = graph[pluginId];
      if (node != null) {
        for (final dep in node.dependencies) {
          if (graph.containsKey(dep.pluginId)) {
            dfs(dep.pluginId);
          }
        }
      }

      recursionStack.remove(pluginId);
      currentPath.removeLast();
    }

    for (final pluginId in graph.keys) {
      if (!visited.contains(pluginId)) {
        dfs(pluginId);
      }
    }

    return cycles;
  }

  /// 拓扑排序生成安装顺序
  List<String> _topologicalSort(Map<String, DependencyNode> graph) {
    final result = <String>[];
    final queue = Queue<String>();
    final inDegreeMap = <String, int>{};

    // 初始化入度映射
    for (final node in graph.values) {
      inDegreeMap[node.pluginId] = node.inDegree;
    }

    // 将入度为0的节点加入队列（这些是没有依赖的节点，应该先安装）
    for (final entry in inDegreeMap.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    // 拓扑排序
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(current);

      // 当前节点已安装，现在可以安装依赖它的节点
      // 找到所有依赖当前节点的节点，减少它们的入度
      for (final node in graph.values) {
        for (final dep in node.dependencies) {
          if (dep.pluginId == current) {
            // 当前节点被安装了，所以依赖它的节点的入度减1
            inDegreeMap[node.pluginId] = inDegreeMap[node.pluginId]! - 1;
            if (inDegreeMap[node.pluginId] == 0) {
              queue.add(node.pluginId);
            }
          }
        }
      }
    }
    return result;
  }

  /// 验证依赖图的完整性
  bool validateDependencyGraph(Map<String, DependencyNode> graph) {
    // 检查所有依赖是否都在图中
    for (final node in graph.values) {
      for (final dep in node.dependencies) {
        if (!graph.containsKey(dep.pluginId)) {
          debugPrint('依赖图不完整: ${node.pluginId} 依赖 ${dep.pluginId}，但后者不在图中');
          return false;
        }
      }
    }
    return true;
  }

  /// 计算依赖深度
  int calculateDependencyDepth(
    String pluginId,
    Map<String, DependencyNode> graph,
  ) {
    final visited = <String>{};

    int dfs(String currentId) {
      if (visited.contains(currentId)) return 0;
      visited.add(currentId);

      final node = graph[currentId];
      if (node == null || node.dependencies.isEmpty) return 0;

      int maxDepth = 0;
      for (final dep in node.dependencies) {
        final depth = dfs(dep.pluginId);
        maxDepth = maxDepth > depth ? maxDepth : depth;
      }

      return maxDepth + 1;
    }

    return dfs(pluginId);
  }

  /// 获取依赖统计信息
  Map<String, dynamic> getDependencyStats(Map<String, DependencyNode> graph) {
    if (graph.isEmpty) {
      return {
        'totalNodes': 0,
        'totalEdges': 0,
        'maxInDegree': 0,
        'maxOutDegree': 0,
        'averageInDegree': 0.0,
        'averageOutDegree': 0.0,
      };
    }

    final totalNodes = graph.length;
    final totalEdges =
        graph.values.fold<int>(0, (sum, node) => sum + node.outDegree);
    final maxInDegree = graph.values
        .map((node) => node.inDegree)
        .reduce((a, b) => a > b ? a : b);
    final maxOutDegree = graph.values
        .map((node) => node.outDegree)
        .reduce((a, b) => a > b ? a : b);
    final averageInDegree =
        graph.values.map((node) => node.inDegree).reduce((a, b) => a + b) /
            totalNodes;
    final averageOutDegree = totalEdges / totalNodes;

    return {
      'totalNodes': totalNodes,
      'totalEdges': totalEdges,
      'maxInDegree': maxInDegree,
      'maxOutDegree': maxOutDegree,
      'averageInDegree': averageInDegree,
      'averageOutDegree': averageOutDegree,
    };
  }
}
