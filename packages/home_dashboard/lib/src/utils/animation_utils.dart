/*
---------------------------------------------------------------
File name:          animation_utils.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        动画工具类 - Phase 5.0.7.3 交互体验优化
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.3 - 实现交互体验优化
    - 响应式布局
    - 动画反馈
    - 拖拽排序
    - 手势交互
---------------------------------------------------------------
*/

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 动画工具类
class AnimationUtils {
  AnimationUtils._();

  /// 默认动画时长
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// 快速动画时长
  static const Duration fastDuration = Duration(milliseconds: 150);

  /// 慢速动画时长
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// 弹性动画曲线
  static const Curve elasticCurve = Curves.elasticOut;

  /// 缓动动画曲线
  static const Curve easeCurve = Curves.easeInOut;

  /// 快速缓动曲线
  static const Curve fastEaseCurve = Curves.easeOut;

  /// 创建淡入动画
  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = easeCurve,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建滑入动画
  static Widget slideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = easeCurve,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建缩放动画
  static Widget scaleIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = elasticCurve,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建组合动画（淡入 + 滑入）
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = easeCurve,
    Offset slideBegin = const Offset(0, 0.5),
    double fadeBegin = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset.lerp(slideBegin, Offset.zero, value)!,
          child: Opacity(
            opacity: Tween(begin: fadeBegin, end: 1.0).transform(value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 创建弹跳动画
  static Widget bounceIn({
    required Widget child,
    Duration duration = slowDuration,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.bounceOut,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建旋转动画
  static Widget rotateIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = easeCurve,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 0.5, // 半圈旋转
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 创建延迟动画
  static Widget delayedAnimation({
    required Widget child,
    required Duration delay,
    Duration duration = defaultDuration,
    Curve curve = easeCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: delay + duration,
      curve: Interval(
        delay.inMilliseconds / (delay + duration).inMilliseconds,
        1.0,
        curve: curve,
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 创建列表项动画
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration duration = defaultDuration,
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return delayedAnimation(
      delay: Duration(milliseconds: delay.inMilliseconds * index),
      duration: duration,
      child: child,
    );
  }

  /// 创建悬停效果
  static Widget hoverEffect({
    required Widget child,
    double scale = 1.05,
    Duration duration = fastDuration,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// 创建点击反馈动画
  static Widget tapFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = fastDuration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return GestureDetector(
          onTapDown: (_) {
            // 触发缩放动画
          },
          onTapUp: (_) {
            onTap();
          },
          onTapCancel: () {
            // 恢复原始大小
          },
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 创建加载动画
  static Widget loadingAnimation({
    required Widget child,
    bool isLoading = false,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (!isLoading) return child;

    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159, // 完整旋转
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建脉冲动画
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final scale = minScale +
            (maxScale - minScale) * (0.5 + 0.5 * (value * 2 - 1).abs());
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 创建摇摆动画
  static Widget shakeAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double amplitude = 5.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final offset = amplitude * math.sin(value * 4 * math.pi) * (1 - value);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// 动画包装器组件
class AnimatedWrapper extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画类型
  final AnimationType type;

  /// 动画时长
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  /// 延迟时间
  final Duration delay;

  /// 是否自动开始
  final bool autoStart;

  const AnimatedWrapper({
    super.key,
    required this.child,
    this.type = AnimationType.fadeIn,
    this.duration = AnimationUtils.defaultDuration,
    this.curve = AnimationUtils.easeCurve,
    this.delay = Duration.zero,
    this.autoStart = true,
  });

  @override
  State<AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<AnimatedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.type) {
          case AnimationType.fadeIn:
            return Opacity(
              opacity: _animation.value,
              child: widget.child,
            );
          case AnimationType.slideUp:
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
          case AnimationType.scaleIn:
            return Transform.scale(
              scale: _animation.value,
              child: widget.child,
            );
          case AnimationType.rotateIn:
            return Transform.rotate(
              angle: (1 - _animation.value) * 0.5,
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
        }
      },
    );
  }
}

/// 动画类型枚举
enum AnimationType {
  /// 淡入
  fadeIn,

  /// 向上滑入
  slideUp,

  /// 缩放进入
  scaleIn,

  /// 旋转进入
  rotateIn,
}
