/*
---------------------------------------------------------------
File name:          status_overview_panel.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        状态概览面板组件 - Phase 5.0.7.2 状态概览系统
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.2 - 实现状态概览系统
    - 系统监控面板
    - 模块状态展示
    - 数据统计展示
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_status.dart';
import '../providers/status_overview_provider.dart';

/// 状态概览面板
class StatusOverviewPanel extends ConsumerWidget {
  const StatusOverviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusState = ref.watch(statusOverviewProvider);
    final systemHealth = ref.watch(systemHealthProvider);

    if (statusState.isLoading) {
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

    if (statusState.error != null) {
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
                '状态加载失败',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                statusState.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(statusOverviewProvider.notifier).refresh(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和整体状态
            _buildHeader(context, ref, systemHealth),

            const SizedBox(height: 16),

            // 系统性能指标
            _buildSystemMetrics(context, ref),

            const SizedBox(height: 16),

            // 模块状态概览
            _buildModuleOverview(context, ref),

            const SizedBox(height: 16),

            // 关键统计数据
            _buildKeyStatistics(context, ref),

            const SizedBox(height: 8),

            // 最后更新时间
            _buildLastUpdated(context, statusState.lastUpdated),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(
      BuildContext context, WidgetRef ref, SystemHealth systemHealth) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.dashboard,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '系统状态概览',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: systemHealth.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: systemHealth.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                systemHealth.icon,
                size: 14,
                color: systemHealth.color,
              ),
              const SizedBox(width: 4),
              Text(
                systemHealth.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: systemHealth.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => ref.read(statusOverviewProvider.notifier).refresh(),
          tooltip: '刷新状态',
        ),
      ],
    );
  }

  /// 构建系统指标
  Widget _buildSystemMetrics(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = ref.watch(systemMetricsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '系统性能',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'CPU',
                '${metrics.cpuUsage.toStringAsFixed(1)}%',
                metrics.cpuUsage / 100,
                _getUsageColor(metrics.cpuUsage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricItem(
                context,
                '内存',
                '${metrics.memoryUsage.toStringAsFixed(1)}%',
                metrics.memoryUsage / 100,
                _getUsageColor(metrics.memoryUsage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricItem(
                context,
                '磁盘',
                '${metrics.diskUsage.toStringAsFixed(1)}%',
                metrics.diskUsage / 100,
                _getUsageColor(metrics.diskUsage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricItem(
                context,
                '延迟',
                '${metrics.networkLatency}ms',
                metrics.networkLatency / 500, // 假设500ms为最大值
                _getLatencyColor(metrics.networkLatency),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建指标项
  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    double progress,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  /// 构建模块概览
  Widget _buildModuleOverview(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final moduleStatuses = ref.watch(moduleStatusesProvider);
    final healthyCount = ref.watch(healthyModulesCountProvider);
    final problematicCount = ref.watch(problematicModulesCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '模块状态',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '健康: $healthyCount  问题: $problematicCount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moduleStatuses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final module = moduleStatuses[index];
              return _buildModuleStatusChip(context, module);
            },
          ),
        ),
      ],
    );
  }

  /// 构建模块状态芯片
  Widget _buildModuleStatusChip(
      BuildContext context, ModuleStatusDetail module) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: module.health.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: module.health.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                module.health.icon,
                size: 14,
                color: module.health.color,
              ),
              const SizedBox(width: 4),
              Text(
                module.moduleName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            module.formattedUptime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建关键统计
  Widget _buildKeyStatistics(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statistics = ref.watch(statisticsProvider);
    final keyStats = statistics.take(3).toList(); // 只显示前3个关键统计

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关键指标',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: keyStats
              .map((stat) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: keyStats.indexOf(stat) < keyStats.length - 1
                            ? 12
                            : 0,
                      ),
                      child: _buildStatisticCard(context, stat),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticCard(BuildContext context, StatisticItem statistic) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statistic.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statistic.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statistic.icon,
                size: 16,
                color: statistic.color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statistic.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statistic.formattedValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: statistic.color,
            ),
          ),
          if (statistic.formattedChangePercent != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  statistic.trend.icon,
                  size: 12,
                  color: statistic.trend.color,
                ),
                const SizedBox(width: 2),
                Text(
                  statistic.formattedChangePercent!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statistic.trend.color,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建最后更新时间
  Widget _buildLastUpdated(BuildContext context, DateTime? lastUpdated) {
    final theme = Theme.of(context);

    if (lastUpdated == null) return const SizedBox.shrink();

    final timeAgo = _formatTimeAgo(lastUpdated);

    return Row(
      children: [
        Icon(
          Icons.update,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        Text(
          '最后更新: $timeAgo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 获取使用率颜色
  Color _getUsageColor(double usage) {
    if (usage <= 50) return Colors.green;
    if (usage <= 75) return Colors.orange;
    return Colors.red;
  }

  /// 获取延迟颜色
  Color _getLatencyColor(int latency) {
    if (latency <= 100) return Colors.green;
    if (latency <= 300) return Colors.orange;
    return Colors.red;
  }

  /// 格式化时间差
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '${difference.inHours}小时前';
    }
  }
}
