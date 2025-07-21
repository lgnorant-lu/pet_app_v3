/*
---------------------------------------------------------------
File name:          desktop_pet.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        desktop_pet模块公共API导出文件
---------------------------------------------------------------
Change History:
    2025-07-21: Initial creation - desktop_pet模块公共API导出文件;
---------------------------------------------------------------
*/

/// desktop_pet模块
///
/// 桌面宠物系统 - 智能AI桌宠核心模块
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
/// import 'package:desktop_pet/desktop_pet.dart';
///
/// // 在Flutter应用中使用
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: DesktopPetWidget(),
///     );
///   }
/// }
/// ```
///
/// @author Pet App V3 Team
/// @version 1.0.0
library desktop_pet;

// 核心模块导出
export 'desktop_pet_module.dart';
export 'src/configuration/index.dart';
export 'src/core/index.dart';
export 'src/logging/index.dart';
export 'src/models/index.dart';
export 'src/monitoring/index.dart';
export 'src/providers/index.dart';
export 'src/repositories/index.dart';
// Flutter完整导出
export 'src/screens/index.dart';
// 企业级功能导出
export 'src/security/index.dart';
export 'src/services/index.dart';
export 'src/themes/index.dart';
export 'src/utils/index.dart';
// 完整模块导出
export 'src/widgets/index.dart';

// 条件导出（根据平台和环境）
// full类型模板不需要平台特定导出
