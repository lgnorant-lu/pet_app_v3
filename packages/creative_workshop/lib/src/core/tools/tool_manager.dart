/*
---------------------------------------------------------------
File name:          tool_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊工具管理器实现
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 工具管理器实现;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:creative_workshop/src/core/tools/drawing_tools.dart';

/// 简化的工具管理器
/// 负责管理简化版本的工具类
class SimpleToolManager extends ChangeNotifier {

  SimpleToolManager._internal();
  static SimpleToolManager? _instance;

  /// 获取单例实例
  static SimpleToolManager get instance {
    _instance ??= SimpleToolManager._internal();
    return _instance!;
  }

  /// 已注册的绘画工具
  final Map<String, SimpleBrushTool> _brushTools = <String, SimpleBrushTool>{};
  final Map<String, SimplePencilTool> _pencilTools = <String, SimplePencilTool>{};

  /// 当前激活的工具
  dynamic _activeTool;
  String? _activeToolId;

  /// 工具历史记录
  final List<String> _toolHistory = <String>[];

  /// 最大历史记录数量
  static const int _maxHistorySize = 10;

  /// 获取当前激活的工具
  dynamic get activeTool => _activeTool;
  String? get activeToolId => _activeToolId;

  /// 获取所有画笔工具
  Map<String, SimpleBrushTool> get brushTools => Map.unmodifiable(_brushTools);

  /// 获取所有铅笔工具
  Map<String, SimplePencilTool> get pencilTools =>
      Map.unmodifiable(_pencilTools);

  /// 获取工具历史记录
  List<String> get toolHistory => List.unmodifiable(_toolHistory);

  /// 初始化工具管理器
  Future<void> initialize() async {
    try {
      // 注册内置工具插件
      await _registerBuiltinTools();

      // 设置默认工具
      _setDefaultTool();

      debugPrint('简化工具管理器初始化完成');
    } catch (e) {
      debugPrint('工具管理器初始化失败: $e');
      rethrow;
    }
  }

  /// 注册内置工具插件
  Future<void> _registerBuiltinTools() async {
    // 注册默认画笔工具
    final defaultBrush = SimpleBrushTool();
    _brushTools[defaultBrush.id] = defaultBrush;

    // 注册默认铅笔工具
    final defaultPencil = SimplePencilTool();
    _pencilTools[defaultPencil.id] = defaultPencil;

    debugPrint(
        '内置工具插件注册完成：${_brushTools.length} 个画笔工具，${_pencilTools.length} 个铅笔工具',);
  }

  /// 设置默认工具
  void _setDefaultTool() {
    // 默认激活画笔工具
    if (_brushTools.isNotEmpty) {
      final defaultBrush = _brushTools.values.first;
      _activeTool = defaultBrush;
      _activeToolId = defaultBrush.id;
      _updateToolHistory(defaultBrush.id);
      debugPrint('默认工具已设置: ${defaultBrush.name}');
    }
  }

  /// 激活画笔工具
  bool activateBrushTool(String toolId) {
    final tool = _brushTools[toolId];
    if (tool != null) {
      _activeTool = tool;
      _activeToolId = toolId;
      _updateToolHistory(toolId);
      notifyListeners();
      debugPrint('画笔工具已激活: ${tool.name}');
      return true;
    }
    debugPrint('画笔工具不存在: $toolId');
    return false;
  }

  /// 激活铅笔工具
  bool activatePencilTool(String toolId) {
    final tool = _pencilTools[toolId];
    if (tool != null) {
      _activeTool = tool;
      _activeToolId = toolId;
      _updateToolHistory(toolId);
      notifyListeners();
      debugPrint('铅笔工具已激活: ${tool.name}');
      return true;
    }
    debugPrint('铅笔工具不存在: $toolId');
    return false;
  }

  /// 停用当前工具
  void deactivateCurrentTool() {
    if (_activeTool != null) {
      debugPrint('工具已停用: ${_activeTool.runtimeType}');
      _activeTool = null;
      _activeToolId = null;
      notifyListeners();
    }
  }

  /// 切换到上一个工具
  bool switchToPreviousTool() {
    if (_toolHistory.length >= 2) {
      final previousToolId = _toolHistory[_toolHistory.length - 2];
      // 尝试激活画笔工具或铅笔工具
      return activateBrushTool(previousToolId) ||
          activatePencilTool(previousToolId);
    }
    return false;
  }

  /// 检查工具是否存在
  bool hasTool(String toolId) => _brushTools.containsKey(toolId) || _pencilTools.containsKey(toolId);

  /// 检查工具是否激活
  bool isToolActive(String toolId) => _activeToolId == toolId;

  /// 更新工具历史记录
  void _updateToolHistory(String toolId) {
    // 移除已存在的记录
    _toolHistory.removeWhere((String id) => id == toolId);

    // 添加到末尾
    _toolHistory.add(toolId);

    // 限制历史记录大小
    while (_toolHistory.length > _maxHistorySize) {
      _toolHistory.removeAt(0);
    }
  }

  /// 获取工具统计信息
  Map<String, dynamic> getToolStatistics() => <String, dynamic>{
      'totalBrushTools': _brushTools.length,
      'totalPencilTools': _pencilTools.length,
      'activeToolId': _activeToolId,
      'historySize': _toolHistory.length,
    };

  /// 清理资源
  @override
  void dispose() {
    // 停用当前工具
    deactivateCurrentTool();

    // 清空工具列表
    _brushTools.clear();
    _pencilTools.clear();
    _toolHistory.clear();

    debugPrint('简化工具管理器已清理');
    super.dispose();
  }
}
