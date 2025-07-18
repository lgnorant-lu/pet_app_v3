# Plugin System API 文档

## 概述

Plugin System 是 Pet App V3 的核心插件化框架，提供了完整的插件生命周期管理、通信机制、事件系统、热重载支持、依赖管理和权限控制。

## 核心 API

### Plugin 基类

所有插件必须继承的基类，定义了插件的基本接口。

```dart
abstract class Plugin {
  // 基本属性
  String get id;              // 插件唯一标识符
  String get name;            // 插件显示名称
  String get version;         // 插件版本号
  String get description;     // 插件描述
  String get author;          // 插件作者
  
  // 分类和权限
  PluginCategory get category;                    // 插件类别
  List<Permission> get requiredPermissions;       // 所需权限
  List<PluginDependency> get dependencies;        // 依赖的其他插件
  List<SupportedPlatform> get supportedPlatforms; // 支持的平台
  
  // 生命周期方法
  Future<void> initialize();  // 初始化插件
  Future<void> start();       // 启动插件
  Future<void> pause();       // 暂停插件
  Future<void> resume();      // 恢复插件
  Future<void> stop();        // 停止插件
  Future<void> dispose();     // 销毁插件
  
  // UI 接口
  Object? getConfigWidget();  // 获取配置界面
  Object getMainWidget();     // 获取主界面
  
  // 消息处理
  Future<dynamic> handleMessage(String action, Map<String, dynamic> data);
  
  // 状态管理
  PluginState get currentState;           // 当前状态
  Stream<PluginState> get stateChanges;   // 状态变化流
}
```

### PluginRegistry 注册中心

管理所有插件的注册、查找和状态跟踪。

```dart
class PluginRegistry {
  static PluginRegistry get instance;  // 单例实例
  
  // 插件管理
  Future<void> register(Plugin plugin);     // 注册插件
  Future<void> unregister(String pluginId); // 注销插件
  Plugin? get(String pluginId);             // 获取插件
  bool contains(String pluginId);           // 检查插件是否存在
  
  // 查询方法
  List<Plugin> getByCategory(PluginCategory category);  // 按类别查找
  List<Plugin> getByState(PluginState state);          // 按状态查找
  List<Plugin> getAll();                               // 获取所有插件
  List<Plugin> getAllActive();                         // 获取活跃插件
  
  // 状态管理
  PluginState? getState(String pluginId);                    // 获取状态
  void updateState(String pluginId, PluginState newState);   // 更新状态
  Stream<PluginState>? getStateStream(String pluginId);      // 状态流
  
  // 元数据
  PluginMetadata? getMetadata(String pluginId);  // 获取元数据
  
  // 统计信息
  int get count;                    // 插件数量
  Future<void> clear();             // 清空所有插件
}
```

### PluginLoader 加载器

负责插件的动态加载、卸载和生命周期管理。

```dart
class PluginLoader {
  static PluginLoader get instance;  // 单例实例
  
  // 插件加载
  Future<void> loadPlugin(Plugin plugin, {int timeoutSeconds = 30});
  Future<void> unloadPlugin(String pluginId, {bool force = false});
  Future<void> reloadPlugin(String pluginId, {Plugin? newPlugin});
  
  // 状态控制
  Future<void> pausePlugin(String pluginId);   // 暂停插件
  Future<void> resumePlugin(String pluginId);  // 恢复插件
  
  // 批量操作
  Future<void> unloadAllPlugins({bool force = false});
  
  // 状态查询
  List<String> getLoadingPlugins();      // 获取加载中的插件
  bool isLoading(String pluginId);       // 检查是否正在加载
  Future<void> waitForPlugin(String pluginId);  // 等待插件加载完成
  
  // 状态信息
  Map<String, dynamic> getStatus();      // 获取加载器状态
}
```

### PluginMessenger 消息传递

提供插件间的消息传递和通信功能。

```dart
class PluginMessenger {
  static PluginMessenger get instance;  // 单例实例
  
  // 消息发送
  Future<PluginMessageResponse> sendMessage(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data, {
    int timeoutMs = 5000,
  });
  
  // 通知发送（不等待响应）
  Future<void> sendNotification(
    String senderId,
    String targetId,
    String action,
    Map<String, dynamic> data,
  );
  
  // 广播消息
  Future<void> broadcastMessage(
    String senderId,
    String action,
    Map<String, dynamic> data, {
    List<String> excludeIds = const [],
  });
  
  // 消息处理器管理
  void registerHandler(String pluginId, String action, PluginMessageHandler handler);
  void unregisterHandler(String pluginId, [String? action]);
  
  // 清理
  void cleanupPlugin(String pluginId);
  
  // 状态信息
  Map<String, dynamic> getStatus();
}
```

### EventBus 事件总线

提供事件发布订阅机制。

```dart
class EventBus {
  static EventBus get instance;  // 单例实例

  // 事件发布
  void publish(String type, String source, {Map<String, dynamic>? data});

  // 事件订阅
  EventSubscription subscribe(EventListener listener, {
    String? eventType,
    String? source,
    EventFilter? filter,
  });

  EventSubscription on(String eventType, EventListener listener);      // 订阅特定类型
  EventSubscription from(String source, EventListener listener);       // 订阅特定源

  // 事件流
  Stream<PluginEvent> get stream;                           // 所有事件流
  Stream<PluginEvent> streamOf(String eventType);          // 特定类型事件流
  Stream<PluginEvent> streamFrom(String source);           // 特定源事件流

  // 等待事件
  Future<PluginEvent> waitFor(String eventType, {
    Duration? timeout,
    EventFilter? filter,
  });

  // 管理
  void clearSubscriptions();    // 清空所有订阅
  void clearStats();           // 清空统计
  void cleanupPlugin(String pluginId);  // 清理插件相关订阅

  // 统计信息
  Map<String, int> getEventStats();           // 事件统计
  Map<String, dynamic> getSubscriptionStats(); // 订阅统计
  Map<String, dynamic> getStatus();           // 状态信息
}
```

### HotReloadManager 热重载管理器

提供插件热重载功能，支持开发时的快速迭代。

```dart
class HotReloadManager {
  static HotReloadManager get instance;  // 单例实例

  // 热重载控制
  Future<void> enableHotReload();        // 启用热重载
  Future<void> disableHotReload();       // 禁用热重载
  bool get isEnabled;                    // 是否启用

  // 插件重载
  Future<void> reloadPlugin(String pluginId, {Plugin? newPlugin});
  Future<void> reloadAllPlugins();       // 重载所有插件

  // 监听管理
  Future<void> watchPlugin(String pluginId, String path);  // 监听插件路径
  Future<void> unwatchPlugin(String pluginId);            // 停止监听

  // 状态管理
  HotReloadState get currentState;       // 当前状态
  Stream<HotReloadState> get stateChanges; // 状态变化流

  // 快照管理
  void createSnapshot(String pluginId);  // 创建状态快照
  Future<void> restoreSnapshot(String pluginId); // 恢复快照

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

### DependencyManager 依赖管理器

管理插件间的依赖关系，确保依赖的正确解析和加载顺序。

```dart
class DependencyManager {
  static DependencyManager get instance;  // 单例实例

  // 依赖解析
  Future<List<String>> resolveDependencies(String pluginId);
  Future<List<String>> getLoadOrder(List<String> pluginIds);

  // 依赖检查
  Future<bool> checkDependencies(String pluginId);
  Future<List<String>> getMissingDependencies(String pluginId);
  Future<bool> hasCircularDependency(String pluginId);

  // 依赖图管理
  void addDependency(String pluginId, String dependencyId);
  void removeDependency(String pluginId, String dependencyId);
  Map<String, List<String>> getDependencyGraph();

  // 版本管理
  bool isVersionCompatible(String pluginId, String dependencyId);
  String? getRequiredVersion(String pluginId, String dependencyId);

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

### PermissionManager 权限管理器

管理插件权限的申请、验证和控制。

```dart
class PermissionManager {
  static PermissionManager get instance;  // 单例实例

  // 权限验证
  Future<bool> checkPermission(String pluginId, Permission permission);
  Future<List<Permission>> getMissingPermissions(String pluginId);
  Future<bool> hasAllPermissions(String pluginId);

  // 权限申请
  Future<bool> requestPermission(String pluginId, Permission permission);
  Future<Map<Permission, bool>> requestPermissions(String pluginId, List<Permission> permissions);

  // 权限管理
  void grantPermission(String pluginId, Permission permission);
  void revokePermission(String pluginId, Permission permission);
  void revokeAllPermissions(String pluginId);

  // 权限查询
  List<Permission> getGrantedPermissions(String pluginId);
  List<Permission> getDeniedPermissions(String pluginId);
  Map<String, List<Permission>> getAllPermissions();

  // 权限策略
  void setPermissionPolicy(Permission permission, PermissionPolicy policy);
  PermissionPolicy getPermissionPolicy(Permission permission);

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

### HotReloadManager 热重载管理器

提供插件热重载功能，支持开发时的快速迭代。

```dart
class HotReloadManager {
  static HotReloadManager get instance;  // 单例实例

  // 热重载控制
  Future<void> enableHotReload();        // 启用热重载
  Future<void> disableHotReload();       // 禁用热重载
  bool get isEnabled;                    // 是否启用

  // 插件重载
  Future<void> reloadPlugin(String pluginId, {Plugin? newPlugin});
  Future<void> reloadAllPlugins();       // 重载所有插件

  // 监听管理
  Future<void> watchPlugin(String pluginId, String path);  // 监听插件路径
  Future<void> unwatchPlugin(String pluginId);            // 停止监听

  // 状态管理
  HotReloadState get currentState;       // 当前状态
  Stream<HotReloadState> get stateChanges; // 状态变化流

  // 快照管理
  void createSnapshot(String pluginId);  // 创建状态快照
  Future<void> restoreSnapshot(String pluginId); // 恢复快照

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

### DependencyManager 依赖管理器

管理插件间的依赖关系，确保依赖的正确解析和加载顺序。

```dart
class DependencyManager {
  static DependencyManager get instance;  // 单例实例

  // 依赖解析
  Future<List<String>> resolveDependencies(String pluginId);
  Future<List<String>> getLoadOrder(List<String> pluginIds);

  // 依赖检查
  Future<bool> checkDependencies(String pluginId);
  Future<List<String>> getMissingDependencies(String pluginId);
  Future<bool> hasCircularDependency(String pluginId);

  // 依赖图管理
  void addDependency(String pluginId, String dependencyId);
  void removeDependency(String pluginId, String dependencyId);
  Map<String, List<String>> getDependencyGraph();

  // 版本管理
  bool isVersionCompatible(String pluginId, String dependencyId);
  String? getRequiredVersion(String pluginId, String dependencyId);

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

### PermissionManager 权限管理器

管理插件权限的申请、验证和控制。

```dart
class PermissionManager {
  static PermissionManager get instance;  // 单例实例

  // 权限验证
  Future<bool> checkPermission(String pluginId, Permission permission);
  Future<List<Permission>> getMissingPermissions(String pluginId);
  Future<bool> hasAllPermissions(String pluginId);

  // 权限申请
  Future<bool> requestPermission(String pluginId, Permission permission);
  Future<Map<Permission, bool>> requestPermissions(String pluginId, List<Permission> permissions);

  // 权限管理
  void grantPermission(String pluginId, Permission permission);
  void revokePermission(String pluginId, Permission permission);
  void revokeAllPermissions(String pluginId);

  // 权限查询
  List<Permission> getGrantedPermissions(String pluginId);
  List<Permission> getDeniedPermissions(String pluginId);
  Map<String, List<Permission>> getAllPermissions();

  // 权限策略
  void setPermissionPolicy(Permission permission, PermissionPolicy policy);
  PermissionPolicy getPermissionPolicy(Permission permission);

  // 状态信息
  Map<String, dynamic> getStatus();      // 获取状态信息
}
```

## 数据类型

### 枚举类型

```dart
// 插件类别
enum PluginCategory {
  system,    // 系统级插件
  ui,        // UI组件插件
  tool,      // 工具类插件
  game,      // 游戏插件
  theme,     // 主题插件
  widget,    // 小部件插件
  service,   // 服务类插件
}

// 权限类型
enum Permission {
  fileSystem,      // 文件系统访问
  network,         // 网络访问
  camera,          // 相机访问
  microphone,      // 麦克风访问
  location,        // 位置信息
  notifications,   // 通知权限
  systemSettings,  // 系统设置
  storage,         // 存储访问
  contacts,        // 联系人访问
}

// 插件状态
enum PluginState {
  unloaded,      // 未加载
  loaded,        // 已加载
  initialized,   // 已初始化
  started,       // 已启动
  paused,        // 已暂停
  stopped,       // 已停止
  error,         // 错误状态
}

// 支持的平台
enum SupportedPlatform {
  android,   // Android平台
  ios,       // iOS平台
  windows,   // Windows平台
  macos,     // macOS平台
  linux,     // Linux平台
  web,       // Web平台
}

// 热重载状态
enum HotReloadState {
  idle,        // 空闲状态
  watching,    // 监听中
  reloading,   // 重载中
  error,       // 错误状态
}

// 权限策略
enum PermissionPolicy {
  allow,       // 允许
  deny,        // 拒绝
  prompt,      // 提示用户
  conditional, // 条件允许
}
```

### 数据模型

```dart
// 插件依赖
class PluginDependency {
  const PluginDependency({
    required this.pluginId,
    required this.versionConstraint,
    this.optional = false,
  });
  
  final String pluginId;           // 依赖的插件ID
  final String versionConstraint;  // 版本约束
  final bool optional;             // 是否为可选依赖
}

// 插件元数据
class PluginMetadata {
  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    required this.requiredPermissions,
    required this.dependencies,
    required this.supportedPlatforms,
    // ... 其他可选字段
  });
  
  // 所有Plugin的基本信息
}

// 插件消息
class PluginMessage {
  const PluginMessage({
    required this.id,
    required this.type,
    required this.action,
    required this.senderId,
    required this.targetId,
    required this.data,
    this.timestamp,
    this.timeout,
  });
  
  final String id;                        // 消息ID
  final MessageType type;                 // 消息类型
  final String action;                    // 动作名称
  final String senderId;                  // 发送者ID
  final String? targetId;                 // 目标ID
  final Map<String, dynamic> data;        // 消息数据
  final DateTime? timestamp;              // 时间戳
  final int? timeout;                     // 超时时间
}

// 插件事件
class PluginEvent {
  const PluginEvent({
    required this.type,
    required this.source,
    this.data,
    this.timestamp,
  });
  
  final String type;                      // 事件类型
  final String source;                    // 事件源
  final Map<String, dynamic>? data;       // 事件数据
  final DateTime? timestamp;              // 时间戳
}

// 插件状态快照
class PluginStateSnapshot {
  const PluginStateSnapshot({
    required this.pluginId,
    required this.state,
    required this.config,
    required this.timestamp,
  });

  final String pluginId;                  // 插件ID
  final PluginState state;                // 状态
  final Map<String, dynamic> config;      // 配置
  final DateTime timestamp;               // 时间戳
}

// 依赖解析结果
class DependencyResolution {
  const DependencyResolution({
    required this.pluginId,
    required this.dependencies,
    required this.loadOrder,
    required this.conflicts,
  });

  final String pluginId;                  // 插件ID
  final List<String> dependencies;        // 依赖列表
  final List<String> loadOrder;           // 加载顺序
  final List<String> conflicts;           // 冲突列表
}

// 权限请求结果
class PermissionResult {
  const PermissionResult({
    required this.permission,
    required this.granted,
    this.reason,
  });

  final Permission permission;            // 权限
  final bool granted;                     // 是否授予
  final String? reason;                   // 原因
}
```

## 异常类型

插件系统定义了完整的异常体系：

### 核心异常
- `PluginNotFoundException` - 插件未找到
- `PluginAlreadyExistsException` - 插件已存在
- `PluginStateException` - 状态异常
- `PluginLoadException` - 加载异常
- `PluginTimeoutException` - 超时异常
- `PluginCommunicationException` - 通信异常

### 依赖管理异常
- `PluginDependencyException` - 插件依赖异常
- `CircularDependencyException` - 循环依赖异常
- `PluginVersionIncompatibleException` - 版本不兼容
- `DependencyResolutionException` - 依赖解析异常

### 权限管理异常
- `PluginPermissionException` - 权限异常
- `PermissionDeniedException` - 权限被拒绝
- `PermissionNotRequestedException` - 权限未申请

### 热重载异常
- `HotReloadException` - 热重载异常
- `PluginReloadException` - 插件重载异常
- `StateSnapshotException` - 状态快照异常

## 使用示例

详细的使用示例请参考 [用户文档](../user/user_guide.md) 和 [开发者文档](../developer/developer_guide.md)。
