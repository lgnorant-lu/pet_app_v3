/*
---------------------------------------------------------------
File name:          settings_models_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置模型测试 - 数据模型功能验证
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app_v3/core/models/settings_models.dart';

void main() {
  group('Settings Models Tests', () {
    group('AppSettings Tests', () {
      test('应该使用默认值创建AppSettings', () {
        const appSettings = AppSettings();

        expect(appSettings.themeMode, equals(AppThemeMode.auto));
        expect(appSettings.language, equals(AppLanguage.chinese));
        expect(appSettings.autoStartup, isTrue);
        expect(appSettings.startupPage, equals(StartupPage.home));
        expect(appSettings.memoryLimitMB, equals(300));
        expect(appSettings.cacheStrategy, equals(CacheStrategy.balanced));
      });

      test('应该能够创建自定义AppSettings', () {
        const appSettings = AppSettings(
          themeMode: AppThemeMode.dark,
          language: AppLanguage.english,
          autoStartup: false,
          startupPage: StartupPage.workshop,
          memoryLimitMB: 500,
          cacheStrategy: CacheStrategy.aggressive,
        );

        expect(appSettings.themeMode, equals(AppThemeMode.dark));
        expect(appSettings.language, equals(AppLanguage.english));
        expect(appSettings.autoStartup, isFalse);
        expect(appSettings.startupPage, equals(StartupPage.workshop));
        expect(appSettings.memoryLimitMB, equals(500));
        expect(appSettings.cacheStrategy, equals(CacheStrategy.aggressive));
      });

      test('应该能够使用copyWith更新AppSettings', () {
        const original = AppSettings();
        final updated = original.copyWith(
          themeMode: AppThemeMode.light,
          language: AppLanguage.english,
        );

        expect(updated.themeMode, equals(AppThemeMode.light));
        expect(updated.language, equals(AppLanguage.english));
        expect(updated.autoStartup, equals(original.autoStartup));
        expect(updated.startupPage, equals(original.startupPage));
        expect(updated.memoryLimitMB, equals(original.memoryLimitMB));
        expect(updated.cacheStrategy, equals(original.cacheStrategy));
      });

      test('应该能够序列化和反序列化AppSettings', () {
        const original = AppSettings(
          themeMode: AppThemeMode.dark,
          language: AppLanguage.english,
          autoStartup: false,
          startupPage: StartupPage.apps,
          memoryLimitMB: 400,
          cacheStrategy: CacheStrategy.conservative,
        );

        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.themeMode, equals(original.themeMode));
        expect(restored.language, equals(original.language));
        expect(restored.autoStartup, equals(original.autoStartup));
        expect(restored.startupPage, equals(original.startupPage));
        expect(restored.memoryLimitMB, equals(original.memoryLimitMB));
        expect(restored.cacheStrategy, equals(original.cacheStrategy));
      });

      test('应该能够处理无效JSON数据', () {
        final restored = AppSettings.fromJson({
          'themeMode': 'invalid_theme',
          'language': 'invalid_language',
          'startupPage': 'invalid_page',
          'cacheStrategy': 'invalid_strategy',
        });

        // 应该使用默认值
        expect(restored.themeMode, equals(AppThemeMode.auto));
        expect(restored.language, equals(AppLanguage.chinese));
        expect(restored.startupPage, equals(StartupPage.home));
        expect(restored.cacheStrategy, equals(CacheStrategy.balanced));
      });
    });

    group('PluginSettings Tests', () {
      test('应该使用默认值创建PluginSettings', () {
        const pluginSettings = PluginSettings();

        expect(pluginSettings.enabledPlugins, isEmpty);
        expect(pluginSettings.disabledPlugins, isEmpty);
        expect(pluginSettings.permissions, isEmpty);
        expect(pluginSettings.autoUpdate, isTrue);
        expect(pluginSettings.allowBetaPlugins, isFalse);
        expect(pluginSettings.storeUrl, isEmpty);
      });

      test('应该能够创建自定义PluginSettings', () {
        const pluginSettings = PluginSettings(
          enabledPlugins: ['plugin1', 'plugin2'],
          disabledPlugins: ['plugin3'],
          permissions: {'plugin1': true, 'plugin2': false},
          autoUpdate: false,
          allowBetaPlugins: true,
          storeUrl: 'https://store.example.com',
        );

        expect(pluginSettings.enabledPlugins, equals(['plugin1', 'plugin2']));
        expect(pluginSettings.disabledPlugins, equals(['plugin3']));
        expect(pluginSettings.permissions, equals({'plugin1': true, 'plugin2': false}));
        expect(pluginSettings.autoUpdate, isFalse);
        expect(pluginSettings.allowBetaPlugins, isTrue);
        expect(pluginSettings.storeUrl, equals('https://store.example.com'));
      });

      test('应该能够序列化和反序列化PluginSettings', () {
        const original = PluginSettings(
          enabledPlugins: ['test_plugin'],
          permissions: {'test_plugin': true},
          autoUpdate: false,
        );

        final json = original.toJson();
        final restored = PluginSettings.fromJson(json);

        expect(restored.enabledPlugins, equals(original.enabledPlugins));
        expect(restored.permissions, equals(original.permissions));
        expect(restored.autoUpdate, equals(original.autoUpdate));
      });
    });

    group('UserPreferences Tests', () {
      test('应该使用默认值创建UserPreferences', () {
        const userPreferences = UserPreferences();

        expect(userPreferences.fontSize, equals(FontSize.medium));
        expect(userPreferences.layout, equals('default'));
        expect(userPreferences.shortcuts, isEmpty);
        expect(userPreferences.gesturesEnabled, isTrue);
        expect(userPreferences.dataCollection, isFalse);
        expect(userPreferences.analytics, isFalse);
        expect(userPreferences.autoBackup, isTrue);
        expect(userPreferences.cloudSync, isFalse);
      });

      test('应该能够序列化和反序列化UserPreferences', () {
        const original = UserPreferences(
          fontSize: FontSize.large,
          layout: 'custom',
          shortcuts: {'ctrl+s': 'save'},
          gesturesEnabled: false,
          dataCollection: true,
        );

        final json = original.toJson();
        final restored = UserPreferences.fromJson(json);

        expect(restored.fontSize, equals(original.fontSize));
        expect(restored.layout, equals(original.layout));
        expect(restored.shortcuts, equals(original.shortcuts));
        expect(restored.gesturesEnabled, equals(original.gesturesEnabled));
        expect(restored.dataCollection, equals(original.dataCollection));
      });
    });

    group('Settings Tests', () {
      test('应该使用默认值创建Settings', () {
        const settings = Settings();

        expect(settings.app, isA<AppSettings>());
        expect(settings.plugins, isA<PluginSettings>());
        expect(settings.user, isA<UserPreferences>());
      });

      test('应该能够创建自定义Settings', () {
        const appSettings = AppSettings(themeMode: AppThemeMode.dark);
        const pluginSettings = PluginSettings(autoUpdate: false);
        const userPreferences = UserPreferences(fontSize: FontSize.large);

        const settings = Settings(
          app: appSettings,
          plugins: pluginSettings,
          user: userPreferences,
        );

        expect(settings.app.themeMode, equals(AppThemeMode.dark));
        expect(settings.plugins.autoUpdate, isFalse);
        expect(settings.user.fontSize, equals(FontSize.large));
      });

      test('应该能够序列化和反序列化完整Settings', () {
        const original = Settings(
          app: AppSettings(themeMode: AppThemeMode.light),
          plugins: PluginSettings(autoUpdate: false),
          user: UserPreferences(fontSize: FontSize.small),
        );

        final json = original.toJson();
        final restored = Settings.fromJson(json);

        expect(restored.app.themeMode, equals(original.app.themeMode));
        expect(restored.plugins.autoUpdate, equals(original.plugins.autoUpdate));
        expect(restored.user.fontSize, equals(original.user.fontSize));
      });

      test('应该能够使用copyWith更新Settings', () {
        const original = Settings();
        const newAppSettings = AppSettings(themeMode: AppThemeMode.dark);
        
        final updated = original.copyWith(app: newAppSettings);

        expect(updated.app.themeMode, equals(AppThemeMode.dark));
        expect(updated.plugins, equals(original.plugins));
        expect(updated.user, equals(original.user));
      });
    });

    group('枚举测试', () {
      test('AppThemeMode枚举应该包含所有值', () {
        expect(AppThemeMode.values, hasLength(3));
        expect(AppThemeMode.values, contains(AppThemeMode.light));
        expect(AppThemeMode.values, contains(AppThemeMode.dark));
        expect(AppThemeMode.values, contains(AppThemeMode.auto));
      });

      test('AppLanguage枚举应该包含所有值', () {
        expect(AppLanguage.values, hasLength(2));
        expect(AppLanguage.values, contains(AppLanguage.chinese));
        expect(AppLanguage.values, contains(AppLanguage.english));
      });

      test('StartupPage枚举应该包含所有值', () {
        expect(StartupPage.values, hasLength(4));
        expect(StartupPage.values, contains(StartupPage.home));
        expect(StartupPage.values, contains(StartupPage.workshop));
        expect(StartupPage.values, contains(StartupPage.apps));
        expect(StartupPage.values, contains(StartupPage.pet));
      });

      test('FontSize枚举应该包含所有值', () {
        expect(FontSize.values, hasLength(3));
        expect(FontSize.values, contains(FontSize.small));
        expect(FontSize.values, contains(FontSize.medium));
        expect(FontSize.values, contains(FontSize.large));
      });

      test('CacheStrategy枚举应该包含所有值', () {
        expect(CacheStrategy.values, hasLength(3));
        expect(CacheStrategy.values, contains(CacheStrategy.aggressive));
        expect(CacheStrategy.values, contains(CacheStrategy.balanced));
        expect(CacheStrategy.values, contains(CacheStrategy.conservative));
      });
    });
  });
}
