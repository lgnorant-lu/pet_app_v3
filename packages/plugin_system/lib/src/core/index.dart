/*
---------------------------------------------------------------
File name:          index.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        核心功能模块导出文件
---------------------------------------------------------------
*/

// 安全模块导出（隐藏与核心模块冲突的类）
export '../security/index.dart' hide PermissionManager, PermissionPolicy;
// 核心功能导出
export 'dependency_manager.dart';
export 'dependency_node.dart';
export 'event_bus.dart';
export 'hot_reload_manager.dart';
export 'plugin.dart';
export 'plugin_downloader.dart';
export 'plugin_exceptions.dart';
export 'plugin_file_manager.dart';
export 'plugin_loader.dart';
export 'plugin_manifest.dart';
export 'plugin_manifest_parser.dart';
export 'plugin_messenger.dart';

export 'plugin_publisher.dart';
export 'plugin_registry.dart';
export 'plugin_security.dart';
export 'plugin_signature.dart';
