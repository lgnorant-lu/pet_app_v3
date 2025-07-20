/*
---------------------------------------------------------------
File name:          settings_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置页面主入口 - Phase 4.2 设置系统核心
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_strings.dart';
import 'pages/app_settings_page.dart';
import 'pages/plugin_settings_page.dart';
import 'pages/user_preferences_page.dart';

/// 设置页面主入口
/// 
/// 提供三大设置分类的导航入口：
/// - 应用设置：主题、语言、启动、性能
/// - 插件设置：插件管理、权限、更新
/// - 用户偏好：界面、交互、隐私、备份
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            context,
            title: AppStrings.settingsApp,
            subtitle: '主题、语言、启动、性能配置',
            icon: Icons.settings,
            onTap: () => _navigateToAppSettings(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: AppStrings.settingsPlugins,
            subtitle: '插件管理、权限设置、更新管理',
            icon: Icons.extension,
            onTap: () => _navigateToPluginSettings(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: AppStrings.settingsUser,
            subtitle: '界面偏好、交互偏好、隐私设置',
            icon: Icons.person,
            onTap: () => _navigateToUserPreferences(context),
          ),
        ],
      ),
    );
  }

  /// 构建设置分类卡片
  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  /// 导航到应用设置页面
  void _navigateToAppSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AppSettingsPage(),
      ),
    );
  }

  /// 导航到插件设置页面
  void _navigateToPluginSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PluginSettingsPage(),
      ),
    );
  }

  /// 导航到用户偏好页面
  void _navigateToUserPreferences(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserPreferencesPage(),
      ),
    );
  }
}
