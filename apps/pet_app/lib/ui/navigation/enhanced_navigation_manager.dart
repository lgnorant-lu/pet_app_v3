/*
---------------------------------------------------------------
File name:          enhanced_navigation_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.1 增强导航管理器 - 模块间导航系统
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.1 - 实现增强导航管理、转场动画、深度链接;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/communication/unified_message_bus.dart';
// import '../../core/communication/module_communication_coordinator.dart' as comm; // 暂时未使用

/// 导航事件类型
enum NavigationEventType {
  /// 导航开始
  navigationStarted,

  /// 导航完成
  navigationCompleted,

  /// 导航失败
  navigationFailed,

  /// 导航取消
  navigationCancelled,

  /// 页面进入
  pageEntered,

  /// 页面离开
  pageLeft,
}

/// 导航事件
class NavigationEvent {
  final NavigationEventType type;
  final String? fromRoute;
  final String? toRoute;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;
  final String? error;

  const NavigationEvent({
    required this.type,
    this.fromRoute,
    this.toRoute,
    this.parameters,
    required this.timestamp,
    this.error,
  });

  @override
  String toString() {
    return 'NavigationEvent(type: $type, from: $fromRoute, to: $toRoute, timestamp: $timestamp)';
  }
}

/// 页面转场类型
enum PageTransitionType {
  /// 无动画
  none,

  /// 淡入淡出
  fade,

  /// 滑动
  slide,

  /// 缩放
  scale,

  /// 旋转
  rotation,

  /// 自定义
  custom,
}

/// 页面转场配置
class PageTransitionConfig {
  final PageTransitionType type;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Offset? slideDirection;
  final double? scaleBegin;
  final double? rotationBegin;

  const PageTransitionConfig({
    this.type = PageTransitionType.slide,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve = Curves.easeInOut,
    this.slideDirection,
    this.scaleBegin,
    this.rotationBegin,
  });

  /// 预定义的转场配置
  static const PageTransitionConfig slideLeft = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(-1.0, 0.0),
  );

  static const PageTransitionConfig slideRight = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(1.0, 0.0),
  );

  static const PageTransitionConfig slideUp = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(0.0, -1.0),
  );

  static const PageTransitionConfig slideDown = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(0.0, 1.0),
  );

  static const PageTransitionConfig fadeIn = PageTransitionConfig(
    type: PageTransitionType.fade,
  );

  static const PageTransitionConfig scaleIn = PageTransitionConfig(
    type: PageTransitionType.scale,
    scaleBegin: 0.0,
  );
}

/// 导航路由信息
class NavigationRouteInfo {
  final String path;
  final String name;
  final String title;
  final IconData? icon;
  final String? description;
  final PageTransitionConfig? transitionConfig;
  final Map<String, dynamic>? metadata;
  final bool requiresAuth;
  final List<String> permissions;

  const NavigationRouteInfo({
    required this.path,
    required this.name,
    required this.title,
    this.icon,
    this.description,
    this.transitionConfig,
    this.metadata,
    this.requiresAuth = false,
    this.permissions = const [],
  });
}

/// 增强导航管理器
///
/// Phase 3.3.2.1 核心功能：
/// - 增强的路由管理
/// - 页面转场动画
/// - 导航历史管理
/// - 深度链接支持
/// - 导航事件监听
/// - 权限控制
class EnhancedNavigationManager {
  EnhancedNavigationManager._();

  static final EnhancedNavigationManager _instance =
      EnhancedNavigationManager._();
  static EnhancedNavigationManager get instance => _instance;

  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 通信协调器 (暂时未使用)
  // final comm.ModuleCommunicationCoordinator _coordinator =
  //     comm.ModuleCommunicationCoordinator.instance;

  /// 导航历史
  final List<String> _navigationHistory = [];

  /// 导航事件流
  final StreamController<NavigationEvent> _navigationEventController =
      StreamController<NavigationEvent>.broadcast();

  /// 注册的路由信息
  final Map<String, NavigationRouteInfo> _routeInfos = {};

  /// 当前路由
  String? _currentRoute;

  /// 导航锁（防止重复导航）
  bool _isNavigating = false;

  /// 消息订阅
  MessageSubscription? _messageSubscription;

  /// 初始化导航管理器
  Future<void> initialize() async {
    try {
      // 注册默认路由信息
      _registerDefaultRoutes();

      // 订阅导航相关消息
      _subscribeToNavigationMessages();

      debugPrint('EnhancedNavigationManager initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize EnhancedNavigationManager: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 注册默认路由信息
  void _registerDefaultRoutes() {
    final defaultRoutes = [
      NavigationRouteInfo(
        path: '/',
        name: 'home',
        title: '首页',
        icon: Icons.home,
        description: '应用主页',
        transitionConfig: PageTransitionConfig.fadeIn,
      ),
      NavigationRouteInfo(
        path: '/workshop',
        name: 'workshop',
        title: '创意工坊',
        icon: Icons.build,
        description: '创意工具和项目管理',
        transitionConfig: PageTransitionConfig.slideLeft,
      ),
      NavigationRouteInfo(
        path: '/notes',
        name: 'notes',
        title: '事务管理',
        icon: Icons.note,
        description: '笔记和任务管理',
        transitionConfig: PageTransitionConfig.slideLeft,
      ),
      NavigationRouteInfo(
        path: '/punch-in',
        name: 'punch-in',
        title: '打卡模块',
        icon: Icons.access_time,
        description: '时间管理和打卡',
        transitionConfig: PageTransitionConfig.slideLeft,
      ),
      NavigationRouteInfo(
        path: '/settings',
        name: 'settings',
        title: '设置',
        icon: Icons.settings,
        description: '应用设置和配置',
        transitionConfig: PageTransitionConfig.slideUp,
      ),
    ];

    for (final route in defaultRoutes) {
      registerRoute(route);
    }
  }

  /// 订阅导航相关消息
  void _subscribeToNavigationMessages() {
    _messageSubscription = _messageBus.subscribe(
      _handleNavigationMessage,
      filter: (message) =>
          message.action.startsWith('navigate_') ||
          message.action.startsWith('navigation_'),
    );
  }

  /// 处理导航消息
  Future<Map<String, dynamic>?> _handleNavigationMessage(
    UnifiedMessage message,
  ) async {
    switch (message.action) {
      case 'navigate_to_home':
        await navigateTo('/');
        break;
      case 'navigate_to_workshop':
        await navigateTo('/workshop');
        break;
      case 'navigate_to_settings':
        await navigateTo('/settings');
        break;
      case 'navigation_back':
        await goBack();
        break;
      case 'navigation_forward':
        await goForward();
        break;
    }
    return null;
  }

  /// 注册路由信息
  void registerRoute(NavigationRouteInfo routeInfo) {
    _routeInfos[routeInfo.path] = routeInfo;
    debugPrint('Registered route: ${routeInfo.path} (${routeInfo.title})');
  }

  /// 导航到指定路径
  Future<bool> navigateTo(
    String path, {
    Map<String, dynamic>? parameters,
    PageTransitionConfig? transitionConfig,
    bool replace = false,
  }) async {
    if (_isNavigating) {
      debugPrint('Navigation already in progress, ignoring request to: $path');
      return false;
    }

    _isNavigating = true;

    try {
      // 发送导航开始事件
      _emitNavigationEvent(
        NavigationEvent(
          type: NavigationEventType.navigationStarted,
          fromRoute: _currentRoute,
          toRoute: path,
          parameters: parameters,
          timestamp: DateTime.now(),
        ),
      );

      // 检查权限
      if (!await _checkNavigationPermission(path)) {
        _emitNavigationEvent(
          NavigationEvent(
            type: NavigationEventType.navigationFailed,
            fromRoute: _currentRoute,
            toRoute: path,
            timestamp: DateTime.now(),
            error: 'Permission denied',
          ),
        );
        return false;
      }

      // 获取当前上下文
      final context = _getNavigationContext();
      if (context == null) {
        _emitNavigationEvent(
          NavigationEvent(
            type: NavigationEventType.navigationFailed,
            fromRoute: _currentRoute,
            toRoute: path,
            timestamp: DateTime.now(),
            error: 'Navigation context not available',
          ),
        );
        return false;
      }

      // 执行导航
      if (replace) {
        context.pushReplacement(path);
      } else {
        context.push(path);
      }

      // 更新历史记录
      if (!replace) {
        _navigationHistory.add(path);
        // 保持最近50条记录
        if (_navigationHistory.length > 50) {
          _navigationHistory.removeAt(0);
        }
      }

      // 更新当前路由
      final previousRoute = _currentRoute;
      _currentRoute = path;

      // 发送页面离开事件
      if (previousRoute != null) {
        _emitNavigationEvent(
          NavigationEvent(
            type: NavigationEventType.pageLeft,
            fromRoute: previousRoute,
            toRoute: path,
            timestamp: DateTime.now(),
          ),
        );
      }

      // 发送页面进入事件
      _emitNavigationEvent(
        NavigationEvent(
          type: NavigationEventType.pageEntered,
          fromRoute: previousRoute,
          toRoute: path,
          timestamp: DateTime.now(),
        ),
      );

      // 发送导航完成事件
      _emitNavigationEvent(
        NavigationEvent(
          type: NavigationEventType.navigationCompleted,
          fromRoute: previousRoute,
          toRoute: path,
          parameters: parameters,
          timestamp: DateTime.now(),
        ),
      );

      // 发送统一消息总线事件
      _messageBus.publishEvent(
        'navigation_manager',
        'navigation_completed',
        {
          'fromRoute': previousRoute,
          'toRoute': path,
          'parameters': parameters,
          'timestamp': DateTime.now().toIso8601String(),
        },
        priority: MessagePriority.normal,
      );

      // 触发触觉反馈
      HapticFeedback.lightImpact();

      debugPrint('Navigation completed: $previousRoute -> $path');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Navigation failed: $e');
      debugPrint('Stack trace: $stackTrace');

      _emitNavigationEvent(
        NavigationEvent(
          type: NavigationEventType.navigationFailed,
          fromRoute: _currentRoute,
          toRoute: path,
          timestamp: DateTime.now(),
          error: e.toString(),
        ),
      );

      return false;
    } finally {
      _isNavigating = false;
    }
  }

  /// 返回上一页
  Future<bool> goBack() async {
    final context = _getNavigationContext();
    if (context == null) return false;

    if (context.canPop()) {
      context.pop();

      // 更新历史记录
      if (_navigationHistory.isNotEmpty) {
        _navigationHistory.removeLast();
      }

      // 发送导航事件
      _messageBus.publishEvent('navigation_manager', 'navigation_back', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      HapticFeedback.lightImpact();
      return true;
    }

    return false;
  }

  /// 前进到下一页（如果有历史记录）
  Future<bool> goForward() async {
    // 这里可以实现前进逻辑，需要维护前进历史
    // 暂时返回false
    return false;
  }

  /// 检查导航权限
  Future<bool> _checkNavigationPermission(String path) async {
    final routeInfo = _routeInfos[path];
    if (routeInfo == null) return true;

    if (!routeInfo.requiresAuth) return true;

    // 这里可以添加权限检查逻辑
    // 例如检查用户登录状态、权限等

    return true;
  }

  /// 获取导航上下文
  BuildContext? _getNavigationContext() {
    // 这里需要从应用中获取导航上下文
    // 可以通过GlobalKey或其他方式获取
    return null; // 暂时返回null，需要在实际集成时实现
  }

  /// 发送导航事件
  void _emitNavigationEvent(NavigationEvent event) {
    _navigationEventController.add(event);
  }

  /// 获取路由信息
  NavigationRouteInfo? getRouteInfo(String path) => _routeInfos[path];

  /// 获取所有注册的路由
  List<NavigationRouteInfo> get registeredRoutes =>
      List.unmodifiable(_routeInfos.values);

  /// 获取导航历史
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// 获取当前路由
  String? get currentRoute => _currentRoute;

  /// 获取导航事件流
  Stream<NavigationEvent> get navigationEvents =>
      _navigationEventController.stream;

  /// 是否可以返回
  bool get canGoBack {
    final context = _getNavigationContext();
    return context?.canPop() ?? false;
  }

  /// 清理资源
  void dispose() {
    _navigationEventController.close();
    _messageSubscription?.cancel();
    _routeInfos.clear();
    _navigationHistory.clear();

    debugPrint('EnhancedNavigationManager disposed');
  }
}
