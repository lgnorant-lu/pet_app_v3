/*
---------------------------------------------------------------
File name:          permission_dialog.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件权限授权对话框 - 用户授权流程UI
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 插件权限授权对话框实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'plugin_manager.dart';

/// 权限授权对话框
class PermissionDialog extends StatefulWidget {
  const PermissionDialog({
    super.key,
    required this.pluginId,
    required this.pluginName,
    required this.permission,
    this.reason,
    this.isDangerous = false,
  });

  /// 插件ID
  final String pluginId;
  
  /// 插件名称
  final String pluginName;
  
  /// 请求的权限
  final PluginPermission permission;
  
  /// 请求原因
  final String? reason;
  
  /// 是否为危险权限
  final bool isDangerous;

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();

  /// 显示权限授权对话框
  static Future<bool?> show(
    BuildContext context, {
    required String pluginId,
    required String pluginName,
    required PluginPermission permission,
    String? reason,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        pluginId: pluginId,
        pluginName: pluginName,
        permission: permission,
        reason: reason,
        isDangerous: isDangerous,
      ),
    );
  }
}

class _PermissionDialogState extends State<PermissionDialog> {
  bool _rememberChoice = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        _getPermissionIcon(widget.permission),
        size: 48,
        color: widget.isDangerous ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        '权限请求',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: widget.isDangerous ? colorScheme.error : null,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 插件信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.extension,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.pluginName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 权限说明
          Text(
            '该插件请求以下权限：',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDangerous 
                  ? colorScheme.errorContainer.withOpacity(0.3)
                  : colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isDangerous 
                    ? colorScheme.error.withOpacity(0.5)
                    : colorScheme.primary.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getPermissionIcon(widget.permission),
                  size: 24,
                  color: widget.isDangerous ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.permission.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.isDangerous ? colorScheme.error : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPermissionDescription(widget.permission),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 请求原因
          if (widget.reason != null) ...[
            const SizedBox(height: 16),
            Text(
              '请求原因：',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.reason!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          
          // 危险权限警告
          if (widget.isDangerous) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '此权限可能存在安全风险，请谨慎授权。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 记住选择选项
          CheckboxListTile(
            value: _rememberChoice,
            onChanged: (value) {
              setState(() {
                _rememberChoice = value ?? false;
              });
            },
            title: Text(
              '记住我的选择',
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              '下次不再询问此权限',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        // 拒绝按钮
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '拒绝',
            style: TextStyle(
              color: colorScheme.error,
            ),
          ),
        ),
        
        // 允许按钮
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: widget.isDangerous 
                ? colorScheme.error 
                : colorScheme.primary,
          ),
          child: Text(
            '允许',
            style: TextStyle(
              color: widget.isDangerous 
                  ? colorScheme.onError 
                  : colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
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

  /// 获取权限描述
  String _getPermissionDescription(PluginPermission permission) {
    switch (permission) {
      case PluginPermission.fileSystem:
        return '读取和写入设备上的文件';
      case PluginPermission.network:
        return '访问互联网和发送网络请求';
      case PluginPermission.notifications:
        return '发送系统通知消息';
      case PluginPermission.clipboard:
        return '读取和修改剪贴板内容';
      case PluginPermission.camera:
        return '使用设备摄像头拍照和录像';
      case PluginPermission.microphone:
        return '使用设备麦克风录音';
      case PluginPermission.location:
        return '获取设备的地理位置信息';
      case PluginPermission.deviceInfo:
        return '获取设备硬件和系统信息';
    }
  }
}
