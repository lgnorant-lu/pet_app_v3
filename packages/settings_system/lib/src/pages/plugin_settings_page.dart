/*
---------------------------------------------------------------
File name:          plugin_settings_page.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        插件设置页面 - 插件管理、权限设置、更新管理
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
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
        title: const Text('插件设置'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 插件管理
          SettingsSection(
            title: '插件管理',
            children: [
              SettingsTile(
                title: '已安装插件',
                subtitle: '管理已安装的插件',
                leading: Icons.extension,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 导航到插件列表页面
                  _showPluginListDialog(context);
                },
              ),
              SettingsTile(
                title: '插件权限',
                subtitle: '管理插件访问权限',
                leading: Icons.security,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 导航到权限管理页面
                  _showPermissionDialog(context);
                },
              ),
            ],
          ),

          // 更新管理
          SettingsSection(
            title: '更新管理',
            children: [
              SettingsTile.switchTile(
                title: '自动更新',
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

          // 插件商店设置
          SettingsSection(
            title: '插件商店',
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
              SettingsTile(
                title: '浏览插件商店',
                subtitle: '发现更多插件',
                leading: Icons.explore,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 打开插件商店
                  _openPluginStore(context, pluginSettings.storeUrl);
                },
              ),
            ],
          ),

          // 开发者选项
          SettingsSection(
            title: '开发者选项',
            children: [
              SettingsTile(
                title: '安装本地插件',
                subtitle: '从本地文件安装插件',
                leading: Icons.folder,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 实现本地插件安装
                  _showLocalPluginDialog(context);
                },
              ),
              SettingsTile(
                title: '插件开发工具',
                subtitle: '插件开发和调试工具',
                leading: Icons.developer_mode,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 打开开发工具
                  _showDeveloperToolsDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示插件列表对话框
  void _showPluginListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('已安装插件'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.extension),
                title: Text('示例插件 1'),
                subtitle: Text('v1.0.0'),
                trailing: Icon(Icons.toggle_on, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.extension),
                title: Text('示例插件 2'),
                subtitle: Text('v2.1.0'),
                trailing: Icon(Icons.toggle_off, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  /// 显示权限管理对话框
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('插件权限'),
          content: const Text('插件权限管理功能正在开发中...'),
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

  /// 打开插件商店
  void _openPluginStore(BuildContext context, String storeUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打开插件商店: $storeUrl'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示本地插件安装对话框
  void _showLocalPluginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('安装本地插件'),
          content: const Text('本地插件安装功能正在开发中...'),
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

  /// 显示开发者工具对话框
  void _showDeveloperToolsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('插件开发工具'),
          content: const Text('插件开发工具正在开发中...'),
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
