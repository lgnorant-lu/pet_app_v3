# Creative Workshop API 文档

## 概述

Creative Workshop 是一个功能强大的 Flutter 应用商店与开发者平台模块，提供插件发现、安装、管理等完整的应用生态功能。该模块采用企业级架构，支持插件生命周期管理、权限控制、依赖解析等高级功能。

**🔄 Phase 5.0.6 重大更新**: 从绘画工具转型为应用商店+开发者平台+插件管理三位一体系统

## 核心架构

### 双核心架构

Creative Workshop 采用双核心架构设计：

- **PluginManager**: 插件生命周期管理
- **PluginRegistry**: 插件注册表和元数据管理

## 插件管理系统

### PluginManager

插件管理器，负责插件的完整生命周期管理。

```dart
class PluginManager extends ChangeNotifier {
  static PluginManager get instance;

  // 插件列表
  List<PluginInstallInfo> get installedPlugins;
  List<PluginInstallInfo> get enabledPlugins;
  List<PluginInstallInfo> get updatablePlugins;

  // 生命周期管理
  Future<PluginOperationResult> installPlugin(String pluginId, {String? version, bool autoUpdate = true});
  Future<PluginOperationResult> uninstallPlugin(String pluginId);
  Future<PluginOperationResult> enablePlugin(String pluginId);
  Future<PluginOperationResult> disablePlugin(String pluginId);
  Future<PluginOperationResult> updatePlugin(String pluginId);

  // 查询方法
  PluginInstallInfo? getPluginInfo(String pluginId);
  bool isPluginInstalled(String pluginId);
  bool isPluginEnabled(String pluginId);
  Map<String, dynamic> getPluginStats();

  // 进度跟踪
  Stream<double>? getInstallProgress(String pluginId);
}
```

### PluginRegistry

插件注册表，负责插件的注册、启动、停止等操作。

```dart
class PluginRegistry extends ChangeNotifier {
  static PluginRegistry get instance;

  // 插件注册
  void registerPlugin(PluginMetadata metadata, Plugin Function() pluginFactory);
  Future<void> unregisterPlugin(String pluginId);

  // 插件生命周期
  Future<void> startPlugin(String pluginId);
  Future<void> stopPlugin(String pluginId);
  Future<void> restartPlugin(String pluginId);

  // 查询方法
  List<PluginRegistration> get registrations;
  List<Plugin> get activePlugins;
  PluginMetadata? getPluginMetadata(String pluginId);
  Plugin? getActivePlugin(String pluginId);
  bool isPluginRegistered(String pluginId);
  bool isPluginRunning(String pluginId);

  // 搜索和分类
  List<PluginRegistration> getPluginsByCategory(String category);
  List<PluginRegistration> searchPlugins(String query);

  // 统计信息
  Map<String, dynamic> getStatistics();

  // 批量操作
  Future<void> startAllPlugins();
  Future<void> stopAllPlugins();

  // 事件流
  Stream<PluginRegistryEvent> get events;
}
```

## 数据模型

### PluginInstallInfo

插件安装信息，包含插件的完整状态和元数据。

```dart
class PluginInstallInfo {
  final String id;
  final String name;
  final String version;
  final PluginState state;
  final DateTime installedAt;
  final DateTime? lastUsedAt;
  final List<PluginPermission> permissions;
  final List<PluginDependency> dependencies;
  final int size; // 字节
  final bool autoUpdate;

  const PluginInstallInfo({
    required this.id,
    required this.name,
    required this.version,
    required this.state,
    required this.installedAt,
    this.lastUsedAt,
    this.permissions = const [],
    this.dependencies = const [],
    this.size = 0,
    this.autoUpdate = true,
  });

  PluginInstallInfo copyWith({...});
}
```

### PluginMetadata

插件元数据，包含插件的基本信息。

```dart
class PluginMetadata {
  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final String category;
  final String? homepage;
  final String? repository;
  final String license;
  final List<String> keywords;
  final List<String> screenshots;
  final String? minAppVersion;
  final String? maxAppVersion;

  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    this.homepage,
    this.repository,
    this.license = 'MIT',
    this.keywords = const [],
    this.screenshots = const [],
    this.minAppVersion,
    this.maxAppVersion,
  });

  factory PluginMetadata.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### PluginDependency

插件依赖关系定义。

```dart
class PluginDependency {
  final String pluginId;
  final String version;
  final bool isRequired;

  const PluginDependency({
    required this.pluginId,
    required this.version,
    required this.isRequired,
  });
}
```

### PluginOperationResult

插件操作结果封装。

```dart
class PluginOperationResult {
  final bool success;
  final String? message;
  final String? error;

  const PluginOperationResult({
    required this.success,
    this.message,
    this.error,
  });

  factory PluginOperationResult.success([String? message]);
  factory PluginOperationResult.failure(String error);
}
```

## 枚举类型

### PluginState

插件状态枚举，定义了插件的12种状态。

```dart
enum PluginState {
  notInstalled,    // 未安装
  downloading,     // 正在下载
  installing,      // 正在安装
  installed,       // 已安装
  enabling,        // 正在启用
  enabled,         // 已启用
  disabling,       // 正在禁用
  disabled,        // 已禁用
  uninstalling,    // 正在卸载
  installFailed,   // 安装失败
  updateAvailable, // 需要更新
  updating,        // 正在更新
}
```

### PluginPermission

插件权限枚举，定义了8种权限类型。

```dart
enum PluginPermission {
  fileSystem('文件系统访问'),
  network('网络访问'),
  notifications('系统通知'),
  clipboard('剪贴板访问'),
  camera('相机访问'),
  microphone('麦克风访问'),
  location('位置信息'),
  deviceInfo('设备信息');

  const PluginPermission(this.displayName);
  final String displayName;
}
```

### WorkspaceLayout

工作区布局枚举。

```dart
enum WorkspaceLayout {
  store,       // 应用商店模式
  developer,   // 开发者平台模式
  management,  // 插件管理模式
}
```

## 插件接口

### Plugin

插件基类，定义了插件的基本接口。

```dart
abstract class Plugin {
  String get id;
  String get name;
  String get version;
  String get description;
  PluginMetadata get metadata;

  Future<void> initialize();
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();

  bool get isInitialized;
  bool get isRunning;
}
```

### PluginRegistration

插件注册信息，包含插件元数据和工厂函数。

```dart
class PluginRegistration {
  final PluginMetadata metadata;
  final Plugin Function() pluginFactory;
  final DateTime registeredAt;

  const PluginRegistration({
    required this.metadata,
    required this.pluginFactory,
    required this.registeredAt,
  });
}
```

## UI 组件

### CreativeWorkspace

主工作区组件，提供应用商店、开发者平台、插件管理三种模式。

```dart
class CreativeWorkspace extends StatefulWidget {
  final WorkspaceLayout initialLayout;
  final Function(WorkspaceLayout)? onLayoutChanged;

  const CreativeWorkspace({
    Key? key,
    this.initialLayout = WorkspaceLayout.store,
    this.onLayoutChanged,
  }) : super(key: key);
}
```

### AppStorePage

应用商店主界面，提供插件浏览和搜索功能。

```dart
class AppStorePage extends StatefulWidget {
  const AppStorePage({Key? key}) : super(key: key);
}
```

### DeveloperPlatformPage

开发者平台主界面，提供项目管理、插件开发等功能。

```dart
class DeveloperPlatformPage extends StatefulWidget {
  const DeveloperPlatformPage({Key? key}) : super(key: key);
}
```

### PluginManagementPage

插件管理主界面，提供插件生命周期管理功能。

```dart
class PluginManagementPage extends StatefulWidget {
  final int initialTabIndex;

  const PluginManagementPage({
    Key? key,
    this.initialTabIndex = 0,
  }) : super(key: key);
}
```

### PluginCard

插件卡片组件，用于展示插件信息。

```dart
class PluginCard extends StatelessWidget {
  final Plugin plugin;
  final VoidCallback? onTap;
  final VoidCallback? onInstall;
  final VoidCallback? onUninstall;

  const PluginCard({
    Key? key,
    required this.plugin,
    this.onTap,
    this.onInstall,
    this.onUninstall,
  }) : super(key: key);
}
```

### PluginSearchBar

插件搜索栏组件，提供实时搜索功能。

```dart
class PluginSearchBar extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final String? hintText;

  const PluginSearchBar({
    Key? key,
    this.onSearchChanged,
    this.hintText = '搜索插件...',
  }) : super(key: key);
}
```

### CategoryFilter

分类过滤组件，提供插件分类筛选功能。

```dart
class CategoryFilter extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?)? onCategoryChanged;

  const CategoryFilter({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.onCategoryChanged,
  }) : super(key: key);
}
```

## 事件系统

### PluginRegistryEvent

插件注册表事件，包含插件生命周期变化信息。

```dart
abstract class PluginRegistryEvent {
  final String pluginId;
  final DateTime timestamp;

  const PluginRegistryEvent(this.pluginId, this.timestamp);

  factory PluginRegistryEvent.registered(String pluginId);
  factory PluginRegistryEvent.unregistered(String pluginId);
  factory PluginRegistryEvent.started(String pluginId);
  factory PluginRegistryEvent.stopped(String pluginId);
  factory PluginRegistryEvent.error(String pluginId, String error);
}
```

## 常量和枚举

### ProjectType

## 常量和配置

### 插件类别常量

```dart
class PluginCategories {
  static const String tools = 'tools';
  static const String games = 'games';
  static const String utilities = 'utilities';
  static const String themes = 'themes';
  static const String other = 'other';

  static const List<String> all = [
    tools,
    games,
    utilities,
    themes,
    other,
  ];
}
```

### 权限常量

```dart
class PluginPermissions {
  static const String fileSystem = 'file_system';
  static const String network = 'network';
  static const String notifications = 'notifications';
  static const String clipboard = 'clipboard';
  static const String camera = 'camera';
  static const String microphone = 'microphone';
  static const String location = 'location';
  static const String deviceInfo = 'device_info';
}
```

## 使用示例

### 基本使用

```dart
import 'package:creative_workshop/creative_workshop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化插件管理器
  await PluginManager.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creative Workshop Demo',
      home: CreativeWorkspace(
        initialLayout: WorkspaceLayout.store,
        onLayoutChanged: (layout) {
          print('布局切换到: $layout');
        },
      ),
    );
  }
}
```

### 插件管理

```dart
// 获取插件管理器实例
final pluginManager = PluginManager.instance;

// 安装插件
final result = await pluginManager.installPlugin('my_plugin_id');
if (result.success) {
  print('插件安装成功: ${result.message}');
} else {
  print('插件安装失败: ${result.error}');
}

// 启用插件
await pluginManager.enablePlugin('my_plugin_id');

// 获取已安装插件列表
final installedPlugins = pluginManager.installedPlugins;
print('已安装 ${installedPlugins.length} 个插件');

// 获取插件统计信息
final stats = pluginManager.getPluginStats();
print('总计: ${stats['totalInstalled']} 已安装, ${stats['totalEnabled']} 已启用');
```

### 插件注册表

```dart
import 'package:creative_workshop/src/core/plugins/plugin_registry.dart';

// 创建插件元数据
const metadata = PluginMetadata(
  id: 'my_plugin',
  name: '我的插件',
  version: '1.0.0',
  description: '这是一个示例插件',
  author: '开发者',
  category: 'tool',
  keywords: ['工具', '示例'],
);

// 注册插件
PluginRegistry.instance.registerPlugin(
  metadata,
  () => MyPlugin(),
);

// 启动插件
await PluginRegistry.instance.startPlugin('my_plugin');

// 获取插件统计
final stats = PluginRegistry.instance.getStatistics();
print('注册插件: ${stats['totalRegistered']}, 活跃插件: ${stats['totalActive']}');
```

### 创建自定义插件

```dart
// 创建自定义插件
class MyPlugin extends Plugin {
  @override
  String get id => 'my_plugin';

  @override
  String get name => '我的插件';

  @override
  String get version => '1.0.0';

  @override
  String get description => '这是一个示例插件';

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'my_plugin',
    name: '我的插件',
    version: '1.0.0',
    description: '这是一个示例插件',
    author: '开发者',
    category: 'tool',
  );

  bool _isInitialized = false;
  bool _isRunning = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('Plugin not initialized');
    }
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
  }

  @override
  Future<void> dispose() async {
    _isRunning = false;
    _isInitialized = false;
  }
}

## 版本信息

- **当前版本**: 5.0.6
- **API 版本**: 5.0
- **最低 Flutter 版本**: 3.16.0
- **最低 Dart 版本**: 3.2.0

## 更多信息

- [架构文档](../architecture/architecture.md)
- [用户指南](../user/user.md)
- [开发指南](../development/development.md)
- [更新日志](../../CHANGELOG.md)
