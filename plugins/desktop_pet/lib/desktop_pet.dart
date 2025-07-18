/*
---------------------------------------------------------------
File name:          desktop_pet.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        desktop_pet模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - desktop_pet模块公共API导出文件;
---------------------------------------------------------------
*/

/// desktop_pet模块
/// 
/// 桌宠插件占位符
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
/// import 'package:desktop_pet/desktop_pet.dart';
/// 
/// // 在Dart应用中使用
/// void main() async {
///   final module = DesktopPetModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
/// 
/// @author Pet App Team
/// @version 1.0.0
library desktop_pet;

// 核心模块导出
export 'desktop_pet_module.dart';

// 通用导出
export 'src/core/index.dart';
export 'src/utils/index.dart';

// 条件导出（根据平台和环境）
export 'src/cross_platform/index.dart';

// 开发工具导出（仅在开发环境）
// export 'src/dev_tools/index.dart';

// 测试工具导出（仅在测试环境）
// export 'src/test_utils/index.dart';
