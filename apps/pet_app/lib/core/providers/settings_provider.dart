/*
---------------------------------------------------------------
File name:          settings_provider.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置状态管理Provider - 使用Riverpod管理设置状态
---------------------------------------------------------------
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_models.dart';
import '../services/settings_service.dart';

/// 设置服务Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// 设置状态Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((
  ref,
) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsNotifier(settingsService);
});

/// 应用设置Provider
final appSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).app;
});

/// 插件设置Provider
final pluginSettingsProvider = Provider<PluginSettings>((ref) {
  return ref.watch(settingsProvider).plugins;
});

/// 用户偏好设置Provider
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  return ref.watch(settingsProvider).user;
});

/// 主题模式Provider
final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

/// 语言Provider
final languageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(appSettingsProvider).language;
});

/// 字体大小Provider
final fontSizeProvider = Provider<FontSize>((ref) {
  return ref.watch(userPreferencesProvider).fontSize;
});

/// 设置状态管理器
class SettingsNotifier extends StateNotifier<Settings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService) : super(const Settings()) {
    // 同步初始化，避免异步问题
    _settingsService.initialize().then((_) {
      if (mounted) {
        state = _settingsService.currentSettings;
      }
    });
  }

  /// 更新应用设置
  Future<void> updateAppSettings(AppSettings appSettings) async {
    await _settingsService.updateAppSettings(appSettings);
    state = state.copyWith(app: appSettings);
  }

  /// 更新插件设置
  Future<void> updatePluginSettings(PluginSettings pluginSettings) async {
    await _settingsService.updatePluginSettings(pluginSettings);
    state = state.copyWith(plugins: pluginSettings);
  }

  /// 更新用户偏好设置
  Future<void> updateUserPreferences(UserPreferences userPreferences) async {
    await _settingsService.updateUserPreferences(userPreferences);
    state = state.copyWith(user: userPreferences);
  }

  /// 更新主题模式
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    await _settingsService.updateThemeMode(themeMode);
    state = state.copyWith(app: state.app.copyWith(themeMode: themeMode));
  }

  /// 更新语言
  Future<void> updateLanguage(AppLanguage language) async {
    await _settingsService.updateLanguage(language);
    state = state.copyWith(app: state.app.copyWith(language: language));
  }

  /// 更新自动启动
  Future<void> updateAutoStartup(bool autoStartup) async {
    await _settingsService.updateAutoStartup(autoStartup);
    state = state.copyWith(app: state.app.copyWith(autoStartup: autoStartup));
  }

  /// 更新启动页面
  Future<void> updateStartupPage(StartupPage startupPage) async {
    await _settingsService.updateStartupPage(startupPage);
    state = state.copyWith(app: state.app.copyWith(startupPage: startupPage));
  }

  /// 更新内存限制
  Future<void> updateMemoryLimit(int memoryLimitMB) async {
    await _settingsService.updateMemoryLimit(memoryLimitMB);
    state = state.copyWith(
      app: state.app.copyWith(memoryLimitMB: memoryLimitMB),
    );
  }

  /// 更新缓存策略
  Future<void> updateCacheStrategy(CacheStrategy cacheStrategy) async {
    await _settingsService.updateCacheStrategy(cacheStrategy);
    state = state.copyWith(
      app: state.app.copyWith(cacheStrategy: cacheStrategy),
    );
  }

  /// 启用插件
  Future<void> enablePlugin(String pluginId) async {
    await _settingsService.enablePlugin(pluginId);
    state = state.copyWith(plugins: _settingsService.pluginSettings);
  }

  /// 禁用插件
  Future<void> disablePlugin(String pluginId) async {
    await _settingsService.disablePlugin(pluginId);
    state = state.copyWith(plugins: _settingsService.pluginSettings);
  }

  /// 更新插件权限
  Future<void> updatePluginPermission(String pluginId, bool granted) async {
    await _settingsService.updatePluginPermission(pluginId, granted);
    state = state.copyWith(plugins: _settingsService.pluginSettings);
  }

  /// 更新字体大小
  Future<void> updateFontSize(FontSize fontSize) async {
    await _settingsService.updateFontSize(fontSize);
    state = state.copyWith(user: state.user.copyWith(fontSize: fontSize));
  }

  /// 更新手势启用状态
  Future<void> updateGesturesEnabled(bool enabled) async {
    await _settingsService.updateGesturesEnabled(enabled);
    state = state.copyWith(user: state.user.copyWith(gesturesEnabled: enabled));
  }

  /// 更新数据收集设置
  Future<void> updateDataCollection(bool enabled) async {
    await _settingsService.updateDataCollection(enabled);
    state = state.copyWith(user: state.user.copyWith(dataCollection: enabled));
  }

  /// 更新自动备份设置
  Future<void> updateAutoBackup(bool enabled) async {
    await _settingsService.updateAutoBackup(enabled);
    state = state.copyWith(user: state.user.copyWith(autoBackup: enabled));
  }

  /// 更新云同步设置
  Future<void> updateCloudSync(bool enabled) async {
    await _settingsService.updateCloudSync(enabled);
    state = state.copyWith(user: state.user.copyWith(cloudSync: enabled));
  }

  /// 重置所有设置
  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
    state = const Settings();
  }

  /// 导出设置
  Map<String, dynamic> exportSettings() {
    return _settingsService.exportSettings();
  }

  /// 导入设置
  Future<void> importSettings(Map<String, dynamic> settingsMap) async {
    await _settingsService.importSettings(settingsMap);
    state = _settingsService.currentSettings;
  }
}
