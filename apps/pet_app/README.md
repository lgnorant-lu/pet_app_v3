# Pet App V3

Pet App V3 是一个基于 Flutter 的跨平台宠物应用，采用企业级模块化架构设计，实现了完整的插件系统和应用运行时。

## ✨ 特性

- 🔌 **模块化架构** - 5个独立模块，完全解耦的设计
- 🎨 **创意工坊** - 强大的创意工具和游戏插件生态
- 🚀 **应用运行时** - 企业级生命周期管理和模块通信
- 🧭 **智能导航** - 深度链接、历史记录、快捷键和手势支持
- 🐾 **桌宠系统** - 智能AI桌宠，完整的生命周期管理
- 📱 **跨平台支持** - Android、iOS、Web、Windows、macOS、Linux

## 🚀 开发状态

**当前版本**: v5.0.5 - 模块化重构完成

### ✅ 已完成阶段

**Phase 1-4**: 核心功能开发 (插件系统、创意工坊、应用运行时、用户界面)

**Phase 5**: 模块化重构 - 将核心功能拆分为独立模块
- ✅ **5.0.1**: Home Dashboard 模块迁移
- ✅ **5.0.2**: Settings System 模块迁移
- ✅ **5.0.3**: Desktop Pet 模块迁移
- ✅ **5.0.4**: App Manager 模块迁移
- ✅ **5.0.5**: Communication System 模块迁移

## 📊 质量指标

- **测试覆盖**: 527个测试，527个通过 (100.0%通过率)
- **代码质量**: 0错误0警告，企业级代码标准
- **架构**: 分层模块化 + 插件系统 + 响应式UI
- **性能**: 启动时间 < 500ms，内存使用 < 60MB

## 🛠️ 快速开始

### 环境要求
- **Flutter**: 3.16.0+
- **Dart**: 3.2.0+
- **IDE**: VS Code 或 Android Studio

### 安装和运行
```bash
# 克隆项目
git clone <repository-url>
cd pet_app_v3/apps/pet_app

# 安装依赖
flutter pub get

# 运行代码生成
flutter packages pub run build_runner build

# 运行应用
flutter run
```

### 测试
```bash
# 运行纯Dart测试 (推荐)
dart test test/core/ test/integration/ test/widget_test.dart test/phase_3_validation_test.dart test/phase_2_9_3_validation_test.dart

# 运行UI测试
dart test test/ui/

# 运行所有测试
flutter test

# 静态分析
dart analyze
```

## 🏗️ 模块化架构

Pet App V3 采用完全解耦的模块化架构，5个核心模块独立开发和维护：

```
┌─────────────────────────────────────────────────────────────┐
│                    Pet App V3 主应用                        │
├─────────────────────────────────────────────────────────────┤
│  独立模块包 (packages/)                                     │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │ home_dashboard  │ │ settings_system │ │  desktop_pet    │ │
│  │   首页仪表板     │ │    设置系统      │ │    桌宠系统     │ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
│  ┌─────────────────┐ ┌─────────────────┐                     │
│  │   app_manager   │ │communication_sys│                     │
│  │   应用管理器     │ │    通信系统      │                     │
│  └─────────────────┘ └─────────────────┘                     │
├─────────────────────────────────────────────────────────────┤
│  核心系统 (lib/core/)                                       │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │   插件系统      │ │   创意工坊      │ │   生命周期      │ │
│  │ PluginSystem    │ │CreativeWorkshop │ │ LifecycleManager│ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 🔧 架构特点

- **完全解耦**: 每个模块都是独立的 Dart 包
- **统一通信**: 通过 `communication_system` 模块协调
- **标准化**: 所有模块遵循统一的架构模式
- **可维护性**: 模块间依赖清晰，便于维护和扩展

## 🎯 核心模块

### 📊 Home Dashboard - 首页仪表板
- 应用状态和用户数据聚合展示
- 快速访问面板和个性化推荐

### ⚙️ Settings System - 设置系统
- 用户偏好设置和系统配置管理
- 分类设置界面，实时生效机制

### 🐾 Desktop Pet - 桌宠系统
- 智能AI桌宠，完整的生命周期管理
- 105个测试用例，确保系统稳定性

### 📱 App Manager - 应用管理器
- 应用的安装、卸载、更新管理
- 应用运行状态的实时监控

### 🔗 Communication System - 通信系统
- 统一消息总线，跨模块通信协调
- 事件路由、数据同步、冲突解决

## 🚀 快速开始

### 环境要求
- Flutter 3.16.0+
- Dart 3.2.0+
- Ming Status CLI (用于模块管理)

### 安装和运行
```bash
# 克隆项目
git clone <repository-url>
cd pet_app_v3/apps/pet_app

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 📚 文档

- [架构文档](docs/architecture/system_architecture.md) - 系统架构设计
- [Phase 5 重构文档](docs/architecture/phase5_modularization.md) - 模块化重构详情
- [开发者指南](docs/developer/development_guide.md) - 开发流程和规范

## 📄 许可证

本项目采用 MIT 许可证。
