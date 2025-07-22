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

Creative Workshop 是一个功能强大的 Flutter 应用商店与开发者平台模块，为用户提供插件发现、安装、管理等完整的应用生态功能。该模块采用模块化设计，支持动态插件加载，是 Pet App V3 项目的核心组件之一。

**🔄 Phase 5.0.6 重大更新**: 从绘画工具转型为应用商店+开发者平台+插件管理三位一体系统

## ✨ 功能特性

### 🏪 应用商店功能
- **插件发现**: 浏览和搜索各类插件应用
- **一键安装**: 简单快捷的插件安装体验
- **分类管理**: 工具、游戏、实用程序等分类
- **评级评论**: 用户评价和反馈系统

### 👨‍💻 开发者平台
- **项目管理**: 完整的开发项目生命周期管理
- **插件开发**: 集成开发环境和调试工具
- **发布管理**: 插件发布、审核、版本控制
- **Ming CLI 集成**: 命令行工具无缝集成

### 🔧 插件管理系统
- **生命周期管理**: 插件安装、启用、禁用、卸载
- **权限控制**: 8种权限类型的细粒度管理
- **依赖解析**: 自动依赖检查和可视化
- **更新管理**: 自动和手动更新机制

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
- **完整API**: 丰富的API接口和插件注册表
- **详细文档**: 完整的开发文档和示例
- **企业级架构**: 双核心架构(PluginManager + PluginRegistry)
- **代码质量**: 0错误0警告，严格代码分析

## 🚀 快速开始

### 前置要求

- [Flutter SDK](https://flutter.dev/) >= 3.0.0
- [Dart SDK](https://dart.dev/) >= 3.2.0

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
          initialLayout: WorkspaceLayout.store, // 应用商店模式
          onLayoutChanged: (layout) {
            print('布局切换到: $layout');
          },
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化插件管理器
  await PluginManager.instance.initialize();

  runApp(MyApp());
}
```

### 高级用法

#### 插件管理

```dart
import 'package:creative_workshop/src/core/plugins/plugin_manager.dart';

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

#### 插件注册表

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

### Phase 5.0.6 完成状态
- ✅ **Phase 5.0.6.1**: 应用商店界面 (100%)
- ✅ **Phase 5.0.6.2**: 应用商店功能 (100%)
- ✅ **Phase 5.0.6.3**: 开发者平台 (95%)
- ✅ **Phase 5.0.6.4**: 插件管理系统 (95%)

### 核心功能状态
- ✅ 应用商店功能完成
- ✅ 开发者平台完成
- ✅ 插件管理系统完成
- ✅ 插件注册表完成
- ✅ 权限管理完成
- ✅ 依赖管理完成
- ✅ 更新管理完成
- ✅ 企业级架构完成

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

