/*
---------------------------------------------------------------
File name:          workshop_manager.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        创意工坊核心管理器
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意工坊核心管理器;
    2025-07-19: 优化初始化逻辑，支持重复调用;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:plugin_system/plugin_system.dart';

import 'package:creative_workshop/src/core/tools/tool_plugin.dart';
import 'package:creative_workshop/src/core/games/game_plugin.dart';
import 'package:creative_workshop/src/core/projects/project_manager.dart';

/// 工坊状态
enum WorkshopState {
  /// 未初始化
  uninitialized,

  /// 初始化中
  initializing,

  /// 就绪
  ready,

  /// 运行中
  running,

  /// 暂停
  paused,

  /// 错误
  error,
}

/// 创意工坊核心管理器
///
/// 统一管理工具插件、游戏插件和创意项目
class WorkshopManager extends ChangeNotifier {
  WorkshopManager._();

  /// 单例实例
  static final WorkshopManager _instance = WorkshopManager._();
  static WorkshopManager get instance => _instance;

  /// 插件注册中心
  final PluginRegistry _pluginRegistry = PluginRegistry.instance;

  /// 项目管理器
  final ProjectManager _projectManager = ProjectManager.instance;

  /// 当前工坊状态
  WorkshopState _state = WorkshopState.uninitialized;

  /// 当前活跃的工具
  ToolPlugin? _activeTool;

  /// 当前运行的游戏
  GamePlugin? _activeGame;

  /// 状态变更流控制器
  final StreamController<WorkshopState> _stateController =
      StreamController<WorkshopState>.broadcast();

  /// 获取当前状态
  WorkshopState get state => _state;

  /// 获取项目管理器
  ProjectManager get projectManager => _projectManager;

  /// 获取当前活跃工具
  ToolPlugin? get activeTool => _activeTool;

  /// 获取当前运行游戏
  GamePlugin? get activeGame => _activeGame;

  /// 状态变更流
  Stream<WorkshopState> get stateChanges => _stateController.stream;

  /// 初始化创意工坊
  Future<bool> initialize() async {
    // 检查是否已经初始化
    if (_state == WorkshopState.ready || _state == WorkshopState.running) {
      _log('info', '创意工坊已经初始化，跳过重复初始化');
      return true;
    }

    // 如果正在初始化中，等待完成
    if (_state == WorkshopState.initializing) {
      _log('info', '创意工坊正在初始化中，等待完成');
      // 等待状态变为ready或error
      await for (final WorkshopState state in _stateController.stream) {
        if (state == WorkshopState.ready) {
          return true;
        } else if (state == WorkshopState.error) {
          return false;
        }
      }
    }

    try {
      _setState(WorkshopState.initializing);

      // 初始化插件系统
      await _initializePluginSystem();

      // 注册内置工具和游戏
      await _registerBuiltinPlugins();

      // 加载用户插件
      await _loadUserPlugins();

      _setState(WorkshopState.ready);
      return true;
    } catch (e) {
      debugPrint('创意工坊初始化失败: $e');
      _setState(WorkshopState.error);
      return false;
    }
  }

  /// 启动创意工坊
  Future<bool> start() async {
    if (_state != WorkshopState.ready) {
      return false;
    }

    try {
      _setState(WorkshopState.running);
      return true;
    } catch (e) {
      debugPrint('创意工坊启动失败: $e');
      _setState(WorkshopState.error);
      return false;
    }
  }

  /// 暂停创意工坊
  Future<bool> pause() async {
    if (_state != WorkshopState.running) {
      return false;
    }

    try {
      // 暂停当前活跃的工具和游戏
      if (_activeTool != null) {
        await _activeTool!.deactivate();
      }

      if (_activeGame != null) {
        await _activeGame!.pauseGame();
      }

      _setState(WorkshopState.paused);
      return true;
    } catch (e) {
      debugPrint('创意工坊暂停失败: $e');
      return false;
    }
  }

  /// 恢复创意工坊
  Future<bool> resume() async {
    if (_state != WorkshopState.paused) {
      return false;
    }

    try {
      // 恢复当前活跃的游戏
      if (_activeGame != null) {
        await _activeGame!.resumeGame();
      }

      _setState(WorkshopState.running);
      return true;
    } catch (e) {
      debugPrint('创意工坊恢复失败: $e');
      return false;
    }
  }

  /// 停止创意工坊
  Future<bool> stop() async {
    try {
      // 停止当前活跃的工具和游戏
      if (_activeTool != null) {
        await _activeTool!.deactivate();
        _activeTool = null;
      }

      if (_activeGame != null) {
        await _activeGame!.endGame();
        _activeGame = null;
      }

      _setState(WorkshopState.ready);
      return true;
    } catch (e) {
      debugPrint('创意工坊停止失败: $e');
      return false;
    }
  }

  /// 激活工具
  Future<bool> activateTool(String toolId) async {
    try {
      // 停用当前工具
      if (_activeTool != null) {
        await _activeTool!.deactivate();
      }

      // 获取新工具
      final plugin = _pluginRegistry.get(toolId);
      if (plugin is! ToolPlugin) {
        return false;
      }

      // 激活新工具
      final result = await plugin.activate();
      if (result.success) {
        _activeTool = plugin;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('激活工具失败: $e');
      return false;
    }
  }

  /// 停用当前工具
  Future<bool> deactivateTool() async {
    if (_activeTool == null) {
      return true;
    }

    try {
      await _activeTool!.deactivate();
      _activeTool = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('停用工具失败: $e');
      return false;
    }
  }

  /// 启动游戏
  Future<bool> startGame(String gameId) async {
    try {
      // 停止当前游戏
      if (_activeGame != null) {
        await _activeGame!.endGame();
      }

      // 获取新游戏
      final plugin = _pluginRegistry.get(gameId);
      if (plugin is! GamePlugin) {
        return false;
      }

      // 启动新游戏
      final result = await plugin.startGame();
      if (result.success) {
        _activeGame = plugin;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('启动游戏失败: $e');
      return false;
    }
  }

  /// 停止当前游戏
  Future<bool> stopGame() async {
    if (_activeGame == null) {
      return true;
    }

    try {
      await _activeGame!.endGame();
      _activeGame = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('停止游戏失败: $e');
      return false;
    }
  }

  /// 获取所有工具插件
  List<ToolPlugin> getTools() => _pluginRegistry
      .getByCategory(PluginCategory.tool)
      .whereType<ToolPlugin>()
      .toList();

  /// 获取所有游戏插件
  List<GamePlugin> getGames() => _pluginRegistry
      .getByCategory(PluginCategory.game)
      .whereType<GamePlugin>()
      .toList();

  /// 按类型获取工具
  List<ToolPlugin> getToolsByType(ToolType type) =>
      getTools().where((ToolPlugin tool) => tool.toolType == type).toList();

  /// 按类型获取游戏
  List<GamePlugin> getGamesByType(GameType type) =>
      getGames().where((GamePlugin game) => game.gameType == type).toList();

  /// 初始化插件系统
  Future<void> _initializePluginSystem() async {
    // 插件系统已经在 Phase 1 中初始化完成
    // 这里可以添加创意工坊特定的初始化逻辑
  }

  /// 注册内置插件
  Future<void> _registerBuiltinPlugins() async {
    try {
      _log('info', '开始注册内置插件');

      // 注册内置工具插件
      await _registerBuiltinTools();

      // 注册内置游戏插件
      await _registerBuiltinGames();

      _log('info', '内置插件注册完成');
    } catch (e, stackTrace) {
      _log('severe', '注册内置插件失败', e, stackTrace);
      rethrow;
    }
  }

  /// 加载用户插件
  Future<void> _loadUserPlugins() async {
    try {
      _log('info', '开始加载用户插件');

      // 从本地存储获取用户插件列表
      final userPlugins = await _getUserPluginList();

      // 验证和加载每个插件
      for (final pluginInfo in userPlugins) {
        await _loadUserPlugin(pluginInfo);
      }

      _log('info', '用户插件加载完成，共加载 ${userPlugins.length} 个插件');
    } catch (e, stackTrace) {
      _log('severe', '加载用户插件失败', e, stackTrace);
      rethrow;
    }
  }

  /// 设置状态
  void _setState(WorkshopState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      notifyListeners();
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }

  // ===== 日志和辅助方法 =====

  /// 日志记录方法
  static void _log(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [$level] [WorkshopManager] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// 注册内置工具插件
  ///
  /// Phase 5.0.6 重构：转型为应用商店模式
  /// 不再注册内置工具，改为从插件市场动态加载
  Future<void> _registerBuiltinTools() async {
    _log('info', '跳过内置工具注册 - 转型为应用商店模式');

    // TODO: Phase 5.0.6.2 - 实现从插件市场加载工具
    // 1. 扫描已安装的工具插件
    // 2. 动态加载插件到注册中心
    // 3. 验证插件兼容性和权限

    _log('info', '工具插件注册完成 - 应用商店模式');
  }

  /// 注册内置游戏插件
  ///
  /// Phase 5.0.6 重构：转型为应用商店模式
  /// 不再注册内置游戏，改为从插件市场动态加载
  Future<void> _registerBuiltinGames() async {
    _log('info', '跳过内置游戏注册 - 转型为应用商店模式');

    // TODO: Phase 5.0.6.2 - 实现从插件市场加载游戏
    // 1. 扫描已安装的游戏插件
    // 2. 动态加载插件到注册中心
    // 3. 验证插件兼容性和权限

    _log('info', '游戏插件注册完成 - 应用商店模式');
  }

  // ===== 用户插件管理方法 =====

  /// 获取用户插件列表
  Future<List<Map<String, dynamic>>> _getUserPluginList() async {
    // TODO(High): [Phase 2.9.2] 实现真实的用户插件列表获取
    // 需要实现：
    // 1. 从SharedPreferences读取用户插件配置
    // 2. 从文件系统扫描插件目录
    // 3. 验证插件文件完整性和签名
    // 4. 支持插件版本管理和更新检测
    // 5. 插件启用/禁用状态管理
    // 6. 插件依赖关系验证
    // 7. 错误插件的过滤和报告
    //
    // 当前状态: 使用硬编码模拟数据
    // 影响: 无法加载真实的用户插件，功能受限
    // 优先级: High - 影响用户体验
    _log('info', '获取用户插件列表');

    try {
      // 从本地存储读取插件配置
      // 这里使用模拟数据，实际应该从SharedPreferences或文件系统读取
      // 获取已注册的插件列表
      final registeredPlugins = _pluginRegistry.getAllPlugins();
      final List<Map<String, dynamic>> userPlugins = <Map<String, dynamic>>[];

      // 转换为用户插件信息格式
      for (final plugin in registeredPlugins) {
        // 跳过内置插件，只返回用户插件
        if (!_isBuiltinPlugin(plugin.id)) {
          userPlugins.add(<String, dynamic>{
            'id': plugin.id,
            'name': plugin.name,
            'type': _getPluginType(plugin),
            'version': plugin.version,
            'enabled': true, // 已注册的插件默认为启用状态
            'author': plugin.author,
            'description': plugin.description,
          });
        }
      }

      _log('info', '找到 ${userPlugins.length} 个用户插件');
      return userPlugins;
    } catch (e) {
      _log('warning', '获取用户插件列表失败: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// 加载单个用户插件
  Future<void> _loadUserPlugin(Map<String, dynamic> pluginInfo) async {
    final String pluginId = pluginInfo['id'] as String;
    _log('info', '加载用户插件: $pluginId');

    try {
      // 验证插件信息
      if (!_validatePluginInfo(pluginInfo)) {
        _log('warning', '插件信息验证失败: $pluginId');
        return;
      }

      // 检查插件是否已启用
      if (!(pluginInfo['enabled'] as bool? ?? false)) {
        _log('info', '插件已禁用，跳过加载: $pluginId');
        return;
      }

      // 根据插件类型进行加载
      final String pluginType = pluginInfo['type'] as String;
      switch (pluginType) {
        case 'tool':
          await _loadUserToolPlugin(pluginInfo);
          break;
        case 'game':
          await _loadUserGamePlugin(pluginInfo);
          break;
        default:
          _log('warning', '未知的插件类型: $pluginType');
      }

      _log('info', '用户插件加载成功: $pluginId');
    } catch (e) {
      _log('warning', '加载用户插件失败: $pluginId, 错误: $e');
    }
  }

  /// 验证插件信息
  bool _validatePluginInfo(Map<String, dynamic> pluginInfo) {
    final List<String> requiredFields = <String>[
      'id',
      'name',
      'type',
      'version'
    ];

    for (final String field in requiredFields) {
      if (!pluginInfo.containsKey(field) || pluginInfo[field] == null) {
        _log('warning', '插件信息缺少必需字段: $field');
        return false;
      }
    }

    return true;
  }

  /// 加载用户工具插件
  Future<void> _loadUserToolPlugin(Map<String, dynamic> pluginInfo) async {
    // TODO(High): [Phase 2.9.2] 实现用户工具插件动态加载
    // 需要实现：
    // 1. 从插件路径读取插件文件
    // 2. 验证插件签名和完整性
    // 3. 动态实例化ToolPlugin子类
    // 4. 注册到PluginRegistry
    // 5. 权限验证和配置
    // 6. 依赖关系检查和解析
    // 7. 插件初始化和生命周期管理
    //
    // 当前状态: 完全占位符实现，无实际加载逻辑
    // 影响: 无法使用用户自定义工具插件
    // 优先级: High - 影响扩展性
    final String pluginId = pluginInfo['id'] as String;
    _log('info', '加载用户工具插件: $pluginId');

    try {
      // 实际实现中，这里会动态加载插件文件
      // 目前使用占位符实现
      _log('info', '用户工具插件加载完成: $pluginId');
    } catch (e) {
      _log('warning', '加载用户工具插件失败: $pluginId, 错误: $e');
      rethrow;
    }
  }

  /// 加载用户游戏插件
  Future<void> _loadUserGamePlugin(Map<String, dynamic> pluginInfo) async {
    // TODO(High): [Phase 2.9.2] 实现用户游戏插件动态加载
    // 需要实现：
    // 1. 从插件路径读取插件文件
    // 2. 验证插件签名和完整性
    // 3. 动态实例化GamePlugin子类
    // 4. 注册到PluginRegistry
    // 5. 权限验证和配置
    // 6. 依赖关系检查和解析
    // 7. 插件初始化和生命周期管理
    //
    // 当前状态: 完全占位符实现，无实际加载逻辑
    // 影响: 无法使用用户自定义游戏插件
    // 优先级: High - 影响扩展性
    final String pluginId = pluginInfo['id'] as String;
    _log('info', '加载用户游戏插件: $pluginId');

    try {
      // 实际实现中，这里会动态加载插件文件
      // 目前使用占位符实现
      _log('info', '用户游戏插件加载完成: $pluginId');
    } catch (e) {
      _log('warning', '加载用户游戏插件失败: $pluginId, 错误: $e');
      rethrow;
    }
  }

  // ===== 辅助方法 =====

  /// 判断是否为内置插件
  bool _isBuiltinPlugin(String pluginId) {
    const builtinPluginIds = <String>{
      'simple_brush_tool',
      'simple_pencil_tool',
      'simple_click_game',
    };
    return builtinPluginIds.contains(pluginId);
  }

  /// 获取插件类型
  String _getPluginType(Plugin plugin) {
    if (plugin is ToolPlugin) {
      return 'tool';
    } else if (plugin is GamePlugin) {
      return 'game';
    } else {
      return 'unknown';
    }
  }
}
