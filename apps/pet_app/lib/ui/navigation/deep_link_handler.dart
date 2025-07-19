/*
---------------------------------------------------------------
File name:          deep_link_handler.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.1 深度链接处理器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.1 - 实现深度链接解析、路由匹配、参数处理;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart'; // 暂时未使用
import 'dart:async';
import '../../core/communication/unified_message_bus.dart';

/// 深度链接类型
enum DeepLinkType {
  /// 应用内路由
  internal,

  /// 外部链接
  external,

  /// 分享链接
  share,

  /// 通知链接
  notification,

  /// 自定义协议
  custom,
}

/// 深度链接信息
class DeepLinkInfo {
  final String originalUrl;
  final DeepLinkType type;
  final String scheme;
  final String host;
  final String path;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const DeepLinkInfo({
    required this.originalUrl,
    required this.type,
    required this.scheme,
    required this.host,
    required this.path,
    required this.queryParameters,
    required this.metadata,
    required this.timestamp,
  });

  /// 是否为有效的应用内链接
  bool get isValidAppLink => type == DeepLinkType.internal && path.isNotEmpty;

  /// 获取目标路由路径
  String get targetRoute => path.startsWith('/') ? path : '/$path';

  @override
  String toString() {
    return 'DeepLinkInfo(url: $originalUrl, type: $type, path: $path)';
  }
}

/// 深度链接处理结果
class DeepLinkResult {
  final bool success;
  final String? targetRoute;
  final Map<String, dynamic>? parameters;
  final String? error;
  final DeepLinkInfo? linkInfo;

  const DeepLinkResult({
    required this.success,
    this.targetRoute,
    this.parameters,
    this.error,
    this.linkInfo,
  });

  /// 成功结果
  factory DeepLinkResult.success({
    required String targetRoute,
    Map<String, dynamic>? parameters,
    DeepLinkInfo? linkInfo,
  }) {
    return DeepLinkResult(
      success: true,
      targetRoute: targetRoute,
      parameters: parameters,
      linkInfo: linkInfo,
    );
  }

  /// 失败结果
  factory DeepLinkResult.failure({
    required String error,
    DeepLinkInfo? linkInfo,
  }) {
    return DeepLinkResult(success: false, error: error, linkInfo: linkInfo);
  }
}

/// 深度链接处理器
///
/// Phase 3.3.2.1 核心功能：
/// - URL解析和验证
/// - 路由匹配和参数提取
/// - 自定义协议支持
/// - 安全性检查
/// - 链接分享功能
class DeepLinkHandler {
  DeepLinkHandler._();

  static final DeepLinkHandler _instance = DeepLinkHandler._();
  static DeepLinkHandler get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 支持的应用协议
  final Set<String> _supportedSchemes = {'petapp', 'https', 'http'};

  /// 支持的主机名
  final Set<String> _supportedHosts = {'petapp.local', 'app.petapp.com'};

  /// 路由映射规则
  final Map<String, String> _routeMappings = {};

  /// 深度链接历史
  final List<DeepLinkInfo> _linkHistory = [];

  /// 链接处理统计
  final Map<String, int> _linkStats = {};

  /// 初始化深度链接处理器
  void initialize() {
    _registerDefaultMappings();
    _setupPlatformChannels();
    debugPrint('DeepLinkHandler initialized');
  }

  /// 注册默认路由映射
  void _registerDefaultMappings() {
    _routeMappings.addAll({
      '/home': '/',
      '/main': '/',
      '/workshop': '/workshop',
      '/creative': '/workshop',
      '/notes': '/notes',
      '/tasks': '/notes',
      '/punch': '/punch-in',
      '/time': '/punch-in',
      '/settings': '/settings',
      '/config': '/settings',
      '/about': '/about',
      '/help': '/help',
    });
  }

  /// 设置平台通道
  void _setupPlatformChannels() {
    // 这里可以设置平台特定的深度链接处理
    // 例如Android的Intent处理、iOS的URL Scheme处理等
  }

  /// 处理深度链接
  Future<DeepLinkResult> handleDeepLink(String url) async {
    try {
      // 解析URL
      final linkInfo = _parseUrl(url);

      // 记录链接历史
      _addToHistory(linkInfo);

      // 验证链接
      if (!_validateLink(linkInfo)) {
        return DeepLinkResult.failure(
          error: 'Invalid or unsupported link',
          linkInfo: linkInfo,
        );
      }

      // 处理不同类型的链接
      switch (linkInfo.type) {
        case DeepLinkType.internal:
          return await _handleInternalLink(linkInfo);
        case DeepLinkType.external:
          return await _handleExternalLink(linkInfo);
        case DeepLinkType.share:
          return await _handleShareLink(linkInfo);
        case DeepLinkType.notification:
          return await _handleNotificationLink(linkInfo);
        case DeepLinkType.custom:
          return await _handleCustomLink(linkInfo);
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling deep link: $e');
      debugPrint('Stack trace: $stackTrace');

      return DeepLinkResult.failure(error: 'Failed to process link: $e');
    }
  }

  /// 解析URL
  DeepLinkInfo _parseUrl(String url) {
    final uri = Uri.parse(url);
    final timestamp = DateTime.now();

    // 确定链接类型
    DeepLinkType type;
    if (_supportedSchemes.contains(uri.scheme) &&
        _supportedHosts.contains(uri.host)) {
      type = DeepLinkType.internal;
    } else if (uri.scheme == 'petapp') {
      type = DeepLinkType.custom;
    } else if (uri.queryParameters.containsKey('share')) {
      type = DeepLinkType.share;
    } else if (uri.queryParameters.containsKey('notification')) {
      type = DeepLinkType.notification;
    } else {
      type = DeepLinkType.external;
    }

    return DeepLinkInfo(
      originalUrl: url,
      type: type,
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path,
      queryParameters: uri.queryParameters,
      metadata: {
        'userAgent': 'PetApp/3.0',
        'timestamp': timestamp.toIso8601String(),
      },
      timestamp: timestamp,
    );
  }

  /// 验证链接
  bool _validateLink(DeepLinkInfo linkInfo) {
    // 检查协议
    if (!_supportedSchemes.contains(linkInfo.scheme)) {
      return false;
    }

    // 检查路径
    if (linkInfo.path.isEmpty && linkInfo.type == DeepLinkType.internal) {
      return false;
    }

    // 安全性检查
    if (_containsMaliciousContent(linkInfo.originalUrl)) {
      return false;
    }

    return true;
  }

  /// 检查恶意内容
  bool _containsMaliciousContent(String url) {
    final maliciousPatterns = [
      'javascript:',
      'data:',
      '<script',
      'eval(',
      'document.cookie',
    ];

    final lowerUrl = url.toLowerCase();
    return maliciousPatterns.any((pattern) => lowerUrl.contains(pattern));
  }

  /// 处理应用内链接
  Future<DeepLinkResult> _handleInternalLink(DeepLinkInfo linkInfo) async {
    // 映射路径
    String targetRoute = _mapRoute(linkInfo.path);

    // 提取参数
    final parameters = <String, dynamic>{};
    parameters.addAll(linkInfo.queryParameters);

    // 处理路径参数
    final pathParams = _extractPathParameters(linkInfo.path);
    parameters.addAll(pathParams);

    // 发送导航事件
    _messageBus.publishEvent('deep_link_handler', 'internal_link_handled', {
      'originalUrl': linkInfo.originalUrl,
      'targetRoute': targetRoute,
      'parameters': parameters,
      'timestamp': linkInfo.timestamp.toIso8601String(),
    }, priority: MessagePriority.high);

    _updateStats('internal_success');

    return DeepLinkResult.success(
      targetRoute: targetRoute,
      parameters: parameters,
      linkInfo: linkInfo,
    );
  }

  /// 处理外部链接
  Future<DeepLinkResult> _handleExternalLink(DeepLinkInfo linkInfo) async {
    // 外部链接通常需要在浏览器中打开
    _updateStats('external_handled');

    return DeepLinkResult.failure(
      error: 'External links not supported in app navigation',
      linkInfo: linkInfo,
    );
  }

  /// 处理分享链接
  Future<DeepLinkResult> _handleShareLink(DeepLinkInfo linkInfo) async {
    final shareData = linkInfo.queryParameters['share'];
    if (shareData == null) {
      return DeepLinkResult.failure(
        error: 'Invalid share link',
        linkInfo: linkInfo,
      );
    }

    // 解析分享数据
    final parameters = {
      'shareData': shareData,
      'shareType': linkInfo.queryParameters['type'] ?? 'general',
    };

    _updateStats('share_handled');

    return DeepLinkResult.success(
      targetRoute: '/share',
      parameters: parameters,
      linkInfo: linkInfo,
    );
  }

  /// 处理通知链接
  Future<DeepLinkResult> _handleNotificationLink(DeepLinkInfo linkInfo) async {
    final notificationId = linkInfo.queryParameters['notification'];
    if (notificationId == null) {
      return DeepLinkResult.failure(
        error: 'Invalid notification link',
        linkInfo: linkInfo,
      );
    }

    final parameters = {
      'notificationId': notificationId,
      'action': linkInfo.queryParameters['action'] ?? 'view',
    };

    _updateStats('notification_handled');

    return DeepLinkResult.success(
      targetRoute: '/notifications',
      parameters: parameters,
      linkInfo: linkInfo,
    );
  }

  /// 处理自定义协议链接
  Future<DeepLinkResult> _handleCustomLink(DeepLinkInfo linkInfo) async {
    // petapp://action/param1/param2?query=value
    final pathSegments = linkInfo.path
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (pathSegments.isEmpty) {
      return DeepLinkResult.failure(
        error: 'Invalid custom protocol link',
        linkInfo: linkInfo,
      );
    }

    final action = pathSegments.first;
    final parameters = <String, dynamic>{};
    parameters.addAll(linkInfo.queryParameters);

    // 根据动作确定目标路由
    String targetRoute;
    switch (action) {
      case 'open':
        targetRoute = pathSegments.length > 1 ? '/${pathSegments[1]}' : '/';
        break;
      case 'create':
        targetRoute = '/workshop';
        parameters['action'] = 'create';
        break;
      case 'edit':
        targetRoute = '/workshop';
        parameters['action'] = 'edit';
        if (pathSegments.length > 1) {
          parameters['itemId'] = pathSegments[1];
        }
        break;
      default:
        targetRoute = '/';
    }

    _updateStats('custom_handled');

    return DeepLinkResult.success(
      targetRoute: targetRoute,
      parameters: parameters,
      linkInfo: linkInfo,
    );
  }

  /// 映射路由
  String _mapRoute(String path) {
    return _routeMappings[path] ?? path;
  }

  /// 提取路径参数
  Map<String, dynamic> _extractPathParameters(String path) {
    final parameters = <String, dynamic>{};

    // 简单的路径参数提取
    // 例如：/item/123 -> {itemId: 123}
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.length >= 2) {
      switch (segments[0]) {
        case 'item':
          parameters['itemId'] = segments[1];
          break;
        case 'module':
          parameters['moduleId'] = segments[1];
          break;
        case 'user':
          parameters['userId'] = segments[1];
          break;
      }
    }

    return parameters;
  }

  /// 添加到历史记录
  void _addToHistory(DeepLinkInfo linkInfo) {
    _linkHistory.insert(0, linkInfo);

    // 保持最近100条记录
    if (_linkHistory.length > 100) {
      _linkHistory.removeLast();
    }
  }

  /// 更新统计
  void _updateStats(String action) {
    _linkStats[action] = (_linkStats[action] ?? 0) + 1;
  }

  /// 生成分享链接
  String generateShareLink({
    required String route,
    Map<String, String>? parameters,
    String? title,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'https',
      host: 'app.petapp.com',
      path: route,
      queryParameters: {
        if (parameters != null) ...parameters,
        'share': 'true',
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    return uri.toString();
  }

  /// 注册路由映射
  void registerRouteMapping(String from, String to) {
    _routeMappings[from] = to;
  }

  /// 获取链接历史
  List<DeepLinkInfo> get linkHistory => List.unmodifiable(_linkHistory);

  /// 获取链接统计
  Map<String, int> get linkStats => Map.unmodifiable(_linkStats);

  /// 清理资源
  void dispose() {
    _linkHistory.clear();
    _linkStats.clear();
    _routeMappings.clear();

    debugPrint('DeepLinkHandler disposed');
  }
}
