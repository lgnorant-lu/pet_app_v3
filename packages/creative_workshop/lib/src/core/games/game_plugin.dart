/*
---------------------------------------------------------------
File name:          game_plugin.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊游戏插件基类
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意工坊游戏插件基类;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:plugin_system/plugin_system.dart';

/// 游戏类型枚举
enum GameType {
  /// 益智游戏
  puzzle,

  /// 动作游戏
  action,

  /// 策略游戏
  strategy,

  /// 教育游戏
  educational,

  /// 创意游戏
  creative,

  /// 休闲游戏
  casual,

  /// 模拟游戏
  simulation,

  /// 自定义游戏
  custom,
}

/// 游戏难度等级
enum GameDifficulty {
  /// 简单
  easy,

  /// 中等
  medium,

  /// 困难
  hard,

  /// 专家
  expert,

  /// 自定义
  custom,
}

/// 游戏状态
enum GameState {
  /// 未开始
  notStarted,

  /// 进行中
  playing,

  /// 暂停
  paused,

  /// 游戏结束
  gameOver,

  /// 胜利
  victory,

  /// 失败
  defeat,
}

/// 游戏配置
class GameConfig {
  const GameConfig({
    required this.name,
    required this.description,
    required this.icon,
    this.difficulty = GameDifficulty.medium,
    this.maxPlayers = 1,
    this.minAge = 3,
    this.estimatedDuration,
    this.settings = const <String, dynamic>{},
  });

  /// 游戏名称
  final String name;

  /// 游戏描述
  final String description;

  /// 游戏图标
  final IconData icon;

  /// 游戏难度
  final GameDifficulty difficulty;

  /// 最大玩家数
  final int maxPlayers;

  /// 最小年龄要求
  final int minAge;

  /// 预估游戏时长（分钟）
  final int? estimatedDuration;

  /// 游戏设置
  final Map<String, dynamic> settings;
}

/// 游戏分数
class GameScore {
  const GameScore({
    required this.score,
    required this.timestamp,
    this.level,
    this.achievements = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  /// 分数
  final int score;

  /// 时间戳
  final DateTime timestamp;

  /// 关卡
  final int? level;

  /// 成就列表
  final List<String> achievements;

  /// 元数据
  final Map<String, dynamic> metadata;
}

/// 游戏结果
class GameResult {
  const GameResult({
    required this.success,
    required this.gameState,
    this.score,
    this.data,
    this.error,
  });

  /// 操作是否成功
  final bool success;

  /// 游戏状态
  final GameState gameState;

  /// 游戏分数
  final GameScore? score;

  /// 结果数据
  final dynamic data;

  /// 错误信息
  final String? error;
}

/// 创意工坊游戏插件基类
///
/// 所有创意工坊游戏都必须继承此类
abstract class GamePlugin extends Plugin {
  GamePlugin({
    required this.gameType,
    required this.gameConfig,
  });

  /// 游戏类型
  final GameType gameType;

  /// 游戏配置
  final GameConfig gameConfig;

  @override
  PluginType get category => PluginType.game;

  /// 当前游戏状态
  GameState get gameState;

  /// 游戏是否正在运行
  bool get isPlaying => gameState == GameState.playing;

  /// 开始游戏
  Future<GameResult> startGame();

  /// 暂停游戏
  Future<GameResult> pauseGame();

  /// 恢复游戏
  Future<GameResult> resumeGame();

  /// 结束游戏
  Future<GameResult> endGame();

  /// 重新开始游戏
  Future<GameResult> restartGame();

  /// 获取游戏界面
  Widget getGameWidget();

  /// 获取游戏设置界面
  Widget? getGameSettingsWidget();

  /// 获取游戏统计界面
  Widget? getGameStatsWidget();

  /// 处理游戏输入
  Future<GameResult> handleGameInput(Map<String, dynamic> input);

  /// 更新游戏状态
  Future<void> updateGameState();

  /// 获取当前分数
  GameScore? getCurrentScore();

  /// 获取最高分数
  GameScore? getHighScore();

  /// 保存游戏进度
  Future<bool> saveGameProgress();

  /// 加载游戏进度
  Future<bool> loadGameProgress();

  /// 获取游戏统计数据
  Map<String, dynamic> getGameStats();

  /// 重置游戏统计
  Future<void> resetGameStats();

  /// 游戏配置变更通知
  void onGameConfigChanged(GameConfig newConfig);

  /// 游戏状态变更通知
  void onGameStateChanged(GameState oldState, GameState newState);
}

/// 回合制游戏基类
abstract class TurnBasedGame extends GamePlugin {
  TurnBasedGame({
    required super.gameType,
    required super.gameConfig,
  });

  /// 当前回合
  int get currentTurn;

  /// 当前玩家
  int get currentPlayer;

  /// 执行回合
  Future<GameResult> executeTurn(Map<String, dynamic> action);

  /// 结束回合
  Future<GameResult> endTurn();

  /// 检查游戏是否结束
  bool checkGameEnd();
}

/// 实时游戏基类
abstract class RealTimeGame extends GamePlugin {
  RealTimeGame({
    required super.gameType,
    required super.gameConfig,
  });

  /// 游戏帧率
  int get frameRate;

  /// 游戏循环
  Future<void> gameLoop();

  /// 更新游戏逻辑
  Future<void> updateGame(double deltaTime);

  /// 渲染游戏画面
  Future<void> renderGame();
}

/// 游戏插件工厂
class GamePluginFactory {
  static final Map<String, GamePlugin Function()> _gameFactories =
      <String, GamePlugin Function()>{};

  /// 注册游戏插件
  static void registerGame(String gameId, GamePlugin Function() factory) {
    _gameFactories[gameId] = factory;
  }

  /// 创建游戏插件
  static GamePlugin? createGame(String gameId) {
    final factory = _gameFactories[gameId];
    return factory?.call();
  }

  /// 获取所有已注册的游戏
  static List<String> getRegisteredGames() => _gameFactories.keys.toList();

  /// 按类型获取游戏
  static List<String> getGamesByType(GameType type) {
    // 这里需要额外的元数据来支持按类型筛选
    // 暂时返回所有游戏，实际实现时需要改进
    return getRegisteredGames();
  }

  /// 清除所有注册的游戏
  static void clearGames() {
    _gameFactories.clear();
  }
}
