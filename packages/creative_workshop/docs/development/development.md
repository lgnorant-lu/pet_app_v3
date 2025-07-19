# Creative Workshop 开发指南

## 概述

本文档为 Creative Workshop 模块的开发者提供详细的开发指南，包括环境搭建、代码规范、扩展开发、测试和部署等内容。

## 开发环境搭建

### 1. 系统要求

- **Flutter SDK**: 3.0.0 或更高版本
- **Dart SDK**: 3.2.0 或更高版本
- **Plugin System**: 必需的插件系统依赖
- **IDE**: VS Code 或 Android Studio
- **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)

### 2. 项目结构

```
creative_workshop/
├── lib/
│   ├── creative_workshop.dart          # 主导出文件
│   ├── creative_workshop_module.dart   # 模块主类
│   └── src/
│       ├── configuration/              # 配置管理
│       ├── constants/                  # 常量定义
│       ├── core/                       # 核心功能
│       │   ├── games/                  # 游戏系统
│       │   ├── projects/               # 项目管理
│       │   ├── tools/                  # 工具系统
│       │   └── workshop_manager.dart   # 工坊管理器
│       ├── logging/                    # 日志系统
│       ├── monitoring/                 # 监控系统
│       ├── ui/                         # 用户界面
│       │   ├── browser/                # 项目浏览器
│       │   ├── canvas/                 # 画布组件
│       │   ├── game/                   # 游戏界面
│       │   ├── panels/                 # 面板组件
│       │   ├── status/                 # 状态栏
│       │   ├── toolbar/                # 工具栏
│       │   └── workspace/              # 工作区
│       ├── utils/                      # 工具函数
│       └── widgets/                    # 通用组件
├── test/                               # 测试文件
├── docs/                               # 文档
├── example/                            # 示例代码
├── pubspec.yaml                        # 依赖配置
└── README.md                           # 项目说明
```

### 3. 依赖管理

主要依赖包括：

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.0.0
  path_provider: ^2.0.0
  uuid: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  test: ^1.21.0
  mockito: ^5.0.0
```

## 代码规范

### 1. 命名规范

**类名**: 使用 PascalCase
```dart
class CreativeWorkshopModule { }
class ProjectManager { }
```

**方法和变量**: 使用 camelCase
```dart
void initializeWorkshop() { }
String projectName = '';
```

**常量**: 使用 SCREAMING_SNAKE_CASE
```dart
static const String DEFAULT_PROJECT_NAME = 'Untitled';
static const int MAX_PROJECT_SIZE = 1024 * 1024;
```

**文件名**: 使用 snake_case
```dart
creative_workshop_module.dart
project_manager.dart
```

### 2. 代码组织

**导入顺序**:
1. Dart 核心库
2. Flutter 库
3. 第三方包
4. 项目内部文件

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/projects/project_manager.dart';
import '../utils/creative_workshop_utils.dart';
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
/// Creative Workshop 模块的主要管理类
/// 
/// 提供工坊的初始化、配置和生命周期管理功能。
/// 
/// 示例用法：
/// ```dart
/// final module = CreativeWorkshopModule.create();
/// await module.initialize();
/// ```
class CreativeWorkshopModule {
  /// 创建模块实例
  /// 
  /// [name] 模块名称，默认为 'CreativeWorkshop'
  /// [version] 模块版本，默认为 '1.0.0'
  /// [config] 配置参数，可选
  static CreativeWorkshopModule create({
    String? name,
    String? version,
    Map<String, dynamic>? config,
  }) {
    // 实现代码
  }
}
```

## 核心开发

### 1. 创建自定义工具

#### 1.1 工具插件基类

```dart
abstract class ToolPlugin {
  /// 工具唯一标识符
  String get id;
  
  /// 工具显示名称
  String get name;
  
  /// 工具描述
  String get description;
  
  /// 工具图标
  IconData get icon;
  
  /// 工具被选中时调用
  void onSelected();
  
  /// 工具被取消选中时调用
  void onDeselected();
  
  /// 处理画布事件
  void onCanvasEvent(CanvasEvent event);
  
  /// 构建属性面板
  Widget buildPropertiesPanel();
  
  /// 获取工具设置
  Map<String, dynamic> getSettings();
  
  /// 应用工具设置
  void applySettings(Map<String, dynamic> settings);
}
```

#### 1.2 实现自定义工具

```dart
class CustomBrushTool extends ToolPlugin {
  double _brushSize = 10.0;
  Color _brushColor = Colors.black;
  
  @override
  String get id => 'custom_brush';
  
  @override
  String get name => '自定义画笔';
  
  @override
  String get description => '具有特殊效果的画笔工具';
  
  @override
  IconData get icon => Icons.brush;
  
  @override
  void onSelected() {
    // 工具选中时的初始化逻辑
  }
  
  @override
  void onDeselected() {
    // 工具取消选中时的清理逻辑
  }
  
  @override
  void onCanvasEvent(CanvasEvent event) {
    switch (event.type) {
      case CanvasEventType.pointerDown:
        _startDrawing(event.position);
        break;
      case CanvasEventType.pointerMove:
        _continueDrawing(event.position);
        break;
      case CanvasEventType.pointerUp:
        _endDrawing(event.position);
        break;
    }
  }
  
  @override
  Widget buildPropertiesPanel() {
    return Column(
      children: [
        // 画笔大小滑块
        Slider(
          value: _brushSize,
          min: 1.0,
          max: 50.0,
          onChanged: (value) => _brushSize = value,
        ),
        // 颜色选择器
        ColorPicker(
          color: _brushColor,
          onColorChanged: (color) => _brushColor = color,
        ),
      ],
    );
  }
  
  void _startDrawing(Offset position) {
    // 开始绘画逻辑
  }
  
  void _continueDrawing(Offset position) {
    // 继续绘画逻辑
  }
  
  void _endDrawing(Offset position) {
    // 结束绘画逻辑
  }
}
```

#### 1.3 注册工具

```dart
// 在模块初始化时注册工具
void registerCustomTools() {
  ToolManager.instance.registerTool(
    'custom_brush',
    () => CustomBrushTool(),
  );
}
```

#### 1.4 插件系统集成

Creative Workshop 完全集成了 Plugin System，支持工具和游戏插件的动态加载。

```dart
// 创建工具插件
class MyToolPlugin extends ToolPlugin {
  @override
  PluginInfo get info => PluginInfo(
    id: 'my_tool_plugin',
    name: '我的工具插件',
    version: '1.0.0',
    description: '自定义工具插件',
    author: '开发者',
    supportedPlatforms: [PluginPlatform.all],
  );

  @override
  Future<void> initialize() async {
    // 插件初始化逻辑
  }

  @override
  Future<void> dispose() async {
    // 插件清理逻辑
  }
}

// 注册插件到系统
void registerPlugin() {
  PluginManager.instance.registerPlugin(MyToolPlugin());
}
```

### 2. 创建自定义游戏

#### 2.1 游戏基类

```dart
abstract class SimpleGame {
  /// 游戏唯一标识符
  String get id;
  
  /// 游戏名称
  String get name;
  
  /// 游戏描述
  String get description;
  
  /// 当前游戏状态
  GameState get state;
  
  /// 开始游戏
  void start();
  
  /// 暂停游戏
  void pause();
  
  /// 恢复游戏
  void resume();
  
  /// 停止游戏
  void stop();
  
  /// 重置游戏
  void reset();
  
  /// 状态变化流
  Stream<GameState> get stateStream;
  
  /// 游戏事件流
  Stream<GameEvent> get eventStream;
}
```

#### 2.2 实现自定义游戏

```dart
class PuzzleGame extends SimpleGame {
  final StreamController<GameState> _stateController = StreamController();
  final StreamController<GameEvent> _eventController = StreamController();
  
  GameState _state = GameState.idle;
  List<List<int>> _puzzle = [];
  int _moves = 0;
  
  @override
  String get id => 'puzzle_game';
  
  @override
  String get name => '拼图游戏';
  
  @override
  String get description => '经典的数字拼图游戏';
  
  @override
  GameState get state => _state;
  
  @override
  Stream<GameState> get stateStream => _stateController.stream;
  
  @override
  Stream<GameEvent> get eventStream => _eventController.stream;
  
  @override
  void start() {
    _state = GameState.running;
    _initializePuzzle();
    _stateController.add(_state);
    _eventController.add(GameEvent(
      type: GameEventType.gameStarted,
      data: {'puzzle': _puzzle},
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  void pause() {
    if (_state == GameState.running) {
      _state = GameState.paused;
      _stateController.add(_state);
    }
  }
  
  @override
  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.running;
      _stateController.add(_state);
    }
  }
  
  @override
  void stop() {
    _state = GameState.idle;
    _stateController.add(_state);
  }
  
  @override
  void reset() {
    _moves = 0;
    _initializePuzzle();
    _eventController.add(GameEvent(
      type: GameEventType.gameReset,
      data: {'puzzle': _puzzle, 'moves': _moves},
      timestamp: DateTime.now(),
    ));
  }
  
  void _initializePuzzle() {
    // 初始化拼图逻辑
    _puzzle = List.generate(3, (i) => List.generate(3, (j) => i * 3 + j + 1));
    _puzzle[2][2] = 0; // 空格
    _shufflePuzzle();
  }
  
  void _shufflePuzzle() {
    // 打乱拼图逻辑
  }
  
  void moveTile(int row, int col) {
    if (_state != GameState.running) return;
    
    // 移动拼图块逻辑
    if (_canMoveTile(row, col)) {
      _swapTiles(row, col);
      _moves++;
      
      _eventController.add(GameEvent(
        type: GameEventType.tileMoved,
        data: {'row': row, 'col': col, 'moves': _moves},
        timestamp: DateTime.now(),
      ));
      
      if (_isPuzzleSolved()) {
        _state = GameState.finished;
        _stateController.add(_state);
        _eventController.add(GameEvent(
          type: GameEventType.gameFinished,
          data: {'moves': _moves},
          timestamp: DateTime.now(),
        ));
      }
    }
  }
  
  bool _canMoveTile(int row, int col) {
    // 检查是否可以移动拼图块
    return true; // 简化实现
  }
  
  void _swapTiles(int row, int col) {
    // 交换拼图块位置
  }
  
  bool _isPuzzleSolved() {
    // 检查拼图是否完成
    return false; // 简化实现
  }
}
```

#### 2.3 注册游戏

```dart
void registerCustomGames() {
  GameManager.instance.registerGame(
    'puzzle_game',
    () => PuzzleGame(),
  );
}
```

### 3. 创建自定义UI组件

#### 3.1 自定义面板

```dart
class CustomPropertiesPanel extends StatefulWidget {
  final VoidCallback? onPropertiesChanged;
  
  const CustomPropertiesPanel({
    Key? key,
    this.onPropertiesChanged,
  }) : super(key: key);
  
  @override
  State<CustomPropertiesPanel> createState() => _CustomPropertiesPanelState();
}

class _CustomPropertiesPanelState extends State<CustomPropertiesPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '自定义属性',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // 自定义属性控件
          _buildCustomControls(),
        ],
      ),
    );
  }
  
  Widget _buildCustomControls() {
    return Column(
      children: [
        // 添加自定义控件
      ],
    );
  }
}
```

## 测试开发

### 1. 单元测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

void main() {
  group('CreativeWorkshopModule Tests', () {
    late CreativeWorkshopModule module;
    
    setUp(() {
      module = CreativeWorkshopModule.create();
    });
    
    test('should create module with default values', () {
      expect(module.name, equals('CreativeWorkshop'));
      expect(module.version, equals('1.0.0'));
    });
    
    test('should initialize successfully', () async {
      await expectLater(module.initialize(), completes);
    });
    
    test('should dispose successfully', () async {
      await module.initialize();
      await expectLater(module.dispose(), completes);
    });
  });
  
  group('ProjectManager Tests', () {
    late ProjectManager projectManager;
    
    setUp(() {
      projectManager = ProjectManager.instance;
    });
    
    test('should create new project', () async {
      final template = ProjectTemplate(
        id: 'test_template',
        name: 'Test Template',
        type: ProjectType.drawing,
        defaultData: {},
      );
      
      final project = await projectManager.createProject(template);
      
      expect(project.name, equals('Test Template'));
      expect(project.type, equals(ProjectType.drawing));
    });
  });
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
            body: CreativeWorkspace(),
          ),
        ),
      );
      
      // 验证工作区组件是否正确显示
      expect(find.byType(CreativeWorkspace), findsOneWidget);
      expect(find.byType(ToolToolbar), findsOneWidget);
      expect(find.byType(CreativeCanvas), findsOneWidget);
    });
    
    testWidgets('should switch between tools', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreativeWorkspace(),
          ),
        ),
      );
      
      // 点击画笔工具
      await tester.tap(find.byIcon(Icons.brush));
      await tester.pumpAndSettle();
      
      // 验证工具是否切换成功
      // 添加验证逻辑
    });
  });
}
```

### 3. 性能测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

void main() {
  group('Performance Tests', () {
    test('canvas rendering performance', () async {
      final stopwatch = Stopwatch()..start();
      
      // 执行大量绘制操作
      for (int i = 0; i < 1000; i++) {
        // 模拟绘制操作
      }
      
      stopwatch.stop();
      
      // 验证性能指标
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    test('memory usage test', () {
      // 内存使用测试
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

**日志调试**:
```dart
import 'package:creative_workshop/src/logging/creative_workshop_logger.dart';

void debugFunction() {
  CreativeWorkshopLogger.debug('调试信息');
  CreativeWorkshopLogger.info('普通信息');
  CreativeWorkshopLogger.warning('警告信息');
  CreativeWorkshopLogger.error('错误信息');
}
```

**断点调试**:
- 在 IDE 中设置断点
- 使用调试模式运行
- 检查变量值和调用栈

### 2. 性能优化

**渲染优化**:
```dart
class OptimizedCanvas extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasPainter(),
        child: Container(),
      ),
    );
  }
}
```

**内存优化**:
```dart
class MemoryOptimizedWidget extends StatefulWidget {
  @override
  void dispose() {
    // 清理资源
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

## 发布和部署

### 1. 版本管理

更新 `pubspec.yaml` 中的版本号：

```yaml
name: creative_workshop
version: 1.0.1+2
```

### 2. 文档更新

- 更新 API 文档
- 更新用户指南
- 更新变更日志

### 3. 测试验证

```bash
# 运行所有测试
flutter test

# 运行集成测试
flutter test integration_test/

# 代码分析
flutter analyze

# 格式化代码
dart format .
```

### 4. 发布流程

1. 创建发布分支
2. 更新版本号和文档
3. 运行完整测试套件
4. 创建发布标签
5. 合并到主分支
6. 发布到包管理器

## 贡献指南

### 1. 代码贡献

1. Fork 项目仓库
2. 创建功能分支
3. 编写代码和测试
4. 提交 Pull Request

### 2. 代码审查

- 代码风格检查
- 功能测试验证
- 性能影响评估
- 文档完整性检查

### 3. 问题报告

使用 GitHub Issues 报告问题，包含：
- 问题描述
- 重现步骤
- 期望行为
- 实际行为
- 环境信息

## 常见问题

### Q: 如何添加新的绘画工具？
A: 继承 `ToolPlugin` 类并实现所有抽象方法，然后使用 `ToolManager.registerTool()` 注册。

### Q: 如何自定义UI主题？
A: 通过 `CreativeWorkshopConfig` 配置主题参数，或直接修改组件的样式属性。

### Q: 如何优化大画布的性能？
A: 使用 `RepaintBoundary` 包装画布，实现增量绘制，使用适当的缓存策略。

### Q: 如何处理内存泄漏？
A: 确保在 `dispose()` 方法中正确清理所有资源，包括控制器、订阅和监听器。
