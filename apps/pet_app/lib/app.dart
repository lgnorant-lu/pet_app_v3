/*
---------------------------------------------------------------
File name:          app.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Pet App V3 主应用组件 - Phase 3.1 应用生命周期管理
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现主应用组件，集成插件系统和模块管理;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Phase 2.9.3: 逐步启用模块导入进行验证
import 'package:plugin_system/plugin_system.dart';
import 'package:creative_workshop/creative_workshop.dart';
// TODO: 修复缺失文件后启用
// import 'package:home_dashboard/home_dashboard.dart';
// import 'package:app_manager/app_manager.dart';
// import 'package:settings_system/settings_system.dart';

// Phase 5.0.4: Communication System 模块导入
import 'package:communication_system/communication_system.dart' as comm;

import 'core/lifecycle/app_lifecycle_manager.dart';
import 'core/persistence/app_state_manager.dart';
import 'core/modules/module_loader.dart';
import 'ui/main_navigation.dart';
import 'ui/splash_screen.dart';

/// Pet App V3 主应用组件
///
/// Phase 3.1 核心功能：
/// - 集成插件系统
/// - 模块生命周期管理
/// - 状态持久化
/// - 响应式UI适配
class PetAppV3 extends StatefulWidget {
  const PetAppV3({super.key});

  @override
  State<PetAppV3> createState() => _PetAppV3State();
}

class _PetAppV3State extends State<PetAppV3> with WidgetsBindingObserver {
  /// 应用初始化状态
  bool _isInitialized = false;

  /// 初始化错误信息
  String? _initializationError;

  /// 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;

  /// 当前语言环境
  Locale _locale = const Locale('zh', 'CN');

  @override
  void initState() {
    super.initState();

    // 注册应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);

    // 初始化应用模块
    _initializeApp();
  }

  @override
  void dispose() {
    // 移除应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 通知应用生命周期管理器
    AppLifecycleManager.instance.handleAppLifecycleChange(state);
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      _log('info', '🚀 开始初始化Pet App V3主应用');

      // 1. 加载持久化状态
      await _loadPersistedState();

      // 2. 初始化核心模块
      await _initializeCoreModules();

      // 3. 加载插件
      await _loadPlugins();

      setState(() {
        _isInitialized = true;
      });

      _log('info', '✅ Pet App V3主应用初始化完成');
    } catch (e, stackTrace) {
      _log('severe', '❌ Pet App V3主应用初始化失败', e, stackTrace);

      setState(() {
        _initializationError = e.toString();
      });
    }
  }

  /// 加载持久化状态
  Future<void> _loadPersistedState() async {
    final stateManager = AppStateManager.instance;

    // 加载主题设置
    final themeMode = await stateManager.getThemeMode();
    if (themeMode != null) {
      setState(() {
        _themeMode = themeMode;
      });
    }

    // 加载语言设置
    final locale = await stateManager.getLocale();
    if (locale != null) {
      setState(() {
        _locale = locale;
      });
    }

    _log('info', '✅ 持久化状态加载完成');
  }

  /// 初始化核心模块
  Future<void> _initializeCoreModules() async {
    final moduleLoader = ModuleLoader.instance;

    // 按顺序加载核心模块
    await moduleLoader.loadModule('plugin_system');
    await moduleLoader.loadModule('creative_workshop');
    await moduleLoader.loadModule('home_dashboard');
    await moduleLoader.loadModule('app_manager');
    await moduleLoader.loadModule('settings_system');

    _log('info', '✅ 核心模块加载完成');
  }

  /// 加载插件
  Future<void> _loadPlugins() async {
    try {
      _log('info', '开始加载插件系统');

      // 1. 初始化统一消息总线和通信协调器
      await _initializeCommunicationSystem();

      // 2. 初始化插件注册中心
      PluginRegistry.instance; // 确保插件注册中心初始化
      _log('info', '✅ 插件注册中心初始化完成');

      // 3. 初始化插件加载器
      PluginLoader.instance; // 确保插件加载器初始化
      _log('info', '✅ 插件加载器初始化完成');

      // 4. 加载Creative Workshop内置插件
      await _loadCreativeWorkshopPlugins();

      _log('info', '✅ 插件加载完成');
    } catch (e, stackTrace) {
      _log('severe', '插件加载失败', e, stackTrace);
      // 插件加载失败不应该阻止应用启动
    }
  }

  /// 初始化通信系统
  Future<void> _initializeCommunicationSystem() async {
    try {
      _log('info', '初始化统一消息总线');

      // 获取通信协调器实例
      final coordinator = comm.ModuleCommunicationCoordinator.instance;

      // 初始化跨模块事件路由器
      final eventRouter = comm.CrossModuleEventRouter.instance;
      await eventRouter.initialize();
      _log('info', '✅ 跨模块事件路由器初始化完成');

      // 初始化数据同步管理器
      final dataSyncManager = comm.DataSyncManager.instance;

      // 注册主应用的数据同步配置
      dataSyncManager.registerSyncConfig(
        const comm.SyncConfig(
          moduleId: 'pet_app_main',
          dataKeys: {
            'app_state',
            'user_preferences',
            'plugin_states',
            'error_logs',
          },
          strategy: comm.SyncStrategy.realtime,
        ),
      );

      _log('info', '✅ 数据同步管理器初始化完成');

      // 初始化冲突解决引擎
      final conflictEngine = comm.ConflictResolutionEngine.instance;
      conflictEngine.initialize();
      _log('info', '✅ 冲突解决引擎初始化完成');

      // 注册主应用模块
      coordinator.registerModule(
        const comm.ModuleInfo(
          id: 'pet_app_main',
          name: 'Pet App V3 主应用',
          version: '3.1.0',
          type: 'main_app',
          capabilities: {
            'lifecycle_management': true,
            'state_persistence': true,
            'error_recovery': true,
          },
        ),
      );

      // 更新主应用状态
      coordinator.updateModuleStatus('pet_app_main', comm.ModuleStatus.running);

      _log('info', '✅ 统一消息总线初始化完成');
    } catch (e, stackTrace) {
      _log('warning', '通信系统初始化失败', e, stackTrace);
      rethrow;
    }
  }

  /// 加载Creative Workshop插件
  Future<void> _loadCreativeWorkshopPlugins() async {
    try {
      // 获取Creative Workshop管理器
      final workshopManager = WorkshopManager.instance;
      await workshopManager.initialize();

      _log('info', '✅ Creative Workshop插件加载完成');
    } catch (e, stackTrace) {
      _log('warning', 'Creative Workshop插件加载失败', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Pet App V3',

        // 主题配置
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: _themeMode,

        // 国际化配置
        locale: _locale,
        supportedLocales: const [
          Locale('zh', 'CN'), // 中文简体
          Locale('en', 'US'), // 英文
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        // 主界面
        home: _buildHome(),

        // 调试配置
        debugShowCheckedModeBanner: kDebugMode,
      ),
    );
  }

  /// 构建主界面
  Widget _buildHome() {
    // 如果有初始化错误，显示错误界面
    if (_initializationError != null) {
      return _buildErrorScreen();
    }

    // 如果还未初始化完成，显示启动画面
    if (!_isInitialized) {
      return const SplashScreen();
    }

    // 显示主导航界面
    return const MainNavigation();
  }

  /// 构建错误界面
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                '应用初始化失败',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _initializationError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initializationError = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }

  /// 日志记录
  void _log(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [PetAppV3] [$level] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
