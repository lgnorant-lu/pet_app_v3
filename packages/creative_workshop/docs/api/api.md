# Creative Workshop API 文档

## 概述

Creative Workshop 模块提供了完整的创意工坊功能，包括绘画工具、游戏系统、项目管理等核心功能。

## 核心类

### CreativeWorkshopModule

主模块类，提供模块的初始化和管理功能。

```dart
class CreativeWorkshopModule {
  static CreativeWorkshopModule create({
    String? name,
    String? version,
    Map<String, dynamic>? config,
  });
  
  String get name;
  String get version;
  Map<String, dynamic> get config;
  
  Future<void> initialize();
  Future<void> dispose();
}
```

### 项目管理

#### CreativeProject

表示一个创意项目的核心类。

```dart
class CreativeProject {
  String id;
  String name;
  String description;
  ProjectType type;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> data;
  
  CreativeProject({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });
}
```

#### ProjectManager

项目管理器，负责项目的创建、保存、加载等操作。

```dart
class ProjectManager {
  static ProjectManager get instance;
  
  Future<List<CreativeProject>> loadProjects();
  Future<void> saveProject(CreativeProject project);
  Future<void> deleteProject(String projectId);
  Future<CreativeProject> createProject(ProjectTemplate template);
  
  CreativeProject? get currentProject;
  Stream<CreativeProject?> get currentProjectStream;
}
```

### 游戏系统

#### SimpleGame

游戏基类，定义了游戏的基本接口。

```dart
abstract class SimpleGame {
  String get id;
  String get name;
  String get description;
  GameState get state;
  
  void start();
  void pause();
  void resume();
  void stop();
  void reset();
  
  Stream<GameState> get stateStream;
  Stream<GameEvent> get eventStream;
}
```

#### GameManager

游戏管理器，负责游戏的注册、创建和管理。

```dart
class GameManager {
  static GameManager get instance;
  
  void registerGame(String id, SimpleGame Function() factory);
  SimpleGame? createGame(String id);
  List<String> getAvailableGames();
  
  SimpleGame? get currentGame;
  Stream<SimpleGame?> get currentGameStream;
}
```

### 绘画工具

#### ToolPlugin

工具插件基类，定义了绘画工具的基本接口。

```dart
abstract class ToolPlugin {
  String get id;
  String get name;
  String get description;
  IconData get icon;
  
  void onSelected();
  void onDeselected();
  void onCanvasEvent(CanvasEvent event);
  
  Widget buildPropertiesPanel();
  Map<String, dynamic> getSettings();
  void applySettings(Map<String, dynamic> settings);
}
```

#### ToolManager

工具管理器，负责工具的注册和管理。

```dart
class ToolManager {
  static ToolManager get instance;
  
  void registerTool(String id, ToolPlugin Function() factory);
  ToolPlugin? createTool(String id);
  List<String> getAvailableTools();
  
  ToolPlugin? get currentTool;
  Stream<ToolPlugin?> get currentToolStream;
}
```

## UI 组件

### CreativeWorkspace

主工作区组件，提供完整的创意工坊界面。

```dart
class CreativeWorkspace extends StatefulWidget {
  const CreativeWorkspace({
    Key? key,
    this.mode = WorkspaceMode.design,
    this.layout = WorkspaceLayout.standard,
    this.project,
    this.game,
    this.tool,
    this.showStatusBar = true,
    this.showProjectBrowser = true,
    this.showPropertiesPanel = true,
    this.showToolbar = true,
    this.onModeChanged,
  }) : super(key: key);
}
```

### CreativeCanvas

绘画画布组件，支持多种绘画模式。

```dart
class CreativeCanvas extends StatefulWidget {
  const CreativeCanvas({
    Key? key,
    this.width = 800,
    this.height = 600,
    this.backgroundColor = Colors.white,
    this.mode = CanvasMode.drawing,
    this.project,
    this.onCanvasChanged,
  }) : super(key: key);
}
```

### GameArea

游戏区域组件，用于显示和运行游戏。

```dart
class GameArea extends StatefulWidget {
  const GameArea({
    Key? key,
    this.width = 800,
    this.height = 600,
    this.backgroundColor = Colors.white,
    this.showControls = true,
  }) : super(key: key);
}
```

### ToolToolbar

工具栏组件，显示可用的绘画工具。

```dart
class ToolToolbar extends StatefulWidget {
  const ToolToolbar({
    Key? key,
    this.orientation = ToolbarOrientation.vertical,
    this.backgroundColor = Colors.grey,
    this.selectedColor = Colors.blue,
    this.iconSize = 24,
    this.padding = const EdgeInsets.all(8),
    this.onToolChanged,
  }) : super(key: key);
}
```

### PropertiesPanel

属性面板组件，显示当前工具或对象的属性。

```dart
class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({
    Key? key,
    this.width = 300,
    this.backgroundColor = Colors.white,
  }) : super(key: key);
}
```

## 事件系统

### CanvasEvent

画布事件，包含用户在画布上的操作信息。

```dart
class CanvasEvent {
  final CanvasEventType type;
  final Offset position;
  final double pressure;
  final DateTime timestamp;
  
  const CanvasEvent({
    required this.type,
    required this.position,
    this.pressure = 1.0,
    required this.timestamp,
  });
}
```

### GameEvent

游戏事件，包含游戏状态变化和用户操作信息。

```dart
class GameEvent {
  final GameEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  const GameEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}
```

## 常量和枚举

### ProjectType

项目类型枚举。

```dart
enum ProjectType {
  drawing,    // 绘画项目
  design,     // 设计项目
  game,       // 游戏项目
  animation,  // 动画项目
  model3d,    // 3D模型项目
  mixed,      // 混合项目
  custom,     // 自定义项目
}
```

### WorkspaceMode

工作区模式枚举。

```dart
enum WorkspaceMode {
  design,  // 设计模式
  game,    // 游戏模式
}
```

### CanvasMode

画布模式枚举。

```dart
enum CanvasMode {
  drawing,  // 绘画模式
  design,   // 设计模式
  game,     // 游戏模式
}
```

### GameState

游戏状态枚举。

```dart
enum GameState {
  idle,     // 空闲
  running,  // 运行中
  paused,   // 暂停
  finished, // 完成
  error,    // 错误
}
```

## 使用示例

### 基本使用

```dart
// 创建模块实例
final module = CreativeWorkshopModule.create(
  name: 'MyCreativeWorkshop',
  version: '1.0.0',
);

// 初始化模块
await module.initialize();

// 使用工作区组件
Widget build(BuildContext context) {
  return CreativeWorkspace(
    mode: WorkspaceMode.design,
    layout: WorkspaceLayout.standard,
    onModeChanged: (mode) {
      // 处理模式变化
    },
  );
}
```

### 创建自定义项目

```dart
// 创建项目模板
final template = ProjectTemplate(
  id: 'custom_template',
  name: '自定义模板',
  description: '我的自定义项目模板',
  type: ProjectType.custom,
  defaultData: {
    'customProperty': 'value',
  },
);

// 创建项目
final project = await ProjectManager.instance.createProject(template);
```

### 注册自定义工具

```dart
// 创建自定义工具
class MyCustomTool extends ToolPlugin {
  @override
  String get id => 'my_custom_tool';
  
  @override
  String get name => '我的工具';
  
  @override
  String get description => '这是我的自定义工具';
  
  @override
  IconData get icon => Icons.brush;
  
  // 实现其他方法...
}

// 注册工具
ToolManager.instance.registerTool(
  'my_custom_tool',
  () => MyCustomTool(),
);
```

### 创建自定义游戏

```dart
// 创建自定义游戏
class MyCustomGame extends SimpleGame {
  @override
  String get id => 'my_custom_game';
  
  @override
  String get name => '我的游戏';
  
  @override
  String get description => '这是我的自定义游戏';
  
  // 实现其他方法...
}

// 注册游戏
GameManager.instance.registerGame(
  'my_custom_game',
  () => MyCustomGame(),
);
```
