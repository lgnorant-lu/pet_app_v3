/*
---------------------------------------------------------------
File name:          unified_permission_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        统一插件权限管理器 - 集成Creative Workshop完整实现
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 1.1.1 - 统一权限管理系统，集成Creative Workshop实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/core/plugin.dart';

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
class PermissionAuthorizationResult {
  const PermissionAuthorizationResult({
    required this.permission,
    required this.granted,
    this.reason,
    this.timestamp,
    this.expiresAt,
  });

  /// 权限类型
  final PluginPermission permission;

  /// 是否授权
  final bool granted;

  /// 授权原因
  final String? reason;

  /// 授权时间
  final DateTime? timestamp;

  /// 过期时间
  final DateTime? expiresAt;

  /// 是否有效（未过期）
  bool get isValid {
    if (!granted) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 是否即将过期（7天内）
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }
}

/// 权限请求结果
class PermissionRequestResult {
  const PermissionRequestResult({
    required this.pluginId,
    required this.permissions,
    required this.allGranted,
    this.deniedPermissions = const [],
    this.dangerousPermissions = const [],
  });

  /// 插件ID
  final String pluginId;

  /// 所有权限结果
  final List<PermissionAuthorizationResult> permissions;

  /// 是否全部授权
  final bool allGranted;

  /// 被拒绝的权限
  final List<PluginPermission> deniedPermissions;

  /// 危险权限组合
  final List<PluginPermission> dangerousPermissions;
}

/// 统一权限管理器
///
/// 集成Creative Workshop的完整权限管理实现，提供企业级权限控制功能
class UnifiedPermissionManager extends ChangeNotifier {
  UnifiedPermissionManager._();
  static final UnifiedPermissionManager _instance =
      UnifiedPermissionManager._();

  /// 获取单例实例
  static UnifiedPermissionManager get instance => _instance;

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
    debugPrint('统一权限管理器已初始化');
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

    // 检查危险权限组合
    final dangerousCombination =
        _checkDangerousPermissionCombination(permissions);
    if (dangerousCombination != null) {
      debugPrint(
          '检测到危险权限组合: ${dangerousCombination.map((p) => p.displayName).join(', ')}');
    }

    // 验证每个权限
    final results = <PermissionAuthorizationResult>[];
    final deniedPermissions = <PluginPermission>[];

    for (final permission in permissions) {
      final result = await _validateSinglePermission(pluginId, permission);
      results.add(result);

      if (!result.granted) {
        deniedPermissions.add(permission);
      }
    }

    final allGranted = deniedPermissions.isEmpty;

    return PermissionRequestResult(
      pluginId: pluginId,
      permissions: results,
      allGranted: allGranted,
      deniedPermissions: deniedPermissions,
      dangerousPermissions: dangerousCombination?.toList() ?? [],
    );
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

  /// 检查插件是否有权限
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限
  bool hasPermission(String pluginId, PluginPermission permission) {
    final auth = getPermissionAuthorization(pluginId, permission);
    return auth != null && auth.isValid;
  }

  /// 获取权限授权信息
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限
  PermissionAuthorizationResult? getPermissionAuthorization(
    String pluginId,
    PluginPermission permission,
  ) {
    return _pluginPermissions[pluginId]?[permission];
  }

  /// 撤销权限
  ///
  /// [pluginId] 插件ID
  /// [permission] 权限，如果为null则撤销所有权限
  Future<void> revokePermission(String pluginId,
      [PluginPermission? permission]) async {
    if (permission != null) {
      _pluginPermissions[pluginId]?.remove(permission);
      debugPrint('撤销权限: $pluginId -> ${permission.displayName}');
    } else {
      _pluginPermissions.remove(pluginId);
      debugPrint('撤销所有权限: $pluginId');
    }

    notifyListeners();
  }

  /// 清理插件权限
  ///
  /// [pluginId] 插件ID
  void cleanupPluginPermissions(String pluginId) {
    _pluginPermissions.remove(pluginId);
    debugPrint('清理插件权限: $pluginId');
    notifyListeners();
  }

  /// 清理过期权限
  void cleanupExpiredPermissions() {
    var cleanedCount = 0;

    _pluginPermissions.forEach((pluginId, permissions) {
      final expiredPermissions = <PluginPermission>[];

      permissions.forEach((permission, auth) {
        if (!auth.isValid) {
          expiredPermissions.add(permission);
        }
      });

      for (final permission in expiredPermissions) {
        permissions.remove(permission);
        cleanedCount++;
      }
    });

    // 移除空的插件权限记录
    _pluginPermissions.removeWhere((_, permissions) => permissions.isEmpty);

    if (cleanedCount > 0) {
      debugPrint('清理过期权限: $cleanedCount 个');
      notifyListeners();
    }
  }

  /// 获取权限统计信息
  Map<String, dynamic> getPermissionStatistics() {
    var totalPermissions = 0;
    var expiredPermissions = 0;
    var expiringSoonPermissions = 0;
    final permissionCounts = <PluginPermission, int>{};

    _pluginPermissions.forEach((_, permissions) {
      permissions.forEach((permission, auth) {
        totalPermissions++;

        if (!auth.isValid) {
          expiredPermissions++;
        } else if (auth.isExpiringSoon) {
          expiringSoonPermissions++;
        }

        permissionCounts[permission] = (permissionCounts[permission] ?? 0) + 1;
      });
    });

    return {
      'totalPlugins': _pluginPermissions.length,
      'totalPermissions': totalPermissions,
      'expiredPermissions': expiredPermissions,
      'expiringSoonPermissions': expiringSoonPermissions,
      'permissionCounts':
          permissionCounts.map((k, v) => MapEntry(k.displayName, v)),
    };
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
    // 文件系统 + 网络访问 = 可能的数据泄露
    _dangerousPermissionCombinations.add({
      PluginPermission.fileSystem,
      PluginPermission.network,
    });

    // 相机 + 网络访问 = 可能的隐私泄露
    _dangerousPermissionCombinations.add({
      PluginPermission.camera,
      PluginPermission.network,
    });

    // 麦克风 + 网络访问 = 可能的隐私泄露
    _dangerousPermissionCombinations.add({
      PluginPermission.microphone,
      PluginPermission.network,
    });

    // 位置 + 网络访问 = 可能的位置跟踪
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
      reason: reason ?? '自动授权',
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

    debugPrint('拒绝权限: $pluginId -> ${permission.displayName}, 原因: $reason');
    return result;
  }

  /// 询问用户权限
  Future<PermissionAuthorizationResult> _askUserPermission(
    String pluginId,
    PluginPermission permission,
    String? reason,
  ) async {
    if (_userAuthorizationCallback == null) {
      debugPrint('无用户授权回调，默认拒绝权限: ${permission.displayName}');
      return _denyPermission(pluginId, permission, '无用户授权回调');
    }

    try {
      final userGranted = await _userAuthorizationCallback!(
        pluginId,
        permission,
        reason,
      );

      if (userGranted) {
        return _grantPermission(pluginId, permission, '用户授权');
      } else {
        return _denyPermission(pluginId, permission, '用户拒绝');
      }
    } catch (e) {
      debugPrint('用户授权回调失败: $e');
      return _denyPermission(pluginId, permission, '授权回调失败');
    }
  }
}
