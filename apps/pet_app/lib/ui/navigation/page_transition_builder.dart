/*
---------------------------------------------------------------
File name:          page_transition_builder.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.1 页面转场动画构建器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.1 - 实现页面转场动画、自定义转场效果;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'enhanced_navigation_manager.dart';

/// 自定义页面转场构建器
/// 
/// Phase 3.3.2.1 核心功能：
/// - 多种转场动画类型
/// - 自定义转场参数
/// - 平台适配转场
/// - 性能优化
class PageTransitionBuilder {
  /// 构建页面转场
  static Page<T> buildTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    PageTransitionConfig? config,
  }) {
    final transitionConfig = config ?? _getDefaultTransition(state.fullPath);
    
    switch (transitionConfig.type) {
      case PageTransitionType.none:
        return NoTransitionPage<T>(
          key: state.pageKey,
          child: child,
        );
        
      case PageTransitionType.fade:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: transitionConfig.curve,
              ),
              child: child,
            );
          },
          transitionDuration: transitionConfig.duration,
          reverseTransitionDuration: transitionConfig.reverseDuration,
        );
        
      case PageTransitionType.slide:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideDirection = transitionConfig.slideDirection ?? const Offset(1.0, 0.0);
            
            return SlideTransition(
              position: Tween<Offset>(
                begin: slideDirection,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: transitionConfig.curve,
              )),
              child: child,
            );
          },
          transitionDuration: transitionConfig.duration,
          reverseTransitionDuration: transitionConfig.reverseDuration,
        );
        
      case PageTransitionType.scale:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleBegin = transitionConfig.scaleBegin ?? 0.0;
            
            return ScaleTransition(
              scale: Tween<double>(
                begin: scaleBegin,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: transitionConfig.curve,
              )),
              child: child,
            );
          },
          transitionDuration: transitionConfig.duration,
          reverseTransitionDuration: transitionConfig.reverseDuration,
        );
        
      case PageTransitionType.rotation:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final rotationBegin = transitionConfig.rotationBegin ?? 0.25;
            
            return RotationTransition(
              turns: Tween<double>(
                begin: rotationBegin,
                end: 0.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: transitionConfig.curve,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: transitionConfig.duration,
          reverseTransitionDuration: transitionConfig.reverseDuration,
        );
        
      case PageTransitionType.custom:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 组合转场效果
            return _buildCombinedTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              transitionConfig,
            );
          },
          transitionDuration: transitionConfig.duration,
          reverseTransitionDuration: transitionConfig.reverseDuration,
        );
    }
  }

  /// 构建组合转场效果
  static Widget _buildCombinedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionConfig config,
  ) {
    Widget result = child;
    
    // 淡入效果
    result = FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
      child: result,
    );
    
    // 滑动效果
    if (config.slideDirection != null) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: config.slideDirection!,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: config.curve,
        )),
        child: result,
      );
    }
    
    // 缩放效果
    if (config.scaleBegin != null) {
      result = ScaleTransition(
        scale: Tween<double>(
          begin: config.scaleBegin!,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
        )),
        child: result,
      );
    }
    
    return result;
  }

  /// 获取默认转场配置
  static PageTransitionConfig _getDefaultTransition(String? path) {
    if (path == null) return PageTransitionConfig.fadeIn;
    
    // 根据路径确定转场类型
    if (path == '/') {
      return PageTransitionConfig.fadeIn;
    } else if (path.startsWith('/settings')) {
      return PageTransitionConfig.slideUp;
    } else if (path.contains('detail') || path.contains('edit')) {
      return PageTransitionConfig.slideLeft;
    } else {
      return PageTransitionConfig.slideLeft;
    }
  }

  /// 构建平台适配的转场
  static Page<T> buildPlatformTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    // 根据平台选择合适的转场
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
        return buildTransition<T>(
          context,
          state,
          child,
          config: PageTransitionConfig.slideLeft,
        );
        
      case TargetPlatform.android:
        return buildTransition<T>(
          context,
          state,
          child,
          config: PageTransitionConfig.fadeIn,
        );
        
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return buildTransition<T>(
          context,
          state,
          child,
          config: PageTransitionConfig.fadeIn,
        );
        
      default:
        return buildTransition<T>(
          context,
          state,
          child,
          config: PageTransitionConfig.fadeIn,
        );
    }
  }
}

/// 无转场页面
class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

/// 自定义转场页面
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool opaque;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      opaque: opaque,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      maintainState: maintainState,
    );
  }
}

/// 转场动画预设
class TransitionPresets {
  /// iOS风格滑动转场
  static const PageTransitionConfig iosSlide = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(1.0, 0.0),
    duration: Duration(milliseconds: 350),
    curve: Curves.easeInOut,
  );

  /// Android风格淡入转场
  static const PageTransitionConfig androidFade = PageTransitionConfig(
    type: PageTransitionType.fade,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeIn,
  );

  /// 桌面风格快速淡入
  static const PageTransitionConfig desktopFade = PageTransitionConfig(
    type: PageTransitionType.fade,
    duration: Duration(milliseconds: 150),
    curve: Curves.easeInOut,
  );

  /// 模态弹出效果
  static const PageTransitionConfig modalSlideUp = PageTransitionConfig(
    type: PageTransitionType.slide,
    slideDirection: Offset(0.0, 1.0),
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );

  /// 弹性缩放效果
  static const PageTransitionConfig elasticScale = PageTransitionConfig(
    type: PageTransitionType.scale,
    scaleBegin: 0.8,
    duration: Duration(milliseconds: 400),
    curve: Curves.elasticOut,
  );

  /// 组合转场效果
  static const PageTransitionConfig combined = PageTransitionConfig(
    type: PageTransitionType.custom,
    slideDirection: Offset(0.3, 0.0),
    scaleBegin: 0.9,
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );
}

/// 转场动画工具类
class TransitionUtils {
  /// 根据导航方向选择转场
  static PageTransitionConfig getDirectionalTransition(
    String? fromPath,
    String? toPath,
  ) {
    if (fromPath == null || toPath == null) {
      return PageTransitionConfig.fadeIn;
    }

    // 分析路径层级
    final fromDepth = fromPath.split('/').length;
    final toDepth = toPath.split('/').length;

    if (toDepth > fromDepth) {
      // 进入更深层级，从右滑入
      return PageTransitionConfig.slideLeft;
    } else if (toDepth < fromDepth) {
      // 返回上层，从左滑入
      return PageTransitionConfig.slideRight;
    } else {
      // 同级切换，淡入淡出
      return PageTransitionConfig.fadeIn;
    }
  }

  /// 根据设备性能调整转场
  static PageTransitionConfig adjustForPerformance(
    PageTransitionConfig config,
    BuildContext context,
  ) {
    // 在低性能设备上简化动画
    final mediaQuery = MediaQuery.of(context);
    final isLowPerformance = mediaQuery.devicePixelRatio < 2.0;

    if (isLowPerformance) {
      return PageTransitionConfig(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeIn,
      );
    }

    return config;
  }

  /// 检查是否应该禁用动画
  static bool shouldDisableAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
