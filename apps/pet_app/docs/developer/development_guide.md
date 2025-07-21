# Pet App V3 开发者指南

## 概述
Pet App V3 开发者指南，涵盖模块化架构设计、开发流程、测试规范和部署指南。经过 Phase 5 模块化重构，项目采用完全解耦的独立模块架构。

## 开发环境设置

### 系统要求
- **Flutter**: 3.16.0 或更高版本
- **Dart**: 3.2.0 或更高版本
- **IDE**: VS Code 或 Android Studio
- **Git**: 用于版本控制
- **Ming Status CLI**: 用于模块创建和管理

### 项目结构 (Phase 5 模块化重构后)
```
pet_app_v3/
├── apps/
│   └── pet_app/                 # 主应用
│       ├── lib/
│       │   ├── core/            # 核心系统 (保留)
│       │   │   ├── lifecycle/   # 生命周期管理
│       │   │   ├── plugins/     # 插件系统
│       │   │   ├── workshop/    # 创意工坊
│       │   │   └── providers/   # 状态管理
│       │   ├── ui/              # UI组件
│       │   │   ├── framework/   # 主框架
│       │   │   ├── navigation/  # 导航系统
│       │   │   └── components/  # 通用组件
│       │   ├── app.dart         # 应用入口
│       │   └── main.dart        # 主函数
│       ├── test/                # 测试文件
│       ├── docs/                # 文档
│       └── pubspec.yaml         # 依赖配置
└── packages/                    # 独立模块包
    ├── home_dashboard/          # 首页仪表板模块
    ├── settings_system/         # 设置系统模块
    ├── desktop_pet/             # 桌宠系统模块
    ├── app_manager/             # 应用管理器模块
    └── communication_system/    # 通信系统模块
```

### 模块化架构特点
- **完全解耦**: 每个模块都是独立的 Dart 包
- **统一通信**: 通过 `communication_system` 模块协调
- **标准化**: 所有模块遵循统一的架构模式
- **可维护性**: 模块间依赖清晰，便于维护和扩展

### 依赖管理 (Phase 5 模块化架构)

#### 主应用依赖配置
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Phase 5: 独立模块依赖
  home_dashboard:
    path: ../../packages/home_dashboard
  settings_system:
    path: ../../packages/settings_system
  desktop_pet:
    path: ../../packages/desktop_pet
  app_manager:
    path: ../../packages/app_manager
  communication_system:
    path: ../../packages/communication_system

  # 状态管理
  flutter_riverpod: ^2.4.9
  # 核心依赖
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  # UI组件
  cupertino_icons: ^1.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 模块化架构原则

### 设计原则
- **完全解耦**: 每个模块都是独立的 Dart 包
- **统一通信**: 通过 communication_system 模块协调
- **标准化**: 所有模块遵循统一的架构模式
- **可维护性**: 模块间依赖清晰，便于维护和扩展

### 开发流程
```
需求分析 → 模块设计 → 接口定义 → 实现开发 → 单元测试 → 集成测试 → 文档更新
```

### 代码规范
- 遵循 Dart/Flutter 官方代码规范
- 使用 `dart analyze` 进行静态分析
- 保持 0 错误 0 警告的代码质量

### 测试规范
- **单元测试**: 覆盖率 > 90%
- **集成测试**: 覆盖主要业务流程
- **静态分析**: 0 错误 0 警告

## 模块开发

### 新模块开发流程
1. **使用 Ming CLI 创建模块**: `ming template create`
2. **实现模块核心功能**: 按照标准架构模式开发
3. **集成通信接口**: 与 communication_system 集成
4. **编写测试用例**: 确保高质量的测试覆盖
5. **更新主应用依赖**: 在主应用中添加模块依赖
6. **文档更新**: 更新相关文档和使用指南

### 模块标准规范
- **目录结构**: 遵循标准的 Dart 包结构
- **导出接口**: 通过 `lib/module_name.dart` 统一导出
- **测试覆盖**: 保持高质量的测试覆盖率
- **文档完善**: 包含 README、API 文档和使用示例

## 快速开始

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

### 测试
```bash
# 运行测试
flutter test

# 静态分析
dart analyze
```

## 文档

详细的开发文档请参考：
- [API文档](../api/plugin_api.md) - 完整的API接口说明
- [架构文档](../architecture/system_architecture.md) - 系统架构设计
- [用户指南](../user/user_guide.md) - 用户使用指南
- [测试报告](../testing/test_report.md) - 详细测试报告
- [部署指南](../deployment/deployment_guide.md) - 部署和发布指南


