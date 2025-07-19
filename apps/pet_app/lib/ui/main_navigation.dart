/*
---------------------------------------------------------------
File name:          main_navigation.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        主导航界面 - Phase 3.1 UI组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现主导航、模块切换、底部导航栏;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'framework/main_app_framework.dart';
// import 'framework/quick_action_panel.dart'; // 暂时未使用

/// 导航页面信息
class NavigationPage {
  final String id;
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final Widget page;
  final bool enabled;

  NavigationPage({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    required this.page,
    this.enabled = true,
  });
}

/// 主导航界面
///
/// Phase 3.1 功能：
/// - 底部导航栏
/// - 模块页面切换
/// - 响应式布局
/// - 状态保持
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// 当前选中的页面索引
  int _currentIndex = 0;

  /// 页面控制器
  late PageController _pageController;

  /// 导航页面列表
  late List<NavigationPage> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializePages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 初始化页面
  void _initializePages() {
    _pages = [
      NavigationPage(
        id: 'home',
        title: '首页',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        page: const _HomePage(),
      ),
      NavigationPage(
        id: 'creative_workshop',
        title: '创意工坊',
        icon: Icons.build_outlined,
        activeIcon: Icons.build,
        page: const _CreativeWorkshopPage(),
      ),
      NavigationPage(
        id: 'app_manager',
        title: '应用管理',
        icon: Icons.apps_outlined,
        activeIcon: Icons.apps,
        page: const _AppManagerPage(),
      ),
      NavigationPage(
        id: 'settings',
        title: '设置',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        page: const _SettingsPage(),
      ),
    ];
  }

  /// 切换页面
  void _onPageChanged(int index) {
    if (index != _currentIndex && _pages[index].enabled) {
      setState(() {
        _currentIndex = index;
      });

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      _log('info', '切换到页面: ${_pages[index].title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainAppFramework(
      title: 'Pet App V3',
      quickActions: _buildQuickActions(),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages.map((page) => page.page).toList(),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  /// 构建快捷操作
  List<QuickAction> _buildQuickActions() {
    return [
      QuickAction(
        id: 'quick_home',
        title: '首页',
        icon: Icons.home,
        onTap: () => _onPageChanged(0),
        tooltip: '快速返回首页',
      ),
      QuickAction(
        id: 'quick_workshop',
        title: '工坊',
        icon: Icons.build,
        onTap: () => _onPageChanged(1),
        tooltip: '打开创意工坊',
      ),
      QuickAction(
        id: 'quick_apps',
        title: '应用',
        icon: Icons.apps,
        onTap: () => _onPageChanged(2),
        tooltip: '管理应用',
      ),
      QuickAction(
        id: 'quick_settings',
        title: '设置',
        icon: Icons.settings,
        onTap: () => _onPageChanged(3),
        tooltip: '打开设置',
      ),
    ];
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onPageChanged,
      destinations: _pages.map((page) {
        return NavigationDestination(
          icon: Icon(page.icon),
          selectedIcon: Icon(page.activeIcon ?? page.icon),
          label: page.title,
          enabled: page.enabled,
        );
      }).toList(),
    );
  }

  /// 日志记录
  void _log(String level, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [MainNavigation] [$level] $message');
    }
  }
}

/// 首页
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet App V3'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              '欢迎使用 Pet App V3',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '万物皆插件的跨平台应用框架',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Phase 3.1 - 应用生命周期管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✅ 应用启动流程优化\n'
                      '✅ 状态持久化系统\n'
                      '✅ 模块加载顺序管理\n'
                      '✅ 错误恢复机制',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 创意工坊页面
class _CreativeWorkshopPage extends StatelessWidget {
  const _CreativeWorkshopPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创意工坊'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              '创意工坊',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '插件创建、管理、分发的核心平台',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Creative Workshop v1.4.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✅ 工具插件系统\n'
                      '✅ 游戏插件系统\n'
                      '✅ 项目管理系统\n'
                      '✅ 跨平台存储支持',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 应用管理页面
class _AppManagerPage extends StatelessWidget {
  const _AppManagerPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('应用管理'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.green),
            SizedBox(height: 24),
            Text(
              '应用管理',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '管理已安装的应用和插件',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'App Manager v1.0.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🚧 待开发功能\n'
                      '• 应用列表管理\n'
                      '• 插件状态监控\n'
                      '• 性能分析工具',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置页面
class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.purple),
            SizedBox(height: 24),
            Text(
              '设置',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '应用设置和个性化配置',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Settings System v1.0.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🚧 待开发功能\n'
                      '• 主题设置\n'
                      '• 语言设置\n'
                      '• 插件配置\n'
                      '• 数据管理',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
