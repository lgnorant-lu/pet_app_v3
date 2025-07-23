/*
---------------------------------------------------------------
File name:          creative_workshop_main_page.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        Creative Workshop主页面 - Phase 3.1 UI集成
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 3.1 - 创建Creative Workshop主页面，集成插件管理UI;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'management/plugin_management_page.dart';
import 'store/app_store_page.dart';
import 'developer/developer_platform_page.dart';
import 'workspace/creative_workspace.dart';

/// Creative Workshop主页面
///
/// Phase 3.1 功能：
/// - 插件管理界面
/// - 应用商店界面
/// - 开发者平台界面
/// - 创意工作区界面
/// - 底部导航栏
class CreativeWorkshopMainPage extends StatefulWidget {
  const CreativeWorkshopMainPage({super.key});

  @override
  State<CreativeWorkshopMainPage> createState() =>
      _CreativeWorkshopMainPageState();
}

class _CreativeWorkshopMainPageState extends State<CreativeWorkshopMainPage>
    with TickerProviderStateMixin {
  /// 当前选中的标签页索引
  int _currentIndex = 0;

  /// 标签页控制器
  late TabController _tabController;

  /// 标签页列表
  final List<_TabInfo> _tabs = [
    const _TabInfo(
      id: 'workspace',
      title: '工作区',
      icon: Icons.workspace_premium,
      activeIcon: Icons.workspace_premium,
    ),
    const _TabInfo(
      id: 'store',
      title: '应用商店',
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
    ),
    const _TabInfo(
      id: 'management',
      title: '插件管理',
      icon: Icons.extension_outlined,
      activeIcon: Icons.extension,
    ),
    const _TabInfo(
      id: 'developer',
      title: '开发者',
      icon: Icons.code_outlined,
      activeIcon: Icons.code,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// 标签页变更处理
  void _onTabChanged() {
    if (_tabController.index != _currentIndex) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _log('info', '切换到标签页: ${_tabs[_currentIndex].title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创意工坊'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 快速操作菜单
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleQuickAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('刷新'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('设置'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text('帮助'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) {
            final isSelected = _tabs.indexOf(tab) == _currentIndex;
            return Tab(
              icon: Icon(isSelected ? tab.activeIcon : tab.icon),
              text: tab.title,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 创意工作区
          const CreativeWorkspace(),

          // 应用商店
          const AppStorePage(),

          // 插件管理
          const PluginManagementPage(),

          // 开发者平台
          const DeveloperPlatformPage(),
        ],
      ),
    );
  }

  /// 处理快速操作
  void _handleQuickAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshCurrentPage();
        break;
      case 'settings':
        _openSettings();
        break;
      case 'help':
        _openHelp();
        break;
    }
  }

  /// 刷新当前页面
  void _refreshCurrentPage() {
    _log('info', '刷新当前页面: ${_tabs[_currentIndex].title}');
    // TODO: 实现页面刷新逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在刷新 ${_tabs[_currentIndex].title}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 打开设置
  void _openSettings() {
    _log('info', '打开Creative Workshop设置');
    // TODO: 实现设置页面导航
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置功能即将推出...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 打开帮助
  void _openHelp() {
    _log('info', '打开Creative Workshop帮助');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creative Workshop 帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎨 创意工作区',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 创建和编辑项目\n• 使用各种创意工具\n• 管理项目资源'),
              SizedBox(height: 16),
              Text(
                '🏪 应用商店',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 浏览和搜索插件\n• 查看插件详情和评价\n• 安装和更新插件'),
              SizedBox(height: 16),
              Text(
                '🔧 插件管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 管理已安装插件\n• 配置插件权限\n• 查看插件依赖'),
              SizedBox(height: 16),
              Text(
                '👨‍💻 开发者平台',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 开发和测试插件\n• 发布插件到商店\n• 管理开发项目'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 日志记录
  void _log(String level, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [CreativeWorkshopMainPage] [$level] $message');
    }
  }
}

/// 标签页信息
class _TabInfo {
  final String id;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const _TabInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}
