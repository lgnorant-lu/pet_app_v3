/*
---------------------------------------------------------------
File name:          tool_toolbar.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊工具栏组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 工具栏组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/tools/index.dart';
import 'package:creative_workshop/src/core/projects/index.dart';

/// 工具栏布局方向
enum ToolbarOrientation {
  /// 水平布局
  horizontal,

  /// 垂直布局
  vertical,
}

/// 工具栏组件
class ToolToolbar extends StatefulWidget {
  const ToolToolbar({
    super.key,
    this.orientation = ToolbarOrientation.horizontal,
    this.backgroundColor,
    this.selectedColor,
    this.iconSize = 24,
    this.padding = const EdgeInsets.all(8),
  });

  /// 布局方向
  final ToolbarOrientation orientation;

  /// 背景颜色
  final Color? backgroundColor;

  /// 选中颜色
  final Color? selectedColor;

  /// 图标大小
  final double iconSize;

  /// 内边距
  final EdgeInsets padding;

  @override
  State<ToolToolbar> createState() => _ToolToolbarState();
}

class _ToolToolbarState extends State<ToolToolbar> {
  late SimpleToolManager _toolManager;
  late ProjectManager _projectManager;

  @override
  void initState() {
    super.initState();
    _toolManager = SimpleToolManager.instance;
    _projectManager = ProjectManager.instance;
    _toolManager.addListener(_onToolChanged);
    _projectManager.addListener(_onProjectChanged);
  }

  @override
  void dispose() {
    _toolManager.removeListener(_onToolChanged);
    _projectManager.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onToolChanged() {
    setState(() {});
  }

  void _onProjectChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.orientation == ToolbarOrientation.horizontal
          ? _buildHorizontalToolbar(selectedColor)
          : _buildVerticalToolbar(selectedColor),
    );
  }

  Widget _buildHorizontalToolbar(Color selectedColor) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 绘画工具组
          _buildToolGroup('绘画工具', <Widget>[
            _buildToolButton(
              icon: Icons.brush,
              label: '画笔',
              isSelected: _toolManager.activeTool is SimpleBrushTool,
              selectedColor: selectedColor,
              onPressed: _activateBrushTool,
            ),
            _buildToolButton(
              icon: Icons.edit,
              label: '铅笔',
              isSelected: _toolManager.activeTool is SimplePencilTool,
              selectedColor: selectedColor,
              onPressed: _activatePencilTool,
            ),
          ]),

          const SizedBox(width: 8),
          _buildDivider(),
          const SizedBox(width: 8),

          // 形状工具组
          _buildToolGroup('形状工具', <Widget>[
            _buildToolButton(
              icon: Icons.crop_square,
              label: '矩形',
              isSelected: false, // TODO: 实现形状工具选择状态
              selectedColor: selectedColor,
              onPressed: _showShapeTools,
            ),
            _buildToolButton(
              icon: Icons.circle_outlined,
              label: '圆形',
              isSelected: false,
              selectedColor: selectedColor,
              onPressed: _showShapeTools,
            ),
          ]),

          const SizedBox(width: 8),
          _buildDivider(),
          const SizedBox(width: 8),

          // 操作工具组
          _buildToolGroup('操作', <Widget>[
            _buildActionButton(
              icon: Icons.undo,
              label: '撤销',
              onPressed: _undo,
            ),
            _buildActionButton(
              icon: Icons.redo,
              label: '重做',
              onPressed: _redo,
            ),
            _buildActionButton(
              icon: Icons.clear,
              label: '清空',
              onPressed: _clearCanvas,
            ),
          ]),
        ],
      );

  Widget _buildVerticalToolbar(Color selectedColor) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 绘画工具组
          _buildToolButton(
            icon: Icons.brush,
            label: '画笔',
            isSelected: _toolManager.activeTool is SimpleBrushTool,
            selectedColor: selectedColor,
            onPressed: _activateBrushTool,
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            icon: Icons.edit,
            label: '铅笔',
            isSelected: _toolManager.activeTool is SimplePencilTool,
            selectedColor: selectedColor,
            onPressed: _activatePencilTool,
          ),

          const SizedBox(height: 8),
          _buildDivider(),
          const SizedBox(height: 8),

          // 形状工具组
          _buildToolButton(
            icon: Icons.crop_square,
            label: '矩形',
            isSelected: false,
            selectedColor: selectedColor,
            onPressed: _showShapeTools,
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            icon: Icons.circle_outlined,
            label: '圆形',
            isSelected: false,
            selectedColor: selectedColor,
            onPressed: _showShapeTools,
          ),

          const SizedBox(height: 8),
          _buildDivider(),
          const SizedBox(height: 8),

          // 操作工具组
          _buildActionButton(
            icon: Icons.undo,
            label: '撤销',
            onPressed: _undo,
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            icon: Icons.redo,
            label: '重做',
            onPressed: _redo,
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            icon: Icons.clear,
            label: '清空',
            onPressed: _clearCanvas,
          ),
        ],
      );

  Widget _buildToolGroup(String title, List<Widget> tools) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: tools,
          ),
        ],
      );

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onPressed,
  }) =>
      Tooltip(
        message: label,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: isSelected
                ? selectedColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(color: selectedColor, width: 2)
                      : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: widget.iconSize,
                  color: isSelected ? selectedColor : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) =>
      Tooltip(
        message: label,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  icon,
                  size: widget.iconSize,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildDivider() => widget.orientation == ToolbarOrientation.horizontal
      ? Container(
          width: 1,
          height: 40,
          color: Colors.grey.shade300,
        )
      : Container(
          width: 40,
          height: 1,
          color: Colors.grey.shade300,
        );

  void _activateBrushTool() {
    final brushTools = _toolManager.brushTools;
    if (brushTools.isNotEmpty) {
      final defaultBrush = brushTools.values.first;
      _toolManager.activateBrushTool(defaultBrush.id);
    }
  }

  void _activatePencilTool() {
    final pencilTools = _toolManager.pencilTools;
    if (pencilTools.isNotEmpty) {
      final defaultPencil = pencilTools.values.first;
      _toolManager.activatePencilTool(defaultPencil.id);
    }
  }

  void _showShapeTools() {
    // TODO: 显示形状工具选择对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('形状工具功能即将推出')),
    );
  }

  void _undo() {
    // TODO: 实现撤销功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('撤销功能即将推出')),
    );
  }

  void _redo() {
    // TODO: 实现重做功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重做功能即将推出')),
    );
  }

  void _clearCanvas() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('清空画布'),
        content: const Text('确定要清空画布吗？此操作无法撤销。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现清空画布功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('画布已清空')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
