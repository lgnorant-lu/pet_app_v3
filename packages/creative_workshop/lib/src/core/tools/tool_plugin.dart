/*
---------------------------------------------------------------
File name:          tool_plugin.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊工具插件基类
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意工坊工具插件基类;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:plugin_system/plugin_system.dart';

/// 工具类型枚举
enum ToolType {
  /// 绘画工具
  drawing,

  /// 编辑工具
  editing,

  /// 效果工具
  effects,

  /// 文本工具
  text,

  /// 形状工具
  shapes,

  /// 选择工具
  selection,

  /// 变换工具
  transform,

  /// 自定义工具
  custom,
}

/// 工具配置
class ToolConfig {
  const ToolConfig({
    required this.name,
    required this.icon,
    this.shortcut,
    this.tooltip,
    this.isEnabled = true,
    this.settings = const <String, dynamic>{},
  });

  /// 工具名称
  final String name;

  /// 工具图标
  final IconData icon;

  /// 快捷键
  final String? shortcut;

  /// 提示文本
  final String? tooltip;

  /// 是否启用
  final bool isEnabled;

  /// 工具设置
  final Map<String, dynamic> settings;
}

/// 工具操作结果
class ToolResult {
  const ToolResult({
    required this.success,
    this.data,
    this.error,
  });

  /// 操作是否成功
  final bool success;

  /// 结果数据
  final dynamic data;

  /// 错误信息
  final String? error;
}

/// 创意工坊工具插件基类
///
/// 所有创意工坊工具都必须继承此类
abstract class ToolPlugin extends Plugin {
  ToolPlugin({
    required this.toolType,
    required this.toolConfig,
  });

  /// 工具类型
  final ToolType toolType;

  /// 工具配置
  final ToolConfig toolConfig;

  // Plugin基类的抽象方法需要在具体实现中重写
  // 这里提供默认的配置面板实现
  Widget buildConfigurationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            toolConfig.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (toolConfig.tooltip != null) ...[
            const SizedBox(height: 8),
            Text(toolConfig.tooltip!),
          ],
          const SizedBox(height: 16),
          // 子类可以重写此方法来提供自定义配置
          ...buildCustomSettings(),
        ],
      ),
    );
  }

  /// 子类重写此方法来提供自定义设置
  List<Widget> buildCustomSettings() => [];

  @override
  PluginCategory get category => PluginCategory.tool;

  /// 工具是否处于活跃状态
  bool get isActive => currentState == PluginState.started;

  /// 激活工具
  Future<ToolResult> activate();

  /// 停用工具
  Future<ToolResult> deactivate();

  /// 执行工具操作
  Future<ToolResult> execute(Map<String, dynamic> parameters);

  /// 获取工具设置界面
  Widget? getSettingsWidget();

  /// 获取工具属性面板
  Widget? getPropertiesWidget();

  /// 处理鼠标/触摸事件
  Future<ToolResult> handlePointerEvent(PointerEvent event);

  /// 处理键盘事件
  Future<ToolResult> handleKeyEvent(KeyEvent event);

  /// 获取工具光标
  MouseCursor getCursor();

  /// 工具配置变更通知
  void onConfigChanged(ToolConfig newConfig);

  /// 获取工具状态
  Map<String, dynamic> getToolState();

  /// 恢复工具状态
  Future<void> restoreToolState(Map<String, dynamic> state);
}

/// 绘画工具基类
abstract class DrawingTool extends ToolPlugin {
  DrawingTool({
    required super.toolConfig,
  }) : super(toolType: ToolType.drawing);

  /// 开始绘制
  Future<ToolResult> startDrawing(Offset position);

  /// 更新绘制
  Future<ToolResult> updateDrawing(Offset position);

  /// 结束绘制
  Future<ToolResult> endDrawing(Offset position);

  /// 获取画笔设置
  Map<String, dynamic> getBrushSettings();

  /// 设置画笔属性
  void setBrushSettings(Map<String, dynamic> settings);
}

/// 选择工具基类
abstract class SelectionTool extends ToolPlugin {
  SelectionTool({
    required super.toolConfig,
  }) : super(toolType: ToolType.selection);

  /// 开始选择
  Future<ToolResult> startSelection(Offset position);

  /// 更新选择区域
  Future<ToolResult> updateSelection(Offset position);

  /// 结束选择
  Future<ToolResult> endSelection(Offset position);

  /// 获取选择区域
  Rect? getSelectionRect();

  /// 清除选择
  Future<void> clearSelection();
}

/// 变换工具基类
abstract class TransformTool extends ToolPlugin {
  TransformTool({
    required super.toolConfig,
  }) : super(toolType: ToolType.transform);

  /// 开始变换
  Future<ToolResult> startTransform(Offset position);

  /// 更新变换
  Future<ToolResult> updateTransform(Offset position);

  /// 结束变换
  Future<ToolResult> endTransform(Offset position);

  /// 应用变换
  Future<ToolResult> applyTransform();

  /// 取消变换
  Future<ToolResult> cancelTransform();
}

/// 工具插件工厂
class ToolPluginFactory {
  static final Map<String, ToolPlugin Function()> _toolFactories =
      <String, ToolPlugin Function()>{};

  /// 注册工具插件
  static void registerTool(String toolId, ToolPlugin Function() factory) {
    _toolFactories[toolId] = factory;
  }

  /// 创建工具插件
  static ToolPlugin? createTool(String toolId) {
    final factory = _toolFactories[toolId];
    return factory?.call();
  }

  /// 获取所有已注册的工具
  static List<String> getRegisteredTools() => _toolFactories.keys.toList();

  /// 清除所有注册的工具
  static void clearTools() {
    _toolFactories.clear();
  }
}
