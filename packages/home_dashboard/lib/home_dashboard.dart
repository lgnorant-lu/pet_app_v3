/*
---------------------------------------------------------------
File name:          home_dashboard.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        home_dashboard模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - home_dashboard模块公共API导出文件;
---------------------------------------------------------------
*/

/// home_dashboard模块
///
/// 首页仪表板模块
///
/// ## 功能特性
///
/// - 提供UI组件和界面元素
/// - 支持主题定制和样式配置
/// - 响应式设计支持
///
/// ## 使用示例
///
/// ```dart
/// import 'package:home_dashboard/home_dashboard.dart';
///
/// // 在Dart应用中使用
/// void main() async {
///   final module = HomeDashboardModule.instance;
///   await module.initialize();
///   // 使用模块功能
/// }
/// ```
///
/// @author Pet App Team
/// @version 1.0.0
library home_dashboard;

// 核心模块导出
export 'home_dashboard_module.dart';

// 页面组件导出
export 'src/pages/home_page.dart';

// UI组件导出
export 'src/widgets/index.dart';

// 数据提供者导出
export 'src/providers/home_provider.dart';

// 条件导出（根据平台和环境）
// ui类型模板不需要平台特定导出
