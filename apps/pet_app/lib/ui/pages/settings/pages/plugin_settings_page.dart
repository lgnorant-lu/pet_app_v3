/*
---------------------------------------------------------------
File name:          plugin_settings_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        插件设置页面 - 插件管理、权限设置、更新管理
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_strings.dart';
import '../../../../core/providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// 插件设置页面
/// 
/// 提供插件相关的配置选项：
/// - 插件列表管理：启用/禁用插件
/// - 权限设置：插件权限管理
/// - 更新管理：自动更新、Beta插件
/// - 插件商店：商店URL配置
class PluginSettingsPage extends ConsumerWidget {
  const PluginSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pluginSettings = ref.watch(pluginSettingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsPlugins),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 插件列表管理
          SettingsSection(
            title: AppStrings.settingsPluginsList,
            children: [
              // 已启用插件数量显示
              SettingsTile(
                title: AppStrings.settingsPluginsEnabled,
                subtitle: '${pluginSettings.enabledPlugins.length} 个插件',
                leading: Icons.check_circle,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPluginList(
                  context,
                  AppStrings.settingsPluginsEnabled,
                  pluginSettings.enabledPlugins,
                  true,
                  settingsNotifier,
                ),
              ),
              
              // 已禁用插件数量显示
              SettingsTile(
                title: AppStrings.settingsPluginsDisabled,
                subtitle: '${pluginSettings.disabledPlugins.length} 个插件',
                leading: Icons.cancel,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPluginList(
                  context,
                  AppStrings.settingsPluginsDisabled,
                  pluginSettings.disabledPlugins,
                  false,
                  settingsNotifier,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 插件权限设置
          SettingsSection(
            title: AppStrings.settingsPluginsPermissions,
            children: [
              SettingsTile(
                title: AppStrings.settingsPluginsPermissions,
                subtitle: '管理插件权限',
                leading: Icons.security,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPermissionSettings(context, pluginSettings, settingsNotifier),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 更新管理
          SettingsSection(
            title: AppStrings.settingsPluginsUpdates,
            children: [
              SettingsTile.switchTile(
                title: AppStrings.settingsPluginsAutoUpdate,
                subtitle: '自动检查和安装插件更新',
                leading: Icons.update,
                value: pluginSettings.autoUpdate,
                onChanged: (value) {
                  // 更新自动更新设置
                  final newSettings = pluginSettings.copyWith(autoUpdate: value);
                  settingsNotifier.updatePluginSettings(newSettings);
                },
              ),
              SettingsTile.switchTile(
                title: '允许Beta插件',
                subtitle: '允许安装和更新Beta版本插件',
                leading: Icons.science,
                value: pluginSettings.allowBetaPlugins,
                onChanged: (value) {
                  // 更新Beta插件设置
                  final newSettings = pluginSettings.copyWith(allowBetaPlugins: value);
                  settingsNotifier.updatePluginSettings(newSettings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 插件商店设置
          SettingsSection(
            title: AppStrings.settingsPluginsStore,
            children: [
              SettingsTile.textField(
                title: '商店URL',
                subtitle: '插件商店的地址',
                leading: Icons.store,
                value: pluginSettings.storeUrl,
                hintText: '输入插件商店URL',
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  // 更新商店URL
                  final newSettings = pluginSettings.copyWith(storeUrl: value);
                  settingsNotifier.updatePluginSettings(newSettings);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示插件列表
  void _showPluginList(
    BuildContext context,
    String title,
    List<String> plugins,
    bool isEnabled,
    dynamic settingsNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: plugins.isEmpty
              ? const Text('暂无插件')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: plugins.length,
                  itemBuilder: (context, index) {
                    final pluginId = plugins[index];
                    return ListTile(
                      title: Text(pluginId),
                      trailing: IconButton(
                        icon: Icon(isEnabled ? Icons.toggle_on : Icons.toggle_off),
                        onPressed: () {
                          if (isEnabled) {
                            settingsNotifier.disablePlugin(pluginId);
                          } else {
                            settingsNotifier.enablePlugin(pluginId);
                          }
                          Navigator.of(context).pop();
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

  /// 显示权限设置
  void _showPermissionSettings(
    BuildContext context,
    dynamic pluginSettings,
    dynamic settingsNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.settingsPluginsPermissions),
        content: SizedBox(
          width: double.maxFinite,
          child: pluginSettings.permissions.isEmpty
              ? const Text('暂无权限设置')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: pluginSettings.permissions.length,
                  itemBuilder: (context, index) {
                    final entry = pluginSettings.permissions.entries.elementAt(index);
                    return SwitchListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (value) {
                        settingsNotifier.updatePluginPermission(entry.key, value);
                      },
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
}
