/*
---------------------------------------------------------------
File name:          quick_access_panel.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        快速访问面板组件 - 常用功能快捷入口
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 快速访问面板
class QuickAccessPanel extends StatelessWidget {
  const QuickAccessPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '快速访问',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllActions(context),
                  child: const Text('查看全部'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 快速操作按钮
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: '新建项目',
                  color: Colors.blue,
                  onTap: () => _handleQuickAction(context, 'new_project'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.folder_open,
                  label: '最近项目',
                  color: Colors.green,
                  onTap: () => _handleQuickAction(context, 'recent_projects'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.extension,
                  label: '插件管理',
                  color: Colors.orange,
                  onTap: () => _handleQuickAction(context, 'plugin_manager'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.build,
                  label: '工具箱',
                  color: Colors.purple,
                  onTap: () => _handleQuickAction(context, 'toolbox'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.help_outline,
                  label: '帮助文档',
                  color: Colors.teal,
                  onTap: () => _handleQuickAction(context, 'help'),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.feedback,
                  label: '反馈建议',
                  color: Colors.indigo,
                  onTap: () => _handleQuickAction(context, 'feedback'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 处理快速操作
  void _handleQuickAction(BuildContext context, String actionId) {
    switch (actionId) {
      case 'new_project':
        _showNewProjectDialog(context);
        break;
      case 'recent_projects':
        _showRecentProjects(context);
        break;
      case 'plugin_manager':
        _navigateToPluginManager(context);
        break;
      case 'toolbox':
        _showToolbox(context);
        break;
      case 'help':
        _showHelp(context);
        break;
      case 'feedback':
        _showFeedback(context);
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('功能开发中: $actionId')));
    }
  }

  /// 显示新建项目对话框
  void _showNewProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建项目'),
        content: const Text('选择项目类型：'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('创意工坊功能开发中...')));
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  /// 显示最近项目
  void _showRecentProjects(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近项目', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('暂无最近项目'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 导航到插件管理
  void _navigateToPluginManager(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('插件管理功能开发中...')));
  }

  /// 显示工具箱
  void _showToolbox(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('工具箱功能开发中...')));
  }

  /// 显示帮助
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助文档'),
        content: const Text(
          'Pet App V3 使用指南\n\n1. 首页仪表板显示各模块状态\n2. 快速访问面板提供常用功能\n3. 设置页面可配置应用偏好',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示反馈
  void _showFeedback(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('反馈功能开发中...')));
  }

  /// 显示所有操作
  void _showAllActions(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('更多快速操作功能开发中...')));
  }
}
