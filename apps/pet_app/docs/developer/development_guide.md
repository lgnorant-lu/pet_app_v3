# Pet App V3 开发者指南

## 概述
Pet App V3 开发者指南，涵盖架构设计、开发流程、测试规范和部署指南。

## 开发环境设置

### 系统要求
- **Flutter**: 3.16.0 或更高版本
- **Dart**: 3.2.0 或更高版本
- **IDE**: VS Code 或 Android Studio
- **Git**: 用于版本控制

### 项目结构
```
pet_app_v3/apps/pet_app/
├── lib/
│   ├── core/                    # 核心系统
│   │   ├── lifecycle/           # 生命周期管理
│   │   ├── communication/       # 通信系统
│   │   ├── plugins/            # 插件系统
│   │   ├── workshop/           # 创意工坊
│   │   └── providers/          # 状态管理
│   ├── ui/                     # UI组件
│   │   ├── framework/          # 主框架
│   │   ├── navigation/         # 导航系统
│   │   ├── pages/              # 页面组件
│   │   │   ├── home/           # 首页仪表板
│   │   │   └── settings/       # 设置页面
│   │   └── components/         # 通用组件
│   ├── app.dart               # 应用入口
│   └── main.dart              # 主函数
├── test/                      # 测试文件
├── docs/                      # 文档
└── pubspec.yaml              # 依赖配置
```

### 依赖管理
```yaml
dependencies:
  flutter:
    sdk: flutter
  # 状态管理
  flutter_riverpod: ^2.4.9
  # 核心依赖
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  # UI组件
  cupertino_icons: ^1.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 架构设计原则

### 1. 分层架构
```
┌─────────────────┐
│   表现层 (UI)    │  ← 用户界面和交互
├─────────────────┤
│   业务层 (Core)  │  ← 业务逻辑和数据处理
├─────────────────┤
│   通信层 (Comm)  │  ← 模块间通信和事件
├─────────────────┤
│   基础层 (Base)  │  ← 生命周期和状态管理
└─────────────────┘
```

### 2. 模块化设计
- **高内聚**: 模块内部功能紧密相关
- **低耦合**: 模块间通过接口通信
- **可插拔**: 模块可以独立开发和部署
- **可测试**: 每个模块都有完整的测试覆盖

### 3. 事件驱动
- **异步通信**: 基于事件的异步消息传递
- **松耦合**: 发送者和接收者不直接依赖
- **可扩展**: 易于添加新的事件处理器
- **可监控**: 完整的事件追踪和调试

## 开发流程

### 1. 功能开发流程
```
需求分析 → 架构设计 → 接口定义 → 实现开发 → 单元测试 → 集成测试 → 文档更新 → 代码审查 → 合并部署
```

### 2. 代码规范

#### 命名规范
```dart
// 类名：大驼峰
class NavigationManager { }

// 方法名：小驼峰
void navigateToPage() { }

// 常量：大写下划线
const int MAX_RETRY_COUNT = 3;

// 私有成员：下划线前缀
String _privateField;
```

#### 文件组织
```dart
/*
---------------------------------------------------------------
File name:          navigation_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        导航管理器实现
---------------------------------------------------------------
Change History:
    2025-07-19: 初始实现导航管理功能
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'dart:async';

// 导入顺序：Flutter → Dart → 第三方 → 项目内部
```

### 3. 测试规范

#### 测试覆盖要求
- **单元测试**: 覆盖率 > 90%
- **集成测试**: 覆盖主要业务流程
- **UI测试**: 覆盖关键用户交互
- **性能测试**: 验证关键性能指标

#### 测试文件结构
```dart
void main() {
  group('NavigationManager Tests', () {
    late NavigationManager navigationManager;

    setUp(() {
      navigationManager = NavigationManager();
    });

    tearDown(() {
      navigationManager.dispose();
    });

    group('基础功能', () {
      test('应该能够注册路由', () {
        // 测试实现
      });
    });
  });
}
```

## 核心系统开发

### 1. 生命周期管理开发

#### 实现新的生命周期状态
```dart
enum CustomLifecycleState {
  initializing,
  ready,
  suspended,
  terminated,
}

class CustomLifecycleManager extends AppLifecycleManager {
  @override
  Future<void> handleStateChange(CustomLifecycleState newState) async {
    // 自定义状态处理逻辑
  }
}
```

#### 注册生命周期监听器
```dart
AppLifecycleManager.instance.stateStream.listen((state) {
  switch (state) {
    case AppLifecycleState.started:
      // 应用启动处理
      break;
    case AppLifecycleState.paused:
      // 应用暂停处理
      break;
  }
});
```

### 2. 消息总线开发

#### 定义新的消息类型
```dart
class CustomMessage extends UnifiedMessage {
  final String customData;
  
  CustomMessage({
    required String sender,
    required String action,
    required this.customData,
    Map<String, dynamic>? data,
  }) : super(
    sender: sender,
    action: action,
    data: data ?? {},
  );
}
```

#### 实现消息处理器
```dart
class CustomMessageHandler {
  MessageSubscription? _subscription;
  
  void initialize() {
    _subscription = UnifiedMessageBus.instance.subscribe(
      _handleMessage,
      filter: (message) => message.action.startsWith('custom_'),
    );
  }
  
  Future<UnifiedMessage?> _handleMessage(UnifiedMessage message) async {
    // 消息处理逻辑
    return null;
  }
  
  void dispose() {
    _subscription?.cancel();
  }
}
```

### 3. UI组件开发

#### 创建新的UI组件
```dart
class CustomWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  
  const CustomWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(widget.title),
      ),
    );
  }
}
```

#### 集成到导航系统
```dart
// 注册路由
NavigationManager.instance.registerRoute(
  '/custom',
  (context, parameters) => CustomWidget(
    title: parameters['title'] ?? 'Default Title',
    onTap: () => NavigationManager.instance.navigateBack(),
  ),
);

// 注册快捷键
KeyboardShortcutManager.instance.registerShortcut(
  ShortcutEntry(
    id: 'open_custom',
    combination: ShortcutCombination.simple(
      key: LogicalKeyboardKey.keyC,
      ctrl: true,
    ),
    action: () async {
      await NavigationManager.instance.navigateTo('/custom');
      return true;
    },
  ),
);
```

## 插件开发

### 1. 创建新插件

#### 插件基础结构
```dart
class CustomPlugin extends PluginInterface {
  @override
  String get name => 'custom_plugin';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => '自定义插件示例';
  
  @override
  Future<void> initialize() async {
    // 插件初始化逻辑
  }
  
  @override
  Future<void> dispose() async {
    // 插件清理逻辑
  }
  
  @override
  Widget buildWidget(BuildContext context) {
    return CustomPluginWidget();
  }
}
```

#### 注册插件
```dart
void main() async {
  // 注册插件
  PluginRegistry.instance.register(CustomPlugin());
  
  // 启动应用
  runApp(MyApp());
}
```

### 2. 工具插件开发

#### 实现工具插件接口
```dart
class CustomToolPlugin extends ToolPlugin {
  @override
  String get toolName => 'Custom Tool';
  
  @override
  IconData get toolIcon => Icons.build;
  
  @override
  Widget buildToolInterface(BuildContext context) {
    return CustomToolInterface();
  }
  
  @override
  Future<void> executeTool(Map<String, dynamic> parameters) async {
    // 工具执行逻辑
  }
}
```

### 3. 游戏插件开发

#### 实现游戏插件接口
```dart
class CustomGamePlugin extends GamePlugin {
  @override
  String get gameName => 'Custom Game';
  
  @override
  String get gameDescription => '自定义游戏示例';
  
  @override
  Widget buildGameInterface(BuildContext context) {
    return CustomGameInterface();
  }
  
  @override
  Future<void> startGame() async {
    // 游戏启动逻辑
  }
  
  @override
  Future<void> pauseGame() async {
    // 游戏暂停逻辑
  }
}
```

## Phase 4 UI开发

### 1. 首页仪表板开发

#### 创建新的首页组件
```dart
class CustomDashboardWidget extends ConsumerWidget {
  const CustomDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自定义仪表板',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (homeData.isLoading)
              const CircularProgressIndicator()
            else
              _buildContent(context, homeData),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeData data) {
    // 自定义内容实现
    return Container();
  }
}
```

#### 集成到首页
```dart
// 在 home_page.dart 中添加新组件
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: CustomDashboardWidget(),
  ),
),
```

### 2. 设置系统开发

#### 创建新的设置分类
```dart
class CustomSettings {
  final bool enableFeature;
  final String customValue;
  final int threshold;

  const CustomSettings({
    this.enableFeature = false,
    this.customValue = '',
    this.threshold = 10,
  });

  CustomSettings copyWith({
    bool? enableFeature,
    String? customValue,
    int? threshold,
  }) {
    return CustomSettings(
      enableFeature: enableFeature ?? this.enableFeature,
      customValue: customValue ?? this.customValue,
      threshold: threshold ?? this.threshold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableFeature': enableFeature,
      'customValue': customValue,
      'threshold': threshold,
    };
  }

  factory CustomSettings.fromJson(Map<String, dynamic> json) {
    return CustomSettings(
      enableFeature: json['enableFeature'] ?? false,
      customValue: json['customValue'] ?? '',
      threshold: json['threshold'] ?? 10,
    );
  }
}
```

#### 创建设置页面
```dart
class CustomSettingsPage extends ConsumerWidget {
  const CustomSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(customSettingsProvider);
    final notifier = ref.read(customSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义设置'),
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: '功能设置',
            children: [
              SwitchListTile(
                title: const Text('启用功能'),
                subtitle: const Text('开启或关闭自定义功能'),
                value: settings.enableFeature,
                onChanged: (value) {
                  notifier.updateEnableFeature(value);
                },
              ),
              ListTile(
                title: const Text('自定义值'),
                subtitle: Text(settings.customValue.isEmpty ? '未设置' : settings.customValue),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditDialog(context, notifier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 3. 状态管理开发

#### 创建Provider
```dart
final customSettingsProvider = StateNotifierProvider<CustomSettingsNotifier, CustomSettings>((ref) {
  return CustomSettingsNotifier();
});

class CustomSettingsNotifier extends StateNotifier<CustomSettings> {
  CustomSettingsNotifier() : super(const CustomSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // 从持久化存储加载设置
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('custom_settings');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      state = CustomSettings.fromJson(json);
    }
  }

  Future<void> updateEnableFeature(bool value) async {
    state = state.copyWith(enableFeature: value);
    await _saveSettings();
  }

  Future<void> updateCustomValue(String value) async {
    state = state.copyWith(customValue: value);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_settings', jsonEncode(state.toJson()));
  }
}
```

## 测试开发

### 1. 单元测试

#### 测试生命周期管理
```dart
void main() {
  group('AppLifecycleManager Tests', () {
    late AppLifecycleManager manager;
    
    setUp(() {
      manager = AppLifecycleManager.instance;
    });
    
    test('应该能够初始化', () async {
      await manager.initialize();
      expect(manager.currentState, equals(AppLifecycleState.initialized));
    });
    
    test('应该能够启动应用', () async {
      await manager.startApplication();
      expect(manager.currentState, equals(AppLifecycleState.started));
    });
  });
}
```

#### 测试消息总线
```dart
void main() {
  group('UnifiedMessageBus Tests', () {
    late UnifiedMessageBus messageBus;
    
    setUp(() {
      messageBus = UnifiedMessageBus.instance;
    });
    
    test('应该能够发布和接收消息', () async {
      String? receivedAction;
      
      final subscription = messageBus.subscribe(
        (message) async {
          receivedAction = message.action;
          return null;
        },
      );
      
      await messageBus.publishEvent('test', 'test_action', {});
      
      expect(receivedAction, equals('test_action'));
      subscription.cancel();
    });
  });
}
```

### 2. 集成测试

#### 测试模块集成
```dart
void main() {
  group('Module Integration Tests', () {
    testWidgets('应该能够加载和切换模块', (WidgetTester tester) async {
      await tester.pumpWidget(const MainAppFramework(
        initialModule: 'home',
      ));
      
      // 验证初始模块加载
      expect(find.text('首页'), findsOneWidget);
      
      // 切换到创意工坊
      await tester.tap(find.text('创意工坊'));
      await tester.pumpAndSettle();
      
      // 验证模块切换
      expect(find.text('创意工坊'), findsOneWidget);
    });
  });
}
```

## 性能优化

### 1. 内存管理
```dart
class MemoryOptimizedWidget extends StatefulWidget {
  @override
  State<MemoryOptimizedWidget> createState() => _MemoryOptimizedWidgetState();
}

class _MemoryOptimizedWidgetState extends State<MemoryOptimizedWidget> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen(_handleData);
  }
  
  @override
  void dispose() {
    _subscription.cancel(); // 防止内存泄漏
    super.dispose();
  }
  
  void _handleData(dynamic data) {
    if (mounted) { // 检查组件是否仍然挂载
      setState(() {
        // 更新状态
      });
    }
  }
}
```

### 2. 性能监控
```dart
class PerformanceMonitor {
  static void measureExecutionTime(String operation, Function() function) {
    final stopwatch = Stopwatch()..start();
    function();
    stopwatch.stop();
    
    debugPrint('$operation took ${stopwatch.elapsedMilliseconds}ms');
  }
  
  static Future<void> measureAsyncExecutionTime(
    String operation,
    Future<void> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    await function();
    stopwatch.stop();
    
    debugPrint('$operation took ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

## 调试和故障排除

### 1. 日志系统
```dart
class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  static void info(String message) {
    print('[INFO] $message');
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }
}
```

### 2. 错误处理
```dart
class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    Logger.error('Unhandled error', error, stackTrace);
    
    // 发送错误报告
    _sendErrorReport(error, stackTrace);
    
    // 尝试恢复
    _attemptRecovery();
  }
  
  static void _sendErrorReport(Object error, StackTrace stackTrace) {
    // 实现错误报告逻辑
  }
  
  static void _attemptRecovery() {
    // 实现错误恢复逻辑
  }
}
```

## 部署指南

### 1. 构建配置
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/configs/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
```

### 2. 平台特定配置

#### Android配置
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:name=".MainApplication"
    android:label="Pet App V3"
    android:icon="@mipmap/ic_launcher">
    
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme">
        
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="petapp" />
        </intent-filter>
    </activity>
</application>
```

#### iOS配置
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>petapp.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>petapp</string>
        </array>
    </dict>
</array>
```

### 3. 构建命令
```bash
# 开发构建
flutter run

# 发布构建
flutter build apk --release
flutter build ios --release
flutter build web --release

# 分析构建
flutter analyze
flutter test --coverage
```

## 版本管理

### 1. 版本号规范
- **主版本号**: 重大架构变更
- **次版本号**: 新功能添加
- **修订版本号**: 错误修复

### 2. 发布流程
```bash
# 1. 更新版本号
# pubspec.yaml: version: 3.3.0+1

# 2. 更新变更日志
# CHANGELOG.md

# 3. 运行测试
flutter test

# 4. 构建发布版本
flutter build apk --release

# 5. 创建Git标签
git tag v3.3.0
git push origin v3.3.0
```
