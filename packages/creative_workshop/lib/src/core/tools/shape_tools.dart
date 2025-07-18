/*
---------------------------------------------------------------
File name:          shape_tools.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊简化形状工具实现
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 简化形状工具实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 简化的矩形工具实现
class SimpleRectangleTool extends ChangeNotifier {
  /// 工具ID
  String get id => 'simple_rectangle_tool';
  
  /// 工具名称
  String get name => '矩形工具';
  
  /// 工具描述
  String get description => '绘制矩形和正方形';
  
  /// 工具图标
  IconData get icon => Icons.crop_square;
  
  /// 起始点
  Offset? _startPoint;
  
  /// 结束点
  Offset? _endPoint;
  
  /// 边框宽度
  double _strokeWidth = 2;
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double value) {
    _strokeWidth = value;
    notifyListeners();
  }
  
  /// 边框颜色
  Color _strokeColor = Colors.black;
  Color get strokeColor => _strokeColor;
  set strokeColor(Color value) {
    _strokeColor = value;
    notifyListeners();
  }
  
  /// 填充颜色
  Color _fillColor = Colors.transparent;
  Color get fillColor => _fillColor;
  set fillColor(Color value) {
    _fillColor = value;
    notifyListeners();
  }
  
  /// 是否填充
  bool _filled = false;
  bool get filled => _filled;
  set filled(bool value) {
    _filled = value;
    notifyListeners();
  }
  
  /// 开始绘制
  void startDrawing(Offset position) {
    _startPoint = position;
    _endPoint = position;
    notifyListeners();
  }
  
  /// 更新绘制
  void updateDrawing(Offset position) {
    if (_startPoint != null) {
      _endPoint = position;
      notifyListeners();
    }
  }
  
  /// 结束绘制
  void endDrawing() {
    if (_startPoint != null && _endPoint != null) {
      debugPrint('矩形绘制完成: $_startPoint -> $_endPoint');
      _startPoint = null;
      _endPoint = null;
      notifyListeners();
    }
  }
  
  /// 绘制到画布
  void paint(Canvas canvas, Size size) {
    if (_startPoint != null && _endPoint != null) {
      final rect = Rect.fromPoints(_startPoint!, _endPoint!);
      
      if (_filled && _fillColor != Colors.transparent) {
        final fillPaint = Paint()
          ..color = _fillColor
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, fillPaint);
      }
      
      final strokePaint = Paint()
        ..color = _strokeColor
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, strokePaint);
    }
  }
  
  /// 获取配置面板
  Widget buildConfigurationPanel() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('矩形设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Text('边框宽度: ${_strokeWidth.toInt()}'),
        Slider(
          value: _strokeWidth,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (double value) {
            strokeWidth = value;
          },
        ),
        
        Row(
          children: <Widget>[
            const Text('填充'),
            Switch(
              value: _filled,
              onChanged: (bool value) {
                filled = value;
              },
            ),
          ],
        ),
        
        const Text('边框颜色'),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _strokeColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        if (_filled) ...<Widget>[
          const SizedBox(height: 8),
          const Text('填充颜色'),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _fillColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
}

/// 简化的圆形工具实现
class SimpleCircleTool extends ChangeNotifier {
  /// 工具ID
  String get id => 'simple_circle_tool';
  
  /// 工具名称
  String get name => '圆形工具';
  
  /// 工具描述
  String get description => '绘制圆形和椭圆形';
  
  /// 工具图标
  IconData get icon => Icons.circle_outlined;
  
  /// 圆心
  Offset? _center;
  
  /// 半径
  double _radius = 0;
  
  /// 边框宽度
  double _strokeWidth = 2;
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double value) {
    _strokeWidth = value;
    notifyListeners();
  }
  
  /// 边框颜色
  Color _strokeColor = Colors.black;
  Color get strokeColor => _strokeColor;
  set strokeColor(Color value) {
    _strokeColor = value;
    notifyListeners();
  }
  
  /// 填充颜色
  Color _fillColor = Colors.transparent;
  Color get fillColor => _fillColor;
  set fillColor(Color value) {
    _fillColor = value;
    notifyListeners();
  }
  
  /// 是否填充
  bool _filled = false;
  bool get filled => _filled;
  set filled(bool value) {
    _filled = value;
    notifyListeners();
  }
  
  /// 开始绘制
  void startDrawing(Offset position) {
    _center = position;
    _radius = 0.0;
    notifyListeners();
  }
  
  /// 更新绘制
  void updateDrawing(Offset position) {
    if (_center != null) {
      _radius = (_center! - position).distance;
      notifyListeners();
    }
  }
  
  /// 结束绘制
  void endDrawing() {
    if (_center != null && _radius > 0) {
      debugPrint('圆形绘制完成: 中心$_center, 半径$_radius');
      _center = null;
      _radius = 0.0;
      notifyListeners();
    }
  }
  
  /// 绘制到画布
  void paint(Canvas canvas, Size size) {
    if (_center != null && _radius > 0) {
      if (_filled && _fillColor != Colors.transparent) {
        final fillPaint = Paint()
          ..color = _fillColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(_center!, _radius, fillPaint);
      }
      
      final strokePaint = Paint()
        ..color = _strokeColor
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(_center!, _radius, strokePaint);
    }
  }
  
  /// 获取配置面板
  Widget buildConfigurationPanel() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('圆形设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Text('边框宽度: ${_strokeWidth.toInt()}'),
        Slider(
          value: _strokeWidth,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (double value) {
            strokeWidth = value;
          },
        ),
        
        Row(
          children: <Widget>[
            const Text('填充'),
            Switch(
              value: _filled,
              onChanged: (bool value) {
                filled = value;
              },
            ),
          ],
        ),
        
        const Text('边框颜色'),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _strokeColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        if (_filled) ...<Widget>[
          const SizedBox(height: 8),
          const Text('填充颜色'),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _fillColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
}
