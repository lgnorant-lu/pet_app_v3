/*
---------------------------------------------------------------
File name:          workshop_manager.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊核心管理器
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意工坊核心管理器;
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
  List<ToolPlugin> getTools() => _pluginRegistry.getByCategory(PluginCategory.tool)
        .whereType<ToolPlugin>()
        .toList();

  /// 获取所有游戏插件
  List<GamePlugin> getGames() => _pluginRegistry.getByCategory(PluginCategory.game)
        .whereType<GamePlugin>()
        .toList();

  /// 按类型获取工具
  List<ToolPlugin> getToolsByType(ToolType type) => getTools().where((ToolPlugin tool) => tool.toolType == type).toList();

  /// 按类型获取游戏
  List<GamePlugin> getGamesByType(GameType type) => getGames().where((GamePlugin game) => game.gameType == type).toList();

  /// 初始化插件系统
  Future<void> _initializePluginSystem() async {
    // 插件系统已经在 Phase 1 中初始化完成
    // 这里可以添加创意工坊特定的初始化逻辑
  }

  /// 注册内置插件
  Future<void> _registerBuiltinPlugins() async {
    // TODO: 注册内置工具和游戏插件
    // 这将在后续任务中实现
  }

  /// 加载用户插件
  Future<void> _loadUserPlugins() async {
    // TODO: 从本地存储加载用户安装的插件
    // 这将在后续任务中实现
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
}
