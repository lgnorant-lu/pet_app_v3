/*
---------------------------------------------------------------
File name:          plugin_exceptions.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        插件异常 (Plugin exceptions)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 插件异常 (Plugin exceptions);
---------------------------------------------------------------
*/

/// 插件系统异常基类
abstract class PluginException implements Exception {
  const PluginException(this.message, [this.pluginId]);

  /// 错误消息
  final String message;
  
  /// 相关的插件ID
  final String? pluginId;

  @override
  String toString() {
    if (pluginId != null) {
      return '$runtimeType: $message (Plugin: $pluginId)';
    }
    return '$runtimeType: $message';
  }
}

/// 插件未找到异常
class PluginNotFoundException extends PluginException {
  const PluginNotFoundException(String pluginId)
      : super('Plugin not found', pluginId);
}

/// 插件已存在异常
class PluginAlreadyExistsException extends PluginException {
  const PluginAlreadyExistsException(String pluginId)
      : super('Plugin already exists', pluginId);
}

/// 插件依赖异常
class PluginDependencyException extends PluginException {
  const PluginDependencyException(String pluginId, String dependencyId)
      : super('Missing dependency: $dependencyId', pluginId);
}

/// 循环依赖异常
class CircularDependencyException extends PluginException {
  const CircularDependencyException(String pluginId)
      : super('Circular dependency detected', pluginId);
}

/// 插件版本不兼容异常
class PluginVersionIncompatibleException extends PluginException {
  const PluginVersionIncompatibleException(String pluginId, String requiredVersion, String actualVersion)
      : super('Version incompatible: required $requiredVersion, got $actualVersion', pluginId);
}

/// 插件权限异常
class PluginPermissionException extends PluginException {
  const PluginPermissionException(String pluginId, String permission)
      : super('Permission denied: $permission', pluginId);
}

/// 权限未声明异常
class PermissionNotDeclaredException extends PluginException {
  const PermissionNotDeclaredException(String pluginId, String permission)
      : super('Permission not declared: $permission', pluginId);
}

/// 插件状态异常
class PluginStateException extends PluginException {
  const PluginStateException(String pluginId, String currentState, String expectedState)
      : super('Invalid state: expected $expectedState, got $currentState', pluginId);
}

/// 插件加载异常
class PluginLoadException extends PluginException {
  const PluginLoadException(String pluginId, String reason)
      : super('Failed to load plugin: $reason', pluginId);
}

/// 插件初始化异常
class PluginInitializationException extends PluginException {
  const PluginInitializationException(String pluginId, String reason)
      : super('Failed to initialize plugin: $reason', pluginId);
}

/// 插件执行超时异常
class PluginTimeoutException extends PluginException {
  const PluginTimeoutException(String pluginId)
      : super('Plugin execution timeout', pluginId);
}

/// 插件资源超限异常
class PluginResourceLimitException extends PluginException {
  const PluginResourceLimitException(String pluginId, String resource, String limit)
      : super('Resource limit exceeded: $resource > $limit', pluginId);
}

/// 插件配置异常
class PluginConfigurationException extends PluginException {
  const PluginConfigurationException(String pluginId, String reason)
      : super('Configuration error: $reason', pluginId);
}

/// 插件通信异常
class PluginCommunicationException extends PluginException {
  const PluginCommunicationException(String pluginId, String targetId, String reason)
      : super('Communication failed with $targetId: $reason', pluginId);
}

/// 插件平台不支持异常
class PluginPlatformNotSupportedException extends PluginException {
  const PluginPlatformNotSupportedException(String pluginId, String platform)
      : super('Platform not supported: $platform', pluginId);
}

/// 插件API版本不兼容异常
class PluginApiVersionIncompatibleException extends PluginException {
  const PluginApiVersionIncompatibleException(String pluginId, String apiVersion)
      : super('API version incompatible: $apiVersion', pluginId);
}
