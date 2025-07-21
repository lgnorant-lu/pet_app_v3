/*
---------------------------------------------------------------
File name:          settings_service.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        设置服务 - 负责设置数据的持久化存储和读取
---------------------------------------------------------------
*/

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_models.dart';

/// 设置服务
///
/// 负责设置数据的持久化存储和读取
/// 使用SharedPreferences作为存储后端
class SettingsService {
  static const String _settingsKey = 'pet_app_settings';

  SharedPreferences? _prefs;
  Settings _currentSettings = const Settings();

  /// 初始化设置服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  /// 获取当前设置
  Settings get currentSettings => _currentSettings;

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _currentSettings = Settings.fromJson(settingsMap);
      }
    } catch (e) {
      // 如果加载失败，使用默认设置
      _currentSettings = const Settings();
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final settingsJson = jsonEncode(_currentSettings.toJson());
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// 更新应用设置
  Future<void> updateAppSettings(AppSettings appSettings) async {
    _currentSettings = _currentSettings.copyWith(app: appSettings);
    await _saveSettings();
  }

  /// 更新插件设置
  Future<void> updatePluginSettings(PluginSettings pluginSettings) async {
    _currentSettings = _currentSettings.copyWith(plugins: pluginSettings);
    await _saveSettings();
  }

  /// 更新用户偏好设置
  Future<void> updateUserPreferences(UserPreferences userPreferences) async {
    _currentSettings = _currentSettings.copyWith(user: userPreferences);
    await _saveSettings();
  }

  /// 重置所有设置到默认值
  Future<void> resetToDefaults() async {
    _currentSettings = const Settings();
    await _saveSettings();
  }

  /// 导出设置
  Map<String, dynamic> exportSettings() {
    return _currentSettings.toJson();
  }

  /// 导入设置
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      _currentSettings = Settings.fromJson(settingsData);
      await _saveSettings();
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  /// 获取应用设置
  AppSettings get appSettings => _currentSettings.app;

  /// 获取插件设置
  PluginSettings get pluginSettings => _currentSettings.plugins;

  /// 获取用户偏好设置
  UserPreferences get userPreferences => _currentSettings.user;

  /// 更新主题模式
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final newAppSettings = _currentSettings.app.copyWith(themeMode: themeMode);
    await updateAppSettings(newAppSettings);
  }

  /// 更新语言
  Future<void> updateLanguage(AppLanguage language) async {
    final newAppSettings = _currentSettings.app.copyWith(language: language);
    await updateAppSettings(newAppSettings);
  }

  /// 更新自动启动
  Future<void> updateAutoStartup(bool autoStartup) async {
    final newAppSettings = _currentSettings.app.copyWith(autoStartup: autoStartup);
    await updateAppSettings(newAppSettings);
  }

  /// 更新启动页面
  Future<void> updateStartupPage(StartupPage startupPage) async {
    final newAppSettings = _currentSettings.app.copyWith(startupPage: startupPage);
    await updateAppSettings(newAppSettings);
  }

  /// 更新内存限制
  Future<void> updateMemoryLimit(int memoryLimitMB) async {
    final newAppSettings = _currentSettings.app.copyWith(memoryLimitMB: memoryLimitMB);
    await updateAppSettings(newAppSettings);
  }

  /// 更新缓存策略
  Future<void> updateCacheStrategy(CacheStrategy cacheStrategy) async {
    final newAppSettings = _currentSettings.app.copyWith(cacheStrategy: cacheStrategy);
    await updateAppSettings(newAppSettings);
  }

  /// 更新自动更新插件
  Future<void> updateAutoUpdate(bool autoUpdate) async {
    final newPluginSettings = _currentSettings.plugins.copyWith(autoUpdate: autoUpdate);
    await updatePluginSettings(newPluginSettings);
  }

  /// 更新允许Beta插件
  Future<void> updateAllowBetaPlugins(bool allowBetaPlugins) async {
    final newPluginSettings = _currentSettings.plugins.copyWith(allowBetaPlugins: allowBetaPlugins);
    await updatePluginSettings(newPluginSettings);
  }

  /// 更新插件商店URL
  Future<void> updateStoreUrl(String storeUrl) async {
    final newPluginSettings = _currentSettings.plugins.copyWith(storeUrl: storeUrl);
    await updatePluginSettings(newPluginSettings);
  }

  /// 更新字体大小
  Future<void> updateFontSize(FontSize fontSize) async {
    final newUserPreferences = _currentSettings.user.copyWith(fontSize: fontSize);
    await updateUserPreferences(newUserPreferences);
  }

  /// 更新数据收集设置
  Future<void> updateDataCollection(bool enabled) async {
    final newUserPreferences = _currentSettings.user.copyWith(dataCollection: enabled);
    await updateUserPreferences(newUserPreferences);
  }

  /// 更新自动备份设置
  Future<void> updateAutoBackup(bool enabled) async {
    final newUserPreferences = _currentSettings.user.copyWith(autoBackup: enabled);
    await updateUserPreferences(newUserPreferences);
  }

  /// 更新云同步设置
  Future<void> updateCloudSync(bool enabled) async {
    final newUserPreferences = _currentSettings.user.copyWith(cloudSync: enabled);
    await updateUserPreferences(newUserPreferences);
  }

  /// 清理设置数据
  Future<void> clearSettings() async {
    await _prefs?.remove(_settingsKey);
    _currentSettings = const Settings();
  }

  /// 检查设置是否存在
  bool get hasSettings {
    return _prefs?.containsKey(_settingsKey) ?? false;
  }

  /// 获取设置文件大小（字节）
  int get settingsSize {
    final settingsJson = _prefs?.getString(_settingsKey);
    return settingsJson?.length ?? 0;
  }
}
