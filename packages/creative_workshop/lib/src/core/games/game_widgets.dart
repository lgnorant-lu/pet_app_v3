/*
---------------------------------------------------------------
File name:          game_widgets.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊游戏界面组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 游戏界面组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/games/simple_games.dart';
import 'package:creative_workshop/src/core/games/game_manager.dart';
import 'package:creative_workshop/src/core/games/game_plugin.dart';

/// 游戏画布组件
class GameCanvas extends StatefulWidget {
  const GameCanvas({super.key});

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = SimpleGameManager.instance;
    _gameManager.addListener(_onGameManagerChanged);
  }

  @override
  void dispose() {
    _gameManager.removeListener(_onGameManagerChanged);
    super.dispose();
  }

  void _onGameManagerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeGame = _gameManager.activeGame;

    if (activeGame == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.games,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '没有激活的游戏',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '请从游戏列表中选择一个游戏',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: activeGame.buildGameWidget(),
      ),
    );
  }
}

/// 游戏控制面板组件
class GameControlPanel extends StatefulWidget {
  const GameControlPanel({super.key});

  @override
  State<GameControlPanel> createState() => _GameControlPanelState();
}

class _GameControlPanelState extends State<GameControlPanel> {
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = SimpleGameManager.instance;
    _gameManager.addListener(_onGameManagerChanged);
  }

  @override
  void dispose() {
    _gameManager.removeListener(_onGameManagerChanged);
    super.dispose();
  }

  void _onGameManagerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeGame = _gameManager.activeGame;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.gamepad, size: 20),
              const SizedBox(width: 8),
              const Text(
                '游戏控制',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (activeGame != null) ...<Widget>[
                Icon(
                  activeGame.icon,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  activeGame.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (activeGame != null) ...<Widget>[
            // 游戏状态信息
            _buildGameInfo(activeGame),
            const SizedBox(height: 16),

            // 游戏控制按钮
            activeGame.buildControlPanel(),
          ] else ...<Widget>[
            const Center(
              child: Text(
                '请选择一个游戏',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameInfo(SimpleGame game) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('状态:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                _buildGameStateChip(game.gameState),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('分数:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${game.score}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('最高分:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${game.highScore}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            if (game.gameTime > 0) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('时间:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${game.gameTime}秒',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _buildGameStateChip(GameState state) {
    Color color;
    String text;

    switch (state) {
      case GameState.notStarted:
        color = Colors.grey;
        text = '未开始';
      case GameState.playing:
        color = Colors.green;
        text = '进行中';
      case GameState.paused:
        color = Colors.orange;
        text = '暂停';
      case GameState.gameOver:
        color = Colors.red;
        text = '游戏结束';
      case GameState.victory:
        color = Colors.purple;
        text = '胜利';
      case GameState.defeat:
        color = Colors.red;
        text = '失败';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// 游戏选择器组件
class GameSelector extends StatefulWidget {
  const GameSelector({super.key});

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = SimpleGameManager.instance;
    _gameManager.addListener(_onGameManagerChanged);
  }

  @override
  void dispose() {
    _gameManager.removeListener(_onGameManagerChanged);
    super.dispose();
  }

  void _onGameManagerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final games = _gameManager.games;
    final activeGameId = _gameManager.activeGameId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.list, size: 20),
              SizedBox(width: 8),
              Text(
                '游戏列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (games.isEmpty) ...<Widget>[
            const Center(
              child: Text(
                '没有可用的游戏',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ] else ...<Widget>[
            ...games.values
                .map((SimpleGame game) => _buildGameTile(game, activeGameId)),
          ],
        ],
      ),
    );
  }

  Widget _buildGameTile(SimpleGame game, String? activeGameId) {
    final isActive = game.id == activeGameId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          game.icon,
          color: isActive ? Colors.blue : Colors.grey,
        ),
        title: Text(
          game.name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.black,
          ),
        ),
        subtitle: Text(
          game.description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isActive
            ? const Icon(Icons.play_circle_filled, color: Colors.blue)
            : null,
        selected: isActive,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isActive ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        onTap: () {
          if (!isActive) {
            _gameManager.activateGame(game.id);
          }
        },
      ),
    );
  }
}
