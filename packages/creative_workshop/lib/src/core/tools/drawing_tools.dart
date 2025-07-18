/*
---------------------------------------------------------------
File name:          drawing_tools.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊绘画工具插件实现
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 绘画工具插件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 简化的画笔工具实现
class SimpleBrushTool extends ChangeNotifier {
  /// 工具ID
  String get id => 'simple_brush_tool';

  /// 工具名称
  String get name => '画笔工具';

  /// 工具描述
  String get description => '用于自由绘画的画笔工具';

  /// 工具图标
  IconData get icon => Icons.brush;

  /// 画笔大小
  double _brushSize = 5;
  double get brushSize => _brushSize;
  set brushSize(double value) {
    _brushSize = value;
    notifyListeners();
  }

  /// 画笔颜色
  Color _brushColor = Colors.black;
  Color get brushColor => _brushColor;
  set brushColor(Color value) {
    _brushColor = value;
    notifyListeners();
  }

  /// 画笔透明度
  double _brushOpacity = 1;
  double get brushOpacity => _brushOpacity;
  set brushOpacity(double value) {
    _brushOpacity = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 当前绘制路径
  Path? _currentPath;
  Path? get currentPath => _currentPath;

  /// 绘制点列表
  final List<Offset> _points = <Offset>[];
  List<Offset> get points => List.unmodifiable(_points);

  /// 开始绘制
  void startDrawing(Offset position) {
    _currentPath = Path();
    _points.clear();
    _points.add(position);
    _currentPath!.moveTo(position.dx, position.dy);
    notifyListeners();
  }

  /// 更新绘制
  void updateDrawing(Offset position) {
    if (_currentPath != null) {
      _points.add(position);
      _currentPath!.lineTo(position.dx, position.dy);
      notifyListeners();
    }
  }

  /// 结束绘制
  void endDrawing() {
    if (_currentPath != null && _points.isNotEmpty) {
      // 这里可以添加路径优化逻辑
      _finalizeDrawing();
      _currentPath = null;
      _points.clear();
      notifyListeners();
    }
  }

  /// 完成绘制
  void _finalizeDrawing() {
    // 发送绘制完成事件（简化版本）
    debugPrint('绘制完成: ${_points.length} 个点');
  }

  /// 绘制到画布
  void paint(Canvas canvas, Size size) {
    if (_currentPath != null && _points.isNotEmpty) {
      final paint = Paint()
        ..color = _brushColor.withOpacity(_brushOpacity)
        ..strokeWidth = _brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(_currentPath!, paint);
    }
  }

  /// 获取配置面板
  Widget buildConfigurationPanel() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('画笔设置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        const SizedBox(height: 8),

        // 画笔大小
        Text('大小: ${_brushSize.toInt()}'),
        Slider(
          value: _brushSize,
          min: 1,
          max: 50,
          divisions: 49,
          onChanged: (double value) {
            brushSize = value;
          },
        ),

        // 画笔透明度
        Text('透明度: ${(_brushOpacity * 100).toInt()}%'),
        Slider(
          value: _brushOpacity,
          divisions: 100,
          onChanged: (double value) {
            brushOpacity = value;
          },
        ),

        // 颜色选择
        const Text('颜色'),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _brushColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
}

/// 简化的铅笔工具实现
class SimplePencilTool extends ChangeNotifier {
  /// 工具ID
  String get id => 'simple_pencil_tool';

  /// 工具名称
  String get name => '铅笔工具';

  /// 工具描述
  String get description => '用于精细绘画的铅笔工具';

  /// 工具图标
  IconData get icon => Icons.edit;

  /// 铅笔大小
  double _pencilSize = 2;
  double get pencilSize => _pencilSize;
  set pencilSize(double value) {
    _pencilSize = value;
    notifyListeners();
  }

  /// 铅笔颜色
  Color _pencilColor = Colors.grey[700]!;
  Color get pencilColor => _pencilColor;
  set pencilColor(Color value) {
    _pencilColor = value;
    notifyListeners();
  }

  /// 当前绘制路径
  Path? _currentPath;
  Path? get currentPath => _currentPath;

  /// 开始绘制
  void startDrawing(Offset position) {
    _currentPath = Path();
    _currentPath!.moveTo(position.dx, position.dy);
    notifyListeners();
  }

  /// 更新绘制
  void updateDrawing(Offset position) {
    if (_currentPath != null) {
      _currentPath!.lineTo(position.dx, position.dy);
      notifyListeners();
    }
  }

  /// 结束绘制
  void endDrawing() {
    if (_currentPath != null) {
      debugPrint('铅笔绘制完成');
      _currentPath = null;
      notifyListeners();
    }
  }

  /// 绘制到画布
  void paint(Canvas canvas, Size size) {
    if (_currentPath != null) {
      final paint = Paint()
        ..color = _pencilColor
        ..strokeWidth = _pencilSize
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(_currentPath!, paint);
    }
  }

  /// 获取配置面板
  Widget buildConfigurationPanel() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('铅笔设置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        const SizedBox(height: 8),
        Text('大小: ${_pencilSize.toInt()}'),
        Slider(
          value: _pencilSize,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (double value) {
            pencilSize = value;
          },
        ),
        const Text('颜色'),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _pencilColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
}
