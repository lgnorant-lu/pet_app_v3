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

import 'package:creative_workshop/src/core/tools/tool_plugin.dart';
import 'package:flutter/material.dart';
import 'package:plugin_system/plugin_system.dart';

/// 画笔工具插件实现
class SimpleBrushTool extends DrawingTool {
  SimpleBrushTool()
      : super(
          toolConfig: const ToolConfig(
            name: '画笔工具',
            icon: Icons.brush,
            tooltip: '用于自由绘画的画笔工具',
            shortcut: 'B',
          ),
        );

  // Plugin基类必需的getter实现
  @override
  String get id => 'simple_brush_tool';

  @override
  String get name => '画笔工具';

  @override
  String get version => '1.0.0';

  @override
  String get description => '用于自由绘画的画笔工具';

  @override
  String get author => 'Creative Workshop';

  @override
  List<Permission> get requiredPermissions => [Permission.storage];

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

  // Plugin生命周期方法实现
  @override
  Future<void> initialize() async {
    // 初始化画笔工具
  }

  @override
  Future<void> start() async {
    // 启动画笔工具
  }

  @override
  Future<void> pause() async {
    // 暂停画笔工具
  }

  @override
  Future<void> resume() async {
    // 恢复画笔工具
  }

  @override
  Future<void> stop() async {
    // 停止画笔工具
  }

  @override
  Future<void> dispose() async {
    // 销毁画笔工具
  }

  @override
  Object? getConfigWidget() {
    // 返回配置界面
    return null;
  }

  @override
  PluginState get currentState => PluginState.loaded;

  @override
  Object getMainWidget() {
    return buildConfigurationPanel();
  }

  @override
  Future<dynamic> handleMessage(
      String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'setBrushSize':
        brushSize = data['size'] as double? ?? brushSize;
        return {'success': true};
      case 'setBrushColor':
        brushColor = Color(data['color'] as int? ?? brushColor.toARGB32());
        return {'success': true};
      case 'getBrushSettings':
        return getBrushSettings();
      default:
        return {'success': false, 'error': 'Unknown action: $action'};
    }
  }

  @override
  Stream<PluginState> get stateChanges => Stream.value(currentState);

  // ToolPlugin抽象方法实现
  @override
  Future<ToolResult> activate() async {
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> deactivate() async {
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> execute(Map<String, dynamic> parameters) async {
    return const ToolResult(success: true);
  }

  @override
  Widget? getSettingsWidget() {
    return buildConfigurationPanel();
  }

  @override
  Widget? getPropertiesWidget() {
    return null;
  }

  @override
  Future<ToolResult> handlePointerEvent(PointerEvent event) async {
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> handleKeyEvent(KeyEvent event) async {
    return const ToolResult(success: true);
  }

  @override
  MouseCursor getCursor() {
    return SystemMouseCursors.precise;
  }

  @override
  void onConfigChanged(ToolConfig newConfig) {
    // 处理配置变更
  }

  @override
  Map<String, dynamic> getToolState() {
    return {
      'brushSize': _brushSize,
      'brushColor': _brushColor.value,
      'brushOpacity': _brushOpacity,
    };
  }

  @override
  Future<void> restoreToolState(Map<String, dynamic> state) async {
    _brushSize = state['brushSize'] as double? ?? _brushSize;
    _brushColor = Color(state['brushColor'] as int? ?? _brushColor.value);
    _brushOpacity = state['brushOpacity'] as double? ?? _brushOpacity;
  }

  // DrawingTool抽象方法实现
  @override
  Future<ToolResult> startDrawing(Offset position) async {
    _currentPath = Path();
    _points.clear();
    _points.add(position);
    _currentPath!.moveTo(position.dx, position.dy);
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> updateDrawing(Offset position) async {
    if (_currentPath != null) {
      _points.add(position);
      _currentPath!.lineTo(position.dx, position.dy);
    }
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> endDrawing(Offset position) async {
    if (_currentPath != null && _points.isNotEmpty) {
      _finalizeDrawing();
      _currentPath = null;
      _points.clear();
    }
    return const ToolResult(success: true);
  }

  @override
  Map<String, dynamic> getBrushSettings() {
    return {
      'size': _brushSize,
      'color': _brushColor.toARGB32(),
      'opacity': _brushOpacity,
    };
  }

  @override
  void setBrushSettings(Map<String, dynamic> settings) {
    _brushSize = settings['size'] as double? ?? _brushSize;
    _brushColor = Color(settings['color'] as int? ?? _brushColor.toARGB32());
    _brushOpacity = settings['opacity'] as double? ?? _brushOpacity;
  }

  /// 画笔大小
  double _brushSize = 5;
  double get brushSize => _brushSize;
  set brushSize(double value) {
    _brushSize = value;
  }

  /// 画笔颜色
  Color _brushColor = Colors.black;
  Color get brushColor => _brushColor;
  set brushColor(Color value) {
    _brushColor = value;
  }

  /// 画笔透明度
  double _brushOpacity = 1;
  double get brushOpacity => _brushOpacity;
  set brushOpacity(double value) {
    _brushOpacity = value.clamp(0.0, 1.0);
  }

  /// 当前绘制路径
  Path? _currentPath;
  Path? get currentPath => _currentPath;

  /// 绘制点列表
  final List<Offset> _points = <Offset>[];
  List<Offset> get points => List.unmodifiable(_points);

  /// 完成绘制
  void _finalizeDrawing() {
    // 发送绘制完成事件（简化版本）
    debugPrint('绘制完成: ${_points.length} 个点');
  }

  /// 绘制到画布
  void paint(Canvas canvas, Size size) {
    if (_currentPath != null && _points.isNotEmpty) {
      final Paint paint = Paint()
        ..color = _brushColor.withValues(alpha: _brushOpacity)
        ..strokeWidth = _brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(_currentPath!, paint);
    }
  }

  /// 获取配置面板
  @override
  Widget buildConfigurationPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '画笔设置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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

/// 铅笔工具插件实现
class SimplePencilTool extends DrawingTool {
  SimplePencilTool()
      : super(
          toolConfig: const ToolConfig(
            name: '铅笔工具',
            icon: Icons.edit,
            tooltip: '用于精细绘画的铅笔工具',
            shortcut: 'P',
          ),
        );

  // Plugin基类必需的getter实现
  @override
  String get id => 'simple_pencil_tool';

  @override
  String get name => '铅笔工具';

  @override
  String get version => '1.0.0';

  @override
  String get description => '用于精细绘画的铅笔工具';

  @override
  String get author => 'Creative Workshop';

  @override
  List<Permission> get requiredPermissions => [Permission.storage];

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

  // Plugin生命周期方法实现
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
  Object getMainWidget() {
    return buildConfigurationPanel();
  }

  @override
  Future<dynamic> handleMessage(
      String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'setPencilSize':
        pencilSize = data['size'] as double? ?? pencilSize;
        return {'success': true};
      case 'setPencilColor':
        pencilColor = Color(data['color'] as int? ?? pencilColor.toARGB32());
        return {'success': true};
      case 'getPencilSettings':
        return getBrushSettings();
      default:
        return {'success': false, 'error': 'Unknown action: $action'};
    }
  }

  @override
  Stream<PluginState> get stateChanges => Stream.value(currentState);

  // ToolPlugin抽象方法实现
  @override
  Future<ToolResult> activate() async => const ToolResult(success: true);

  @override
  Future<ToolResult> deactivate() async => const ToolResult(success: true);

  @override
  Future<ToolResult> execute(Map<String, dynamic> parameters) async =>
      const ToolResult(success: true);

  @override
  Widget? getSettingsWidget() => buildConfigurationPanel();

  @override
  Widget? getPropertiesWidget() => null;

  @override
  Future<ToolResult> handlePointerEvent(PointerEvent event) async =>
      const ToolResult(success: true);

  @override
  Future<ToolResult> handleKeyEvent(KeyEvent event) async =>
      const ToolResult(success: true);

  @override
  MouseCursor getCursor() => SystemMouseCursors.precise;

  @override
  void onConfigChanged(ToolConfig newConfig) {}

  @override
  Map<String, dynamic> getToolState() => {
        'pencilSize': _pencilSize,
        'pencilColor': _pencilColor.toARGB32(),
      };

  @override
  Future<void> restoreToolState(Map<String, dynamic> state) async {
    _pencilSize = state['pencilSize'] as double? ?? _pencilSize;
    _pencilColor =
        Color(state['pencilColor'] as int? ?? _pencilColor.toARGB32());
  }

  // DrawingTool抽象方法实现
  @override
  Future<ToolResult> startDrawing(Offset position) async {
    _currentPath = Path();
    _currentPath!.moveTo(position.dx, position.dy);
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> updateDrawing(Offset position) async {
    if (_currentPath != null) {
      _currentPath!.lineTo(position.dx, position.dy);
    }
    return const ToolResult(success: true);
  }

  @override
  Future<ToolResult> endDrawing(Offset position) async {
    if (_currentPath != null) {
      debugPrint('铅笔绘制完成');
      _currentPath = null;
    }
    return const ToolResult(success: true);
  }

  @override
  Map<String, dynamic> getBrushSettings() => {
        'size': _pencilSize,
        'color': _pencilColor.toARGB32(),
      };

  @override
  void setBrushSettings(Map<String, dynamic> settings) {
    _pencilSize = settings['size'] as double? ?? _pencilSize;
    _pencilColor = Color(settings['color'] as int? ?? _pencilColor.toARGB32());
  }

  /// 铅笔大小
  double _pencilSize = 2;
  double get pencilSize => _pencilSize;
  set pencilSize(double value) {
    _pencilSize = value;
  }

  /// 铅笔颜色
  Color _pencilColor = Colors.grey[700]!;
  Color get pencilColor => _pencilColor;
  set pencilColor(Color value) {
    _pencilColor = value;
  }

  /// 当前绘制路径
  Path? _currentPath;
  Path? get currentPath => _currentPath;

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
  @override
  Widget buildConfigurationPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '铅笔设置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
