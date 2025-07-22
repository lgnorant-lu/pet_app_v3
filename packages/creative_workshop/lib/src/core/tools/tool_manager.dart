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
import 'package:creative_workshop/src/core/tools/tool_plugin.dart';

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

  /// 已注册的工具
  final Map<String, ToolPlugin> _tools = <String, ToolPlugin>{};

  /// 当前激活的工具
  ToolPlugin? _activeTool;
  String? _activeToolId;

  /// 工具历史记录
  final List<String> _toolHistory = <String>[];

  /// 最大历史记录数量
  static const int _maxHistorySize = 10;

  /// 获取当前激活的工具
  ToolPlugin? get activeTool => _activeTool;
  String? get activeToolId => _activeToolId;

  /// 获取所有工具
  Map<String, ToolPlugin> get tools => Map.unmodifiable(_tools);

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
  ///
  /// Phase 5.0.6 重构：转型为应用商店模式
  /// 不再注册内置工具，改为从插件市场动态加载
  Future<void> _registerBuiltinTools() async {
    debugPrint('跳过内置工具注册 - 转型为应用商店模式');

    // TODO: Phase 5.0.6.2 - 实现从插件市场加载工具
    // 1. 扫描已安装的工具插件
    // 2. 动态加载插件到注册中心
    // 3. 验证插件兼容性和权限

    debugPrint('工具插件注册完成 - 应用商店模式');
  }

  /// 设置默认工具
  void _setDefaultTool() {
    // 默认激活第一个工具
    if (_tools.isNotEmpty) {
      final defaultTool = _tools.values.first;
      _activeTool = defaultTool;
      _activeToolId = defaultTool.id;
      _updateToolHistory(defaultTool.id);
      debugPrint('默认工具已设置: ${defaultTool.name}');
    }
  }

  /// 激活工具
  bool activateTool(String toolId) {
    final tool = _tools[toolId];
    if (tool != null) {
      _activeTool = tool;
      _activeToolId = toolId;
      _updateToolHistory(toolId);
      notifyListeners();
      debugPrint('工具已激活: ${tool.name}');
      return true;
    }
    debugPrint('工具不存在: $toolId');
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
      return activateTool(previousToolId);
    }
    return false;
  }

  /// 检查工具是否存在
  bool hasTool(String toolId) => _tools.containsKey(toolId);

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
        'totalTools': _tools.length,
        'activeToolId': _activeToolId,
        'historySize': _toolHistory.length,
      };

  /// 清理资源
  @override
  void dispose() {
    // 停用当前工具
    deactivateCurrentTool();

    // 清空工具列表
    _tools.clear();
    _toolHistory.clear();

    debugPrint('简化工具管理器已清理');
    super.dispose();
  }
}
