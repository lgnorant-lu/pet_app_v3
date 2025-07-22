/*
---------------------------------------------------------------
File name:          installed_plugins_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        已安装插件标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 已安装插件管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

/// 已安装插件标签页
class InstalledPluginsTab extends StatefulWidget {
  const InstalledPluginsTab({super.key});

  @override
  State<InstalledPluginsTab> createState() => _InstalledPluginsTabState();
}

class _InstalledPluginsTabState extends State<InstalledPluginsTab> {
  late final PluginManager _pluginManager;
  List<PluginInstallInfo> _plugins = [];
  String _searchQuery = '';
  PluginState? _selectedState;
  bool _sortByName = true;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _pluginManager = PluginManager.instance;
    _pluginManager.addListener(_loadPlugins);
    _loadPlugins();
  }

  @override
  void dispose() {
    _pluginManager.removeListener(_loadPlugins);
    super.dispose();
  }

  /// 加载插件列表
  void _loadPlugins() {
    setState(() {
      _plugins = _pluginManager.installedPlugins;
      _sortPlugins();
    });
  }

  /// 排序插件
  void _sortPlugins() {
    _plugins.sort((a, b) {
      int result;
      if (_sortByName) {
        result = a.name.compareTo(b.name);
      } else {
        result = a.installedAt.compareTo(b.installedAt);
      }
      return _sortAscending ? result : -result;
    });
  }

  /// 过滤插件
  List<PluginInstallInfo> get _filteredPlugins {
    return _plugins.where((plugin) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!plugin.name.toLowerCase().contains(query) &&
            !plugin.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态过滤
      if (_selectedState != null && plugin.state != _selectedState) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索和过滤栏
        _buildSearchAndFilterBar(),

        // 插件列表
        Expanded(
          child: _buildPluginList(),
        ),
      ],
    );
  }

  /// 构建搜索和过滤栏
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索框
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: '搜索插件...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),

          const SizedBox(height: 12),

          // 过滤和排序选项
          Row(
            children: [
              // 状态过滤
              Expanded(
                child: DropdownButtonFormField<PluginState?>(
                  value: _selectedState,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '状态过滤',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<PluginState?>(
                      value: null,
                      child: Text('全部状态'),
                    ),
                    ...PluginState.values.map((state) => DropdownMenuItem(
                          value: state,
                          child: Text(_getStateDisplayName(state)),
                        )),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 排序选项
              PopupMenuButton<String>(
                icon: Icon(
                  _sortAscending ? Icons.sort : Icons.sort,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onSelected: _handleSortOption,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'name_asc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          color: _sortByName && _sortAscending
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('按名称升序'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_desc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          color: _sortByName && !_sortAscending
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('按名称降序'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: !_sortByName && _sortAscending
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('按安装时间升序'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: !_sortByName && !_sortAscending
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('按安装时间降序'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建插件列表
  Widget _buildPluginList() {
    final filteredPlugins = _filteredPlugins;

    if (filteredPlugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _plugins.isEmpty ? '暂无已安装插件' : '没有找到匹配的插件',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredPlugins.length,
      itemBuilder: (context, index) {
        return _buildPluginCard(filteredPlugins[index]);
      },
    );
  }

  /// 构建插件卡片
  Widget _buildPluginCard(PluginInstallInfo plugin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 插件标题和状态
            Row(
              children: [
                // 插件图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStateColor(plugin.state),
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
                      const SizedBox(height: 2),
                      Text(
                        'v${plugin.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // 状态标签
                _buildStateChip(plugin.state),
              ],
            ),

            const SizedBox(height: 12),

            // 插件详细信息
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '安装: ${_formatDate(plugin.installedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.storage,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatSize(plugin.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (plugin.lastUsedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '最近使用: ${_formatDate(plugin.lastUsedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),

            // 权限和依赖信息
            if (plugin.permissions.isNotEmpty ||
                plugin.dependencies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (plugin.permissions.isNotEmpty) ...[
                    Icon(
                      Icons.security,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plugin.permissions.length} 项权限',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (plugin.permissions.isNotEmpty &&
                      plugin.dependencies.isNotEmpty)
                    const SizedBox(width: 16),
                  if (plugin.dependencies.isNotEmpty) ...[
                    Icon(
                      Icons.account_tree,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plugin.dependencies.length} 个依赖',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 12),

            // 操作按钮
            Row(
              children: [
                if (plugin.state == PluginState.disabled)
                  ElevatedButton.icon(
                    onPressed: () => _enablePlugin(plugin),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('启用'),
                  )
                else if (plugin.state == PluginState.enabled)
                  OutlinedButton.icon(
                    onPressed: () => _disablePlugin(plugin),
                    icon: const Icon(Icons.pause, size: 16),
                    label: const Text('禁用'),
                  ),

                if (plugin.state == PluginState.updateAvailable) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updatePlugin(plugin),
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('更新'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],

                const Spacer(),

                // 更多操作
                PopupMenuButton<String>(
                  onSelected: (action) => _handlePluginAction(action, plugin),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Text('详细信息'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'permissions',
                      child: Row(
                        children: [
                          Icon(Icons.security),
                          SizedBox(width: 8),
                          Text('权限管理'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('插件设置'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'uninstall',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('卸载', style: TextStyle(color: Colors.red)),
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

  /// 构建状态标签
  Widget _buildStateChip(PluginState state) {
    final color = _getStateColor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStateDisplayName(state),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStateColor(PluginState state) {
    switch (state) {
      case PluginState.enabled:
        return Colors.green;
      case PluginState.disabled:
        return Colors.grey;
      case PluginState.updateAvailable:
        return Colors.orange;
      case PluginState.installing:
      case PluginState.enabling:
      case PluginState.disabling:
      case PluginState.updating:
        return Colors.blue;
      case PluginState.installFailed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 获取状态显示名称
  String _getStateDisplayName(PluginState state) {
    switch (state) {
      case PluginState.notInstalled:
        return '未安装';
      case PluginState.downloading:
        return '下载中';
      case PluginState.installing:
        return '安装中';
      case PluginState.installed:
        return '已安装';
      case PluginState.enabling:
        return '启用中';
      case PluginState.enabled:
        return '已启用';
      case PluginState.disabling:
        return '禁用中';
      case PluginState.disabled:
        return '已禁用';
      case PluginState.uninstalling:
        return '卸载中';
      case PluginState.installFailed:
        return '安装失败';
      case PluginState.updateAvailable:
        return '有更新';
      case PluginState.updating:
        return '更新中';
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 处理排序选项
  void _handleSortOption(String option) {
    setState(() {
      switch (option) {
        case 'name_asc':
          _sortByName = true;
          _sortAscending = true;
          break;
        case 'name_desc':
          _sortByName = true;
          _sortAscending = false;
          break;
        case 'date_asc':
          _sortByName = false;
          _sortAscending = true;
          break;
        case 'date_desc':
          _sortByName = false;
          _sortAscending = false;
          break;
      }
      _sortPlugins();
    });
  }

  /// 启用插件
  Future<void> _enablePlugin(PluginInstallInfo plugin) async {
    final result = await _pluginManager.enablePlugin(plugin.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.message! : result.error!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 禁用插件
  Future<void> _disablePlugin(PluginInstallInfo plugin) async {
    final result = await _pluginManager.disablePlugin(plugin.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.message! : result.error!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 更新插件
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

  /// 处理插件操作
  void _handlePluginAction(String action, PluginInstallInfo plugin) {
    switch (action) {
      case 'details':
        _showPluginDetails(plugin);
        break;
      case 'permissions':
        _showPluginPermissions(plugin);
        break;
      case 'settings':
        _showPluginSettings(plugin);
        break;
      case 'uninstall':
        _uninstallPlugin(plugin);
        break;
    }
  }

  /// 显示插件详情
  void _showPluginDetails(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现插件详情对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${plugin.name} 详情')),
    );
  }

  /// 显示插件权限
  void _showPluginPermissions(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现权限管理对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('管理 ${plugin.name} 权限')),
    );
  }

  /// 显示插件设置
  void _showPluginSettings(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现插件设置对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('配置 ${plugin.name} 设置')),
    );
  }

  /// 卸载插件
  Future<void> _uninstallPlugin(PluginInstallInfo plugin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认卸载'),
        content: Text('确定要卸载插件 "${plugin.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('卸载'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _pluginManager.uninstallPlugin(plugin.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? result.message! : result.error!),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
