/*
---------------------------------------------------------------
File name:          settings_models.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置系统数据模型 - 配置项的数据结构定义
---------------------------------------------------------------
*/

/// 应用主题模式枚举
enum AppThemeMode { light, dark, auto }

/// 语言枚举
enum AppLanguage { chinese, english }

/// 启动页面枚举
enum StartupPage { home, workshop, apps, pet }

/// 字体大小枚举
enum FontSize { small, medium, large }

/// 缓存策略枚举
enum CacheStrategy { aggressive, balanced, conservative }

/// 应用设置数据模型
class AppSettings {
  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool autoStartup;
  final StartupPage startupPage;
  final int memoryLimitMB;
  final CacheStrategy cacheStrategy;

  const AppSettings({
    this.themeMode = AppThemeMode.auto,
    this.language = AppLanguage.chinese,
    this.autoStartup = true,
    this.startupPage = StartupPage.home,
    this.memoryLimitMB = 300,
    this.cacheStrategy = CacheStrategy.balanced,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? autoStartup,
    StartupPage? startupPage,
    int? memoryLimitMB,
    CacheStrategy? cacheStrategy,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      autoStartup: autoStartup ?? this.autoStartup,
      startupPage: startupPage ?? this.startupPage,
      memoryLimitMB: memoryLimitMB ?? this.memoryLimitMB,
      cacheStrategy: cacheStrategy ?? this.cacheStrategy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'language': language.name,
      'autoStartup': autoStartup,
      'startupPage': startupPage.name,
      'memoryLimitMB': memoryLimitMB,
      'cacheStrategy': cacheStrategy.name,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.auto,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguage.chinese,
      ),
      autoStartup: json['autoStartup'] ?? true,
      startupPage: StartupPage.values.firstWhere(
        (e) => e.name == json['startupPage'],
        orElse: () => StartupPage.home,
      ),
      memoryLimitMB: json['memoryLimitMB'] ?? 300,
      cacheStrategy: CacheStrategy.values.firstWhere(
        (e) => e.name == json['cacheStrategy'],
        orElse: () => CacheStrategy.balanced,
      ),
    );
  }
}

/// 插件设置数据模型
class PluginSettings {
  final List<String> enabledPlugins;
  final List<String> disabledPlugins;
  final Map<String, bool> permissions;
  final bool autoUpdate;
  final bool allowBetaPlugins;
  final String storeUrl;

  const PluginSettings({
    this.enabledPlugins = const <String>[],
    this.disabledPlugins = const <String>[],
    this.permissions = const <String, bool>{},
    this.autoUpdate = true,
    this.allowBetaPlugins = false,
    this.storeUrl = '',
  });

  PluginSettings copyWith({
    List<String>? enabledPlugins,
    List<String>? disabledPlugins,
    Map<String, bool>? permissions,
    bool? autoUpdate,
    bool? allowBetaPlugins,
    String? storeUrl,
  }) {
    return PluginSettings(
      enabledPlugins: enabledPlugins ?? this.enabledPlugins,
      disabledPlugins: disabledPlugins ?? this.disabledPlugins,
      permissions: permissions ?? this.permissions,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      allowBetaPlugins: allowBetaPlugins ?? this.allowBetaPlugins,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabledPlugins': enabledPlugins,
      'disabledPlugins': disabledPlugins,
      'permissions': permissions,
      'autoUpdate': autoUpdate,
      'allowBetaPlugins': allowBetaPlugins,
      'storeUrl': storeUrl,
    };
  }

  factory PluginSettings.fromJson(Map<String, dynamic> json) {
    return PluginSettings(
      enabledPlugins: List<String>.from(json['enabledPlugins'] ?? []),
      disabledPlugins: List<String>.from(json['disabledPlugins'] ?? []),
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
      autoUpdate: json['autoUpdate'] ?? true,
      allowBetaPlugins: json['allowBetaPlugins'] ?? false,
      storeUrl: json['storeUrl'] ?? '',
    );
  }
}

/// 用户偏好设置数据模型
class UserPreferences {
  final FontSize fontSize;
  final String layout;
  final Map<String, String> shortcuts;
  final bool gesturesEnabled;
  final bool dataCollection;
  final bool analytics;
  final bool autoBackup;
  final bool cloudSync;

  const UserPreferences({
    this.fontSize = FontSize.medium,
    this.layout = 'default',
    this.shortcuts = const <String, String>{},
    this.gesturesEnabled = true,
    this.dataCollection = false,
    this.analytics = false,
    this.autoBackup = true,
    this.cloudSync = false,
  });

  UserPreferences copyWith({
    FontSize? fontSize,
    String? layout,
    Map<String, String>? shortcuts,
    bool? gesturesEnabled,
    bool? dataCollection,
    bool? analytics,
    bool? autoBackup,
    bool? cloudSync,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      layout: layout ?? this.layout,
      shortcuts: shortcuts ?? this.shortcuts,
      gesturesEnabled: gesturesEnabled ?? this.gesturesEnabled,
      dataCollection: dataCollection ?? this.dataCollection,
      analytics: analytics ?? this.analytics,
      autoBackup: autoBackup ?? this.autoBackup,
      cloudSync: cloudSync ?? this.cloudSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize.name,
      'layout': layout,
      'shortcuts': shortcuts,
      'gesturesEnabled': gesturesEnabled,
      'dataCollection': dataCollection,
      'analytics': analytics,
      'autoBackup': autoBackup,
      'cloudSync': cloudSync,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      fontSize: FontSize.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => FontSize.medium,
      ),
      layout: json['layout'] ?? 'default',
      shortcuts: Map<String, String>.from(json['shortcuts'] ?? {}),
      gesturesEnabled: json['gesturesEnabled'] ?? true,
      dataCollection: json['dataCollection'] ?? false,
      analytics: json['analytics'] ?? false,
      autoBackup: json['autoBackup'] ?? true,
      cloudSync: json['cloudSync'] ?? false,
    );
  }
}

/// 完整设置数据模型
class Settings {
  final AppSettings app;
  final PluginSettings plugins;
  final UserPreferences user;

  const Settings({
    this.app = const AppSettings(),
    this.plugins = const PluginSettings(),
    this.user = const UserPreferences(),
  });

  Settings copyWith({
    AppSettings? app,
    PluginSettings? plugins,
    UserPreferences? user,
  }) {
    return Settings(
      app: app ?? this.app,
      plugins: plugins ?? this.plugins,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app.toJson(),
      'plugins': plugins.toJson(),
      'user': user.toJson(),
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      app: AppSettings.fromJson(json['app'] ?? {}),
      plugins: PluginSettings.fromJson(json['plugins'] ?? {}),
      user: UserPreferences.fromJson(json['user'] ?? {}),
    );
  }
}
