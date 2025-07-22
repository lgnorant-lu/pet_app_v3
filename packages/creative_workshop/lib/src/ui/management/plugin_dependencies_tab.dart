/*
---------------------------------------------------------------
File name:          plugin_dependencies_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件依赖管理标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件依赖管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

/// 依赖关系节点
class DependencyNode {
  const DependencyNode({
    required this.plugin,
    required this.dependencies,
    required this.dependents,
  });

  final PluginInstallInfo plugin;
  final List<PluginDependency> dependencies;
  final List<PluginInstallInfo> dependents;
}

/// 插件依赖管理标签页
class PluginDependenciesTab extends StatefulWidget {
  const PluginDependenciesTab({super.key});

  @override
  State<PluginDependenciesTab> createState() => _PluginDependenciesTabState();
}

class _PluginDependenciesTabState extends State<PluginDependenciesTab> {
  late final PluginManager _pluginManager;
  List<DependencyNode> _dependencyNodes = [];
  PluginInstallInfo? _selectedPlugin;

  @override
  void initState() {
    super.initState();
    _pluginManager = PluginManager.instance;
    _pluginManager.addListener(_buildDependencyGraph);
    _buildDependencyGraph();
  }

  @override
  void dispose() {
    _pluginManager.removeListener(_buildDependencyGraph);
    super.dispose();
  }

  /// 构建依赖关系图
  void _buildDependencyGraph() {
    final plugins = _pluginManager.installedPlugins;
    final nodes = <DependencyNode>[];

    for (final plugin in plugins) {
      // 查找依赖此插件的其他插件
      final dependents = plugins
          .where((p) => p.dependencies.any((dep) => dep.pluginId == plugin.id))
          .toList();

      nodes.add(DependencyNode(
        plugin: plugin,
        dependencies: plugin.dependencies,
        dependents: dependents,
      ));
    }

    setState(() {
      _dependencyNodes = nodes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 依赖概览
        _buildDependencyOverview(),

        // 主要内容区域
        Expanded(
          child: _selectedPlugin == null
              ? _buildDependencyList()
              : _buildPluginDependencyDetails(_selectedPlugin!),
        ),
      ],
    );
  }

  /// 构建依赖概览
  Widget _buildDependencyOverview() {
    final totalPlugins = _dependencyNodes.length;
    final pluginsWithDeps =
        _dependencyNodes.where((n) => n.dependencies.isNotEmpty).length;
    final totalDependencies =
        _dependencyNodes.fold<int>(0, (sum, n) => sum + n.dependencies.length);
    final circularDeps = _detectCircularDependencies().length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '依赖关系概览',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDependencyStatCard(
                  '总插件数',
                  totalPlugins.toString(),
                  Icons.extension,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDependencyStatCard(
                  '有依赖的插件',
                  pluginsWithDeps.toString(),
                  Icons.link,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDependencyStatCard(
                  '总依赖数',
                  totalDependencies.toString(),
                  Icons.account_tree,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDependencyStatCard(
                  '循环依赖',
                  circularDeps.toString(),
                  Icons.warning,
                  circularDeps > 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建依赖统计卡片
  Widget _buildDependencyStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建依赖列表
  Widget _buildDependencyList() {
    if (_dependencyNodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无依赖关系',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dependencyNodes.length,
      itemBuilder: (context, index) {
        return _buildDependencyCard(_dependencyNodes[index]);
      },
    );
  }

  /// 构建依赖卡片
  Widget _buildDependencyCard(DependencyNode node) {
    final hasIssues = _hasIssues(node);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasIssues ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            hasIssues ? Icons.warning : Icons.extension,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          node.plugin.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (node.dependencies.isNotEmpty)
              Text('依赖: ${node.dependencies.length} 个插件'),
            if (node.dependents.isNotEmpty)
              Text('被依赖: ${node.dependents.length} 个插件'),
            if (node.dependencies.isEmpty && node.dependents.isEmpty)
              const Text('无依赖关系'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIssues)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Text(
                  '有问题',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedPlugin = node.plugin;
          });
        },
      ),
    );
  }

  /// 构建插件依赖详情
  Widget _buildPluginDependencyDetails(PluginInstallInfo plugin) {
    final node = _dependencyNodes.firstWhere((n) => n.plugin.id == plugin.id);

    return Column(
      children: [
        // 返回按钮和插件标题
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedPlugin = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.extension,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v${plugin.version}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 依赖详情内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 依赖的插件
                if (node.dependencies.isNotEmpty) ...[
                  Text(
                    '依赖的插件 (${node.dependencies.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...node.dependencies.map((dep) => _buildDependencyItem(dep)),
                  const SizedBox(height: 24),
                ],

                // 依赖此插件的其他插件
                if (node.dependents.isNotEmpty) ...[
                  Text(
                    '依赖此插件的其他插件 (${node.dependents.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...node.dependents
                      .map((dependent) => _buildDependentItem(dependent)),
                  const SizedBox(height: 24),
                ],

                // 依赖关系图
                Text(
                  '依赖关系图',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDependencyVisualization(node),

                // 操作按钮
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _validateDependencies(plugin),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('验证依赖'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _exportDependencyGraph(plugin),
                      icon: const Icon(Icons.download),
                      label: const Text('导出关系图'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建依赖项
  Widget _buildDependencyItem(PluginDependency dependency) {
    final depPlugin = _pluginManager.getPluginInfo(dependency.pluginId);
    final isInstalled = depPlugin != null;
    final isEnabled = isInstalled && depPlugin.state == PluginState.enabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.error,
            color: isEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependency.pluginId,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '版本: ${dependency.version} ${dependency.isRequired ? "(必需)" : "(可选)"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (!isInstalled)
                  const Text(
                    '未安装',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  )
                else if (!isEnabled)
                  const Text(
                    '未启用',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          if (!isInstalled)
            TextButton(
              onPressed: () => _installDependency(dependency),
              child: const Text('安装'),
            )
          else if (!isEnabled)
            TextButton(
              onPressed: () => _enableDependency(dependency),
              child: const Text('启用'),
            ),
        ],
      ),
    );
  }

  /// 构建依赖者项
  Widget _buildDependentItem(PluginInstallInfo dependent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.extension,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependent.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'v${dependent.version}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: dependent.state == PluginState.enabled
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dependent.state == PluginState.enabled ? '已启用' : '已禁用',
              style: TextStyle(
                fontSize: 10,
                color: dependent.state == PluginState.enabled
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建依赖关系可视化
  Widget _buildDependencyVisualization(DependencyNode node) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // 当前插件
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              node.plugin.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 依赖箭头和依赖项
          if (node.dependencies.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Icon(Icons.arrow_downward, color: Colors.grey),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: node.dependencies.map((dep) {
                final depPlugin = _pluginManager.getPluginInfo(dep.pluginId);
                final isAvailable =
                    depPlugin != null && depPlugin.state == PluginState.enabled;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dep.pluginId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // 被依赖箭头和被依赖项
          if (node.dependents.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Icon(Icons.arrow_upward, color: Colors.grey),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: node.dependents.map((dependent) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dependent.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 检查是否有问题
  bool _hasIssues(DependencyNode node) {
    for (final dep in node.dependencies) {
      final depPlugin = _pluginManager.getPluginInfo(dep.pluginId);
      if (depPlugin == null || depPlugin.state != PluginState.enabled) {
        if (dep.isRequired) {
          return true;
        }
      }
    }
    return false;
  }

  /// 检测循环依赖
  List<List<String>> _detectCircularDependencies() {
    // TODO: Phase 5.0.6.4 - 实现循环依赖检测算法
    return [];
  }

  /// 安装依赖
  Future<void> _installDependency(PluginDependency dependency) async {
    // TODO: Phase 5.0.6.4 - 实现依赖安装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在安装依赖: ${dependency.pluginId}')),
    );
  }

  /// 启用依赖
  Future<void> _enableDependency(PluginDependency dependency) async {
    final result = await _pluginManager.enablePlugin(dependency.pluginId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.message! : result.error!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 验证依赖
  Future<void> _validateDependencies(PluginInstallInfo plugin) async {
    // TODO: Phase 5.0.6.4 - 实现依赖验证
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在验证 ${plugin.name} 的依赖关系...')),
    );
  }

  /// 导出依赖关系图
  void _exportDependencyGraph(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现依赖关系图导出
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导出 ${plugin.name} 的依赖关系图')),
    );
  }
}
