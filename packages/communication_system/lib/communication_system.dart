/*
---------------------------------------------------------------
File name:          communication_system.dart
Author:             Pet App V3 Team
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        communication_system模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-21: Initial creation - communication_system模块公共API导出文件;
---------------------------------------------------------------
*/

/// communication_system模块
///
/// 跨模块通信系统 - 统一消息总线、事件路由、数据同步
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
/// import 'package:communication_system/communication_system.dart';
///
/// // 在Flutter应用中使用
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: CommunicationSystemWidget(),
///     );
///   }
/// }
/// ```
///
/// @author Pet App V3 Team
/// @version 1.0.0
library communication_system;

// 核心模块导出
export 'communication_system_module.dart';

// 通信系统核心组件导出
export 'src/core/unified_message_bus.dart';
export 'src/core/module_communication_coordinator.dart';
export 'src/core/cross_module_event_router.dart';
export 'src/core/data_sync_manager.dart';
export 'src/core/conflict_resolution_engine.dart';

// 通用导出
export 'src/utils/index.dart';
export 'src/models/index.dart';
export 'src/constants/index.dart';

// 开发工具导出（仅在开发环境）
// export 'src/dev_tools/index.dart';

// 测试工具导出（仅在测试环境）
// export 'src/test_utils/index.dart';
