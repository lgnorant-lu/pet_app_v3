/*
---------------------------------------------------------------
File name:          game_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊简化游戏管理器
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 简化游戏管理器实现;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:creative_workshop/src/core/games/simple_games.dart';

/// 简化的游戏管理器
/// 负责管理简化版本的游戏类
class SimpleGameManager extends ChangeNotifier {
  
  SimpleGameManager._internal();
  static SimpleGameManager? _instance;
  
  /// 获取单例实例
  static SimpleGameManager get instance {
    _instance ??= SimpleGameManager._internal();
    return _instance!;
  }

  /// 已注册的游戏
  final Map<String, SimpleGame> _games = <String, SimpleGame>{};
  
  /// 当前激活的游戏
  SimpleGame? _activeGame;
  String? _activeGameId;
  
  /// 游戏历史记录
  final List<String> _gameHistory = <String>[];
  
  /// 最大历史记录数量
  static const int _maxHistorySize = 10;

  /// 获取当前激活的游戏
  SimpleGame? get activeGame => _activeGame;
  String? get activeGameId => _activeGameId;
  
  /// 获取所有游戏
  Map<String, SimpleGame> get games => Map.unmodifiable(_games);
  
  /// 获取游戏历史记录
  List<String> get gameHistory => List.unmodifiable(_gameHistory);

  /// 初始化游戏管理器
  Future<void> initialize() async {
    try {
      // 注册内置游戏
      await _registerBuiltinGames();
      
      // 设置默认游戏
      _setDefaultGame();
      
      debugPrint('简化游戏管理器初始化完成：${_games.length} 个游戏');
    } catch (e) {
      debugPrint('游戏管理器初始化失败: $e');
      rethrow;
    }
  }

  /// 注册内置游戏
  Future<void> _registerBuiltinGames() async {
    // 注册点击游戏
    final clickGame = SimpleClickGame();
    _games[clickGame.id] = clickGame;
    
    // 注册猜数字游戏
    final guessGame = SimpleGuessGame();
    _games[guessGame.id] = guessGame;
    
    debugPrint('内置游戏注册完成：${_games.length} 个游戏');
  }

  /// 设置默认游戏
  void _setDefaultGame() {
    // 默认激活点击游戏
    if (_games.isNotEmpty) {
      final defaultGame = _games.values.first;
      _activeGame = defaultGame;
      _activeGameId = defaultGame.id;
      _updateGameHistory(defaultGame.id);
      debugPrint('默认游戏已设置: ${defaultGame.name}');
    }
  }

  /// 激活游戏
  bool activateGame(String gameId) {
    final game = _games[gameId];
    if (game != null) {
      // 停用当前游戏
      if (_activeGame != null && _activeGame!.gameState == SimpleGameState.playing) {
        _activeGame!.pauseGame();
      }
      
      _activeGame = game;
      _activeGameId = gameId;
      _updateGameHistory(gameId);
      notifyListeners();
      debugPrint('游戏已激活: ${game.name}');
      return true;
    }
    debugPrint('游戏不存在: $gameId');
    return false;
  }

  /// 停用当前游戏
  void deactivateCurrentGame() {
    if (_activeGame != null) {
      if (_activeGame!.gameState == SimpleGameState.playing) {
        _activeGame!.pauseGame();
      }
      debugPrint('游戏已停用: ${_activeGame!.name}');
      _activeGame = null;
      _activeGameId = null;
      notifyListeners();
    }
  }

  /// 切换到上一个游戏
  bool switchToPreviousGame() {
    if (_gameHistory.length >= 2) {
      final previousGameId = _gameHistory[_gameHistory.length - 2];
      return activateGame(previousGameId);
    }
    return false;
  }

  /// 注册新游戏
  bool registerGame(SimpleGame game) {
    if (_games.containsKey(game.id)) {
      debugPrint('游戏已存在: ${game.id}');
      return false;
    }
    
    _games[game.id] = game;
    debugPrint('游戏注册成功: ${game.name} (${game.id})');
    notifyListeners();
    return true;
  }

  /// 注销游戏
  bool unregisterGame(String gameId) {
    final game = _games[gameId];
    if (game == null) {
      debugPrint('游戏不存在: $gameId');
      return false;
    }

    // 如果是当前激活的游戏，先停用
    if (_activeGameId == gameId) {
      deactivateCurrentGame();
    }

    // 从游戏列表移除
    _games.remove(gameId);
    
    // 从历史记录移除
    _gameHistory.removeWhere((String id) => id == gameId);
    
    debugPrint('游戏注销成功: ${game.name} (${game.id})');
    notifyListeners();
    return true;
  }

  /// 检查游戏是否存在
  bool hasGame(String gameId) => _games.containsKey(gameId);

  /// 检查游戏是否激活
  bool isGameActive(String gameId) => _activeGameId == gameId;

  /// 获取游戏
  SimpleGame? getGame(String gameId) => _games[gameId];

  /// 获取所有游戏名称
  List<String> getGameNames() => _games.values.map((SimpleGame game) => game.name).toList();

  /// 获取所有游戏ID
  List<String> getGameIds() => _games.keys.toList();

  /// 更新游戏历史记录
  void _updateGameHistory(String gameId) {
    // 移除已存在的记录
    _gameHistory.removeWhere((String id) => id == gameId);
    
    // 添加到末尾
    _gameHistory.add(gameId);
    
    // 限制历史记录大小
    if (_gameHistory.length > _maxHistorySize) {
      _gameHistory.removeAt(0);
    }
  }

  /// 获取游戏统计信息
  Map<String, dynamic> getGameStatistics() {
    final stats = <String, dynamic>{};
    
    stats['totalGames'] = _games.length;
    stats['activeGameId'] = _activeGameId;
    stats['historySize'] = _gameHistory.length;
    
    // 按游戏类型统计
    final gameStats = <String, dynamic>{};
    for (final game in _games.values) {
      gameStats[game.id] = <String, Object>{
        'name': game.name,
        'state': game.gameState.toString(),
        'score': game.score,
        'highScore': game.highScore,
        'gameTime': game.gameTime,
      };
    }
    stats['gameDetails'] = gameStats;
    
    return stats;
  }

  /// 重置所有游戏统计
  void resetAllGameStats() {
    for (final game in _games.values) {
      if (game.gameState != SimpleGameState.notStarted) {
        game.endGame();
      }
    }
    debugPrint('所有游戏统计已重置');
    notifyListeners();
  }

  /// 清理资源
  @override
  void dispose() {
    // 停用当前游戏
    deactivateCurrentGame();
    
    // 清空游戏列表
    _games.clear();
    _gameHistory.clear();
    
    debugPrint('简化游戏管理器已清理');
    super.dispose();
  }
}
