/*
---------------------------------------------------------------
File name:          user_preferences_page.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        用户偏好设置页面 - 界面偏好、交互偏好、隐私设置
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_models.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// 用户偏好设置页面
/// 
/// 提供用户个性化配置选项：
/// - 界面偏好：字体大小、动画效果
/// - 交互偏好：手势、快捷键
/// - 隐私设置：数据收集、分析
/// - 备份设置：自动备份、云同步
class UserPreferencesPage extends ConsumerWidget {
  const UserPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('用户偏好'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 界面偏好
          SettingsSection(
            title: '界面偏好',
            children: [
              SettingsTile.selection<FontSize>(
                title: '字体大小',
                subtitle: _getFontSizeDisplayName(userPreferences.fontSize),
                leading: Icons.text_fields,
                value: userPreferences.fontSize,
                options: const [
                  SelectionOption(
                    value: FontSize.small,
                    title: '小',
                  ),
                  SelectionOption(
                    value: FontSize.medium,
                    title: '中',
                  ),
                  SelectionOption(
                    value: FontSize.large,
                    title: '大',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateFontSize(value);
                  }
                },
              ),
              SettingsTile(
                title: '动画效果',
                subtitle: '界面动画和过渡效果',
                leading: Icons.animation,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现动画设置
                  _showAnimationSettings(context);
                },
              ),
            ],
          ),

          // 交互偏好
          SettingsSection(
            title: '交互偏好',
            children: [
              SettingsTile(
                title: '手势设置',
                subtitle: '自定义手势操作',
                leading: Icons.gesture,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现手势设置
                  _showGestureSettings(context);
                },
              ),
              SettingsTile(
                title: '快捷键',
                subtitle: '自定义键盘快捷键',
                leading: Icons.keyboard,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现快捷键设置
                  _showShortcutSettings(context);
                },
              ),
            ],
          ),

          // 隐私设置
          SettingsSection(
            title: '隐私设置',
            children: [
              SettingsTile.switchTile(
                title: '数据收集',
                subtitle: '允许收集匿名使用数据以改进应用',
                leading: Icons.analytics,
                value: userPreferences.dataCollection,
                onChanged: (value) {
                  settingsNotifier.updateDataCollection(value);
                },
              ),
              SettingsTile(
                title: '隐私政策',
                subtitle: '查看隐私政策和数据使用说明',
                leading: Icons.privacy_tip,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 显示隐私政策
                  _showPrivacyPolicy(context);
                },
              ),
            ],
          ),

          // 备份设置
          SettingsSection(
            title: '备份设置',
            children: [
              SettingsTile.switchTile(
                title: '自动备份',
                subtitle: '定期自动备份应用数据',
                leading: Icons.backup,
                value: userPreferences.autoBackup,
                onChanged: (value) {
                  settingsNotifier.updateAutoBackup(value);
                },
              ),
              SettingsTile.switchTile(
                title: '云同步',
                subtitle: '将数据同步到云端',
                leading: Icons.cloud_sync,
                value: userPreferences.cloudSync,
                onChanged: (value) {
                  settingsNotifier.updateCloudSync(value);
                },
              ),
              SettingsTile(
                title: '备份管理',
                subtitle: '管理备份文件和恢复数据',
                leading: Icons.restore,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现备份管理
                  _showBackupManagement(context);
                },
              ),
            ],
          ),

          // 高级设置
          SettingsSection(
            title: '高级设置',
            children: [
              SettingsTile(
                title: '重置设置',
                subtitle: '将所有设置恢复为默认值',
                leading: Icons.restore_page,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 显示重置确认对话框
                  _showResetConfirmDialog(context, settingsNotifier);
                },
              ),
              SettingsTile(
                title: '导出设置',
                subtitle: '导出当前设置配置',
                leading: Icons.file_download,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现设置导出
                  _exportSettings(context, settingsNotifier);
                },
              ),
              SettingsTile(
                title: '导入设置',
                subtitle: '从文件导入设置配置',
                leading: Icons.file_upload,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现设置导入
                  _importSettings(context, settingsNotifier);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取字体大小显示名称
  String _getFontSizeDisplayName(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return '小';
      case FontSize.medium:
        return '中';
      case FontSize.large:
        return '大';
    }
  }

  /// 显示动画设置
  void _showAnimationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('动画效果'),
          content: const Text('动画设置功能正在开发中...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示手势设置
  void _showGestureSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('手势设置'),
          content: const Text('手势设置功能正在开发中...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示快捷键设置
  void _showShortcutSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('快捷键设置'),
          content: const Text('快捷键设置功能正在开发中...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示隐私政策
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('隐私政策'),
          content: const SingleChildScrollView(
            child: Text(
              '这里是隐私政策的内容...\n\n'
              '我们重视您的隐私，承诺保护您的个人信息安全。\n\n'
              '收集的数据仅用于改进应用体验，不会与第三方分享。',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示备份管理
  void _showBackupManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('备份管理'),
          content: const Text('备份管理功能正在开发中...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示重置确认对话框
  void _showResetConfirmDialog(BuildContext context, settingsNotifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重置设置'),
          content: const Text('确定要将所有设置恢复为默认值吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                settingsNotifier.resetToDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设置已重置为默认值')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 导出设置
  void _exportSettings(BuildContext context, settingsNotifier) {
    final settings = settingsNotifier.exportSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('设置已导出: ${settings.keys.length} 项配置'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 导入设置
  void _importSettings(BuildContext context, settingsNotifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('导入设置'),
          content: const Text('设置导入功能正在开发中...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
