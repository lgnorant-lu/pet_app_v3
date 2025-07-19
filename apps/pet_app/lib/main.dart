/*
---------------------------------------------------------------
File name:          main.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Pet App V3 主应用入口 - Phase 3.1 应用生命周期管理
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现应用生命周期管理、状态持久化、模块加载顺序管理;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/lifecycle/app_lifecycle_manager.dart';
import 'core/persistence/app_state_manager.dart';
import 'core/modules/module_loader.dart';
import 'core/error/error_recovery_manager.dart';

/// Pet App V3 应用入口点
///
/// Phase 3.1: 应用生命周期管理
/// - 应用启动流程优化
/// - 状态持久化系统
/// - 模块加载顺序管理
/// - 错误恢复机制
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置全局错误处理
  _setupGlobalErrorHandling();

  try {
    // Phase 3.1: 应用生命周期管理
    await _initializeApplication();

    // 启动主应用
    runApp(const PetAppV3());
  } catch (error, stackTrace) {
    // 错误恢复机制
    await _handleStartupError(error, stackTrace);
  }
}

/// 初始化应用程序
///
/// Phase 3.1 核心功能：
/// 1. 应用启动流程优化
/// 2. 状态持久化系统初始化
/// 3. 模块加载顺序管理
/// 4. 错误恢复机制准备
Future<void> _initializeApplication() async {
  final stopwatch = Stopwatch()..start();

  try {
    _log('info', '🚀 Pet App V3 启动开始 - Phase 3.1');

    // 1. 初始化应用生命周期管理器
    await AppLifecycleManager.instance.initialize();
    _log('info', '✅ 应用生命周期管理器初始化完成');

    // 2. 初始化状态持久化系统
    await AppStateManager.instance.initialize();
    _log('info', '✅ 状态持久化系统初始化完成');

    // 3. 初始化模块加载器
    await ModuleLoader.instance.initialize();
    _log('info', '✅ 模块加载器初始化完成');

    // 4. 初始化错误恢复管理器
    await ErrorRecoveryManager.instance.initialize();
    _log('info', '✅ 错误恢复管理器初始化完成');

    stopwatch.stop();
    _log('info', '🎉 Pet App V3 初始化完成，耗时: ${stopwatch.elapsedMilliseconds}ms');
  } catch (e, stackTrace) {
    stopwatch.stop();
    _log(
      'severe',
      '❌ Pet App V3 初始化失败，耗时: ${stopwatch.elapsedMilliseconds}ms',
      e,
      stackTrace,
    );
    rethrow;
  }
}

/// 设置全局错误处理
///
/// 捕获Flutter框架和Dart运行时的未处理异常
void _setupGlobalErrorHandling() {
  // Flutter框架错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    _log('severe', '🔥 Flutter框架错误', details.exception, details.stack);

    // 在调试模式下显示错误详情
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // 生产模式下记录错误并尝试恢复
      ErrorRecoveryManager.instance.handleFlutterError(details);
    }
  };

  // Dart运行时错误处理
  PlatformDispatcher.instance.onError = (error, stack) {
    _log('severe', '🔥 Dart运行时错误', error, stack);

    if (!kDebugMode) {
      // 生产模式下尝试错误恢复
      ErrorRecoveryManager.instance.handleDartError(error, stack);
    }

    return true; // 表示错误已处理
  };
}

/// 处理启动错误
///
/// 当应用初始化失败时的错误恢复机制
Future<void> _handleStartupError(Object error, StackTrace stackTrace) async {
  _log('severe', '💥 应用启动失败', error, stackTrace);

  try {
    // 尝试启动错误恢复应用
    runApp(
      ErrorRecoveryApp(
        error: error.toString(),
        stackTrace: stackTrace.toString(),
      ),
    );
  } catch (e) {
    // 如果连错误恢复应用都无法启动，显示最基本的错误界面
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Pet App V3 启动失败',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '错误: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 日志记录工具函数
///
/// 统一的日志格式，支持不同级别的日志记录
void _log(
  String level,
  String message, [
  Object? error,
  StackTrace? stackTrace,
]) {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '[$timestamp] [$level] $message';

  if (kDebugMode) {
    print(logMessage);
    if (error != null) {
      print('Error: $error');
    }
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  // TODO: 在生产环境中，这里应该发送到日志服务
}

/// 错误恢复应用
///
/// 当主应用无法启动时显示的备用界面
class ErrorRecoveryApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const ErrorRecoveryApp({
    super.key,
    required this.error,
    this.stackTrace = '',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet App V3 - 错误恢复',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('应用启动失败'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Pet App V3 启动时遇到错误',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '错误详情:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(error),
                      if (stackTrace.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          '堆栈跟踪:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(stackTrace, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 重启应用
                    SystemNavigator.pop();
                  },
                  child: const Text('重启应用'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
