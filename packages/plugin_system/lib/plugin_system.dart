/*
---------------------------------------------------------------
File name:          plugin_system.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        plugin_system模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - plugin_system模块公共API导出文件;
---------------------------------------------------------------
*/

/// plugin_system模块
///
/// 插件系统核心模块
///
/// ## 功能特性
///
/// - 模块化设计
/// - 可扩展架构
/// - 标准化接口
///
/// ## 使用示例
///
/// ```dart
/// import 'package:plugin_system/plugin_system.dart';
///
/// // 在Dart应用中使用
/// void main() async {
///   final module = PluginSystemModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
///
/// @author Pet App Team
/// @version 1.0.0
library plugin_system;

// 核心模块导出
export 'plugin_system_module.dart';

// 核心功能导出
export 'src/core/index.dart';
