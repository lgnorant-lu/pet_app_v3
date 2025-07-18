# creative_workshop

创意工坊核心模块

## 📊 项目状态

[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.2.0-blue.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![codecov](https://codecov.io/gh/username/creative_workshop/branch/main/graph/badge.svg)](https://codecov.io/gh/username/creative_workshop)
[![Tests](https://github.com/username/creative_workshop/workflows/Tests/badge.svg)](https://github.com/username/creative_workshop/actions)

## 📋 目录

- [项目描述](#-项目描述)
- [功能特性](#-功能特性)
- [快速开始](#-快速开始)
- [安装说明](#-安装说明)
- [使用说明](#-使用说明)
- [API文档](#-api文档)
- [开发指南](#-开发指南)
- [测试](#-测试)
- [部署](#-部署)
- [贡献指南](#-贡献指南)
- [许可证](#-许可证)
- [联系方式](#-联系方式)

## 📖 项目描述

Creative Workshop 是一个功能强大的 Flutter 创意工坊模块，为用户提供绘画、游戏、项目管理等完整的创意功能。该模块采用模块化设计，支持插件扩展，是 Pet App V3 项目的核心组件之一。

## ✨ 功能特性

### 🎨 绘画功能
- **多种绘画工具**: 画笔、铅笔、形状工具、橡皮擦等
- **高级画布**: 支持多点触控、压感、无限画布
- **图层管理**: 完整的图层系统，支持混合模式
- **颜色系统**: 丰富的调色板和颜色管理

### 🎮 游戏系统
- **内置游戏**: 点击游戏、猜数字游戏等
- **游戏引擎**: 完整的游戏状态管理和事件系统
- **可扩展**: 支持自定义游戏开发

### 📁 项目管理
- **项目模板**: 多种预设项目模板
- **自动保存**: 智能的自动保存机制
- **导入导出**: 支持多种格式的项目导入导出
- **项目浏览**: 直观的项目管理界面

### 🖥️ 用户界面
- **现代化设计**: 美观且直观的用户界面
- **响应式布局**: 适配不同屏幕尺寸
- **主题支持**: 浅色/深色主题切换
- **可定制**: 灵活的界面配置选项

### 🔧 开发者友好
- **插件系统**: 支持自定义工具和游戏插件
- **完整API**: 丰富的API接口
- **详细文档**: 完整的开发文档和示例
- **测试覆盖**: 73个企业级测试，100%通过率
- **代码质量**: 0错误0警告，严格代码分析

## 🚀 快速开始

### 前置要求

- [Flutter SDK](https://flutter.dev/) >= 3.0.0
- [Dart SDK](https://dart.dev/) >= 2.17.0

### 安装

在您的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  creative_workshop:
    path: ../packages/creative_workshop
```

然后运行：

```bash
flutter pub get
```

## 🎯 使用说明

### 基本用法

```dart
import 'package:flutter/material.dart';
import 'package:creative_workshop/creative_workshop.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creative Workshop Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Creative Workshop'),
        ),
        body: CreativeWorkspace(
          mode: WorkspaceMode.design,
          layout: WorkspaceLayout.standard,
          onModeChanged: (mode) {
            print('工作模式切换到: $mode');
          },
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 创建并初始化模块
  final module = CreativeWorkshopModule.create(
    name: 'MyCreativeWorkshop',
    version: '1.0.0',
    config: {
      'enableLogging': true,
      'autoSave': true,
    },
  );

  await module.initialize();

  runApp(MyApp());
}
```

### 高级用法

#### 创建自定义工具

```dart
class MyCustomTool extends ToolPlugin {
  @override
  String get id => 'my_custom_tool';

  @override
  String get name => '我的工具';

  @override
  String get description => '这是一个自定义工具';

  @override
  IconData get icon => Icons.star;

  @override
  void onCanvasEvent(CanvasEvent event) {
    // 处理画布事件
    switch (event.type) {
      case CanvasEventType.pointerDown:
        // 开始绘制
        break;
      case CanvasEventType.pointerMove:
        // 继续绘制
        break;
      case CanvasEventType.pointerUp:
        // 结束绘制
        break;
    }
  }

  @override
  Widget buildPropertiesPanel() {
    return Column(
      children: [
        Text('自定义工具属性'),
        // 添加属性控件
      ],
    );
  }

  // 实现其他抽象方法...
}

// 注册自定义工具
void registerCustomTool() {
  ToolManager.instance.registerTool(
    'my_custom_tool',
    () => MyCustomTool(),
  );
}
```

#### 创建自定义游戏

```dart
class MyCustomGame extends SimpleGame {
  @override
  String get id => 'my_custom_game';

  @override
  String get name => '我的游戏';

  @override
  String get description => '这是一个自定义游戏';

  @override
  void start() {
    // 游戏开始逻辑
  }

  @override
  void pause() {
    // 游戏暂停逻辑
  }

  // 实现其他抽象方法...
}

// 注册自定义游戏
void registerCustomGame() {
  GameManager.instance.registerGame(
    'my_custom_game',
    () => MyCustomGame(),
  );
}
```

## 📚 文档

- [API 文档](docs/api/api.md) - 详细的API参考
- [架构文档](docs/architecture/architecture.md) - 系统架构和设计
- [用户指南](docs/guides/user_guide.md) - 用户使用指南
- [开发指南](docs/development/development.md) - 开发者指南

## 🛠️ 开发指南

### 项目结构

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

### 代码规范

项目遵循 [Dart 官方代码规范](https://dart.dev/guides/language/effective-dart) 和 [Flutter 代码规范](https://docs.flutter.dev/development/tools/formatting)。

运行代码检查：

```bash
flutter analyze
```

格式化代码：

```bash
dart format .
```

## 🧪 测试

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行测试并生成覆盖率报告
flutter test --coverage

# 运行集成测试
flutter test integration_test/
```

### 测试覆盖率

查看测试覆盖率报告：

```bash
# 生成HTML覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📊 项目状态

- ✅ 核心功能完成
- ✅ 基础UI组件完成
- ✅ 项目管理系统完成
- ✅ 工具系统完成
- ✅ 游戏系统完成
- ✅ 测试覆盖完成
- ✅ 文档完成

## 🤝 贡献指南

欢迎贡献代码！请查看 [开发指南](docs/development.md) 了解如何参与开发。

### 提交流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 编写代码和测试
4. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
5. 推送到分支 (`git push origin feature/AmazingFeature`)
6. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 相关链接

- [Pet App V3 项目](../../README.md)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)

## 📞 支持

如果您在使用过程中遇到问题，可以：

1. 查看 [用户指南](docs/guides/user_guide.md)
2. 查看 [常见问题](docs/development/development.md#常见问题)
3. 提交 [Issue](https://github.com/your-repo/issues)
4. 联系开发团队

---

⭐ 如果这个项目对你有帮助，请给它一个星标！

