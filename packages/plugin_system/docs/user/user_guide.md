# Plugin System 用户指南

## 简介

Plugin System 是 Pet App V3 的核心插件化框架，让您可以轻松地创建、管理和使用插件来扩展应用功能。它提供了智能热重载、高级依赖管理、企业级权限控制等强大功能。

**版本**: v1.3.0
**新特性**:
- 🔥 智能热重载 - 开发时实时更新插件
- 🔗 智能依赖管理 - 自动解析和安装依赖
- 🔒 企业级权限控制 - 细粒度权限管理

## 快速开始

### 1. 安装依赖

在您的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  plugin_system:
    path: ../packages/plugin_system
```

### 2. 导入包

```dart
import 'package:plugin_system/plugin_system.dart';
```

### 3. 创建您的第一个插件

```dart
class MyFirstPlugin extends Plugin {
  @override
  String get id => 'my_first_plugin';
  
  @override
  String get name => 'My First Plugin';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => 'This is my first plugin';
  
  @override
  String get author => 'Your Name';
  
  @override
  PluginCategory get category => PluginCategory.tool;
  
  @override
  List<Permission> get requiredPermissions => [];
  
  @override
  List<PluginDependency> get dependencies => [];
  
  @override
  List<SupportedPlatform> get supportedPlatforms => [
    SupportedPlatform.android,
    SupportedPlatform.ios,
    SupportedPlatform.web,
  ];
  
  @override
  Future<void> initialize() async {
    print('[$id] Plugin initialized');
  }
  
  @override
  Future<void> start() async {
    print('[$id] Plugin started');
  }
  
  @override
  Future<void> pause() async {
    print('[$id] Plugin paused');
  }
  
  @override
  Future<void> resume() async {
    print('[$id] Plugin resumed');
  }
  
  @override
  Future<void> stop() async {
    print('[$id] Plugin stopped');
  }
  
  @override
  Future<void> dispose() async {
    print('[$id] Plugin disposed');
  }
  
  @override
  Object? getConfigWidget() {
    return null; // 返回配置界面，如果有的话
  }
  
  @override
  Object getMainWidget() {
    return {
      'type': 'text',
      'content': 'Hello from My First Plugin!',
    };
  }
  
  @override
  Future<dynamic> handleMessage(String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'greet':
        return {'message': 'Hello, ${data['name'] ?? 'World'}!'};
      default:
        return {'error': 'Unknown action: $action'};
    }
  }
  
  @override
  PluginState get currentState => _currentState;
  
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;
  
  // 私有状态管理
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController = 
      StreamController<PluginState>.broadcast();
}
```

### 4. 加载和使用插件

```dart
void main() async {
  // 创建插件实例
  final myPlugin = MyFirstPlugin();
  
  // 获取插件加载器
  final loader = PluginLoader.instance;
  
  // 加载插件
  await loader.loadPlugin(myPlugin);
  
  // 插件现在已经启动并可以使用了
  print('Plugin loaded successfully!');
}
```

## 核心概念

### 插件生命周期

每个插件都有以下生命周期状态：

1. **unloaded** - 未加载
2. **loaded** - 已加载到注册中心
3. **initialized** - 已初始化
4. **started** - 已启动（活跃状态）
5. **paused** - 已暂停
6. **stopped** - 已停止
7. **error** - 错误状态

### 插件类别

- **system** - 系统级插件
- **ui** - UI组件插件
- **tool** - 工具类插件
- **game** - 游戏插件
- **theme** - 主题插件
- **widget** - 小部件插件
- **service** - 服务类插件

### 权限系统

插件可以声明所需的权限：

- **fileSystem** - 文件系统访问
- **network** - 网络访问
- **camera** - 相机访问
- **microphone** - 麦克风访问
- **location** - 位置信息
- **notifications** - 通知权限
- **systemSettings** - 系统设置
- **storage** - 存储访问
- **contacts** - 联系人访问

## 常用操作

### 管理插件

```dart
final registry = PluginRegistry.instance;
final loader = PluginLoader.instance;

// 加载插件
await loader.loadPlugin(myPlugin);

// 检查插件是否存在
if (registry.contains('my_plugin_id')) {
  print('Plugin exists');
}

// 获取插件
final plugin = registry.get('my_plugin_id');

// 获取插件状态
final state = registry.getState('my_plugin_id');

// 暂停插件
await loader.pausePlugin('my_plugin_id');

// 恢复插件
await loader.resumePlugin('my_plugin_id');

// 卸载插件
await loader.unloadPlugin('my_plugin_id');
```

### 插件间通信

```dart
final messenger = PluginMessenger.instance;

// 发送消息并等待响应
final response = await messenger.sendMessage(
  'sender_plugin_id',
  'target_plugin_id',
  'greet',
  {'name': 'Alice'},
);

if (response.success) {
  print('Response: ${response.data}');
} else {
  print('Error: ${response.error}');
}

// 发送通知（不等待响应）
await messenger.sendNotification(
  'sender_plugin_id',
  'target_plugin_id',
  'notification',
  {'type': 'info', 'message': 'Hello!'},
);

// 广播消息
await messenger.broadcastMessage(
  'sender_plugin_id',
  'announcement',
  {'message': 'System update available'},
);
```

### 事件系统

```dart
final eventBus = EventBus.instance;

// 订阅事件
final subscription = eventBus.on('user_login', (event) {
  print('User logged in: ${event.data}');
});

// 发布事件
eventBus.publish('user_login', 'auth_plugin', data: {
  'userId': '12345',
  'username': 'alice',
});

// 等待特定事件
final event = await eventBus.waitFor('system_ready');
print('System is ready: ${event.data}');

// 取消订阅
subscription.cancel();
```

### 热重载功能

```dart
final hotReloadManager = HotReloadManager.instance;

// 启用热重载
await hotReloadManager.enableHotReload();

// 监听插件文件变化
await hotReloadManager.watchPlugin('my_plugin_id', '/path/to/plugin');

// 手动重载插件
await hotReloadManager.reloadPlugin('my_plugin_id');

// 监听热重载状态
hotReloadManager.stateChanges.listen((state) {
  print('Hot reload state: $state');
});
```

### 依赖管理

```dart
final dependencyManager = DependencyManager.instance;

// 检查插件依赖
final hasAllDeps = await dependencyManager.checkDependencies('my_plugin_id');
if (!hasAllDeps) {
  final missing = await dependencyManager.getMissingDependencies('my_plugin_id');
  print('Missing dependencies: $missing');
}

// 获取加载顺序
final loadOrder = await dependencyManager.getLoadOrder(['plugin1', 'plugin2', 'plugin3']);
print('Load order: $loadOrder');

// 检查循环依赖
final hasCircular = await dependencyManager.hasCircularDependency('my_plugin_id');
if (hasCircular) {
  print('Circular dependency detected!');
}
```

### 权限管理

```dart
final permissionManager = PermissionManager.instance;

// 检查权限
final hasPermission = await permissionManager.checkPermission(
  'my_plugin_id',
  Permission.fileSystem,
);

// 申请权限
final granted = await permissionManager.requestPermission(
  'my_plugin_id',
  Permission.network,
);

if (granted) {
  print('Network permission granted');
} else {
  print('Network permission denied');
}

// 批量申请权限
final results = await permissionManager.requestPermissions(
  'my_plugin_id',
  [Permission.camera, Permission.microphone],
);

results.forEach((permission, granted) {
  print('$permission: ${granted ? "granted" : "denied"}');
});
```

## 高级功能

### 插件依赖

```dart
class AdvancedPlugin extends Plugin {
  @override
  List<PluginDependency> get dependencies => [
    PluginDependency(
      pluginId: 'base_plugin',
      versionConstraint: '^1.0.0',
    ),
    PluginDependency(
      pluginId: 'optional_plugin',
      versionConstraint: '>=2.0.0',
      optional: true,
    ),
  ];
  
  // ... 其他实现
}
```

### 状态监听

```dart
// 监听插件状态变化
final stateStream = registry.getStateStream('my_plugin_id');
stateStream?.listen((state) {
  print('Plugin state changed to: $state');
});

// 监听插件自身状态变化
myPlugin.stateChanges.listen((state) {
  print('My plugin state: $state');
});
```

### 错误处理

```dart
try {
  await loader.loadPlugin(myPlugin);
} on PluginAlreadyExistsException {
  print('Plugin already exists');
} on PluginDependencyException catch (e) {
  print('Dependency error: $e');
} on PluginLoadException catch (e) {
  print('Load error: $e');
} catch (e) {
  print('Unexpected error: $e');
}
```

## 最佳实践

### 1. 插件设计原则

- **单一职责**: 每个插件只负责一个特定功能
- **松耦合**: 减少插件间的直接依赖
- **可配置**: 提供配置选项让用户自定义
- **错误处理**: 优雅地处理异常情况

### 2. 性能优化

- **按需加载**: 只在需要时加载插件
- **资源清理**: 在dispose方法中清理资源
- **异步操作**: 使用异步方法避免阻塞UI

### 3. 安全考虑

- **权限最小化**: 只申请必要的权限
- **输入验证**: 验证消息和事件数据
- **异常隔离**: 防止插件错误影响系统

### 4. 测试策略

- **单元测试**: 测试插件的核心功能
- **集成测试**: 测试插件间的交互
- **模拟测试**: 使用模拟对象测试边界情况

## 故障排除

### 常见问题

**Q: 插件加载失败怎么办？**
A: 检查插件的依赖是否满足，权限是否正确声明，以及是否有语法错误。

**Q: 插件间通信失败？**
A: 确认目标插件已加载并处于活跃状态，检查消息格式是否正确。

**Q: 事件没有被接收？**
A: 检查事件类型和源是否匹配，确认订阅在事件发布之前建立。

**Q: 插件状态异常？**
A: 查看插件的生命周期方法实现，确保正确更新状态。

**Q: 热重载失败？**
A: 检查文件路径是否正确，确认插件文件没有语法错误，查看热重载管理器状态。

**Q: 依赖解析失败？**
A: 检查依赖声明是否正确，确认依赖的插件已注册，查看是否存在循环依赖。

**Q: 权限申请被拒绝？**
A: 检查权限策略设置，确认用户是否拒绝了权限申请，查看权限申请的合理性。

### 调试技巧

1. **启用日志**: 在插件方法中添加日志输出
2. **状态监控**: 监听插件状态变化
3. **异常捕获**: 使用try-catch捕获和分析异常
4. **系统状态**: 使用getStatus方法查看系统状态

## 更多资源

- [API 文档](../api/plugin_api.md)
- [架构设计](../architecture/system_architecture.md)
- [开发者指南](../developer/developer_guide.md)
- [示例代码](../../test/helpers/test_plugin.dart)
