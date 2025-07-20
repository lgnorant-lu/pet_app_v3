/*
---------------------------------------------------------------
File name:          settings_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        主设置页面 - 设置系统入口页面
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_app_v3/constants/app_strings.dart';
import 'package:pet_app_v3/ui/pages/settings/pages/app_settings_page.dart';
import 'package:pet_app_v3/ui/pages/settings/pages/plugin_settings_page.dart';
import 'package:pet_app_v3/ui/pages/settings/pages/user_preferences_page.dart';
import 'package:pet_app_v3/ui/pages/settings/widgets/settings_section.dart';
import 'package:pet_app_v3/ui/pages/settings/widgets/settings_tile.dart';

/// 主设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SettingsSection(
            title: AppStrings.settingsGeneral,
            children: [
              SettingsTile(
                title: AppStrings.settingsApp,
                subtitle: AppStrings.settingsAppDescription,
                leading: Icons.app_settings_alt,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppSettingsPage(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: AppStrings.settingsPlugins,
                subtitle: AppStrings.settingsPluginsDescription,
                leading: Icons.extension,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PluginSettingsPage(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: AppStrings.settingsUser,
                subtitle: AppStrings.settingsUserDescription,
                leading: Icons.person,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserPreferencesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: AppStrings.settingsAbout,
            children: [
              SettingsTile(
                title: AppStrings.settingsVersion,
                subtitle: '1.0.0',
                leading: Icons.info_outline,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              SettingsTile(
                title: AppStrings.settingsHelp,
                subtitle: AppStrings.settingsHelpDescription,
                leading: Icons.help_outline,
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.pets, size: 48),
      children: [
        const Text(AppStrings.appDescription),
      ],
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.settingsHelp),
        content: const Text(AppStrings.settingsHelpContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}
