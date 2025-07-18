/*
---------------------------------------------------------------
File name:          settings_system.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        settings_system模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - settings_system模块公共API导出文件;
---------------------------------------------------------------
*/

/// settings_system模块
/// 
/// 设置系统模块
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
/// import 'package:settings_system/settings_system.dart';
/// 
/// // 在Dart应用中使用
/// void main() async {
///   final module = SettingsSystemModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
/// 
/// @author Pet App Team
/// @version 1.0.0
library settings_system;

// 核心模块导出
export 'settings_system_module.dart';

// 通用导出
export 'src/core/index.dart';
export 'src/utils/index.dart';

// 条件导出（根据平台和环境）
export 'src/cross_platform/index.dart';

// 开发工具导出（仅在开发环境）
// export 'src/dev_tools/index.dart';

// 测试工具导出（仅在测试环境）
// export 'src/test_utils/index.dart';
