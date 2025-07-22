/*
---------------------------------------------------------------
File name:          plugin_card.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件卡片组件
---------------------------------------------------------------
Change History:
    2025-07-22: Initial creation - 插件卡片组件;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/ui/store/app_store_page.dart';

/// 插件卡片组件
class PluginCard extends StatelessWidget {
  const PluginCard({
    super.key,
    required this.plugin,
    this.onInstall,
    this.onUninstall,
    this.onTap,
  });

  /// 插件信息
  final PluginInfo plugin;

  /// 安装回调
  final Future<void> Function(PluginInfo plugin)? onInstall;

  /// 卸载回调
  final Future<void> Function(PluginInfo plugin)? onUninstall;

  /// 点击回调
  final void Function(PluginInfo plugin)? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onTap?.call(plugin),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 插件图标和基本信息
              Row(
                children: [
                  // 插件图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(plugin.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(plugin.category),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 插件名称和作者
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plugin.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 插件描述
              Text(
                plugin.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 评分和下载量
              Row(
                children: [
                  // 评分
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plugin.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // 下载量
                  Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDownloadCount(plugin.downloadCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 价格
                  if (plugin.price > 0)
                    Text(
                      '¥${plugin.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    )
                  else
                    Text(
                      '免费',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 操作按钮
              SizedBox(
                width: double.infinity,
                child: plugin.isInstalled
                    ? OutlinedButton(
                        onPressed: () => onUninstall?.call(plugin),
                        child: const Text('卸载'),
                      )
                    : ElevatedButton(
                        onPressed: () => onInstall?.call(plugin),
                        child: const Text('安装'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取分类颜色
  Color _getCategoryColor(StorePluginCategory category) {
    switch (category) {
      case StorePluginCategory.tool:
        return Colors.blue;
      case StorePluginCategory.game:
        return Colors.purple;
      case StorePluginCategory.utility:
        return Colors.green;
      case StorePluginCategory.theme:
        return Colors.orange;
      case StorePluginCategory.other:
        return Colors.grey;
    }
  }

  /// 获取分类图标
  IconData _getCategoryIcon(StorePluginCategory category) {
    switch (category) {
      case StorePluginCategory.tool:
        return Icons.build;
      case StorePluginCategory.game:
        return Icons.games;
      case StorePluginCategory.utility:
        return Icons.widgets;
      case StorePluginCategory.theme:
        return Icons.palette;
      case StorePluginCategory.other:
        return Icons.extension;
    }
  }

  /// 格式化下载量
  String _formatDownloadCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}

/// 应用商店插件分类枚举
enum StorePluginCategory {
  tool('工具'),
  game('游戏'),
  utility('实用程序'),
  theme('主题'),
  other('其他');

  const StorePluginCategory(this.displayName);

  final String displayName;
}
