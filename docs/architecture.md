# Pet App V3 架构设计文档

## 🏗️ 整体架构概览

Pet App V3 采用"万物皆插件"的模块化架构设计，通过插件系统实现高度可扩展的应用生态。

```
┌─────────────────────────────────────────────────────────────┐
│                    Pet App V3 架构                          │
├─────────────────────────────────────────────────────────────┤
│  🏠 首页    🎨 创意工坊   📱 应用管理   🐾 桌宠   ⚙️ 设置    │
├─────────────────────────────────────────────────────────────┤
│                    插件运行时环境                            │
├─────────────────────────────────────────────────────────────┤
│                    平台适配层                               │
├─────────────────────────────────────────────────────────────┤
│              Flutter Framework & Dart VM                   │
├─────────────────────────────────────────────────────────────┤
│           📱 Mobile    🖥️ Desktop    🌐 Web                │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 核心设计理念

### 1. 万物皆插件 (Everything as Plugin)
```
🔌 系统级插件: 主题、设置、文件管理
🎮 功能级插件: 桌宠、小游戏、工具
🎨 UI级插件: 组件、布局、动画
🔧 开发级插件: 代码编辑器、调试器
```

### 2. 三端特征化 (Platform-Specific UX)
```
📱 Mobile: 触摸优化、底部导航、手势交互
🖥️ Desktop: 鼠标键盘、侧边栏、多窗口
🌐 Web: 浏览器特性、URL路由、响应式
```

### 3. 模块化解耦 (Modular Decoupling)
```
🔗 接口驱动: 模块间只通过接口通信
📦 独立打包: 每个模块可独立开发部署
🔄 热插拔: 支持运行时加载卸载模块
```

## 🏛️ 分层架构设计

### Layer 1: 平台层 (Platform Layer)
```dart
// 平台抽象接口
abstract class PlatformService {
  Future<void> initialize();
  bool get isSupported;
  Map<String, dynamic> get capabilities;
}

// 具体平台实现
class MobilePlatformService extends PlatformService { ... }
class DesktopPlatformService extends PlatformService { ... }
class WebPlatformService extends PlatformService { ... }
```

### Layer 2: 核心层 (Core Layer)
```dart
// 插件系统核心
class PluginSystem {
  static final PluginRegistry registry = PluginRegistry();
  static final PluginLoader loader = PluginLoader();
  static final PluginMessenger messenger = PluginMessenger();
  static final ResourceMonitor monitor = ResourceMonitor();
}

// 应用核心服务
class CoreServices {
  static final NavigationService navigation = NavigationService();
  static final ThemeService theme = ThemeService();
  static final ConfigService config = ConfigService();
  static final EventBus eventBus = EventBus();
}
```

### Layer 3: 业务层 (Business Layer)
```dart
// 五大核心模块
abstract class CoreModule {
  String get id;
  String get name;
  Widget buildUI();
  Future<void> initialize();
}

class HomeModule extends CoreModule { ... }
class CreativeWorkshopModule extends CoreModule { ... }
class AppManagerModule extends CoreModule { ... }
class DesktopPetModule extends CoreModule { ... }
class SettingsModule extends CoreModule { ... }
```

### Layer 4: 表现层 (Presentation Layer)
```dart
// 平台适配的UI层
class AdaptiveUI {
  static Widget build(BuildContext context, Widget child) {
    final adapter = PlatformAdaptationManager.current;
    return adapter.buildLayout(child);
  }
}
```

## 🔌 插件系统架构

### 插件生命周期管理
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   未加载     │───▶│   已加载     │───▶│  已初始化    │
│  Unloaded   │    │   Loaded    │    │ Initialized │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   已销毁     │◀───│   已停止     │◀───│   已启动     │
│  Disposed   │    │   Stopped   │    │   Started   │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
                                              ▼
                                      ┌─────────────┐
                                      │   已暂停     │
                                      │   Paused    │
                                      └─────────────┘
```

### 插件注册中心
```dart
class PluginRegistry {
  final Map<String, Plugin> _plugins = {};
  final Map<String, PluginMetadata> _metadata = {};
  final Map<String, PluginState> _states = {};
  
  // 插件注册
  Future<void> register(Plugin plugin) async {
    _validatePlugin(plugin);
    _plugins[plugin.id] = plugin;
    _metadata[plugin.id] = PluginMetadata.from(plugin);
    _states[plugin.id] = PluginState.loaded;
    
    await _resolveDependencies(plugin);
    _notifyPluginRegistered(plugin);
  }
  
  // 插件查找
  Plugin? get(String id) => _plugins[id];
  
  // 按类别查找
  List<Plugin> getByCategory(PluginCategory category) {
    return _plugins.values
        .where((p) => p.category == category)
        .toList();
  }
  
  // 依赖解析
  Future<void> _resolveDependencies(Plugin plugin) async {
    for (final dep in plugin.dependencies) {
      if (!_plugins.containsKey(dep.pluginId)) {
        if (!dep.optional) {
          throw PluginDependencyException(plugin.id, dep.pluginId);
        }
      }
    }
  }
}
```

### 插件通信机制
```dart
// 消息传递系统
class PluginMessenger {
  static final Map<String, StreamController> _channels = {};
  
  // 发送消息
  static Future<T?> sendMessage<T>(
    String targetPluginId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final target = PluginRegistry.get(targetPluginId);
    if (target == null) {
      throw PluginNotFoundException(targetPluginId);
    }
    
    return await target.handleMessage(action, data) as T?;
  }
  
  // 订阅消息
  static Stream<PluginMessage> subscribe(String pluginId) {
    _channels.putIfAbsent(
      pluginId, 
      () => StreamController<PluginMessage>.broadcast(),
    );
    return _channels[pluginId]!.stream;
  }
  
  // 广播消息
  static Future<void> broadcast(PluginMessage message) async {
    for (final controller in _channels.values) {
      controller.add(message);
    }
  }
}

// 事件总线
class EventBus {
  static final StreamController<Event> _controller = 
      StreamController<Event>.broadcast();
  
  static void emit(String type, dynamic data) {
    _controller.add(Event(type: type, data: data));
  }
  
  static Stream<Event> on(String type) {
    return _controller.stream.where((event) => event.type == type);
  }
}
```

## 🎨 创意工坊架构

### 插件开发环境
```dart
class CreativeWorkshop {
  final PluginProjectManager projectManager;
  final CodeEditor codeEditor;
  final PluginBuilder builder;
  final PluginTester tester;
  final PluginPublisher publisher;
  
  // 创建新插件项目
  Future<PluginProject> createProject(PluginTemplate template) async {
    final project = await projectManager.create(template);
    await _setupDevelopmentEnvironment(project);
    return project;
  }
  
  // 构建插件
  Future<PluginPackage> buildPlugin(PluginProject project) async {
    await _validateProject(project);
    final package = await builder.build(project);
    await _runTests(package);
    return package;
  }
  
  // 发布插件
  Future<void> publishPlugin(PluginPackage package) async {
    await _validatePackage(package);
    await publisher.publish(package);
    _notifyPublished(package);
  }
}
```

### Ming CLI集成
```dart
class MingCliIntegration {
  static Future<PluginProject> createFromTemplate(
    String templateName,
    Map<String, dynamic> config,
  ) async {
    // 调用Ming CLI生成项目
    final result = await Process.run('ming', [
      'template',
      'create',
      '--name=${config['name']}',
      '--type=${config['type']}',
      '--complexity=${config['complexity']}',
      '--output=${config['output']}',
      '--no-wizard',
    ]);
    
    if (result.exitCode != 0) {
      throw MingCliException(result.stderr);
    }
    
    return PluginProject.fromPath(config['output']);
  }
}
```

## 📱 应用管理架构

### 插件运行时环境
```dart
class PluginRuntime {
  final Map<String, PluginInstance> _instances = {};
  final ResourceMonitor _monitor = ResourceMonitor();
  final SecurityManager _security = SecurityManager();
  
  // 启动插件实例
  Future<PluginInstance> startPlugin(String pluginId) async {
    final plugin = PluginRegistry.get(pluginId);
    if (plugin == null) {
      throw PluginNotFoundException(pluginId);
    }
    
    // 权限检查
    await _security.checkPermissions(plugin);
    
    // 创建隔离的运行环境
    final instance = PluginInstance(plugin);
    await instance.initialize();
    
    // 资源监控
    _monitor.startMonitoring(instance);
    
    _instances[pluginId] = instance;
    return instance;
  }
  
  // 停止插件实例
  Future<void> stopPlugin(String pluginId) async {
    final instance = _instances[pluginId];
    if (instance != null) {
      _monitor.stopMonitoring(instance);
      await instance.dispose();
      _instances.remove(pluginId);
    }
  }
}
```

### 文件系统管理
```dart
class PluginFileSystem {
  final String _basePath;
  final Map<String, String> _pluginPaths = {};
  
  // 为插件分配独立的文件空间
  String getPluginPath(String pluginId) {
    return _pluginPaths.putIfAbsent(
      pluginId,
      () => path.join(_basePath, 'plugins', pluginId),
    );
  }
  
  // 文件访问权限控制
  Future<bool> checkFileAccess(String pluginId, String filePath) async {
    final pluginPath = getPluginPath(pluginId);
    return filePath.startsWith(pluginPath);
  }
}
```

## 🔒 安全架构

### 权限管理系统
```dart
class SecurityManager {
  final Map<String, Set<Permission>> _grantedPermissions = {};
  
  // 检查插件权限
  Future<void> checkPermissions(Plugin plugin) async {
    for (final permission in plugin.requiredPermissions) {
      if (!await _hasPermission(plugin.id, permission)) {
        final granted = await _requestPermission(plugin.id, permission);
        if (!granted) {
          throw PermissionDeniedException(plugin.id, permission);
        }
      }
    }
  }
  
  // 权限沙箱
  Future<T> executeWithPermissions<T>(
    String pluginId,
    List<Permission> permissions,
    Future<T> Function() operation,
  ) async {
    final context = SecurityContext(pluginId, permissions);
    return await SecurityZone.run(context, operation);
  }
}
```

### 资源限制
```dart
class ResourceMonitor {
  final Map<String, ResourceUsage> _usage = {};
  
  // 监控插件资源使用
  void startMonitoring(PluginInstance instance) {
    final timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final usage = _measureUsage(instance);
      _usage[instance.pluginId] = usage;
      
      if (_isExceedingLimits(usage)) {
        _handleResourceViolation(instance);
      }
    });
    
    instance.onDispose(() => timer.cancel());
  }
  
  // 处理资源违规
  void _handleResourceViolation(PluginInstance instance) {
    // 警告 -> 限制 -> 终止
    final violations = _getViolationCount(instance.pluginId);
    
    if (violations > 3) {
      instance.terminate();
    } else if (violations > 1) {
      instance.throttle();
    } else {
      instance.warn();
    }
  }
}
```

## 🎨 UI架构设计

### 响应式设计系统
```dart
class ResponsiveDesignSystem {
  static const breakpoints = {
    'mobile': 600.0,
    'tablet': 900.0,
    'desktop': 1200.0,
    'ultrawide': 1600.0,
  };
  
  static Widget adaptive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? ultrawide,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= breakpoints['ultrawide']!) {
          return ultrawide ?? desktop ?? tablet ?? mobile;
        } else if (width >= breakpoints['desktop']!) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= breakpoints['tablet']!) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### 主题系统
```dart
class ThemeSystem {
  static final Map<String, ThemeData> _themes = {};
  static final ValueNotifier<String> _currentTheme = ValueNotifier('default');
  
  // 注册主题
  static void registerTheme(String id, ThemeData theme) {
    _themes[id] = theme;
  }
  
  // 切换主题
  static void switchTheme(String themeId) {
    if (_themes.containsKey(themeId)) {
      _currentTheme.value = themeId;
    }
  }
  
  // 获取当前主题
  static ThemeData get currentTheme {
    return _themes[_currentTheme.value] ?? ThemeData();
  }
}
```

## 📊 性能架构

### 懒加载系统
```dart
class LazyLoadManager {
  final Map<String, Future<dynamic>> _loadingCache = {};
  
  // 懒加载插件
  Future<Plugin> loadPlugin(String pluginId) async {
    return _loadingCache.putIfAbsent(
      pluginId,
      () => _doLoadPlugin(pluginId),
    ) as Future<Plugin>;
  }
  
  // 预加载策略
  Future<void> preloadCriticalPlugins() async {
    final criticalPlugins = ['theme_system', 'navigation', 'settings'];
    await Future.wait(
      criticalPlugins.map((id) => loadPlugin(id)),
    );
  }
}
```

### 缓存系统
```dart
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final int _maxSize;
  final Duration _ttl;
  
  // 缓存数据
  void put(String key, dynamic data) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
    
    _evictIfNeeded();
  }
  
  // 获取缓存
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().difference(entry.timestamp) > _ttl) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data as T?;
  }
}
```

## 🔄 数据流架构

### 状态管理
```dart
// 使用Riverpod进行状态管理
final pluginStateProvider = StateNotifierProvider.family<
    PluginStateNotifier, 
    PluginState, 
    String
>((ref, pluginId) {
  return PluginStateNotifier(pluginId);
});

class PluginStateNotifier extends StateNotifier<PluginState> {
  final String pluginId;
  
  PluginStateNotifier(this.pluginId) : super(PluginState.unloaded);
  
  Future<void> loadPlugin() async {
    state = PluginState.loading;
    try {
      await PluginRegistry.load(pluginId);
      state = PluginState.loaded;
    } catch (e) {
      state = PluginState.error;
    }
  }
}
```

### 数据持久化
```dart
class DataPersistence {
  static final Map<String, StorageAdapter> _adapters = {};
  
  // 注册存储适配器
  static void registerAdapter(String type, StorageAdapter adapter) {
    _adapters[type] = adapter;
  }
  
  // 保存数据
  static Future<void> save(String key, dynamic data, {String? type}) async {
    final adapter = _adapters[type ?? 'default'];
    if (adapter != null) {
      await adapter.save(key, data);
    }
  }
  
  // 加载数据
  static Future<T?> load<T>(String key, {String? type}) async {
    final adapter = _adapters[type ?? 'default'];
    if (adapter != null) {
      return await adapter.load<T>(key);
    }
    return null;
  }
}
```

## 📋 架构原则

### 1. 单一职责原则 (SRP)
每个模块、类和函数都应该有且仅有一个职责。

### 2. 开闭原则 (OCP)
系统应该对扩展开放，对修改关闭。通过插件系统实现功能扩展。

### 3. 依赖倒置原则 (DIP)
高层模块不应该依赖低层模块，都应该依赖抽象。

### 4. 接口隔离原则 (ISP)
客户端不应该依赖它不需要的接口。

### 5. 最小权限原则
插件只能访问其声明的权限范围内的资源。

---

更多详细信息请参考：
- [开发指南](./development_guide.md)
- [插件API文档](./plugin_api.md)
- [平台特征化指南](./platform_guide.md)
