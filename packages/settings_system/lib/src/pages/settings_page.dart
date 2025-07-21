/*
---------------------------------------------------------------
File name:          settings_page.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        设置页面主入口 - Settings System 模块核心
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_settings_page.dart';
import 'plugin_settings_page.dart';
import 'user_preferences_page.dart';

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
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            context,
            title: '应用设置',
            subtitle: '主题、语言、启动、性能配置',
            icon: Icons.settings,
            onTap: () => _navigateToAppSettings(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: '插件设置',
            subtitle: '插件管理、权限设置、更新管理',
            icon: Icons.extension,
            onTap: () => _navigateToPluginSettings(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: '用户偏好',
            subtitle: '界面偏好、交互偏好、隐私设置',
            icon: Icons.person,
            onTap: () => _navigateToUserPreferences(context),
          ),
        ],
      ),
    );
  }

  /// 构建设置分组卡片
  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
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
