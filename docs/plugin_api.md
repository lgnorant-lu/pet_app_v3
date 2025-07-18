# Pet App V3 插件API文档

## 🔌 插件系统概述

Pet App V3的插件系统基于"万物皆插件"的理念设计，提供统一的插件接口规范，支持动态加载、热重载、版本管理和资源控制。

## 📋 插件接口规范

### 核心插件基类

```dart
/// 插件基类 - 所有插件必须继承此类
abstract class Plugin {
  /// 插件唯一标识符
  String get id;
  
  /// 插件显示名称
  String get name;
  
  /// 插件版本号 (语义化版本)
  String get version;
  
  /// 插件描述
  String get description;
  
  /// 插件作者
  String get author;
  
  /// 插件类别
  PluginCategory get category;
  
  /// 所需权限列表
  List<Permission> get requiredPermissions;
  
  /// 依赖的其他插件
  List<PluginDependency> get dependencies;
  
  /// 支持的平台
  List<TargetPlatform> get supportedPlatforms;
  
  /// 插件初始化
  Future<void> initialize();
  
  /// 启动插件
  Future<void> start();
  
  /// 暂停插件
  Future<void> pause();
  
  /// 恢复插件
  Future<void> resume();
  
  /// 停止插件
  Future<void> stop();
  
  /// 销毁插件
  Future<void> dispose();
  
  /// 获取插件配置界面
  Widget? getConfigWidget();
  
  /// 获取插件主界面
  Widget getMainWidget();
  
  /// 处理插件间消息
  Future<dynamic> handleMessage(String action, Map<String, dynamic> data);
}
```

### 插件元数据定义

```dart
/// 插件类别枚举
enum PluginCategory {
  system,      // 系统级插件
  ui,          // UI组件插件
  tool,        // 工具类插件
  game,        // 游戏插件
  theme,       // 主题插件
  widget,      // 小部件插件
  service,     // 服务类插件
}

/// 权限枚举
enum Permission {
  fileSystem,     // 文件系统访问
  network,        // 网络访问
  camera,         // 相机访问
  microphone,     // 麦克风访问
  location,       // 位置信息
  notifications,  // 通知权限
  systemSettings, // 系统设置
  storage,        // 存储访问
  contacts,       // 联系人访问
}

/// 插件依赖定义
class PluginDependency {
  final String pluginId;
  final String versionConstraint;
  final bool optional;
  
  const PluginDependency({
    required this.pluginId,
    required this.versionConstraint,
    this.optional = false,
  });
}
```

### 插件配置文件格式

```yaml
# plugin.yaml - 插件元数据配置文件
name: example_plugin
version: 1.0.0
description: 示例插件
author: Pet App Team
category: tool
homepage: https://github.com/pet-app/example-plugin

# 平台支持
platforms:
  - android
  - ios
  - windows
  - macos
  - linux
  - web

# 权限要求
permissions:
  - fileSystem
  - network

# 依赖插件
dependencies:
  theme_system: "^1.0.0"
  ui_components:
    version: ">=2.0.0 <3.0.0"
    optional: true

# 兼容性
compatibility:
  core_api: ">=1.0.0 <2.0.0"
  flutter: ">=3.0.0"
  dart: ">=3.0.0"

# 资源限制
resources:
  max_memory_mb: 100
  max_cpu_percent: 30
  max_execution_ms: 5000
```

## 🔧 插件开发指南

### 1. 创建插件项目

```bash
# 使用Ming CLI创建插件项目
ming template create \
  --name=my_awesome_plugin \
  --type=plugin \
  --complexity=medium \
  --author="Your Name" \
  --description="我的超棒插件"
```

### 2. 实现插件类

```dart
// lib/my_awesome_plugin.dart
import 'package:pet_app_plugin_api/pet_app_plugin_api.dart';

class MyAwesomePlugin extends Plugin {
  @override
  String get id => 'my_awesome_plugin';
  
  @override
  String get name => '我的超棒插件';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => '这是一个示例插件';
  
  @override
  String get author => 'Your Name';
  
  @override
  PluginCategory get category => PluginCategory.tool;
  
  @override
  List<Permission> get requiredPermissions => [
    Permission.fileSystem,
    Permission.network,
  ];
  
  @override
  List<PluginDependency> get dependencies => [
    PluginDependency(
      pluginId: 'theme_system',
      versionConstraint: '^1.0.0',
    ),
  ];
  
  @override
  List<TargetPlatform> get supportedPlatforms => [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.fuchsia,
  ];
  
  @override
  Future<void> initialize() async {
    // 插件初始化逻辑
    print('$name 插件初始化完成');
  }
  
  @override
  Future<void> start() async {
    // 插件启动逻辑
    print('$name 插件已启动');
  }
  
  @override
  Future<void> pause() async {
    // 插件暂停逻辑
  }
  
  @override
  Future<void> resume() async {
    // 插件恢复逻辑
  }
  
  @override
  Future<void> stop() async {
    // 插件停止逻辑
    print('$name 插件已停止');
  }
  
  @override
  Future<void> dispose() async {
    // 插件销毁逻辑
    print('$name 插件已销毁');
  }
  
  @override
  Widget? getConfigWidget() {
    // 返回插件配置界面
    return MyAwesomePluginConfig();
  }
  
  @override
  Widget getMainWidget() {
    // 返回插件主界面
    return MyAwesomePluginMain();
  }
  
  @override
  Future<dynamic> handleMessage(String action, Map<String, dynamic> data) async {
    // 处理插件间消息
    switch (action) {
      case 'getData':
        return {'result': 'success', 'data': 'some data'};
      case 'updateConfig':
        // 更新配置逻辑
        return {'result': 'updated'};
      default:
        throw UnsupportedError('Unknown action: $action');
    }
  }
}
```

### 3. 插件UI组件

```dart
// lib/widgets/my_awesome_plugin_main.dart
class MyAwesomePluginMain extends StatefulWidget {
  @override
  _MyAwesomePluginMainState createState() => _MyAwesomePluginMainState();
}

class _MyAwesomePluginMainState extends State<MyAwesomePluginMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的超棒插件'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('这是插件的主界面'),
            ElevatedButton(
              onPressed: () {
                // 插件功能逻辑
              },
              child: Text('执行功能'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 插件生命周期

### 生命周期状态

```dart
enum PluginState {
  unloaded,    // 未加载
  loaded,      // 已加载
  initialized, // 已初始化
  started,     // 已启动
  paused,      // 已暂停
  stopped,     // 已停止
  error,       // 错误状态
}
```

### 生命周期流程

```
unloaded → loaded → initialized → started
    ↑         ↓         ↓           ↓
    └─────────┴─────────┴───────────┘
                                   ↓
                              paused ↔ resumed
                                   ↓
                               stopped
                                   ↓
                               disposed
```

## 📡 插件间通信

### 消息传递机制

```dart
// 发送消息给其他插件
class PluginMessenger {
  static Future<T?> sendMessage<T>(
    String targetPluginId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final targetPlugin = PluginRegistry.get(targetPluginId);
    if (targetPlugin == null) {
      throw PluginNotFoundException(targetPluginId);
    }
    
    return await targetPlugin.handleMessage(action, data) as T?;
  }
  
  // 广播消息给所有插件
  static Future<void> broadcast(
    String action,
    Map<String, dynamic> data,
  ) async {
    final plugins = PluginRegistry.getAllActive();
    for (final plugin in plugins) {
      try {
        await plugin.handleMessage(action, data);
      } catch (e) {
        // 记录错误但不中断其他插件
        print('Plugin ${plugin.id} failed to handle broadcast: $e');
      }
    }
  }
}
```

### 事件总线

```dart
// 全局事件总线
class EventBus {
  static final _controller = StreamController<Event>.broadcast();
  
  static void emit(String type, dynamic data) {
    _controller.add(Event(type: type, data: data));
  }
  
  static Stream<Event> on(String type) {
    return _controller.stream.where((event) => event.type == type);
  }
  
  static StreamSubscription<Event> listen(
    String type,
    void Function(Event) onData,
  ) {
    return on(type).listen(onData);
  }
}

class Event {
  final String type;
  final dynamic data;
  final DateTime timestamp;
  
  Event({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}
```

## 🔒 权限管理

### 权限检查

```dart
class PermissionManager {
  static Future<bool> checkPermission(
    String pluginId,
    Permission permission,
  ) async {
    final plugin = PluginRegistry.get(pluginId);
    if (plugin == null) return false;
    
    return plugin.requiredPermissions.contains(permission);
  }
  
  static Future<bool> requestPermission(
    String pluginId,
    Permission permission,
  ) async {
    // 检查插件是否声明了该权限
    if (!await checkPermission(pluginId, permission)) {
      throw PermissionNotDeclaredException(pluginId, permission);
    }
    
    // 根据权限类型进行相应的权限请求
    switch (permission) {
      case Permission.camera:
        return await _requestCameraPermission();
      case Permission.location:
        return await _requestLocationPermission();
      // ... 其他权限处理
      default:
        return true;
    }
  }
}
```

## 📊 性能监控

### 资源使用监控

```dart
class ResourceMonitor {
  static Future<T> executeWithLimits<T>(
    String pluginId,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      return await operation().timeout(
        Duration(milliseconds: maxExecutionMs),
      );
    } on TimeoutException {
      await _killPlugin(pluginId);
      throw PluginTimeoutException(pluginId);
    } finally {
      stopwatch.stop();
      _recordPerformance(pluginId, stopwatch.elapsedMilliseconds);
    }
  }
  
  static void _recordPerformance(String pluginId, int executionTime) {
    // 记录插件性能数据
    PerformanceTracker.record(pluginId, executionTime);
  }
}
```

## 🧪 插件测试

### 单元测试示例

```dart
// test/my_awesome_plugin_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_awesome_plugin/my_awesome_plugin.dart';

void main() {
  group('MyAwesomePlugin', () {
    late MyAwesomePlugin plugin;
    
    setUp(() {
      plugin = MyAwesomePlugin();
    });
    
    test('should initialize successfully', () async {
      await plugin.initialize();
      expect(plugin.id, equals('my_awesome_plugin'));
      expect(plugin.name, equals('我的超棒插件'));
    });
    
    test('should handle messages correctly', () async {
      final result = await plugin.handleMessage('getData', {});
      expect(result['result'], equals('success'));
    });
    
    tearDown(() async {
      await plugin.dispose();
    });
  });
}
```

## 📚 最佳实践

### 1. 插件设计原则
- 单一职责：每个插件只负责一个明确的功能
- 最小权限：只申请必需的权限
- 优雅降级：在依赖不可用时提供备选方案
- 错误处理：妥善处理异常情况

### 2. 性能优化
- 懒加载：按需加载资源和功能
- 内存管理：及时释放不需要的资源
- 异步操作：避免阻塞主线程
- 缓存策略：合理使用缓存提升性能

### 3. 用户体验
- 响应式设计：适配不同屏幕尺寸
- 平台特征：遵循平台设计规范
- 无障碍访问：支持辅助功能
- 国际化：支持多语言

---

更多详细信息请参考：
- [开发指南](./development_guide.md)
- [架构设计](./architecture.md)
- [平台特征化指南](./platform_guide.md)
