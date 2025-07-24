/*
---------------------------------------------------------------
File name:          quick_access_panel.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        快速访问面板组件 - 智能快捷入口聚合系统 (Phase 5.0.7.1)
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.1 - 实现智能快捷入口聚合系统
    - 动态快捷方式配置
    - 个性化推荐算法
    - 工作流集成
    - 权限控制
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quick_action.dart';
import '../providers/quick_access_provider.dart';
import '../utils/animation_utils.dart';
import '../utils/responsive_utils.dart';

/// 快速访问面板 - 智能快捷入口聚合系统
class QuickAccessPanel extends ConsumerWidget {
  const QuickAccessPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quickAccessState = ref.watch(quickAccessProvider);
    final recommendedActions = ref.watch(recommendedActionsProvider);
    final pinnedActions = ref.watch(pinnedActionsProvider);
    final workflows = ref.watch(workflowsProvider);

    if (quickAccessState.isLoading) {
      return const Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (quickAccessState.error != null) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                '加载失败',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                quickAccessState.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(quickAccessProvider.notifier).refresh(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题和操作
              _buildHeader(context, ref),

              const SizedBox(height: 16),

              // 置顶操作（如果有）
              if (pinnedActions.isNotEmpty) ...[
                _buildSectionTitle(context, '置顶操作', Icons.push_pin),
                const SizedBox(height: 8),
                _buildActionGrid(context, ref, pinnedActions.take(4).toList()),
                const SizedBox(height: 16),
              ],

              // 推荐操作
              _buildSectionTitle(context, '推荐操作', Icons.recommend),
              const SizedBox(height: 8),
              _buildActionGrid(
                  context, ref, recommendedActions.take(6).toList()),

              const SizedBox(height: 16),

              // 工作流（如果有）
              if (workflows.isNotEmpty) ...[
                _buildSectionTitle(context, '快速工作流', Icons.alt_route),
                const SizedBox(height: 8),
                _buildWorkflowList(context, ref, workflows.take(2).toList()),
                const SizedBox(height: 16),
              ],

              // 最近活动
              _buildRecentActivity(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.flash_on,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '智能快捷入口',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'customize',
              child: Row(
                children: [
                  Icon(Icons.tune, size: 16),
                  SizedBox(width: 8),
                  Text('自定义'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 16),
                  SizedBox(width: 8),
                  Text('刷新'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_all',
              child: Row(
                children: [
                  Icon(Icons.view_list, size: 16),
                  SizedBox(width: 8),
                  Text('查看全部'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建分节标题
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建操作网格
  Widget _buildActionGrid(
      BuildContext context, WidgetRef ref, List<QuickAction> actions) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context),
        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context),
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return AnimationUtils.listItemAnimation(
          index: index,
          child: _buildActionCard(context, ref, action),
        );
      },
    );
  }

  /// 构建操作卡片
  Widget _buildActionCard(
      BuildContext context, WidgetRef ref, QuickAction action) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _executeAction(context, ref, action),
      onLongPress: () => _showActionMenu(context, ref, action),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.color.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            // 主要内容
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: action.color,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 置顶标识
            if (action.priority == QuickActionPriority.pinned)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.push_pin,
                  size: 12,
                  color: action.color,
                ),
              ),

            // 使用次数标识
            if (action.usageCount > 0)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${action.usageCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: action.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建工作流列表
  Widget _buildWorkflowList(
      BuildContext context, WidgetRef ref, List<Workflow> workflows) {
    return Column(
      children: workflows
          .map((workflow) => _buildWorkflowCard(context, ref, workflow))
          .toList(),
    );
  }

  /// 构建工作流卡片
  Widget _buildWorkflowCard(
      BuildContext context, WidgetRef ref, Workflow workflow) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _executeWorkflow(context, ref, workflow),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: workflow.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: workflow.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                workflow.icon,
                color: workflow.color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workflow.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workflow.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (workflow.usageCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: workflow.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${workflow.usageCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: workflow.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_arrow,
                color: workflow.color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建最近活动
  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentActions = ref.watch(recentActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '最近活动', Icons.access_time),
        const SizedBox(height: 8),
        if (recentActions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '暂无最近活动',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          Column(
            children: recentActions
                .take(3)
                .map((action) => _buildRecentActivityItem(context, action))
                .toList(),
          ),
      ],
    );
  }

  /// 构建最近活动项
  Widget _buildRecentActivityItem(BuildContext context, QuickAction action) {
    final theme = Theme.of(context);
    final timeAgo =
        action.lastUsed != null ? _formatTimeAgo(action.lastUsed!) : '未知时间';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              action.icon,
              size: 14,
              color: action.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '使用了 "${action.title}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  /// 处理菜单操作
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'customize':
        _showCustomizeDialog(context, ref);
        break;
      case 'refresh':
        ref.read(quickAccessProvider.notifier).refresh();
        break;
      case 'view_all':
        _showAllActionsDialog(context, ref);
        break;
    }
  }

  /// 执行快速操作
  void _executeAction(BuildContext context, WidgetRef ref, QuickAction action) {
    // 更新使用统计
    ref.read(quickAccessProvider.notifier).executeAction(action);

    // 执行操作
    if (action.target != null) {
      Navigator.of(context).pushNamed(action.target!);
    } else if (action.onTap != null) {
      action.onTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${action.title} 功能开发中...')),
      );
    }
  }

  /// 执行工作流
  void _executeWorkflow(
      BuildContext context, WidgetRef ref, Workflow workflow) {
    ref.read(quickAccessProvider.notifier).executeWorkflow(workflow);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在执行工作流: ${workflow.name}'),
        action: SnackBarAction(
          label: '查看详情',
          onPressed: () => _showWorkflowDetails(context, workflow),
        ),
      ),
    );
  }

  /// 显示操作菜单
  void _showActionMenu(
      BuildContext context, WidgetRef ref, QuickAction action) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(action.icon, color: action.color),
              title: Text(action.title),
              subtitle: Text(action.description),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.launch),
              title: const Text('执行'),
              onTap: () {
                Navigator.pop(context);
                _executeAction(context, ref, action);
              },
            ),
            ListTile(
              leading: Icon(
                action.priority == QuickActionPriority.pinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin,
              ),
              title: Text(
                action.priority == QuickActionPriority.pinned ? '取消置顶' : '置顶',
              ),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(quickAccessProvider.notifier)
                    .toggleActionPin(action.id);
              },
            ),
            if (action.type == QuickActionType.custom)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(quickAccessProvider.notifier)
                      .removeAction(action.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 格式化时间差
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${(difference.inDays / 7).floor()}周前';
    }
  }

  /// 显示自定义对话框
  void _showCustomizeDialog(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义功能开发中...')),
    );
  }

  /// 显示所有操作对话框
  void _showAllActionsDialog(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看全部功能开发中...')),
    );
  }

  /// 显示工作流详情
  void _showWorkflowDetails(BuildContext context, Workflow workflow) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('工作流详情: ${workflow.name}')),
    );
  }
}
