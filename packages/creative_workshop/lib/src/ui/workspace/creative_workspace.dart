/*
---------------------------------------------------------------
File name:          creative_workspace.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        Creative Workshop 应用商店主界面
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.3 - 重构为应用商店界面;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/ui/store/app_store_page.dart';
import 'package:creative_workshop/src/ui/store/plugin_card.dart';
import 'package:creative_workshop/src/ui/developer/developer_platform_page.dart';
import 'package:creative_workshop/src/ui/management/plugin_management_page.dart';

/// 工作区布局模式
enum WorkspaceLayout {
  /// 应用商店模式（插件浏览和管理）
  store,

  /// 开发者模式（插件开发和调试）
  developer,

  /// 管理模式（已安装插件管理）
  management,

  /// 自定义布局
  custom,
}

/// Creative Workshop 应用商店主界面
class CreativeWorkspace extends StatefulWidget {
  const CreativeWorkspace({
    super.key,
    this.layout = WorkspaceLayout.store,
    this.initialCategory,
    this.initialSearchQuery,
    this.onLayoutChanged,
  });

  /// 工作区布局
  final WorkspaceLayout layout;

  /// 初始分类
  final StorePluginCategory? initialCategory;

  /// 初始搜索查询
  final String? initialSearchQuery;

  /// 布局变化回调
  final void Function(WorkspaceLayout layout)? onLayoutChanged;

  @override
  State<CreativeWorkspace> createState() => _CreativeWorkspaceState();
}

class _CreativeWorkspaceState extends State<CreativeWorkspace> {
  @override
  Widget build(BuildContext context) {
    switch (widget.layout) {
      case WorkspaceLayout.store:
        return AppStorePage(
          initialCategory: widget.initialCategory,
          initialSearchQuery: widget.initialSearchQuery,
        );

      case WorkspaceLayout.developer:
        return const DeveloperPlatformPage();

      case WorkspaceLayout.management:
        return const PluginManagementPage();

      case WorkspaceLayout.custom:
        return _buildCustomMode();
    }
  }

  /// 构建自定义模式界面
  Widget _buildCustomMode() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义布局'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () =>
                widget.onLayoutChanged?.call(WorkspaceLayout.store),
            tooltip: '切换到应用商店',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '自定义布局',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Phase 5.0.6.3 - 自定义布局功能待实现',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
