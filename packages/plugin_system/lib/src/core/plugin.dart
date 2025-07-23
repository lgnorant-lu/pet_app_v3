/*
---------------------------------------------------------------
File name:          plugin.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件基类 (Plugin base class)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件基类 (Plugin base class);
---------------------------------------------------------------
*/
import 'dart:async';
import 'package:meta/meta.dart';

/// 支持的平台枚举
enum SupportedPlatform {
  /// Android平台
  android,

  /// iOS平台
  ios,

  /// Windows平台
  windows,

  /// macOS平台
  macos,

  /// Linux平台
  linux,

  /// Web平台
  web,
}

/// 插件类型枚举
enum PluginType {
  /// 系统级插件
  system,

  /// UI组件插件
  ui,

  /// 工具类插件
  tool,

  /// 游戏插件
  game,

  /// 主题插件
  theme,

  /// 小部件插件
  widget,

  /// 服务类插件
  service,
}

/// 插件权限类型 (统一Creative Workshop和Plugin System)
enum PluginPermission {
  /// 文件系统访问
  fileSystem('file_system', '文件系统访问', '允许插件读写文件和目录'),

  /// 网络访问
  network('network', '网络访问', '允许插件访问互联网'),

  /// 系统通知
  notifications('notifications', '系统通知', '允许插件发送系统通知'),

  /// 摄像头访问
  camera('camera', '摄像头访问', '允许插件使用摄像头'),

  /// 麦克风访问
  microphone('microphone', '麦克风访问', '允许插件使用麦克风'),

  /// 位置信息
  location('location', '位置信息', '允许插件获取设备位置'),

  /// 联系人访问
  contacts('contacts', '联系人访问', '允许插件访问联系人信息'),

  /// 日历访问
  calendar('calendar', '日历访问', '允许插件访问日历数据'),

  /// 照片访问
  photos('photos', '照片访问', '允许插件访问照片库'),

  /// 系统设置
  systemSettings('system_settings', '系统设置', '允许插件修改系统设置'),

  /// 后台运行
  backgroundExecution('background_execution', '后台运行', '允许插件在后台运行'),

  /// 设备信息
  deviceInfo('device_info', '设备信息', '允许插件获取设备信息'),

  /// 剪贴板访问
  clipboard('clipboard', '剪贴板访问', '允许插件访问剪贴板内容');

  const PluginPermission(this.id, this.displayName, this.description);

  /// 权限ID
  final String id;

  /// 显示名称
  final String displayName;

  /// 权限描述
  final String description;

  /// 是否为敏感权限
  bool get isSensitive {
    switch (this) {
      case PluginPermission.camera:
      case PluginPermission.microphone:
      case PluginPermission.location:
      case PluginPermission.contacts:
      case PluginPermission.photos:
      case PluginPermission.systemSettings:
        return true;
      default:
        return false;
    }
  }

  /// 是否为危险权限
  bool get isDangerous {
    switch (this) {
      case PluginPermission.systemSettings:
      case PluginPermission.fileSystem:
        return true;
      default:
        return false;
    }
  }

  /// 从ID获取权限类型
  static PluginPermission? fromId(String id) {
    for (final permission in PluginPermission.values) {
      if (permission.id == id) {
        return permission;
      }
    }
    return null;
  }
}

/// 插件状态枚举
enum PluginState {
  /// 未加载
  unloaded,

  /// 已加载
  loaded,

  /// 已初始化
  initialized,

  /// 已启动
  started,

  /// 已暂停
  paused,

  /// 已停止
  stopped,

  /// 错误状态
  error,
}

/// 插件依赖定义
@immutable
class PluginDependency {
  const PluginDependency({
    required this.pluginId,
    required this.versionConstraint,
    this.optional = false,
  });

  /// 依赖的插件ID
  final String pluginId;

  /// 版本约束
  final String versionConstraint;

  /// 是否为可选依赖
  final bool optional;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginDependency &&
          runtimeType == other.runtimeType &&
          pluginId == other.pluginId &&
          versionConstraint == other.versionConstraint &&
          optional == other.optional;

  @override
  int get hashCode =>
      pluginId.hashCode ^ versionConstraint.hashCode ^ optional.hashCode;

  @override
  String toString() =>
      'PluginDependency(pluginId: $pluginId, versionConstraint: $versionConstraint, optional: $optional)';
}

/// 插件基类 - 所有插件必须继承此类
abstract class Plugin {
  /// 插件唯一标识符
  String get id;

  /// 插件显示名称
  String get name;

  /// 插件版本号 (语义化版本)
  String get version;

  /// 插件描述
  String get description;

  /// 插件作者
  String get author;

  /// 插件类型
  PluginType get category;

  /// 所需权限列表
  List<PluginPermission> get requiredPermissions;

  /// 依赖的其他插件
  List<PluginDependency> get dependencies;

  /// 支持的平台
  List<SupportedPlatform> get supportedPlatforms;

  /// 插件初始化
  Future<void> initialize();

  /// 启动插件
  Future<void> start();

  /// 暂停插件
  Future<void> pause();

  /// 恢复插件
  Future<void> resume();

  /// 停止插件
  Future<void> stop();

  /// 销毁插件
  Future<void> dispose();

  /// 获取插件配置界面
  Object? getConfigWidget();

  /// 获取插件主界面
  Object getMainWidget();

  /// 处理插件间消息
  Future<dynamic> handleMessage(String action, Map<String, dynamic> data);

  /// 获取插件当前状态
  PluginState get currentState;

  /// 状态变化通知
  Stream<PluginState> get stateChanges;
}

/// 插件元数据
@immutable
class PluginMetadata {
  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    required this.requiredPermissions,
    required this.dependencies,
    required this.supportedPlatforms,
    this.homepage,
    this.repository,
    this.documentation,
    this.license,
    this.tags = const <String>[],
    this.minSdkVersion,
    this.maxSdkVersion,
  });

  /// 从Plugin实例创建元数据
  factory PluginMetadata.from(Plugin plugin) => PluginMetadata(
        id: plugin.id,
        name: plugin.name,
        version: plugin.version,
        description: plugin.description,
        author: plugin.author,
        category: plugin.category,
        requiredPermissions: plugin.requiredPermissions,
        dependencies: plugin.dependencies,
        supportedPlatforms: plugin.supportedPlatforms,
      );

  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final PluginType category;
  final List<PluginPermission> requiredPermissions;
  final List<PluginDependency> dependencies;
  final List<SupportedPlatform> supportedPlatforms;
  final String? homepage;
  final String? repository;
  final String? documentation;
  final String? license;
  final List<String> tags;
  final String? minSdkVersion;
  final String? maxSdkVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;

  @override
  String toString() =>
      'PluginMetadata(id: $id, name: $name, version: $version)';
}
