/*
---------------------------------------------------------------
File name:          app_settings_page.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        应用设置页面 - 主题、语言、启动、性能配置
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_models.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// 应用设置页面
///
/// 提供应用级别的配置选项：
/// - 主题设置：浅色/深色/自动
/// - 语言设置：中文/英文（预留国际化）
/// - 启动设置：自动启动、启动页面
/// - 性能设置：内存限制、缓存策略
class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('应用设置'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 主题设置
          SettingsSection(
            title: '主题设置',
            children: [
              SettingsTile.selection<AppThemeMode>(
                title: '主题模式',
                subtitle: _getThemeModeDisplayName(appSettings.themeMode),
                value: appSettings.themeMode,
                options: const [
                  SelectionOption(
                    value: AppThemeMode.light,
                    title: '浅色主题',
                  ),
                  SelectionOption(
                    value: AppThemeMode.dark,
                    title: '深色主题',
                  ),
                  SelectionOption(
                    value: AppThemeMode.auto,
                    title: '跟随系统',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateThemeMode(value);
                  }
                },
              ),
            ],
          ),

          // 语言设置
          SettingsSection(
            title: '语言设置',
            children: [
              SettingsTile.selection<AppLanguage>(
                title: '界面语言',
                subtitle: _getLanguageDisplayName(appSettings.language),
                value: appSettings.language,
                options: const [
                  SelectionOption(
                    value: AppLanguage.chinese,
                    title: '简体中文',
                  ),
                  SelectionOption(
                    value: AppLanguage.english,
                    title: 'English',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateLanguage(value);
                  }
                },
              ),
            ],
          ),

          // 启动设置
          SettingsSection(
            title: '启动设置',
            children: [
              SettingsTile.switchTile(
                title: '开机自启动',
                subtitle: '系统启动时自动运行应用',
                leading: Icons.power_settings_new,
                value: appSettings.autoStartup,
                onChanged: (value) {
                  settingsNotifier.updateAutoStartup(value);
                },
              ),
              SettingsTile.selection<StartupPage>(
                title: '启动页面',
                subtitle: _getStartupPageDisplayName(appSettings.startupPage),
                value: appSettings.startupPage,
                options: const [
                  SelectionOption(
                    value: StartupPage.home,
                    title: '首页',
                  ),
                  SelectionOption(
                    value: StartupPage.workshop,
                    title: '创意工坊',
                  ),
                  SelectionOption(
                    value: StartupPage.apps,
                    title: '应用管理',
                  ),
                  SelectionOption(
                    value: StartupPage.pet,
                    title: '桌面宠物',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateStartupPage(value);
                  }
                },
              ),
            ],
          ),

          // 性能设置
          SettingsSection(
            title: '性能设置',
            children: [
              SettingsTile.sliderTile(
                title: '内存限制',
                subtitle: '应用最大内存使用量',
                leading: Icons.memory,
                value: appSettings.memoryLimitMB.toDouble(),
                min: 100,
                max: 1000,
                divisions: 18,
                valueFormatter: (value) => '${value.toInt()} MB',
                onChanged: (value) {
                  settingsNotifier.updateMemoryLimit(value.toInt());
                },
              ),
              SettingsTile.selection<CacheStrategy>(
                title: '缓存策略',
                subtitle: _getCacheStrategyDisplayName(appSettings.cacheStrategy),
                value: appSettings.cacheStrategy,
                options: const [
                  SelectionOption(
                    value: CacheStrategy.aggressive,
                    title: '激进缓存',
                    subtitle: '最大化缓存，提升性能',
                  ),
                  SelectionOption(
                    value: CacheStrategy.balanced,
                    title: '平衡模式',
                    subtitle: '性能与内存平衡',
                  ),
                  SelectionOption(
                    value: CacheStrategy.conservative,
                    title: '保守缓存',
                    subtitle: '最小化内存使用',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.updateCacheStrategy(value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取主题模式显示名称
  String _getThemeModeDisplayName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return '浅色主题';
      case AppThemeMode.dark:
        return '深色主题';
      case AppThemeMode.auto:
        return '跟随系统';
    }
  }

  /// 获取语言显示名称
  String _getLanguageDisplayName(AppLanguage language) {
    switch (language) {
      case AppLanguage.chinese:
        return '简体中文';
      case AppLanguage.english:
        return 'English';
    }
  }

  /// 获取启动页面显示名称
  String _getStartupPageDisplayName(StartupPage startupPage) {
    switch (startupPage) {
      case StartupPage.home:
        return '首页';
      case StartupPage.workshop:
        return '创意工坊';
      case StartupPage.apps:
        return '应用管理';
      case StartupPage.pet:
        return '桌面宠物';
    }
  }

  /// 获取缓存策略显示名称
  String _getCacheStrategyDisplayName(CacheStrategy cacheStrategy) {
    switch (cacheStrategy) {
      case CacheStrategy.aggressive:
        return '激进缓存';
      case CacheStrategy.balanced:
        return '平衡模式';
      case CacheStrategy.conservative:
        return '保守缓存';
    }
  }
}
