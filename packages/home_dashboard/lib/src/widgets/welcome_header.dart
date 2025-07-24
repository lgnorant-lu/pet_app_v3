/*
---------------------------------------------------------------
File name:          welcome_header.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        欢迎头部组件 - 首页仪表板顶部展示 (迁移到模块)
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 欢迎头部组件
class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 应用标题和版本
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 32,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet App V3',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'v5.0.0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 通知图标
                  IconButton(
                    onPressed: () => _showNotifications(context),
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 欢迎信息
              Text(
                _getWelcomeMessage(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '万物皆插件的跨平台应用框架',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 16),

              // 快速状态指示器
              Row(
                children: [
                  _buildStatusIndicator(
                    context,
                    '插件系统',
                    Icons.extension,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatusIndicator(
                    context,
                    '创意工坊',
                    Icons.build,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatusIndicator(
                    context,
                    '桌宠系统',
                    Icons.pets,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            icon,
            size: 16,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取欢迎消息
  String _getWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '夜深了，注意休息 🌙';
    } else if (hour < 12) {
      return '早上好！☀️';
    } else if (hour < 18) {
      return '下午好！🌤️';
    } else {
      return '晚上好！🌆';
    }
  }

  /// 显示通知
  void _showNotifications(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知中心'),
        content: const Text('暂无新通知'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
