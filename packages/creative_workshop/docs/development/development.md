# Creative Workshop 开发指南

## 概述

本文档为 Creative Workshop 模块的开发者提供详细的开发指南，包括环境搭建、代码规范、插件开发、测试和部署等内容。

**🔄 Phase 5.0.6 重大更新**: 从绘画工具转型为应用商店+开发者平台+插件管理三位一体系统

## 开发环境搭建

### 1. 系统要求

- **Flutter SDK**: 3.16.0 或更高版本
- **Dart SDK**: 3.2.0 或更高版本
- **IDE**: VS Code 或 Android Studio
- **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)
- **Git**: 版本控制系统
- **Ming CLI**: 可选，用于项目管理和构建

### 2. 项目结构

```
creative_workshop/
├── lib/
│   ├── creative_workshop.dart          # 主导出文件
│   └── src/
│       ├── core/                       # 核心功能
│       │   ├── plugins/                # 插件系统
│       │   │   ├── plugin_manager.dart # 插件管理器
│       │   │   └── plugin_registry.dart # 插件注册表
│       │   ├── providers/              # 状态管理
│       │   ├── router/                 # 路由管理
│       │   └── theme/                  # 主题管理
│       └── ui/                         # 用户界面
│           ├── store/                  # 应用商店
│           ├── developer/              # 开发者平台
│           ├── management/             # 插件管理
│           └── workspace/              # 工作区
├── test/                               # 测试文件
│   └── src/
│       └── core/
│           └── plugins/                # 插件系统测试
├── docs/                               # 文档
│   ├── api/                           # API 文档
│   ├── architecture/                  # 架构文档
│   ├── guides/                        # 用户指南
│   └── development/                   # 开发指南
├── pubspec.yaml                        # 依赖配置
├── CHANGELOG.md                        # 更新日志
└── README.md                           # 项目说明
```

### 3. 依赖管理

主要依赖包括：

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  provider: ^6.1.2

  # 路由管理
  go_router: ^14.6.1

  # 工具库
  uuid: ^4.5.1

dev_dependencies:
  # Flutter 测试
  flutter_test:
    sdk: flutter

  # 测试工具
  test: ^1.25.8
  mockito: ^5.4.4

  # 代码质量
  very_good_analysis: ^6.0.0

  # 构建工具
  build_runner: ^2.4.13
```

## 代码规范

### 1. 命名规范

**类名**: 使用 PascalCase
```dart
class PluginManager { }
class PluginRegistry { }
class PluginInstallInfo { }
```

**方法和变量**: 使用 camelCase
```dart
Future<void> installPlugin(String pluginId) { }
List<PluginInstallInfo> installedPlugins = [];
```

**常量**: 使用 SCREAMING_SNAKE_CASE
```dart
static const String DEFAULT_PLUGIN_CATEGORY = 'other';
static const int MAX_PLUGIN_SIZE = 50 * 1024 * 1024; // 50MB
```

**文件名**: 使用 snake_case
```dart
plugin_manager.dart
plugin_registry.dart
plugin_install_info.dart
```

### 2. 代码组织

**导入顺序**:
1. Dart 核心库
2. Flutter 库
3. 第三方包
4. 项目内部文件

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/plugins/plugin_manager.dart';
import '../utils/plugin_utils.dart';
```

**类结构顺序**:
1. 静态常量
2. 静态方法
3. 实例变量
4. 构造函数
5. Getter/Setter
6. 公共方法
7. 私有方法

### 3. 文档注释

使用 Dart 文档注释格式：

```dart
/// 插件管理器，负责插件的完整生命周期管理
///
/// 提供插件的安装、卸载、启用、禁用、更新等功能。
/// 支持依赖检查、权限验证、进度跟踪等高级特性。
///
/// 示例用法：
/// ```dart
/// final manager = PluginManager.instance;
/// await manager.initialize();
/// final result = await manager.installPlugin('my_plugin');
/// ```
class PluginManager extends ChangeNotifier {
  /// 安装插件
  ///
  /// [pluginId] 插件唯一标识符
  /// [version] 插件版本，可选，默认安装最新版本
  /// [autoUpdate] 是否启用自动更新，默认为 true
  ///
  /// 返回 [PluginOperationResult] 包含操作结果和详细信息
  Future<PluginOperationResult> installPlugin(
    String pluginId, {
    String? version,
    bool autoUpdate = true,
  }) async {
    // 实现代码
  }
}
```

## 插件开发

### 1. 创建自定义插件

#### 1.1 插件基类

```dart
abstract class Plugin {
  /// 插件唯一标识符
  String get id;

  /// 插件显示名称
  String get name;

  /// 插件版本
  String get version;

  /// 插件描述
  String get description;

  /// 插件元数据
  PluginMetadata get metadata;

  /// 插件是否已初始化
  bool get isInitialized;

  /// 插件是否正在运行
  bool get isRunning;

  /// 初始化插件
  Future<void> initialize();

  /// 启动插件
  Future<void> start();

  /// 停止插件
  Future<void> stop();

  /// 释放插件资源
  Future<void> dispose();
}
```

#### 1.2 实现自定义插件

```dart
class MyCustomPlugin extends Plugin {
  bool _isInitialized = false;
  bool _isRunning = false;

  @override
  String get id => 'my_custom_plugin';

  @override
  String get name => '我的自定义插件';

  @override
  String get version => '1.0.0';

  @override
  String get description => '这是一个示例自定义插件';

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'my_custom_plugin',
    name: '我的自定义插件',
    version: '1.0.0',
    description: '这是一个示例自定义插件',
    author: '开发者姓名',
    category: 'tool',
    keywords: ['工具', '示例'],
    permissions: [
      PluginPermission.fileSystem,
      PluginPermission.network,
    ],
  );

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> initialize() async {
    // 初始化插件资源
    print('初始化插件: $name');
    _isInitialized = true;
  }

  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('Plugin not initialized');
    }

    // 启动插件逻辑
    print('启动插件: $name');
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    // 停止插件逻辑
    print('停止插件: $name');
    _isRunning = false;
  }

  @override
  Future<void> dispose() async {
    // 清理插件资源
    print('释放插件: $name');
    _isRunning = false;
    _isInitialized = false;
  }
}
#### 1.3 注册插件

```dart
// 注册插件到插件注册表
void registerCustomPlugin() {
  final metadata = PluginMetadata(
    id: 'my_custom_plugin',
    name: '我的自定义插件',
    version: '1.0.0',
    description: '这是一个示例自定义插件',
    author: '开发者姓名',
    category: 'tool',
    keywords: ['工具', '示例'],
    permissions: [
      PluginPermission.fileSystem,
      PluginPermission.network,
    ],
  );

  PluginRegistry.instance.registerPlugin(
    metadata,
    () => MyCustomPlugin(),
  );
}

// 在应用启动时调用
void initializePlugins() {
  registerCustomPlugin();
  // 注册其他插件...
}
```

### 2. 插件权限管理

#### 2.1 权限类型

Creative Workshop 支持8种权限类型：

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

#### 2.2 权限验证

```dart
class PermissionValidator {
  /// 验证插件权限
  static bool validatePermission(
    String pluginId,
    PluginPermission permission,
  ) {
    // 检查插件是否有该权限
    final plugin = PluginManager.instance.getPluginInfo(pluginId);
    if (plugin == null) return false;

    return plugin.permissions.contains(permission);
  }

  /// 请求权限
  static Future<bool> requestPermission(
    String pluginId,
    PluginPermission permission,
  ) async {
    // 显示权限请求对话框
    // 用户确认后授予权限
    return true; // 示例返回值
  }
}
```

### 3. 插件依赖管理

#### 3.1 定义依赖

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

// 在插件元数据中定义依赖
const metadata = PluginMetadata(
  id: 'advanced_plugin',
  name: '高级插件',
  version: '2.0.0',
  description: '依赖其他插件的高级功能插件',
  author: '开发者',
  category: 'tool',
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

#### 3.2 依赖解析

```dart
class DependencyResolver {
  /// 解析插件依赖
  static Future<List<String>> resolveDependencies(
    String pluginId,
  ) async {
    final plugin = PluginManager.instance.getPluginInfo(pluginId);
    if (plugin == null) return [];

    final dependencies = <String>[];

    for (final dep in plugin.dependencies) {
      if (dep.isRequired) {
        // 检查必需依赖是否已安装
        if (!PluginManager.instance.isPluginInstalled(dep.pluginId)) {
          dependencies.add(dep.pluginId);
        }
      }
    }

    return dependencies;
  }

  /// 检查依赖冲突
  static List<String> checkConflicts(String pluginId) {
    // 检查版本冲突、循环依赖等
    return [];
  }
}
### 4. UI 组件开发

#### 4.1 自定义插件卡片

```dart
class CustomPluginCard extends StatelessWidget {
  final PluginInstallInfo plugin;
  final VoidCallback? onInstall;
  final VoidCallback? onUninstall;
  final VoidCallback? onTap;

  const CustomPluginCard({
    Key? key,
    required this.plugin,
    this.onInstall,
    this.onUninstall,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getPluginIcon(),
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plugin.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'v${plugin.version}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plugin.description ?? '暂无描述',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildStatusChip(),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPluginIcon() {
    switch (plugin.category) {
      case 'tool':
        return Icons.build;
      case 'game':
        return Icons.games;
      case 'utility':
        return Icons.apps;
      case 'theme':
        return Icons.palette;
      default:
        return Icons.extension;
    }
  }

  Widget _buildActionButton() {
    switch (plugin.state) {
      case PluginState.notInstalled:
        return ElevatedButton(
          onPressed: onInstall,
          child: const Text('安装'),
        );
      case PluginState.installed:
      case PluginState.enabled:
        return ElevatedButton(
          onPressed: onUninstall,
          child: const Text('卸载'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (plugin.state) {
      case PluginState.enabled:
        chipColor = Colors.green;
        statusText = '已启用';
        break;
      case PluginState.disabled:
        chipColor = Colors.orange;
        statusText = '已禁用';
        break;
      case PluginState.updateAvailable:
        chipColor = Colors.blue;
        statusText = '可更新';
        break;
      default:
        chipColor = Colors.grey;
        statusText = plugin.state.name;
    }

    return Chip(
      label: Text(statusText),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(color: chipColor),
    );
  }
}
```

#### 4.2 权限管理组件

```dart
class PermissionManagementWidget extends StatefulWidget {
  final String pluginId;
  final List<PluginPermission> permissions;
  final Function(PluginPermission, bool)? onPermissionChanged;

  const PermissionManagementWidget({
    Key? key,
    required this.pluginId,
    required this.permissions,
    this.onPermissionChanged,
  }) : super(key: key);

  @override
  State<PermissionManagementWidget> createState() =>
      _PermissionManagementWidgetState();
}

class _PermissionManagementWidgetState
    extends State<PermissionManagementWidget> {
  final Map<PluginPermission, bool> _permissionStates = {};

  @override
  void initState() {
    super.initState();
    for (final permission in widget.permissions) {
      _permissionStates[permission] = true; // 默认授权
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '权限管理',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...widget.permissions.map((permission) =>
          _buildPermissionTile(permission)),
      ],
    );
  }

  Widget _buildPermissionTile(PluginPermission permission) {
    return SwitchListTile(
      title: Text(permission.displayName),
      subtitle: Text(_getPermissionDescription(permission)),
      value: _permissionStates[permission] ?? false,
      onChanged: (value) {
        setState(() {
          _permissionStates[permission] = value;
        });
        widget.onPermissionChanged?.call(permission, value);
      },
    );
  }

  String _getPermissionDescription(PluginPermission permission) {
    switch (permission) {
      case PluginPermission.fileSystem:
        return '允许插件访问文件系统';
      case PluginPermission.network:
        return '允许插件访问网络';
      case PluginPermission.notifications:
        return '允许插件发送系统通知';
      case PluginPermission.clipboard:
        return '允许插件访问剪贴板';
      case PluginPermission.camera:
        return '允许插件访问相机';
      case PluginPermission.microphone:
        return '允许插件访问麦克风';
      case PluginPermission.location:
        return '允许插件访问位置信息';
      case PluginPermission.deviceInfo:
        return '允许插件获取设备信息';
    }
  }
}
```

## 测试开发

### 1. 单元测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';
import 'package:creative_workshop/src/core/plugins/plugin_registry.dart';

void main() {
  group('PluginManager Tests', () {
    late PluginManager pluginManager;

    setUp(() {
      pluginManager = PluginManager.instance;
    });

    test('should be singleton', () {
      final instance1 = PluginManager.instance;
      final instance2 = PluginManager.instance;
      expect(instance1, same(instance2));
    });

    test('should install plugin successfully', () async {
      final result = await pluginManager.installPlugin('test_plugin');
      expect(result.success, isTrue);
      expect(pluginManager.isPluginInstalled('test_plugin'), isTrue);
    });

    test('should enable plugin successfully', () async {
      await pluginManager.installPlugin('test_plugin');
      final result = await pluginManager.enablePlugin('test_plugin');
      expect(result.success, isTrue);
      expect(pluginManager.isPluginEnabled('test_plugin'), isTrue);
    });

    test('should handle plugin dependencies', () async {
      // 测试依赖解析逻辑
      final dependencies = await pluginManager.resolveDependencies('complex_plugin');
      expect(dependencies, isNotEmpty);
    });
  });

  group('PluginRegistry Tests', () {
    late PluginRegistry registry;

    setUp(() {
      registry = PluginRegistry.instance;
    });

    test('should register plugin successfully', () {
      const metadata = PluginMetadata(
        id: 'test_plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        description: 'A test plugin',
        author: 'Test Author',
        category: 'test',
      );

      registry.registerPlugin(metadata, () => TestPlugin());
      expect(registry.isPluginRegistered('test_plugin'), isTrue);
    });

    test('should start and stop plugin', () async {
      // 注册测试插件
      const metadata = PluginMetadata(
        id: 'test_plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        description: 'A test plugin',
        author: 'Test Author',
        category: 'test',
      );

      registry.registerPlugin(metadata, () => TestPlugin());

      // 启动插件
      await registry.startPlugin('test_plugin');
      expect(registry.isPluginRunning('test_plugin'), isTrue);

      // 停止插件
      await registry.stopPlugin('test_plugin');
      expect(registry.isPluginRunning('test_plugin'), isFalse);
    });
  });
}

// 测试插件实现
class TestPlugin extends Plugin {
  bool _isInitialized = false;
  bool _isRunning = false;

  @override
  String get id => 'test_plugin';

  @override
  String get name => 'Test Plugin';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'A test plugin';

  @override
  PluginMetadata get metadata => const PluginMetadata(
    id: 'test_plugin',
    name: 'Test Plugin',
    version: '1.0.0',
    description: 'A test plugin',
    author: 'Test Author',
    category: 'test',
  );

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
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _isRunning = false;
  }
}
```

### 2. 集成测试

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Creative Workshop Integration Tests', () {
    testWidgets('should display workspace correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreativeWorkspace(
              initialLayout: WorkspaceLayout.store,
            ),
          ),
        ),
      );

      // 验证工作区组件是否正确显示
      expect(find.byType(CreativeWorkspace), findsOneWidget);
      expect(find.text('应用商店'), findsOneWidget);
    });

    testWidgets('should switch between layouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreativeWorkspace(
              initialLayout: WorkspaceLayout.store,
            ),
          ),
        ),
      );

      // 切换到开发者平台
      await tester.tap(find.byIcon(Icons.developer_mode));
      await tester.pumpAndSettle();

      // 验证布局是否切换成功
      expect(find.text('开发者平台'), findsOneWidget);
    });

    testWidgets('should install plugin from store', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreativeWorkspace(
              initialLayout: WorkspaceLayout.store,
            ),
          ),
        ),
      );

      // 查找并点击安装按钮
      await tester.tap(find.text('安装').first);
      await tester.pumpAndSettle();

      // 验证安装成功
      expect(find.text('已安装'), findsOneWidget);
    });
  });
}
```

### 3. 性能测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

void main() {
  group('Performance Tests', () {
    test('plugin installation performance', () async {
      final stopwatch = Stopwatch()..start();
      final pluginManager = PluginManager.instance;

      // 批量安装插件
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(pluginManager.installPlugin('test_plugin_$i'));
      }

      await Future.wait(futures);
      stopwatch.stop();

      // 验证性能指标 (应该在5秒内完成)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('plugin registry search performance', () {
      final stopwatch = Stopwatch()..start();
      final registry = PluginRegistry.instance;

      // 注册大量插件
      for (int i = 0; i < 1000; i++) {
        final metadata = PluginMetadata(
          id: 'plugin_$i',
          name: 'Plugin $i',
          version: '1.0.0',
          description: 'Test plugin $i',
          author: 'Test Author',
          category: 'test',
        );
        registry.registerPlugin(metadata, () => TestPlugin());
      }

      // 执行搜索
      final results = registry.searchPlugins('Plugin');
      stopwatch.stop();

      // 验证搜索性能和结果
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(results.length, 1000);
    });

    test('memory usage test', () {
      // 内存使用测试
      final pluginManager = PluginManager.instance;

      // 安装和卸载插件多次，检查内存泄漏
      for (int i = 0; i < 100; i++) {
        pluginManager.installPlugin('temp_plugin_$i');
        pluginManager.uninstallPlugin('temp_plugin_$i');
      }

      // 验证内存使用情况
      // 这里可以添加内存监控逻辑
    });
  });
}
```

## 调试和优化

### 1. 调试技巧

**使用 Flutter Inspector**:
- 查看组件树结构
- 检查组件属性
- 分析布局问题
- 监控插件状态

**日志调试**:
```dart
import 'dart:developer' as developer;

void debugPluginOperation(String operation, String pluginId) {
  developer.log(
    '插件操作: $operation',
    name: 'PluginManager',
    error: null,
    level: 800,
    sequenceNumber: null,
    zone: null,
    time: DateTime.now(),
  );
}

// 使用示例
debugPluginOperation('安装', 'my_plugin');
```

**断点调试**:
- 在 IDE 中设置断点
- 使用调试模式运行
- 检查变量值和调用栈
- 监控插件生命周期

### 2. 性能优化

**插件加载优化**:
```dart
class OptimizedPluginLoader {
  static final Map<String, Plugin> _pluginCache = {};

  static Future<Plugin> loadPlugin(String pluginId) async {
    // 检查缓存
    if (_pluginCache.containsKey(pluginId)) {
      return _pluginCache[pluginId]!;
    }

    // 懒加载插件
    final plugin = await _createPlugin(pluginId);
    _pluginCache[pluginId] = plugin;

    return plugin;
  }

  static Future<Plugin> _createPlugin(String pluginId) async {
    // 异步创建插件实例
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => MyPlugin(),
    );
  }
}
```

**内存优化**:
```dart
class MemoryOptimizedPluginManager extends ChangeNotifier {
  final Map<String, WeakReference<Plugin>> _pluginRefs = {};

  @override
  void dispose() {
    // 清理弱引用
    _pluginRefs.clear();
    super.dispose();
  }

  void _cleanupUnusedPlugins() {
    _pluginRefs.removeWhere((key, ref) => ref.target == null);
  }
}
```

**UI 渲染优化**:
```dart
class OptimizedPluginCard extends StatelessWidget {
  final PluginInstallInfo plugin;

  const OptimizedPluginCard({Key? key, required this.plugin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(_getPluginIcon()),
          ),
          title: Text(plugin.name),
          subtitle: Text(plugin.version),
          trailing: _buildActionButton(),
        ),
      ),
    );
  }

  IconData _getPluginIcon() {
    // 缓存图标以避免重复计算
    return Icons.extension;
  }

  Widget _buildActionButton() {
    // 使用 const 构造函数优化性能
    return const Icon(Icons.more_vert);
  }
}
```

## 发布和部署

### 1. 版本管理

更新 `pubspec.yaml` 中的版本号：

```yaml
name: creative_workshop
version: 5.0.6+1
description: A powerful Flutter app store and developer platform module
```

### 2. 文档更新

- 更新 API 文档 (`docs/api/api.md`)
- 更新用户指南 (`docs/guides/user_guide.md`)
- 更新架构文档 (`docs/architecture/architecture.md`)
- 更新开发指南 (`docs/development/development.md`)
- 更新变更日志 (`CHANGELOG.md`)

### 3. 测试验证

```bash
# 运行所有测试
dart test

# 运行特定测试
dart test test/src/core/plugins/

# 代码分析
dart analyze

# 格式化代码
dart format .

# 检查依赖
dart pub deps
```

### 4. 发布流程

1. **创建发布分支**:
   ```bash
   git checkout -b release/5.0.6
   ```

2. **更新版本和文档**:
   - 更新版本号
   - 更新文档
   - 更新变更日志

3. **运行完整测试套件**:
   ```bash
   dart test --coverage
   dart analyze
   ```

4. **创建发布标签**:
   ```bash
   git tag -a v5.0.6 -m "Release version 5.0.6"
   ```

5. **合并到主分支**:
   ```bash
   git checkout main
   git merge release/5.0.6
   ```

6. **发布到包管理器**:
   ```bash
   dart pub publish
   ```

## 贡献指南

### 1. 代码贡献

1. **Fork 项目仓库**
2. **创建功能分支**:
   ```bash
   git checkout -b feature/new-plugin-feature
   ```
3. **编写代码和测试**
4. **提交 Pull Request**

### 2. 代码审查标准

- **代码风格**: 遵循 Dart 代码规范
- **测试覆盖**: 新功能必须有对应测试
- **性能影响**: 评估对系统性能的影响
- **文档完整性**: 更新相关文档
- **向后兼容**: 确保不破坏现有 API

### 3. 问题报告

使用 GitHub Issues 报告问题，包含：
- **问题描述**: 清晰描述遇到的问题
- **重现步骤**: 详细的重现步骤
- **期望行为**: 期望的正确行为
- **实际行为**: 实际发生的行为
- **环境信息**: Flutter 版本、操作系统等

## 常见问题

### Q: 如何创建自定义插件？
A: 继承 `Plugin` 类并实现所有抽象方法，然后使用 `PluginRegistry.registerPlugin()` 注册。

### Q: 如何管理插件权限？
A: 在插件元数据中声明所需权限，系统会自动进行权限验证和管理。

### Q: 如何处理插件依赖？
A: 在 `PluginMetadata` 中定义依赖关系，系统会自动解析和安装依赖。

### Q: 如何优化插件加载性能？
A: 使用懒加载、缓存机制、异步加载等技术优化插件加载性能。

### Q: 如何调试插件问题？
A: 使用 Flutter Inspector、日志调试、断点调试等工具进行问题诊断。

### Q: 如何处理插件冲突？
A: 系统会自动检测版本冲突和循环依赖，并提供解决建议。

---

**文档版本**: 5.0.6
**最后更新**: 2025-07-22
**适用版本**: Creative Workshop 5.0.6+
**维护者**: Creative Workshop 开发团队
