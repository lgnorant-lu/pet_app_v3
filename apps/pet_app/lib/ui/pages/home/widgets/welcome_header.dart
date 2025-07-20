/*
---------------------------------------------------------------
File name:          welcome_header.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        欢迎头部组件 - 首页仪表板顶部展示
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_app_v3/constants/app_strings.dart';

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
                          AppStrings.appName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'v${AppStrings.appVersion}',
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
                AppStrings.appDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 状态指示器
              _buildStatusIndicators(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicators(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatusChip(
          context,
          icon: Icons.check_circle,
          label: '系统正常',
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatusChip(
          context,
          icon: Icons.update,
          label: '已是最新',
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatusChip(
          context,
          icon: Icons.security,
          label: '安全',
          color: Colors.orange,
        ),
      ],
    );
  }

  /// 构建状态芯片
  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取欢迎信息
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知'),
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
