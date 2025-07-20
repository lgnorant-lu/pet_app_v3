/*
---------------------------------------------------------------
File name:          settings_provider_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置Provider测试 - 验证设置状态管理功能
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_app_v3/core/providers/settings_provider.dart';
import 'package:pet_app_v3/core/models/settings_models.dart';

void main() {
  group('SettingsProvider Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // 设置测试环境的SharedPreferences
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider初始化测试', () {
      test('应该提供默认设置', () {
        final settings = container.read(settingsProvider);

        expect(settings.app.themeMode, AppThemeMode.auto);
        expect(settings.app.language, AppLanguage.chinese);
        expect(settings.plugins.enabledPlugins, isEmpty);
        expect(settings.user.fontSize, FontSize.medium);
      });

      test('应该提供正确的子Provider', () {
        final appSettings = container.read(appSettingsProvider);
        final pluginSettings = container.read(pluginSettingsProvider);
        final userPreferences = container.read(userPreferencesProvider);

        expect(appSettings.themeMode, AppThemeMode.auto);
        expect(pluginSettings.enabledPlugins, isEmpty);
        expect(userPreferences.fontSize, FontSize.medium);
      });

      test('应该提供特定的设置Provider', () {
        final themeMode = container.read(themeModeProvider);
        final language = container.read(languageProvider);
        final fontSize = container.read(fontSizeProvider);

        expect(themeMode, AppThemeMode.auto);
        expect(language, AppLanguage.chinese);
        expect(fontSize, FontSize.medium);
      });
    });

    group('设置更新测试', () {
      test('应该能够更新主题模式', () async {
        final notifier = container.read(settingsProvider.notifier);

        await notifier.updateThemeMode(AppThemeMode.dark);

        final settings = container.read(settingsProvider);
        expect(settings.app.themeMode, AppThemeMode.dark);

        final themeMode = container.read(themeModeProvider);
        expect(themeMode, AppThemeMode.dark);
      });

      test('应该能够更新语言', () async {
        final notifier = container.read(settingsProvider.notifier);

        await notifier.updateLanguage(AppLanguage.english);

        final settings = container.read(settingsProvider);
        expect(settings.app.language, AppLanguage.english);

        final language = container.read(languageProvider);
        expect(language, AppLanguage.english);
      });

      test('应该能够更新字体大小', () async {
        final notifier = container.read(settingsProvider.notifier);

        await notifier.updateFontSize(FontSize.large);

        final settings = container.read(settingsProvider);
        expect(settings.user.fontSize, FontSize.large);

        final fontSize = container.read(fontSizeProvider);
        expect(fontSize, FontSize.large);
      });
    });

    group('插件管理测试', () {
      test('应该能够启用插件', () async {
        final notifier = container.read(settingsProvider.notifier);

        await notifier.enablePlugin('test_plugin');

        final settings = container.read(settingsProvider);
        expect(settings.plugins.enabledPlugins, contains('test_plugin'));
      });

      test('应该能够禁用插件', () async {
        final notifier = container.read(settingsProvider.notifier);

        // 先启用插件
        await notifier.enablePlugin('test_plugin');
        // 再禁用插件
        await notifier.disablePlugin('test_plugin');

        final settings = container.read(settingsProvider);
        expect(settings.plugins.enabledPlugins, isNot(contains('test_plugin')));
        expect(settings.plugins.disabledPlugins, contains('test_plugin'));
      });

      test('应该能够更新插件权限', () async {
        final notifier = container.read(settingsProvider.notifier);

        await notifier.updatePluginPermission('test_plugin', true);

        final settings = container.read(settingsProvider);
        expect(settings.plugins.permissions['test_plugin'], true);
      });
    });

    group('复合设置更新测试', () {
      test('应该能够更新完整的应用设置', () async {
        final notifier = container.read(settingsProvider.notifier);

        const newAppSettings = AppSettings(
          themeMode: AppThemeMode.dark,
          language: AppLanguage.english,
          autoStartup: false,
          startupPage: StartupPage.workshop,
          memoryLimitMB: 500,
          cacheStrategy: CacheStrategy.aggressive,
        );

        await notifier.updateAppSettings(newAppSettings);

        final settings = container.read(settingsProvider);
        expect(settings.app.themeMode, AppThemeMode.dark);
        expect(settings.app.language, AppLanguage.english);
        expect(settings.app.autoStartup, false);
        expect(settings.app.startupPage, StartupPage.workshop);
        expect(settings.app.memoryLimitMB, 500);
        expect(settings.app.cacheStrategy, CacheStrategy.aggressive);
      });

      test('应该能够更新完整的用户偏好', () async {
        final notifier = container.read(settingsProvider.notifier);

        const newUserPreferences = UserPreferences(
          fontSize: FontSize.large,
          layout: 'custom',
          gesturesEnabled: false,
          dataCollection: true,
          analytics: true,
          autoBackup: false,
          cloudSync: true,
        );

        await notifier.updateUserPreferences(newUserPreferences);

        final settings = container.read(settingsProvider);
        expect(settings.user.fontSize, FontSize.large);
        expect(settings.user.layout, 'custom');
        expect(settings.user.gesturesEnabled, false);
        expect(settings.user.dataCollection, true);
        expect(settings.user.analytics, true);
        expect(settings.user.autoBackup, false);
        expect(settings.user.cloudSync, true);
      });
    });

    group('数据操作测试', () {
      test('应该能够重置所有设置', () async {
        final notifier = container.read(settingsProvider.notifier);

        // 修改一些设置
        await notifier.updateThemeMode(AppThemeMode.dark);
        await notifier.updateLanguage(AppLanguage.english);
        await notifier.enablePlugin('test_plugin');

        // 重置设置
        await notifier.resetToDefaults();

        final settings = container.read(settingsProvider);
        expect(settings.app.themeMode, AppThemeMode.auto);
        expect(settings.app.language, AppLanguage.chinese);
        expect(settings.plugins.enabledPlugins, isEmpty);
      });

      test('应该能够导出和导入设置', () async {
        final notifier = container.read(settingsProvider.notifier);

        // 修改一些设置
        await notifier.updateThemeMode(AppThemeMode.dark);
        await notifier.updateLanguage(AppLanguage.english);

        // 导出设置
        final exportedSettings = notifier.exportSettings();

        // 重置设置
        await notifier.resetToDefaults();

        // 导入设置
        await notifier.importSettings(exportedSettings);

        // 验证设置已恢复
        final settings = container.read(settingsProvider);
        expect(settings.app.themeMode, AppThemeMode.dark);
        expect(settings.app.language, AppLanguage.english);
      });
    });

    group('Provider监听测试', () {
      test('设置变更应该触发Provider更新', () async {
        final notifier = container.read(settingsProvider.notifier);

        // 监听主题模式变化
        final themeModeListener = container.listen<AppThemeMode>(
          themeModeProvider,
          (previous, next) {},
        );

        // 更新主题模式
        await notifier.updateThemeMode(AppThemeMode.dark);

        // 验证Provider已更新
        expect(themeModeListener.read(), AppThemeMode.dark);
      });
    });
  });
}
