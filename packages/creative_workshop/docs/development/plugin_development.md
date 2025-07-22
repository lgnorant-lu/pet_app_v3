# Creative Workshop 插件开发指南

## 概述

本指南详细介绍如何为 Creative Workshop 开发自定义插件，包括插件架构、开发流程、最佳实践等内容。

**🔄 Phase 5.0.6**: 企业级插件管理系统，支持完整的插件生命周期管理

## 插件架构

### 1. 插件基础架构

Creative Workshop 采用双核心插件架构：

```
┌─────────────────────────────────────────────────────────────┐
│                    Plugin Architecture                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │ Plugin      │ │ Plugin      │ │ Permission  │ │ Event   │ │
│  │ Manager     │ │ Registry    │ │ System      │ │ System  │ │
│  │ 生命周期管理 │ │ 注册表管理   │ │ 权限控制     │ │ 事件驱动 │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │ Tool        │ │ Game        │ │ Utility     │ │ Theme   │ │
│  │ Plugins     │ │ Plugins     │ │ Plugins     │ │ Plugins │ │
│  │ 工具插件     │ │ 游戏插件     │ │ 实用插件     │ │ 主题插件 │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2. 插件类型

Creative Workshop 支持5种插件类型：

- **工具插件 (Tool)**: 提供特定功能的工具
- **游戏插件 (Game)**: 娱乐和游戏功能
- **实用插件 (Utility)**: 系统实用程序
- **主题插件 (Theme)**: 界面主题和样式
- **其他插件 (Other)**: 自定义功能插件

## 快速开始

### 1. 创建插件项目

```bash
# 使用 Ming CLI 创建插件项目
ming create plugin my_awesome_plugin

# 或手动创建目录结构
mkdir my_awesome_plugin
cd my_awesome_plugin
```

### 2. 基础插件结构

```dart
// lib/my_awesome_plugin.dart
import 'package:creative_workshop/creative_workshop.dart';

class MyAwesomePlugin extends Plugin {
  @override
  String get id => 'my_awesome_plugin';
  
  @override
  String get name => '我的超棒插件';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => '这是一个超棒的示例插件';
  
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'my_awesome_plugin',
    name: '我的超棒插件',
    version: '1.0.0',
    description: '这是一个超棒的示例插件',
    author: '你的名字',
    category: 'tool',
    keywords: ['工具', '示例', '超棒'],
    permissions: [
      PluginPermission.fileSystem,
    ],
  );
  
  bool _isInitialized = false;
  bool _isRunning = false;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isRunning => _isRunning;
  
  @override
  Future<void> initialize() async {
    print('初始化插件: $name');
    // 在这里添加初始化逻辑
    _isInitialized = true;
  }
  
  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('Plugin not initialized');
    }
    
    print('启动插件: $name');
    // 在这里添加启动逻辑
    _isRunning = true;
  }
  
  @override
  Future<void> stop() async {
    print('停止插件: $name');
    // 在这里添加停止逻辑
    _isRunning = false;
  }
  
  @override
  Future<void> dispose() async {
    print('释放插件: $name');
    // 在这里添加清理逻辑
    _isRunning = false;
    _isInitialized = false;
  }
}
```

### 3. 注册插件

```dart
// lib/plugin_registration.dart
import 'package:creative_workshop/creative_workshop.dart';
import 'my_awesome_plugin.dart';

void registerMyAwesomePlugin() {
  final metadata = PluginMetadata(
    id: 'my_awesome_plugin',
    name: '我的超棒插件',
    version: '1.0.0',
    description: '这是一个超棒的示例插件',
    author: '你的名字',
    category: 'tool',
    keywords: ['工具', '示例', '超棒'],
    permissions: [
      PluginPermission.fileSystem,
    ],
  );

  PluginRegistry.instance.registerPlugin(
    metadata,
    () => MyAwesomePlugin(),
  );
}

// 在应用启动时调用
void initializePlugins() {
  registerMyAwesomePlugin();
  // 注册其他插件...
}
```

## 插件元数据

### 1. 基础元数据

```dart
const PluginMetadata(
  id: 'unique_plugin_id',           // 唯一标识符
  name: '插件显示名称',               // 用户看到的名称
  version: '1.0.0',                // 语义化版本号
  description: '插件功能描述',        // 详细描述
  author: '开发者名称',              // 作者信息
  category: 'tool',                // 插件类别
  keywords: ['关键词1', '关键词2'],   // 搜索关键词
  permissions: [                   // 所需权限
    PluginPermission.fileSystem,
    PluginPermission.network,
  ],
);
```

### 2. 高级元数据

```dart
const PluginMetadata(
  id: 'advanced_plugin',
  name: '高级插件',
  version: '2.1.0',
  description: '具有高级功能的插件',
  author: '高级开发者',
  category: 'utility',
  homepage: 'https://example.com/plugin',
  repository: 'https://github.com/user/plugin',
  license: 'MIT',
  keywords: ['高级', '功能', '实用'],
  screenshots: [
    'https://example.com/screenshot1.png',
    'https://example.com/screenshot2.png',
  ],
  minAppVersion: '5.0.0',
  maxAppVersion: '6.0.0',
  permissions: [
    PluginPermission.fileSystem,
    PluginPermission.network,
    PluginPermission.notifications,
  ],
  dependencies: [
    PluginDependency(
      pluginId: 'base_plugin',
      version: '1.0.0',
      isRequired: true,
    ),
    PluginDependency(
      pluginId: 'optional_plugin',
      version: '1.5.0',
      isRequired: false,
    ),
  ],
);
```

## 权限系统

### 1. 权限类型

Creative Workshop 支持8种权限类型：

```dart
enum PluginPermission {
  fileSystem('文件系统访问'),      // 读写文件
  network('网络访问'),           // 网络请求
  notifications('系统通知'),     // 发送通知
  clipboard('剪贴板访问'),       // 剪贴板操作
  camera('相机访问'),           // 相机功能
  microphone('麦克风访问'),     // 麦克风功能
  location('位置信息'),         // 地理位置
  deviceInfo('设备信息');       // 设备信息
}
```

### 2. 权限使用示例

```dart
class FileAccessPlugin extends Plugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'file_access_plugin',
    name: '文件访问插件',
    version: '1.0.0',
    description: '演示文件系统访问权限的插件',
    author: '开发者',
    category: 'utility',
    permissions: [
      PluginPermission.fileSystem,  // 声明文件系统权限
    ],
  );
  
  Future<void> readFile(String path) async {
    // 检查权限
    if (!await _hasPermission(PluginPermission.fileSystem)) {
      throw PermissionDeniedException('文件系统访问权限被拒绝');
    }
    
    // 执行文件操作
    // ...
  }
  
  Future<bool> _hasPermission(PluginPermission permission) async {
    // 权限检查逻辑
    return true; // 简化示例
  }
}
```

## 依赖管理

### 1. 定义依赖

```dart
const PluginMetadata(
  id: 'dependent_plugin',
  name: '依赖插件',
  version: '1.0.0',
  description: '依赖其他插件的示例',
  author: '开发者',
  category: 'tool',
  dependencies: [
    // 必需依赖
    PluginDependency(
      pluginId: 'base_plugin',
      version: '1.0.0',
      isRequired: true,
    ),
    // 可选依赖
    PluginDependency(
      pluginId: 'enhancement_plugin',
      version: '2.0.0',
      isRequired: false,
    ),
  ],
);
```

### 2. 依赖检查

```dart
class DependentPlugin extends Plugin {
  @override
  Future<void> initialize() async {
    // 检查必需依赖
    if (!await _checkDependencies()) {
      throw DependencyException('缺少必需的依赖插件');
    }
    
    await super.initialize();
  }
  
  Future<bool> _checkDependencies() async {
    final dependencies = metadata.dependencies;

    for (final dep in dependencies) {
      if (dep.isRequired) {
        final isInstalled = PluginManager.instance.isPluginInstalled(dep.pluginId);
        if (!isInstalled) {
          return false;
        }
      }
    }

    return true;
  }
}
```

## 插件生命周期

### 1. 生命周期阶段

插件在 Creative Workshop 中经历以下生命周期：

```
注册 → 安装 → 初始化 → 启动 → 运行 → 停止 → 释放 → 卸载
```

### 2. 生命周期方法

```dart
class LifecycleAwarePlugin extends Plugin {
  @override
  Future<void> initialize() async {
    print('插件初始化阶段');
    // 初始化资源、配置、数据库连接等
    await _initializeResources();
    await super.initialize();
  }

  @override
  Future<void> start() async {
    print('插件启动阶段');
    // 启动服务、注册监听器、开始工作等
    await _startServices();
    await super.start();
  }

  @override
  Future<void> stop() async {
    print('插件停止阶段');
    // 停止服务、保存状态、清理临时资源等
    await _stopServices();
    await super.stop();
  }

  @override
  Future<void> dispose() async {
    print('插件释放阶段');
    // 释放所有资源、关闭连接、清理内存等
    await _disposeResources();
    await super.dispose();
  }

  Future<void> _initializeResources() async {
    // 初始化逻辑
  }

  Future<void> _startServices() async {
    // 启动逻辑
  }

  Future<void> _stopServices() async {
    // 停止逻辑
  }

  Future<void> _disposeResources() async {
    // 清理逻辑
  }
}
```

## 事件系统

### 1. 监听插件事件

```dart
class EventAwarePlugin extends Plugin {
  StreamSubscription<PluginRegistryEvent>? _eventSubscription;

  @override
  Future<void> initialize() async {
    // 监听插件注册表事件
    _eventSubscription = PluginRegistry.instance.events.listen(_handleEvent);
    await super.initialize();
  }

  @override
  Future<void> dispose() async {
    // 取消事件监听
    await _eventSubscription?.cancel();
    await super.dispose();
  }

  void _handleEvent(PluginRegistryEvent event) {
    switch (event.runtimeType) {
      case PluginRegisteredEvent:
        print('插件已注册: ${event.pluginId}');
        break;
      case PluginStartedEvent:
        print('插件已启动: ${event.pluginId}');
        break;
      case PluginStoppedEvent:
        print('插件已停止: ${event.pluginId}');
        break;
      case PluginErrorEvent:
        print('插件错误: ${event.pluginId}');
        break;
    }
  }
}
```

### 2. 发送自定义事件

```dart
class CustomEventPlugin extends Plugin {
  final StreamController<CustomEvent> _eventController = StreamController.broadcast();

  Stream<CustomEvent> get events => _eventController.stream;

  void sendCustomEvent(String message) {
    final event = CustomEvent(
      pluginId: id,
      message: message,
      timestamp: DateTime.now(),
    );
    _eventController.add(event);
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
    await super.dispose();
  }
}

class CustomEvent {
  final String pluginId;
  final String message;
  final DateTime timestamp;

  const CustomEvent({
    required this.pluginId,
    required this.message,
    required this.timestamp,
  });
}
```

## UI 集成

### 1. 创建插件界面

```dart
class UIPlugin extends Plugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'ui_plugin',
    name: 'UI 插件',
    version: '1.0.0',
    description: '演示 UI 集成的插件',
    author: '开发者',
    category: 'tool',
  );

  Widget buildUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: [
          Text('这是 $name 的界面'),
          ElevatedButton(
            onPressed: _handleButtonPress,
            child: const Text('执行操作'),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress() {
    print('插件按钮被点击');
  }
}
```

### 2. 集成到应用商店

```dart
class StoreIntegratedPlugin extends Plugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'store_plugin',
    name: '商店插件',
    version: '1.0.0',
    description: '集成到应用商店的插件',
    author: '开发者',
    category: 'utility',
    screenshots: [
      'assets/screenshot1.png',
      'assets/screenshot2.png',
    ],
  );

  Widget buildStoreCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.extension),
        title: Text(name),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () => _installPlugin(context),
          child: const Text('安装'),
        ),
      ),
    );
  }

  void _installPlugin(BuildContext context) {
    PluginManager.instance.installPlugin(id).then((result) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('插件安装成功')),
        );
      }
    });
  }
}
```

## 数据存储

### 1. 插件配置存储

```dart
class ConfigurablePlugin extends Plugin {
  static const String _configKey = 'plugin_config';
  Map<String, dynamic> _config = {};

  @override
  Future<void> initialize() async {
    await _loadConfig();
    await super.initialize();
  }

  @override
  Future<void> dispose() async {
    await _saveConfig();
    await super.dispose();
  }

  Future<void> _loadConfig() async {
    // 从本地存储加载配置
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('${id}_$_configKey');

    if (configJson != null) {
      _config = json.decode(configJson);
    } else {
      _config = _getDefaultConfig();
    }
  }

  Future<void> _saveConfig() async {
    // 保存配置到本地存储
    final prefs = await SharedPreferences.getInstance();
    final configJson = json.encode(_config);
    await prefs.setString('${id}_$_configKey', configJson);
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'enabled': true,
      'theme': 'light',
      'autoUpdate': true,
    };
  }

  T getConfig<T>(String key, T defaultValue) {
    return _config[key] as T? ?? defaultValue;
  }

  void setConfig<T>(String key, T value) {
    _config[key] = value;
  }
}
```

### 2. 插件数据管理

```dart
class DataManagedPlugin extends Plugin {
  late Database _database;

  @override
  Future<void> initialize() async {
    await _initializeDatabase();
    await super.initialize();
  }

  @override
  Future<void> dispose() async {
    await _database.close();
    await super.dispose();
  }

  Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, '${id}_data.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plugin_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL,
            value TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveData(String key, String value) async {
    await _database.insert(
      'plugin_data',
      {
        'key': key,
        'value': value,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadData(String key) async {
    final result = await _database.query(
      'plugin_data',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }

    return null;
  }
}

## 网络通信

### 1. HTTP 请求

```dart
class NetworkPlugin extends Plugin {
  final http.Client _httpClient = http.Client();

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'network_plugin',
    name: '网络插件',
    version: '1.0.0',
    description: '演示网络通信的插件',
    author: '开发者',
    category: 'utility',
    permissions: [
      PluginPermission.network,  // 声明网络权限
    ],
  );

  @override
  Future<void> dispose() async {
    _httpClient.close();
    await super.dispose();
  }

  Future<Map<String, dynamic>> fetchData(String url) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw NetworkException('网络请求失败: $e');
    }
  }

  Future<void> postData(String url, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw NetworkException('网络请求失败: $e');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
```

### 2. WebSocket 通信

```dart
class WebSocketPlugin extends Plugin {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'websocket_plugin',
    name: 'WebSocket 插件',
    version: '1.0.0',
    description: '演示 WebSocket 通信的插件',
    author: '开发者',
    category: 'utility',
    permissions: [
      PluginPermission.network,
    ],
  );

  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
    } catch (e) {
      throw WebSocketException('WebSocket 连接失败: $e');
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    } else {
      throw StateError('WebSocket 未连接');
    }
  }

  void _handleMessage(dynamic message) {
    print('收到消息: $message');
    // 处理接收到的消息
  }

  void _handleError(error) {
    print('WebSocket 错误: $error');
  }

  void _handleDisconnect() {
    print('WebSocket 连接断开');
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await super.dispose();
  }
}

class WebSocketException implements Exception {
  final String message;
  const WebSocketException(this.message);

  @override
  String toString() => 'WebSocketException: $message';
}
```

## 测试开发

### 1. 单元测试

```dart
// test/my_awesome_plugin_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_awesome_plugin/my_awesome_plugin.dart';

void main() {
  group('MyAwesomePlugin Tests', () {
    late MyAwesomePlugin plugin;

    setUp(() {
      plugin = MyAwesomePlugin();
    });

    test('should have correct metadata', () {
      expect(plugin.id, 'my_awesome_plugin');
      expect(plugin.name, '我的超棒插件');
      expect(plugin.version, '1.0.0');
    });

    test('should initialize successfully', () async {
      expect(plugin.isInitialized, isFalse);
      await plugin.initialize();
      expect(plugin.isInitialized, isTrue);
    });

    test('should start and stop correctly', () async {
      await plugin.initialize();

      expect(plugin.isRunning, isFalse);
      await plugin.start();
      expect(plugin.isRunning, isTrue);

      await plugin.stop();
      expect(plugin.isRunning, isFalse);
    });

    test('should dispose correctly', () async {
      await plugin.initialize();
      await plugin.start();
      await plugin.dispose();

      expect(plugin.isInitialized, isFalse);
      expect(plugin.isRunning, isFalse);
    });

    test('should throw error when starting uninitialized plugin', () async {
      expect(() => plugin.start(), throwsStateError);
    });
  });
}
```

### 2. 集成测试

```dart
// integration_test/plugin_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:creative_workshop/creative_workshop.dart';
import 'package:my_awesome_plugin/my_awesome_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Plugin Integration Tests', () {
    testWidgets('should register and install plugin', (tester) async {
      // 注册插件
      final metadata = PluginMetadata(
        id: 'my_awesome_plugin',
        name: '我的超棒插件',
        version: '1.0.0',
        description: '这是一个超棒的示例插件',
        author: '你的名字',
        category: 'tool',
      );

      PluginRegistry.instance.registerPlugin(
        metadata,
        () => MyAwesomePlugin(),
      );

      // 验证插件已注册
      expect(PluginRegistry.instance.isPluginRegistered('my_awesome_plugin'), isTrue);

      // 安装插件
      final result = await PluginManager.instance.installPlugin('my_awesome_plugin');
      expect(result.success, isTrue);

      // 验证插件已安装
      expect(PluginManager.instance.isPluginInstalled('my_awesome_plugin'), isTrue);
    });

    testWidgets('should display plugin in store', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreativeWorkspace(
            initialLayout: WorkspaceLayout.store,
          ),
        ),
      );

      // 查找插件卡片
      expect(find.text('我的超棒插件'), findsOneWidget);
      expect(find.text('这是一个超棒的示例插件'), findsOneWidget);
    });
  });
}
```

## 最佳实践

### 1. 性能优化

```dart
class OptimizedPlugin extends Plugin {
  // 使用懒加载
  late final Map<String, dynamic> _cache = {};

  // 使用对象池
  final List<ExpensiveObject> _objectPool = [];

  @override
  Future<void> initialize() async {
    // 异步初始化，避免阻塞主线程
    await Future.microtask(() async {
      await _initializeAsync();
    });

    await super.initialize();
  }

  Future<void> _initializeAsync() async {
    // 预加载关键资源
    await _preloadCriticalResources();

    // 初始化对象池
    _initializeObjectPool();
  }

  Future<void> _preloadCriticalResources() async {
    // 预加载逻辑
  }

  void _initializeObjectPool() {
    // 对象池初始化
    for (int i = 0; i < 10; i++) {
      _objectPool.add(ExpensiveObject());
    }
  }

  ExpensiveObject borrowObject() {
    if (_objectPool.isNotEmpty) {
      return _objectPool.removeLast();
    }
    return ExpensiveObject();
  }

  void returnObject(ExpensiveObject obj) {
    obj.reset();
    _objectPool.add(obj);
  }

  // 使用缓存
  Future<T> getCachedData<T>(String key, Future<T> Function() loader) async {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }

    final data = await loader();
    _cache[key] = data;
    return data;
  }
}

class ExpensiveObject {
  void reset() {
    // 重置对象状态
  }
}
```

### 2. 错误处理

```dart
class RobustPlugin extends Plugin {
  @override
  Future<void> initialize() async {
    try {
      await _safeInitialize();
    } catch (e, stackTrace) {
      _handleError('初始化失败', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _safeInitialize() async {
    // 带超时的初始化
    await Future.timeout(
      _doInitialize(),
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('插件初始化超时', const Duration(seconds: 30));
      },
    );
  }

  Future<void> _doInitialize() async {
    // 实际初始化逻辑
  }

  void _handleError(String operation, dynamic error, StackTrace stackTrace) {
    // 记录错误
    print('插件错误 [$operation]: $error');
    print('堆栈跟踪: $stackTrace');

    // 发送错误事件
    _sendErrorEvent(operation, error);

    // 可选：发送错误报告到服务器
    _reportError(operation, error, stackTrace);
  }

  void _sendErrorEvent(String operation, dynamic error) {
    // 发送错误事件给插件注册表
  }

  void _reportError(String operation, dynamic error, StackTrace stackTrace) {
    // 发送错误报告到远程服务器
  }
}
```

### 3. 资源管理

```dart
class ResourceManagedPlugin extends Plugin {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<Completer> _completers = [];

  @override
  Future<void> dispose() async {
    // 清理所有订阅
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // 清理所有定时器
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // 完成所有未完成的 Completer
    for (final completer in _completers) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _completers.clear();

    await super.dispose();
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  void addCompleter(Completer completer) {
    _completers.add(completer);
  }
}
```

## 发布和分发

### 1. 插件打包

```yaml
# pubspec.yaml
name: my_awesome_plugin
description: 我的超棒插件
version: 1.0.0
homepage: https://example.com/my_awesome_plugin
repository: https://github.com/user/my_awesome_plugin

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  creative_workshop:
    path: ../creative_workshop

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.example.my_awesome_plugin
        pluginClass: MyAwesomePlugin
      ios:
        pluginClass: MyAwesomePlugin
```

### 2. 插件清单

```yaml
# plugin_manifest.yaml
plugin:
  id: my_awesome_plugin
  name: 我的超棒插件
  version: 1.0.0
  description: 这是一个超棒的示例插件
  author: 你的名字
  category: tool
  keywords:
    - 工具
    - 示例
    - 超棒
  permissions:
    - file_system
  dependencies:
    - plugin_id: base_plugin
      version: ">=1.0.0 <2.0.0"
      required: true
  screenshots:
    - assets/screenshot1.png
    - assets/screenshot2.png
  changelog: CHANGELOG.md
  readme: README.md
```

### 3. 发布流程

```bash
# 1. 验证插件
ming plugin validate

# 2. 运行测试
flutter test

# 3. 构建插件
ming plugin build

# 4. 发布到插件商店
ming plugin publish

# 5. 或者发布到 pub.dev
flutter pub publish
```

## 调试和故障排除

### 1. 调试技巧

```dart
class DebuggablePlugin extends Plugin {
  static const bool _debugMode = kDebugMode;

  void debugLog(String message) {
    if (_debugMode) {
      print('[${DateTime.now()}] [$id] $message');
    }
  }

  @override
  Future<void> initialize() async {
    debugLog('开始初始化插件');

    try {
      await super.initialize();
      debugLog('插件初始化成功');
    } catch (e, stackTrace) {
      debugLog('插件初始化失败: $e');
      debugLog('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  void debugState() {
    debugLog('插件状态:');
    debugLog('  - ID: $id');
    debugLog('  - 名称: $name');
    debugLog('  - 版本: $version');
    debugLog('  - 已初始化: $isInitialized');
    debugLog('  - 正在运行: $isRunning');
  }
}
```

### 2. 常见问题

**Q: 插件无法启动**
```dart
// 检查依赖
Future<void> diagnoseStartupIssue() async {
  // 1. 检查插件是否已注册
  if (!PluginRegistry.instance.isPluginRegistered(id)) {
    print('错误: 插件未注册');
    return;
  }

  // 2. 检查依赖是否满足
  final dependencies = metadata.dependencies;
  for (final dep in dependencies) {
    if (dep.isRequired && !PluginManager.instance.isPluginInstalled(dep.pluginId)) {
      print('错误: 缺少必需依赖 ${dep.pluginId}');
      return;
    }
  }

  // 3. 检查权限
  for (final permission in metadata.permissions) {
    if (!await _hasPermission(permission)) {
      print('错误: 缺少权限 ${permission.displayName}');
      return;
    }
  }

  print('诊断完成: 未发现明显问题');
}
```

**Q: 内存泄漏**
```dart
class MemoryLeakDetector {
  static final Map<String, int> _objectCounts = {};

  static void trackObject(String type) {
    _objectCounts[type] = (_objectCounts[type] ?? 0) + 1;
  }

  static void untrackObject(String type) {
    _objectCounts[type] = (_objectCounts[type] ?? 1) - 1;
    if (_objectCounts[type]! <= 0) {
      _objectCounts.remove(type);
    }
  }

  static void printReport() {
    print('内存使用报告:');
    _objectCounts.forEach((type, count) {
      print('  $type: $count 个对象');
    });
  }
}

class TrackedPlugin extends Plugin {
  TrackedPlugin() {
    MemoryLeakDetector.trackObject('TrackedPlugin');
  }

  @override
  Future<void> dispose() async {
    MemoryLeakDetector.untrackObject('TrackedPlugin');
    await super.dispose();
  }
}
```

## 示例插件

### 1. 文件管理插件

```dart
class FileManagerPlugin extends Plugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'file_manager',
    name: '文件管理器',
    version: '1.0.0',
    description: '简单的文件管理插件',
    author: '开发者',
    category: 'utility',
    permissions: [
      PluginPermission.fileSystem,
    ],
  );

  Future<List<FileSystemEntity>> listFiles(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw FileSystemException('目录不存在', path);
    }

    return directory.listSync();
  }

  Future<String> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', path);
    }

    return file.readAsString();
  }

  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

### 2. 通知插件

```dart
class NotificationPlugin extends Plugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'notification_plugin',
    name: '通知插件',
    version: '1.0.0',
    description: '系统通知插件',
    author: '开发者',
    category: 'utility',
    permissions: [
      PluginPermission.notifications,
    ],
  );

  Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
  }) async {
    // 检查权限
    if (!await _hasNotificationPermission()) {
      throw PermissionDeniedException('通知权限被拒绝');
    }

    // 显示通知
    await _displayNotification(title, body, icon);
  }

  Future<bool> _hasNotificationPermission() async {
    // 权限检查逻辑
    return true; // 简化示例
  }

  Future<void> _displayNotification(String title, String body, String? icon) async {
    // 平台特定的通知显示逻辑
    print('通知: $title - $body');
  }
}
```

## 总结

Creative Workshop 的插件系统提供了强大而灵活的扩展机制。通过遵循本指南中的最佳实践，您可以创建高质量、高性能的插件，为用户提供丰富的功能体验。

### 关键要点

1. **遵循生命周期**: 正确实现插件生命周期方法
2. **权限管理**: 合理声明和使用权限
3. **依赖管理**: 正确处理插件依赖关系
4. **错误处理**: 实现健壮的错误处理机制
5. **资源管理**: 及时清理资源避免内存泄漏
6. **性能优化**: 使用懒加载、缓存等优化技术
7. **测试覆盖**: 编写全面的单元测试和集成测试

### 下一步

- 查看 [API 文档](../api/api.md) 了解详细的 API 接口
- 参考 [架构文档](../architecture/architecture.md) 理解系统设计
- 阅读 [用户指南](../guides/user_guide.md) 了解用户体验
- 查看示例插件代码获取更多灵感

---

**文档版本**: 5.0.6
**最后更新**: 2025-07-22
**适用版本**: Creative Workshop 5.0.6+
**维护者**: Creative Workshop 插件开发团队
