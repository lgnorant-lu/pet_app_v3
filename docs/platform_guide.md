# Pet App V3 平台特征化指南

## 🎯 概述

Pet App V3 支持Mobile、Desktop、Web三端，每个平台都有其独特的用户体验特征。本指南详细说明如何在保持核心功能一致的同时，为每个平台提供最佳的用户体验。

## 📱 三端特征化设计原则

### 核心理念
- **一套代码，三端体验**: 共享核心逻辑，差异化UI/UX
- **平台原生感**: 遵循各平台的设计规范和交互习惯
- **响应式适配**: 自动适应不同屏幕尺寸和输入方式
- **渐进增强**: 基础功能全平台支持，高级功能按平台能力提供

## 🏗️ 平台适配架构

### 平台适配器抽象层

```dart
/// 平台适配器基类
abstract class PlatformAdapter {
  /// 平台类型
  TargetPlatform get platform;
  
  /// 主要输入方式
  InputMethod get primaryInput;
  
  /// 导航样式
  NavigationStyle get navigationStyle;
  
  /// 构建平台特定的布局
  Widget buildLayout(Widget child);
  
  /// 获取平台特定的主题
  ThemeData getTheme(Brightness brightness);
  
  /// 获取快捷操作列表
  List<QuickAction> getQuickActions();
  
  /// 处理平台特定的生命周期事件
  void handleLifecycleEvent(AppLifecycleState state);
  
  /// 获取平台特定的设置项
  List<SettingItem> getPlatformSettings();
}

/// 输入方式枚举
enum InputMethod {
  touch,      // 触摸
  mouse,      // 鼠标
  keyboard,   // 键盘
  gamepad,    // 手柄
}

/// 导航样式枚举
enum NavigationStyle {
  bottomBar,    // 底部导航栏
  sidebar,      // 侧边栏
  topTabs,      // 顶部标签
  drawer,       // 抽屉导航
}
```

### 响应式断点系统

```dart
/// 响应式断点定义
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultrawide = 1600;
  
  /// 获取当前设备类型
  static DeviceType getDeviceType(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < desktop) return DeviceType.desktop;
    return DeviceType.ultrawide;
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  ultrawide,
}

/// 响应式布局构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;
  
  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = Breakpoints.getDeviceType(constraints.maxWidth);
        return builder(context, deviceType);
      },
    );
  }
}
```

## 📱 Mobile端特征化

### 设计特点
```
✅ 触摸优先交互
✅ 单窗口应用模式
✅ 手势导航支持
✅ 紧凑的信息密度
✅ 垂直滚动为主
✅ 底部导航栏
✅ 浮动操作按钮
```

### Mobile适配器实现

```dart
class MobilePlatformAdapter extends PlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.android; // 或 iOS
  
  @override
  InputMethod get primaryInput => InputMethod.touch;
  
  @override
  NavigationStyle get navigationStyle => NavigationStyle.bottomBar;
  
  @override
  Widget buildLayout(Widget child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  @override
  ThemeData getTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // Mobile特定的主题配置
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
  
  @override
  List<QuickAction> getQuickActions() {
    return [
      QuickAction(
        icon: Icons.add,
        label: '创建插件',
        action: () => _navigateToCreatePlugin(),
      ),
      QuickAction(
        icon: Icons.search,
        label: '搜索',
        action: () => _openSearch(),
      ),
    ];
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: '创意工坊',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          label: '应用',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: '桌宠',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }
}
```

### Mobile特定功能

```dart
/// 手势导航支持
class MobileGestureHandler extends StatelessWidget {
  final Widget child;
  
  const MobileGestureHandler({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // 处理滑动手势
        if (details.delta.dx > 20) {
          // 右滑返回
          Navigator.of(context).maybePop();
        }
      },
      child: child,
    );
  }
}

/// 触摸反馈增强
class TouchFeedbackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  
  const TouchFeedbackButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // 触觉反馈
          onPressed();
        },
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
```

## 🖥️ Desktop端特征化

### 设计特点
```
✅ 鼠标键盘交互
✅ 多窗口支持
✅ 侧边栏导航
✅ 宽屏布局优化
✅ 快捷键支持
✅ 右键菜单
✅ 拖拽操作
✅ 悬停效果
```

### Desktop适配器实现

```dart
class DesktopPlatformAdapter extends PlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.windows; // 或 macOS, linux
  
  @override
  InputMethod get primaryInput => InputMethod.mouse;
  
  @override
  NavigationStyle get navigationStyle => NavigationStyle.sidebar;
  
  @override
  Widget buildLayout(Widget child) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
  
  @override
  ThemeData getTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // Desktop特定的主题配置
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 1,
        toolbarHeight: 48,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
    );
  }
  
  @override
  List<QuickAction> getQuickActions() {
    return [
      QuickAction(
        icon: Icons.add,
        label: '新建项目',
        shortcut: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN),
        action: () => _createNewProject(),
      ),
      QuickAction(
        icon: Icons.folder_open,
        label: '打开项目',
        shortcut: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO),
        action: () => _openProject(),
      ),
    ];
  }
  
  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildNavigationRail()),
          _buildSidebarFooter(),
        ],
      ),
    );
  }
}
```

### Desktop特定功能

```dart
/// 快捷键处理
class DesktopShortcutHandler extends StatelessWidget {
  final Widget child;
  final Map<LogicalKeySet, VoidCallback> shortcuts;
  
  const DesktopShortcutHandler({
    Key? key,
    required this.child,
    required this.shortcuts,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          for (final entry in shortcuts.entries)
            CallbackAction<Intent>: CallbackAction<Intent>(
              onInvoke: (intent) => entry.value(),
            ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

/// 右键菜单支持
class ContextMenuRegion extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> menuItems;
  
  const ContextMenuRegion({
    Key? key,
    required this.child,
    required this.menuItems,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }
  
  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: menuItems.map((item) => PopupMenuItem(
        value: item.action,
        child: Row(
          children: [
            Icon(item.icon),
            SizedBox(width: 8),
            Text(item.label),
          ],
        ),
      )).toList(),
    ).then((action) {
      if (action != null) action();
    });
  }
}
```

## 🌐 Web端特征化

### 设计特点
```
✅ 浏览器特性集成
✅ URL路由管理
✅ 响应式设计
✅ 键盘导航
✅ 无障碍访问
✅ SEO优化
✅ PWA支持
```

### Web适配器实现

```dart
class WebPlatformAdapter extends PlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.fuchsia; // Web平台标识
  
  @override
  InputMethod get primaryInput => InputMethod.mouse;
  
  @override
  NavigationStyle get navigationStyle => NavigationStyle.topTabs;
  
  @override
  Widget buildLayout(Widget child) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileWebLayout(child);
          case DeviceType.tablet:
            return _buildTabletWebLayout(child);
          default:
            return _buildDesktopWebLayout(child);
        }
      },
    );
  }
  
  @override
  ThemeData getTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // Web特定的主题配置
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: MaterialStateProperty.all(true),
        trackVisibility: MaterialStateProperty.all(true),
      ),
    );
  }
  
  Widget _buildDesktopWebLayout(Widget child) {
    return Scaffold(
      appBar: _buildWebAppBar(),
      body: Row(
        children: [
          _buildWebSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildBreadcrumb(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Web特定功能

```dart
/// URL路由集成
class WebRouterDelegate extends RouterDelegate<RouteInformation> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: _buildPages(),
      onPopPage: _handlePopPage,
    );
  }
  
  List<Page> _buildPages() {
    // 根据当前URL构建页面栈
    final uri = Uri.parse(currentConfiguration?.location ?? '/');
    return _parseRouteToPages(uri);
  }
}

/// PWA支持
class PWAManager {
  static Future<void> registerServiceWorker() async {
    if (kIsWeb) {
      // 注册Service Worker
      await html.window.navigator.serviceWorker?.register('/sw.js');
    }
  }
  
  static Future<void> showInstallPrompt() async {
    if (kIsWeb) {
      // 显示PWA安装提示
      final event = html.window.onBeforeInstallPrompt.first;
      await event.then((e) => e.prompt());
    }
  }
}

/// 无障碍访问增强
class AccessibilityEnhancer extends StatelessWidget {
  final Widget child;
  
  const AccessibilityEnhancer({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Focus(
        onKeyEvent: _handleKeyEvent,
        child: child,
      ),
    );
  }
  
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // 处理键盘导航
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.tab:
          // Tab键导航
          return KeyEventResult.handled;
        case LogicalKeyboardKey.escape:
          // ESC键关闭
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
```

## 🎨 响应式设计实现

### 自适应布局组件

```dart
/// 自适应网格布局
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  
  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / minItemWidth).floor();
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount.clamp(1, children.length),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// 自适应导航
class AdaptiveNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  
  const AdaptiveNavigation({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return BottomNavigationBar(
              items: items.map(_buildBottomNavItem).toList(),
              currentIndex: selectedIndex,
              onTap: onItemSelected,
            );
          case DeviceType.tablet:
            return NavigationRail(
              destinations: items.map(_buildRailDestination).toList(),
              selectedIndex: selectedIndex,
              onDestinationSelected: onItemSelected,
            );
          default:
            return _buildSidebarNavigation();
        }
      },
    );
  }
}
```

## 🔧 平台检测和适配

### 平台检测工具

```dart
class PlatformDetector {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => kIsWeb;
  
  static PlatformAdapter createAdapter() {
    if (isWeb) return WebPlatformAdapter();
    if (isMobile) return MobilePlatformAdapter();
    if (isDesktop) return DesktopPlatformAdapter();
    throw UnsupportedError('Unsupported platform');
  }
  
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Breakpoints.getDeviceType(width);
  }
}
```

### 平台适配管理器

```dart
class PlatformAdaptationManager {
  static late PlatformAdapter _adapter;
  
  static void initialize() {
    _adapter = PlatformDetector.createAdapter();
  }
  
  static PlatformAdapter get current => _adapter;
  
  static Widget buildAdaptiveLayout(Widget child) {
    return _adapter.buildLayout(child);
  }
  
  static ThemeData getAdaptiveTheme(Brightness brightness) {
    return _adapter.getTheme(brightness);
  }
}
```

## 📋 最佳实践

### 1. 设计原则
- **移动优先**: 从移动端开始设计，逐步增强到桌面端
- **渐进增强**: 基础功能全平台支持，高级功能按需提供
- **一致性**: 保持核心交互逻辑的一致性
- **原生感**: 遵循各平台的设计规范

### 2. 性能优化
- **懒加载**: 按需加载平台特定的组件
- **代码分割**: 将平台特定代码分离
- **资源优化**: 为不同平台提供合适的资源

### 3. 测试策略
- **多平台测试**: 在所有目标平台上进行测试
- **响应式测试**: 测试不同屏幕尺寸的适配效果
- **交互测试**: 验证平台特定的交互方式

---

更多信息请参考：
- [开发指南](./development_guide.md)
- [插件API文档](./plugin_api.md)
- [架构设计](./architecture.md)
