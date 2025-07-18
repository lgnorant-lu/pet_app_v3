/*
---------------------------------------------------------------
File name:          app_manager.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        app_manager模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - app_manager模块公共API导出文件;
---------------------------------------------------------------
*/

/// app_manager模块
/// 
/// 应用管理核心模块
/// 
/// ## 功能特性
/// 
/// - 提供业务服务和API接口
/// - 支持异步操作和错误处理
/// - 数据持久化和缓存
/// 
/// ## 使用示例
/// 
/// ```dart
/// import 'package:app_manager/app_manager.dart';
/// 
/// // 在Dart应用中使用
/// void main() async {
///   final module = AppManagerModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
/// 
/// @author Pet App Team
/// @version 1.0.0
library app_manager;

// 核心模块导出
export 'app_manager_module.dart';

// 服务接口导出
export 'src/services/index.dart';
export 'src/repositories/index.dart';
export 'src/providers/index.dart';

// API接口导出
export 'src/api/index.dart';
export 'src/models/index.dart';

// 条件导出（根据平台和环境）
// service类型模板不需要平台特定导出
