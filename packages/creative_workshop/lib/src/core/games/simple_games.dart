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
import 'dart:math';

/// 游戏状态枚举
enum SimpleGameState {
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
}

/// 简化的游戏基类
abstract class SimpleGame extends ChangeNotifier {
  /// 游戏ID
  String get id;

  /// 游戏名称
  String get name;

  /// 游戏描述
  String get description;

  /// 游戏图标
  IconData get icon;

  /// 当前游戏状态
  SimpleGameState _gameState = SimpleGameState.notStarted;
  SimpleGameState get gameState => _gameState;

  /// 当前分数
  int _score = 0;
  int get score => _score;

  /// 最高分数
  int _highScore = 0;
  int get highScore => _highScore;

  /// 游戏时间（秒）
  int _gameTime = 0;
  int get gameTime => _gameTime;

  /// 开始游戏
  void startGame() {
    _gameState = SimpleGameState.playing;
    _score = 0;
    _gameTime = 0;
    onGameStart();
    notifyListeners();
    debugPrint('游戏开始: $name');
  }

  /// 暂停游戏
  void pauseGame() {
    if (_gameState == SimpleGameState.playing) {
      _gameState = SimpleGameState.paused;
      onGamePause();
      notifyListeners();
      debugPrint('游戏暂停: $name');
    }
  }

  /// 恢复游戏
  void resumeGame() {
    if (_gameState == SimpleGameState.paused) {
      _gameState = SimpleGameState.playing;
      onGameResume();
      notifyListeners();
      debugPrint('游戏恢复: $name');
    }
  }

  /// 结束游戏
  void endGame() {
    _gameState = SimpleGameState.gameOver;
    if (_score > _highScore) {
      _highScore = _score;
    }
    onGameEnd();
    notifyListeners();
    debugPrint('游戏结束: $name, 分数: $_score');
  }

  /// 重新开始游戏
  void restartGame() {
    endGame();
    startGame();
  }

  /// 更新分数
  void updateScore(int points) {
    _score += points;
    notifyListeners();
  }

  /// 更新游戏时间
  void updateGameTime(int seconds) {
    _gameTime = seconds;
    notifyListeners();
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
  @override
  String get id => 'simple_click_game';

  @override
  String get name => '点击游戏';

  @override
  String get description => '点击按钮获得分数';

  @override
  IconData get icon => Icons.touch_app;

  /// 点击次数
  int _clickCount = 0;
  int get clickCount => _clickCount;

  /// 目标点击次数
  int _targetClicks = 50;
  int get targetClicks => _targetClicks;

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
    if (gameState == SimpleGameState.playing) {
      _clickCount++;
      updateScore(10);

      if (_clickCount >= _targetClicks) {
        _gameState = SimpleGameState.victory;
        endGame();
      }

      notifyListeners();
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
          if (gameState == SimpleGameState.playing) ...<Widget>[
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
          ] else if (gameState == SimpleGameState.victory) ...<Widget>[
            const Text(
              '恭喜胜利！',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
          ] else if (gameState == SimpleGameState.gameOver) ...<Widget>[
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
        if (gameState == SimpleGameState.notStarted ||
            gameState == SimpleGameState.gameOver) ...<Widget>[
          ElevatedButton(
            onPressed: startGame,
            child: const Text('开始游戏'),
          ),
        ],
        if (gameState == SimpleGameState.playing) ...<Widget>[
          ElevatedButton(
            onPressed: pauseGame,
            child: const Text('暂停'),
          ),
        ],
        if (gameState == SimpleGameState.paused) ...<Widget>[
          ElevatedButton(
            onPressed: resumeGame,
            child: const Text('继续'),
          ),
        ],
        if (gameState != SimpleGameState.notStarted) ...<Widget>[
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
  @override
  String get id => 'simple_guess_game';

  @override
  String get name => '猜数字';

  @override
  String get description => '猜测1-100之间的随机数字';

  @override
  IconData get icon => Icons.quiz;

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
    if (gameState != SimpleGameState.playing) return;

    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final guess = int.tryParse(input);
    if (guess == null || guess < 1 || guess > 100) {
      _hint = '请输入1-100之间的有效数字';
      notifyListeners();
      return;
    }

    _guessCount++;

    if (guess == _targetNumber) {
      _gameState = SimpleGameState.victory;
      _hint = '恭喜！猜对了！';
      updateScore(100 - _guessCount * 10);
      endGame();
    } else if (_guessCount >= _maxGuesses) {
      _gameState = SimpleGameState.gameOver;
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
    notifyListeners();
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
            if (gameState == SimpleGameState.playing) ...<Widget>[
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
            ] else if (gameState == SimpleGameState.notStarted) ...<Widget>[
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
        if (gameState == SimpleGameState.notStarted ||
            gameState == SimpleGameState.gameOver ||
            gameState == SimpleGameState.victory) ...<Widget>[
          ElevatedButton(
            onPressed: startGame,
            child: const Text('开始游戏'),
          ),
        ],
        if (gameState == SimpleGameState.playing) ...<Widget>[
          ElevatedButton(
            onPressed: pauseGame,
            child: const Text('暂停'),
          ),
        ],
        if (gameState == SimpleGameState.paused) ...<Widget>[
          ElevatedButton(
            onPressed: resumeGame,
            child: const Text('继续'),
          ),
        ],
        if (gameState != SimpleGameState.notStarted) ...<Widget>[
          ElevatedButton(
            onPressed: restartGame,
            child: const Text('重新开始'),
          ),
        ],
      ],
    );
}
