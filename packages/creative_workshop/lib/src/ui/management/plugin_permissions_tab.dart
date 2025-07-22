/*
---------------------------------------------------------------
File name:          plugin_permissions_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件权限管理标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件权限管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

/// 权限使用统计
class PermissionUsage {
  const PermissionUsage({
    required this.permission,
    required this.pluginCount,
    required this.plugins,
  });

  final PluginPermission permission;
  final int pluginCount;
  final List<PluginInstallInfo> plugins;
}

/// 插件权限管理标签页
class PluginPermissionsTab extends StatefulWidget {
  const PluginPermissionsTab({super.key});

  @override
  State<PluginPermissionsTab> createState() => _PluginPermissionsTabState();
}

class _PluginPermissionsTabState extends State<PluginPermissionsTab> {
  late final PluginManager _pluginManager;
  List<PermissionUsage> _permissionUsages = [];
  PluginPermission? _selectedPermission;

  @override
  void initState() {
    super.initState();
    _pluginManager = PluginManager.instance;
    _pluginManager.addListener(_loadPermissionUsages);
    _loadPermissionUsages();
  }

  @override
  void dispose() {
    _pluginManager.removeListener(_loadPermissionUsages);
    super.dispose();
  }

  /// 加载权限使用情况
  void _loadPermissionUsages() {
    final plugins = _pluginManager.installedPlugins;
    final usageMap = <PluginPermission, List<PluginInstallInfo>>{};

    // 统计每个权限的使用情况
    for (final plugin in plugins) {
      for (final permission in plugin.permissions) {
        usageMap.putIfAbsent(permission, () => []).add(plugin);
      }
    }

    setState(() {
      _permissionUsages = usageMap.entries
          .map((entry) => PermissionUsage(
                permission: entry.key,
                pluginCount: entry.value.length,
                plugins: entry.value,
              ))
          .toList();

      // 按使用插件数量排序
      _permissionUsages.sort((a, b) => b.pluginCount.compareTo(a.pluginCount));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 权限概览
        _buildPermissionOverview(),

        // 权限详细列表
        Expanded(
          child: _selectedPermission == null
              ? _buildPermissionList()
              : _buildPermissionDetails(_selectedPermission!),
        ),
      ],
    );
  }

  /// 构建权限概览
  Widget _buildPermissionOverview() {
    final totalPermissions = PluginPermission.values.length;
    final usedPermissions = _permissionUsages.length;
    final totalPlugins = _pluginManager.installedPlugins.length;
    final pluginsWithPermissions = _pluginManager.installedPlugins
        .where((p) => p.permissions.isNotEmpty)
        .length;

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
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '权限概览',
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
                child: _buildOverviewCard(
                  '总权限数',
                  totalPermissions.toString(),
                  Icons.security,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '已使用权限',
                  usedPermissions.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '需要权限的插件',
                  '$pluginsWithPermissions/$totalPlugins',
                  Icons.extension,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建概览卡片
  Widget _buildOverviewCard(
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

  /// 构建权限列表
  Widget _buildPermissionList() {
    if (_permissionUsages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无权限使用记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 返回按钮（当选择了权限时显示）
        if (_selectedPermission != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedPermission = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回权限列表'),
                ),
              ],
            ),
          ),

        // 权限列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _permissionUsages.length,
            itemBuilder: (context, index) {
              return _buildPermissionCard(_permissionUsages[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 构建权限卡片
  Widget _buildPermissionCard(PermissionUsage usage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getPermissionColor(usage.permission),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPermissionIcon(usage.permission),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          usage.permission.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${usage.pluginCount} 个插件使用'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${usage.pluginCount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getPermissionColor(usage.permission),
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
            _selectedPermission = usage.permission;
          });
        },
      ),
    );
  }

  /// 构建权限详情
  Widget _buildPermissionDetails(PluginPermission permission) {
    final usage = _permissionUsages.firstWhere((u) => u.permission == permission);

    return Column(
      children: [
        // 返回按钮和权限标题
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
                    _selectedPermission = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPermissionColor(permission),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPermissionIcon(permission),
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
                      permission.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${usage.pluginCount} 个插件使用此权限',
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

        // 使用此权限的插件列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usage.plugins.length,
            itemBuilder: (context, index) {
              return _buildPluginPermissionCard(usage.plugins[index], permission);
            },
          ),
        ),
      ],
    );
  }

  /// 构建插件权限卡片
  Widget _buildPluginPermissionCard(PluginInstallInfo plugin, PluginPermission permission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: plugin.state == PluginState.enabled ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.extension,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          plugin.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${plugin.version}'),
            Text(
              '状态: ${_getStateDisplayName(plugin.state)}',
              style: TextStyle(
                color: plugin.state == PluginState.enabled ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handlePluginPermissionAction(action, plugin, permission),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'revoke',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('撤销权限', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text('查看详情'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取权限颜色
  Color _getPermissionColor(PluginPermission permission) {
    switch (permission) {
      case PluginPermission.fileSystem:
        return Colors.blue;
      case PluginPermission.network:
        return Colors.green;
      case PluginPermission.notifications:
        return Colors.orange;
      case PluginPermission.clipboard:
        return Colors.purple;
      case PluginPermission.camera:
        return Colors.red;
      case PluginPermission.microphone:
        return Colors.pink;
      case PluginPermission.location:
        return Colors.teal;
      case PluginPermission.deviceInfo:
        return Colors.brown;
    }
  }

  /// 获取权限图标
  IconData _getPermissionIcon(PluginPermission permission) {
    switch (permission) {
      case PluginPermission.fileSystem:
        return Icons.folder;
      case PluginPermission.network:
        return Icons.wifi;
      case PluginPermission.notifications:
        return Icons.notifications;
      case PluginPermission.clipboard:
        return Icons.content_paste;
      case PluginPermission.camera:
        return Icons.camera_alt;
      case PluginPermission.microphone:
        return Icons.mic;
      case PluginPermission.location:
        return Icons.location_on;
      case PluginPermission.deviceInfo:
        return Icons.info;
    }
  }

  /// 获取状态显示名称
  String _getStateDisplayName(PluginState state) {
    switch (state) {
      case PluginState.enabled:
        return '已启用';
      case PluginState.disabled:
        return '已禁用';
      case PluginState.installed:
        return '已安装';
      case PluginState.updateAvailable:
        return '有更新';
      default:
        return '其他';
    }
  }

  /// 处理插件权限操作
  void _handlePluginPermissionAction(
    String action,
    PluginInstallInfo plugin,
    PluginPermission permission,
  ) {
    switch (action) {
      case 'revoke':
        _revokePermission(plugin, permission);
        break;
      case 'details':
        _showPluginDetails(plugin);
        break;
    }
  }

  /// 撤销权限
  Future<void> _revokePermission(PluginInstallInfo plugin, PluginPermission permission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤销权限'),
        content: Text(
          '确定要撤销插件 "${plugin.name}" 的 "${permission.displayName}" 权限吗？\n\n'
          '撤销后插件可能无法正常工作。',
        ),
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
            child: const Text('撤销'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Phase 5.0.6.4 - 实现权限撤销逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已撤销 ${plugin.name} 的 ${permission.displayName} 权限'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// 显示插件详情
  void _showPluginDetails(PluginInstallInfo plugin) {
    // TODO: Phase 5.0.6.4 - 实现插件详情对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${plugin.name} 详情')),
    );
  }
}
