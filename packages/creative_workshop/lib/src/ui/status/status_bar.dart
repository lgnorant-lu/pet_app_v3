/*
---------------------------------------------------------------
File name:          status_bar.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊状态栏组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 状态栏组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/tools/index.dart';
import 'package:creative_workshop/src/core/projects/index.dart';
import 'package:creative_workshop/src/core/games/index.dart';

/// 状态栏组件
class StatusBar extends StatefulWidget {
  const StatusBar({
    super.key,
    this.height = 32,
    this.backgroundColor,
    this.showProjectInfo = true,
    this.showToolInfo = true,
    this.showGameInfo = true,
  });

  /// 状态栏高度
  final double height;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示项目信息
  final bool showProjectInfo;

  /// 是否显示工具信息
  final bool showToolInfo;

  /// 是否显示游戏信息
  final bool showGameInfo;

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late SimpleToolManager _toolManager;
  late ProjectManager _projectManager;
  late SimpleGameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _toolManager = SimpleToolManager.instance;
    _projectManager = ProjectManager.instance;
    _gameManager = SimpleGameManager.instance;

    _toolManager.addListener(_onStateChanged);
    _projectManager.addListener(_onStateChanged);
    _gameManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _toolManager.removeListener(_onStateChanged);
    _projectManager.removeListener(_onStateChanged);
    _gameManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: <Widget>[
          // 左侧状态信息
          Expanded(
            child: Row(
              children: <Widget>[
                // 项目信息
                if (widget.showProjectInfo) _buildProjectInfo(),

                // 分隔符
                if (widget.showProjectInfo && widget.showToolInfo)
                  _buildDivider(),

                // 工具信息
                if (widget.showToolInfo) _buildToolInfo(),

                // 分隔符
                if ((widget.showProjectInfo || widget.showToolInfo) &&
                    widget.showGameInfo)
                  _buildDivider(),

                // 游戏信息
                if (widget.showGameInfo) _buildGameInfo(),
              ],
            ),
          ),

          // 右侧系统信息
          _buildSystemInfo(),
        ],
      ),
    );
  }

  Widget _buildProjectInfo() {
    final currentProject = _projectManager.currentProject;

    if (currentProject == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '没有打开的项目',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _getProjectTypeIcon(currentProject.type),
            size: 14,
            color: _getProjectTypeColor(currentProject.type),
          ),
          const SizedBox(width: 6),
          Text(
            currentProject.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _getProjectStatusColor(currentProject.status)
                  .withOpacity(0.1),
              border: Border.all(
                color: _getProjectStatusColor(currentProject.status),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getProjectStatusName(currentProject.status),
              style: TextStyle(
                fontSize: 10,
                color: _getProjectStatusColor(currentProject.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolInfo() {
    final activeTool = _toolManager.activeTool;

    if (activeTool == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '没有选择工具',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _getToolIcon(activeTool),
            size: 14,
            color: Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            _getToolName(activeTool),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Text(
            _getToolDetails(activeTool),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    final activeGame = _gameManager.activeGame;

    if (activeGame == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '没有激活的游戏',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            activeGame.icon,
            size: 14,
            color: Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            activeGame.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _getGameStateColor(activeGame.gameState).withOpacity(0.1),
              border: Border.all(
                color: _getGameStateColor(activeGame.gameState),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getGameStateName(activeGame.gameState),
              style: TextStyle(
                fontSize: 10,
                color: _getGameStateColor(activeGame.gameState),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '分数: ${activeGame.score}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 内存使用情况
            _buildSystemInfoItem(
              icon: Icons.memory,
              label: '内存',
              value: '${_getMemoryUsage()}MB',
              color: Colors.orange,
            ),

            const SizedBox(width: 12),

            // 时间显示
            _buildSystemInfoItem(
              icon: Icons.access_time,
              label: '时间',
              value: _getCurrentTime(),
              color: Colors.blue,
            ),
          ],
        ),
      );

  Widget _buildSystemInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      );

  Widget _buildDivider() => Container(
        width: 1,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.grey.shade300,
      );

  // 辅助方法
  IconData _getProjectTypeIcon(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return Icons.brush;
      case ProjectType.design:
        return Icons.design_services;
      case ProjectType.game:
        return Icons.games;
      case ProjectType.animation:
        return Icons.movie;
      case ProjectType.model3d:
        return Icons.view_in_ar;
      case ProjectType.mixed:
        return Icons.auto_awesome;
      case ProjectType.custom:
        return Icons.extension;
    }
  }

  Color _getProjectTypeColor(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return Colors.red;
      case ProjectType.design:
        return Colors.blue;
      case ProjectType.game:
        return Colors.green;
      case ProjectType.animation:
        return Colors.purple;
      case ProjectType.model3d:
        return Colors.orange;
      case ProjectType.mixed:
        return Colors.teal;
      case ProjectType.custom:
        return Colors.grey;
    }
  }

  String _getProjectStatusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return '草稿';
      case ProjectStatus.inProgress:
        return '进行中';
      case ProjectStatus.completed:
        return '已完成';
      case ProjectStatus.published:
        return '已发布';
      case ProjectStatus.archived:
        return '已归档';
    }
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.published:
        return Colors.purple;
      case ProjectStatus.archived:
        return Colors.orange;
    }
  }

  IconData _getToolIcon(dynamic tool) {
    if (tool is SimpleBrushTool) {
      return Icons.brush;
    } else if (tool is SimplePencilTool) {
      return Icons.edit;
    }
    return Icons.build;
  }

  String _getToolName(dynamic tool) {
    if (tool is SimpleBrushTool) {
      return '画笔';
    } else if (tool is SimplePencilTool) {
      return '铅笔';
    }
    return tool.runtimeType.toString();
  }

  String _getToolDetails(dynamic tool) {
    if (tool is SimpleBrushTool) {
      return '大小: ${tool.brushSize.toInt()}';
    } else if (tool is SimplePencilTool) {
      return '大小: ${tool.pencilSize.toInt()}';
    }
    return '';
  }

  String _getGameStateName(GameState state) {
    switch (state) {
      case GameState.notStarted:
        return '未开始';
      case GameState.playing:
        return '进行中';
      case GameState.paused:
        return '暂停';
      case GameState.gameOver:
        return '结束';
      case GameState.victory:
        return '胜利';
      case GameState.defeat:
        return '失败';
    }
  }

  Color _getGameStateColor(GameState state) {
    switch (state) {
      case GameState.notStarted:
        return Colors.grey;
      case GameState.playing:
        return Colors.green;
      case GameState.paused:
        return Colors.orange;
      case GameState.gameOver:
        return Colors.red;
      case GameState.victory:
        return Colors.purple;
      case GameState.defeat:
        return Colors.red;
    }
  }

  int _getMemoryUsage() {
    try {
      // 在实际应用中，可以使用以下方法获取内存使用情况：
      // 1. 使用 dart:developer 的 Service.getIsolateMemoryUsage()
      // 2. 使用 dart:io 的 ProcessInfo.currentRss
      // 3. 使用第三方包如 device_info_plus

      // 这里提供一个基于时间和随机因子的模拟实现
      final now = DateTime.now();
      const baseMemory = 64; // 基础内存 64MB
      final timeVariation =
          (now.millisecondsSinceEpoch % 1000) / 10; // 0-100的时间变化
      final randomFactor = (now.microsecond % 50); // 0-50的随机因子

      final totalMemory = baseMemory + timeVariation + randomFactor;
      return totalMemory.round();
    } catch (e) {
      // 如果获取失败，返回默认值
      return 128;
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
