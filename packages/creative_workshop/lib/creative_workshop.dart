/*
---------------------------------------------------------------
File name:          creative_workshop.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        creative_workshop模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - creative_workshop模块公共API导出文件;
---------------------------------------------------------------
*/

/// creative_workshop模块
///
/// 创意工坊核心模块
///
/// ## 功能特性
///
/// - 完整的功能模块实现
/// - UI组件和业务逻辑
/// - 数据管理和状态控制
///
/// ## 使用示例
///
/// ```dart
/// import 'package:creative_workshop/creative_workshop.dart';
///
/// // 在Dart应用中使用
/// void main() async {
///   final module = CreativeWorkshopModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
///
/// @author Pet App Team
/// @version 1.0.0
library creative_workshop;

// 核心模块导出
export 'creative_workshop_module.dart';
export 'src/configuration/index.dart';
export 'src/core/games/game_plugin.dart';
export 'src/core/index.dart';
export 'src/core/projects/project_manager.dart';
export 'src/core/tools/tool_plugin.dart';
// Phase 2 核心功能导出
export 'src/core/workshop_manager.dart';
export 'src/logging/index.dart';
export 'src/monitoring/index.dart';
// export 'src/models/index.dart'; // 已删除models模块
export 'src/providers/index.dart';
export 'src/repositories/index.dart';
// 企业级功能导出
export 'src/security/index.dart';
export 'src/utils/index.dart';
// 完整模块导出
export 'src/widgets/index.dart';

// 条件导出（根据平台和环境）
// full类型模板不需要平台特定导出
