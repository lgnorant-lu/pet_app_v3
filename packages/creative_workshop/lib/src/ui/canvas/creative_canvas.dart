/*
---------------------------------------------------------------
File name:          creative_canvas.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊画布组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意画布组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:creative_workshop/src/core/tools/index.dart';
import 'package:creative_workshop/src/core/projects/index.dart';

/// 画布模式枚举
enum CanvasMode {
  /// 绘画模式
  drawing,

  /// 设计模式
  design,

  /// 游戏模式
  game,

  /// 预览模式
  preview,
}

/// 创意画布组件
class CreativeCanvas extends StatefulWidget {
  const CreativeCanvas({
    super.key,
    this.width = 800,
    this.height = 600,
    this.backgroundColor = Colors.white,
    this.mode = CanvasMode.drawing,
    this.project,
  });

  /// 画布宽度
  final double width;

  /// 画布高度
  final double height;

  /// 背景颜色
  final Color backgroundColor;

  /// 画布模式
  final CanvasMode mode;

  /// 关联的项目
  final CreativeProject? project;

  @override
  State<CreativeCanvas> createState() => _CreativeCanvasState();
}

class _CreativeCanvasState extends State<CreativeCanvas> {
  late SimpleToolManager _toolManager;
  late ProjectManager _projectManager;

  /// 画布变换矩阵
  Matrix4 _transform = Matrix4.identity();

  /// 缩放级别
  double _scale = 1;

  /// 平移偏移
  Offset _offset = Offset.zero;

  /// 绘制路径列表
  final List<Path> _paths = <Path>[];

  /// 绘制颜色列表
  final List<Color> _pathColors = <Color>[];

  /// 绘制宽度列表
  final List<double> _pathWidths = <double>[];

  /// 当前绘制路径
  Path? _currentPath;

  /// 是否正在绘制
  bool _isDrawing = false;

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
  Widget build(BuildContext context) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: <Widget>[
              // 背景网格
              if (widget.mode == CanvasMode.design) _buildGrid(),

              // 主画布区域
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: Transform(
                    transform: _transform,
                    child: CustomPaint(
                      painter: _CanvasPainter(
                        paths: _paths,
                        pathColors: _pathColors,
                        pathWidths: _pathWidths,
                        currentPath: _currentPath,
                        currentColor: _getCurrentColor(),
                        currentWidth: _getCurrentWidth(),
                        mode: widget.mode,
                      ),
                      size: Size(widget.width, widget.height),
                    ),
                  ),
                ),
              ),

              // 画布信息覆盖层
              _buildCanvasOverlay(),
            ],
          ),
        ),
      );

  Widget _buildGrid() => CustomPaint(
        painter: _GridPainter(
          gridSize: 20,
          gridColor: Colors.grey.shade200,
        ),
        size: Size(widget.width, widget.height),
      );

  Widget _buildCanvasOverlay() => Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${widget.width.toInt()} x ${widget.height.toInt()} | ${(_scale * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );

  void _handlePanStart(DragStartDetails details) {
    if (widget.mode == CanvasMode.drawing) {
      _startDrawing(details.localPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.mode == CanvasMode.drawing && _isDrawing) {
      _updateDrawing(details.localPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.mode == CanvasMode.drawing && _isDrawing) {
      _endDrawing();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // 缩放开始
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_scale * details.scale).clamp(0.1, 5.0);
      _offset += details.focalPointDelta;
      _updateTransform();
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // 缩放结束
  }

  void _updateTransform() {
    _transform = Matrix4.identity()
      ..translate(_offset.dx, _offset.dy)
      ..scale(_scale);
  }

  void _startDrawing(Offset position) {
    final activeTool = _toolManager.activeTool;
    if (activeTool is SimpleBrushTool || activeTool is SimplePencilTool) {
      _isDrawing = true;
      _currentPath = Path();
      _currentPath!.moveTo(position.dx, position.dy);
      setState(() {});
    }
  }

  void _updateDrawing(Offset position) {
    if (_currentPath != null) {
      _currentPath!.lineTo(position.dx, position.dy);
      setState(() {});
    }
  }

  void _endDrawing() {
    if (_currentPath != null) {
      _paths.add(_currentPath!);
      _pathColors.add(_getCurrentColor());
      _pathWidths.add(_getCurrentWidth());
      _currentPath = null;
      _isDrawing = false;
      setState(() {});

      // 保存到项目
      _saveToProject();
    }
  }

  Color _getCurrentColor() {
    final activeTool = _toolManager.activeTool;
    if (activeTool is SimpleBrushTool) {
      return activeTool.brushColor;
    } else if (activeTool is SimplePencilTool) {
      return activeTool.pencilColor;
    }
    return Colors.black;
  }

  double _getCurrentWidth() {
    final activeTool = _toolManager.activeTool;
    if (activeTool is SimpleBrushTool) {
      return activeTool.brushSize;
    } else if (activeTool is SimplePencilTool) {
      return activeTool.pencilSize;
    }
    return 2;
  }

  void _saveToProject() {
    final currentProject = _projectManager.currentProject;
    if (currentProject != null) {
      // 将绘制数据保存到项目
      final drawingData = <String, Object>{
        'paths': _paths.length,
        'lastModified': DateTime.now().toIso8601String(),
      };

      final updatedProject = currentProject.copyWith(
        data: <String, dynamic>{
          ...currentProject.data,
          'drawing': drawingData,
        },
      );

      _projectManager.saveProject(updatedProject);
    }
  }

  /// 清空画布
  void clearCanvas() {
    setState(() {
      _paths.clear();
      _pathColors.clear();
      _pathWidths.clear();
      _currentPath = null;
      _isDrawing = false;
    });
    _saveToProject();
  }

  /// 撤销最后一步
  void undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _paths.removeLast();
        _pathColors.removeLast();
        _pathWidths.removeLast();
      });
      _saveToProject();
    }
  }

  /// 重置缩放和位置
  void resetView() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
      _updateTransform();
    });
  }
}

/// 画布绘制器
class _CanvasPainter extends CustomPainter {
  const _CanvasPainter({
    required this.paths,
    required this.pathColors,
    required this.pathWidths,
    required this.currentColor,
    required this.currentWidth,
    required this.mode,
    this.currentPath,
  });

  final List<Path> paths;
  final List<Color> pathColors;
  final List<double> pathWidths;
  final Path? currentPath;
  final Color currentColor;
  final double currentWidth;
  final CanvasMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制已完成的路径
    for (int i = 0; i < paths.length; i++) {
      final paint = Paint()
        ..color = pathColors[i]
        ..strokeWidth = pathWidths[i]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(paths[i], paint);
    }

    // 绘制当前路径
    if (currentPath != null) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(currentPath!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) =>
      paths != oldDelegate.paths ||
      currentPath != oldDelegate.currentPath ||
      currentColor != oldDelegate.currentColor ||
      currentWidth != oldDelegate.currentWidth;
}

/// 网格绘制器
class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.gridSize,
    required this.gridColor,
  });

  final double gridSize;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      gridSize != oldDelegate.gridSize || gridColor != oldDelegate.gridColor;
}
