/*
---------------------------------------------------------------
File name:          permission_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件权限管理器 - 处理权限检查、授权、撤销等操作
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.3 - 插件权限管理器实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'plugin_manager.dart';

/// 权限策略
enum PermissionPolicy {
  /// 自动允许
  allow,

  /// 自动拒绝
  deny,

  /// 询问用户
  ask,
}

/// 权限授权结果
@immutable
class PermissionAuthorizationResult {
  const PermissionAuthorizationResult({
    required this.permission,
    required this.granted,
    required this.timestamp,
    this.reason,
    this.expiresAt,
  });

  /// 权限类型
  final PluginPermission permission;

  /// 是否授权
  final bool granted;

  /// 授权时间
  final DateTime timestamp;

  /// 授权/拒绝原因
  final String? reason;

  /// 过期时间
  final DateTime? expiresAt;

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 是否有效
  bool get isValid => granted && !isExpired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionAuthorizationResult &&
          runtimeType == other.runtimeType &&
          permission == other.permission &&
          granted == other.granted &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      permission.hashCode ^ granted.hashCode ^ timestamp.hashCode;

  @override
  String toString() =>
      'PermissionAuthorizationResult(permission: $permission, granted: $granted)';
}

/// 权限请求结果
@immutable
class PermissionRequestResult {
  const PermissionRequestResult({
    required this.success,
    required this.results,
    this.error,
  });

  /// 是否成功
  final bool success;

  /// 权限授权结果列表
  final List<PermissionAuthorizationResult> results;

  /// 错误信息
  final String? error;

  /// 创建成功结果
  factory PermissionRequestResult.success(
      List<PermissionAuthorizationResult> results) {
    return PermissionRequestResult(
      success: true,
      results: results,
    );
  }

  /// 创建失败结果
  factory PermissionRequestResult.failure(String error) {
    return PermissionRequestResult(
      success: false,
      results: [],
      error: error,
    );
  }

  /// 是否所有权限都被授权
  bool get allGranted => results.every((r) => r.granted);

  /// 获取被授权的权限
  List<PluginPermission> get grantedPermissions =>
      results.where((r) => r.granted).map((r) => r.permission).toList();

  /// 获取被拒绝的权限
  List<PluginPermission> get deniedPermissions =>
      results.where((r) => !r.granted).map((r) => r.permission).toList();
}

/// 权限管理器
///
/// 负责插件权限的验证、授权和管理
class PermissionManager extends ChangeNotifier {
  PermissionManager._();
  static final PermissionManager _instance = PermissionManager._();
  static PermissionManager get instance => _instance;

  /// 权限策略配置
  final Map<PluginPermission, PermissionPolicy> _permissionPolicies = {};

  /// 插件权限授权记录
  final Map<String, Map<PluginPermission, PermissionAuthorizationResult>>
      _pluginPermissions = {};

  /// 危险权限组合
  final Set<Set<PluginPermission>> _dangerousPermissionCombinations = {};

  /// 用户授权回调
  Future<bool> Function(
          String pluginId, PluginPermission permission, String? reason)?
      _userAuthorizationCallback;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化权限管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    _initializeDefaultPolicies();
    _initializeDangerousPermissionCombinations();

    _isInitialized = true;
    debugPrint('权限管理器已初始化');
  }

  /// 设置用户授权回调
  void setUserAuthorizationCallback(
    Future<bool> Function(
            String pluginId, PluginPermission permission, String? reason)?
        callback,
  ) {
    _userAuthorizationCallback = callback;
  }

  /// 验证插件权限
  ///
  /// [pluginId] 插件ID
  /// [permissions] 需要验证的权限列表
  Future<PermissionRequestResult> validatePermissions(
    String pluginId,
    List<PluginPermission> permissions,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 检查危险权限组合
      final dangerousCombination =
          _checkDangerousPermissionCombination(permissions);
      if (dangerousCombination != null) {
        return PermissionRequestResult.failure(
          '权限组合存在安全风险: ${dangerousCombination.map((p) => p.displayName).join(', ')}',
        );
      }

      final results = <PermissionAuthorizationResult>[];

      for (final permission in permissions) {
        final result = await _validateSinglePermission(pluginId, permission);
        results.add(result);
      }

      return PermissionRequestResult.success(results);
    } catch (e) {
      return PermissionRequestResult.failure('权限验证失败: $e');
    }
  }

  /// 请求权限授权
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限
  /// [reason] 请求原因
  Future<PermissionAuthorizationResult> requestPermission(
    String pluginId,
    PluginPermission permission, {
    String? reason,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 检查是否已有有效授权
    final existingAuth = getPermissionAuthorization(pluginId, permission);
    if (existingAuth != null && existingAuth.isValid) {
      return existingAuth;
    }

    final policy = _getPermissionPolicy(permission);

    switch (policy) {
      case PermissionPolicy.allow:
        return _grantPermission(pluginId, permission, reason);
      case PermissionPolicy.deny:
        return _denyPermission(pluginId, permission, '权限策略拒绝');
      case PermissionPolicy.ask:
        return await _askUserPermission(pluginId, permission, reason);
    }
  }

  /// 撤销权限
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限，如果为null则撤销所有权限
  Future<void> revokePermission(String pluginId,
      [PluginPermission? permission]) async {
    if (permission == null) {
      _pluginPermissions.remove(pluginId);
      debugPrint('已撤销插件 $pluginId 的所有权限');
    } else {
      _pluginPermissions[pluginId]?.remove(permission);
      debugPrint('已撤销插件 $pluginId 的权限: ${permission.displayName}');
    }

    notifyListeners();
  }

  /// 检查插件是否有指定权限
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限
  bool hasPermission(String pluginId, PluginPermission permission) {
    final auth = getPermissionAuthorization(pluginId, permission);
    return auth != null && auth.isValid;
  }

  /// 获取插件权限授权信息
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限
  PermissionAuthorizationResult? getPermissionAuthorization(
      String pluginId, PluginPermission permission) {
    return _pluginPermissions[pluginId]?[permission];
  }

  /// 获取插件的所有权限
  ///
  /// [pluginId] 插件ID
  List<PluginPermission> getPluginPermissions(String pluginId) {
    final pluginPerms = _pluginPermissions[pluginId];
    if (pluginPerms == null) return [];

    return pluginPerms.entries
        .where((entry) => entry.value.isValid)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取插件的所有权限授权结果
  ///
  /// [pluginId] 插件ID
  List<PermissionAuthorizationResult> getPluginPermissionResults(
      String pluginId) {
    final pluginPerms = _pluginPermissions[pluginId];
    if (pluginPerms == null) return [];

    return pluginPerms.values.toList();
  }

  /// 设置权限策略
  ///
  /// [permission] 权限
  /// [policy] 策略
  void setPermissionPolicy(
      PluginPermission permission, PermissionPolicy policy) {
    _permissionPolicies[permission] = policy;
    debugPrint('设置权限策略: ${permission.displayName} -> $policy');
    notifyListeners();
  }

  /// 获取权限策略
  ///
  /// [permission] 权限
  PermissionPolicy getPermissionPolicy(PluginPermission permission) {
    return _getPermissionPolicy(permission);
  }

  /// 清理插件权限
  ///
  /// [pluginId] 插件ID
  void cleanupPluginPermissions(String pluginId) {
    _pluginPermissions.remove(pluginId);
    debugPrint('已清理插件 $pluginId 的权限记录');
    notifyListeners();
  }

  /// 清理过期权限
  void cleanupExpiredPermissions() {
    int cleanedCount = 0;

    _pluginPermissions.forEach((pluginId, permissions) {
      final expiredPermissions = permissions.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();

      for (final permission in expiredPermissions) {
        permissions.remove(permission);
        cleanedCount++;
      }
    });

    if (cleanedCount > 0) {
      debugPrint('已清理 $cleanedCount 个过期权限');
      notifyListeners();
    }
  }

  /// 获取权限统计信息
  Map<String, dynamic> getPermissionStatistics() {
    final stats = <String, dynamic>{};

    // 统计各权限的使用情况
    final permissionCounts = <PluginPermission, int>{};
    for (final permissions in _pluginPermissions.values) {
      for (final entry in permissions.entries) {
        if (entry.value.isValid) {
          permissionCounts[entry.key] = (permissionCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    stats['totalPlugins'] = _pluginPermissions.length;
    stats['permissionCounts'] =
        permissionCounts.map((k, v) => MapEntry(k.name, v));
    stats['totalPermissions'] =
        permissionCounts.values.fold(0, (a, b) => a + b);

    return stats;
  }

  /// 初始化默认权限策略
  void _initializeDefaultPolicies() {
    // 文件系统和网络访问需要用户确认
    _permissionPolicies[PluginPermission.fileSystem] = PermissionPolicy.ask;
    _permissionPolicies[PluginPermission.network] = PermissionPolicy.ask;

    // 相机和麦克风需要用户确认
    _permissionPolicies[PluginPermission.camera] = PermissionPolicy.ask;
    _permissionPolicies[PluginPermission.microphone] = PermissionPolicy.ask;

    // 位置信息需要用户确认
    _permissionPolicies[PluginPermission.location] = PermissionPolicy.ask;

    // 通知和剪贴板默认允许
    _permissionPolicies[PluginPermission.notifications] =
        PermissionPolicy.allow;
    _permissionPolicies[PluginPermission.clipboard] = PermissionPolicy.allow;

    // 设备信息默认允许
    _permissionPolicies[PluginPermission.deviceInfo] = PermissionPolicy.allow;
  }

  /// 初始化危险权限组合
  void _initializeDangerousPermissionCombinations() {
    // 文件系统 + 网络访问组合需要特别注意
    _dangerousPermissionCombinations.add({
      PluginPermission.fileSystem,
      PluginPermission.network,
    });

    // 相机 + 网络访问组合需要特别注意
    _dangerousPermissionCombinations.add({
      PluginPermission.camera,
      PluginPermission.network,
    });

    // 麦克风 + 网络访问组合需要特别注意
    _dangerousPermissionCombinations.add({
      PluginPermission.microphone,
      PluginPermission.network,
    });

    // 位置 + 网络访问组合需要特别注意
    _dangerousPermissionCombinations.add({
      PluginPermission.location,
      PluginPermission.network,
    });
  }

  /// 检查危险权限组合
  Set<PluginPermission>? _checkDangerousPermissionCombination(
      List<PluginPermission> permissions) {
    final permissionSet = permissions.toSet();

    for (final dangerousCombination in _dangerousPermissionCombinations) {
      if (dangerousCombination.every((p) => permissionSet.contains(p))) {
        return dangerousCombination;
      }
    }

    return null;
  }

  /// 验证单个权限
  Future<PermissionAuthorizationResult> _validateSinglePermission(
    String pluginId,
    PluginPermission permission,
  ) async {
    // 检查是否已有有效授权
    final existingAuth = getPermissionAuthorization(pluginId, permission);
    if (existingAuth != null && existingAuth.isValid) {
      return existingAuth;
    }

    // 根据策略处理
    return await requestPermission(pluginId, permission);
  }

  /// 获取权限策略
  PermissionPolicy _getPermissionPolicy(PluginPermission permission) {
    return _permissionPolicies[permission] ?? PermissionPolicy.ask;
  }

  /// 授予权限
  PermissionAuthorizationResult _grantPermission(
    String pluginId,
    PluginPermission permission,
    String? reason,
  ) {
    final result = PermissionAuthorizationResult(
      permission: permission,
      granted: true,
      reason: reason,
      timestamp: DateTime.now(),
    );

    _pluginPermissions.putIfAbsent(pluginId, () => {});
    _pluginPermissions[pluginId]![permission] = result;

    debugPrint('授予权限: $pluginId -> ${permission.displayName}');
    notifyListeners();

    return result;
  }

  /// 拒绝权限
  PermissionAuthorizationResult _denyPermission(
    String pluginId,
    PluginPermission permission,
    String reason,
  ) {
    final result = PermissionAuthorizationResult(
      permission: permission,
      granted: false,
      reason: reason,
      timestamp: DateTime.now(),
    );

    debugPrint('拒绝权限: $pluginId -> ${permission.displayName} ($reason)');

    return result;
  }

  /// 询问用户权限
  Future<PermissionAuthorizationResult> _askUserPermission(
    String pluginId,
    PluginPermission permission,
    String? reason,
  ) async {
    if (_userAuthorizationCallback == null) {
      // 如果没有设置用户授权回调，默认拒绝
      return _denyPermission(pluginId, permission, '无用户授权回调');
    }

    try {
      final userGranted =
          await _userAuthorizationCallback!(pluginId, permission, reason);

      if (userGranted) {
        return _grantPermission(pluginId, permission, '用户授权');
      } else {
        return _denyPermission(pluginId, permission, '用户拒绝');
      }
    } catch (e) {
      return _denyPermission(pluginId, permission, '用户授权失败: $e');
    }
  }
}
