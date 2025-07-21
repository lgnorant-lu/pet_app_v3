/*
---------------------------------------------------------------
File name:          quick_access_panel.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        快速访问面板组件 - 常用功能快捷入口 (迁移到模块)
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

            // 快速操作按钮网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildQuickAction(
                  context,
                  '新建项目',
                  Icons.add_circle_outline,
                  Colors.blue,
                  () => _createNewProject(context),
                ),
                _buildQuickAction(
                  context,
                  '插件市场',
                  Icons.store,
                  Colors.green,
                  () => _openPluginStore(context),
                ),
                _buildQuickAction(
                  context,
                  '最近项目',
                  Icons.history,
                  Colors.orange,
                  () => _showRecentProjects(context),
                ),
                _buildQuickAction(
                  context,
                  '设置',
                  Icons.settings,
                  Colors.grey,
                  () => _openSettings(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 最近活动
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '最近活动',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 最近活动列表
            Column(
              children: [
                _buildRecentActivity(
                  context,
                  '创建了新项目 "Flutter UI Kit"',
                  '2小时前',
                  Icons.create_new_folder,
                ),
                _buildRecentActivity(
                  context,
                  '安装了插件 "Animation Helper"',
                  '昨天',
                  Icons.extension,
                ),
                _buildRecentActivity(
                  context,
                  '更新了桌宠设置',
                  '3天前',
                  Icons.pets,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
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

  /// 构建最近活动项
  Widget _buildRecentActivity(
    BuildContext context,
    String title,
    String time,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示所有操作
  void _showAllActions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看全部功能开发中...')),
    );
  }

  /// 创建新项目
  void _createNewProject(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('新建项目功能开发中...')),
    );
  }

  /// 打开插件市场
  void _openPluginStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('插件市场功能开发中...')),
    );
  }

  /// 显示最近项目
  void _showRecentProjects(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('最近项目功能开发中...')),
    );
  }

  /// 打开设置
  void _openSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }
}
