/*
---------------------------------------------------------------
File name:          game_area.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊游戏区域组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 游戏区域组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/games/index.dart';

/// 游戏区域组件
class GameArea extends StatefulWidget {
  const GameArea({
    super.key,
    this.width = 800,
    this.height = 600,
    this.backgroundColor,
    this.showControls = true,
  });

  /// 游戏区域宽度
  final double width;

  /// 游戏区域高度
  final double height;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示控制面板
  final bool showControls;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = SimpleGameManager.instance;
    _gameManager.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    _gameManager.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          // 游戏区域标题
          _buildGameAreaHeader(),

          // 游戏内容区域
          Expanded(
            child: _buildGameContent(),
          ),

          // 游戏控制面板
          if (widget.showControls) _buildGameControls(),
        ],
      ),
    );
  }

  Widget _buildGameAreaHeader() {
    final activeGame = _gameManager.activeGame;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            activeGame?.icon ?? Icons.games,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            activeGame?.name ?? '游戏区域',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // 游戏状态指示器
          if (activeGame != null)
            _buildGameStateIndicator(activeGame.gameState),
        ],
      ),
    );
  }

  Widget _buildGameStateIndicator(GameState state) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case GameState.notStarted:
        color = Colors.grey;
        text = '未开始';
        icon = Icons.play_circle_outline;
      case GameState.playing:
        color = Colors.green;
        text = '进行中';
        icon = Icons.play_circle_filled;
      case GameState.paused:
        color = Colors.orange;
        text = '暂停';
        icon = Icons.pause_circle_filled;
      case GameState.gameOver:
        color = Colors.red;
        text = '游戏结束';
        icon = Icons.stop_circle;
      case GameState.victory:
        color = Colors.purple;
        text = '胜利';
        icon = Icons.emoji_events;
      case GameState.defeat:
        color = Colors.red;
        text = '失败';
        icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final activeGame = _gameManager.activeGame;

    if (activeGame == null) {
      return _buildNoGameContent();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: activeGame.buildGameWidget(),
    );
  }

  Widget _buildNoGameContent() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.games,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '没有激活的游戏',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请从游戏列表中选择一个游戏',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showGameSelector,
              icon: const Icon(Icons.list),
              label: const Text('选择游戏'),
            ),
          ],
        ),
      );

  Widget _buildGameControls() {
    final activeGame = _gameManager.activeGame;

    if (activeGame == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: <Widget>[
          // 游戏信息
          _buildGameInfo(activeGame),

          const SizedBox(height: 12),

          // 游戏控制按钮
          activeGame.buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildGameInfo(SimpleGame game) => Row(
        children: <Widget>[
          Expanded(
            child: _buildInfoItem('分数', '${game.score}', Colors.blue),
          ),
          Expanded(
            child: _buildInfoItem('最高分', '${game.highScore}', Colors.orange),
          ),
          if (game.gameTime > 0)
            Expanded(
              child: _buildInfoItem('时间', '${game.gameTime}秒', Colors.green),
            ),
        ],
      );

  Widget _buildInfoItem(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  void _showGameSelector() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('选择游戏'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: _buildGameList(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameList() {
    final games = _gameManager.games;

    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (BuildContext context, int index) {
        final game = games.values.elementAt(index);
        final isActive = _gameManager.activeGameId == game.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(game.icon, color: Colors.blue),
            title: Text(game.name),
            subtitle: Text(game.description),
            trailing: isActive
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            selected: isActive,
            onTap: () {
              _gameManager.activateGame(game.id);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

/// 游戏选择器对话框
class GameSelectorDialog extends StatefulWidget {
  const GameSelectorDialog({super.key});

  @override
  State<GameSelectorDialog> createState() => _GameSelectorDialogState();
}

class _GameSelectorDialogState extends State<GameSelectorDialog> {
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = SimpleGameManager.instance;
  }

  @override
  Widget build(BuildContext context) {
    final games = _gameManager.games;

    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              '选择游戏',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (BuildContext context, int index) {
                  final game = games.values.elementAt(index);
                  final isActive = _gameManager.activeGameId == game.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(game.icon, color: Colors.blue),
                      title: Text(game.name),
                      subtitle: Text(game.description),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      selected: isActive,
                      onTap: () {
                        _gameManager.activateGame(game.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
