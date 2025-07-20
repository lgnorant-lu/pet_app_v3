# Pet App V3 部署指南

## 概述
Pet App V3 Phase 4.1-4.2 部署指南，涵盖多平台构建、发布流程和运维监控。

## 部署环境要求

### 开发环境
- **Flutter**: 3.16.0+
- **Dart**: 3.2.0+
- **Git**: 2.30+
- **IDE**: VS Code 或 Android Studio

### 构建环境
- **CI/CD**: GitHub Actions 或 GitLab CI
- **构建机器**: 
  - macOS (iOS构建)
  - Linux/Windows (Android/Web/Desktop构建)
- **内存**: 8GB+
- **存储**: 50GB+

### 目标平台
- **移动端**: Android 7.0+, iOS 12.0+
- **桌面端**: Windows 10+, macOS 10.14+, Linux Ubuntu 18.04+
- **Web端**: Chrome 90+, Firefox 88+, Safari 14+

## 构建配置

### 1. 环境配置文件

#### config/app_config.dart
```dart
class AppConfig {
  static const String appName = 'Pet App V3';
  static const String version = '4.2.0';
  static const int buildNumber = 1;
  
  // 环境配置
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool enableDebugFeatures = !isProduction;
  
  // API配置
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.petapp.dev',
  );
  
  // 功能开关
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true);
  static const bool enableCrashReporting = bool.fromEnvironment('ENABLE_CRASH_REPORTING', defaultValue: true);
}
```

#### pubspec.yaml 版本配置
```yaml
name: pet_app_v3
description: Pet App V3 - 宠物应用第三版
version: 3.3.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  # 生产依赖
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  build_runner: ^2.4.7
```

### 2. 平台特定配置

#### Android 配置
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.petapp.v3"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        
        // 深度链接配置
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'petapp'
        ]
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
            debuggable true
        }
    }
}
```

#### iOS 配置
```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <key>CFBundleName</key>
    <string>Pet App V3</string>
    <key>CFBundleIdentifier</key>
    <string>com.petapp.v3</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <!-- 深度链接配置 -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>petapp.deeplink</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>petapp</string>
            </array>
        </dict>
    </array>
    
    <!-- 权限配置 -->
    <key>NSCameraUsageDescription</key>
    <string>Pet App需要访问相机来拍摄宠物照片</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Pet App需要访问相册来选择宠物照片</string>
</dict>
```

## 构建流程

### 1. 本地构建

#### 开发构建
```bash
# 安装依赖
flutter pub get

# 代码生成
flutter packages pub run build_runner build

# 运行测试
flutter test

# 启动开发服务器
flutter run
```

#### 发布构建
```bash
# Android APK
flutter build apk --release --target-platform android-arm64

# Android App Bundle (推荐)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

### 2. CI/CD 自动化构建

#### GitHub Actions 配置
```yaml
# .github/workflows/build.yml
name: Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
      working-directory: apps/pet_app
    
    - name: Run tests
      run: flutter test
      working-directory: apps/pet_app
    
    - name: Analyze code
      run: flutter analyze
      working-directory: apps/pet_app

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    
    - name: Build APK
      run: flutter build apk --release
      working-directory: apps/pet_app
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: apps/pet_app/build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
      working-directory: apps/pet_app

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Build Web
      run: flutter build web --release
      working-directory: apps/pet_app
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: apps/pet_app/build/web
```

## 发布流程

### 1. 版本管理

#### 版本号规范
```
主版本.次版本.修订版本+构建号
例如: 3.3.0+1

主版本: 重大架构变更或不兼容更新
次版本: 新功能添加或重要改进
修订版本: 错误修复或小幅改进
构建号: 每次构建递增
```

#### 发布检查清单
```markdown
发布前检查:
- [ ] 所有测试通过 (98%+通过率)
- [ ] 代码静态分析无错误
- [ ] 性能测试达标
- [ ] 安全扫描通过
- [ ] 文档更新完成
- [ ] 变更日志更新
- [ ] 版本号正确更新
- [ ] 签名证书有效
- [ ] 多平台构建成功
- [ ] 内部测试完成
```

### 2. 应用商店发布

#### Google Play Store
```bash
# 1. 构建App Bundle
flutter build appbundle --release

# 2. 上传到Google Play Console
# - 登录 https://play.google.com/console
# - 选择应用
# - 上传 build/app/outputs/bundle/release/app-release.aab
# - 填写发布说明
# - 提交审核

# 3. 发布配置
# - 设置发布轨道 (内部测试/封闭测试/开放测试/生产)
# - 配置分阶段发布
# - 设置目标用户群体
```

#### Apple App Store
```bash
# 1. 构建iOS应用
flutter build ios --release

# 2. 使用Xcode Archive
# - 在Xcode中打开 ios/Runner.xcworkspace
# - 选择 Product > Archive
# - 上传到App Store Connect

# 3. App Store Connect配置
# - 登录 https://appstoreconnect.apple.com
# - 创建新版本
# - 上传构建版本
# - 填写应用信息和截图
# - 提交审核
```

#### Web部署
```bash
# 1. 构建Web应用
flutter build web --release

# 2. 部署到服务器
# 方式1: GitHub Pages
git subtree push --prefix apps/pet_app/build/web origin gh-pages

# 方式2: 自定义服务器
rsync -avz apps/pet_app/build/web/ user@server:/var/www/petapp/

# 3. 配置Web服务器
# Nginx配置示例:
server {
    listen 80;
    server_name petapp.com;
    root /var/www/petapp;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 缓存配置
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 3. 桌面应用分发

#### Windows
```bash
# 1. 构建Windows应用
flutter build windows --release

# 2. 创建安装包 (使用Inno Setup或NSIS)
# installer_script.iss
[Setup]
AppName=Pet App V3
AppVersion=3.3.0
DefaultDirName={pf}\Pet App V3
DefaultGroupName=Pet App V3
OutputDir=dist
OutputBaseFilename=PetAppV3-Setup

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Pet App V3"; Filename: "{app}\pet_app_v3.exe"
```

#### macOS
```bash
# 1. 构建macOS应用
flutter build macos --release

# 2. 创建DMG安装包
# 使用create-dmg工具
create-dmg \
  --volname "Pet App V3" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --app-drop-link 425 120 \
  "PetAppV3.dmg" \
  "build/macos/Build/Products/Release/"
```

## 监控和运维

### 1. 应用监控

#### 性能监控
```dart
// lib/core/monitoring/performance_monitor.dart
class PerformanceMonitor {
  static void trackAppStart() {
    // 记录应用启动时间
  }
  
  static void trackPageLoad(String pageName, Duration loadTime) {
    // 记录页面加载时间
  }
  
  static void trackMemoryUsage() {
    // 记录内存使用情况
  }
}
```

#### 错误监控
```dart
// lib/core/monitoring/error_monitor.dart
class ErrorMonitor {
  static void reportError(Object error, StackTrace stackTrace) {
    // 上报错误信息
  }
  
  static void reportCrash(String crashInfo) {
    // 上报崩溃信息
  }
}
```

### 2. 用户分析

#### 使用统计
```dart
// lib/core/analytics/usage_analytics.dart
class UsageAnalytics {
  static void trackEvent(String eventName, Map<String, dynamic> parameters) {
    // 记录用户行为事件
  }
  
  static void trackScreenView(String screenName) {
    // 记录页面访问
  }
  
  static void setUserProperty(String name, String value) {
    // 设置用户属性
  }
}
```

### 3. 更新机制

#### 热更新配置
```dart
// lib/core/update/update_manager.dart
class UpdateManager {
  static Future<bool> checkForUpdates() async {
    // 检查应用更新
    return false;
  }
  
  static Future<void> downloadUpdate() async {
    // 下载更新包
  }
  
  static Future<void> installUpdate() async {
    // 安装更新
  }
}
```

## 安全配置

### 1. 代码混淆

#### Android ProGuard
```proguard
# android/app/proguard-rules.pro
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
```

#### iOS代码保护
```xml
<!-- ios/Runner.xcconfig -->
ENABLE_BITCODE = YES
SWIFT_OPTIMIZATION_LEVEL = -O
GCC_OPTIMIZATION_LEVEL = s
```

### 2. 证书管理

#### Android签名
```bash
# 生成签名密钥
keytool -genkey -v -keystore release-key.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000

# 配置签名
# android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=release
storeFile=release-key.keystore
```

#### iOS证书
```bash
# 开发证书
# 1. 在Apple Developer Portal创建证书
# 2. 下载并安装到Keychain
# 3. 在Xcode中配置Provisioning Profile

# 发布证书
# 1. 创建Distribution证书
# 2. 创建App Store Provisioning Profile
# 3. 配置Xcode项目设置
```

## 故障排除

### 常见构建问题

#### Flutter版本不兼容
```bash
# 检查Flutter版本
flutter --version

# 升级Flutter
flutter upgrade

# 清理缓存
flutter clean
flutter pub get
```

#### 依赖冲突
```bash
# 查看依赖树
flutter pub deps

# 解决冲突
flutter pub upgrade
```

#### 平台特定问题
```bash
# Android构建失败
cd android && ./gradlew clean
cd .. && flutter clean && flutter pub get

# iOS构建失败
cd ios && rm -rf Pods Podfile.lock
pod install
cd .. && flutter clean && flutter pub get
```

## 发布后维护

### 1. 监控指标
- **崩溃率**: < 0.1%
- **ANR率**: < 0.1%
- **启动时间**: < 2秒
- **内存使用**: < 100MB
- **用户评分**: > 4.5星

### 2. 更新策略
- **紧急修复**: 24小时内发布
- **常规更新**: 2-4周周期
- **大版本更新**: 3-6个月周期

### 3. 用户反馈处理
- **应用商店评论**: 48小时内回复
- **用户支持**: 24小时内响应
- **Bug修复**: 根据严重程度1-7天

---

**文档版本**: v3.3.0  
**最后更新**: 2025-07-19  
**维护团队**: Pet App V3 Team
