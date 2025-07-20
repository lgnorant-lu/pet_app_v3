/*
---------------------------------------------------------------
File name:          app_strings.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        应用字符串常量管理 - 硬编码字符串集中管理，预留国际化接口
---------------------------------------------------------------
*/

/// 应用字符串常量管理类
///
/// 用于集中管理应用中的所有硬编码字符串，便于后续国际化处理
/// 所有字符串都标记了 TODO: i18n 以便后续提取到资源文件
class AppStrings {
  // TODO: i18n - 应用基础信息
  static const String appName = 'Pet App V3';
  static const String appTitle = 'Pet App V3';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Pet App V3 是一个现代化的桌面宠物应用，提供丰富的交互功能和个性化体验。';

  // TODO: i18n - 主页相关
  static const String homeTitle = '主页';
  static const String homeWelcome = '欢迎使用Pet App';
  static const String homeModuleStatus = '模块状态';
  static const String homeQuickAccess = '快速访问';
  static const String homeUserOverview = '用户概览';

  // TODO: i18n - 创意工坊相关
  static const String workshopTitle = '创意工坊';
  static const String workshopNewProject = '新建项目';
  static const String workshopRecentProjects = '最近项目';
  static const String workshopTools = '工具';

  // TODO: i18n - 应用管理相关
  static const String appsTitle = '应用';
  static const String appsInstalled = '已安装应用';
  static const String appsAvailable = '可用应用';
  static const String appsUpdates = '更新';

  // TODO: i18n - 桌宠相关
  static const String petTitle = '桌宠';
  static const String petStatus = '状态';
  static const String petInteraction = '互动';
  static const String petSettings = '桌宠设置';

  // TODO: i18n - 设置相关
  static const String settings = '设置';
  static const String settingsTitle = '设置';
  static const String settingsGeneral = '通用设置';
  static const String settingsAbout = '关于';
  static const String settingsApp = '应用设置';
  static const String settingsAppDescription = '主题、语言、启动等应用配置';
  static const String settingsPlugins = '插件设置';
  static const String settingsPluginsDescription = '插件安装、权限、更新管理';
  static const String settingsUser = '用户偏好';
  static const String settingsUserDescription = '界面、交互、隐私等个人设置';
  static const String settingsVersion = '版本信息';
  static const String settingsHelp = '帮助与支持';
  static const String settingsHelpDescription = '使用指南和技术支持';
  static const String settingsHelpContent =
      '这是Pet App V3的设置帮助页面。\n\n如需更多帮助，请访问我们的官方网站或联系技术支持。';

  // TODO: i18n - 应用配置
  static const String settingsTheme = '主题';
  static const String settingsThemeLight = '浅色';
  static const String settingsThemeDark = '深色';
  static const String settingsThemeAuto = '跟随系统';
  static const String settingsLanguage = '语言';
  static const String settingsLanguageChinese = '中文';
  static const String settingsLanguageEnglish = 'English';
  static const String settingsStartup = '启动设置';
  static const String settingsStartupAuto = '自动启动';
  static const String settingsStartupPage = '启动页面';
  static const String settingsPerformance = '性能设置';
  static const String settingsMemoryLimit = '内存限制';
  static const String settingsCacheStrategy = '缓存策略';

  // TODO: i18n - 插件配置
  static const String settingsPluginsList = '插件列表';
  static const String settingsPluginsEnabled = '已启用';
  static const String settingsPluginsDisabled = '已禁用';
  static const String settingsPluginsPermissions = '权限设置';
  static const String settingsPluginsUpdates = '更新管理';
  static const String settingsPluginsStore = '插件商店';
  static const String settingsPluginsAutoUpdate = '自动更新';

  // TODO: i18n - 用户偏好
  static const String settingsInterface = '界面偏好';
  static const String settingsLayout = '布局';
  static const String settingsFontSize = '字体大小';
  static const String settingsFontSizeSmall = '小';
  static const String settingsFontSizeMedium = '中';
  static const String settingsFontSizeLarge = '大';
  static const String settingsInteraction = '交互偏好';
  static const String settingsShortcuts = '快捷键';
  static const String settingsGestures = '手势';
  static const String settingsPrivacy = '隐私设置';
  static const String settingsDataCollection = '数据收集';
  static const String settingsAnalytics = '分析统计';
  static const String settingsBackup = '备份设置';
  static const String settingsAutoBackup = '自动备份';
  static const String settingsCloudSync = '云同步';

  // TODO: i18n - 通用操作
  static const String save = '保存';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String ok = '确定';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String add = '添加';
  static const String remove = '移除';
  static const String enable = '启用';
  static const String disable = '禁用';
  static const String reset = '重置';
  static const String apply = '应用';

  // TODO: i18n - 状态信息
  static const String statusLoading = '加载中...';
  static const String statusSaving = '保存中...';
  static const String statusSuccess = '成功';
  static const String statusError = '错误';
  static const String statusWarning = '警告';
  static const String statusInfo = '信息';

  // TODO: i18n - 错误信息
  static const String errorGeneral = '发生未知错误';
  static const String errorNetwork = '网络连接错误';
  static const String errorPermission = '权限不足';
  static const String errorFileNotFound = '文件未找到';
  static const String errorInvalidInput = '输入无效';

  // TODO: i18n - 成功信息
  static const String successSaved = '保存成功';
  static const String successDeleted = '删除成功';
  static const String successUpdated = '更新成功';
  static const String successInstalled = '安装成功';

  // TODO: i18n - 选择选项标题
  static const String optionTitle = '选择';
  static const String optionCancel = '取消';
  static const String optionConfirm = '确认';
}
