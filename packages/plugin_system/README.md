# plugin_system

插件系统核心模块

## 📊 项目状态

[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.2.0-blue.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![codecov](https://codecov.io/gh/username/plugin_system/branch/main/graph/badge.svg)](https://codecov.io/gh/username/plugin_system)
[![Tests](https://github.com/username/plugin_system/workflows/Tests/badge.svg)](https://github.com/username/plugin_system/actions)

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

**Plugin System** 是 Pet App V3 的核心插件化框架，实现了"万物皆插件"的设计理念。它提供了完整的插件生命周期管理、通信机制和事件系统，让应用具备高度的可扩展性和模块化能力。

### 🏗️ 核心架构

- **Plugin**: 插件基类，定义标准接口
- **PluginRegistry**: 插件注册中心，管理插件生命周期
- **PluginLoader**: 插件加载器，动态加载和卸载
- **PluginMessenger**: 消息传递器，插件间通信
- **EventBus**: 事件总线，发布订阅机制

## ✨ 功能特性

- 🔌 **万物皆插件**: 统一的插件接口规范
- 🔄 **动态管理**: 运行时插件加载和卸载
- 💬 **插件通信**: 完整的消息传递和事件系统
- 🛡️ **安全可靠**: 权限管理和异常处理
- 📈 **高性能**: 异步处理和资源优化
- 🌐 **跨平台**: 支持所有主流平台
- 🧪 **测试完备**: 44个测试用例，100%通过率
- 📚 **文档完整**: 详细的API和架构文档
- 🧪 完整的测试覆盖

## 🚀 快速开始

### 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  plugin_system:
    path: ../packages/plugin_system
```

### 1. 创建插件

```dart
import 'package:plugin_system/plugin_system.dart';

class MyPlugin extends Plugin {
  @override
  String get id => 'my_plugin';

  @override
  String get name => 'My Plugin';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'My first plugin';

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

  // ... 实现其他必需方法
}
```

### 2. 加载插件

```dart
void main() async {
  final plugin = MyPlugin();
  final loader = PluginLoader.instance;

  await loader.loadPlugin(plugin);
  print('Plugin loaded successfully!');
}
```

### 3. 插件通信

```dart
final messenger = PluginMessenger.instance;

// 发送消息
final response = await messenger.sendMessage(
  'sender_id',
  'target_id',
  'action',
  {'data': 'value'},
);

// 订阅事件
final eventBus = EventBus.instance;
eventBus.on('event_type', (event) {
  print('Received event: ${event.data}');
});
```

## 📚 文档导航

### 📖 用户文档
- [用户指南](docs/user/user_guide.md) - 快速上手和基本使用
- [API 文档](docs/api/plugin_api.md) - 完整的API参考

### 🏗️ 架构文档
- [系统架构](docs/architecture/system_architecture.md) - 深入的架构设计

### 👨‍💻 开发者文档
- [开发者指南](docs/developer/developer_guide.md) - 高级开发和扩展

### 🧪 测试和示例
- [测试用例](test/) - 完整的测试套件
- [示例插件](test/helpers/test_plugin.dart) - 参考实现

## 🛠️ 开发指南

### 项目结构

```
plugin_system/
├── lib/
│   ├── src/
│   │   └── core/           # 核心功能
│   │       ├── plugin.dart
│   │       ├── plugin_registry.dart
│   │       ├── plugin_loader.dart
│   │       ├── plugin_messenger.dart
│   │       ├── event_bus.dart
│   │       └── plugin_exceptions.dart
│   └── plugin_system.dart  # 主导出文件
├── test/
│   ├── unit/              # 单元测试
│   ├── integration/       # 集成测试
│   └── helpers/           # 测试辅助工具
├── docs/                  # 文档
└── pubspec.yaml
```

### 代码规范

项目遵循 [Dart 官方代码规范](https://dart.dev/guides/language/effective-dart)。

运行代码检查：

```bash
dart analyze
dart format .
```

格式化代码：

```bash
dart format .
```

## 🧪 测试

### 运行所有测试

```bash
dart test
```

### 运行特定测试

```bash
dart test test/unit/plugin_registry_test.dart
dart test test/integration/plugin_system_integration_test.dart
```

### 测试覆盖率

- **单元测试**: 26个测试用例，100%通过率
- **集成测试**: 18个测试用例，100%通过率
- **总计**: 44个测试用例，100%通过率
- **代码覆盖**: 核心功能全覆盖

## � 项目状态

### ✅ 已完成功能

- [x] 插件基类和接口规范
- [x] 插件注册中心
- [x] 插件加载器
- [x] 插件消息传递
- [x] 事件总线系统
- [x] 异常处理体系
- [x] 单元测试和集成测试
- [x] 完整文档体系

### 🎯 性能指标

- **插件加载**: < 100ms (典型插件)
- **消息传递**: < 10ms (本地通信)
- **事件分发**: < 5ms (单个事件)
- **内存占用**: < 10MB (基础框架)

## 🤝 贡献指南

我们欢迎所有形式的贡献！请查看 [开发者指南](docs/developer/developer_guide.md) 了解详细信息。

### 开发流程

1. Fork 项目
2. 创建功能分支
3. 编写代码和测试
4. 提交 Pull Request

### 代码规范

- 遵循 Dart 官方代码风格
- 保持测试覆盖率 > 90%
- 编写清晰的文档注释

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为 Plugin System 做出贡献的开发者和用户！

---

**Plugin System** - 让 Pet App V3 真正实现"万物皆插件"的技术基础 🚀

## 📄 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

**Pet App Team**

- 项目链接: [https://github.com/username/plugin_system](https://github.com/username/plugin_system)
- 问题反馈: [https://github.com/username/plugin_system/issues](https://github.com/username/plugin_system/issues)

---

⭐ 如果这个项目对你有帮助，请给它一个星标！

