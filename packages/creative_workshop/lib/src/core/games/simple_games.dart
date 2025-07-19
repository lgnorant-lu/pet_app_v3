/*
---------------------------------------------------------------
File name:          simple_games.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊简化游戏实现
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 简化游戏实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:plugin_system/plugin_system.dart';
import 'package:creative_workshop/src/core/games/game_plugin.dart';
import 'dart:math';

/// 简化的游戏基类
abstract class SimpleGame extends GamePlugin {
  SimpleGame({
    required GameType gameType,
    required GameConfig gameConfig,
  }) : super(
          gameType: gameType,
          gameConfig: gameConfig,
        );

  /// 当前游戏状态
  GameState _gameState = GameState.notStarted;

  @override
  GameState get gameState => _gameState;

  /// 当前分数
  int _score = 0;
  int get score => _score;

  /// 最高分数
  int _highScore = 0;
  int get highScore => _highScore;

  /// 游戏时间（秒）
  int _gameTime = 0;
  int get gameTime => _gameTime;

  /// 游戏图标
  IconData get icon => gameConfig.icon;

  /// 开始游戏
  @override
  Future<GameResult> startGame() async {
    _gameState = GameState.playing;
    _score = 0;
    _gameTime = 0;
    onGameStart();
    debugPrint('游戏开始: ${gameConfig.name}');
    return GameResult(success: true, gameState: _gameState);
  }

  /// 暂停游戏
  @override
  Future<GameResult> pauseGame() async {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      onGamePause();
      debugPrint('游戏暂停: ${gameConfig.name}');
    }
    return GameResult(success: true, gameState: _gameState);
  }

  /// 恢复游戏
  @override
  Future<GameResult> resumeGame() async {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      onGameResume();
      debugPrint('游戏恢复: ${gameConfig.name}');
    }
    return GameResult(success: true, gameState: _gameState);
  }

  /// 结束游戏
  @override
  Future<GameResult> endGame() async {
    // 只有在非胜利状态时才设置为游戏结束
    if (_gameState != GameState.victory) {
      _gameState = GameState.gameOver;
    }
    if (_score > _highScore) {
      _highScore = _score;
    }
    onGameEnd();
    debugPrint('游戏结束: ${gameConfig.name}, 分数: $_score');
    return GameResult(success: true, gameState: _gameState);
  }

  /// 重新开始游戏
  @override
  Future<GameResult> restartGame() async {
    await endGame();
    return await startGame();
  }

  /// 更新分数
  void updateScore(int points) {
    _score += points;
  }

  /// 更新游戏时间
  void updateGameTime(int seconds) {
    _gameTime = seconds;
  }

  // Plugin基类必需的方法实现
  @override
  Future<void> initialize() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Object? getConfigWidget() => null;

  @override
  PluginState get currentState => PluginState.loaded;

  @override
  Object getMainWidget() => getGameWidget();

  @override
  Future<dynamic> handleMessage(
      String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'start':
        return await startGame();
      case 'pause':
        return await pauseGame();
      case 'resume':
        return await resumeGame();
      case 'end':
        return await endGame();
      case 'restart':
        return await restartGame();
      default:
        return GameResult(
          success: false,
          gameState: gameState,
          error: 'Unknown action: $action',
        );
    }
  }

  @override
  Stream<PluginState> get stateChanges => Stream.value(currentState);

  // GamePlugin抽象方法实现
  @override
  Widget getGameWidget() => buildGameWidget();

  @override
  Widget? getGameSettingsWidget() => null;

  @override
  GameScore? getCurrentScore() {
    return GameScore(
      score: score,
      timestamp: DateTime.now(),
    );
  }

  @override
  GameScore? getHighScore() {
    return GameScore(
      score: highScore,
      timestamp: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> getGameStats() {
    return {
      'currentScore': score,
      'highScore': highScore,
      'gameTime': gameTime,
      'gamesPlayed': 1,
    };
  }

  @override
  Widget? getGameStatsWidget() => null;

  @override
  Future<GameResult> handleGameInput(Map<String, dynamic> input) async {
    // 基类实现，子类可以重写
    return GameResult(success: true, gameState: gameState);
  }

  @override
  Future<void> updateGameState() async {
    // 游戏状态更新逻辑
  }

  @override
  Future<bool> saveGameProgress() async {
    // 保存游戏进度
    return true;
  }

  @override
  Future<bool> loadGameProgress() async {
    // 加载游戏进度
    return true;
  }

  @override
  Future<void> resetGameStats() async {
    _score = 0;
    _highScore = 0;
    _gameTime = 0;
  }

  @override
  void onGameConfigChanged(GameConfig newConfig) {
    // 处理游戏配置变更
  }

  @override
  void onGameStateChanged(GameState oldState, GameState newState) {
    // 处理游戏状态变更
  }

  /// 游戏开始时调用
  void onGameStart();

  /// 游戏暂停时调用
  void onGamePause();

  /// 游戏恢复时调用
  void onGameResume();

  /// 游戏结束时调用
  void onGameEnd();

  /// 获取游戏界面
  Widget buildGameWidget();

  /// 获取游戏控制面板
  Widget buildControlPanel();
}

/// 简单的点击游戏
class SimpleClickGame extends SimpleGame {
  SimpleClickGame()
      : super(
          gameType: GameType.casual,
          gameConfig: const GameConfig(
            name: '点击游戏',
            description: '点击按钮获得分数',
            icon: Icons.touch_app,
            difficulty: GameDifficulty.easy,
            estimatedDuration: 5,
          ),
        );

  // Plugin基类必需的getter实现
  @override
  String get id => 'simple_click_game';

  @override
  String get name => '点击游戏';

  @override
  String get version => '1.0.0';

  @override
  String get description => '点击按钮获得分数';

  @override
  String get author => 'Creative Workshop';

  @override
  List<Permission> get requiredPermissions => [];

  @override
  List<PluginDependency> get dependencies => [];

  @override
  List<SupportedPlatform> get supportedPlatforms => [
        SupportedPlatform.android,
        SupportedPlatform.ios,
        SupportedPlatform.windows,
        SupportedPlatform.macos,
        SupportedPlatform.linux,
        SupportedPlatform.web,
      ];

  /// 点击次数
  int _clickCount = 0;
  int get clickCount => _clickCount;

  /// 目标点击次数
  int _targetClicks = 50;
  int get targetClicks => _targetClicks;

  // 重写GamePlugin方法
  @override
  Future<GameResult> handleGameInput(Map<String, dynamic> input) async {
    if (input['action'] == 'click') {
      handleClick();
    }
    return GameResult(success: true, gameState: gameState);
  }

  @override
  Future<void> resetGameStats() async {
    await super.resetGameStats();
    _clickCount = 0;
  }

  @override
  void onGameStart() {
    _clickCount = 0;
    _targetClicks = 50;
  }

  @override
  void onGamePause() {
    // 暂停时不需要特殊处理
  }

  @override
  void onGameResume() {
    // 恢复时不需要特殊处理
  }

  @override
  void onGameEnd() {
    // 游戏结束时不需要特殊处理
  }

  /// 处理点击
  void handleClick() {
    if (gameState == GameState.playing) {
      _clickCount++;
      updateScore(10);

      if (_clickCount >= _targetClicks) {
        _gameState = GameState.victory;
        endGame();
      }
    }
  }

  @override
  Widget buildGameWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '点击游戏',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('分数: $score'),
            Text('点击次数: $_clickCount / $_targetClicks'),
            const SizedBox(height: 20),
            if (gameState == GameState.playing) ...<Widget>[
              ElevatedButton(
                onPressed: handleClick,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 100),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  '点击我！',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ] else if (gameState == GameState.victory) ...<Widget>[
              const Text(
                '恭喜胜利！',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            ] else if (gameState == GameState.gameOver) ...<Widget>[
              const Text(
                '游戏结束',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ] else ...<Widget>[
              const Text(
                '点击开始按钮开始游戏',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      );

  @override
  Widget buildControlPanel() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (gameState == GameState.notStarted ||
              gameState == GameState.gameOver) ...<Widget>[
            ElevatedButton(
              onPressed: startGame,
              child: const Text('开始游戏'),
            ),
          ],
          if (gameState == GameState.playing) ...<Widget>[
            ElevatedButton(
              onPressed: () => pauseGame(),
              child: const Text('暂停'),
            ),
          ],
          if (gameState == GameState.paused) ...<Widget>[
            ElevatedButton(
              onPressed: () => resumeGame(),
              child: const Text('继续'),
            ),
          ],
          if (gameState != GameState.notStarted) ...<Widget>[
            ElevatedButton(
              onPressed: restartGame,
              child: const Text('重新开始'),
            ),
          ],
        ],
      );
}

/// 简单的数字猜测游戏
class SimpleGuessGame extends SimpleGame {
  SimpleGuessGame()
      : super(
          gameType: GameType.puzzle,
          gameConfig: const GameConfig(
            name: '猜数字游戏',
            description: '猜测1-100之间的随机数字',
            icon: Icons.quiz,
            difficulty: GameDifficulty.medium,
            estimatedDuration: 10,
          ),
        );

  // Plugin基类必需的getter实现
  @override
  String get id => 'simple_guess_game';

  @override
  String get name => '猜数字';

  @override
  String get version => '1.0.0';

  @override
  String get description => '猜测1-100之间的随机数字';

  @override
  String get author => 'Creative Workshop';

  @override
  List<Permission> get requiredPermissions => [];

  @override
  List<PluginDependency> get dependencies => [];

  @override
  List<SupportedPlatform> get supportedPlatforms => [
        SupportedPlatform.android,
        SupportedPlatform.ios,
        SupportedPlatform.windows,
        SupportedPlatform.macos,
        SupportedPlatform.linux,
        SupportedPlatform.web,
      ];

  /// 目标数字
  int _targetNumber = 0;

  /// 猜测次数
  int _guessCount = 0;
  int get guessCount => _guessCount;

  /// 最大猜测次数
  int _maxGuesses = 10;
  int get maxGuesses => _maxGuesses;

  /// 提示信息
  String _hint = '';
  String get hint => _hint;

  /// 输入控制器
  final TextEditingController _inputController = TextEditingController();

  @override
  void onGameStart() {
    _targetNumber = Random().nextInt(100) + 1;
    _guessCount = 0;
    _maxGuesses = 10;
    _hint = '请输入1-100之间的数字';
    _inputController.clear();
  }

  @override
  void onGamePause() {
    // 暂停时不需要特殊处理
  }

  @override
  void onGameResume() {
    // 恢复时不需要特殊处理
  }

  @override
  void onGameEnd() {
    _inputController.dispose();
  }

  /// 处理猜测
  void handleGuess() {
    if (gameState != GameState.playing) return;

    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final guess = int.tryParse(input);
    if (guess == null || guess < 1 || guess > 100) {
      _hint = '请输入1-100之间的有效数字';
      return;
    }

    _guessCount++;

    if (guess == _targetNumber) {
      _gameState = GameState.victory;
      _hint = '恭喜！猜对了！';
      updateScore(100 - _guessCount * 10);
      endGame();
    } else if (_guessCount >= _maxGuesses) {
      _gameState = GameState.gameOver;
      _hint = '游戏结束！正确答案是 $_targetNumber';
      endGame();
    } else {
      if (guess < _targetNumber) {
        _hint = '太小了！还有 ${_maxGuesses - _guessCount} 次机会';
      } else {
        _hint = '太大了！还有 ${_maxGuesses - _guessCount} 次机会';
      }
    }

    _inputController.clear();
  }

  @override
  Widget buildGameWidget() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '猜数字游戏',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('分数: $score'),
              Text('猜测次数: $_guessCount / $_maxGuesses'),
              const SizedBox(height: 20),
              Text(
                _hint,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (gameState == GameState.playing) ...<Widget>[
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '输入数字',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => handleGuess(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: handleGuess,
                  child: const Text('猜测'),
                ),
              ] else if (gameState == GameState.notStarted) ...<Widget>[
                const Text(
                  '点击开始按钮开始游戏',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      );

  @override
  Widget buildControlPanel() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (gameState == GameState.notStarted ||
              gameState == GameState.gameOver ||
              gameState == GameState.victory) ...<Widget>[
            ElevatedButton(
              onPressed: startGame,
              child: const Text('开始游戏'),
            ),
          ],
          if (gameState == GameState.playing) ...<Widget>[
            ElevatedButton(
              onPressed: pauseGame,
              child: const Text('暂停'),
            ),
          ],
          if (gameState == GameState.paused) ...<Widget>[
            ElevatedButton(
              onPressed: resumeGame,
              child: const Text('继续'),
            ),
          ],
          if (gameState != GameState.notStarted) ...<Widget>[
            ElevatedButton(
              onPressed: restartGame,
              child: const Text('重新开始'),
            ),
          ],
        ],
      );

  // GamePlugin抽象方法实现
  @override
  GameScore? getCurrentScore() {
    return GameScore(
      score: score,
      timestamp: DateTime.now(),
    );
  }

  @override
  GameScore? getHighScore() {
    return GameScore(
      score: highScore,
      timestamp: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> getGameStats() {
    return {
      'currentScore': score,
      'highScore': highScore,
      'gameTime': gameTime,
      'guessCount': _guessCount,
      'maxGuesses': _maxGuesses,
    };
  }

  @override
  Widget? getGameStatsWidget() => null;

  @override
  Future<GameResult> handleGameInput(Map<String, dynamic> input) async {
    if (input['action'] == 'guess' && input['value'] != null) {
      // 可以在这里处理外部输入的猜测
    }
    return GameResult(success: true, gameState: gameState);
  }

  @override
  Future<void> updateGameState() async {
    // 游戏状态更新逻辑
  }

  @override
  Future<bool> saveGameProgress() async {
    // 保存游戏进度
    return true;
  }

  @override
  Future<bool> loadGameProgress() async {
    // 加载游戏进度
    return true;
  }

  @override
  Future<void> resetGameStats() async {
    await super.resetGameStats();
    _guessCount = 0;
    _targetNumber = Random().nextInt(100) + 1;
    _hint = '我想了一个1-100之间的数字，你能猜出来吗？';
  }

  @override
  void onGameConfigChanged(GameConfig newConfig) {
    // 处理游戏配置变更
  }

  @override
  void onGameStateChanged(GameState oldState, GameState newState) {
    // 处理游戏状态变更
  }
}
