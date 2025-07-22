/*
---------------------------------------------------------------
File name:          plugin_management_page.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件管理主界面
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';
import 'package:creative_workshop/src/ui/management/installed_plugins_tab.dart';
import 'package:creative_workshop/src/ui/management/plugin_permissions_tab.dart';
import 'package:creative_workshop/src/ui/management/plugin_updates_tab.dart';
import 'package:creative_workshop/src/ui/management/plugin_dependencies_tab.dart';

/// 插件管理主界面
class PluginManagementPage extends StatefulWidget {
  const PluginManagementPage({
    super.key,
    this.initialTabIndex = 0,
  });

  /// 初始标签页索引
  final int initialTabIndex;

  @override
  State<PluginManagementPage> createState() => _PluginManagementPageState();
}

class _PluginManagementPageState extends State<PluginManagementPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PluginManager _pluginManager;

  // 统计数据
  int _totalInstalled = 0;
  int _totalEnabled = 0;
  int _totalSize = 0;
  int _needsUpdate = 0;

  @override
  void initState() {
    super.initState();
    _pluginManager = PluginManager.instance;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // 监听插件管理器变化
    _pluginManager.addListener(_updateStats);
    _updateStats();
  }

  @override
  void dispose() {
    _pluginManager.removeListener(_updateStats);
    _tabController.dispose();
    super.dispose();
  }

  /// 更新统计数据
  void _updateStats() {
    final stats = _pluginManager.getPluginStats();
    setState(() {
      _totalInstalled = (stats['totalInstalled'] as int?) ?? 0;
      _totalEnabled = (stats['totalEnabled'] as int?) ?? 0;
      _totalSize = (stats['totalSize'] as int?) ?? 0;
      _needsUpdate = (stats['needsUpdate'] as int?) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '返回应用商店',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPlugins,
            tooltip: '刷新插件',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'check_updates',
                child: Row(
                  children: [
                    Icon(Icons.update),
                    SizedBox(width: 8),
                    Text('检查更新'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(width: 8),
                    Text('清理缓存'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('管理设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.extension),
              text: '已安装 ($_totalInstalled)',
            ),
            const Tab(
              icon: Icon(Icons.security),
              text: '权限管理',
            ),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.update),
                  if (_needsUpdate > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          _needsUpdate.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              text: '更新',
            ),
            const Tab(
              icon: Icon(Icons.account_tree),
              text: '依赖关系',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 统计面板
          _buildStatsPanel(),

          // 主要内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                InstalledPluginsTab(),
                PluginPermissionsTab(),
                PluginUpdatesTab(),
                PluginDependenciesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计面板
  Widget _buildStatsPanel() {
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
              const Icon(
                Icons.analytics,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                '插件统计',
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
                child: _buildStatCard(
                  '已安装',
                  _totalInstalled.toString(),
                  Icons.extension,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '已启用',
                  _totalEnabled.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '占用空间',
                  _formatSize(_totalSize),
                  Icons.storage,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '待更新',
                  _needsUpdate.toString(),
                  Icons.update,
                  _needsUpdate > 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
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
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// 刷新插件
  Future<void> _refreshPlugins() async {
    // TODO: Phase 5.0.6.4 - 实现插件刷新
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新插件列表...')),
    );

    // 模拟刷新过程
    await Future<void>.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('插件列表已刷新')),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'check_updates':
        _checkUpdates();
        break;
      case 'cleanup':
        _cleanupCache();
        break;
      case 'settings':
        _openSettings();
        break;
    }
  }

  /// 检查更新
  Future<void> _checkUpdates() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查插件更新...')),
    );

    // TODO: Phase 5.0.6.4 - 实现更新检查
    await Future<void>.delayed(const Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更新检查完成')),
    );
  }

  /// 清理缓存
  Future<void> _cleanupCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理插件缓存吗？这将删除所有临时文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在清理缓存...')),
      );

      // TODO: Phase 5.0.6.4 - 实现缓存清理
      await Future<void>.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存清理完成')),
      );
    }
  }

  /// 打开设置
  void _openSettings() {
    // TODO: Phase 5.0.6.4 - 实现管理设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('管理设置功能即将推出...')),
    );
  }
}
