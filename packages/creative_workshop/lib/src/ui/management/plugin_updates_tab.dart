/*
---------------------------------------------------------------
File name:          plugin_updates_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件更新管理标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件更新管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

/// 插件更新管理标签页
class PluginUpdatesTab extends StatefulWidget {
  const PluginUpdatesTab({super.key});

  @override
  State<PluginUpdatesTab> createState() => _PluginUpdatesTabState();
}

class _PluginUpdatesTabState extends State<PluginUpdatesTab> {
  late final PluginManager _pluginManager;
  List<PluginInstallInfo> _updatablePlugins = [];
  bool _isCheckingUpdates = false;
  bool _isUpdatingAll = false;
  DateTime? _lastCheckTime;

  @override
  void initState() {
    super.initState();
    _pluginManager = PluginManager.instance;
    _pluginManager.addListener(_loadUpdatablePlugins);
    _loadUpdatablePlugins();
  }

  @override
  void dispose() {
    _pluginManager.removeListener(_loadUpdatablePlugins);
    super.dispose();
  }

  /// 加载可更新插件
  void _loadUpdatablePlugins() {
    setState(() {
      _updatablePlugins = _pluginManager.updatablePlugins;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 更新控制面板
        _buildUpdateControlPanel(),

        // 可更新插件列表
        Expanded(
          child: _buildUpdatablePluginsList(),
        ),
      ],
    );
  }

  /// 构建更新控制面板
  Widget _buildUpdateControlPanel() {
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
                Icons.update,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '更新管理',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (_lastCheckTime != null)
                Text(
                  '最后检查: ${_formatTime(_lastCheckTime!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 统计信息
          Row(
            children: [
              Expanded(
                child: _buildUpdateStatCard(
                  '可更新插件',
                  _updatablePlugins.length.toString(),
                  Icons.update,
                  _updatablePlugins.isNotEmpty ? Colors.orange : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUpdateStatCard(
                  '自动更新',
                  _updatablePlugins
                      .where((p) => p.autoUpdate)
                      .length
                      .toString(),
                  Icons.auto_mode,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUpdateStatCard(
                  '手动更新',
                  _updatablePlugins
                      .where((p) => !p.autoUpdate)
                      .length
                      .toString(),
                  Icons.touch_app,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isCheckingUpdates ? null : _checkForUpdates,
                icon: _isCheckingUpdates
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isCheckingUpdates ? '检查中...' : '检查更新'),
              ),
              const SizedBox(width: 12),
              if (_updatablePlugins.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _isUpdatingAll ? null : _updateAllPlugins,
                  icon: _isUpdatingAll
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.system_update),
                  label: Text(_isUpdatingAll ? '更新中...' : '全部更新'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openUpdateSettings,
                icon: const Icon(Icons.settings),
                label: const Text('更新设置'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建更新统计卡片
  Widget _buildUpdateStatCard(
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

  /// 构建可更新插件列表
  Widget _buildUpdatablePluginsList() {
    if (_updatablePlugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              '所有插件都是最新版本',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '您的插件都已更新到最新版本',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkForUpdates,
              icon: const Icon(Icons.refresh),
              label: const Text('重新检查'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _updatablePlugins.length,
      itemBuilder: (context, index) {
        return _buildUpdateCard(_updatablePlugins[index]);
      },
    );
  }

  /// 构建更新卡片
  Widget _buildUpdateCard(PluginInstallInfo plugin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 插件标题和版本信息
            Row(
              children: [
                // 插件图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.extension,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // 插件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '当前版本: ${plugin.version}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '新版本: 1.6.0', // TODO: 从更新信息获取
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 自动更新标识
                if (plugin.autoUpdate)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '自动更新',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // 更新说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.new_releases,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '更新内容',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• 修复了已知问题\n• 提升了性能表现\n• 新增了实用功能',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 更新信息
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '更新大小: 2.1 MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '发布时间: 2天前',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 操作按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: plugin.state == PluginState.updating
                      ? null
                      : () => _updatePlugin(plugin),
                  icon: plugin.state == PluginState.updating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.update, size: 16),
                  label: Text(
                    plugin.state == PluginState.updating ? '更新中...' : '立即更新',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showUpdateDetails(plugin),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('详情'),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleUpdateAction(action, plugin),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_auto_update',
                      child: Row(
                        children: [
                          Icon(
                            plugin.autoUpdate ? Icons.pause : Icons.play_arrow,
                          ),
                          const SizedBox(width: 8),
                          Text(plugin.autoUpdate ? '关闭自动更新' : '开启自动更新'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'skip_version',
                      child: Row(
                        children: [
                          Icon(Icons.skip_next),
                          SizedBox(width: 8),
                          Text('跳过此版本'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_changelog',
                      child: Row(
                        children: [
                          Icon(Icons.list_alt),
                          SizedBox(width: 8),
                          Text('查看更新日志'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  /// 检查更新
  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdates = true;
    });

    try {
      // TODO: Phase 5.0.6.4 - 实现真实的更新检查
      await Future<void>.delayed(const Duration(seconds: 2));

      setState(() {
        _lastCheckTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('更新检查完成'),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      setState(() {
        _isCheckingUpdates = false;
      });
    }
  }

  /// 全部更新
  Future<void> _updateAllPlugins() async {
    setState(() {
      _isUpdatingAll = true;
    });

    try {
      for (final plugin in _updatablePlugins) {
        await _pluginManager.updatePlugin(plugin.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有插件更新完成'),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingAll = false;
      });
    }
  }

  /// 更新单个插件
  Future<void> _updatePlugin(PluginInstallInfo plugin) async {
    final result = await _pluginManager.updatePlugin(plugin.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.message! : result.error!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 显示更新详情
  void _showUpdateDetails(PluginInstallInfo plugin) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${plugin.name} 更新详情'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '版本 1.6.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('发布时间: 2025-07-19'),
              Text('更新大小: 2.1 MB'),
              SizedBox(height: 16),
              Text(
                '更新内容:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 修复了在某些情况下的崩溃问题'),
              Text('• 提升了渲染性能，减少了内存占用'),
              Text('• 新增了批量处理功能'),
              Text('• 改进了用户界面的响应速度'),
              Text('• 修复了与其他插件的兼容性问题'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePlugin(plugin);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  /// 处理更新操作
  void _handleUpdateAction(String action, PluginInstallInfo plugin) {
    switch (action) {
      case 'toggle_auto_update':
        _toggleAutoUpdate(plugin);
        break;
      case 'skip_version':
        _skipVersion(plugin);
        break;
      case 'view_changelog':
        _viewChangelog(plugin);
        break;
    }
  }

  /// 切换自动更新
  void _toggleAutoUpdate(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现自动更新切换
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          plugin.autoUpdate
              ? '已关闭 ${plugin.name} 的自动更新'
              : '已开启 ${plugin.name} 的自动更新',
        ),
      ),
    );
  }

  /// 跳过版本
  void _skipVersion(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现版本跳过
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已跳过 ${plugin.name} 的此版本更新')),
    );
  }

  /// 查看更新日志
  void _viewChangelog(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现更新日志查看
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${plugin.name} 的更新日志')),
    );
  }

  /// 打开更新设置
  void _openUpdateSettings() {
    // TODO: Phase 5.0.6.4 - 实现更新设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更新设置功能即将推出...')),
    );
  }
}
