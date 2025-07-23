/*
---------------------------------------------------------------
File name:          dependency_node.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        依赖节点数据模型 - 集成Creative Workshop的依赖图功能
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.1.4 - 统一依赖解析算法，集成Creative Workshop实现;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

import 'plugin.dart';

/// 依赖冲突类型
enum DependencyConflictType {
  /// 版本不兼容
  versionIncompatible,

  /// 循环依赖
  circularDependency,

  /// 缺失依赖
  missingDependency,

  /// 平台不兼容
  platformIncompatible,

  /// 权限冲突
  permissionConflict,
}

/// 依赖冲突信息 (集成Creative Workshop功能)
@immutable
class DependencyConflict {
  const DependencyConflict({
    required this.pluginId,
    required this.dependencyId,
    required this.requiredVersion,
    required this.availableVersion,
    required this.conflictType,
    this.conflictingPlugins = const <String>[],
    this.description,
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

  /// 冲突的插件列表
  final List<String> conflictingPlugins;

  /// 冲突描述
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyConflict &&
          runtimeType == other.runtimeType &&
          pluginId == other.pluginId &&
          dependencyId == other.dependencyId &&
          conflictType == other.conflictType;

  @override
  int get hashCode =>
      pluginId.hashCode ^ dependencyId.hashCode ^ conflictType.hashCode;

  @override
  String toString() => 'DependencyConflict('
      'plugin: $pluginId, '
      'dependency: $dependencyId, '
      'type: $conflictType, '
      'required: $requiredVersion, '
      'available: $availableVersion)';
}

/// 依赖节点 (集成Creative Workshop功能)
@immutable
class DependencyNode {
  const DependencyNode({
    required this.pluginId,
    required this.version,
    required this.dependencies,
    this.optional = false,
    this.platform,
  });

  /// 插件ID
  final String pluginId;

  /// 插件版本
  final String version;

  /// 依赖列表
  final List<PluginDependency> dependencies;

  /// 是否为可选依赖
  final bool optional;

  /// 目标平台
  final String? platform;

  /// 获取直接依赖的插件ID列表
  List<String> get directDependencies =>
      dependencies.map((PluginDependency dep) => dep.pluginId).toList();

  /// 获取必需依赖的插件ID列表
  List<String> get requiredDependencies => dependencies
      .where((PluginDependency dep) => !dep.optional)
      .map((PluginDependency dep) => dep.pluginId)
      .toList();

  /// 获取可选依赖的插件ID列表
  List<String> get optionalDependencies => dependencies
      .where((PluginDependency dep) => dep.optional)
      .map((PluginDependency dep) => dep.pluginId)
      .toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyNode &&
          runtimeType == other.runtimeType &&
          pluginId == other.pluginId &&
          version == other.version;

  @override
  int get hashCode => pluginId.hashCode ^ version.hashCode;

  @override
  String toString() => 'DependencyNode('
      'id: $pluginId, '
      'version: $version, '
      'deps: ${dependencies.length})';
}

/// 依赖解析结果 (集成Creative Workshop功能)
@immutable
class DependencyResolutionResult {
  const DependencyResolutionResult({
    required this.success,
    required this.loadOrder,
    this.conflicts = const <DependencyConflict>[],
    this.missingDependencies = const <PluginDependency>[],
    this.circularDependencies = const <List<String>>[],
    this.error,
    this.warnings = const <String>[],
  });

  /// 是否解析成功
  final bool success;

  /// 插件加载顺序（拓扑排序结果）
  final List<String> loadOrder;

  /// 依赖冲突列表
  final List<DependencyConflict> conflicts;

  /// 缺失的依赖
  final List<PluginDependency> missingDependencies;

  /// 循环依赖路径
  final List<List<String>> circularDependencies;

  /// 错误信息
  final String? error;

  /// 警告信息
  final List<String> warnings;

  /// 创建成功结果
  factory DependencyResolutionResult.success({
    required List<String> loadOrder,
    List<String> warnings = const <String>[],
  }) =>
      DependencyResolutionResult(
        success: true,
        loadOrder: loadOrder,
        warnings: warnings,
      );

  /// 创建失败结果
  factory DependencyResolutionResult.failure({
    String? error,
    List<DependencyConflict> conflicts = const <DependencyConflict>[],
    List<PluginDependency> missingDependencies = const <PluginDependency>[],
    List<List<String>> circularDependencies = const <List<String>>[],
  }) =>
      DependencyResolutionResult(
        success: false,
        loadOrder: const <String>[],
        conflicts: conflicts,
        missingDependencies: missingDependencies,
        circularDependencies: circularDependencies,
        error: error,
      );

  /// 是否有冲突
  bool get hasConflicts => conflicts.isNotEmpty;

  /// 是否有缺失依赖
  bool get hasMissingDependencies => missingDependencies.isNotEmpty;

  /// 是否有循环依赖
  bool get hasCircularDependencies => circularDependencies.isNotEmpty;

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 获取所有问题的摘要
  String get problemSummary {
    final List<String> problems = <String>[];

    if (hasConflicts) {
      problems.add('${conflicts.length}个版本冲突');
    }

    if (hasMissingDependencies) {
      problems.add('${missingDependencies.length}个缺失依赖');
    }

    if (hasCircularDependencies) {
      problems.add('${circularDependencies.length}个循环依赖');
    }

    if (hasWarnings) {
      problems.add('${warnings.length}个警告');
    }

    return problems.isEmpty ? '无问题' : problems.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyResolutionResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          listEquals(loadOrder, other.loadOrder);

  @override
  int get hashCode => success.hashCode ^ loadOrder.hashCode;

  @override
  String toString() => 'DependencyResolutionResult('
      'success: $success, '
      'loadOrder: ${loadOrder.length} plugins, '
      'problems: $problemSummary)';
}

/// 插件安装信息 (用于依赖解析)
@immutable
class PluginInstallInfo {
  const PluginInstallInfo({
    required this.id,
    required this.version,
    required this.dependencies,
    this.state = PluginState.unloaded,
    this.installPath,
    this.size,
  });

  /// 插件ID
  final String id;

  /// 插件版本
  final String version;

  /// 插件依赖
  final List<PluginDependency> dependencies;

  /// 插件状态
  final PluginState state;

  /// 安装路径
  final String? installPath;

  /// 插件大小
  final int? size;

  /// 从Plugin创建安装信息
  factory PluginInstallInfo.fromPlugin(Plugin plugin) => PluginInstallInfo(
        id: plugin.id,
        version: plugin.version,
        dependencies: plugin.dependencies,
        state: plugin.currentState,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginInstallInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;

  @override
  String toString() => 'PluginInstallInfo('
      'id: $id, '
      'version: $version, '
      'state: $state)';
}
