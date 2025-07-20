/*
---------------------------------------------------------------
File name:          user_preferences_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        用户偏好设置页面 - 界面偏好、交互偏好、隐私设置
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_strings.dart';
import '../../../../core/models/settings_models.dart';
import '../../../../core/providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// 用户偏好设置页面
///
/// 提供用户个性化配置选项：
/// - 界面偏好：布局、字体大小
/// - 交互偏好：快捷键、手势
/// - 隐私设置：数据收集、分析统计
/// - 备份设置：自动备份、云同步
class UserPreferencesPage extends ConsumerWidget {
  const UserPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsUser), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 界面偏好
          SettingsSection(
            title: AppStrings.settingsInterface,
            children: [
              SettingsTile.selection<FontSize>(
                title: AppStrings.settingsFontSize,
                subtitle: _getFontSizeDisplayName(userPreferences.fontSize),
                leading: Icons.text_fields,
                value: userPreferences.fontSize,
                options: const [
                  SelectionOption(
                    value: FontSize.small,
                    title: AppStrings.settingsFontSizeSmall,
                  ),
                  SelectionOption(
                    value: FontSize.medium,
                    title: AppStrings.settingsFontSizeMedium,
                  ),
                  SelectionOption(
                    value: FontSize.large,
                    title: AppStrings.settingsFontSizeLarge,
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateFontSize(value);
                  }
                },
              ),
              SettingsTile.textField(
                title: AppStrings.settingsLayout,
                subtitle: '界面布局样式',
                leading: Icons.dashboard,
                value: userPreferences.layout,
                hintText: '输入布局名称',
                onChanged: (value) {
                  // 更新布局设置
                  final newPreferences = userPreferences.copyWith(
                    layout: value,
                  );
                  settingsNotifier.updateUserPreferences(newPreferences);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 交互偏好
          SettingsSection(
            title: AppStrings.settingsInteraction,
            children: [
              SettingsTile.switchTile(
                title: AppStrings.settingsGestures,
                subtitle: '启用手势操作',
                leading: Icons.gesture,
                value: userPreferences.gesturesEnabled,
                onChanged: (value) {
                  settingsNotifier.updateGesturesEnabled(value);
                },
              ),
              SettingsTile(
                title: AppStrings.settingsShortcuts,
                subtitle: '自定义快捷键',
                leading: Icons.keyboard,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showShortcutsSettings(
                  context,
                  userPreferences,
                  settingsNotifier,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 隐私设置
          SettingsSection(
            title: AppStrings.settingsPrivacy,
            children: [
              SettingsTile.switchTile(
                title: AppStrings.settingsDataCollection,
                subtitle: '允许收集使用数据以改进应用',
                leading: Icons.data_usage,
                value: userPreferences.dataCollection,
                onChanged: (value) {
                  settingsNotifier.updateDataCollection(value);
                },
              ),
              SettingsTile.switchTile(
                title: AppStrings.settingsAnalytics,
                subtitle: '允许发送分析统计数据',
                leading: Icons.analytics,
                value: userPreferences.analytics,
                onChanged: (value) {
                  // 更新分析统计设置
                  final newPreferences = userPreferences.copyWith(
                    analytics: value,
                  );
                  settingsNotifier.updateUserPreferences(newPreferences);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 备份设置
          SettingsSection(
            title: AppStrings.settingsBackup,
            children: [
              SettingsTile.switchTile(
                title: AppStrings.settingsAutoBackup,
                subtitle: '自动备份应用数据',
                leading: Icons.backup,
                value: userPreferences.autoBackup,
                onChanged: (value) {
                  settingsNotifier.updateAutoBackup(value);
                },
              ),
              SettingsTile.switchTile(
                title: AppStrings.settingsCloudSync,
                subtitle: '同步数据到云端',
                leading: Icons.cloud_sync,
                value: userPreferences.cloudSync,
                onChanged: (value) {
                  settingsNotifier.updateCloudSync(value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 重置设置
          SettingsSection(
            title: '重置设置',
            children: [
              SettingsTile(
                title: '重置为默认设置',
                subtitle: '将所有设置恢复为默认值',
                leading: Icons.restore,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showResetConfirmation(context, settingsNotifier),
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
        return AppStrings.settingsFontSizeSmall;
      case FontSize.medium:
        return AppStrings.settingsFontSizeMedium;
      case FontSize.large:
        return AppStrings.settingsFontSizeLarge;
    }
  }

  /// 显示快捷键设置
  void _showShortcutsSettings(
    BuildContext context,
    UserPreferences userPreferences,
    dynamic settingsNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.settingsShortcuts),
        content: SizedBox(
          width: double.maxFinite,
          child: userPreferences.shortcuts.isEmpty
              ? const Text('暂无自定义快捷键')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: userPreferences.shortcuts.length,
                  itemBuilder: (context, index) {
                    final entry = userPreferences.shortcuts.entries.elementAt(
                      index,
                    );
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: 实现快捷键编辑功能
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetConfirmation(BuildContext context, dynamic settingsNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              settingsNotifier.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置已重置为默认值')));
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
