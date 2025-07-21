/*
---------------------------------------------------------------
File name:          user_overview_widget.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        用户概览组件 - 显示用户数据和成就 (迁移到模块)
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_dashboard/src/providers/home_provider.dart';

/// 成就数据类
class _AchievementData {
  final String name;
  final String icon;
  final Color color;

  const _AchievementData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 用户概览组件
class UserOverviewWidget extends ConsumerWidget {
  const UserOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userStats = ref.watch(userStatsProvider);
    final recentProjects = ref.watch(recentProjectsProvider);
    final achievements = ref.watch(achievementsProvider);

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
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '用户概览',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDetailedStats(context),
                  child: const Text('详细统计'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 统计数据网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard(
                  context,
                  '使用时长',
                  '${userStats['usageHours'] ?? 0}小时',
                  Icons.access_time,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  '项目数量',
                  '${userStats['projectCount'] ?? 0}个',
                  Icons.folder,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  '插件数量',
                  '${userStats['pluginCount'] ?? 0}个',
                  Icons.extension,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  '成就数量',
                  '${userStats['achievementCount'] ?? 0}个',
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 最近项目
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '最近项目',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 最近项目列表
            if (recentProjects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '暂无最近项目',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: recentProjects.take(3).map((project) {
                  return _buildProjectItem(context, project);
                }).toList(),
              ),

            const SizedBox(height: 20),

            // 成就展示
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '最新成就',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 成就列表
            if (achievements.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '暂无成就',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: achievements.take(3).map((achievement) {
                  return _buildAchievementChip(context, achievement);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建项目项
  Widget _buildProjectItem(BuildContext context, String projectName) {
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
              Icons.folder_outlined,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              projectName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  /// 构建成就芯片
  Widget _buildAchievementChip(BuildContext context, String achievement) {
    final theme = Theme.of(context);
    final achievementData = _getAchievementData(achievement);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: achievementData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievementData.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievementData.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            achievementData.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: achievementData.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取成就数据
  _AchievementData _getAchievementData(String achievementId) {
    switch (achievementId) {
      case 'first_launch':
        return const _AchievementData(
          name: '首次启动',
          icon: '🚀',
          color: Colors.blue,
        );
      case 'first_project':
        return const _AchievementData(
          name: '首个项目',
          icon: '📁',
          color: Colors.green,
        );
      case 'settings_complete':
        return const _AchievementData(
          name: '设置完成',
          icon: '⚙️',
          color: Colors.orange,
        );
      default:
        return const _AchievementData(
          name: '未知成就',
          icon: '🏆',
          color: Colors.grey,
        );
    }
  }

  /// 显示详细统计
  void _showDetailedStats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('详细统计功能开发中...')),
    );
  }
}
