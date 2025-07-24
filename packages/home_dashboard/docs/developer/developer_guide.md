# Home Dashboard 开发者指南

## 开发环境设置

### 前置要求

- **Flutter**: >= 3.16.0
- **Dart**: >= 3.2.0
- **IDE**: VS Code 或 Android Studio
- **Git**: 版本控制

### 项目设置

```bash
# 克隆项目
git clone https://github.com/petapp/pet_app_v3.git
cd pet_app_v3/packages/home_dashboard

# 安装依赖
flutter pub get

# 运行测试
flutter test

# 静态分析
dart analyze
```

## 项目结构

```
home_dashboard/
├── lib/
│   ├── src/
│   │   ├── models/          # 数据模型
│   │   ├── pages/           # 页面组件
│   │   ├── providers/       # 状态管理
│   │   ├── services/        # 业务服务
│   │   ├── utils/           # 工具类
│   │   └── widgets/         # UI组件
│   ├── home_dashboard.dart  # 主导出文件
│   └── home_dashboard_module.dart # 模块定义
├── test/                    # 测试文件
├── docs/                    # 文档
├── example/                 # 示例代码
└── pubspec.yaml            # 依赖配置
```

## 核心概念

### 1. 模块化架构

Home Dashboard 采用模块化设计，实现了标准的模块接口：

```dart
abstract class ModuleInterface {
  Future<void> initialize();
  Future<void> dispose();
  Map<String, dynamic> getModuleInfo();
  Map<String, Function> registerRoutes();
}
```

### 2. 状态管理

使用 Riverpod 进行状态管理，提供响应式的数据流：

```dart
// Provider 定义
final homeProvider = StateNotifierProvider<HomeNotifier, HomeData>((ref) {
  return HomeNotifier();
});

// 在组件中使用
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);
    return Scaffold(/* ... */);
  }
}
```

### 3. 服务层设计

服务层负责业务逻辑和数据处理：

```dart
class SystemDataService {
  static final SystemDataService _instance = SystemDataService._();
  static SystemDataService get instance => _instance;
  
  Future<SystemMetrics> getSystemMetrics() async {
    // 跨平台系统数据获取
  }
}
```

## 开发指南

### 添加新功能

#### 1. 创建数据模型

```dart
// lib/src/models/new_feature.dart
class NewFeature {
  final String id;
  final String name;
  final bool isEnabled;
  
  const NewFeature({
    required this.id,
    required this.name,
    required this.isEnabled,
  });
  
  NewFeature copyWith({
    String? id,
    String? name,
    bool? isEnabled,
  }) {
    return NewFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
```

#### 2. 创建状态管理

```dart
// lib/src/providers/new_feature_provider.dart
class NewFeatureNotifier extends StateNotifier<List<NewFeature>> {
  NewFeatureNotifier() : super([]);
  
  void addFeature(NewFeature feature) {
    state = [...state, feature];
  }
  
  void removeFeature(String id) {
    state = state.where((feature) => feature.id != id).toList();
  }
}

final newFeatureProvider = StateNotifierProvider<NewFeatureNotifier, List<NewFeature>>((ref) {
  return NewFeatureNotifier();
});
```

#### 3. 创建UI组件

```dart
// lib/src/widgets/new_feature_widget.dart
class NewFeatureWidget extends ConsumerWidget {
  const NewFeatureWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(newFeatureProvider);
    
    return ListView.builder(
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return ListTile(
          title: Text(feature.name),
          trailing: Switch(
            value: feature.isEnabled,
            onChanged: (value) {
              // 更新状态
            },
          ),
        );
      },
    );
  }
}
```

#### 4. 添加测试

```dart
// test/src/providers/new_feature_provider_test.dart
void main() {
  group('NewFeatureProvider Tests', () {
    test('should add feature correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(newFeatureProvider.notifier);
      
      final feature = NewFeature(
        id: 'test',
        name: 'Test Feature',
        isEnabled: true,
      );
      
      notifier.addFeature(feature);
      
      final state = container.read(newFeatureProvider);
      expect(state.length, equals(1));
      expect(state.first.id, equals('test'));
    });
  });
}
```

### 扩展现有功能

#### 添加新的快速操作

```dart
// 在 QuickAccessProvider 中添加新操作
void addCustomAction(QuickAction action) {
  final updatedActions = [...state.allActions, action];
  state = state.copyWith(allActions: updatedActions);
}

// 使用示例
final customAction = QuickAction(
  id: 'custom_action',
  title: '自定义操作',
  description: '这是一个自定义操作',
  icon: Icons.custom,
  color: Colors.purple,
  type: QuickActionType.workflow,
  priority: QuickActionPriority.normal,
  isEnabled: true,
  usageCount: 0,
  createdAt: DateTime.now(),
  tags: const ['自定义'],
  onTap: () {
    // 执行自定义逻辑
  },
);

ref.read(quickAccessProvider.notifier).addCustomAction(customAction);
```

#### 添加新的系统指标

```dart
// 扩展 SystemMetrics 模型
class ExtendedSystemMetrics extends SystemMetrics {
  final double gpuUsage;
  final int processCount;
  
  const ExtendedSystemMetrics({
    required super.cpuUsage,
    required super.memoryUsage,
    required super.diskUsage,
    required super.networkLatency,
    required super.activeUsers,
    required super.errorRate,
    required super.responseTime,
    required super.timestamp,
    required this.gpuUsage,
    required this.processCount,
  });
}

// 在 SystemDataService 中添加获取方法
Future<double> getGpuUsage() async {
  // 实现GPU使用率获取逻辑
}
```

## 最佳实践

### 1. 代码规范

#### 命名约定
- **类名**: PascalCase (例: `QuickAccessPanel`)
- **方法名**: camelCase (例: `executeAction`)
- **常量**: SCREAMING_SNAKE_CASE (例: `MAX_RETRY_COUNT`)
- **文件名**: snake_case (例: `quick_access_panel.dart`)

#### 文档注释
```dart
/// 快速访问面板组件
/// 
/// 提供智能推荐、操作管理等功能
/// 
/// 使用示例:
/// ```dart
/// const QuickAccessPanel()
/// ```
class QuickAccessPanel extends ConsumerWidget {
  /// 创建快速访问面板
  const QuickAccessPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 实现
  }
}
```

### 2. 性能优化

#### 状态管理优化
```dart
// 使用 Provider.family 避免不必要的重建
final moduleStatusProvider = Provider.family<ModuleStatus, String>((ref, moduleId) {
  final allStatuses = ref.watch(statusOverviewProvider).moduleStatuses;
  return allStatuses.firstWhere((status) => status.moduleId == moduleId);
});

// 使用 select 只监听需要的数据
final isLoading = ref.watch(homeProvider.select((state) => state.isLoading));
```

#### 组件优化
```dart
// 使用 const 构造函数
class StaticWidget extends StatelessWidget {
  const StaticWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static Content');
  }
}

// 使用 RepaintBoundary 隔离重绘
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

### 3. 错误处理

#### 统一错误处理
```dart
class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // 记录错误日志
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    
    // 发送错误报告
    // CrashReporting.recordError(error, stackTrace);
  }
}

// 在 Provider 中使用
try {
  await someAsyncOperation();
} catch (error, stackTrace) {
  ErrorHandler.handleError(error, stackTrace);
  state = state.copyWith(error: error.toString());
}
```

#### 用户友好的错误提示
```dart
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 4. 测试策略

#### 单元测试
```dart
// 测试业务逻辑
void main() {
  group('SystemDataService Tests', () {
    test('should return valid metrics', () async {
      final service = SystemDataService.instance;
      final metrics = await service.getSystemMetrics();
      
      expect(metrics.cpuUsage, greaterThanOrEqualTo(0));
      expect(metrics.cpuUsage, lessThanOrEqualTo(100));
      expect(metrics.timestamp, isNotNull);
    });
  });
}
```

#### 组件测试
```dart
// 测试UI组件
void main() {
  group('QuickAccessPanel Tests', () {
    testWidgets('should display actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickAccessPanel(),
            ),
          ),
        ),
      );
      
      expect(find.byType(QuickAccessPanel), findsOneWidget);
      expect(find.text('快速访问'), findsOneWidget);
    });
  });
}
```

## 调试技巧

### 1. 日志记录

```dart
// 使用统一的日志格式
void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
  final timestamp = DateTime.now().toIso8601String();
  print('[$timestamp] [HomeDashboard] [$level] $message');
  
  if (error != null) {
    print('Error: $error');
  }
  
  if (stackTrace != null) {
    print('StackTrace: $stackTrace');
  }
}
```

### 2. 状态调试

```dart
// 使用 Riverpod 的调试功能
class DebugObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('Provider ${provider.name} updated: $previousValue -> $newValue');
  }
}

// 在应用中启用
ProviderScope(
  observers: [DebugObserver()],
  child: MyApp(),
)
```

### 3. 性能分析

```dart
// 使用 Timeline 分析性能
import 'dart:developer' as developer;

Future<void> expensiveOperation() async {
  developer.Timeline.startSync('ExpensiveOperation');
  try {
    // 执行耗时操作
    await Future.delayed(Duration(seconds: 1));
  } finally {
    developer.Timeline.finishSync();
  }
}
```

## 部署指南

### 1. 构建优化

```yaml
# pubspec.yaml 优化配置
flutter:
  assets:
    - assets/images/
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf

# 启用代码混淆
flutter build apk --obfuscate --split-debug-info=debug-info/
```

### 2. 平台特定配置

#### Web 配置
```html
<!-- web/index.html -->
<meta name="description" content="Pet App V3 Home Dashboard">
<meta name="keywords" content="dashboard, pet app, flutter">
```

#### 桌面配置
```cpp
// windows/runner/main.cpp
// 设置窗口标题和图标
```

### 3. 持续集成

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
```

## 贡献指南

### 1. 开发流程

1. **Fork 项目**: 从主仓库 fork 到个人仓库
2. **创建分支**: `git checkout -b feature/new-feature`
3. **开发功能**: 按照代码规范开发新功能
4. **编写测试**: 确保测试覆盖率
5. **提交代码**: `git commit -m "feat: add new feature"`
6. **推送分支**: `git push origin feature/new-feature`
7. **创建PR**: 在GitHub上创建Pull Request

### 2. 代码审查

- 确保代码符合项目规范
- 检查测试覆盖率是否足够
- 验证功能是否正常工作
- 检查文档是否完整

### 3. 发布流程

1. **版本号更新**: 按照语义化版本规范更新版本号
2. **更新日志**: 更新 CHANGELOG.md
3. **创建标签**: `git tag v1.0.1`
4. **发布版本**: 推送标签触发自动发布

通过遵循这些开发指南，您可以高效地开发和维护 Home Dashboard 模块，为 Pet App V3 贡献高质量的代码。
