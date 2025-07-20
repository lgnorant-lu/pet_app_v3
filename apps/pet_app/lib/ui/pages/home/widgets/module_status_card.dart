/*
---------------------------------------------------------------
File name:          module_status_card.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        模块状态卡片组件 - 显示各模块运行状态
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 模块状态卡片
class ModuleStatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String status;
  final Color statusColor;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const ModuleStatusCard({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.statusColor,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：图标和状态
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 标题
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // 副标题
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // 底部操作指示
              if (onTap != null && !isLoading)
                Row(
                  children: [
                    Text(
                      '点击查看',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 模块状态枚举
enum ModuleStatus {
  active('活跃', Colors.green),
  normal('正常', Colors.blue),
  warning('警告', Colors.orange),
  error('错误', Colors.red),
  inactive('未激活', Colors.grey);

  const ModuleStatus(this.label, this.color);

  final String label;
  final Color color;
}

/// 模块信息数据类
class ModuleInfo {
  final String id;
  final String title;
  final IconData icon;
  final ModuleStatus status;
  final String subtitle;
  final Map<String, dynamic>? metadata;

  const ModuleInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.status,
    required this.subtitle,
    this.metadata,
  });

  /// 从JSON创建
  factory ModuleInfo.fromJson(Map<String, dynamic> json) {
    return ModuleInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: _iconFromString(json['icon']),
      status: _statusFromString(json['status']),
      subtitle: json['subtitle'] ?? '',
      metadata: json['metadata'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': _iconToString(icon),
      'status': status.name,
      'subtitle': subtitle,
      'metadata': metadata,
    };
  }

  /// 从字符串获取图标
  static IconData _iconFromString(String? iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'apps':
        return Icons.apps;
      case 'pets':
        return Icons.pets;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.extension;
    }
  }

  /// 图标转换为字符串
  static String _iconToString(IconData icon) {
    if (icon == Icons.build) return 'build';
    if (icon == Icons.apps) return 'apps';
    if (icon == Icons.pets) return 'pets';
    if (icon == Icons.settings) return 'settings';
    return 'extension';
  }

  /// 从字符串获取状态
  static ModuleStatus _statusFromString(String? statusName) {
    switch (statusName) {
      case 'active':
        return ModuleStatus.active;
      case 'normal':
        return ModuleStatus.normal;
      case 'warning':
        return ModuleStatus.warning;
      case 'error':
        return ModuleStatus.error;
      case 'inactive':
        return ModuleStatus.inactive;
      default:
        return ModuleStatus.normal;
    }
  }
}
