/*
---------------------------------------------------------------
File name:          permission_service.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件权限服务 - 集成权限管理器和用户授权流程
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 插件权限服务实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'permission_manager.dart';
import 'permission_dialog.dart';
import 'plugin_manager.dart';

/// 权限授权上下文
@immutable
class PermissionAuthorizationContext {
  const PermissionAuthorizationContext({
    required this.pluginId,
    required this.pluginName,
    required this.permission,
    this.reason,
    this.isDangerous = false,
  });

  /// 插件ID
  final String pluginId;
  
  /// 插件名称
  final String pluginName;
  
  /// 请求的权限
  final PluginPermission permission;
  
  /// 请求原因
  final String? reason;
  
  /// 是否为危险权限
  final bool isDangerous;
}

/// 插件权限服务
/// 
/// 提供完整的权限管理功能，包括权限检查、用户授权流程等
class PermissionService extends ChangeNotifier {
  PermissionService._();
  static final PermissionService _instance = PermissionService._();
  static PermissionService get instance => _instance;

  /// 权限管理器
  late final PermissionManager _permissionManager;
  
  /// 当前上下文（用于显示对话框）
  BuildContext? _context;
  
  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化权限服务
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _context = context;
    _permissionManager = PermissionManager.instance;
    await _permissionManager.initialize();
    
    // 设置用户授权回调
    _permissionManager.setUserAuthorizationCallback(_handleUserAuthorization);
    
    _isInitialized = true;
    debugPrint('权限服务已初始化');
  }

  /// 更新上下文
  void updateContext(BuildContext context) {
    _context = context;
  }

  /// 检查插件权限
  /// 
  /// [pluginId] 插件ID
  /// [permission] 权限
  bool hasPermission(String pluginId, PluginPermission permission) {
    return _permissionManager.hasPermission(pluginId, permission);
  }

  /// 请求单个权限
  /// 
  /// [pluginId] 插件ID
  /// [pluginName] 插件名称
  /// [permission] 权限
  /// [reason] 请求原因
  Future<PermissionAuthorizationResult> requestPermission(
    String pluginId,
    String pluginName,
    PluginPermission permission, {
    String? reason,
  }) async {
    if (!_isInitialized) {
      throw StateError('权限服务未初始化');
    }

    return await _permissionManager.requestPermission(
      pluginId,
      permission,
      reason: reason,
    );
  }

  /// 请求多个权限
  /// 
  /// [pluginId] 插件ID
  /// [pluginName] 插件名称
  /// [permissions] 权限列表
  /// [reason] 请求原因
  Future<PermissionRequestResult> requestPermissions(
    String pluginId,
    String pluginName,
    List<PluginPermission> permissions, {
    String? reason,
  }) async {
    if (!_isInitialized) {
      throw StateError('权限服务未初始化');
    }

    return await _permissionManager.validatePermissions(pluginId, permissions);
  }

  /// 撤销权限
  /// 
  /// [pluginId] 插件ID
  /// [permission] 权限，如果为null则撤销所有权限
  Future<void> revokePermission(String pluginId, [PluginPermission? permission]) async {
    await _permissionManager.revokePermission(pluginId, permission);
    notifyListeners();
  }

  /// 获取插件权限列表
  /// 
  /// [pluginId] 插件ID
  List<PluginPermission> getPluginPermissions(String pluginId) {
    return _permissionManager.getPluginPermissions(pluginId);
  }

  /// 获取插件权限授权结果
  /// 
  /// [pluginId] 插件ID
  List<PermissionAuthorizationResult> getPluginPermissionResults(String pluginId) {
    return _permissionManager.getPluginPermissionResults(pluginId);
  }

  /// 设置权限策略
  /// 
  /// [permission] 权限
  /// [policy] 策略
  void setPermissionPolicy(PluginPermission permission, PermissionPolicy policy) {
    _permissionManager.setPermissionPolicy(permission, policy);
    notifyListeners();
  }

  /// 获取权限策略
  /// 
  /// [permission] 权限
  PermissionPolicy getPermissionPolicy(PluginPermission permission) {
    return _permissionManager.getPermissionPolicy(permission);
  }

  /// 清理插件权限
  /// 
  /// [pluginId] 插件ID
  void cleanupPluginPermissions(String pluginId) {
    _permissionManager.cleanupPluginPermissions(pluginId);
    notifyListeners();
  }

  /// 清理过期权限
  void cleanupExpiredPermissions() {
    _permissionManager.cleanupExpiredPermissions();
    notifyListeners();
  }

  /// 获取权限统计信息
  Map<String, dynamic> getPermissionStatistics() {
    return _permissionManager.getPermissionStatistics();
  }

  /// 检查权限是否为危险权限
  bool isDangerousPermission(PluginPermission permission) {
    // 定义危险权限列表
    const dangerousPermissions = {
      PluginPermission.fileSystem,
      PluginPermission.network,
      PluginPermission.camera,
      PluginPermission.microphone,
      PluginPermission.location,
    };
    
    return dangerousPermissions.contains(permission);
  }

  /// 检查权限组合是否危险
  bool isDangerousPermissionCombination(List<PluginPermission> permissions) {
    final permissionSet = permissions.toSet();
    
    // 文件系统 + 网络访问
    if (permissionSet.contains(PluginPermission.fileSystem) &&
        permissionSet.contains(PluginPermission.network)) {
      return true;
    }
    
    // 相机 + 网络访问
    if (permissionSet.contains(PluginPermission.camera) &&
        permissionSet.contains(PluginPermission.network)) {
      return true;
    }
    
    // 麦克风 + 网络访问
    if (permissionSet.contains(PluginPermission.microphone) &&
        permissionSet.contains(PluginPermission.network)) {
      return true;
    }
    
    // 位置 + 网络访问
    if (permissionSet.contains(PluginPermission.location) &&
        permissionSet.contains(PluginPermission.network)) {
      return true;
    }
    
    return false;
  }

  /// 获取插件显示名称
  String getPluginDisplayName(String pluginId) {
    // TODO: 从插件清单或注册表获取插件名称
    // 这里先使用简单的格式化
    return pluginId
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// 处理用户授权
  Future<bool> _handleUserAuthorization(
    String pluginId,
    PluginPermission permission,
    String? reason,
  ) async {
    if (_context == null) {
      debugPrint('权限服务：无可用上下文，拒绝权限请求');
      return false;
    }

    try {
      final pluginName = getPluginDisplayName(pluginId);
      final isDangerous = isDangerousPermission(permission);

      final result = await PermissionDialog.show(
        _context!,
        pluginId: pluginId,
        pluginName: pluginName,
        permission: permission,
        reason: reason,
        isDangerous: isDangerous,
      );

      return result ?? false;
    } catch (e) {
      debugPrint('权限服务：显示授权对话框失败: $e');
      return false;
    }
  }

  /// 批量检查权限
  Map<PluginPermission, bool> checkPermissions(
    String pluginId,
    List<PluginPermission> permissions,
  ) {
    final result = <PluginPermission, bool>{};
    
    for (final permission in permissions) {
      result[permission] = hasPermission(pluginId, permission);
    }
    
    return result;
  }

  /// 获取缺失的权限
  List<PluginPermission> getMissingPermissions(
    String pluginId,
    List<PluginPermission> requiredPermissions,
  ) {
    final missingPermissions = <PluginPermission>[];
    
    for (final permission in requiredPermissions) {
      if (!hasPermission(pluginId, permission)) {
        missingPermissions.add(permission);
      }
    }
    
    return missingPermissions;
  }

  /// 检查插件是否有足够权限
  bool hasAllPermissions(
    String pluginId,
    List<PluginPermission> requiredPermissions,
  ) {
    return getMissingPermissions(pluginId, requiredPermissions).isEmpty;
  }

  /// 格式化权限列表为可读文本
  String formatPermissionList(List<PluginPermission> permissions) {
    if (permissions.isEmpty) return '无';
    
    return permissions.map((p) => p.displayName).join('、');
  }

  /// 获取权限风险等级
  String getPermissionRiskLevel(PluginPermission permission) {
    if (isDangerousPermission(permission)) {
      return '高风险';
    } else {
      return '低风险';
    }
  }

  /// 获取权限组合风险等级
  String getPermissionCombinationRiskLevel(List<PluginPermission> permissions) {
    if (isDangerousPermissionCombination(permissions)) {
      return '高风险';
    } else if (permissions.any(isDangerousPermission)) {
      return '中风险';
    } else {
      return '低风险';
    }
  }
}
