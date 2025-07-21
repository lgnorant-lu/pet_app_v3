/*
---------------------------------------------------------------
File name:          settings_models.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
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
      autoStartup: json['autoStartup'] as bool? ?? true,
      startupPage: StartupPage.values.firstWhere(
        (e) => e.name == json['startupPage'],
        orElse: () => StartupPage.home,
      ),
      memoryLimitMB: json['memoryLimitMB'] as int? ?? 300,
      cacheStrategy: CacheStrategy.values.firstWhere(
        (e) => e.name == json['cacheStrategy'],
        orElse: () => CacheStrategy.balanced,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.autoStartup == autoStartup &&
        other.startupPage == startupPage &&
        other.memoryLimitMB == memoryLimitMB &&
        other.cacheStrategy == cacheStrategy;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      language,
      autoStartup,
      startupPage,
      memoryLimitMB,
      cacheStrategy,
    );
  }
}

/// 插件设置数据模型
class PluginSettings {
  final bool autoUpdate;
  final bool allowBetaPlugins;
  final String storeUrl;

  const PluginSettings({
    this.autoUpdate = true,
    this.allowBetaPlugins = false,
    this.storeUrl = 'https://plugins.petapp.com',
  });

  PluginSettings copyWith({
    bool? autoUpdate,
    bool? allowBetaPlugins,
    String? storeUrl,
  }) {
    return PluginSettings(
      autoUpdate: autoUpdate ?? this.autoUpdate,
      allowBetaPlugins: allowBetaPlugins ?? this.allowBetaPlugins,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoUpdate': autoUpdate,
      'allowBetaPlugins': allowBetaPlugins,
      'storeUrl': storeUrl,
    };
  }

  factory PluginSettings.fromJson(Map<String, dynamic> json) {
    return PluginSettings(
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      allowBetaPlugins: json['allowBetaPlugins'] as bool? ?? false,
      storeUrl: json['storeUrl'] as String? ?? 'https://plugins.petapp.com',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PluginSettings &&
        other.autoUpdate == autoUpdate &&
        other.allowBetaPlugins == allowBetaPlugins &&
        other.storeUrl == storeUrl;
  }

  @override
  int get hashCode {
    return Object.hash(autoUpdate, allowBetaPlugins, storeUrl);
  }
}

/// 用户偏好设置数据模型
class UserPreferences {
  final FontSize fontSize;
  final bool dataCollection;
  final bool autoBackup;
  final bool cloudSync;

  const UserPreferences({
    this.fontSize = FontSize.medium,
    this.dataCollection = false,
    this.autoBackup = true,
    this.cloudSync = false,
  });

  UserPreferences copyWith({
    FontSize? fontSize,
    bool? dataCollection,
    bool? autoBackup,
    bool? cloudSync,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      dataCollection: dataCollection ?? this.dataCollection,
      autoBackup: autoBackup ?? this.autoBackup,
      cloudSync: cloudSync ?? this.cloudSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize.name,
      'dataCollection': dataCollection,
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
      dataCollection: json['dataCollection'] as bool? ?? false,
      autoBackup: json['autoBackup'] as bool? ?? true,
      cloudSync: json['cloudSync'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.fontSize == fontSize &&
        other.dataCollection == dataCollection &&
        other.autoBackup == autoBackup &&
        other.cloudSync == cloudSync;
  }

  @override
  int get hashCode {
    return Object.hash(fontSize, dataCollection, autoBackup, cloudSync);
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
      app: json['app'] != null 
          ? AppSettings.fromJson(json['app'] as Map<String, dynamic>)
          : const AppSettings(),
      plugins: json['plugins'] != null
          ? PluginSettings.fromJson(json['plugins'] as Map<String, dynamic>)
          : const PluginSettings(),
      user: json['user'] != null
          ? UserPreferences.fromJson(json['user'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.app == app &&
        other.plugins == plugins &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(app, plugins, user);
  }
}
