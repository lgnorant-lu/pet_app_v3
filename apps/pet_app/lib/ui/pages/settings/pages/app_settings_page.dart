/*
---------------------------------------------------------------
File name:          app_settings_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        应用设置页面 - 主题、语言、启动、性能配置
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_strings.dart';
import '../../../../core/models/settings_models.dart';
import '../../../../core/providers/settings_provider.dart';
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
      appBar: AppBar(title: const Text(AppStrings.settingsApp), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 主题设置
          SettingsSection(
            title: AppStrings.settingsTheme,
            children: [
              SettingsTile.selection<AppThemeMode>(
                title: AppStrings.settingsTheme,
                subtitle: _getThemeModeDisplayName(appSettings.themeMode),
                value: appSettings.themeMode,
                options: const [
                  SelectionOption(
                    value: AppThemeMode.light,
                    title: AppStrings.settingsThemeLight,
                  ),
                  SelectionOption(
                    value: AppThemeMode.dark,
                    title: AppStrings.settingsThemeDark,
                  ),
                  SelectionOption(
                    value: AppThemeMode.auto,
                    title: AppStrings.settingsThemeAuto,
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

          const SizedBox(height: 24),

          // 语言设置
          SettingsSection(
            title: AppStrings.settingsLanguage,
            children: [
              SettingsTile.selection<AppLanguage>(
                title: AppStrings.settingsLanguage,
                subtitle: _getLanguageDisplayName(appSettings.language),
                value: appSettings.language,
                options: const [
                  SelectionOption(
                    value: AppLanguage.chinese,
                    title: AppStrings.settingsLanguageChinese,
                  ),
                  SelectionOption(
                    value: AppLanguage.english,
                    title: AppStrings.settingsLanguageEnglish,
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

          const SizedBox(height: 24),

          // 启动设置
          SettingsSection(
            title: AppStrings.settingsStartup,
            children: [
              SettingsTile.switchTile(
                title: AppStrings.settingsStartupAuto,
                subtitle: '应用随系统启动',
                value: appSettings.autoStartup,
                onChanged: (value) {
                  settingsNotifier.updateAutoStartup(value);
                },
              ),
              SettingsTile.selection<StartupPage>(
                title: AppStrings.settingsStartupPage,
                subtitle: _getStartupPageDisplayName(appSettings.startupPage),
                value: appSettings.startupPage,
                options: const [
                  SelectionOption(
                    value: StartupPage.home,
                    title: AppStrings.homeTitle,
                  ),
                  SelectionOption(
                    value: StartupPage.workshop,
                    title: AppStrings.workshopTitle,
                  ),
                  SelectionOption(
                    value: StartupPage.apps,
                    title: AppStrings.appsTitle,
                  ),
                  SelectionOption(
                    value: StartupPage.pet,
                    title: AppStrings.petTitle,
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

          const SizedBox(height: 24),

          // 性能设置
          SettingsSection(
            title: AppStrings.settingsPerformance,
            children: [
              SettingsTile.slider(
                title: AppStrings.settingsMemoryLimit,
                subtitle: '${appSettings.memoryLimitMB} MB',
                value: appSettings.memoryLimitMB.toDouble(),
                min: 100,
                max: 1000,
                divisions: 18,
                onChanged: (value) {
                  settingsNotifier.updateMemoryLimit(value.round());
                },
              ),
              SettingsTile.selection<CacheStrategy>(
                title: AppStrings.settingsCacheStrategy,
                subtitle: _getCacheStrategyDisplayName(
                  appSettings.cacheStrategy,
                ),
                value: appSettings.cacheStrategy,
                options: const [
                  SelectionOption(
                    value: CacheStrategy.aggressive,
                    title: '激进缓存',
                  ),
                  SelectionOption(value: CacheStrategy.balanced, title: '平衡缓存'),
                  SelectionOption(
                    value: CacheStrategy.conservative,
                    title: '保守缓存',
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
        return AppStrings.settingsThemeLight;
      case AppThemeMode.dark:
        return AppStrings.settingsThemeDark;
      case AppThemeMode.auto:
        return AppStrings.settingsThemeAuto;
    }
  }

  /// 获取语言显示名称
  String _getLanguageDisplayName(AppLanguage language) {
    switch (language) {
      case AppLanguage.chinese:
        return AppStrings.settingsLanguageChinese;
      case AppLanguage.english:
        return AppStrings.settingsLanguageEnglish;
    }
  }

  /// 获取启动页面显示名称
  String _getStartupPageDisplayName(StartupPage startupPage) {
    switch (startupPage) {
      case StartupPage.home:
        return AppStrings.homeTitle;
      case StartupPage.workshop:
        return AppStrings.workshopTitle;
      case StartupPage.apps:
        return AppStrings.appsTitle;
      case StartupPage.pet:
        return AppStrings.petTitle;
    }
  }

  /// 获取缓存策略显示名称
  String _getCacheStrategyDisplayName(CacheStrategy cacheStrategy) {
    switch (cacheStrategy) {
      case CacheStrategy.aggressive:
        return '激进缓存';
      case CacheStrategy.balanced:
        return '平衡缓存';
      case CacheStrategy.conservative:
        return '保守缓存';
    }
  }
}
