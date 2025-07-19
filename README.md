# Pet App V3

[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.2.0-blue.svg)](https://dart.dev/)
[![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Pet App V3 是一个现代化的 Flutter 多平台应用项目，采用模块化架构设计，支持 Web、桌面和移动平台。

## 📋 项目概述

Pet App V3 是 Pet App 系列的第三代产品，完全重构并采用了企业级的模块化架构。项目包含两个核心模块：

- **Plugin System** - 企业级插件系统
- **Creative Workshop** - 创意工坊核心模块

## 🏗️ 项目架构

```
pet_app_v3/
├── packages/
│   ├── plugin_system/        # 插件系统 ✅ v1.2.0
│   └── creative_workshop/    # 创意工坊 ✅ v1.4.0
├── docs/                     # 项目文档
├── lib/                      # 主应用代码
├── test/                     # 测试文件
└── pubspec.yaml             # 项目配置
```

## ✨ 功能特性

### 🔌 Plugin System (v1.2.0)
- **企业级插件架构**: 完整的插件生命周期管理
- **跨平台支持**: Web、桌面、移动平台全覆盖
- **动态加载**: 支持插件的动态注册和卸载
- **权限管理**: 完整的插件权限系统
- **测试覆盖**: 100%测试通过率

### 🎨 Creative Workshop (v1.4.0)
- **绘画功能**: 多种绘画工具，支持画笔、铅笔、形状工具
- **游戏系统**: 内置游戏引擎，支持自定义游戏开发
- **项目管理**: 完整的项目生命周期管理
- **存储系统**: 跨平台存储支持
- **测试覆盖**: 163个测试用例，100%通过率

## 🚀 快速开始

### 前置要求

- [Flutter SDK](https://flutter.dev/) >= 3.0.0
- [Dart SDK](https://dart.dev/) >= 3.2.0

### 安装和运行

```bash
# 克隆项目
git clone <repository-url>
cd pet_app_v3

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 📚 文档

- [项目上下文](docs/Context.md) - 项目整体状态和进度
- [Plugin System 文档](packages/plugin_system/README.md)
- [Creative Workshop 文档](packages/creative_workshop/README.md)

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行特定模块测试
cd packages/plugin_system && flutter test
cd packages/creative_workshop && flutter test
```

## 📊 项目状态

**当前版本**: v1.4.0
**开发状态**: Phase 2.9.2 已完成 ✅
**下一阶段**: Phase 3.0 主应用集成

### 模块状态
- ✅ **Plugin System**: v1.2.0 - 企业级插件系统完成
- ✅ **Creative Workshop**: v1.4.0 - 创意工坊功能完成

## 🤝 贡献指南

欢迎贡献代码！请查看各模块的开发指南：

- [Plugin System 开发指南](packages/plugin_system/docs/development/development.md)
- [Creative Workshop 开发指南](packages/creative_workshop/docs/development/development.md)

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
