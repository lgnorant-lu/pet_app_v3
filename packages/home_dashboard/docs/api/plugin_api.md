# Home Dashboard API 文档

## 概述

Home Dashboard 模块提供了首页仪表板的核心功能，包括系统状态监控、快速访问面板、用户行为分析等功能。

- **模块名称**: home_dashboard
- **版本**: 1.0.0
- **作者**: Pet App Team
- **类型**: UI模块
- **复杂度**: Complex
- **平台支持**: 跨平台

## 核心API

### 模块初始化

```dart
import 'package:home_dashboard/home_dashboard.dart';

// 初始化模块
final module = HomeDashboardModule.instance;
await module.initialize();
```

### 页面组件

#### HomePage
主页面组件，集成了所有仪表板功能。

```dart
import 'package:home_dashboard/home_dashboard.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}
```

### 数据提供者

#### HomeProvider
首页数据状态管理。

```dart
// 获取首页数据
final homeData = ref.watch(homeProvider);

// 刷新数据
ref.read(homeProvider.notifier).refresh();

// 更新模块状态
ref.read(homeProvider.notifier).updateModuleStatus('moduleId', ModuleStatus.active);
```

#### QuickAccessProvider
快速访问功能管理。

```dart
// 获取快速访问状态
final quickAccessState = ref.watch(quickAccessProvider);

// 执行快速操作
await ref.read(quickAccessProvider.notifier).executeAction(action);

// 切换操作置顶
ref.read(quickAccessProvider.notifier).toggleActionPin(actionId);
```

#### StatusOverviewProvider
系统状态概览管理。

```dart
// 获取系统状态
final statusState = ref.watch(statusOverviewProvider);

// 手动刷新状态
ref.read(statusOverviewProvider.notifier).refreshStatus();

// 获取特定模块状态
final moduleStatus = ref.read(statusOverviewProvider.notifier).getModuleStatus('moduleId');
```

### UI组件

#### QuickAccessPanel
快速访问面板组件。

```dart
const QuickAccessPanel()
```

#### StatusOverviewPanel
状态概览面板组件。

```dart
const StatusOverviewPanel()
```

#### WelcomeHeader
欢迎头部组件。

```dart
const WelcomeHeader()
```

#### ModuleStatusCard
模块状态卡片组件。

```dart
ModuleStatusCard(
  module: moduleInfo,
  onTap: () => _navigateToModule(moduleInfo.id),
)
```

### 工具类

#### AnimationUtils
动画工具类，提供13种预定义动画效果。

```dart
// 延迟动画
AnimationUtils.delayedAnimation(
  delay: const Duration(milliseconds: 200),
  child: widget,
)

// 淡入动画
AnimationUtils.fadeIn(child: widget)

// 滑入动画
AnimationUtils.slideIn(
  direction: SlideDirection.fromBottom,
  child: widget,
)
```

#### ResponsiveUtils
响应式布局工具类。

```dart
// 检查屏幕类型
if (ResponsiveUtils.isMobile(context)) {
  // 移动端布局
}

// 获取列数
final columns = ResponsiveUtils.getColumns(context);

// 响应式容器
ResponsiveContainer(
  child: widget,
)
```

### 服务类

#### SystemDataService
系统数据服务，提供跨平台系统指标获取。

```dart
// 获取系统指标
final metrics = await SystemDataService.instance.getSystemMetrics();

print('CPU使用率: ${metrics.cpuUsage}%');
print('内存使用率: ${metrics.memoryUsage}%');
print('磁盘使用率: ${metrics.diskUsage}%');
```

#### UserBehaviorService
用户行为分析服务。

```dart
// 记录用户操作
await UserBehaviorService.instance.recordAction(
  'action_id',
  context: {'key': 'value'},
);

// 获取推荐操作
final recommendations = await UserBehaviorService.instance.getRecommendedActions();

// 获取最近操作
final recentActions = await UserBehaviorService.instance.getRecentActions();
```

## 数据模型

### QuickAction
快速操作数据模型。

```dart
final action = QuickAction(
  id: 'unique_id',
  title: '操作标题',
  description: '操作描述',
  icon: Icons.action,
  color: Colors.blue,
  type: QuickActionType.workflow,
  priority: QuickActionPriority.normal,
  isEnabled: true,
  usageCount: 0,
  createdAt: DateTime.now(),
  tags: const ['标签1', '标签2'],
  onTap: () => print('执行操作'),
);
```

### SystemMetrics
系统指标数据模型。

```dart
final metrics = SystemMetrics(
  cpuUsage: 25.5,
  memoryUsage: 60.2,
  diskUsage: 45.8,
  networkLatency: 30,
  activeUsers: 1200,
  errorRate: 0.5,
  responseTime: 150,
  timestamp: DateTime.now(),
);
```

### ModuleInfo
模块信息数据模型。

```dart
final moduleInfo = ModuleInfo(
  id: 'module_id',
  title: '模块标题',
  icon: Icons.module,
  status: ModuleStatus.active,
  subtitle: '模块副标题',
  metadata: {'key': 'value'},
);
```

## 错误处理

模块提供了完善的错误处理机制：

```dart
try {
  await module.initialize();
} catch (e, stackTrace) {
  print('模块初始化失败: $e');
  // 处理错误
}
```

## 性能优化

- 使用 Riverpod 进行高效的状态管理
- 实现了响应式布局，避免不必要的重建
- 提供了动画优化，确保流畅的用户体验
- 支持异步数据加载，避免阻塞UI

## 平台支持

- **Web**: 使用性能API获取系统数据
- **Windows**: 使用Performance Counters
- **macOS**: 使用系统命令和vm_stat
- **Linux**: 使用/proc文件系统
- **移动端**: 使用设备信息API

## 注意事项

1. 模块需要在使用前进行初始化
2. 系统数据服务在某些平台可能有权限限制
3. 用户行为数据存储在本地，注意隐私保护
4. 动画效果可能影响性能，建议在低端设备上适当调整
