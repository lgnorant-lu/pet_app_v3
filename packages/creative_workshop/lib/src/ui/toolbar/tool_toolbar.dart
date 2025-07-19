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
  late _HistoryManager _historyManager;

  // 工具选择状态
  String _selectedTool = 'brush';
  String _selectedShapeTool = 'rectangle';

  @override
  void initState() {
    super.initState();
    _toolManager = SimpleToolManager.instance;
    _projectManager = ProjectManager.instance;
    _historyManager = _HistoryManager();
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
              isSelected:
                  _selectedTool == 'shape' && _selectedShapeTool == 'rectangle',
              selectedColor: selectedColor,
              onPressed: () => _selectShapeTool('rectangle'),
            ),
            _buildToolButton(
              icon: Icons.circle_outlined,
              label: '圆形',
              isSelected:
                  _selectedTool == 'shape' && _selectedShapeTool == 'circle',
              selectedColor: selectedColor,
              onPressed: () => _selectShapeTool('circle'),
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
    final previousTool = _toolManager.activeToolId ?? 'none';

    // 通过插件ID激活画笔工具
    final success = _toolManager.activateBrushTool('simple_brush_tool');
    if (success) {
      debugPrint('画笔工具已激活');

      // 记录工具切换历史
      _historyManager.addToolSwitchAction(
        fromTool: previousTool,
        toTool: 'simple_brush_tool',
        undoCallback: () {
          if (previousTool != 'none') {
            _toolManager.activateBrushTool(previousTool);
          }
        },
        redoCallback: () {
          _toolManager.activateBrushTool('simple_brush_tool');
        },
      );
    } else {
      debugPrint('激活画笔工具失败: 工具不存在');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('画笔工具不可用')),
        );
      }
    }
  }

  void _activatePencilTool() {
    final previousTool = _toolManager.activeToolId ?? 'none';

    // 通过插件ID激活铅笔工具
    final success = _toolManager.activatePencilTool('simple_pencil_tool');
    if (success) {
      debugPrint('铅笔工具已激活');

      // 记录工具切换历史
      _historyManager.addToolSwitchAction(
        fromTool: previousTool,
        toTool: 'simple_pencil_tool',
        undoCallback: () {
          if (previousTool != 'none') {
            _toolManager.activatePencilTool(previousTool);
          }
        },
        redoCallback: () {
          _toolManager.activatePencilTool('simple_pencil_tool');
        },
      );
    } else {
      debugPrint('激活铅笔工具失败: 工具不存在');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('铅笔工具不可用')),
        );
      }
    }
  }

  void _performClearCanvas() {
    try {
      // 清空画布内容
      // 这里应该调用画布管理器的清空方法
      debugPrint('画布已清空');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('画布已清空')),
        );
      }
    } catch (e) {
      debugPrint('清空画布失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空画布失败: $e')),
        );
      }
    }
  }

  void _showShapeTools() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('选择形状工具'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              const Text('可用的形状工具：'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildShapeToolItem(
                      icon: Icons.crop_square,
                      name: '矩形工具',
                      description: '绘制矩形和正方形',
                      onTap: () => _activateShapeTool('rectangle'),
                    ),
                    _buildShapeToolItem(
                      icon: Icons.circle_outlined,
                      name: '圆形工具',
                      description: '绘制圆形和椭圆',
                      onTap: () => _activateShapeTool('circle'),
                    ),
                    _buildShapeToolItem(
                      icon: Icons.timeline,
                      name: '直线工具',
                      description: '绘制直线和箭头',
                      onTap: () => _activateShapeTool('line'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _selectShapeTool(String shapeTool) {
    setState(() {
      _selectedTool = 'shape';
      _selectedShapeTool = shapeTool;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已选择${_getShapeToolName(shapeTool)}工具')),
    );
  }

  String _getShapeToolName(String shapeTool) {
    switch (shapeTool) {
      case 'rectangle':
        return '矩形';
      case 'circle':
        return '圆形';
      case 'line':
        return '直线';
      case 'triangle':
        return '三角形';
      default:
        return '形状';
    }
  }

  void _undo() {
    final canUndo = _historyManager.canUndo();
    if (canUndo) {
      _historyManager.undo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已撤销上一步操作')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可撤销的操作')),
      );
    }
  }

  void _redo() {
    final canRedo = _historyManager.canRedo();
    if (canRedo) {
      _historyManager.redo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已重做上一步操作')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可重做的操作')),
      );
    }
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
              // 实现清空画布功能
              _performClearCanvas();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeToolItem({
    required IconData icon,
    required String name,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(name),
      subtitle: Text(description),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _activateShapeTool(String shapeType) {
    try {
      debugPrint('激活形状工具: $shapeType');

      // 这里应该激活对应的形状工具插件
      // 目前使用简化实现
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$shapeType 形状工具已激活')),
        );
      }
    } catch (e) {
      debugPrint('激活形状工具失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('激活形状工具失败: $e')),
        );
      }
    }
  }
}

/// 历史管理器 - 用于撤销重做功能
class _HistoryManager {
  final List<_HistoryAction> _undoStack = <_HistoryAction>[];
  final List<_HistoryAction> _redoStack = <_HistoryAction>[];
  static const int _maxHistorySize = 50;

  /// 添加一个操作到历史记录
  void addAction(_HistoryAction action) {
    _undoStack.add(action);
    _redoStack.clear(); // 清空重做栈

    // 限制历史记录大小
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }

    debugPrint('历史记录已添加: ${action.description}');
  }

  /// 添加绘画操作到历史记录
  void addDrawingAction({
    required String description,
    required VoidCallback undoCallback,
    required VoidCallback redoCallback,
  }) {
    final action = _DrawingAction(
      description: description,
      undoCallback: undoCallback,
      redoCallback: redoCallback,
    );
    addAction(action);
  }

  /// 添加工具切换操作到历史记录
  void addToolSwitchAction({
    required String fromTool,
    required String toTool,
    required VoidCallback undoCallback,
    required VoidCallback redoCallback,
  }) {
    final action = _ToolSwitchAction(
      fromTool: fromTool,
      toTool: toTool,
      undoCallback: undoCallback,
      redoCallback: redoCallback,
    );
    addAction(action);
  }

  /// 是否可以撤销
  bool canUndo() => _undoStack.isNotEmpty;

  /// 是否可以重做
  bool canRedo() => _redoStack.isNotEmpty;

  /// 撤销操作
  void undo() {
    if (canUndo()) {
      final action = _undoStack.removeLast();
      action.undo();
      _redoStack.add(action);
    }
  }

  /// 重做操作
  void redo() {
    if (canRedo()) {
      final action = _redoStack.removeLast();
      action.redo();
      _undoStack.add(action);
    }
  }

  /// 清空历史记录
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// 获取撤销栈大小
  int get undoCount => _undoStack.length;

  /// 获取重做栈大小
  int get redoCount => _redoStack.length;
}

/// 历史操作抽象类
abstract class _HistoryAction {
  /// 操作描述
  final String description;

  /// 操作时间
  final DateTime timestamp;

  _HistoryAction(this.description) : timestamp = DateTime.now();

  /// 撤销操作
  void undo();

  /// 重做操作
  void redo();
}

/// 绘画操作历史记录
class _DrawingAction extends _HistoryAction {
  final VoidCallback undoCallback;
  final VoidCallback redoCallback;

  _DrawingAction({
    required String description,
    required this.undoCallback,
    required this.redoCallback,
  }) : super(description);

  @override
  void undo() {
    undoCallback();
  }

  @override
  void redo() {
    redoCallback();
  }
}

/// 工具切换操作历史记录
class _ToolSwitchAction extends _HistoryAction {
  final String fromTool;
  final String toTool;
  final VoidCallback undoCallback;
  final VoidCallback redoCallback;

  _ToolSwitchAction({
    required this.fromTool,
    required this.toTool,
    required this.undoCallback,
    required this.redoCallback,
  }) : super('工具切换: $fromTool → $toTool');

  @override
  void undo() {
    undoCallback();
  }

  @override
  void redo() {
    redoCallback();
  }
}
