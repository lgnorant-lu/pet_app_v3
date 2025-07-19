/*
---------------------------------------------------------------
File name:          splash_screen.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        启动画面 - Phase 3.1 UI组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现启动画面、加载动画、进度显示;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// 启动画面
///
/// Phase 3.1 功能：
/// - 显示应用Logo和名称
/// - 加载进度指示器
/// - 优雅的动画效果
/// - 错误状态显示
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Logo动画控制器
  late AnimationController _logoController;

  /// 文字动画控制器
  late AnimationController _textController;

  /// 进度动画控制器
  late AnimationController _progressController;

  /// Logo缩放动画
  late Animation<double> _logoScale;

  /// Logo透明度动画
  late Animation<double> _logoOpacity;

  /// 文字滑入动画
  late Animation<Offset> _textSlide;

  /// 文字透明度动画
  late Animation<double> _textOpacity;

  /// 进度值动画
  late Animation<double> _progressValue;

  /// 当前加载状态
  String _loadingStatus = '正在启动 Pet App V3...';

  /// 是否显示错误
  bool _hasError = false;

  /// 错误信息
  String _errorMessage = '';

  /// Timer列表，用于清理
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    // 清理所有Timer
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // 清理动画控制器
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    // Logo动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 文字动画控制器
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Logo缩放动画
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Logo透明度动画
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // 文字滑入动画
    _textSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // 文字透明度动画
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // 进度值动画
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  /// 开始动画
  void _startAnimations() {
    // 启动Logo动画
    _logoController.forward();

    // 延迟启动文字动画
    _timers.add(
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _textController.forward();
        }
      }),
    );

    // 延迟启动进度动画
    _timers.add(
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _progressController.forward();
        }
      }),
    );

    // 模拟加载过程
    _simulateLoading();
  }

  /// 模拟加载过程
  void _simulateLoading() {
    final loadingSteps = [
      '初始化应用框架...',
      '加载插件系统...',
      '启动创意工坊...',
      '准备用户界面...',
      '完成初始化...',
    ];

    for (int i = 0; i < loadingSteps.length; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 600 * (i + 1)), () {
          if (mounted) {
            setState(() {
              _loadingStatus = loadingSteps[i];
            });
          }
        }),
      );
    }
  }

  /// 显示错误状态
  void showError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo区域
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 应用名称
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'Pet App V3',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '万物皆插件的跨平台应用框架',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // 加载状态区域
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasError) ...[
                      // 错误状态
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '启动失败',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // 重试逻辑
                          setState(() {
                            _hasError = false;
                            _errorMessage = '';
                            _loadingStatus = '正在重新启动...';
                          });
                          _startAnimations();
                        },
                        child: const Text('重试'),
                      ),
                    ] else ...[
                      // 正常加载状态
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              // 进度条
                              LinearProgressIndicator(
                                value: _progressValue.value,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 加载状态文字
                              Text(
                                _loadingStatus,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              // 进度百分比
                              Text(
                                '${(_progressValue.value * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // 版本信息
              Text(
                'Version 3.1.0 - Phase 3.1',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),

              if (kDebugMode) ...[
                const SizedBox(height: 8),
                Text(
                  'Debug Mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Logo
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.pets,
        size: 64,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
